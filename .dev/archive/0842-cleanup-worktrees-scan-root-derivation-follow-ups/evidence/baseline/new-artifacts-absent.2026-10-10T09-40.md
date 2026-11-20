# P0-T6 baseline absence of new fixtures and test names

Timestamp: 2026-10-10T09-40
Command: git ls-files -- tests/fixtures/cleanup_worktrees/scenarios/scan_roots_drive_relative tests/fixtures/cleanup_worktrees/scenarios/scan_roots_backslash; grep -c -F "scan_roots_drive_relative" BATS_FILE; grep -c -F "scan_roots_backslash" BATS_FILE; grep -c "^@test " BATS_FILE
EXIT_CODE: 0
Output Summary:
- git ls-files: empty output, exit 0
- GREP scan_roots_drive_relative value=0 exit=1
- GREP scan_roots_backslash value=0 exit=1
- GREP "^@test " value=16 exit=0 (last grep, top-level exit code)
- BATS_FILE = tests/shell/test_cleanup_worktrees_scan_roots.bats
Result: all acceptance conditions met.
