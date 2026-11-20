# Fail-before run (P1-T2)

Timestamp: 2026-11-08T13-52
Command: Invoke-Pester -Path tests/scripts/claude-lib/runbook/RunbookCommandVersion.Tests.ps1 -PassThru (debugging run, not a gate; sh launcher SCRATCH/focused.sh exits with FailedCount plus FailedContainersCount)
EXIT_CODE: 2
Output Summary: Expected failure. The container failed at import with FileNotFoundException because .claude/lib/runbook/RunbookCommandVersion.psm1 does not exist yet. Combined failed count 2 (FailedCount 1 plus FailedContainersCount 1); Passed=0 Total=1.
