#lang racket/base

(require rackunit
         "../src/checksum.rkt")

(test-case "checksum: 345882865 valid (kata example)"
  (check-true (valid-checksum? "345882865")))

(test-case "checksum: 123456789 valid"
  (check-true (valid-checksum? "123456789")))

(test-case "checksum: 000000000 valid (zero sum)"
  (check-true (valid-checksum? "000000000")))

(test-case "checksum: 664371495 invalid (kata example)"
  (check-false (valid-checksum? "664371495")))

(test-case "checksum: 111111111 invalid"
  (check-false (valid-checksum? "111111111")))

(test-case "checksum: illegible (contains ?) is false"
  (check-false (valid-checksum? "86110??36"))
  (check-false (valid-checksum? "????????")))

(test-case "checksum: rejects wrong length"
  (check-false (valid-checksum? ""))
  (check-false (valid-checksum? "12345678"))
  (check-false (valid-checksum? "1234567890")))

(test-case "checksum: rejects non-digit characters"
  (check-false (valid-checksum? "12345678X"))
  (check-false (valid-checksum? "abcdefghi")))

(test-case "checksum: 711111111 valid (corrector target)"
  (check-true (valid-checksum? "711111111")))
