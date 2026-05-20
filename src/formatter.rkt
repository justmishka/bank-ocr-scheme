#lang racket/base

;; Output formatting for parsed account numbers.
;; Valid: "123456789"
;; Invalid checksum: "664371495 ERR"
;; Illegible: "86110??36 ILL"
;; Ambiguous (Story 4): "123456789 AMB ['123456789', '723456789']"
;;
;; TODO: Story 3 — implement format-account

(provide format-account)

(define (format-account account)
  ;; STUB: takes 9-char digit string (or symbolic representation for AMB),
  ;; returns formatted line per spec above.
  (error 'format-account "not implemented"))
