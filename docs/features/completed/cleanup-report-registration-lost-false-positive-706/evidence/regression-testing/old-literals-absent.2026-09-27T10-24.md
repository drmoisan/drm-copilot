# Old Literals Absent (P2-T5)

Timestamp: 2026-09-27T10-24
ExpectedExitCode: 1
Command: grep -n -F -e 'if [[ $target != /* ]]; then' -e 'if [[ -e $target ]]; then' scripts/bash/cleanup_worktrees_scan_helper.sh
EXIT_CODE: 1
Output Summary: No output; exit 1. Both pre-fix literals are gone from the helper.
