#lang racket/base

;; Bank OCR — console entry point.
;;
;; Usage:
;;   racket main.rkt <file>
;;   cat <file> | racket main.rkt
;;
;; Reads OCR text, parses each 4-line entry to an account number, validates
;; the checksum, attempts single-OCR-char correction for ERR/ILL accounts,
;; and prints one result per line to stdout.

(require racket/cmdline
         racket/port
         "src/parser.rkt"
         "src/checksum.rkt"
         "src/formatter.rkt"
         "src/corrector.rkt")

(provide process-content
         load-input
         run)

(define (process-entry entry-lines)
  (define parsed (parse-entry entry-lines))
  (cond
    [(valid-checksum? parsed) parsed]
    [else
     (define corrected (correct-account entry-lines parsed))
     (cond
       [(string? corrected) corrected]      ; uniquely corrected
       [(ambiguous? corrected) corrected]   ; AMB (passed to formatter)
       [else parsed])]))                    ; falls through to ERR/ILL

(define (process-content content)
  (for/list ([entry (in-list (split-entries content))])
    (format-account (process-entry entry))))

;; Tagged result so the CLI driver — and tests — can react without exiting.
;; Returns either:
;;   (list 'ok content-string)  on successful read,
;;   (list 'error message)       on user-visible failures.
(define (load-input source)
  (cond
    [(eq? source 'stdin)
     (cond
       [(terminal-port? (current-input-port))
        (list 'error "no input. Usage: racket main.rkt <file> | echo … | racket main.rkt")]
       [else
        (list 'ok (port->string (current-input-port)))])]
    [(not (file-exists? source))
     (list 'error (format "file not found: ~a" source))]
    [else
     (list 'ok (call-with-input-file source port->string))]))

(define (fail msg [code 2])
  (eprintf "bank-ocr: ~a~n" msg)
  (exit code))

(define (run source)
  (define result (load-input source))
  (case (car result)
    [(error) (fail (cadr result))]
    [(ok)
     (with-handlers ([exn:fail? (lambda (e) (fail (exn-message e)))])
       (for ([line (in-list (process-content (cadr result)))])
         (displayln line)))]))

(define (main)
  (command-line
   #:program "bank-ocr"
   #:args args
   (cond
     [(null? args) (run 'stdin)]
     [(null? (cdr args)) (run (car args))]
     [else (fail
            (format "usage: bank-ocr [file] — expected 0 or 1 args, got ~a" (length args)))])))

(module+ main
  (main))
