# Post-fix reproduction, malformed token after newline (P3-T4) (AC-5)

Timestamp: 2026-10-09T07-10
Command: sh .claude/lib/bash/compute-cohorts.sh --keys "1<LF>02"
EXIT_CODE: 2
ExpectedExitCode: 2
Output Summary: exit 2 and the output contains `found: 02`; before the fix the same call exited 0 and ignored the token.

stderr: compute-cohorts.sh: item key must be a decimal integer matching -?(0|[1-9][0-9]*); found: 02
