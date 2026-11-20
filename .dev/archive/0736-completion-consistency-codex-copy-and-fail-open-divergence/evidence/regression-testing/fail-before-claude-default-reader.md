# Fail-before: Claude DefaultReader suite ([P1-T15])

Timestamp: 2026-10-08T17-50
Command: PESTER_RUN with PESTER_PATHS tests/scripts/claude-hooks/enforce-completion-consistency.DefaultReader.Tests.ps1 (unmodified hook)
EXIT_CODE: 3
ExpectedExitCode: 3
Output Summary: PASSED=4 FAILED=3 FAILED_BLOCKS=0 FAILED_CONTAINERS=0. FAILED_TEST lines are exactly R34 (not_started to pending), R5 (empty fixture), and R6 (missing fixture); R0, R1, R2, R7 pass.
