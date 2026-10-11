# Final QC: PSScriptAnalyzer ([P12-T2])

Timestamp: 2026-10-09T22-00
Command: (PowerShell-tool) @(Invoke-ScriptAnalyzer -Path tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1 -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1).Count
EXIT_CODE: 1
Output Summary: PowerShell tool unavailable. The executor's tool set does not include the PowerShell tool, and the delegation forbids routing pwsh, sh, or bash wrapper scripts through the Bash tool, so the command was not executed (EXIT_CODE 1 records the non-execution; no process ran). No finding count was produced.
Error: PowerShell tool unavailable
Branch: A7-CI
Outcome: LOCAL-PESTER-UNAVAILABLE

Dependent criterion AC-38 stays unchecked and is listed as pending-CI. The CI job `poshqc / PowerShell QC` on the PR head is authoritative; the orchestrator checks it off at S9.

## Supplementary: PoshQC MCP analyze run (scan_folders ["tests/scripts/workflows"])

The MCP result payload carries only an `ok` flag and a summary string composed by the server; it does not carry analyzer findings or a count, so it is not a substitute for the A7-LOCAL acceptance literal `0`.

Command: mcp__drm-copilot__run_poshqc_analyze (workspace_root <worktree>, scan_folders ["tests/scripts/workflows"])
Result (verbatim):

```
{"ok":true,"tool":"run_poshqc_analyze","workspace_root":"<worktree>","summary":"Ran bundled PoshQC analyze against '<worktree>' with 1 selected scan folder(s)."}
```
Redaction: absolute worktree path replaced with <worktree> on 2026-10-09T22-23 (policy-audit PA-4); no other content changed.
