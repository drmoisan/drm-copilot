# rc1 Cycle Scope (P2-T18)

Timestamp: 2026-10-16T02-15
Command: git diff --name-only 832573c22...HEAD; git status --porcelain --untracked-files=all
EXIT_CODE: 0
Output Summary: the listings contain tests/scripts/dev_tools/npm_token_guard_test_support.py, tests/scripts/dev_tools/test_workflow_npm_token_guard.py, and FEATURE/remediation-plan.2026-10-16T00-56.md; every other path is under FEATURE/evidence/ with a filename beginning rc1-, or phase0-instructions-read. inside evidence/remediation-baseline/. Paths outside the permitted set: none.

Abbreviation used below: FEATURE = docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933

## git diff --name-only 832573c22...HEAD (exit 0)

```text
FEATURE/evidence/other/rc1-phase1-handoff.2026-10-16T01-39.md
FEATURE/evidence/qa-gates/rc1-coverage-comparison.2026-10-16T01-52.md
FEATURE/evidence/qa-gates/rc1-final-black.2026-10-16T01-44.md
FEATURE/evidence/qa-gates/rc1-final-coverage-percentages.2026-10-16T01-47.md
FEATURE/evidence/qa-gates/rc1-final-coverage-thresholds.2026-10-16T01-47.md
FEATURE/evidence/qa-gates/rc1-final-loop-single-pass.2026-10-16T01-48.md
FEATURE/evidence/qa-gates/rc1-final-pyright.2026-10-16T01-44.md
FEATURE/evidence/qa-gates/rc1-final-pytest-coverage.2026-10-16T01-47.md
FEATURE/evidence/qa-gates/rc1-final-pytest-guard.2026-10-16T01-44.md
FEATURE/evidence/qa-gates/rc1-final-ruff.2026-10-16T01-44.md
FEATURE/evidence/regression-testing/rc1-pass-after.2026-10-16T01-42.md
FEATURE/evidence/regression-testing/rc1-regex-after-edit.2026-10-16T01-42.md
FEATURE/evidence/regression-testing/rc1-rows-f1.2026-10-16T01-40.md
FEATURE/evidence/regression-testing/rc1-rows-f2-detect.2026-10-16T01-40.md
FEATURE/evidence/regression-testing/rc1-rows-f2-ignore.2026-10-16T01-41.md
FEATURE/evidence/remediation-baseline/phase0-instructions-read.2026-10-16T01-29.md
FEATURE/evidence/remediation-baseline/rc1-baseline-black-check.2026-10-16T01-32.md
FEATURE/evidence/remediation-baseline/rc1-baseline-characterization.2026-10-16T01-37.md
FEATURE/evidence/remediation-baseline/rc1-baseline-coverage-percentages.2026-10-16T01-36.md
FEATURE/evidence/remediation-baseline/rc1-baseline-coverage-thresholds.2026-10-16T01-36.md
FEATURE/evidence/remediation-baseline/rc1-baseline-docstring-f1.2026-10-16T01-37.md
FEATURE/evidence/remediation-baseline/rc1-baseline-docstring-f3.2026-10-16T01-37.md
FEATURE/evidence/remediation-baseline/rc1-baseline-environment.2026-10-16T01-31.md
FEATURE/evidence/remediation-baseline/rc1-baseline-id-absence.2026-10-16T01-32.md
FEATURE/evidence/remediation-baseline/rc1-baseline-line-count.2026-10-16T01-37.md
FEATURE/evidence/remediation-baseline/rc1-baseline-line-width.2026-10-16T01-37.md
FEATURE/evidence/remediation-baseline/rc1-baseline-mode-check.2026-10-16T01-30.md
FEATURE/evidence/remediation-baseline/rc1-baseline-production-scope.2026-10-16T01-37.md
FEATURE/evidence/remediation-baseline/rc1-baseline-pyright.2026-10-16T01-32.md
FEATURE/evidence/remediation-baseline/rc1-baseline-pytest-coverage.2026-10-16T01-36.md
FEATURE/evidence/remediation-baseline/rc1-baseline-pytest-guard.2026-10-16T01-32.md
FEATURE/evidence/remediation-baseline/rc1-baseline-regex.2026-10-16T01-37.md
FEATURE/evidence/remediation-baseline/rc1-baseline-ruff-check.2026-10-16T01-32.md
FEATURE/remediation-plan.2026-10-16T00-56.md
tests/scripts/dev_tools/npm_token_guard_test_support.py
tests/scripts/dev_tools/test_workflow_npm_token_guard.py
```

## git status --porcelain --untracked-files=all (exit 0)

```text
 M FEATURE/remediation-plan.2026-10-16T00-56.md
?? FEATURE/evidence/qa-gates/rc1-coverage-comparison.2026-10-16T02-11.md
?? FEATURE/evidence/qa-gates/rc1-docstring-f1.2026-10-16T02-13.md
?? FEATURE/evidence/qa-gates/rc1-docstring-f3.2026-10-16T02-13.md
?? FEATURE/evidence/qa-gates/rc1-issue-unchanged.2026-10-16T02-14.md
?? FEATURE/evidence/qa-gates/rc1-line-count.2026-10-16T02-13.md
?? FEATURE/evidence/qa-gates/rc1-line-width.2026-10-16T02-13.md
?? FEATURE/evidence/qa-gates/rc1-node-listing.2026-10-16T02-11.md
?? FEATURE/evidence/qa-gates/rc1-regex-unchanged.2026-10-16T02-13.md
?? FEATURE/evidence/qa-gates/rc1-scope-boundary.2026-10-16T02-14.md
```
