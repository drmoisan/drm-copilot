# Change-Budget Route — Batch Split

Timestamp: 2026-09-17T10-45

Command: `Get-ChildItem -Path .claude/state -Filter 'powershell-batch-budget.*.json' -ErrorAction SilentlyContinue | ForEach-Object { Write-Output ('PRE-RESET ' + $_.FullName + ' ' + (Get-Content -Raw $_.FullName)); Remove-Item -LiteralPath $_.FullName -Force }` followed by `Get-ChildItem -Path .claude/state -Filter 'powershell-batch-budget.*.json' -ErrorAction SilentlyContinue | Measure-Object | Select-Object -ExpandProperty Count`, run from the worktree root through the scratchpad wrapper `sh runps.sh clearstate-filtered.ps1`.

EXIT_CODE: 0

## Route

The route taken is the **batch split**. No override was requested or assumed. Neither `CLAUDE_POWERSHELL_BUDGET_PROD` nor `CLAUDE_POWERSHELL_BUDGET_TEST` was set. The skill `powershell-change-budget-router` was not invoked.

`.claude/rules/powershell.md` lines 39-40 cap direct mode at 2 production PowerShell files and any batch at 3 production and 3 test files. This change set is 4 production PowerShell files plus 2 `.psd1` settings files, which `.claude/hooks/enforce-powershell-batch-budget.ps1` also classifies as production, so the work is split into six batches.

| batch | phase | opened by | production files in the batch | production count |
| --- | --- | --- | --- | --- |
| A1 | Phase 0 | `[P0-T10]` (this task) | `.claude/hooks/enforce-prd-feature-before-planner.ps1`, `.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1` | 2 |
| A2 | Phase 1 | no reset needed (same two files as A1; a repeat edit consumes no new slot, per the hook's line 289 early return) | the same two files | 2 |
| B | Phase 2 | `[P2-T1]` | the two bundled mirrors under `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/` | 2 |
| C | Phase 2 | `[P2-T4]` | `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`, `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1` (plus `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`, which is not a PowerShell file and consumes no slot) | 2 |
| D | Phase 4 | `[P4-T1]` | the repository hook and its sibling | 2 |
| E | Phase 5 | `[P5-T1]` | the two bundled mirrors | 2 |

Every PowerShell batch carries 2 production files, at or under the direct-mode limit of 2 and well under the per-batch cap of 3; batch C carries 2 PowerShell production files, at or under 3. Test files are counted separately against a cap of 3 and never exceed 3 per batch; the three test paths in scope are `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.TargetResolution.Tests.ps1` (new), `...enforce-prd-feature-before-planner.Tests.ps1` (amended), and `...enforce-prd-feature-before-planner.FolderResolution.Tests.ps1` (amended).

## Reset mechanism

The session's batch-budget counter is session-scoped, not phase-scoped. `.claude/hooks/enforce-powershell-batch-budget.ps1` composes its state file at line 366 as `<root>/.claude/state/powershell-batch-budget.<resolved-session-id>.json`, rehydrates the persisted production and test path lists on every subsequent write, and denies at line 297 once the production list has reached `prodCap`, which the entry point sets to 3 at line 426. The reset the hook itself states in its deny reason at line 296 is to delete that state file. Each batch boundary task therefore removes the state file before that batch's first write. The file name is enumerated by filter rather than composed, because the resolved session id is not knowable at planning time (the hook resolves it at lines 139-173 from `CLAUDE_SESSION_ID`, then `.claude/state/current-session-id`, then a worktree-derived identifier).

## State directory observation at Phase 0

- Resolved state-directory path: `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-accbbbab931643b40/.claude/state`
- Enumerated `powershell-batch-budget.*.json` files: **none**. The directory did not exist in this worktree; `[P0-T7]` ran earlier in this phase, its unfiltered removal emitted no `PRE-RESET` line, and its verification count was 0. The `none` observation here is the expected consequence of `[P0-T7]` having run, as both tasks state.
- Because the enumeration was empty, the removal branch had nothing to remove; the verification enumeration was nevertheless run and reported a count of `0`.
- Halt branch not triggered: no state file was enumerated that could not be removed.

Batch A1 is therefore opened with an empty budget, and `[P0-T12]`'s production write cannot be denied by slots consumed before this plan's execution began.
