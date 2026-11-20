# Final QC — PoshQC Analyze Stage

Timestamp: 2026-09-17T08:35:23-04:00
Command: mcp__drm-copilot__run_poshqc_analyze workspace_root=C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a3a183dccbc73c30c scan_folders=[".claude/lib", "tests/scripts/claude-lib", "scripts/powershell/PoshQC/settings", "extensions/drm-copilot/resources/claude-customizations/.claude/lib", "extensions/drm-copilot/resources/powershell/PoshQC/settings"] ; Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; try { Invoke-PoshQCAnalyze -Root (Get-Location).Path -ScanFolders @('.claude/lib','tests/scripts/claude-lib','scripts/powershell/PoshQC/settings','extensions/drm-copilot/resources/claude-customizations/.claude/lib','extensions/drm-copilot/resources/powershell/PoshQC/settings') } catch { $_ | Out-String }
EXIT_CODE: 0
Output Summary: Loop iteration 2 (governing). MCP ok=true with the literal "Ran bundled PoshQC analyze against ". Self-hosted stdout contains "PSScriptAnalyzer passed: no findings under ". Final finding set: none, which is a subset of the [P0-T5] Baseline finding set (none) and contains no finding on any of the ten Scope Boundary paths. The stage modified no file (porcelain listing unchanged from the format stage's after-listing).

## Iteration 2 (governing)

MCP result object (verbatim):

```json
{"ok":true,"tool":"run_poshqc_analyze","workspace_root":"C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a3a183dccbc73c30c","summary":"Ran bundled PoshQC analyze against 'C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a3a183dccbc73c30c' with 5 selected scan folder(s)."}
```

Self-hosted stdout (verbatim):

```text
PSScriptAnalyzer passed: no findings under C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a3a183dccbc73c30c
```

Final finding set: none

Comparison with [P0-T5]: Baseline finding set = none; final finding set = none; subset holds; no finding
names a Scope Boundary path.

## Iteration 1 (failed; loop restarted at [P4-T2])

Timestamp: 2026-09-17T08:32:24-04:00. MCP result object (verbatim):

```json
{"ok":false,"tool":"run_poshqc_analyze","workspace_root":"C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a3a183dccbc73c30c","summary":"Command exited with code 1.","stderr_excerpt":"\u001b[31;1mException: \u001b[31;1mPSScriptAnalyzer reported 26 issue(s).\u001b[0m"}
```

Self-hosted finding set (26, all on Scope Boundary paths introduced by this feature):

- PSUseOutputTypeCorrectly (Information) — WorktreeResolution.psm1 lines 111, 359, 399 (reported twice each, once per scanned copy: repo-side and bundle mirror): unary-comma array returns inferred as System.Object[] against `[OutputType([string[]])]`.
- PSUseShouldProcessForStateChangingFunctions (Warning) — WorktreeResolution.Tests.ps1 lines 27 (New-TestTopology), 51 (Set-TopologyMock); WorktreeTargetResolution.Tests.ps1 lines 28, 58 (same helpers).
- PSUseDeclaredVarsMoreThanAssignments (Warning) — `$Topology` assigned but not visibly used: WorktreeResolution.Tests.ps1 lines 192, 200, 226, 248, 259, 270, 282, 355, 367, 418; WorktreeTargetResolution.Tests.ps1 lines 138, 239, 275, 327, 342, 369.

Repairs applied (window C slots: 1 production, 2 test):

- WorktreeResolution.psm1: `[OutputType([string[]], [object[]])]` on `Get-WorktreeResolutionDirectoryChildName` and `Get-WorktreeResolutionWorktreeRoot` (follows the `[OutputType([object[]])]` precedent in DiscoveryValidation.psm1); line count unchanged at 480. Bundle mirror re-synchronised with Copy-Item.
- Both behavioural suites: helpers renamed to `Get-TestTopology` and `Register-TopologyMock`; the topology is passed as `-Topology $Topology` and stored in `$script:ActiveTopology`, which the mock bodies read.
- Post-repair: the three worktree-resolution suites pass 106 of 106; the loop restarted at [P4-T2].
