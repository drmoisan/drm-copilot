# P2-T18 AC-7 check-off

Timestamp: 2026-10-10T10-16
Command: grep -c -F "[x] AC-7:" issue.md; grep -c -F "[x] AC-" issue.md; grep -c -F "[ ] AC-" issue.md
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- Evidence before the edit: P2-T1 (shfmt clean), P2-T2 (shellcheck clean), P2-T3 (local bats 85/85 ok), P2-T17 (CI bats 0 not ok; kcov 94.5% aggregate vs 94.2% baseline; enumerate library 0.954 vs 0.953 baseline; changed line 352 hits=1). See evidence/qa-gates/shell-coverage-pr-run.2026-10-10T10-16.md.
- Edit changed only `- [ ]` to `- [x]` on the AC-7 line.
- Expected greps: 1, 7, and 0 (the last exits 1, the pass condition).
