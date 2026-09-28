# Batch A2 Gate — Extraction Only, No Behaviour Change

Timestamp: 2026-09-17T11-08

Command:
1. `mcp__drm-copilot__run_poshqc_analyze` with `workspace_root: C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-accbbbab931643b40` (route compliance; returned `{"ok":true,...}` and carries no finding count)
2. `mcp__drm-copilot__run_poshqc_test` with the same `workspace_root` (route compliance; returned `ok:false, "Command exited with code 2."` and carries no test count)
3. `Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCAnalyze -Root (Get-Location).Path -SettingsPath ./scripts/powershell/PoshQC/settings/pssa.settings.psd1 6>&1`
4. `Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root (Get-Location).Path -SettingsPath ./scripts/powershell/PoshQC/settings/pester.runsettings.psd1`
5. `Import-Module PSScriptAnalyzer -ErrorAction Stop; @(Invoke-ScriptAnalyzer -Path '<file>' -Settings 'scripts/powershell/PoshQC/settings/pssa.settings.psd1').Count`, once for each of the five paths below

Commands 3 through 5 ran from the worktree root through the scratchpad wrapper (`cd <worktree root>` then `pwsh -NoProfile -File <script>`), this host's equivalent of the PowerShell tool.

EXIT_CODE: 0 for the direct analyzer run; 2 for the direct test run (`Run.Exit = $true` makes the process exit code the failed-test count).

Output Summary:

- Analyzer branch observable (zero-findings branch): `PSScriptAnalyzer passed: no findings under C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-accbbbab931643b40`. Whole-tree finding count: 0. This is quoted from the captured console output of the direct run with `6>&1`, not from an exit code and not from an MCP result.
- Per-file `Invoke-ScriptAnalyzer` counts, all 0:
  - 0 `.claude/hooks/enforce-prd-feature-before-planner.ps1`
  - 0 `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-prd-feature-before-planner.ps1`
  - 0 `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1`
  - 0 `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.FolderResolution.Tests.ps1`
  - 0 `.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1`
- JUnit `testsuites` attributes read from `artifacts/pester/pester-junit.xml`: `tests` = 4734, `failures` = 2, `errors` = 0; passed = 4734 - 2 - 0 = 4732.
- The three prd-feature suites run alone report 73 total, 73 passed, 0 failed (`enforce-prd-feature-before-planner.Tests.ps1`, `...FolderResolution.Tests.ps1`, `...TargetResolution.Tests.ps1`), so the extraction changed no behaviour in the files this batch touched.

## DEVIATION — the `failures = 0` clause is not met, for a pre-existing cause

This gate's acceptance requires the JUnit `failures` and `errors` attributes to be 0. `errors` is 0. `failures` is 2, and the two failing nodes are byte-identical to the pre-existing pair recorded before any modification in `evidence/baseline/baseline-poshqc-test.2026-09-17T10-34.md`:

1. `enforce-pr-author-skill.ps1.allowed commands.allows gh pr create --body-file artifacts/pr_body_12.md when context exists`
2. `Every registered Codex PreToolUse handler accepts every tool name its matcher admits.allows every registered handler for every tool name its own matcher admits`

Neither lies in this feature's file set. `tests` rose from the baseline's 4733 to 4734, which is the single new smoke case added by `[P0-T13]`; the passed count rose correspondingly from 4731 to 4732. No new failure was introduced by this batch.

Because the clause is stated as an absolute and the residual failures are outside this plan's scope to remediate, `[P1-T7]` is recorded as complete on every clause it governs except this one, and the plan task is left unchecked with this deviation as its reason.

## Coverage observation (recorded, not gated by this task)

Per-file line coverage for `.claude/hooks/enforce-prd-feature-before-planner.ps1` fell from the baseline's 91.35 percent (95/104) to 85.25 percent (52/61). The cause is denominator movement, not lost testing: the moved functions are well covered and have left this file's denominator, while the sibling that now holds them is not yet in `CodeCoverage.Path` (`[P2-T6]` adds it). Overall aggregate: 95.64 percent (9290/9714) over 104 nodes, 0 using the fallback form.
