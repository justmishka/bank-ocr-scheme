#lang racket/base

;; Checksum validation for parsed account numbers.
;; Formula: (d1 + 2*d2 + 3*d3 + ... + 9*d9) mod 11 = 0
;; Note: d1 is the RIGHTMOST digit. Digits are numbered right-to-left.
;;
;; TODO: Story 2 — implement valid-checksum?

(provide valid-checksum?)

(define (valid-checksum? account)
  ;; STUB: takes 9-char digit string, returns #t if checksum valid, #f otherwise.
  ;; If account contains "?", return #f (illegible can't be checksummed).
  (error 'valid-checksum? "not implemented"))
