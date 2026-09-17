# Final QC — Testing with Coverage

Timestamp: 2026-09-17T11-58

Command: `Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root (Get-Location).Path -SettingsPath ./scripts/powershell/PoshQC/settings/pester.runsettings.psd1`

Run from the worktree root through the scratchpad wrapper `sh runps.sh runtest.ps1`, this host's equivalent of the PowerShell tool. It runs with `CodeCoverage.Enabled = $true` (`scripts/powershell/PoshQC/settings/pester.runsettings.psd1` line 18), emits `artifacts/pester/powershell-coverage.xml` (line 22) and `artifacts/pester/pester-junit.xml` (line 15). This is the single route for this task, named unconditionally rather than as a fallback.

EXIT_CODE: 2 (`Run.Exit = $true`; the process exit code is the failed-test count)

Output Summary — every value derived from `artifacts/pester/pester-junit.xml` or `artifacts/pester/powershell-coverage.xml`, none from an MCP result or a console summary:

- Total tests (`testsuites/@tests`): **4758**
- Failures (`testsuites/@failures`): **2**
- Errors (`testsuites/@errors`): **0**
- Passed (tests - failures - errors): **4756**
- Overall line coverage, aggregated over every `sourcefile` node: **95.64 percent** (covered **9384** / total **9812**), 105 nodes aggregated, 0 using the `counter[@type='LINE']` fallback form
- Per-file line coverage, keyed on the parent `package` name `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-accbbbab931643b40/.claude/hooks`:
  - `.claude/hooks/enforce-prd-feature-before-planner.ps1`: **90.72 percent** (88 / 97); uncovered lines 143, 144, 147, 150, 151, 153, 420, 422, 424
  - `.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1`: **93.55 percent** (58 / 62); uncovered lines 121, 126, 138, 237

No branch-coverage value is recorded: Pester measures line and command coverage only, so a branch percentage is never printed and no branch gate applies.

The parent's uncovered lines are the same two regions that were uncovered at baseline, renumbered by the extraction: the `Get-PrdFeatureCheckpointFolder` file-read body (lines 143-153, which reads a real checkpoint from disk) and the entrypoint tail below the dot-source guard (lines 420-424). The sibling's four uncovered lines are the empty-path early return and the two not-a-feature-folder early returns in `ConvertTo-PrdFeatureFolderToken`, plus the no-match return in `Select-PrdFeatureFolderByTarget`.

## Loop pass

This is pass 2 of the `[P6-T1]` through `[P6-T4]` loop. Pass 1 recorded the parent hook at 82.47 percent, below the 85 percent floor `spec.md` line 667 requires, because no case exercised `Get-PrdFeatureCallTarget` or the non-null arm of `Test-PrdFeatureSessionRootTarget`. Seven direct cases were added for both (commit `e5b7a210`), which changed a tracked file, so the loop restarted at `[P6-T1]`. Pass 2 completed format, lint, and test with no file change and no new failure.

## DEVIATION — the `failures = 0` clause is not met, for the pre-existing cause

`errors` is 0. `failures` is 2, and the two failing nodes are the same pre-existing pair recorded before any modification in `evidence/baseline/baseline-poshqc-test.2026-09-17T10-34.md`:

1. `enforce-pr-author-skill.ps1.allowed commands.allows gh pr create --body-file artifacts/pr_body_12.md when context exists`
2. `Every registered Codex PreToolUse handler accepts every tool name its matcher admits.allows every registered handler for every tool name its own matcher admits`

Neither lies in this feature's file set; the first is a case in a suite this feature does not touch, and the second denies from ambient epic-checkpoint state in this worktree rather than from any file this plan changed. `tests` rose from the baseline's 4733 to 4758, which is the 25 nodes this feature adds, and the passed count rose from 4731 to 4756. The plan task `[P6-T3]` is left unchecked with this deviation as its reason; every other clause of its acceptance is satisfied and recorded above.
