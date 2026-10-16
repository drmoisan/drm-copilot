# Final diff scope (#884)

Timestamp: 2026-10-16T00-39
Command: git diff --name-only origin/main...HEAD; git status --porcelain -uall (counts computed by the executor from the printed lines because the Bash tool permits only git, pwsh, poetry, npx and refuses pipes to wc and grep)
EXIT_CODE: 0
Output Summary: N=4, M=4, P=9, Q=9. Folder-prefix assertion for the diff printed count 0; folder-prefix assertion for porcelain status printed count 0. N equals M, P equals Q, N >= 1, P >= 1. This observation precedes the writes of this artifact and of toolchain-scope.2026-10-16T00-39.md, which are also under the feature folder.

AC4-DIFF-SCOPE: ONLY FEATURE FOLDER

## git diff --name-only origin/main...HEAD (4 lines)

- docs/features/active/untouched-files-coverage-verification-884/evidence/other/ci-per-file-coverage.2026-10-15T11-47.md
- docs/features/active/untouched-files-coverage-verification-884/issue.md
- docs/features/active/untouched-files-coverage-verification-884/plan.2026-10-15T07-41.md
- docs/features/active/untouched-files-coverage-verification-884/research/research.2026-10-15T07-50.md

## git status --porcelain -uall (9 lines)

- M issue.md
- M plan.2026-10-15T07-41.md
- ?? evidence/baseline/branch-diff-scope.2026-10-16T00-26.md
- ?? evidence/baseline/coverage-baseline.2026-10-16T00-26.md
- ?? evidence/baseline/minor-audit-doc-shape.2026-10-16T00-26.md
- ?? evidence/baseline/phase0-instructions-read.2026-10-16T00-26.md
- ?? evidence/issue-updates/issue-884.2026-10-16T00-37.md
- ?? evidence/qa-gates/coverage-verification.2026-10-16T00-28.md
- ?? evidence/qa-gates/poshqc-codex-hooks-status.2026-10-16T00-37.md

(All paths above are under docs/features/active/untouched-files-coverage-verification-884/.)

## Counts

- N: 4
- M: 4
- P: 9
- Q: 9
- Diff lines NOT containing the feature folder prefix, printed count: 0
- Status lines NOT containing the feature folder prefix, printed count: 0
