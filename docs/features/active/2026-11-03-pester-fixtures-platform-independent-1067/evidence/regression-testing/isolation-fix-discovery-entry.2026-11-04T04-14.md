# Isolation Fix: Test-DiscoveryHostCapability.Entry.Tests.ps1 (P6-T3)

Timestamp: 2026-11-04T04-14
Command: pwsh -NoProfile -NonInteractive -File SCRATCH/issue-1067-run-pester.ps1 -Root <worktree> -Paths tests/scripts/dev-tools/Test-DiscoveryHostCapability.Entry.Tests.ps1
EXIT_CODE: 0
Output Summary:
- TOTAL Tests=4 Passed=4 Failed=0 Skipped=0 NotRun=0
- PROBE LASTEXITCODE=0
- Change: a Describe-level `AfterEach` resets `$global:LASTEXITCODE` to 0 after each test; the operator script under test exits with its verdict (1 or 2), which sets the process-wide exit code.
- Probe limitation: Invoke-Pester itself sets `$global:LASTEXITCODE` to the failed-test count when the run ends, so a post-run probe of 0 is consistent with the fix but does not by itself distinguish it from the pre-fix state (P5-T10 also printed 0). The reset is verified by reading the suite.
