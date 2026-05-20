#lang racket/base

;; Bank OCR — console entry point.
;; Reads an OCR file from a path argument (or stdin if no argument),
;; prints parsed account numbers with validation status to stdout.

(require racket/cmdline
         "src/parser.rkt"
         "src/checksum.rkt"
         "src/formatter.rkt")

(define (read-input source)
  (cond
    [(eq? source 'stdin) (port->string (current-input-port))]
    [else (call-with-input-file source port->string)]))

(define (main)
  (command-line
   #:program "bank-ocr"
   #:args input-path
   (let* ([source (if (null? input-path) 'stdin (car input-path))]
          [content (read-input source)]
          [accounts (parse-file content)])
     (for ([account (in-list accounts)])
       (displayln (format-account account))))))

(require racket/port)

(module+ main
  (main))
