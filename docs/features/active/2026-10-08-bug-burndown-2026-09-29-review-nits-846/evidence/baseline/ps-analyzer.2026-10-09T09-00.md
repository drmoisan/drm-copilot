# Baseline: PSScriptAnalyzer on PublishMcpNpmWorkflow.Tests.ps1 ([P0-T25], A7 branch rule)

Timestamp: 2026-10-09T21-04
Command: @(Invoke-ScriptAnalyzer -Path tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1 -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1).Count (PowerShell tool)
EXIT_CODE: not-run (no process was started; the PowerShell tool is not in this executor's tool set, so no exit code exists to record)
Output Summary: PowerShell tool unavailable. Branch A7-CI selected. No local finding count was observed. The CI job `poshqc / PowerShell QC` on the PR head is authoritative; AC-38 stays unchecked and is listed as pending-CI.
Error: PowerShell tool unavailable
Outcome: LOCAL-PESTER-UNAVAILABLE

## Supplementary block (MCP, binding adjustment 2)

Command: mcp__drm-copilot__run_poshqc_analyze with workspace_root set to this worktree and scan_folders ["tests/scripts/workflows"]
EXIT_CODE: not reported by the tool (returned "ok": true)
Output Summary: returned status recorded verbatim below. The result carries no finding count, so no count is recorded here.

```
{"ok":true,"tool":"run_poshqc_analyze","workspace_root":"C:\\Users\\DanMoisan\\repos\\drm-copilot\\.claude\\worktrees\\agent-a6e4f01baf096421b","summary":"Ran bundled PoshQC analyze against 'C:\\Users\\DanMoisan\\repos\\drm-copilot\\.claude\\worktrees\\agent-a6e4f01baf096421b' with 1 selected scan folder(s)."}
```
