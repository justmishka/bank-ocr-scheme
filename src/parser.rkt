#lang racket/base

;; OCR parser — converts ASCII art account numbers (3 lines × 27 chars) to digit strings.
;; Each digit is a 3×3 block. Unrecognized blocks become "?".
;;
;; TODO: Story 1 — implement parse-digit, parse-entry, parse-file.

(provide parse-digit
         parse-entry
         parse-file)

(define (parse-digit top mid bot)
  ;; STUB: takes three 3-char strings, returns single-char digit string or "?"
  (error 'parse-digit "not implemented"))

(define (parse-entry lines)
  ;; STUB: takes list of 3 lines (each 27 chars), returns 9-char digit string
  (error 'parse-entry "not implemented"))

(define (parse-file content)
  ;; STUB: takes file content string, returns list of 9-char account strings.
  ;; Each entry is 4 lines: 3 digit lines + 1 blank separator.
  (error 'parse-file "not implemented"))
