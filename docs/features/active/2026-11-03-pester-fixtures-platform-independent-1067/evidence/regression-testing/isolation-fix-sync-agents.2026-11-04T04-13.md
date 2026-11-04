# Isolation Fix: sync-agents-from-instructions.Tests.ps1 (P6-T1)

Timestamp: 2026-11-04T04-13
Command: pwsh -NoProfile -NonInteractive -File SCRATCH/issue-1067-run-pester.ps1 -Root <worktree> -Paths tests/scripts/dev-tools/sync-agents-from-instructions.Tests.ps1
EXIT_CODE: 0
Output Summary:
- TOTAL Tests=20 Passed=20 Failed=0 Skipped=0 NotRun=0
- PROBE POSHQC_SKIP_SCRIPT_EXECUTION=absent (before the fix, P5-T9 recorded `=1`; the run script clears the variable before the run, so `absent` shows the suite restored the prior state)
- Change: `BeforeAll` saves the prior `$env:POSHQC_SKIP_SCRIPT_EXECUTION`; a new `AfterAll` restores it, or removes the variable when it was absent.
