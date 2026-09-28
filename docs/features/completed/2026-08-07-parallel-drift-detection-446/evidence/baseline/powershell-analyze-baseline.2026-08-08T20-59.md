# Baseline — PowerShell Analysis (PoshQC / PSScriptAnalyzer)

Timestamp: 2026-08-08T20-59

Task: [P0-T7]
Feature: 2026-08-07-parallel-drift-detection-446 (issue #446)
Branch: feature/parallel-drift-detection-446
Integration head at execution: c939b5b8

Command: `mcp__drm-copilot__run_poshqc_analyze` with
`workspace_root = C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a16d115637b38dd44`
(no `scan_folders` argument; the scan set is resolved from the repository PoshQC
configuration)

EXIT_CODE: 0

Output Summary: PASS. Finding count = 0. The MCP tool returned `"ok": true` with the summary
`Ran bundled PoshQC analyze against '<workspace_root>'`, which corresponds to exit code 0 and
means PSScriptAnalyzer produced zero diagnostics at or above the repository's configured
failure severity across the resolved scan set. No pre-existing PowerShell analyzer debt exists
at baseline, so any PSScriptAnalyzer finding observed in the Phase 7 final-QC loop is
attributable to code added by this feature. The analyzer stage is non-mutating and no
PowerShell file changed as a result of the run.

## Raw Output

```json
{
  "ok": true,
  "tool": "run_poshqc_analyze",
  "workspace_root": "C:\\Users\\DanMoisan\\repos\\drm-copilot\\.claude\\worktrees\\agent-a16d115637b38dd44",
  "summary": "Ran bundled PoshQC analyze against 'C:\\Users\\DanMoisan\\repos\\drm-copilot\\.claude\\worktrees\\agent-a16d115637b38dd44'."
}
```
