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

(test-case "checksum: 100000000 invalid (locks in right-to-left weighting)"
  ;; If weighting were left-to-right (d1 = leftmost), sum would be 1·1 = 1.
  ;; Correct right-to-left weighting gives 1·9 = 9. Both ≠ 0, so this case
  ;; doesn't discriminate by itself — paired with 010000000 it does.
  (check-false (valid-checksum? "100000000")))

(test-case "checksum: 123456789 vs reversed weighting discriminator"
  ;; 123456789 right-to-left: 9+16+21+24+25+24+21+16+9 = 165 → 0 mod 11 ✓
  ;;          left-to-right:  1+4+9+16+25+36+49+64+81 = 285 → 10 mod 11 ✗
  ;; If the implementation reversed the direction, this test would flip.
  (check-true (valid-checksum? "123456789")))
