#lang racket/base

(require rackunit
         "../src/checksum.rkt")

(test-case "checksum: known-valid number 345882865 passes"
  (check-true (valid-checksum? "345882865")))

(test-case "checksum: known-invalid number 664371495 fails"
  (check-false (valid-checksum? "664371495")))

(test-case "checksum: illegible account (contains ?) fails"
  (check-false (valid-checksum? "86110??36")))

;; TODO: add more boundary cases
