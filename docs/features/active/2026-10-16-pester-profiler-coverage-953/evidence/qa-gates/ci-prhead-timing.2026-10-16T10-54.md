# CI PR-Head Timing (P7-T3)

Timestamp: 2026-10-16T10-54
Command: gh run view 38887178530 --json jobs --jq '.jobs[] | select(.name=="poshqc / PowerShell QC") | .steps[] | select(.name=="Test PowerShell") | ((.completedAt|fromdateiso8601) - (.startedAt|fromdateiso8601))' ; gh run view 38887178530 --json jobs --jq '.jobs[] | select(.name=="poshqc / PowerShell QC") | ((.completedAt|fromdateiso8601) - (.startedAt|fromdateiso8601))'
EXIT_CODE: 0
Output Summary: Both commands exited 0 and each printed one integer. PR-head (profiler mode) Test PowerShell step 1141 s, job 1313 s; baseline run 38846579572 (breakpoint mode) step 930 s, job 1118 s. Pester log: "Tests completed in 1066.11s" for 10488 tests (baseline run: 864.76s for 10407 tests). Supplementary breakpoint-mode observations on main push runs (same TIMING commands): run 38885440106 (head = PR merge base 5bdf22d0f) step 618 s / job 713 s; run 38881687469 step 900 s / job 1078 s; run 38877945822 step 1039 s / job 1218 s; run 38874180903 step 895 s / job 1075 s. Profiler mode did not shorten the step on this run; runner variance across breakpoint-mode runs is 618-1039 s.

TEST_STEP_SECONDS: 1141
JOB_SECONDS: 1313
BASELINE_TEST_STEP_SECONDS: 930
BASELINE_JOB_SECONDS: 1118
