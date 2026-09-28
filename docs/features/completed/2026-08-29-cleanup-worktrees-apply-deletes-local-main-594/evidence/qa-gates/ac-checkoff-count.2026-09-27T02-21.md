# P6-T41 — AC check-off count (checked items)

Timestamp: 2026-09-27T02-21
Task: [P6-T41]
Working directory: repository worktree root

Evidence artifacts present on disk for each checked item (AC-01 through AC-22):
- AC-01: `qa-gates/ac01-base-constant.2026-09-27T01-41.md`, `qa-gates/ac01-no-default-expansion.2026-09-27T01-41.md`
- AC-02 through AC-11 (T1-T10): `regression-testing/pass-after.2026-09-27T01-40.md`, `qa-gates/ci-shell-coverage.2026-09-27T02-00.md`
- AC-12: `qa-gates/ac12-tests-added-only.2026-09-27T02-16.md`
- AC-13: `qa-gates/ac13-goldens-unchanged.2026-09-27T02-16.md`
- AC-14: `qa-gates/ac14-no-new-state.2026-09-27T01-41.md`, `qa-gates/ac14-no-protected-base.2026-09-27T01-41.md`
- AC-15: `qa-gates/ac15-comments.2026-09-27T01-41.md`, `qa-gates/ac15-phrase-1.2026-09-27T01-41.md`, `qa-gates/ac15-phrase-2.2026-09-27T01-41.md`, `qa-gates/ac15-phrase-3.2026-09-27T01-41.md`, `qa-gates/ac15-run-apply-search.2026-09-27T01-42.md`, `qa-gates/ac15-run-apply-docstring.2026-09-27T01-42.md`
- AC-16: `qa-gates/ac16-help-text.2026-09-27T01-42.md`
- AC-17: `qa-gates/ac17-skill-parity.2026-09-27T01-42.md`
- AC-18: `qa-gates/ac18-line-counts-and-anchors.2026-09-27T01-44.md`
- AC-19: `qa-gates/qc-step1-shfmt.2026-09-27T01-47.md`, `qa-gates/qc-step2a-shellcheck-production.2026-09-27T01-47.md`, `qa-gates/qc-step2b-shellcheck-bats.2026-09-27T01-47.md`, `qa-gates/qc-step2c-shell-qc-check.2026-09-27T01-47.md`, `qa-gates/ci-shell-coverage.2026-09-27T02-00.md`
- AC-20: `qa-gates/kcov/coverage-summary.2026-09-27T02-12.md`, `qa-gates/kcov/added-line-hits.2026-09-27T02-14.md`
- AC-21: `qa-gates/ac21-portability.2026-09-27T01-43.md`, `qa-gates/ac21-pattern-tests.2026-09-27T01-43.md`, `qa-gates/ac21-pattern-fixtures.2026-09-27T01-43.md`, `qa-gates/ci-shell-coverage.2026-09-27T02-00.md`
- AC-22: `qa-gates/ac22-no-temp-files.2026-09-27T01-43.md`, `qa-gates/ac22-no-redirection.2026-09-27T01-43.md`

Command: `grep -c -e '^- \[x\] ' docs/features/active/2026-08-29-cleanup-worktrees-apply-deletes-local-main-594/spec.md`
EXIT_CODE: 0

Output Summary:
- Printed count: `22`.
- Expected under the P6-T40 deferral branch: 22 checked. Matches.
- Every checked item has its evidence artifacts present on disk (list above).
