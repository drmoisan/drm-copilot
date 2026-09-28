# Baseline Pester State with Coverage

Timestamp: 2026-09-17T10-34

Command:
1. `mcp__drm-copilot__run_poshqc_test` with `workspace_root: C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-accbbbab931643b40` (route compliance only; it returned `ok:false, summary: "Command exited with code 2."` and carries no test count or coverage value)
2. `Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root (Get-Location).Path -SettingsPath ./scripts/powershell/PoshQC/settings/pester.runsettings.psd1`

Command 2 ran from the worktree root through the scratchpad wrapper `sh runps.sh runtest.ps1` (`cd <worktree root>` then `pwsh -NoProfile -File <script>`), which is this host's equivalent of the PowerShell tool. Every value below is derived from `artifacts/pester/pester-junit.xml` and `artifacts/pester/powershell-coverage.xml`, per the plan preamble; none is taken from an MCP result or a console summary.

EXIT_CODE: 2 (the direct run; `Run.Exit = $true` at `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` line 4 makes the process exit code the failed-test count)

Output Summary:
- Total tests (`testsuites/@tests`): 4733
- Failures (`testsuites/@failures`): 2
- Errors (`testsuites/@errors`): 0
- Passed (tests - failures - errors): 4731
- Overall line coverage, aggregated over every `sourcefile` node of `artifacts/pester/powershell-coverage.xml` by the preamble's rule: 95.65 percent (covered 9333 / total 9757), 104 nodes aggregated, 0 of them using the `counter[@type='LINE']` fallback form
- Per-file baseline line coverage for `.claude/hooks/enforce-prd-feature-before-planner.ps1`, keyed on the parent `package` name `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-accbbbab931643b40/.claude/hooks`: 91.35 percent (covered 95 / total 104), child-`line`-element form; uncovered lines 206, 207, 210, 213, 214, 216, 444, 446, 448

## Pre-existing baseline failure set (recorded, not introduced by this plan)

This run precedes every modification this plan makes, so both failures are pre-existing and neither is in this feature's file set:

1. `enforce-pr-author-skill.ps1.allowed commands.allows gh pr create --body-file artifacts/pr_body_12.md when context exists` in `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` — expected `allow`, got `deny`.
2. `Every registered Codex PreToolUse handler accepts every tool name its matcher admits.allows every registered handler for every tool name its own matcher admits` in `tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1` — `enforce-epic-wave-barrier.ps1` denies with `EPIC_WAVE_BARRIER_BLOCKED: '672' cannot mutate until every depends_on edge is merged or worktree_removed in the epic checkpoint`, which is ambient epic-checkpoint state in this worktree rather than a property of any file this plan touches.

Consequence recorded here so it is not discovered later: the gates `[P1-T7]`, `[P4-T21]`, and `[P6-T3]` require the JUnit `failures` and `errors` attributes to be 0. Errors are 0 at baseline and are expected to stay 0. Failures are 2 at baseline for the two causes above. Remediating either would be work outside this plan (one is a suite this feature does not touch, the other is orchestration state this session is directed not to modify), so each of those gates records the observed failure set and compares it against this baseline pair; a gate whose failure set is exactly this pair introduces no regression, and a gate whose failure set differs is a genuine failure of this change.
