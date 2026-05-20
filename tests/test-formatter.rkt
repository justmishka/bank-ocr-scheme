#lang racket/base

(require rackunit
         "../src/formatter.rkt")

(test-case "formatter: valid account → bare number"
  (check-equal? (format-account "345882865") "345882865")
  (check-equal? (format-account "123456789") "123456789")
  (check-equal? (format-account "000000000") "000000000"))

(test-case "formatter: invalid checksum → ERR suffix"
  (check-equal? (format-account "664371495") "664371495 ERR")
  (check-equal? (format-account "111111111") "111111111 ERR"))

(test-case "formatter: illegible → ILL suffix"
  (check-equal? (format-account "86110??36") "86110??36 ILL")
  (check-equal? (format-account "?????????") "????????? ILL"))

(test-case "formatter: AMB case (pair input)"
  (check-equal? (format-account (cons "888888888"
                                      (list "888886888" "888888880")))
                "888888888 AMB ['888886888', '888888880']"))

(test-case "formatter: AMB with single candidate (edge case)"
  ;; Realistically corrector wouldn't return single via pair, but format it cleanly anyway.
  (check-equal? (format-account (cons "123456789" (list "123456780")))
                "123456789 AMB ['123456780']"))
