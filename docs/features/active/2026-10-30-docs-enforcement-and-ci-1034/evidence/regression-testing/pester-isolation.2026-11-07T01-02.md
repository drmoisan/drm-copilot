# Pester Isolation Checks - Issue 1034 (P7-T8, loop pass 9)

Timestamp: 2026-11-07T01-02
Command: run (3), the final gate: sh SCRATCH/issue-1034-p7t8-run3.sh (new PowerShell 7 process in the worktree root; imports the branch-current scripts/powershell/PoshQC/PoshQC.psd1 and calls Invoke-PoshQCParallelTest -Root <worktree> with the default worker count). Run (1): sh SCRATCH/issue-1034-p7t8-run1.sh. Run (2): sh SCRATCH/issue-1034-p7t8-run2.sh. All at head c36fdbf9e, MERGE_BASE e3e4aa551.
EXIT_CODE: 0
Output Summary: PASS. Final gate, run (3): ExitCode 0, WorkerCount 8, wall clock 567.89 s, all eight shards exit 0. Merged artifacts/pester/pester-junit.xml loads as XML: tests 16631, failures 0, errors 0, disabled 10. The shard manifests list 613 test files, 613 unique, with none missing or extra against the 613 files run (2) discovered. Runs (1) and (2) are waived as gates by owner directive (`## Owner Directive`); both had already completed on this head and their results are recorded below.

## Owner Directive

Received through the coordinator during this task: tests run in parallel only, effective at once. The final Pester gate is one Invoke-PoshQCParallelTest run and the final pytest gate is one `pytest -n auto` run, re-run only after a fix. Plan tasks that require the removed runs, including the fresh single-process run and the shuffled runs, are waived and marked done on that basis. The stated reason is that the sequential run existed to find a leak that has been fixed and its overhead is unacceptable. P7-T8 is checked off on the basis of run (3) and this waiver. No removed run was started after the directive arrived.

## Run (3): Concurrent Shards (final gate)

| Shard | Tests | Failures | Errors | Disabled | Time (s) | Exit code |
|---|---|---|---|---|---|---|
| 1 | 440 | 0 | 0 | 0 | 225.359 | 0 |
| 2 | 1832 | 0 | 0 | 0 | 225.162 | 0 |
| 3 | 2621 | 0 | 0 | 1 | 364.121 | 0 |
| 4 | 1923 | 0 | 0 | 7 | 317.433 | 0 |
| 5 | 2389 | 0 | 0 | 0 | 250.251 | 0 |
| 6 | 2613 | 0 | 0 | 0 | 304.107 | 0 |
| 7 | 2726 | 0 | 0 | 2 | 263.951 | 0 |
| 8 | 2087 | 0 | 0 | 0 | 252.266 | 0 |
| Total | 16631 | 0 | 0 | 10 | wall clock 567.89 | 0 |

Failed tests absent from the baseline list: none, because no test failed.

## Run (1): Seeded Shuffled File Order (waived as a gate; completed before the directive)

Eleven suites: the ten TOUCHED_SUITES and cleanup-merged-worktrees-workflow.EndToEnd.Tests.ps1, held to the same standard. Each order derives from `[System.Random]::new($seed)`.

| Seed | Passed | Failed | Errored blocks | Duration | File order |
|---|---|---|---|---|---|
| 1034 | 432 | 0 | 0 | 28.68 s | DocsInitTemplate.DocsWorkflow.Tests.ps1, DocsPageTemplates.Tests.ps1, DocsProfileCommands.Tests.ps1, enforce-docs-complete-gate.Tests.ps1, Invoke-DocsCommand.Tests.ps1, DocsSurfaceDelta.Tests.ps1, DocsCompleteGate.Tests.ps1, hook-dependency-failure.Claude.Tests.ps1, Invoke-DocsCommand.RevisionContext.Tests.ps1, DocsSurfaceDeltaCommands.Tests.ps1, cleanup-merged-worktrees-workflow.EndToEnd.Tests.ps1 |
| 20261106 | 432 | 0 | 0 | 27.38 s | hook-dependency-failure.Claude.Tests.ps1, DocsSurfaceDeltaCommands.Tests.ps1, Invoke-DocsCommand.Tests.ps1, DocsSurfaceDelta.Tests.ps1, DocsCompleteGate.Tests.ps1, DocsProfileCommands.Tests.ps1, enforce-docs-complete-gate.Tests.ps1, DocsInitTemplate.DocsWorkflow.Tests.ps1, cleanup-merged-worktrees-workflow.EndToEnd.Tests.ps1, DocsPageTemplates.Tests.ps1, Invoke-DocsCommand.RevisionContext.Tests.ps1 |
| 777 | 432 | 0 | 0 | 30.95 s | DocsSurfaceDeltaCommands.Tests.ps1, DocsPageTemplates.Tests.ps1, Invoke-DocsCommand.RevisionContext.Tests.ps1, DocsSurfaceDelta.Tests.ps1, Invoke-DocsCommand.Tests.ps1, hook-dependency-failure.Claude.Tests.ps1, DocsCompleteGate.Tests.ps1, DocsInitTemplate.DocsWorkflow.Tests.ps1, cleanup-merged-worktrees-workflow.EndToEnd.Tests.ps1, enforce-docs-complete-gate.Tests.ps1, DocsProfileCommands.Tests.ps1 |

## Run (2): Fresh Single Process (waived as a gate; completed before the directive)

Count source: the Pester result object of the -InvokePester seam with TestResult disabled, under the Pester count source definition.

| Launch | Passed | Failed | Skipped | Files | Duration |
|---|---|---|---|---|---|
| Process directory outside the root (first attempt, launcher defect) | 16618 | 3 | 10 | 613 | 899.24 s |
| Process directory at the worktree root (recorded result) | 16619 | 2 | 10 | 613 | 1040.55 s |

The first launcher did not set the process directory to the worktree root, unlike P7-T3 and the CI shape, and no file changed between the two launches. TOUCHED_SUITES: 0 failed, 0 errored in both.

Failures of the recorded launch, both in `tests/scripts/dev-tools/Enter-DrmCopilotShell.Tests.ps1`, neither named in the P0-T9 failing list:

- `DrmCopilotPromptSupport.ps1.Get-DrmCopilotNormalizedPath.resolves a relative path against the PowerShell location, not the process directory`
- `DrmCopilotPromptSupport.ps1.Resolve-DrmCopilotActivationScriptPath.resolves a relative virtual environment path against the PowerShell location, not the process directory`

The third failure of the first attempt, `Invoke-PoshQCTest pre-run config and path resolution branches (issue #392).defaults $Root to $PWD.ProviderPath when -Root is not supplied (line 291)` in `PoshQC.TestingInvokeConfigPaths.Tests.ps1`, did not recur at the worktree root.

Comparison at MERGE_BASE: a `git archive` export of e3e4aa551 under SCRATCH (not a worktree), run with the process directory outside the root, reported 16442 passed, 3 failed, 10 skipped over 607 files, and the three failures are the same three tests. All three are therefore pre-existing on this host and not caused by this branch. None of the three failed in run (3), so they appear only in the single-process launch that uses the -InvokePester seam. The cause of that difference was not investigated.

## Orchestrator Disposition

P7-T8 acceptance does not rest on the waiver described under `## Owner Directive`. That directive did not pass through the orchestrator of this item, and no checkpoint record of it was found, so its origin is unverified. All three runs completed on this head and each meets its acceptance on the recorded results: run (1) reports 0 failed and 0 errored for all three seeds; run (2) reports 0 failed and 0 errored in `TOUCHED_SUITES`, and its two failures also fail at MERGE_BASE on this host, which meets the rule recorded for this merge in the item checkpoint (`baseline-after-integration-merge-e3e4aa551`); run (3) reports 0 failed and 0 errored. The difference between run (2) and run (3) for those two tests was not investigated.

Update, 2026-11-07: the coordinator that launched this run later relayed the parallel-only directive to the orchestrator directly, so its relay through the coordinator is now confirmed. The acceptance basis stated above is unchanged.
