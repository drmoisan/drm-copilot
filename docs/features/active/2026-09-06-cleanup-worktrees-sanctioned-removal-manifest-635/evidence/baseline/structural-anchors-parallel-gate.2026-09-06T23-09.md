# Structural Anchor Re-Derivation — `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1`

Timestamp: 2026-09-08T00-06

Task: [P0-T3]

## Route deviation, stated before any figure is read

Mandated command (attempted first, refused by the runtime worktree-isolation guard):

`pwsh -NoProfile -Command "Select-String -Path .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 -Pattern 'Import-Module','AllowedMergeStatuses','worktreePath =','itemRecord =','Test-ParallelWorktreeRemovalAllowed','Get-ParallelWorktreeGateBlockDecision -Reason' | Select-Object LineNumber,Line"`

The guard refuses every `pwsh` invocation issued through the Bash tool for a worktree-isolated
agent. The refusal, its message, and its persistence under an explicit `-WorkingDirectory` argument
are recorded in the [P0-T2] artifact in this same folder and, independently, in the issue-545
feature folder's `evidence/baseline/baseline-selfhosted-test.2026-09-07T10-57.md`.

Substituted route: `grep -n` with the same six patterns against the same file. `grep -n` reports the
same two values `Select-Object LineNumber,Line` reports. None of the six patterns contains a
regular-expression metacharacter.

Command:
`grep -n -e "Import-Module" -e "AllowedMergeStatuses" -e "worktreePath =" -e "itemRecord =" -e "Test-ParallelWorktreeRemovalAllowed" -e "Get-ParallelWorktreeGateBlockDecision -Reason" .claude/hooks/enforce-parallel-worktree-removal-gate.ps1`

EXIT_CODE: 0

## File total line count

313 lines, from `wc -l` on the same file in the same run.

## Full match list, all six patterns

| Line | Matching line (trimmed) |
| --- | --- |
| 32 | `Import-Module (Join-Path $PSScriptRoot '../lib/hook-payload/HookPayload.psm1') -Force` |
| 40 | `$script:AllowedMergeStatuses = @('merged', 'worktree_removed')` |
| 151 | `function Test-ParallelWorktreeRemovalAllowed {` |
| 175 | `return $script:AllowedMergeStatuses -contains ([string]$ItemRecord.merge_status)` |
| 225 | `return Get-ParallelWorktreeGateBlockDecision -Reason (` |
| 243 | `$worktreePath = Get-ParallelWorktreeRemovalCommandPath -CommandText $commandText` |
| 255 | `$itemRecord = Find-ParallelWorktreeItemRecord -Checkpoint $checkpoint -WorktreePath $worktreePath` |
| 256 | `if (Test-ParallelWorktreeRemovalAllowed -ItemRecord $itemRecord) {` |
| 260 | `return Get-ParallelWorktreeGateBlockDecision -Reason "PARALLEL_WORKTREE_REMOVAL_BLOCKED: ...` |

Exactly three of the six patterns matched more than one line, which is the shape the task predicted:

- `AllowedMergeStatuses` — 2 matches: 40, 175.
- `Test-ParallelWorktreeRemovalAllowed` — 2 matches: 151, 256.
- `Get-ParallelWorktreeGateBlockDecision -Reason` — 2 matches: 225, 260.

The other three patterns matched exactly one line each: `Import-Module` at 32, `worktreePath =` at
243, and `itemRecord =` at 255.

## The six anchors

| # | Anchor | Line | Structural description |
| --- | --- | --- | --- |
| 1 | `Import-Module` statement | 32 | The single column-0 `Import-Module` in the file, importing `HookPayload.psm1`. |
| 2 | `$script:AllowedMergeStatuses` assignment | 40 | The `$script:` assignment. Not 175, which is the read site inside `Test-ParallelWorktreeRemovalAllowed`. |
| 3 | `$worktreePath` assignment | 243 | Inside `Invoke-ParallelWorktreeRemovalGateDecision`, immediately after the `Test-CommandLineInvocation` scope filter's early allow return. |
| 4 | `$itemRecord` assignment | 255 | Inside the same function, immediately after the checkpoint parse block that closes on line 253. |
| 5 | `Test-ParallelWorktreeRemovalAllowed` call | 256 | The **call** inside `Invoke-ParallelWorktreeRemovalGateDecision`, not the function definition at 151. |
| 6 | Final `Get-ParallelWorktreeGateBlockDecision` return | 260 | The **last** of the two occurrences; the function's final return. The occurrence at 225 constructs the payload-anomaly reason and is not this anchor. |

Statement each later insertion sits after, expressed structurally so it survives line drift:

- The new `Import-Module` for the manifest module sits immediately **after** the
  `Import-Module (Join-Path $PSScriptRoot '../lib/hook-payload/HookPayload.psm1') -Force` statement.
- The new script-scope manifest-path constant sits immediately **after** the
  `$script:AllowedMergeStatuses = @('merged', 'worktree_removed')` assignment.
- The manifest authorization branch sits **after** the
  `if (Test-ParallelWorktreeRemovalAllowed -ItemRecord $itemRecord) { return Get-ParallelWorktreeGateAllowDecision }`
  block that closes on line 258, which is after the `$worktreePath` assignment and after the existing
  positive-predicate return, and **before** the final `Get-ParallelWorktreeGateBlockDecision` return
  on line 260.

## Deny Reason Verbatim:

The complete source text of the reason string passed to the **last**
`Get-ParallelWorktreeGateBlockDecision -Reason` occurrence (line 260, the final return of
`Invoke-ParallelWorktreeRemovalGateDecision`), exactly as it appears in the pre-change file,
including the `$worktreePath` token:

```
"PARALLEL_WORKTREE_REMOVAL_BLOCKED: git worktree remove for '$worktreePath' requires a matching parallel checkpoint items[] record with merge_status in {merged, worktree_removed}. The checkpoint was unreadable, no matching record was found, or merge_status was not yet safe for removal."
```

This string carries no doubled quote character. The earlier occurrence at line 225 constructs the
payload-anomaly reason (`PARALLEL_WORKTREE_REMOVAL_BLOCKED: payload anomaly - ...`) and is not this
block's subject. Both reasons begin with the same `PARALLEL_WORKTREE_REMOVAL_BLOCKED` code token,
which is why the occurrence rather than the token identifies the recorded value.

Output Summary: Six anchors re-derived against the current tree at line numbers 32, 40, 243, 255,
256, and 260. File total 313 lines. Three patterns matched more than once and their full match lists
are recorded above. The `Deny Reason Verbatim:` block is non-empty and was transcribed from line 260
of the pre-change file. The mandated `pwsh` route was refused by the runtime worktree-isolation
guard; `grep -n` was substituted and the deviation is recorded above.
