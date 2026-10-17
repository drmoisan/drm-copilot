# Branch diff scope baseline (#884)

Timestamp: 2026-10-16T00-26
Command: git diff --name-only origin/main...HEAD; git status --porcelain -uall (counts computed by the executor from the printed lines because the Bash tool permits only git, pwsh, poetry, npx and refuses pipes to wc and grep)
EXIT_CODE: 0
Output Summary: N=4 (committed paths vs origin/main), M=4 (under feature folder), P=2 (uncommitted paths), Q=2 (under feature folder). Folder-prefix assertion for the diff printed count 0 (no path outside the feature folder). Folder-prefix assertion for porcelain status printed count 0. N equals M, P equals Q, N >= 1, P >= 1.

## git diff --name-only origin/main...HEAD (4 lines)

- docs/features/active/untouched-files-coverage-verification-884/evidence/other/ci-per-file-coverage.2026-10-15T11-47.md
- docs/features/active/untouched-files-coverage-verification-884/issue.md
- docs/features/active/untouched-files-coverage-verification-884/plan.2026-10-15T07-41.md
- docs/features/active/untouched-files-coverage-verification-884/research/research.2026-10-15T07-50.md

## git status --porcelain -uall (2 lines)

-  M docs/features/active/untouched-files-coverage-verification-884/plan.2026-10-15T07-41.md
- ?? docs/features/active/untouched-files-coverage-verification-884/evidence/baseline/phase0-instructions-read.2026-10-16T00-26.md

## Counts

- N (git diff --name-only origin/main...HEAD, line count): 4
- M (same, lines containing the feature folder prefix): 4
- P (git status --porcelain -uall, line count): 2
- Q (same, lines containing the feature folder prefix): 2
- Diff lines NOT containing the feature folder prefix (grep -c -v -F equivalent), printed count: 0
- Status lines NOT containing the feature folder prefix (grep -c -v -F equivalent), printed count: 0
