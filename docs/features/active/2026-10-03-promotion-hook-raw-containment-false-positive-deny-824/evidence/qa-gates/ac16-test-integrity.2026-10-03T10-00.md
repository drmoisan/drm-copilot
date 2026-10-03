# P4-T6 AC-16: no pre-existing test line edited beyond the rename

Timestamp: 2026-10-03T10-00
Command: git diff --numstat 9e8fe7eb576a904ac22cab96faf8c5c12311833e -- tests/scripts/claude-hooks tests/scripts/codex-hooks; git status --porcelain --untracked-files=all -- tests/scripts/claude-hooks tests/scripts/codex-hooks; $LASTEXITCODE
EXIT_CODE: 0
Output Summary:
- numstat lists exactly 15 tracked files (S1-S14 and LEGACY):
  - S13 14/0, S6 27/0, S11 8/0, S7 26/0, S5 18/0, S1 63/0, S3 18/1, S9 8/0, S14 11/0, S8 20/0, S12 8/0, S2 63/0, S4 18/1, LEGACY 1/1, S10 8/0
- Deleted count is 1 for S3, S4, and LEGACY and 0 for every other file
- Porcelain status: the same 15 files as ' M', and exactly two untracked files: tests/scripts/claude-hooks/hook-command-raw-invocation.Tests.ps1 (U1) and tests/scripts/codex-hooks/hook-command-raw-invocation.Tests.ps1 (U2)
- Result: PASS
