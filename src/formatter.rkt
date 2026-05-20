#lang racket/base

;; Output formatting.
;; Input is either:
;;   - a 9-char digit string ("valid" / "ERR" / "ILL"), or
;;   - a pair (account . list-of-candidates) for the AMB case from corrector.

(require racket/string
         "checksum.rkt")

(provide format-account)

(define (illegible? account)
  (for/or ([ch (in-string account)]) (char=? ch #\?)))

(define (format-account result)
  (cond
    [(pair? result)
     (define original (car result))
     (define candidates (cdr result))
     (format "~a AMB [~a]"
             original
             (string-join
              (map (lambda (c) (format "'~a'" c)) candidates)
              ", "))]
    [(illegible? result) (string-append result " ILL")]
    [(valid-checksum? result) result]
    [else (string-append result " ERR")]))
