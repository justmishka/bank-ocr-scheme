#lang racket/base

(require rackunit
         "../src/parser.rkt")

;; ASCII art reference for digits 0-9
;; (each row is 3 chars × 10 digits = 30 chars total in original kata table,
;; here split into individual 3-char patterns)

(define digit-0-top " _ ") (define digit-0-mid "| |") (define digit-0-bot "|_|")
(define digit-1-top "   ") (define digit-1-mid "  |") (define digit-1-bot "  |")
(define digit-2-top " _ ") (define digit-2-mid " _|") (define digit-2-bot "|_ ")

(test-case "parse-digit recognizes 0"
  (check-equal? (parse-digit digit-0-top digit-0-mid digit-0-bot) "0"))

(test-case "parse-digit recognizes 1"
  (check-equal? (parse-digit digit-1-top digit-1-mid digit-1-bot) "1"))

(test-case "parse-digit returns ? for garbage"
  (check-equal? (parse-digit "xxx" "xxx" "xxx") "?"))

;; TODO: add tests for all digits 0-9, parse-entry, parse-file
