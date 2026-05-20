#lang racket/base

(require rackunit
         "../src/parser.rkt")

;; Digit patterns for every digit 0..9 (each 3 chars × 3 lines).
(define DIGIT-PATTERNS
  '(("0" " _ " "| |" "|_|")
    ("1" "   " "  |" "  |")
    ("2" " _ " " _|" "|_ ")
    ("3" " _ " " _|" " _|")
    ("4" "   " "|_|" "  |")
    ("5" " _ " "|_ " " _|")
    ("6" " _ " "|_ " "|_|")
    ("7" " _ " "  |" "  |")
    ("8" " _ " "|_|" "|_|")
    ("9" " _ " "|_|" " _|")))

;; Concatenated 9-digit row "012345678" — 27 chars per line.
(define DIGITS-TOP " _     _  _     _  _  _  _ ")     ; digits 0..8 tops
(define DIGITS-MID "| |  | _| _||_||_ |_   ||_|")
(define DIGITS-BOT "|_|  ||_  _|  | _||_|  ||_|")

(test-case "parse-digit: every digit 0-9"
  (for ([entry (in-list DIGIT-PATTERNS)])
    (define expected (list-ref entry 0))
    (define top (list-ref entry 1))
    (define mid (list-ref entry 2))
    (define bot (list-ref entry 3))
    (check-equal? (parse-digit top mid bot)
                  expected
                  (format "digit ~a" expected))))

(test-case "parse-digit: garbage → ?"
  (check-equal? (parse-digit "xxx" "xxx" "xxx") "?")
  (check-equal? (parse-digit "###" "###" "###") "?"))

(test-case "parse-entry: all-digits row 0123456789... (wait, only 9 digits)"
  (check-equal? (parse-entry (list DIGITS-TOP DIGITS-MID DIGITS-BOT))
                "012345678"))

(test-case "parse-entry: all zeros"
  (define top " _  _  _  _  _  _  _  _  _ ")
  (define mid "| || || || || || || || || |")
  (define bot "|_||_||_||_||_||_||_||_||_|")
  (check-equal? (parse-entry (list top mid bot)) "000000000"))

(test-case "parse-entry: all ones (short lines get padded)"
  (define top "")
  (define mid "  |  |  |  |  |  |  |  |  |")
  (define bot "  |  |  |  |  |  |  |  |  |")
  (check-equal? (parse-entry (list top mid bot)) "111111111"))

(test-case "parse-entry: too few lines errors"
  (check-exn exn:fail?
             (lambda () (parse-entry '("foo" "bar")))))

(test-case "parse-entry: unrecognized block becomes ?"
  (define top " _ ")
  (define mid "x x")
  (define bot "|_|")
  (check-equal? (parse-entry (list (string-append top "                        ")
                                   (string-append mid "                        ")
                                   (string-append bot "                        ")))
                "?????????"))

(test-case "split-entries: returns 3 entries from sample"
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
     "  |  |  |  |  |  |  |  |  |\n"
     "\n"))
  (check-equal? (length (split-entries content)) 3))

(test-case "parse-file: empty content returns empty list"
  (check-equal? (parse-file "") '())
  (check-equal? (parse-file "   \n  \n") '()))

(test-case "parse-file: 3 entries parsed correctly"
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
  (check-equal? (parse-file content)
                '("123456789" "000000000" "111111111")))

(test-case "pad-right: pads short strings, leaves long alone"
  (check-equal? (pad-right "abc" 5) "abc  ")
  (check-equal? (pad-right "abcde" 5) "abcde")
  (check-equal? (pad-right "abcdef" 5) "abcdef"))
