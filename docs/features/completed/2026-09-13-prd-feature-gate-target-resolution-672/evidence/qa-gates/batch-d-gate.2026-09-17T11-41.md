# Batch D Gate — Target-Resolution Behaviour Change

Timestamp: 2026-09-17T11-41

Command:
1. `mcp__drm-copilot__run_poshqc_analyze` with `workspace_root: C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-accbbbab931643b40` (route compliance; returned `{"ok":true,...}`)
2. `mcp__drm-copilot__run_poshqc_test` with the same `workspace_root` (route compliance; returned `ok:false, "Command exited with code 2."`)
3. `Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCAnalyze -Root (Get-Location).Path -SettingsPath ./scripts/powershell/PoshQC/settings/pssa.settings.psd1 6>&1`
4. `Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root (Get-Location).Path -SettingsPath ./scripts/powershell/PoshQC/settings/pester.runsettings.psd1`
5. `Import-Module PSScriptAnalyzer -ErrorAction Stop; @(Invoke-ScriptAnalyzer -Path '<file>' -Settings 'scripts/powershell/PoshQC/settings/pssa.settings.psd1').Count`, once for each of the seven paths below

Commands 3 through 5 ran from the worktree root through the scratchpad wrapper, this host's equivalent of the PowerShell tool.

EXIT_CODE: 0 for the direct analyzer run; 2 for the direct test run.

Output Summary:

- Analyzer branch observable: `PSScriptAnalyzer passed: no findings under C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-accbbbab931643b40`, quoted from the captured console output of the direct run with `6>&1`. Whole-tree finding count: 0.
- Per-file `Invoke-ScriptAnalyzer` counts, all **0**: `.claude/hooks/enforce-prd-feature-before-planner.ps1`; `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-prd-feature-before-planner.ps1`; `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1`; `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.FolderResolution.Tests.ps1`; `.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1`; `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1`; `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.TargetResolution.Tests.ps1`.
- An earlier run of the same commands, before the two remediations recorded at the end of this artifact, reported 12 findings in the new suite. Both remediations were applied and the direct analyzer was re-run to the clean state quoted above.
- JUnit `testsuites` attributes from `artifacts/pester/pester-junit.xml`: `tests` = 4751, `failures` = 2, `errors` = 0; passed = 4751 - 2 - 0 = **4749**.

## The eighteen fixed `It` identifiers, derived per the preamble's per-test rule

Each row gives the identifier, its observed matched-node count among `$junit.SelectNodes('//testcase')` matched by `name` containment, and its derived result (no matched node carries a child `failure` element).

| identifier | expected nodes | matched | result |
| --- | --- | --- | --- |
| `observes a test-scope mock across the dot-source boundary` | 1 | 1 | PASSED |
| `allows when the target root holds the required document` | 1 | 1 | PASSED |
| `denies with the missing-document reason when the document is absent under the target root` | 1 | 1 | PASSED |
| `denies with the ambiguity code when the target cannot be resolved` | 1 | 1 | PASSED |
| `emits an ambiguity code distinct from the missing-document and marker reasons` | 1 | 1 | PASSED |
| `denies rather than validating against a sibling session checkpoint` | 1 | 1 | PASSED |
| `denies rather than selecting the earliest candidate on an unresolved tie` | 1 | 1 | PASSED |
| `denies with the ambiguity reason when the folder is absent from the target root` | 1 | 1 | PASSED |
| `runs no existence probe on the ambiguity branch` | 1 | 1 | PASSED |
| `probes once on a full-bug allow row` | 1 | 1 | PASSED |
| `probes twice on a full-feature allow row` | 1 | 1 | PASSED |
| `allows an absolute path to the target feature folder` | 2 | 2 | PASSED |
| `allows the session-root fallback when the derived target is the session root` | 1 | 1 | PASSED |
| `prefers the derived target when it occurs later in the prompt` | 1 | 1 | PASSED |
| `resolves the required document set for each work mode` | 4 | 4 | PASSED |
| `allows when the modelled cwd is the item worktree` | 1 | 1 | PASSED |
| `denies when the checkpoint is absent and the tie cannot be resolved against the derived target` | 1 | 1 | PASSED |
| `denies when the checkpoint names a folder that is not a candidate` | 1 | 1 | PASSED |

**Total matched nodes: 22**, exactly the required sixteen identifiers at one node each plus four for `resolves the required document set for each work mode` and two for `allows an absolute path to the target feature folder`. No identifier's match count differs from its fixed expected count in either direction.

Full `name` attribute of one matched node, recorded verbatim so the report's own spelling is documented:

`enforce-prd-feature-before-planner.ps1 target resolution.cross-file mock resolution smoke.observes a test-scope mock across the dot-source boundary`

The eight Phase 3 fail-before rows are among the identifiers above and all now pass; the other ten pass alongside them. None of this was read from an MCP result or a console summary, neither of which carries a per-test name.

## DEVIATION — the `failures = 0` clause is not met, for the pre-existing cause

`errors` is 0. `failures` is 2, and the two failing nodes are the same pre-existing pair recorded before any modification in `evidence/baseline/baseline-poshqc-test.2026-09-17T10-34.md`:

1. `enforce-pr-author-skill.ps1.allowed commands.allows gh pr create --body-file artifacts/pr_body_12.md when context exists`
2. `Every registered Codex PreToolUse handler accepts every tool name its matcher admits.allows every registered handler for every tool name its own matcher admits`

Neither lies in this feature's file set, and no new failure was introduced by batch D. `tests` rose from 4734 to 4751, which is the seventeen new nodes this phase adds. The plan task `[P4-T21]` is left unchecked with this deviation as its reason; every other clause of its acceptance is satisfied and recorded above.

## Remediations applied within this task

The first direct analyzer run after the behaviour change reported 12 findings, all in `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.TargetResolution.Tests.ps1`:

- Ten `PSAlignAssignmentStatement` findings at lines 46-57, in the two `-ForEach` row hashtables. Fixed by aligning the assignments in place, rather than by running the write-mode formatter, so no unrelated tracked file was rewritten.
- Two `PSUseShouldProcessForStateChangingFunctions` findings, on the pure in-memory test factories `New-PlannerPayload` (line 121) and `New-ModelledTarget` (line 130). Fixed with `[Diagnostics.CodeAnalysis.SuppressMessageAttribute(...)]` carrying a justification, following the precedent set by `New-WorktreeResolutionTargetResult` at `.claude/lib/worktree-resolution/WorktreeTargetResolution.psm1` line 90. Neither function changes system state.
