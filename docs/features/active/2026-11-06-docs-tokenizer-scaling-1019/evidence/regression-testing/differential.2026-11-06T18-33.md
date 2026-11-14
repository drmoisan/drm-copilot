# Differential Run, Unfixed Against Fixed - Issue 1019

Timestamp: 2026-11-06T18-33
Command: sh SCRATCH/issue-1019-p2-par.sh (SCRATCH/issue-1019-diff-inputs.ps1 writes SCRATCH/diff/inputs.jsonl; SCRATCH/issue-1019-differential.ps1 runs 12 partition processes on SCRATCH/unfixed and 6 on SCRATCH/fixed-tree, one module per process; SCRATCH/issue-1019-diff-compare.ps1 compares the records; SCRATCH/issue-1019-diff-scale.ps1 runs the final module alone on the scaling shapes)
EXIT_CODE: 0
Output Summary: 1098 inputs compared, zero differing hashes, zero missing records. The fixed-only scaling inputs report zero diagnostics and exact reconstruction for all 15 shape and size pairs. Unfixed module hash 4ec8d9c5006a7ad2648a87cbba9a7f42136330cda94c9704b5ff980b68dbab53. Final MODULE hash 6010cf357e5816136cf60b8d0e7dcf52f85555c42c7ec37b7e65883493ab9cbf. Input file SHA-256 767392daf127bf5411cb9bd0d20e679105f8b047a5d330ade4457ffddcb70c91. HEAD 39a0bdbe17ab8ad3bd5d2cfe1453184013ba4ff4.

## Per Input Class

| Input class | Included | Excluded | Identical | Differing | Tokens (fixed) | With diagnostics |
| --- | --- | --- | --- | --- | --- | --- |
| Tracked `*.py` files at `HEAD`, at most 64,000 characters | 993 | 0 | 993 | 0 | 1,908,471 | 0 |
| `Case` inputs of `reports <Code> as a blocking error for: <Case>` | 12 | 0 | 12 | 0 | 134 | 12 |
| Generated, each string form, seed 101911 | 54 | 0 | 54 | 0 | 128,945 | 0 |
| Generated, each diagnostic past the first window, seed 101911 | 39 | 0 | 39 | 0 | 78,814 | 39 |
| Token-limit input | 0 | 1 | not compared | not compared | not applicable | not applicable |
| 1,048,576-byte comment input | 0 | 1 | not compared | not compared | not applicable | not applicable |

Exclusion reason: the token-limit and 1,048,576-byte inputs are excluded from the unfixed run because of its run time on those sizes, as the plan states. `SUITE` covers both on the fixed module. No tracked Python file exceeds 64,000 characters; the longest input is 26,368 characters. No shape was excluded.

## Generated Inputs

There are 18 string forms and 13 diagnostic forms, with three seeded variants of each. Generated lengths range from 3,543 to 7,104 characters, with an average of 4,971. Sizes were not reduced to shorten the run.

| Diagnostic code | Generated inputs (fixed) | `SUITE` case inputs (fixed) |
| --- | --- | --- |
| `PYTHON_ENCODING_UNSUPPORTED` | 3 | 1 |
| `PYTHON_LEXER_UNCLASSIFIED` | 15 | 5 |
| `PYTHON_LEXER_UNTERMINATED` | 21 | 6 |

The coding cookie is read from the first two lines only, so those inputs place it past the first window with a first line of 2,000 to 3,000 characters. Each string-form input repeats its form after a filler of about 1,000 to 1,100 characters, so later occurrences lie past the first window.

## Fixed-Only Scaling Inputs

| Shape | Units | Characters | Tokens | Diagnostics | Exact reconstruction |
| --- | --- | --- | --- | --- | --- |
| `names` | 2,000 | 4,000 | 4,000 | 0 | yes |
| `strings` | 2,000 | 8,000 | 4,000 | 0 | yes |
| `long-string-body` | 2,000 | 4,002 | 1 | 0 | yes |
| `names` | 4,000 | 8,000 | 8,000 | 0 | yes |
| `strings` | 4,000 | 16,000 | 8,000 | 0 | yes |
| `long-string-body` | 4,000 | 8,002 | 1 | 0 | yes |
| `names` | 8,000 | 16,000 | 16,000 | 0 | yes |
| `strings` | 8,000 | 32,000 | 16,000 | 0 | yes |
| `long-string-body` | 8,000 | 16,002 | 1 | 0 | yes |
| `names` | 16,000 | 32,000 | 32,000 | 0 | yes |
| `strings` | 16,000 | 64,000 | 32,000 | 0 | yes |
| `long-string-body` | 16,000 | 32,002 | 1 | 0 | yes |
| `names` | 32,000 | 64,000 | 64,000 | 0 | yes |
| `strings` | 32,000 | 128,000 | 64,000 | 0 | yes |
| `long-string-body` | 32,000 | 64,002 | 1 | 0 | yes |

## Serialized Fields

Each token contributes Type, Text with its length, Line, Column, EndLine, Depth, Prefix, Quote, IsTriple, HasEscape, IsBytes, IsFormat, IsRaw, and IsKeyword. A field a token does not carry is serialized as an explicit absent marker, so an added or dropped field changes the hash. Each diagnostic contributes Code, Severity, Blocking, and Line. The hash is SHA-256 of the canonical string.

## Negative Control

This check is additional to the task acceptance. `SCRATCH/issue-1019-mut-check.ps1` ran the same differential script on a scratch copy of the final module with `$script:DocsPythonTokenWindowMargin` set to 0, over the 93 generated inputs, and compared the hashes with the fixed records: 80 differ and 13 are the same. The comparison can therefore report a difference when tokens change.
