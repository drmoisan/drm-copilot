# Baseline CI shell check step (P0-T6)

Timestamp: 2026-10-09T06-59
Command: gh run view 37895732802 --json jobs --jq '.jobs[].steps[] | select(.name | startswith("Run shell-qc check")) | .conclusion'
EXIT_CODE: 0
Output Summary: single line `success`; format and lint gate (shfmt diff plus shellcheck) passes on main baseline.

Output:
success
