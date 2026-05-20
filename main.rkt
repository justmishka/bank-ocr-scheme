#lang racket/base

;; Bank OCR — console entry point.
;;
;; Usage:
;;   racket main.rkt <file>
;;   cat <file> | racket main.rkt
;;
;; Reads OCR text, parses each 4-line entry to an account number, validates the
;; checksum, attempts single-char correction for ERR/ILL accounts, and prints
;; one result per line to stdout.

(require racket/cmdline
         racket/port
         "src/parser.rkt"
         "src/checksum.rkt"
         "src/formatter.rkt"
         "src/corrector.rkt")

(provide process-content)

(define (illegible? s)
  (for/or ([ch (in-string s)]) (char=? ch #\?)))

(define (process-entry entry-lines)
  (define parsed (parse-entry entry-lines))
  (cond
    [(valid-checksum? parsed) parsed]
    [else
     (define corrected (correct-account entry-lines parsed))
     (cond
       [(string? corrected) corrected]                      ; uniquely corrected
       [(pair? corrected) corrected]                        ; AMB (passed to formatter)
       [else parsed])]))                                    ; falls through to ERR/ILL

(define (process-content content)
  (for/list ([entry (in-list (split-entries content))])
    (format-account (process-entry entry))))

(define (read-input source)
  (cond
    [(eq? source 'stdin) (port->string (current-input-port))]
    [else (call-with-input-file source port->string)]))

(define (main)
  (command-line
   #:program "bank-ocr"
   #:args input-path
   (define source (if (null? input-path) 'stdin (car input-path)))
   (define content (read-input source))
   (for ([line (in-list (process-content content))])
     (displayln line))))

(module+ main
  (main))
