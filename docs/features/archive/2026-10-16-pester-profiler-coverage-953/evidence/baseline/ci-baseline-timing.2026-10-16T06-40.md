# CI Baseline Timing (P0-T3)

Timestamp: 2026-10-16T06-40
Command: gh run view 38846579572 --json jobs --jq '.jobs[] | select(.name=="poshqc / PowerShell QC") | .steps[] | select(.name=="Test PowerShell") | ((.completedAt|fromdateiso8601) - (.startedAt|fromdateiso8601))' ; gh run view 38846579572 --json jobs --jq '.jobs[] | select(.name=="poshqc / PowerShell QC") | ((.completedAt|fromdateiso8601) - (.startedAt|fromdateiso8601))'
EXIT_CODE: 0
Output Summary: Both commands exited 0 and each printed exactly one integer. Test PowerShell step 930 s (15.5 min); poshqc / PowerShell QC job 1118 s (18.6 min).

TEST_STEP_SECONDS: 930
JOB_SECONDS: 1118
