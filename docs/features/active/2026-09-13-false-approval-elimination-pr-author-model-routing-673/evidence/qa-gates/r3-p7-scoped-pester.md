# Phase 7 Scoped Pester Verification (issue #673)

Timestamp: 2026-09-19T18-36

Command: `pwsh -NoProfile -File <SCRATCHPAD>/r3-test-scoped.ps1` (route `a`) with the scan-folder list supplied as `tests/scripts/claude-hooks,tests/scripts/claude-runtime,tests/scripts/claude-lib`, running `Invoke-PoshQCTest -Root $root -ScanFolders tests/scripts/claude-hooks,tests/scripts/claude-runtime,tests/scripts/claude-lib -SettingsPath scripts/powershell/PoshQC/settings/pester.runsettings.psd1`; then `pwsh -NoProfile -File <SCRATCHPAD>/r3-report.ps1`.

EXIT_CODE: 0

## Report freshness

- JUnit report last write (UTC): `2026-09-19T18:39:29Z`, later than this artifact's `Timestamp:` of `2026-09-19T18-36`.

## Root results

| Attribute | Value |
| --- | --- |
| `tests` | 3408 |
| `failures` | 0 |
| `errors` | 0 |

Testcases carrying a `failure` child: none. The `[P0-T10]` baseline recorded no failing test, so the exclusion this task's acceptance allows for is empty and the zero is unconditional.

## Every testcase under the four named testsuites (72 rows, all Passed)

| Testsuite | Testcase | Status |
| --- | --- | --- |
| `enforce-pr-author-skill.WorktreeResolution.Tests.ps1` | `pr-author R1 allows when the resolved own checkpoint is ready and the working directory is the sibling session root` | Passed |
| `enforce-pr-author-skill.WorktreeResolution.Tests.ps1` | `pr-author R1 allows when the branch locates the own ready checkpoint from the sibling session root` | Passed |
| `enforce-pr-author-skill.WorktreeResolution.Tests.ps1` | `pr-author R2 denies with the no-target code when only the sibling session-root checkpoint is present` | Passed |
| `enforce-pr-author-skill.WorktreeResolution.Tests.ps1` | `pr-author R3 denies with the preflight reason when the resolved own checkpoint is not ready` | Passed |
| `enforce-pr-author-skill.WorktreeResolution.Tests.ps1` | `pr-author R3 denies with the preflight reason when the checkpoint is absent at the resolved target` | Passed |
| `enforce-pr-author-skill.WorktreeResolution.Tests.ps1` | `pr-author R4 takes the preflight verdict from the own checkpoint located by branch when the sibling checkpoint is ready` | Passed |
| `enforce-pr-author-skill.WorktreeResolution.Tests.ps1` | `pr-author R4 takes the epic base-branch verdict from the own checkpoint when own and sibling checkpoints are both present` | Passed |
| `enforce-pr-author-skill.WorktreeResolution.Tests.ps1` | `pr-author R5 denies with the no-target code when the command names no target` | Passed |
| `enforce-pr-author-skill.WorktreeResolution.Tests.ps1` | `pr-author R6 allows when the working directory is the item worktree and its own checkpoint is ready` | Passed |
| `enforce-pr-author-skill.WorktreeResolution.Tests.ps1` | `pr-author R7 denies with the preflight reason when the resolved checkpoint is unparseable` | Passed |
| `enforce-pr-author-skill.WorktreeResolution.Tests.ps1` | `pr-author R7 denies with the preflight reason when the resolved checkpoint is empty` | Passed |
| `enforce-pr-author-skill.WorktreeResolution.Tests.ps1` | `pr-author R8 denies with the no-target code when the branch is checked out in no live worktree` | Passed |
| `enforce-pr-author-skill.WorktreeResolution.Tests.ps1` | `pr-author R9 denies with the ambiguity code when the branch is checked out in two live worktrees` | Passed |
| `enforce-pr-author-skill.WorktreeResolution.Tests.ps1` | `pr-author R10 allows a command that is not a gated gh pr invocation when the target is unresolvable` | Passed |
| `enforce-pr-author-skill.WorktreeResolution.Tests.ps1` | `pr-author genuine-absence and target-resolution reason codes never appear in each other's decisions` | Passed |
| `enforce-pr-author-skill.WorktreeResolution.Tests.ps1` | `pr-author denies an unresolved NoTarget target without reaching the orchestrator-state preflight` | Passed |
| `enforce-pr-author-skill.WorktreeResolution.Tests.ps1` | `pr-author denies an unresolved Ambiguous target without reaching the orchestrator-state preflight` | Passed |
| `enforce-pr-author-skill.WorktreeResolution.Tests.ps1` | `pr-author passes one resolved checkpoint path to both the preflight and the epic base-branch check` | Passed |
| `enforce-model-routing-receipt.WorktreeResolution.Tests.ps1` | `model-routing R1 allows when the resolved own checkpoint records the receipt` | Passed |
| `enforce-model-routing-receipt.WorktreeResolution.Tests.ps1` | `model-routing R2 denies with the no-target code when only the sibling session-root checkpoint is present` | Passed |
| `enforce-model-routing-receipt.WorktreeResolution.Tests.ps1` | `model-routing R2 denies with the no-target code when the only signal is a repository-relative path` | Passed |
| `enforce-model-routing-receipt.WorktreeResolution.Tests.ps1` | `model-routing R3 denies with the blocked reason when the resolved own checkpoint records no receipt` | Passed |
| `enforce-model-routing-receipt.WorktreeResolution.Tests.ps1` | `model-routing R3 denies with the blocked reason when the checkpoint is absent at the resolved target` | Passed |
| `enforce-model-routing-receipt.WorktreeResolution.Tests.ps1` | `model-routing R4 takes the verdict from the own checkpoint located by issue number when the sibling checkpoint records the receipt` | Passed |
| `enforce-model-routing-receipt.WorktreeResolution.Tests.ps1` | `model-routing R4 selects the branch-named worktree when a stale attempt records the same issue` | Passed |
| `enforce-model-routing-receipt.WorktreeResolution.Tests.ps1` | `model-routing R5 denies with the no-target code when the prompt names no target` | Passed |
| `enforce-model-routing-receipt.WorktreeResolution.Tests.ps1` | `model-routing R6 allows when the working directory is the item worktree and its own receipt is present` | Passed |
| `enforce-model-routing-receipt.WorktreeResolution.Tests.ps1` | `model-routing R7 denies with the blocked reason when the resolved checkpoint is unparseable` | Passed |
| `enforce-model-routing-receipt.WorktreeResolution.Tests.ps1` | `model-routing R7 denies with the blocked reason when the resolved checkpoint is empty` | Passed |
| `enforce-model-routing-receipt.WorktreeResolution.Tests.ps1` | `model-routing R8 denies with the no-target code when the issue is recorded in no live worktree` | Passed |
| `enforce-model-routing-receipt.WorktreeResolution.Tests.ps1` | `model-routing R9 denies with the ambiguity code when the issue and the branch name different worktrees` | Passed |
| `enforce-model-routing-receipt.WorktreeResolution.Tests.ps1` | `model-routing R9 denies with the ambiguity code when two live worktrees record the issue` | Passed |
| `enforce-model-routing-receipt.WorktreeResolution.Tests.ps1` | `model-routing R10 allows a subagent outside the gated set when the target is unresolvable` | Passed |
| `enforce-model-routing-receipt.WorktreeResolution.Tests.ps1` | `model-routing genuine-absence and target-resolution reason codes never appear in each other's decisions` | Passed |
| `enforce-model-routing-receipt.WorktreeResolution.Tests.ps1` | `model-routing denies an unresolved NoTarget target without reaching the checkpoint read` | Passed |
| `enforce-model-routing-receipt.WorktreeResolution.Tests.ps1` | `model-routing denies an unresolved Ambiguous target without reaching the checkpoint read` | Passed |
| `enforce-model-routing-receipt.WorktreeResolution.Tests.ps1` | `model-routing reads the checkpoint at the resolved absolute path for a SessionRoot target` | Passed |
| `enforce-model-routing-receipt.WorktreeResolution.Tests.ps1` | `model-routing reads the checkpoint at the resolved absolute path for a OtherWorktree target` | Passed |
| `WorktreeItemResolution.Tests.ps1` | `returns the repository-relative orchestrator checkpoint path` | Passed |
| `WorktreeItemResolution.Tests.ps1` | `matches the default checkpoint path of Invoke-OrchestratorStatePreflight` | Passed |
| `WorktreeItemResolution.Tests.ps1` | `composes the absolute checkpoint path under a worktree root` | Passed |
| `WorktreeItemResolution.Tests.ps1` | `reads every distinct issue number from canonical issue lines` | Passed |
| `WorktreeItemResolution.Tests.ps1` | `returns no issue number for text without a canonical issue line` | Passed |
| `WorktreeItemResolution.Tests.ps1` | `normalises string and integer issue-num values` | Passed |
| `WorktreeItemResolution.Tests.ps1` | `rejects zero, none, empty, and non-numeric issue-num values` | Passed |
| `WorktreeItemResolution.Tests.ps1` | `reads the issue number from a worktree checkpoint through the checkpoint text seam` | Passed |
| `WorktreeItemResolution.Tests.ps1` | `returns no issue number for an absent, empty, or unparseable checkpoint` | Passed |
| `WorktreeItemResolution.Tests.ps1` | `keeps only registered worktrees that still carry a root marker` | Passed |
| `WorktreeItemResolution.Tests.ps1` | `returns no live worktree when the session path is inside no repository` | Passed |
| `WorktreeItemResolution.Tests.ps1` | `resolves NoTarget without enumerating worktrees when the text carries no identity` | Passed |
| `WorktreeItemResolution.Tests.ps1` | `resolves the single live worktree whose checkpoint records the issue` | Passed |
| `WorktreeItemResolution.Tests.ps1` | `resolves NoTarget when no live worktree records the issue` | Passed |
| `WorktreeItemResolution.Tests.ps1` | `resolves Ambiguous when two live worktrees record the issue` | Passed |
| `WorktreeItemResolution.Tests.ps1` | `breaks a stale-attempt tie with the branch signal` | Passed |
| `WorktreeItemResolution.Tests.ps1` | `resolves Ambiguous when the branch worktree records a different issue` | Passed |
| `WorktreeItemResolution.Tests.ps1` | `resolves Ambiguous when the branch and the issue name different worktrees` | Passed |
| `WorktreeItemResolution.Tests.ps1` | `resolves the branch worktree when its checkpoint records no issue and no other worktree records it` | Passed |
| `WorktreeItemResolution.Tests.ps1` | `resolves Ambiguous when the text names two different issue numbers` | Passed |
| `WorktreeItemResolution.Tests.ps1` | `resolves the branch worktree when only a branch signal is present` | Passed |
| `WorktreeItemResolution.Tests.ps1` | `resolves NoTarget when the branch is checked out in no live worktree` | Passed |
| `WorktreeItemResolution.Tests.ps1` | `ignores a feature-folder path and resolves NoTarget when it is the only signal` | Passed |
| `WorktreeItemResolution.Tests.ps1` | `resolves by branch when a relative feature folder and a unique branch are both present` | Passed |
| `WorktreeItemResolution.Tests.ps1` | `labels the result SessionRoot when the resolved worktree is the session root` | Passed |
| `WorktreeItemResolution.Tests.ps1` | `carries the no-target and ambiguity codes supplied by the worktree-resolution accessors` | Passed |
| `WorktreeItemResolution.Tests.ps1` | `names no absolute path in the Detail of any result` | Passed |
| `enforcement-hooks-checkpoint-path-explicit.Tests.ps1` | `every production call to Invoke-OrchestratorStatePreflight supplies CheckpointPath explicitly` | Passed |
| `enforcement-hooks-checkpoint-path-explicit.Tests.ps1` | `every production call to Get-PrAuthorCheckpointContent supplies CheckpointPath explicitly` | Passed |
| `enforcement-hooks-checkpoint-path-explicit.Tests.ps1` | `every production call to Get-ModelRoutingCheckpoint supplies CheckpointPath explicitly` | Passed |
| `enforcement-hooks-checkpoint-path-explicit.Tests.ps1` | `every production call to Test-EpicBaseBranchOverride supplies CheckpointPath explicitly` | Passed |
| `enforcement-hooks-checkpoint-path-explicit.Tests.ps1` | `every production call to Test-PrAuthorReceiptVerification supplies CheckpointPath explicitly` | Passed |
| `enforcement-hooks-checkpoint-path-explicit.Tests.ps1` | `the in-scope hook files carry the checkpoint path literal in no string expression` | Passed |
| `enforcement-hooks-checkpoint-path-explicit.Tests.ps1` | `the orchestrator-state module keeps its four hundred ninety-nine line count` | Passed |

All 72 rows pass. That is every name §7 assigns to these four files except one: `every production call to Get-PrdFeatureCheckpointFolder supplies CheckpointPath explicitly`, which `[P9-T10]` adds once the production change it asserts exists. Each name appears exactly once.

## Counts per testsuite

| Testsuite | Rows | Passed | Failed |
| --- | --- | --- | --- |
| `WorktreeItemResolution.Tests.ps1` | 27 | 27 | 0 |
| `enforce-pr-author-skill.WorktreeResolution.Tests.ps1` | 18 | 18 | 0 |
| `enforce-model-routing-receipt.WorktreeResolution.Tests.ps1` | 20 | 20 | 0 |
| `enforcement-hooks-checkpoint-path-explicit.Tests.ps1` | 7 | 7 | 0 |

The model-routing matrix moved from 3 of 20 passing to 20 of 20. Seventeen rows changed status, which is the whole of this phase's behavioural effect.

Output Summary: All four acceptance conditions hold. The report post-dates this artifact's timestamp; the root records `failures 0` and `errors 0` with no exclusion applied; and every §7 name for the four files, other than the row `[P9-T10]` adds later, appears exactly once with status Passed. Both gate families are now fully green against their matrices, and the structural guard confirms every production checkpoint reader is given its path explicitly.
