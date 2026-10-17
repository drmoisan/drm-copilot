# R2 Token and Line-Count Baseline (issue #935, remediation cycle 2)

Timestamp: 2026-10-16T08-58
Task: [P0-T4]
Command: `grep -c -F -e '<token>' <path>` per row below (`grep -c -E -e` for rows marked ERE); `awk 'END { print NR }' <path>` for line counts. Run through the helper `SCRATCH/p0t4.sh`, which prints `<path> | <token> | <count>` per command.
EXIT_CODE: 0

Output Summary (path | token | observed | expected):

`tests/scripts/claude-hooks/EpicStateIsolation.HookReference.Helpers.ps1`
- ERE `^function ` | 16 | 16
- `[CmdletBinding()]` | 3 | 3
- `$isJoinPath = {` | 2 | 2
- `$isVariable = {` | 4 | 4
- `FindAll($isVariable` | 4 | 4
- `FindAll($isJoinPath` | 2 | 2
- `StartsWith('EpicStateIsolation.` | 2 | 2
- `EndsWith('.Tests.ps1'` | 2 | 2
- `'ErrorAction'` | 0 | 0
- `'WorkingDirectory'` | 1 | 1
- `An abbreviated parameter name` | 0 | 0
- `Test-EpicStateIsolationExcludedHookName` | 0 | 0
- `Get-EpicStateIsolationJoinPathCommand` | 0 | 0
- `Get-EpicStateIsolationVariableNode` | 0 | 0

`tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.HookReference.Tests.ps1`
- `$Source.Replace(` | 3 | 3
- `ConvertTo-HookReferenceFixtureAst -Source $Source` | 7 | 7
- `CR-R1` | 0 | 0
- `; Index = ` | 0 | 0

`tests/scripts/claude-hooks/enforce-prd-feature-before-planner.CallTarget.Tests.ps1`
- `Import-Module` | 2 | 2
- `F1's own constructor` | 1 | 1
- `imports no worktree-resolution module itself` | 0 | 0
- `It '` | 6 | 6
- ERE `(New|Get|ConvertTo|Find|Test)-WorktreeResolution` | 0 | 0

Static FIX-U2 evidence (`WorktreeResolution.psm1` on the seven created files):
- `enforce-epic-worktree-removal-gate.ManifestBranch.Tests.ps1` | 0 | 0
- `enforce-prd-feature-before-planner.CallTarget.Tests.ps1` | 1 | 1
- `enforce-orchestration-preimplementation-gate-command-exemption.Helpers.ps1` | 0 | 0
- `enforce-orchestration-preimplementation-gate-command-exemption.Selectors.Tests.ps1` | 0 | 0
- `EpicStateIsolation.HookReference.Helpers.ps1` | 0 | 0
- `enforce-gate-suites.EpicStateIsolation.HookReference.Tests.ps1` | 0 | 0
- `EnforcementHooksNoPythonInvocation.Allowlist.Helpers.ps1` | 0 | 0
- `.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1` `WorktreeResolution.psm1') -Force` | 1 | 1
- `.claude/hooks/enforce-prd-feature-before-planner.ps1` `WorktreeTargetResolution.psm1') -Force` | 1 | 1

Line counts (all at or below 500):
- `EpicStateIsolation.HookReference.Helpers.ps1`: 410
- `enforce-gate-suites.EpicStateIsolation.HookReference.Tests.ps1`: 429
- `enforce-prd-feature-before-planner.CallTarget.Tests.ps1`: 124

Acceptance: every count equals its stated value; every line count is at or below 500. PASS.
