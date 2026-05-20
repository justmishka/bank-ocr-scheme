#lang racket/base

;; Error correction. For each digit position, find every valid digit whose
;; 3×3 pattern differs from the OCR pattern at that position by exactly one
;; character. Substitute and check the resulting account's checksum.
;;
;; Returns:
;;   - 9-char string if exactly one valid single-char correction exists,
;;   - `ambiguous` struct if multiple corrections are valid,
;;   - #f if no correction makes the checksum valid.

(require racket/list
         "parser.rkt"
         "checksum.rkt")

(provide correct-account
         (struct-out ambiguous))

(struct ambiguous (original candidates) #:transparent)

(define (hamming-distance s1 s2)
  (for/sum ([c1 (in-string s1)]
            [c2 (in-string s2)])
    (if (char=? c1 c2) 0 1)))

(define (digit-pattern-at entry-lines pos)
  (define top (pad-right (list-ref entry-lines 0) 27))
  (define mid (pad-right (list-ref entry-lines 1) 27))
  (define bot (pad-right (list-ref entry-lines 2) 27))
  (define start (* pos 3))
  (string-append (substring top start (+ start 3))
                 (substring mid start (+ start 3))
                 (substring bot start (+ start 3))))

(define (neighbors-for-pattern pattern)
  ;; Digit candidates whose pattern is exactly 1 OCR-char from `pattern`.
  ;; A distance-0 match (the digit itself) is naturally excluded.
  (for/list ([entry (in-list DIGIT-TABLE)]
             #:when (= 1 (hamming-distance pattern (cdr entry))))
    (car entry)))

(define (replace-at-pos s pos new-ch)
  (string-append (substring s 0 pos)
                 (string new-ch)
                 (substring s (add1 pos))))

(define (correct-account entry-lines parsed)
  (define candidates
    (for*/list ([pos (in-range 9)]
                [new-digit (in-list (neighbors-for-pattern
                                     (digit-pattern-at entry-lines pos)))])
      (replace-at-pos parsed pos (string-ref new-digit 0))))
  (define valid (remove-duplicates (filter valid-checksum? candidates)))
  (cond
    [(null? valid) #f]
    [(= 1 (length valid)) (car valid)]
    [else (ambiguous parsed (sort valid string<?))]))
