# Structural Anchor Re-Derivation — `.claude/hooks/enforce-epic-worktree-removal-gate.ps1`

Timestamp: 2026-09-08T00-04

Task: [P0-T2]

## Route deviation, stated before any figure is read

Mandated command (attempted first, refused by the runtime worktree-isolation guard):

`pwsh -NoProfile -Command "Select-String -Path .claude/hooks/enforce-epic-worktree-removal-gate.ps1 -Pattern 'Import-Module','AllowedMergeStatuses','worktreePath =','featureRecord =','Test-ParallelCheckpointAllowsWorktreeRemoval','Get-EpicWorktreeGateBlockDecision -Reason' | Select-Object LineNumber,Line"`

The guard refuses every `pwsh` invocation issued through the Bash tool for a worktree-isolated
agent, with the message beginning `This agent is isolated in the worktree ... but this command runs
pwsh in a plain command`. No process starts, so the mandated command produces no exit code. The
same refusal is recorded against the same guard in the issue-545 feature folder's
`evidence/baseline/baseline-selfhosted-test.2026-09-07T10-57.md`, which additionally records that it
persists with an explicit `-WorkingDirectory` argument and with the worktree as the shell's current
directory.

Substituted route: `grep -n` with the same six patterns against the same file. `grep -n` reports the
same two values `Select-Object LineNumber,Line` reports — the 1-based line number and the matching
line — so the substitution changes the tool, not the observation. None of the six patterns contains a
regular-expression metacharacter, so the BRE and the .NET regex dialects agree on all six.

Command:
`grep -n -e "Import-Module" -e "AllowedMergeStatuses" -e "worktreePath =" -e "featureRecord =" -e "Test-ParallelCheckpointAllowsWorktreeRemoval" -e "Get-EpicWorktreeGateBlockDecision -Reason" .claude/hooks/enforce-epic-worktree-removal-gate.ps1`

EXIT_CODE: 0

## File total line count

444 lines, from `wc -l` on the same file in the same run.

## Full match list, all six patterns

| Line | Matching line (trimmed) |
| --- | --- |
| 62 | `Import-Module (Join-Path $PSScriptRoot '../lib/hook-payload/HookPayload.psm1') -Force` |
| 69 | `$script:AllowedMergeStatuses = @('merged', 'worktree_removed')` |
| 245 | `return $script:AllowedMergeStatuses -contains ([string]$FeatureRecord.merge_status)` |
| 248 | `function Test-ParallelCheckpointAllowsWorktreeRemoval {` |
| 306 | `return $script:AllowedMergeStatuses -contains ([string]$item.merge_status)` |
| 359 | `return Get-EpicWorktreeGateBlockDecision -Reason (` |
| 377 | `$worktreePath = Get-EpicWorktreeRemovalCommandPath -CommandText $commandText` |
| 381 | `$featureRecord = Find-EpicWorktreeFeatureRecord -Checkpoint $checkpoint -WorktreePath $worktreePath` |
| 387 | `if (Test-ParallelCheckpointAllowsWorktreeRemoval -Checkpoint $parallelCheckpoint -WorktreePath $worktreePath) {` |
| 391 | `return Get-EpicWorktreeGateBlockDecision -Reason "EPIC_WORKTREE_REMOVAL_BLOCKED: ...` |

Exactly three of the six patterns matched more than one line, which is the shape the task predicted:

- `AllowedMergeStatuses` — 3 matches: 69, 245, 306.
- `Test-ParallelCheckpointAllowsWorktreeRemoval` — 2 matches: 248, 387.
- `Get-EpicWorktreeGateBlockDecision -Reason` — 2 matches: 359, 391.

The other three patterns matched exactly one line each: `Import-Module` at 62, `worktreePath =` at
377, and `featureRecord =` at 381.

## The six anchors

| # | Anchor | Line | Structural description |
| --- | --- | --- | --- |
| 1 | `Import-Module` statement | 62 | The single column-0 `Import-Module` in the file, importing `HookPayload.psm1`. |
| 2 | `$script:AllowedMergeStatuses` assignment | 69 | The `$script:` assignment. Not 245 and not 306, which are read sites inside two predicate functions. |
| 3 | `$worktreePath` assignment | 377 | Inside `Invoke-EpicWorktreeRemovalGateDecision`, immediately after the `Test-CommandLineInvocation` scope filter's early allow return. |
| 4 | `$featureRecord` assignment | 381 | Inside the same function, immediately after the `$checkpoint` assignment on line 379. |
| 5 | `Test-ParallelCheckpointAllowsWorktreeRemoval` call | 387 | The **call** inside `Invoke-EpicWorktreeRemovalGateDecision`, not the function definition at 248. |
| 6 | Final `Get-EpicWorktreeGateBlockDecision` return | 391 | The **last** of the two occurrences; the function's final return. The occurrence at 359 constructs the payload-anomaly reason and is not this anchor. |

Statement each later insertion sits after, expressed structurally so it survives line drift:

- The new `Import-Module` for the manifest module sits immediately **after** the
  `Import-Module (Join-Path $PSScriptRoot '../lib/hook-payload/HookPayload.psm1') -Force` statement.
- The new script-scope manifest-path constant sits immediately **after** the
  `$script:AllowedMergeStatuses = @('merged', 'worktree_removed')` assignment.
- The manifest authorization branch sits **after** the
  `if (Test-ParallelCheckpointAllowsWorktreeRemoval ...) { return Get-EpicWorktreeGateAllowDecision }`
  block that closes on line 389, which is after the `$worktreePath` assignment and after both
  existing positive-predicate returns, and **before** the final
  `Get-EpicWorktreeGateBlockDecision` return on line 391.

## Deny Reason Verbatim:

The complete source text of the reason string passed to the **last**
`Get-EpicWorktreeGateBlockDecision -Reason` occurrence (line 391, the final return of
`Invoke-EpicWorktreeRemovalGateDecision`), exactly as it appears in the pre-change file, including
the `$worktreePath` token and the doubled quote characters around `parallel`:

```
"EPIC_WORKTREE_REMOVAL_BLOCKED: git worktree remove for '$worktreePath' requires either an epic checkpoint features[] record with merge_status in {merged, worktree_removed}, or a parallel-orchestrator checkpoint with route_id == ""parallel"" whose matching items[] record (matched by worktree_path) has merge_status in {merged, worktree_removed}. No checkpoint authorized this removal."
```

The earlier occurrence at line 359 constructs the payload-anomaly reason
(`EPIC_WORKTREE_REMOVAL_BLOCKED: payload anomaly - ...`) and is not this block's subject. Both
reasons begin with the same `EPIC_WORKTREE_REMOVAL_BLOCKED` code token, which is why the occurrence
rather than the token identifies the recorded value.

Output Summary: Six anchors re-derived against the current tree at line numbers 62, 69, 377, 381,
387, and 391. File total 444 lines. Three patterns matched more than once and their full match lists
are recorded above. The `Deny Reason Verbatim:` block is non-empty and was transcribed from line 391
of the pre-change file. The mandated `pwsh` route was refused by the runtime worktree-isolation
guard; `grep -n` was substituted and the deviation is recorded above.
