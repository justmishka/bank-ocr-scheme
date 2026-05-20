#lang racket/base

;; OCR parser — ASCII art (3 lines × 27 chars) → digit string.
;; Each digit is a 3×3 block. Unrecognized blocks become "?".
;;
;; DIGIT-TABLE is the single source of truth for digit ↔ ASCII pattern.
;; The parser hashes it for fast lookup; corrector uses the raw list for
;; Hamming-distance neighbor search.

(require racket/string
         racket/list)

(provide DIGIT-TABLE
         parse-digit
         parse-entry
         parse-file
         split-entries
         pad-right)

(define DIGIT-TABLE
  '(("0" . " _ | ||_|")
    ("1" . "     |  |")
    ("2" . " _  _||_ ")
    ("3" . " _  _| _|")
    ("4" . "   |_|  |")
    ("5" . " _ |_  _|")
    ("6" . " _ |_ |_|")
    ("7" . " _   |  |")
    ("8" . " _ |_||_|")
    ("9" . " _ |_| _|")))

(define DIGIT-PATTERNS
  (for/hash ([entry (in-list DIGIT-TABLE)])
    (values (cdr entry) (car entry))))

(define (pad-right s n)
  (if (< (string-length s) n)
      (string-append s (make-string (- n (string-length s)) #\space))
      s))

(define (parse-digit top mid bot)
  (hash-ref DIGIT-PATTERNS (string-append top mid bot) "?"))

(define (parse-entry lines)
  (unless (= (length lines) 3)
    (error 'parse-entry "Entry must have exactly 3 lines, got ~a" (length lines)))
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

(define (blank-line? s)
  (zero? (string-length (string-trim s))))

;; Returns list of 3-line entries (each list of 3 padded-to-27 strings).
;; Source format: each entry is 4 lines (3 digit lines + 1 blank separator).
;; The blank separator after the final entry is optional.
;; Strict 4-line grouping is required because digit "1"'s top row is all
;; spaces, so we cannot use blank-line detection to split.
(define (split-entries content)
  (cond
    [(or (not content) (zero? (string-length (string-trim content)))) '()]
    [else
     (define lines (strip-trailing-empty (string-split content "\n" #:trim? #f)))
     (define total (length lines))
     (let loop ([i 0] [acc '()])
       (cond
         [(>= i total) (reverse acc)]
         [(> (+ i 3) total)
          (error 'split-entries
                 "Incomplete entry starting at line ~a: need 3 digit lines, got ~a remaining"
                 (add1 i)
                 (- total i))]
         [else
          (define entry
            (list (pad-right (list-ref lines i) 27)
                  (pad-right (list-ref lines (+ i 1)) 27)
                  (pad-right (list-ref lines (+ i 2)) 27)))
          (define sep-idx (+ i 3))
          (when (< sep-idx total)
            (unless (blank-line? (list-ref lines sep-idx))
              (error 'split-entries
                     "Missing blank separator after entry ending at line ~a (got: ~v)"
                     (+ i 3)
                     (list-ref lines sep-idx))))
          (loop (+ i 4) (cons entry acc))]))]))

(define (parse-file content)
  (map parse-entry (split-entries content)))
