#lang racket/base

;; Integration tests for main.rkt — exercises the full pipeline including
;; CLI error paths and kata-canonical end-to-end cases.

(require rackunit
         racket/string
         racket/file
         "../src/parser.rkt"
         "../main.rkt")

;; Encode a digit string into a 3-line OCR entry plus blank separator.
(define (encode-entry digits-string)
  (define patterns
    (for/list ([ch (in-string digits-string)])
      (cdr (assoc (string ch) DIGIT-TABLE))))
  (define (row n)
    (apply string-append
           (map (lambda (p) (substring p (* n 3) (+ 3 (* n 3)))) patterns)))
  (string-join (list (row 0) (row 1) (row 2) "") "\n"))

(test-case "process-content: canonical sample produces 3 lines"
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
  ;; 111111111 has invalid checksum; corrector uniquely recovers 711111111.
  (check-equal? (list-ref out 2) "711111111"))

(test-case "process-content: empty input → empty output"
  (check-equal? (process-content "") '()))

(test-case "process-content: 888888888 emits AMB with 3 candidates"
  (define result (car (process-content (encode-entry "888888888"))))
  (check-equal? result
                "888888888 AMB ['888886888', '888888880', '888888988']"))

(test-case "process-content: 490067715 emits AMB with 3 candidates"
  (define result (car (process-content (encode-entry "490067715"))))
  (check-equal? result
                "490067715 AMB ['490067115', '490067719', '490867715']"))

(test-case "process-content: missing separator line raises error"
  ;; Six contiguous digit lines (two entries glued together) is malformed.
  (define content
    (string-append
     " _  _  _  _  _  _  _  _  _ \n"
     "| || || || || || || || || |\n"
     "|_||_||_||_||_||_||_||_||_|\n"
     " _  _  _  _  _  _  _  _  _ \n"
     "| || || || || || || || || |\n"
     "|_||_||_||_||_||_||_||_||_|\n"))
  (check-exn exn:fail? (lambda () (process-content content))))

(test-case "load-input: missing file returns user-friendly error"
  (define result (load-input "/no/such/path/does/not/exist.txt"))
  (check-equal? (car result) 'error)
  (check-true (regexp-match? #rx"file not found" (cadr result))))

(test-case "load-input: existing file returns 'ok with content"
  (define path (make-temporary-file))
  (with-output-to-file path #:exists 'truncate
    (lambda () (display "hello\n")))
  (define result (load-input path))
  (check-equal? (car result) 'ok)
  (check-equal? (cadr result) "hello\n")
  (delete-file path))
