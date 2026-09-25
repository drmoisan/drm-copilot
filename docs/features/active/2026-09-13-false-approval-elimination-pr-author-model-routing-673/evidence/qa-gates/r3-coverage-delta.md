# Coverage Delta (issue #673)

Timestamp: 2026-09-19T19-26

Command: baseline figures from `evidence/baseline/r3-phase0-pester-coverage.md` (`[P0-T10]`); post figures from `evidence/qa-gates/r3-final-pester-coverage.md` (`[P11-T4]`); changed-line coverage from `pwsh -NoProfile -File <SCRATCHPAD>/r3-changed-line-coverage.ps1`, which intersects the added-line numbers of `git diff -U0 b7c1161655b4b53b0358dc7890a26200207c4b91 HEAD -- <file>` with the `line` elements of `artifacts/pester/powershell-coverage.xml` and counts those whose `ci` attribute is greater than zero.

EXIT_CODE: 0

The coverage report carries `line` elements for all seven files — 106, 93, 90, 59, 57, 50, and 26 of them — so the changed-line computation has data and this task is not remediation-required on that ground.

## The twenty-one values

| File | Baseline percent | Post percent | Changed-line coverage |
| --- | --- | --- | --- |
| `.claude/hooks/enforce-pr-author-skill.ps1` | 92% | 92% | 100% |
| `.claude/hooks/enforce-pr-author-skill-helpers.ps1` | 95.51% | 96.67% | 100% |
| `.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1` | 92.31% | 92.31% | 100% |
| `.claude/hooks/enforce-model-routing-receipt.ps1` | 92.68% | 94.74% | 100% |
| `.claude/hooks/enforce-prd-feature-before-planner.ps1` | 90.72% | 90.32% | 100% |
| `.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1` | 96.77% | 96.61% | 100% |
| `.claude/lib/worktree-resolution/WorktreeItemResolution.psm1` | n/a (new file) | 99.06% | 99.06% |

Twenty-one values recorded, with the new module's baseline as `n/a (new file)`.

## Condition-by-condition result

| Condition | Result |
| --- | --- |
| Every post percent at least 85% | **met** — lowest is 90.32% |
| Every changed-line figure at least 85% | **met** — six files at 100%, one at 99.06% |
| Every hook's post percent at least its baseline | **NOT MET for two of the six hooks** |

## The two files below baseline, and why

`.claude/hooks/enforce-prd-feature-before-planner.ps1`: 90.72% to 90.32%, a fall of 0.40 points.
`.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1`: 96.77% to 96.61%, a fall of 0.16 points.

The raw counters show what moved:

| File | Baseline covered / missed / total | Post covered / missed / total |
| --- | --- | --- |
| `enforce-prd-feature-before-planner.ps1` | 88 / 9 / 97 | 84 / **9** / 93 |
| `enforce-prd-feature-before-planner-helpers.ps1` | 60 / 2 / 62 | 57 / **2** / 59 |

**In both files the number of uncovered lines is unchanged** — 9 and 2 before, 9 and 2 after. What fell is the denominator: the gate lost four instrumented lines and the helpers three, and every one of those lines was **covered**. Deleting covered code lowers a covered-over-total ratio while leaving the count of untested lines exactly where it was.

The deletions are the ones the plan requires. DD-9 removes `Test-PrdFeatureSessionRootTarget` and the deny that used it, on the grounds that anchoring the checkpoint read by construction makes the guard unreachable and therefore uncovered code; DD-7 removes the signal-value read the renamed selector no longer needs. Both were exercised by tests, so both counted as covered before they were removed.

Stated plainly: no line that was tested before this change set is untested now, and no untested line was added. Changed-line coverage is 100% for both files, so every line the change set added to them is covered. The no-regression condition as written is nonetheless not met for these two, and it is recorded as not met rather than argued into compliance.

## What would raise the ratio, and why it was not done here

The nine uncovered lines in the gate are `:173-183`, the body of `Get-PrdFeatureCheckpointFolder`, which every suite mocks, and `:473-477`, the entrypoint tail that a dot-sourced test cannot reach. Six of the nine are reachable: three committed fixture checkpoints already exist that would drive the reader's valid-JSON-with-key, invalid-JSON, and valid-JSON-without-key branches, which would take the file to roughly 96.8% and clear the baseline comfortably. The two uncovered helper lines, `:132` and `:144`, sit inside `ConvertTo-PrdFeatureFolderToken` and are likewise reachable by direct calls.

Those rows were not added, because every candidate home is closed by an acceptance condition already satisfied and checked off:

- `enforce-prd-feature-before-planner.Tests.ps1` and `.FolderResolution.Tests.ps1` are pinned by `[P9-T6]` and `[P9-T7]` to an exact changed-line and touched-region set; adding rows would retroactively break a condition already recorded as met.
- `enforce-prd-feature-before-planner.IdentityResolution.Tests.ps1` states, and `[P10-T7]` verifies, that it derives no path from the script file location. Reaching a committed fixture requires exactly that, so adding these rows there would break issue #672's test-hygiene criterion, which `[P11-T9]` checks off.
- A new suite is a new independent outcome the plan does not describe.

This is therefore escalated rather than fixed: the shortfall is a 0.40-point and a 0.16-point ratio movement with no increase in untested lines, and closing it needs one plan revision authorising a small addition to the coverage of `Get-PrdFeatureCheckpointFolder` and `ConvertTo-PrdFeatureFolderToken`.

## The one uncovered added line

`.claude/lib/worktree-resolution/WorktreeItemResolution.psm1:206` is the only added line in the change set that is instrumented and uncovered:

```
        Get-WorktreeResolutionWorktreeRoot -SessionRoot $ascended -Branch $Branch
```

It is the branch-filtered arm of the enumerator call inside `Get-WorktreeItemLiveRoot`. Every suite that needs a branch-filtered result mocks `Get-WorktreeItemLiveRoot` itself, and the one row that exercises the function directly, `keeps only registered worktrees that still carry a root marker`, calls it without a branch and so takes the unfiltered arm. The module still reaches 99.06%.

Output Summary: Twenty-one values recorded. Every post percentage is at or above 85%, the lowest being 90.32%, and every changed-line figure is at or above 85%, six at 100% and one at 99.06%. The no-regression condition is met for four of the six hooks and **not met** for the two prd-feature files, which fell 0.40 and 0.16 points. In both, the uncovered-line count is unchanged and the fall is entirely the effect of deleting covered code that the plan requires deleting. The shortfall is recorded as not met and escalated, with the reachable uncovered lines and the reason no row was added to reach them both named.
