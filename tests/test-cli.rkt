#lang racket/base

;; Integration test for main.rkt — exercises the full pipeline.

(require rackunit
         "../main.rkt")

(test-case "process-content: sample produces 3 lines"
  (define content
    (string-append
     "    _  _     _  _  _  _  _ \n"
     "  | _| _||_||_ |_   ||_||_|\n"
     "  ||_  _|  | _||_|  ||_| _|\n"
     "\n"
     " _  _  _  _  _  _  _  _  _ \n"
     "| || || || || || || || || |\n"
     "|_||_||_||_||_||_||_||_||_|\n"
     "\n"
     "                           \n"
     "  |  |  |  |  |  |  |  |  |\n"
     "  |  |  |  |  |  |  |  |  |\n"))
  (define out (process-content content))
  (check-equal? (length out) 3)
  (check-equal? (list-ref out 0) "123456789")
  (check-equal? (list-ref out 1) "000000000")
  ;; 111111111 is invalid checksum, corrected to 711111111
  (check-equal? (list-ref out 2) "711111111"))

(test-case "process-content: empty input → empty output"
  (check-equal? (process-content "") '()))
