# P2-T9 AC-1 (M-3) check-off

Timestamp: 2026-10-10T09-57
Command: grep -c -F "[x] AC-1 (M-3)" issue.md; grep -c -F "[x] AC-" issue.md; grep -c -F "[ ] AC-" issue.md
EXIT_CODE: 0
Output Summary: GREP value=1 exit=0; GREP value=1 exit=0; GREP value=6 exit=0 (expected 1, 1, 6). The line now begins with "- [x] AC-1 (M-3):". The top-level EXIT_CODE is the last grep's exit code.
Evidence relied on: P1-T7 expect-fail artifact (T1 `not ok 17` before the fix); P1-T14 pass-after and P2-T3 (`ok 17`); P2-T7 checks (1) count 1 and (2) lines 350/352/353.
