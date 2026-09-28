# Fail-Before Matrix Run Against the Unmodified Hooks (issue #673) [expect-fail]

Timestamp: 2026-09-19T18-21

Command: `pwsh -NoProfile -File <SCRATCHPAD>/r3-test-scoped.ps1` (route `a`) with the scan-folder list supplied as `tests/scripts/claude-hooks`, running `Invoke-PoshQCTest -Root $root -ScanFolders tests/scripts/claude-hooks -SettingsPath scripts/powershell/PoshQC/settings/pester.runsettings.psd1`; then `pwsh -NoProfile -File <SCRATCHPAD>/r3-report.ps1` to read the report.

EXIT_CODE: 27

A non-zero exit is the expected outcome of this task and of this task alone. Both matrix suites were authored against the **unmodified** hooks, so every row whose subject is the behaviour this change set adds must fail here and pass after the implementation phases. The exit code equals the failure count the runner reports.

## Report freshness

- JUnit report last write (UTC): `2026-09-19T18:22:40Z`, later than this artifact's `Timestamp:` of `2026-09-19T18-21`.

## Root results

| Attribute | Value |
| --- | --- |
| `tests` | 1817 |
| `failures` | 27 |
| `errors` | 0 |
| `disabled` | 0 |

Console summary: `Tests Passed: 1790, Failed: 27, Skipped: 0, Inconclusive: 0, NotRun: 0`.

All 27 failing testcases belong to the two `WorktreeResolution` testsuites this task authored. **Every pre-existing testsuite under `tests/scripts/claude-hooks` therefore has `failures` 0**, which is the last acceptance condition; the `[P0-T10]` baseline recorded no failing test, so no exclusion applies.

## Every testcase under the two new testsuites

Both testsuites are present in the report. 38 expanded rows: 18 from the pr-author suite and 20 from the model-routing suite.

| Testcase | Status |
| --- | --- |
| pr-author R1 allows when the resolved own checkpoint is ready and the working directory is the sibling session root | Passed |
| pr-author R1 allows when the branch locates the own ready checkpoint from the sibling session root | Failed |
| pr-author R2 denies with the no-target code when only the sibling session-root checkpoint is present | Passed |
| pr-author R3 denies with the preflight reason when the resolved own checkpoint is not ready | Failed |
| pr-author R3 denies with the preflight reason when the checkpoint is absent at the resolved target | Failed |
| pr-author R4 takes the preflight verdict from the own checkpoint located by branch when the sibling checkpoint is ready | Failed |
| pr-author R4 takes the epic base-branch verdict from the own checkpoint when own and sibling checkpoints are both present | Failed |
| pr-author R5 denies with the no-target code when the command names no target | Passed |
| pr-author R6 allows when the working directory is the item worktree and its own checkpoint is ready | Passed |
| pr-author R7 denies with the preflight reason when the resolved checkpoint is unparseable | Failed |
| pr-author R7 denies with the preflight reason when the resolved checkpoint is empty | Failed |
| pr-author R8 denies with the no-target code when the branch is checked out in no live worktree | Failed |
| pr-author R9 denies with the ambiguity code when the branch is checked out in two live worktrees | Passed |
| pr-author R10 allows a command that is not a gated gh pr invocation when the target is unresolvable | Passed |
| pr-author genuine-absence and target-resolution reason codes never appear in each other's decisions | Failed |
| pr-author denies an unresolved NoTarget target without reaching the orchestrator-state preflight | Passed |
| pr-author denies an unresolved Ambiguous target without reaching the orchestrator-state preflight | Passed |
| pr-author passes one resolved checkpoint path to both the preflight and the epic base-branch check | Failed |
| model-routing R1 allows when the resolved own checkpoint records the receipt | Passed |
| model-routing R2 denies with the no-target code when only the sibling session-root checkpoint is present | Failed |
| model-routing R2 denies with the no-target code when the only signal is a repository-relative path | Failed |
| model-routing R3 denies with the blocked reason when the resolved own checkpoint records no receipt | Failed |
| model-routing R3 denies with the blocked reason when the checkpoint is absent at the resolved target | Failed |
| model-routing R4 takes the verdict from the own checkpoint located by issue number when the sibling checkpoint records the receipt | Failed |
| model-routing R4 selects the branch-named worktree when a stale attempt records the same issue | Failed |
| model-routing R5 denies with the no-target code when the prompt names no target | Failed |
| model-routing R6 allows when the working directory is the item worktree and its own receipt is present | Passed |
| model-routing R7 denies with the blocked reason when the resolved checkpoint is unparseable | Failed |
| model-routing R7 denies with the blocked reason when the resolved checkpoint is empty | Failed |
| model-routing R8 denies with the no-target code when the issue is recorded in no live worktree | Failed |
| model-routing R9 denies with the ambiguity code when the issue and the branch name different worktrees | Failed |
| model-routing R9 denies with the ambiguity code when two live worktrees record the issue | Failed |
| model-routing R10 allows a subagent outside the gated set when the target is unresolvable | Passed |
| model-routing genuine-absence and target-resolution reason codes never appear in each other's decisions | Failed |
| model-routing denies an unresolved NoTarget target without reaching the checkpoint read | Failed |
| model-routing denies an unresolved Ambiguous target without reaching the checkpoint read | Failed |
| model-routing reads the checkpoint at the resolved absolute path for a SessionRoot target | Failed |
| model-routing reads the checkpoint at the resolved absolute path for a OtherWorktree target | Failed |

## The four rows this task requires to be Failed

| Testcase | Status | Why it fails against the unmodified hook |
| --- | --- | --- |
| `model-routing R2 denies with the no-target code when only the sibling session-root checkpoint is present` | Failed | The gate has no resolution step at all, so it reads the session root's checkpoint, finds the sibling's `atomic-planner` receipt, and allows. This is defect 3.4 reproduced as a test. |
| `model-routing R2 denies with the no-target code when the only signal is a repository-relative path` | Failed | Same cause, driven by the prompt pinned in the archived reproduction control pair. |
| `model-routing R4 takes the verdict from the own checkpoint located by issue number when the sibling checkpoint records the receipt` | Failed | Same cause: the verdict comes from the session root rather than from the worktree the issue number identifies. |
| `pr-author R4 takes the epic base-branch verdict from the own checkpoint when own and sibling checkpoints are both present` | Failed | Binding 2. `Test-EpicBaseBranchOverride` takes no checkpoint path, so check 6 reads the session root's checkpoint, finds no epic mode, and allows. This is the substitute fail-before evidence RS-5 names for AC-12's binding-2 half. |

## The five rows this task requires to be Passed

| Testcase | Status | Why it already passes |
| --- | --- | --- |
| `pr-author R2 denies with the no-target code when only the sibling session-root checkpoint is present` | Passed | #687 already added the no-target deny to the pr-author gate, which is why a genuine failing run is impossible for this row and a fail-before exception dossier stands in its place. |
| `pr-author R1 allows when the resolved own checkpoint is ready and the working directory is the sibling session root` | Passed | #687 already composes the resolved worktree's checkpoint path for an `OtherWorktree` result, so this row is a regression guard rather than new behaviour. |
| `pr-author R6 allows when the working directory is the item worktree and its own checkpoint is ready` | Passed | The standalone topology, which the spec requires to behave exactly as it does now. |
| `model-routing R1 allows when the resolved own checkpoint records the receipt` | Passed | The row's resolved target and the session root both record the receipt, so the pre-change and post-change readings agree. |
| `model-routing R6 allows when the working directory is the item worktree and its own receipt is present` | Passed | The standalone topology for the model-routing gate. |

The two allow rows named above are the AC-18 pair: they are observed passing against the unmodified hooks, and `[P4-T6]` archives that observation.

## The remaining failures

The other 18 failures are identity rows and capture rows whose subject does not exist yet. They route through `Resolve-WorktreeCallTarget` rather than the identity resolver before the fix, and the two model-routing capture rows name `Resolve-ModelRoutingWorktreeTarget`, a function the implementation phase adds. This task states no required status for them; `[P7-T6]` requires every one to pass.

Output Summary: The expected-failure run completed with 1790 passed and 27 failed, all 27 inside the two suites this task authored and none in any pre-existing suite. All four rows required to be Failed are Failed and all five rows required to be Passed are Passed. Both testsuites are present in the report and the report post-dates this artifact's timestamp.
