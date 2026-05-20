#lang racket/base

;; OCR parser — ASCII art (3 lines × 27 chars) → digit string.
;; Each digit is a 3×3 block. Unrecognized blocks become "?".

(require racket/string
         racket/list)

(provide parse-digit
         parse-entry
         parse-file
         split-entries
         pad-right)

(define DIGIT-PATTERNS
  (hash
   (string-append " _ " "| |" "|_|") "0"
   (string-append "   " "  |" "  |") "1"
   (string-append " _ " " _|" "|_ ") "2"
   (string-append " _ " " _|" " _|") "3"
   (string-append "   " "|_|" "  |") "4"
   (string-append " _ " "|_ " " _|") "5"
   (string-append " _ " "|_ " "|_|") "6"
   (string-append " _ " "  |" "  |") "7"
   (string-append " _ " "|_|" "|_|") "8"
   (string-append " _ " "|_|" " _|") "9"))

(define (pad-right s n)
  (if (< (string-length s) n)
      (string-append s (make-string (- n (string-length s)) #\space))
      s))

(define (parse-digit top mid bot)
  (hash-ref DIGIT-PATTERNS (string-append top mid bot) "?"))

(define (parse-entry lines)
  (unless (>= (length lines) 3)
    (error 'parse-entry "Entry must have at least 3 lines, got ~a" (length lines)))
  (define top (pad-right (list-ref lines 0) 27))
  (define mid (pad-right (list-ref lines 1) 27))
  (define bot (pad-right (list-ref lines 2) 27))
  (apply string-append
         (for/list ([i (in-range 9)])
           (define s (* i 3))
           (parse-digit (substring top s (+ s 3))
                        (substring mid s (+ s 3))
                        (substring bot s (+ s 3))))))

(define (strip-trailing-empty lines)
  (cond
    [(null? lines) lines]
    [(equal? "" (last lines)) (strip-trailing-empty (drop-right lines 1))]
    [else lines]))

;; Returns list of 3-line entries (each a list of 3 strings, padded to 27).
;; Each entry block is 4 lines in the source: 3 digit lines + 1 separator.
;; We use strict 4-line grouping because digit "1" has an all-spaces top line
;; that would otherwise be mistaken for a separator.
(define (split-entries content)
  (cond
    [(or (not content) (zero? (string-length (string-trim content)))) '()]
    [else
     (define lines (strip-trailing-empty (string-split content "\n" #:trim? #f)))
     (let loop ([i 0] [acc '()])
       (cond
         [(> (+ i 3) (length lines)) (reverse acc)]
         [else
          (define entry
            (list (pad-right (list-ref lines i) 27)
                  (pad-right (list-ref lines (+ i 1)) 27)
                  (pad-right (list-ref lines (+ i 2)) 27)))
          (loop (+ i 4) (cons entry acc))]))]))

(define (parse-file content)
  (map parse-entry (split-entries content)))
