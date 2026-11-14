# Fail-before evidence: planner allow cases ([P2-T5], AC-8)

Timestamp: 2026-11-11T04-38
Command: sh SCRATCH/issue-1161-pester-failbefore wrapper `sh SCRATCH/issue-1161-pester.sh failbefore` (PowerShell 7; imports the branch-current `scripts/powershell/PoshQC/PoshQC.psd1`, runs one `Invoke-PoshQCParallelTest -Root <worktree>`, exits with the returned `ExitCode`; counts read from `artifacts/pester/parallel/shard-<i>/pester-junit.xml`)
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: ExitCode 1 after 1384.4 s with 8 shards. Run before any edit to the three gate files; the P2-T1 to P2-T4 suites existed. Shard totals: 21658 tests, 45 failures, 0 errors (shard-3 15, shard-6 15, shard-7 15; shards 1, 2, 4, 5, 8 had 0). Every failure is in one of the new suites `tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-planner-worktree.Tests.ps1`, `tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.PlannerWorktree.Tests.ps1`, or `tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.PlannerWorktree.Tests.ps1`. No test outside the five new suites failed. The merged `artifacts/pester/pester-junit.xml` was not rewritten (it still carries the Phase 0 write time), as a failed run leaves it in place.

## Gate-level allow cases (each failed)

Codex gate, through `Invoke-CodexWorktreeRemovalDecision` with `-PlannerCheckpointRaw` (failure: parameter `PlannerCheckpointRaw` not found):

- `Codex planner worktree branch (issue #1161).adapter and gate rows.gate: allows a prepared record (AC-7)`
- `Codex planner worktree branch (issue #1161).adapter and gate rows.gate: allows a fanned_in record (AC-7)`

Claude epic gate (failure: the gate denied):

- `enforce-epic-worktree-removal-gate.ps1 planner branch.planner rows.allows a prepared record whose HEAD is on the integration ref (AC-5)`
- `enforce-epic-worktree-removal-gate.ps1 planner branch.planner rows.allows a fanned_in record whose HEAD is on the integration ref (AC-5)`
- `enforce-epic-worktree-removal-gate.ps1 planner branch.planner rows.allows a prepared record whose HEAD is on the branch ref (AC-5)`
- `enforce-epic-worktree-removal-gate.ps1 planner branch.planner rows.allows a fanned_in record whose HEAD is on the branch ref (AC-5)`

Claude parallel gate (failure: the gate denied):

- `enforce-parallel-worktree-removal-gate.ps1 planner branch.planner rows.allows a prepared record whose HEAD is on the integration ref (AC-6)`
- `enforce-parallel-worktree-removal-gate.ps1 planner branch.planner rows.allows a fanned_in record whose HEAD is on the integration ref (AC-6)`
- `enforce-parallel-worktree-removal-gate.ps1 planner branch.planner rows.allows a prepared record whose HEAD is on the branch ref (AC-6)`
- `enforce-parallel-worktree-removal-gate.ps1 planner branch.planner rows.allows a fanned_in record whose HEAD is on the branch ref (AC-6)`

## Other failed rows in the new suites (refusal sentences not yet appended; not allow cases)

- Codex suite: 13 further gate-level rows (dirty with `--force`, unrecorded deny, U1 to U5, not pushed, not eligible, ambiguous, git failure, epic allow precedence, existing-suite row), all failing on the absent `-PlannerCheckpointRaw` or `-TargetCheckpointReader` parameter.
- Claude epic and parallel suites: 11 further rows each (dirty with and without `--force`, six refusal codes, U3 with and without `--force`, manifest allow after a refusal), failing because no planner sentence is appended and the planner seams are not called.

## Rows that passed at this point (not listed as failed)

The adapter-level allow rows of `tests/scripts/claude-hooks/enforce-worktree-removal-gate-planner.Tests.ps1` and the adapter rows of the Codex suite passed, as did all of `tests/scripts/claude-hooks/hook-planner-worktree-removal.Tests.ps1`.
