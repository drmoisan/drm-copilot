# LASTEXITCODE Fail-Before (remediation cycle 1, P1-T3, expect-fail)

Timestamp: 2026-10-16T04-55
Command: mcp__drm-copilot__run_poshqc_test (scan_folders ["tests/scripts/claude-hooks"]) then poetry run python SCRATCH/928/junit_rows.py artifacts/pester/pester-junit.xml subagentstop-uncaught-error.Tests.ps1
MCP_DISPOSITION: error (Command exited with code 2.)
EXIT_CODE: 2
ExpectedExitCode: 2
Output Summary:
- Timestamp is the UTC clock read immediately before the MCP test call; the artifact file name carries the write time.
- MTIME_UTC 2026-10-16T05-10 (not earlier than Timestamp)
- TOTALS tests 4609 failures 2 errors 0 (targeted scope); the only two ANYFAIL lines are the U1-ST rows below.
- PASS baseline mock interception probe
- PASS U1: .claude/hooks/validate-discovery-artifact-gate.ps1 blocks with exit 2 when the validation call throws
- PASS U1: .claude/hooks/validate-executor-output.ps1 blocks with exit 2 when the validation call throws
- PASS U1: .claude/hooks/validate-feature-review-coverage.ps1 blocks with exit 2 when the validation call throws
- PASS U1: .claude/hooks/validate-orchestrator-output.ps1 blocks with exit 2 when the validation call throws
- PASS U1: .claude/hooks/validate-planner-output.ps1 blocks with exit 2 when the validation call throws
- PASS U1: .claude/hooks/validate-pr-author-output.ps1 blocks with exit 2 when the validation call throws
- PASS U1: .claude/hooks/validate-prd-feature-output.ps1 blocks with exit 2 when the validation call throws
- PASS U1: .claude/hooks/validate-required-artifact-output.ps1 blocks with exit 2 when the validation call throws
- PASS U1: .claude/hooks/validate-task-researcher-output.ps1 blocks with exit 2 when the validation call throws
- FAIL U1-ST: .claude/hooks/validate-discovery-artifact-gate.ps1 blocks with exit 2 when the validation call raises a statement-terminating error | Expected 0, because Invoke-ValidatorUnderTest restores the previous LASTEXITCODE, but got 2.
- FAIL U1-ST: .claude/hooks/validate-pr-author-output.ps1 blocks with exit 2 when the validation call raises a statement-terminating error | Expected 0, because Invoke-ValidatorUnderTest restores the previous LASTEXITCODE, but got 2.
- PASS U2: has a row for every hook that dot-sources subagentstop-envelope.ps1 and no other
- SUITE subagentstop-uncaught-error.Tests.ps1 MATCHED 13 FAILED 2

Interpretation:
- Expected shape observed. Each U1-ST failure is at the last assertion (`restores the previous LASTEXITCODE`), so for both validators the earlier assertions passed: no escaped error, exit code 2, the stderr prefix, the error text, and exactly one reader call (CR-N1 observation: both validators block with exit 2 for a statement-terminating error).
- `$global:LASTEXITCODE` is 2 after the helper returns because the helper does not yet restore it (CR-N2 fail-before).
- Stop conditions (a), (b), (c): none triggered.
