# scope-boundary

Timestamp: 2026-10-16T00-39
Command: git diff --name-only origin/main...HEAD
EXIT_CODE: 0
Output Summary: Every listed path is an allowed in-scope path or a pre-existing branch path. No path begins with `.github/`, `src/`, `scripts/`, `extensions/`, `.codex/`, `.claude/`, or `tests/fixtures/`. Scope boundary holds.

Let FEATURE = docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933 (paths below are written in full).

## 1. git status --porcelain --untracked-files=all (exit 0)

```text
 M docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/plan.2026-10-15T17-44.md
 M tests/scripts/dev_tools/test_workflow_npm_token_guard.py
?? docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/qa-gates/ac-node-listing.2026-10-16T00-37.md
?? docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/qa-gates/ac2-id-absence.2026-10-16T00-37.md
?? docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/qa-gates/ac5-docstring-pin.2026-10-16T00-37.md
?? docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/qa-gates/ac5-docstring-support.2026-10-16T00-37.md
?? docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/qa-gates/ac8-line-count.2026-10-16T00-38.md
?? docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/qa-gates/coverage-comparison.2026-10-16T00-36.md
?? docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/qa-gates/final-black.2026-10-16T00-29.md
?? docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/qa-gates/final-black.2026-10-16T00-30.md
?? docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/qa-gates/final-coverage-percentages.2026-10-16T00-34.md
?? docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/qa-gates/final-coverage-thresholds.2026-10-16T00-34.md
?? docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/qa-gates/final-loop-single-pass.2026-10-16T00-35.md
?? docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/qa-gates/final-pyright.2026-10-16T00-30.md
?? docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/qa-gates/final-pytest-coverage.2026-10-16T00-34.md
?? docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/qa-gates/final-pytest-guard.2026-10-16T00-31.md
?? docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/qa-gates/final-ruff.2026-10-16T00-30.md
```

## 2. git fetch origin main (exit 0)

```text
From https://github.com/drmoisan/drm-copilot
 * branch                main       -> FETCH_HEAD
```

## 3. git diff --name-only origin/main...HEAD (exit 0)

```text
docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/baseline/baseline-black-check.2026-10-16T00-13.md
docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/baseline/baseline-coverage-percentages.2026-10-16T00-19.md
docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/baseline/baseline-coverage-thresholds.2026-10-16T00-18.md
docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/baseline/baseline-docstring-pin.2026-10-16T00-20.md
docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/baseline/baseline-docstring-support.2026-10-16T00-20.md
docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/baseline/baseline-environment.2026-10-16T00-12.md
docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/baseline/baseline-line-count.2026-10-16T00-20.md
docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/baseline/baseline-mode-check.2026-10-16T00-11.md
docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/baseline/baseline-production-scope.2026-10-16T00-21.md
docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/baseline/baseline-pyright.2026-10-16T00-14.md
docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/baseline/baseline-pytest-coverage.2026-10-16T00-18.md
docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/baseline/baseline-pytest-guard.2026-10-16T00-14.md
docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/baseline/baseline-ruff-check.2026-10-16T00-13.md
docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/baseline/phase0-instructions-read.2026-10-16T00-08.md
docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/other/phase1-handoff.2026-10-16T00-22.md
docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/regression-testing/expect-fail-p1-t2.2026-10-16T00-23.md
docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/regression-testing/expect-fail-p1-t3.2026-10-16T00-23.md
docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/regression-testing/expect-fail-p1-t4.2026-10-16T00-24.md
docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/regression-testing/fail-before.2026-10-16T00-25.md
docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/regression-testing/pass-after.2026-10-16T00-27.md
docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/issue.md
docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/plan.2026-10-15T17-44.md
docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/research/research.2026-10-15T17-50.md
tests/scripts/dev_tools/npm_token_guard_test_support.py
tests/scripts/dev_tools/test_workflow_npm_token_guard.py
```

## Classification

- In-scope source: `tests/scripts/dev_tools/npm_token_guard_test_support.py`, `tests/scripts/dev_tools/test_workflow_npm_token_guard.py`.
- In-scope feature docs: `issue.md` (pre-existing, from promotion commits `babb2c2a4` and `8878ebb96`), `plan.2026-10-15T17-44.md`.
- Evidence: every path under `docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/`.
- Pre-existing on the branch before this plan ran: `docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/research/research.2026-10-15T17-50.md` (commit `8878ebb96`).
- Prohibited-prefix paths: none.
