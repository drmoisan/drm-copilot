# P2-T10 AC-2 (N-1) check-off

Timestamp: 2026-10-10T09-58
Command: grep -c -F "[x] AC-2 (N-1)" issue.md; grep -c -F "[x] AC-" issue.md; grep -c -F "[ ] AC-" issue.md
EXIT_CODE: 0
Output Summary: GREP value=1 exit=0; GREP value=2 exit=0; GREP value=5 exit=0 (expected 1, 2, 5). The line now begins with "- [x] AC-2 (N-1):".
Evidence relied on: P1-T14 pass-after and P2-T3 (`ok 20` T4 and `ok 21` T5); P2-T7 checks (9) and (10) each 1.
