# Bank OCR (Racket)

Bank OCR kata, reimplemented in [Racket](https://racket-lang.org/) (Scheme dialect)
as a console app — no UI, just stdin/file → stdout.

**Source kata:** [codingdojo.org/kata/BankOCR](https://codingdojo.org/kata/BankOCR/)
**Python reference:** [justmishka/workshop-bank-ocr](https://github.com/justmishka/workshop-bank-ocr)

## What it does

Parses ASCII-art bank account numbers (output of a paper scanner), validates them
against a checksum, and prints each account with its status:

```
345882865
664371495 ERR
86110??36 ILL
888888888 AMB ['888886888', '888888880', '888888988']
```

`AMB` lines come from the error-correction pass: when an `ERR` or `ILL` number
has more than one valid single-OCR-char fix, all candidates are listed.

## Requirements

[Racket](https://racket-lang.org/) 8.0+. On macOS: `brew install --cask racket`.

## Usage

```bash
racket main.rkt samples/sample.txt
# or
cat samples/sample.txt | racket main.rkt
```

## Tests

```bash
raco test tests/
```

## Project plan

See [TODO.md](TODO.md) — the full requirements + per-story Definition of Done.
