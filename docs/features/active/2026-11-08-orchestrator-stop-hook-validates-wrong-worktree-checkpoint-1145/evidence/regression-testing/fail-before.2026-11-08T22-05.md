# Fail-Before Pester Gate (issue #1145, [P1-T2], expect-fail)

Timestamp: 2026-11-08T21-55
Command: sh SCRATCH/issue-1145-pester.sh (PowerShell 7: Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; $r = Invoke-PoshQCParallelTest -Root <worktree root>; exit $r.ExitCode)
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- Run: one `Invoke-PoshQCParallelTest` gate with the P1-T1 test file `tests/scripts/claude-hooks/validate-orchestrator-output.TargetWorktree.Tests.ps1` added and every hook unmodified; workers=8; wall-clock 598.52 s; returned `ExitCode` 1 (shard 2 exited 16, all other shards 0); finished 2026-11-08T22-05.
- Counts (per-shard JUnit files): 20503 testcases; 20477 passed; 16 failed; 0 errors; 10 skipped.
- Every failing testcase is in the new file (the P0-T2 failing list is empty):
  - H1, H2, H3, H4, H5 (branch in no worktree), H5 (issue recorded by no worktree), H6 (two distinct issue lines), H6 (branch in two worktrees), H7, H8, H9, H10 (epic-orchestrator-state), H10 (parallel-orchestrator-state), H11, H12: `ParameterBindingException: A parameter cannot be found that matches parameter name 'ReadTranscriptHead'.`
  - H13: `Expected like wildcard '*ORCHESTRATOR_CHECKPOINT_FALLBACK:*' to match <empty>, but it did not match.` (the unmodified hook writes no fallback note on allow).
- Failure reason of H1 and H2, as observed: both fail at parameter binding, because the unmodified `Invoke-OrchestratorOutputValidation` has no `-ReadTranscriptHead` (or `-WorktreeListInvoker`) parameter, so the item worktree named by the delegation prompt cannot be resolved by the hook before the fix.
- The baseline isolation probe row of the new file passed.

Prior run of the same gate (recorded for completeness, superseded by the run above):
- Timestamp 2026-11-08T21-43 to 2026-11-08T21-52, head before the P1-T1 fix commit; `ExitCode` 1; 20503 testcases, 20476 passed, 17 failed, 10 skipped.
- The 16 failures above plus one in `enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1` (AC-4 compliance row for the new file): the outermost `BeforeAll` of the new file lacked the baseline mocks of `Get-CheckpointFileContent`, `Get-OrchestratorStateCheckpoint`, and `Get-WorktreeRunCheckpointText`. The new file was fixed (one `Register-EpicStateBaselineMock` statement now names those seams) and the gate was re-run once.
