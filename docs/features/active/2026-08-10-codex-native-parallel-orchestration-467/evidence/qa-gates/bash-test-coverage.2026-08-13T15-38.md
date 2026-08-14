# Bash final test and coverage receipt

- Recorded at: `2026-08-14T00:43:27Z`
- Command: `bash scripts/bash/shell-qc.sh test --coverage`
- Host invocation: WSL Ubuntu from the repository root
- Coverage output: `evidence/qa-gates/bash-final-kcov.2026-08-13T15-38/cov.xml`
- Exit code: `0`
- Result: `PASS`
- Bats tests: `255 passed / 255 total`
- Line coverage: `1339 / 1461 = 91.6%` (`PASS`, threshold `>= 85%`)
- Branch coverage: `N/A/not-PASS`

Kcov does not provide an authoritative Bash branch-coverage metric for this repository. The Cobertura branch attributes are placeholders and are not treated as measured branch coverage or as a passing result.

The top-level and merged `cov.xml` files are byte-identical. Their SHA-256 is `B4EED1020E26AAF2E849E0AE1D5EB268BD797D7EB9C2BC46FE8B2934C5A6D2E1`.

This completed one consecutive format, check, and test-with-coverage loop without a failed step or formatter-reported change.
