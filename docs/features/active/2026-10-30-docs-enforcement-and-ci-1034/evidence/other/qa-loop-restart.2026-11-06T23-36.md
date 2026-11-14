# QA Loop Restart Record - Issue 1034 (loop pass 8 to loop pass 9)

Timestamp: 2026-11-06T23-36
Command: sh SCRATCH/issue-1034-p7t3.sh (new PowerShell 7 process; SCRATCH/issue-1034-pester.ps1 -Root <worktree> -ScanFolders tests/scripts/claude-lib,tests/scripts/claude-hooks,tests/scripts/claude-runtime with an -InvokePester seam; Pester 6.2.0)
EXIT_CODE: 1
Output Summary: P7-T3 of loop pass 8 FAILED and the loop restarts at P7-T1 as pass 9. Pester result object: 12584 passed, 1 failed, 1 skipped, 0 failed blocks, 0 failed containers, 441 test files, 1550.13 s. P7-T1 and P7-T2 of pass 8 passed before the failure.

## Failure

- File: `tests/scripts/claude-hooks/cleanup-merged-worktrees-workflow.EndToEnd.Tests.ps1` (outside TOUCHED_SUITES; arrived with the integration merge, issue #1026).
- Test: `cleanup-merged-worktrees workflow end to end with no checkpoint (issue #1026).lists every hook registered for the Bash, Write|Edit, and Agent matchers as composed or exempted`.
- Message: Expected $null or empty, because a newly registered hook must be composed here or exempted with a reason, but got 'enforce-docs-complete-gate.ps1'.

## Attribution

The test is absent from the P0-T9 baseline. The hook is registered only on this branch, so the test passes at MERGE_BASE e3e4aa551 and this is a new failure caused by this branch, not a pre-existing one. It first appeared in this pass because the guard reached the branch through merge 7599a3b00.

## Fix

One `$script:ExemptHook` row for `enforce-docs-complete-gate.ps1`, the route the guard's own failure message prescribes. No assertion changed. The reason is that the workflow creates a pull request and does not merge one, the same reason the table records for `enforce-epic-merge-gate.ps1`: the hook returns allow with no I/O for any command outside the merge and enqueue scope of Test-EpicMergeGateCommandInScope.

The test file was outside `## Artifact Classification`, so an executor-marked row and a `## Notes` entry were added to the plan. No task was added, removed or reordered. The suite is held to the TOUCHED_SUITES standard (0 failed, 0 errored) and is added to the P7-T8 shuffled runs.
