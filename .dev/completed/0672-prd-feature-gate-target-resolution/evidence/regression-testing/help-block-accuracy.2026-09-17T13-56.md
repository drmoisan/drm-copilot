# R2 — resolution-order help block rewritten to the delivered branch order

Timestamp: 2026-09-17T13-56

Task: `[P2-T3]` of `remediation-plan.2026-09-17T12-29.md`
Batch: R-B

Command, each run as `Select-String -SimpleMatch -Pattern '<token>' -Path '<path>'`.

EXIT_CODE: 0 for every invocation.

Output Summary:

## The required counts

| # | asserted token | path | pre-change count | post-change count | required | verdict |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | `earliest-occurring candidate` | `.claude/hooks/enforce-prd-feature-before-planner.ps1` | 1, at line 28 | **0** | 0 against a recorded pre-change count of 1 | **OK** |
| 2 | `If no candidate was found in the prompt` | same | 1, at line 31 | **0** | 0 against a recorded pre-change count of 1 | **OK** |
| 3 | `the derived call target is the only disambiguator` | same | 0 | **1**, at line 35 | exactly 1 | **OK** |
| 4 | `the checkpoint stands in only when the session root is the derived target` | same | 0 | **1**, at line 45 | exactly 1 | **OK** |
| 5 | `TARGET_WORKTREE_AMBIGUOUS` | same | 0 | **0** | 0 | **OK** |
| control | `TARGET_WORKTREE_AMBIGUOUS` | `.claude/lib/worktree-resolution/WorktreeResolution.psm1` | — | **2**, at lines 55 and 462 | non-zero | **OK** |

The pre-change counts for rows 1 and 2 are the values `[P0-T4]` measured before any file was edited, each
carrying a `MATCHES` verdict against the plan's preamble control table.

Row 5 and its control together satisfy criterion 24's requirement that the ambiguity reason code be read from
the resolution module and defined nowhere in the hook. The control count of 2 is what makes the hook's zero a
real assertion: the literal exists in the tree, in the module that owns it, and the hook simply does not carry
it. The rewritten help block refers to it as "that module's own ambiguity reason code" rather than quoting it.

Rows 3 and 4 assert the two mandated sentences are each present on a single line of their own. They are, at
lines 35 and 45.

## What the rewritten block now states, against the delivered code

The block replaced was 21 lines documenting a four-step order. Two of its steps described behaviour the
delivered change had already removed:

- **step 2 claimed a positional tie-break** — "otherwise the earliest-occurring candidate in the prompt wins";
- **step 3 claimed an unconditional checkpoint fallback** — "If no candidate was found in the prompt, read the
  feature-folder field from artifacts/orchestration/orchestrator-state.json".

The replacement is a seven-step order. Each step was re-derived against the delivered code in this pass:

| step | what it states | delivered code it describes |
| --- | --- | --- |
| 1 | the derivation runs first, and a signal it cannot narrow to one worktree denies before any probe | the `$target.Status -eq 'Ambiguous'` branch, which returns `Get-PrdFeatureAmbiguityDecision` before `Find-PrdFeatureFolderCandidate` is called |
| 2 | four-segment truncation, depth-insensitive, deduplicated in first-occurrence order | `Find-PrdFeatureFolderCandidate` and `ConvertTo-PrdFeatureFolderToken`; this step is carried over unchanged and remains accurate |
| 3 | **the derived-target disambiguator**, and that neither prompt position nor the checkpoint takes that role | `Select-PrdFeatureFolderByTarget`, whose own `.DESCRIPTION` states the same property: it compares the target's `SignalValue`, truncated to a folder token, against the candidate list and returns `$null` when the target names none of them |
| 4 | **the unresolved-tie deny** | the `-not $folder -and $candidates.Count -gt 1` branch, which denies with the ambiguity reason and does not select a candidate |
| 5 | **the conditional checkpoint**, and that a call targeting another worktree denies instead | the `-not $folder -and (Test-PrdFeatureSessionRootTarget -Target $target)` branch that consults the checkpoint, paired with the `-not $folder -and -not (Test-PrdFeatureSessionRootTarget ...)` branch that denies |
| 6 | the no-folder-at-all block reason | the terminal `-not $folder` branch returning the reference-a-feature-folder reason |
| 7 | **the folder-absent-under-the-target-root deny**, and that the marker-is-broken reason is reachable only when the folder does exist there | the `$probeFolder` composition, which applies `Join-WorktreeResolutionPath` only for an `OtherWorktree` target with a `WorktreeRoot`, and keeps the bare repo-relative spelling otherwise |

Step 7's final sentence is the property criterion 6 asserts, stated in the help block for the first time. It
is also the defect the `[P1-T7]` fail-before run reproduced: against the pre-change hook, the row
`denies with the ambiguity reason when a repo-relative citation places in no worktree` reached the
marker-is-broken reason, which step 7 now states is unreachable on that path.

## File size

The hook measures **456** physical lines after this task, against 431 before Phase 2 and a 500-line cap. The
net change across `[P2-T2]` and `[P2-T3]` is +25 lines: `[P2-T2]` was net zero, and this task's replacement
is 46 lines against the 21 it replaced. Headroom remaining: 44 lines. `[P2-T7]` records the measurement
formally.

Acceptance: the `earliest-occurring candidate` search returns 0 against a recorded pre-change count of 1; the
`If no candidate was found in the prompt` search returns 0 against a recorded pre-change count of 1; each of
the two quoted sentences returns exactly 1; the `TARGET_WORKTREE_AMBIGUOUS` search against the hook returns 0,
with a non-zero control count of 2 recorded from `.claude/lib/worktree-resolution/WorktreeResolution.psm1`.
Satisfied.
