# P2-T11 AC-3 check-off

Timestamp: 2026-10-10T09-58
Command: grep -c -F "[x] AC-3:" issue.md; grep -c -F "[x] AC-" issue.md; grep -c -F "[ ] AC-" issue.md
EXIT_CODE: 0
Output Summary: GREP value=1 exit=0; GREP value=3 exit=0; GREP value=4 exit=0 (expected 1, 3, 4). The line now begins with "- [x] AC-3:".
Evidence relied on: P1-T7 expect-fail artifact (T2 `not ok 18` before the fix); P1-T14 and P2-T3 (`ok 18`); the T2 body in tests/shell/test_cleanup_worktrees_scan_roots.bats line 271 fails if any output line equals `D:`; P2-T7 check (8) count 1.
