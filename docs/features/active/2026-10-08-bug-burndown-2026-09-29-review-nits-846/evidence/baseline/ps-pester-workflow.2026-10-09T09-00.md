# Baseline: Pester run of PublishMcpNpmWorkflow.Tests.ps1 ([P0-T23], A7 branch rule)

Timestamp: 2026-10-09T21-05
Command: $r = Invoke-Pester -Path tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1 -Output Detailed -PassThru; "Passed=$($r.PassedCount) Failed=$($r.FailedCount)" (PowerShell tool)
EXIT_CODE: not-run (no process was started; the PowerShell tool is not in this executor's tool set, so no exit code exists to record)
Output Summary: PowerShell tool unavailable. Branch A7-CI selected (also recorded in [P0-T5]). No local Pester pass or fail count was observed. The CI job `poshqc / PowerShell QC` on the PR head is authoritative for this file; AC-30, AC-31, and AC-38 stay unchecked and are listed as pending-CI.
Error: PowerShell tool unavailable
Outcome: LOCAL-PESTER-UNAVAILABLE

## Supplementary block (MCP, binding adjustment 2)

Command: mcp__drm-copilot__run_poshqc_test with workspace_root set to this worktree and scan_folders ["tests/scripts/workflows"]
EXIT_CODE: not reported by the tool (returned "ok": true)
Output Summary: returned status recorded verbatim below. The result carries no pass, fail, or coverage counts, so none are recorded here. A follow-up `git status --porcelain --untracked-files=all` showed no tracked file modified by the run.

```
{"ok":true,"tool":"run_poshqc_test","workspace_root":"C:\\Users\\DanMoisan\\repos\\drm-copilot\\.claude\\worktrees\\agent-a6e4f01baf096421b","summary":"Ran bundled PoshQC test against 'C:\\Users\\DanMoisan\\repos\\drm-copilot\\.claude\\worktrees\\agent-a6e4f01baf096421b' with 1 selected scan folder(s)."}
```
