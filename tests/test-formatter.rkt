#lang racket/base

(require rackunit
         "../src/formatter.rkt")

(test-case "formatter: valid account → just the number"
  (check-equal? (format-account "345882865") "345882865"))

(test-case "formatter: invalid checksum → ERR suffix"
  (check-equal? (format-account "664371495") "664371495 ERR"))

(test-case "formatter: illegible → ILL suffix"
  (check-equal? (format-account "86110??36") "86110??36 ILL"))

;; TODO: AMB case for Story 4
