#lang racket/base

;; Error correction (Story 4 — stretch).
;; For ERR or ILL accounts, try modifying exactly one pipe or underscore.
;; - One valid match  → use it
;; - Multiple matches → mark AMB with list of possibilities
;; - No valid match   → keep as ILL
;;
;; TODO: Story 4 — implement correct-account

(provide correct-account)

(define (correct-account entry-lines)
  ;; STUB: takes raw 3-line OCR entry, returns either:
  ;;  - corrected 9-char digit string, or
  ;;  - (cons 'ambiguous (list-of-candidates)), or
  ;;  - original parse with ILL/ERR status preserved
  (error 'correct-account "not implemented"))
