# rc2 Cycle Scope (P2-T20)

Timestamp: 2026-10-16T03-10
Command: git diff --name-only 3bc4ee9d1...HEAD
EXIT_CODE: 0
Output Summary: 26 committed paths plus 1 modified and 19 untracked paths; all are within the allowlist; no prohibited prefix.

DiffListing:

```text
docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/qa-gates/rc2-after-edit.2026-10-16T03-01.md
docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/qa-gates/rc2-edit-f4.2026-10-16T02-59.md
docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/qa-gates/rc2-edit-f5.2026-10-16T03-00.md
docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/qa-gates/rc2-edit-f6.2026-10-16T03-00.md
docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/qa-gates/rc2-phase1-handoff.2026-10-16T02-59.md
docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/remediation-baseline/phase0-instructions-read.2026-10-16T02-55.md
docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/remediation-baseline/rc2-baseline-black-check.2026-10-16T02-56.md
docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/remediation-baseline/rc2-baseline-changed-lines.2026-10-16T02-57.md
docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/remediation-baseline/rc2-baseline-coverage-reference.2026-10-16T02-57.md
docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/remediation-baseline/rc2-baseline-docstring-f4.2026-10-16T02-57.md
docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/remediation-baseline/rc2-baseline-docstring-f5.2026-10-16T02-57.md
docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/remediation-baseline/rc2-baseline-environment.2026-10-16T02-56.md
docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/remediation-baseline/rc2-baseline-f6-field.2026-10-16T02-57.md
docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/remediation-baseline/rc2-baseline-f6-new.2026-10-16T02-57.md
docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/remediation-baseline/rc2-baseline-f6-old.2026-10-16T02-57.md
docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/remediation-baseline/rc2-baseline-line-count.2026-10-16T02-57.md
docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/remediation-baseline/rc2-baseline-line-width.2026-10-16T02-57.md
docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/remediation-baseline/rc2-baseline-mode-check.2026-10-16T02-55.md
docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/remediation-baseline/rc2-baseline-pyright.2026-10-16T02-56.md
docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/remediation-baseline/rc2-baseline-pytest-guard.2026-10-16T02-56.md
docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/remediation-baseline/rc2-baseline-regex.2026-10-16T02-57.md
docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/remediation-baseline/rc2-baseline-ruff-check.2026-10-16T02-56.md
docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/remediation-plan.2026-10-16T00-56.md
docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/remediation-plan.2026-10-16T02-27.md
tests/scripts/dev_tools/npm_token_guard_test_support.py
tests/scripts/dev_tools/test_workflow_npm_token_guard.py
```

StatusCommand: git status --porcelain --untracked-files=all
StatusExitCode: 0
StatusListing:

```text
 M docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/remediation-plan.2026-10-16T02-27.md
?? docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/qa-gates/rc2-changed-lines.2026-10-16T03-09.md
?? docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/qa-gates/rc2-coverage-comparison.2026-10-16T03-08.md
?? docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/qa-gates/rc2-docstring-f4.2026-10-16T03-09.md
?? docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/qa-gates/rc2-docstring-f5.2026-10-16T03-09.md
?? docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/qa-gates/rc2-f6-field.2026-10-16T03-09.md
?? docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/qa-gates/rc2-f6-new.2026-10-16T03-09.md
?? docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/qa-gates/rc2-f6-old.2026-10-16T03-09.md
?? docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/qa-gates/rc2-final-black.2026-10-16T03-03.md
?? docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/qa-gates/rc2-final-coverage-percentages.2026-10-16T03-07.md
?? docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/qa-gates/rc2-final-coverage-thresholds.2026-10-16T03-07.md
?? docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/qa-gates/rc2-final-loop-single-pass.2026-10-16T03-08.md
?? docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/qa-gates/rc2-final-pyright.2026-10-16T03-03.md
?? docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/qa-gates/rc2-final-pytest-coverage.2026-10-16T03-07.md
?? docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/qa-gates/rc2-final-pytest-guard.2026-10-16T03-03.md
?? docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/qa-gates/rc2-final-ruff.2026-10-16T03-03.md
?? docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/qa-gates/rc2-issue-unchanged.2026-10-16T03-09.md
?? docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/qa-gates/rc2-line-count.2026-10-16T03-09.md
?? docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/qa-gates/rc2-line-width.2026-10-16T03-09.md
?? docs/features/active/2026-10-15-npm-token-guard-misses-append-assignment-933/evidence/qa-gates/rc2-regex-unchanged.2026-10-16T03-09.md
```

Result: the four required paths (the two test-tree files, the cycle 1 plan, and the cycle 2 plan) are present. Every other path is a file under `evidence/remediation-baseline/` or `evidence/qa-gates/` whose filename begins `rc2-`, or `phase0-instructions-read.` inside `evidence/remediation-baseline/`. No path begins with `.github/`, `src/`, `scripts/`, `extensions/`, `.codex/`, `.claude/`, or `tests/fixtures/`. This artifact, written after the listing ran, is also an `rc2-` file under `evidence/qa-gates/`.
