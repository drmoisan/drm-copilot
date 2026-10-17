# Baseline CI shell test step (P0-T7)

Timestamp: 2026-10-09T06-59
Command: gh run view 37895732802 --json jobs --jq '.jobs[].steps[] | select(.name | startswith("Run shell-qc test")) | .conclusion' ; gh run view 37895732802 --log | awk 'index($0,"not ok"){n++} END{print n+0}'
EXIT_CODE: 0
Output Summary: test step conclusion `success`; count of `not ok` lines in the log is 0 (N0 = 0).

Step conclusion output:
success

not ok count output:
0

N0: 0
