#lang racket/base

;; Output formatting.
;; Input is one of:
;;   - a 9-char digit string ("valid" / "ERR" / "ILL"), or
;;   - an `ambiguous` struct for the AMB case from corrector.

(require racket/string
         "checksum.rkt"
         "corrector.rkt")

(provide format-account
         illegible?)

(define (illegible? account)
  (for/or ([ch (in-string account)]) (char=? ch #\?)))

(define (format-account result)
  (cond
    [(ambiguous? result)
     (format "~a AMB [~a]"
             (ambiguous-original result)
             (string-join
              (map (lambda (c) (format "'~a'" c)) (ambiguous-candidates result))
              ", "))]
    [(illegible? result) (string-append result " ILL")]
    [(valid-checksum? result) result]
    [else (string-append result " ERR")]))
