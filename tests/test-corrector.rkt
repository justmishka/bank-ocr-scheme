#lang racket/base

(require rackunit
         "../src/parser.rkt"
         "../src/corrector.rkt")

;; Test helper: encode a digit string into a 3-line OCR entry using the
;; canonical patterns from DIGIT-TABLE. Lets tests build inputs by stating
;; the intended account number instead of hand-drawing ASCII art.
(define (encode digits-string)
  (define patterns
    (for/list ([ch (in-string digits-string)])
      (cdr (assoc (string ch) DIGIT-TABLE))))
  (define (row n)
    (apply string-append
           (map (lambda (p) (substring p (* n 3) (+ 3 (* n 3)))) patterns)))
  (list (row 0) (row 1) (row 2)))

(test-case "encode helper round-trips through parse-entry"
  (check-equal? (parse-entry (encode "123456789")) "123456789")
  (check-equal? (parse-entry (encode "000000000")) "000000000"))

(test-case "corrector: 111111111 → uniquely fixes to 711111111"
  (check-equal? (correct-account (encode "111111111") "111111111") "711111111"))

(test-case "corrector: 000000000 has no valid single-char correction → #f"
  ;; Only neighbor of 0 in OCR space is 8; none of the 9 8-substitutions
  ;; produces a valid checksum.
  (check-equal? (correct-account (encode "000000000") "000000000") #f))

(test-case "corrector: kata AMB case 888888888"
  (define result (correct-account (encode "888888888") "888888888"))
  (check-true (ambiguous? result) "expected ambiguous struct")
  (check-equal? (ambiguous-original result) "888888888")
  (check-equal? (ambiguous-candidates result)
                '("888886888" "888888880" "888888988")))

(test-case "corrector: ILL with single fixable ? recovers the original"
  ;; Take 123456789, corrupt position 0's middle row so digit "1" becomes "?".
  ;; The middle row of "1" is "  |"; replacing with "   " (one OCR-char less)
  ;; leaves a pattern that's exactly 1 char from "1" → corrector recovers it.
  (define entry (encode "123456789"))
  (define top (list-ref entry 0))
  (define mid (list-ref entry 1))
  (define bot (list-ref entry 2))
  ;; The mid row at digit-0 (pos 0..2) is "  |"; blank out the '|'.
  (define mid-broken (string-append "   " (substring mid 3)))
  (check-equal? (correct-account (list top mid-broken bot) "?23456789")
                "123456789"))
