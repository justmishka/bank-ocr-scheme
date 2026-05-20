#lang racket/base

;; Checksum: (d1 + 2·d2 + ··· + 9·d9) mod 11 = 0
;; d1 is the RIGHTMOST digit; digits are weighted right-to-left.
;; For a left-to-right string of 9 digits, position i (0-indexed) carries
;; weight (9 - i).

(provide valid-checksum?)

(define (valid-checksum? account)
  (cond
    [(not (= 9 (string-length account))) #f]
    [(for/or ([ch (in-string account)]) (char=? ch #\?)) #f]
    [(for/or ([ch (in-string account)])
       (not (and (char>=? ch #\0) (char<=? ch #\9))))
     #f]
    [else
     (define total
       (for/sum ([ch (in-string account)]
                 [i (in-naturals)])
         (* (- (char->integer ch) (char->integer #\0))
            (- 9 i))))
     (zero? (modulo total 11))]))
