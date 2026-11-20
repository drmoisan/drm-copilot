# Pester Final Gate, Run 1 ([P4-T3]) - failed, fixed, re-run follows

Timestamp: 2026-11-08T19-26
Command: sh SCRATCH/issue-1139-pester.sh (from the worktree root: pwsh -NoProfile -Command 'Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; $r = Invoke-PoshQCParallelTest -Root (Get-Location).ProviderPath; exit $r.ExitCode')
EXIT_CODE: 1
Output Summary: One Invoke-PoshQCParallelTest run of the branch-current PoshQC module on the merged tree. Returned ExitCode 1; WorkerCount 8; wall-clock 722.84 s; shard 5 exited 1, the other seven exited 0. No merged JUnit or coverage artifact was written (the merged files on disk are the P0-T2 files and are not read here). Counts from the eight per-shard JUnit files: 20464 tests, 1 failed, 0 errors, 10 skipped, 20453 passed. Coverage: unknown for this run (no merged coverage is produced by a failed run).

## Failing Test

- `Claude library module conventions.states the fail-fast convention in the module help block` (`tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1`): offender `OrchestratorStateOwnerDirectives.psm1`. The new module's leading help block did not carry the convention line that every `.claude/lib` module states. This test is not in the P0-T2 failure list (P0-T2 recorded no failure), so it is a new failure introduced by this branch.

## Fix

- Added the convention line used by the fifteen sibling modules, `CONVENTION: this module fails fast at module scope and imports its siblings with -ErrorAction Stop.`, to the `.NOTES` section of `.claude/lib/orchestrator-state/OrchestratorStateOwnerDirectives.psm1`, and copied the module byte-identically to its bundle copy (equal SHA-256). The module already sets `$ErrorActionPreference = 'Stop'` at module scope and imports nothing; no code changed.
- Per the plan, the static loop of [P4-T2] is re-run for the changed file and the gate is re-run once for this fix; the re-run is recorded in a later `pester.*.md`.
