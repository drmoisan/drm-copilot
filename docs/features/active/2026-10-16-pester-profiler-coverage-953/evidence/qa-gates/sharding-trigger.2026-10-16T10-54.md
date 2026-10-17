# Sharding Trigger (P7-T4)

Timestamp: 2026-10-16T10-54
Command: gh run view 38887178530 --json jobs --jq '.jobs[] | select(.name=="poshqc / PowerShell QC") | .steps[] | select(.name=="Test PowerShell") | ((.completedAt|fromdateiso8601) - (.startedAt|fromdateiso8601))'
EXIT_CODE: 0
Output Summary: T is the TEST_STEP_SECONDS value of ci-prhead-timing.2026-10-16T10-54.md (1141). 1141 > 480, so the trigger fires.

T_SECONDS: 1141
RULE: TRIGGERED if and only if T > 480
SHARDING_DECISION: TRIGGERED
