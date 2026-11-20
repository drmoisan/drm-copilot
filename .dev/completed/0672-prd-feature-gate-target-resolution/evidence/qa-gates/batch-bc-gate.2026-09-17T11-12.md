# Batch B/C Gate — Post-Extraction, Pre-Behaviour-Change Coverage Reading

Timestamp: 2026-09-17T11-12

Command: `Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root (Get-Location).Path -SettingsPath ./scripts/powershell/PoshQC/settings/pester.runsettings.psd1`

Run from the worktree root through the scratchpad wrapper `sh runps.sh runtest.ps1` (`cd <worktree root>` then `pwsh -NoProfile -File <script>`), this host's equivalent of the PowerShell tool. This is the single route for this task, named unconditionally rather than as a fallback.

EXIT_CODE: 2 (`Run.Exit = $true`; the process exit code is the failed-test count)

Output Summary:

- JUnit `testsuites` attributes from `artifacts/pester/pester-junit.xml`: `tests` = 4734, `failures` = 2, `errors` = 0; passed = 4734 - 2 - 0 = 4732.
- Per-file line coverage, each keyed on the full directory path of the enclosing `package` element (`C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-accbbbab931643b40/.claude/hooks`) rather than on the bare file name, and each computed from child `line` elements with `ci` greater than zero over all child `line` elements:
  - `.claude/hooks/enforce-prd-feature-before-planner.ps1`: **85.25 percent** (52 / 61); uncovered lines 138, 139, 142, 145, 146, 148, 258, 260, 262
  - `.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1`: **100.00 percent** (44 / 44); no uncovered lines
- Overall aggregate over every `sourcefile` node: 95.65 percent (9334 / 9758) across **105** nodes, 0 of them using the `counter[@type='LINE']` fallback form. The node count rose from 104 to 105, which is the direct confirmation that `[P2-T6]`'s `CodeCoverage.Path` entry put the new sibling into the denominator on this route.

Both per-file percentages are numeric and neither is a placeholder. This is the post-extraction, pre-behaviour-change reading that `[P6-T5]` compares against.

## DEVIATION — the `failures = 0` clause is not met, for the pre-existing cause

`errors` is 0. `failures` is 2, and the two failing nodes are the same pre-existing pair recorded before any modification in `evidence/baseline/baseline-poshqc-test.2026-09-17T10-34.md`:

1. `enforce-pr-author-skill.ps1.allowed commands.allows gh pr create --body-file artifacts/pr_body_12.md when context exists`
2. `Every registered Codex PreToolUse handler accepts every tool name its matcher admits.allows every registered handler for every tool name its own matcher admits`

Neither lies in this feature's file set, and no new failure was introduced by batches B or C. The plan task `[P2-T10]` is left unchecked with this deviation as its reason; every other clause of its acceptance is satisfied and recorded above.
