# Remediation scope baseline (#884, cycle 1)

Timestamp: 2026-10-16T01-01
Command: git diff --name-only origin/main...HEAD ; git status --porcelain -uall
EXIT_CODE: 0
EXIT-CODE-SCOPE: both git commands exited 0 as reported by the tool (no error output); the artifact write was observed to succeed
Output Summary: Committed diff against origin/main lists 14 paths, all under the feature folder. Porcelain status lists 6 untracked paths (5 review/remediation documents plus the P0-T1 artifact), all under the feature folder.

BASELINE-DIFF-N: 14
BASELINE-STATUS-OUTSIDE-FEATURE: 0

Timestamp source: `TZ=UTC git var GIT_COMMITTER_IDENT` epoch 1792112484 (+0000), converted by hand to 2026-10-16T01:01:24 UTC (pwsh refused by the worktree isolation guard).

## Printed lines of `git diff --name-only origin/main...HEAD` (14)

```
docs/features/active/untouched-files-coverage-verification-884/evidence/baseline/branch-diff-scope.2026-10-16T00-26.md
docs/features/active/untouched-files-coverage-verification-884/evidence/baseline/coverage-baseline.2026-10-16T00-26.md
docs/features/active/untouched-files-coverage-verification-884/evidence/baseline/minor-audit-doc-shape.2026-10-16T00-26.md
docs/features/active/untouched-files-coverage-verification-884/evidence/baseline/phase0-instructions-read.2026-10-16T00-26.md
docs/features/active/untouched-files-coverage-verification-884/evidence/issue-updates/issue-884.2026-10-16T00-37.md
docs/features/active/untouched-files-coverage-verification-884/evidence/other/ci-per-file-coverage.2026-10-15T11-47.md
docs/features/active/untouched-files-coverage-verification-884/evidence/qa-gates/coverage-verification.2026-10-16T00-28.md
docs/features/active/untouched-files-coverage-verification-884/evidence/qa-gates/final-diff-scope.2026-10-16T00-39.md
docs/features/active/untouched-files-coverage-verification-884/evidence/qa-gates/plan-validation.2026-10-16T00-41.md
docs/features/active/untouched-files-coverage-verification-884/evidence/qa-gates/poshqc-codex-hooks-status.2026-10-16T00-37.md
docs/features/active/untouched-files-coverage-verification-884/evidence/qa-gates/toolchain-scope.2026-10-16T00-39.md
docs/features/active/untouched-files-coverage-verification-884/issue.md
docs/features/active/untouched-files-coverage-verification-884/plan.2026-10-15T07-41.md
docs/features/active/untouched-files-coverage-verification-884/research/research.2026-10-15T07-50.md
```

## Printed lines of `git status --porcelain -uall` (6)

```
?? docs/features/active/untouched-files-coverage-verification-884/code-review.2026-10-16T00-46.md
?? docs/features/active/untouched-files-coverage-verification-884/evidence/baseline/remediation-instructions-read.2026-10-16T01-00.md
?? docs/features/active/untouched-files-coverage-verification-884/feature-audit.2026-10-16T00-46.md
?? docs/features/active/untouched-files-coverage-verification-884/policy-audit.2026-10-16T00-46.md
?? docs/features/active/untouched-files-coverage-verification-884/remediation-inputs.2026-10-16T00-55.md
?? docs/features/active/untouched-files-coverage-verification-884/remediation-plan.2026-10-16T00-55.md
```
