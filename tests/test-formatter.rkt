#lang racket/base

(require rackunit
         "../src/formatter.rkt"
         "../src/corrector.rkt")

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

(test-case "formatter: AMB case via ambiguous struct"
  (check-equal? (format-account (ambiguous "888888888"
                                           '("888886888" "888888880" "888888988")))
                "888888888 AMB ['888886888', '888888880', '888888988']"))

(test-case "formatter: AMB with single candidate (edge case)"
  (check-equal? (format-account (ambiguous "123456789" '("123456780")))
                "123456789 AMB ['123456780']"))
