# Fail-Before F3 [P1-T6] — remediation cycle 1

Timestamp: 2026-11-20T19-29
Command: sh <worktree>/.claude/skills/test-execution-policy/scripts/run-test-suite.sh pester -TestPath <worktree>/tests/scripts/dev-tools/Get-StageTimingReport.Tests.ps1
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: With the [P0-T3] clean layout in place (no `docs/features` directory on disk, as in a clean CI checkout), the selection reports Tests Passed: 6, Failed: 1. The failing case is `Get-StageTimingReport.ps1 entry.STR-ENTRY-PRINTS-LABELS-AND-FIXTURE-MEDIANS` with `RuntimeException: Stage timing evidence root not found: <worktree>\docs\features`, the same failure as CI run 44791702384 job `poshqc / PowerShell QC shard 1`. Source: artifacts/pester/parallel/shard-1/shard.log of this run.
