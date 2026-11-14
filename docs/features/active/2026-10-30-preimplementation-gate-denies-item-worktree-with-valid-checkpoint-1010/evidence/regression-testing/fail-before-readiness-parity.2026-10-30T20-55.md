# Fail-Before: Strict lifecycle_ready Parity Rows (Issue #1010, P2-T6)

Timestamp: 2026-10-30T20-53
Command: sh SCRATCH/issue-1010-pt.sh issue-1010-parity.txt -NoCoverage (Invoke-PoshQCTest from scripts/powershell/PoshQC/PoshQC.psd1 over tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Parity.Tests.ps1, Run.Exit off; counts read from artifacts/pester/pester-junit.xml)
EXIT_CODE: 0
ExpectedExitCode: 0
Output Summary: Run before any Phase 3 fix. JUnit total 93 (85 at baseline plus 4 new readiness cases per runtime), failed 6, passed 87. The "false", "true", and 1 rows fail on both runtimes; the null rows pass on both runtimes.

## Failing Cases (JUnit)

- AC-17 readiness a checkpoint whose lifecycle_ready is the string false claude
- AC-17 readiness a checkpoint whose lifecycle_ready is the string true claude
- AC-17 readiness a checkpoint whose lifecycle_ready is the number 1 claude
- AC-17 readiness a checkpoint whose lifecycle_ready is the string false codex
- AC-17 readiness a checkpoint whose lifecycle_ready is the string true codex
- AC-17 readiness a checkpoint whose lifecycle_ready is the number 1 codex

## Expected Pass

- AC-17 readiness a checkpoint whose lifecycle_ready is null claude
- AC-17 readiness a checkpoint whose lifecycle_ready is null codex

The null rows pass before the fix as the plan expects: a `[bool]` cast of null is already false.
