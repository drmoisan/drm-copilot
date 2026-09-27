# New Names Absent (P0-T6)

Timestamp: 2026-09-27T10-00
ExpectedExitCode: 1
Command: grep -n -e 'scan_helper_is_absolute_path' -e 'scan_helper_target_present' scripts/bash/cleanup_worktrees_scan_helper.sh tests/shell/test_cleanup_worktrees_scan_helper.bats
EXIT_CODE: 1
Output Summary: No output; exit 1. Neither new function name exists in the helper or its bats file.
