# P2-T12 AC-4 (M-2) check-off

Timestamp: 2026-10-10T09-58
Command: grep -c -F "[x] AC-4 (M-2)" issue.md; grep -c -F "[x] AC-" issue.md; grep -c -F "[ ] AC-" issue.md
EXIT_CODE: 0
Output Summary: GREP value=1 exit=0; GREP value=4 exit=0; GREP value=3 exit=0 (expected 1, 4, 3). The line now begins with "- [x] AC-4 (M-2):".
Evidence relied on: P1-T9 artifact; P2-T1 shfmt clean (exit 0); P2-T2 shellcheck clean (exit 0); P2-T7 check (3) prints 44:, 45:, 46: lines.
