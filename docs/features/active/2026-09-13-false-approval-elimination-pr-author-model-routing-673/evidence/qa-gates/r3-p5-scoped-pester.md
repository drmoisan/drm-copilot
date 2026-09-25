# Phase 5 Scoped Pester Verification (issue #673)

Timestamp: 2026-09-19T18-28

Command: `pwsh -NoProfile -File <SCRATCHPAD>/r3-test-scoped.ps1` (route `a`) with the scan-folder list supplied as `tests/scripts/claude-hooks`, running `Invoke-PoshQCTest -Root $root -ScanFolders tests/scripts/claude-hooks -SettingsPath scripts/powershell/PoshQC/settings/pester.runsettings.psd1`; then `pwsh -NoProfile -File <SCRATCHPAD>/r3-report.ps1`.

EXIT_CODE: 17

The exit code equals the failure count, and every failure is in the one testsuite this task explicitly exempts: `enforce-model-routing-receipt.WorktreeResolution.Tests.ps1`, which is still authored against the unmodified model-routing hook. Phase 7 implements that family and `[P7-T6]` requires all 20 of its rows to pass.

## Report freshness

- JUnit report last write (UTC): `2026-09-19T18:30:12Z`, later than this artifact's `Timestamp:` of `2026-09-19T18-28`.

## Root results

| Attribute | Value |
| --- | --- |
| `tests` | 1817 |
| `failures` | 17 |
| `errors` | 0 |

Console summary: `Tests Passed: 1800, Failed: 17`.

## Testsuites required to have `failures` 0

| Testsuite | tests | failures | passed |
| --- | --- | --- | --- |
| `enforce-pr-author-skill.Tests.ps1` | 43 | 0 | 43 |
| `enforce-pr-author-skill.TargetResolution.Tests.ps1` | 5 | 0 | 5 |
| `enforce-pr-author-skill.OrchestratorStatePreflight.Tests.ps1` | 3 | 0 | 3 |
| `enforce-pr-author-skill.epic-base-branch.Tests.ps1` | 9 | 0 | 9 |
| `enforce-pr-author-skill.epic-base-branch.TriggerScoping.Tests.ps1` | 2 | 0 | 2 |
| `enforce-pr-author-skill.WorktreeResolution.Tests.ps1` | 18 | 0 | 18 |
| `enforce-prd-feature-before-planner.Tests.ps1` | 47 | 0 | 47 |
| `enforce-prd-feature-before-planner.FolderResolution.Tests.ps1` | 25 | 0 | 25 |
| `enforce-prd-feature-before-planner.TargetResolution.Tests.ps1` | 28 | 0 | 28 |
| `enforce-model-routing-receipt.Tests.ps1` | 15 | 0 | 15 |

Every listed pr-author testsuite has `failures` 0, including `enforce-pr-author-skill.WorktreeResolution.Tests.ps1`, whose 18 expanded rows all pass. The three prd-feature testsuites and `enforce-model-routing-receipt.Tests.ps1` are untouched by this phase and remain at `failures` 0, so the pr-author edits caused no collateral regression in the two families Phases 7 and 9 change later.

## What changed since the fail-before run

Ten rows of the pr-author matrix moved from Failed to Passed:

- `pr-author R1 allows when the branch locates the own ready checkpoint from the sibling session root`
- `pr-author R3 denies with the preflight reason when the resolved own checkpoint is not ready`
- `pr-author R3 denies with the preflight reason when the checkpoint is absent at the resolved target`
- `pr-author R4 takes the preflight verdict from the own checkpoint located by branch when the sibling checkpoint is ready`
- `pr-author R4 takes the epic base-branch verdict from the own checkpoint when own and sibling checkpoints are both present`
- `pr-author R7 denies with the preflight reason when the resolved checkpoint is unparseable`
- `pr-author R7 denies with the preflight reason when the resolved checkpoint is empty`
- `pr-author R8 denies with the no-target code when the branch is checked out in no live worktree`
- `pr-author genuine-absence and target-resolution reason codes never appear in each other's decisions`
- `pr-author passes one resolved checkpoint path to both the preflight and the epic base-branch check`

The fourth of these is the substitute fail-before row for binding 2: it allowed against the unmodified hook and denies now, which is the pass-after half of the AC-12 evidence the dossier names.

## `enforce-model-routing-receipt.WorktreeResolution.Tests.ps1` (still pre-fix, exempt)

Every `testcase` status in that testsuite:

| Testcase | Status |
| --- | --- |
| `model-routing R1 allows when the resolved own checkpoint records the receipt` | Passed |
| `model-routing R2 denies with the no-target code when only the sibling session-root checkpoint is present` | Failed |
| `model-routing R2 denies with the no-target code when the only signal is a repository-relative path` | Failed |
| `model-routing R3 denies with the blocked reason when the resolved own checkpoint records no receipt` | Failed |
| `model-routing R3 denies with the blocked reason when the checkpoint is absent at the resolved target` | Failed |
| `model-routing R4 takes the verdict from the own checkpoint located by issue number when the sibling checkpoint records the receipt` | Failed |
| `model-routing R4 selects the branch-named worktree when a stale attempt records the same issue` | Failed |
| `model-routing R5 denies with the no-target code when the prompt names no target` | Failed |
| `model-routing R6 allows when the working directory is the item worktree and its own receipt is present` | Passed |
| `model-routing R7 denies with the blocked reason when the resolved checkpoint is unparseable` | Failed |
| `model-routing R7 denies with the blocked reason when the resolved checkpoint is empty` | Failed |
| `model-routing R8 denies with the no-target code when the issue is recorded in no live worktree` | Failed |
| `model-routing R9 denies with the ambiguity code when the issue and the branch name different worktrees` | Failed |
| `model-routing R9 denies with the ambiguity code when two live worktrees record the issue` | Failed |
| `model-routing R10 allows a subagent outside the gated set when the target is unresolvable` | Passed |
| `model-routing genuine-absence and target-resolution reason codes never appear in each other's decisions` | Failed |
| `model-routing denies an unresolved NoTarget target without reaching the checkpoint read` | Failed |
| `model-routing denies an unresolved Ambiguous target without reaching the checkpoint read` | Failed |
| `model-routing reads the checkpoint at the resolved absolute path for a SessionRoot target` | Failed |
| `model-routing reads the checkpoint at the resolved absolute path for a OtherWorktree target` | Failed |

Seventeen Failed and three Passed, identical to the fail-before run: Phase 5 touched no model-routing file, so this testsuite's statuses are unchanged.

Output Summary: All four acceptance conditions hold. The report post-dates this artifact's timestamp; every listed pr-author testsuite, the three prd-feature testsuites, and `enforce-model-routing-receipt.Tests.ps1` have `failures` 0. The pr-author matrix is fully green at 18 of 18, ten of its rows having moved from Failed to Passed, including the substitute fail-before row for the epic base-branch binding. The 17 remaining failures are confined to the still-pre-fix model-routing matrix, which this task exempts and Phase 7 addresses.
