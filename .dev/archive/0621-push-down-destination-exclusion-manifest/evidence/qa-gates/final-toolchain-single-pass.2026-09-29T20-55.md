# Final toolchain single-clean-pass record — [P12-T1] (AC-27, US-23)

Timestamp: 2026-09-29T20-55
Command: git log --format='%h %ad %s' --date=format:'%Y-%m-%dT%H:%M' 9438bdf5253e10903e2e74eab5cf51df988e0466..HEAD --name-only -- . ":(exclude)docs"
EXIT_CODE: 0
Output Summary: the last commit that changes a file outside `docs/` is `79a89747` (2026-09-29T20:45, README.md); the last source or test change is `4eb74cee` (2026-09-29T20:42). Phases 9, 10, and 11 changed no file outside the feature's evidence folder and plan checklist. Python and TypeScript each passed format, lint, type check, and tests with coverage in iteration 1, after the last file change, with no step changing a file or failing. PASS.

## Python — Phase 10, iteration 1 (the only iteration)

Ran from HEAD `e97a73db` with an empty `git status --porcelain`, after `79a89747`.

| Step | Artifact | Result |
|---|---|---|
| Format (write mode) | evidence/qa-gates/final-python-black.2026-09-29T20-48.md | `529 files left unchanged.`, no `reformatted` |
| Lint | evidence/qa-gates/final-python-ruff.2026-09-29T20-49.md | `All checks passed!` |
| Type check | evidence/qa-gates/final-python-pyright.2026-09-29T20-50.md | `0 errors, 0 warnings, 0 informations` |
| Tests with coverage | evidence/qa-gates/final-python-pytest-coverage.2026-09-29T20-51.md | `5661 passed, 6 skipped`, 0 failed; TOTAL 91% |
| Coverage delta | evidence/qa-gates/python-coverage-delta.2026-09-29T20-52.md | three modules >= 85/75; entry point not below baseline; 0 changed lines missing |

## TypeScript — Phase 11, iteration 1 (the only iteration)

Ran from HEAD `581f42e8` with an empty `git status --porcelain`, after `79a89747`.

| Step | Artifact | Result |
|---|---|---|
| Format (write mode) | evidence/qa-gates/final-ts-prettier.2026-09-29T20-52.md | 471 of 471 file lines `(unchanged)` |
| Lint | evidence/qa-gates/final-ts-eslint.2026-09-29T20-52.md | exit 0, no `problem` line |
| Type check | evidence/qa-gates/final-ts-tsc.2026-09-29T20-52.md | exit 0, no `error TS` line |
| Tests with coverage | evidence/qa-gates/final-ts-jest-coverage.2026-09-29T20-53.md | `3315 passed, 3315 total`; no threshold failure |
| Coverage delta | evidence/qa-gates/typescript-coverage-delta.2026-09-29T20-54.md | six files >= 85/75; no regression; 0 changed lines at 0 hits |

## Bundle-contract tests

- [P4-T7] artifact: evidence/regression-testing/python-bundle-contracts-after.2026-09-30T00-24.md (`16 passed`).
- The same two suites (`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`, `tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py`) ran again inside the Phase 10 whole-suite gate after the last file change and passed, with the issue #510 hook state file set aside and restored with an identical SHA-256 (recorded in the [P10-T4] artifact). The TypeScript bundle suites ran inside the Phase 11 whole-suite gate and passed.

## Rerun rule

No Phase 11 iteration and no Phase 9 remediation changed a file after Phase 10 completed, so the conditional re-run of Phase 10 does not apply.

## Timestamp note

Artifact file-name timestamps are not a reliable ordering signal in this feature folder. The Phases 1 to 7 artifacts carry `2026-09-30T00-xx` names although their commits are dated 2026-09-29T20:12 to 20:42. The Phase 8 and Phase 9 artifacts in this run (`20-45` and `20-50` to `20-54`) were named a few minutes ahead of the system clock, which read 20-48 at the start of Phase 10; the Phase 10 to 12 artifacts use the system clock. Ordering in this record is taken from commit order: Phase 8 `79a89747`, Phase 9 `e97a73db`, Phase 10 `581f42e8`, Phase 11 `408ae4f7`.
