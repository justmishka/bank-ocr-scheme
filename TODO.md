# Bank OCR (Racket) — Requirements

This file is the **single source of truth** for what needs to be built. No Jira.
The team works story-by-story: Finn implements, Dex adds tests, Sage reviews.

**Source kata:** https://codingdojo.org/kata/BankOCR/
**Original repo (Python reference):** https://github.com/justmishka/workshop-bank-ocr

---

## Product Description

A bank's scanning machine produces files with account numbers written in ASCII
art using pipes (`|`) and underscores (`_`). This tool is a Racket console app
that:

1. Parses OCR output files into readable account numbers.
2. Validates account numbers using a checksum algorithm.
3. Prints output with validation status (valid / `ERR` / `ILL`).
4. Attempts error correction for invalid or illegible numbers.

**No UI.** Stdin → stdout (or file path argument). That's it.

---

## Digit Reference

Each digit is a 3-wide × 3-tall ASCII block. Account numbers are 9 digits → 27
characters per row × 3 rows. Entries are separated by a blank 4th line.

```
 _     _  _     _  _  _  _  _
| |  | _| _||_||_ |_   ||_||_|
|_|  ||_  _|  | _||_|  ||_| _|

 0  1  2  3  4  5  6  7  8  9
```

---

## Story 1 — Parse OCR digits  (2 pts)

> As a user, I want to parse an OCR file so that I get readable account numbers.

**Acceptance Criteria:**
- Given a valid OCR file → returns correct 9-digit account number string.
- Given multiple entries → each parsed separately.
- Given an unrecognized 3×3 pattern → that digit becomes `?`.

**Files:** `src/parser.rkt`, `tests/test-parser.rkt`
**Status:** [ ] Not started

---

## Story 2 — Validate checksum  (1 pt)

> As a user, I want account numbers validated so I know which ones are correct.

**Formula:** `(d1 + 2·d2 + 3·d3 + … + 9·d9) mod 11 = 0`
where `d1` is the **rightmost** digit. Right-to-left ordering — watch out.

**Acceptance Criteria:**
- `345882865` → valid.
- `664371495` → invalid.
- Account containing `?` → returns false (illegible, skip checksum).

**Files:** `src/checksum.rkt`, `tests/test-checksum.rkt`
**Status:** [ ] Not started

---

## Story 3 — Format output with status  (1 pt)

> As a user, I want formatted output so I can see which accounts are valid,
> invalid, or illegible.

**Format:**
```
345882865
664371495 ERR
86110??36 ILL
```

**Acceptance Criteria:**
- Valid account → just the 9-digit number, nothing else.
- Invalid checksum → `<number> ERR`.
- Illegible (`?` present) → `<number> ILL`.

**Files:** `src/formatter.rkt`, `tests/test-formatter.rkt`
**Status:** [ ] Not started

---

## Story 4 — Error correction  (3 pts, stretch)

> As a user, I want the system to attempt to fix errors so that I recover as
> many valid numbers as possible.

**Approach:** For `ERR` / `ILL` accounts, try every single-pipe-or-underscore
modification. One valid match → use it. Multiple → `AMB` with list. None →
keep original status.

**Acceptance Criteria:**
- `ERR` account with exactly one valid single-char fix → corrected.
- `ILL` account with exactly one valid single-char fix → corrected.
- Multiple corrections → `<original> AMB ['cand1', 'cand2', …]`.

**Files:** `src/corrector.rkt`, `tests/test-corrector.rkt`
**Status:** [ ] Not started

---

## Story 5 — CLI entry point  (1 pt)

> As a user, I want to run `bank-ocr <file>` (or pipe stdin) and see the result.

**Acceptance Criteria:**
- `racket main.rkt samples/sample.txt` → prints expected output.
- `cat samples/sample.txt | racket main.rkt` → same.
- No file + no stdin → friendly error message.

**Files:** `main.rkt`
**Status:** [ ] Skeleton in place, needs glue once S1-S3 done.

---

## Definition of Done (per story)

- [ ] Implementation in `src/<module>.rkt`.
- [ ] Tests in `tests/test-<module>.rkt` — at least 2 new tests beyond the spec examples (Dex's QA rule).
- [ ] All tests pass: `raco test tests/`.
- [ ] Sage code review approved.
- [ ] No `error '<fn> "not implemented"` stubs left in the changed module.

---

## Engineering Standards (non-negotiable)

These apply even though there's no Jira. From `team/agents/context/shared/engineering-standards.md`:

- Small, focused functions. Pure where possible.
- Idiomatic Racket — `racket/base` over `racket`, contracts where they add safety, no needless mutation.
- Tests must exercise the spec, not just the happy path.
- Clean commit messages. One concern per PR.

---

## How to run

```bash
# Run the app
racket main.rkt samples/sample.txt

# Run all tests
raco test tests/

# Run a single test file
raco test tests/test-parser.rkt
```
