# Final QC: Pester workflow suite ([P12-T3])

Timestamp: 2026-10-09T22-00
Command: (PowerShell-tool) $r = Invoke-Pester -Path tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1 -Output Detailed -PassThru; "Passed=$($r.PassedCount) Failed=$($r.FailedCount)"
EXIT_CODE: 1
Output Summary: PowerShell tool unavailable. The executor's tool set does not include the PowerShell tool, and the delegation forbids routing pwsh, sh, or bash wrapper scripts through the Bash tool, so the command was not executed (EXIT_CODE 1 records the non-execution; no process ran). No `Passed=` line was produced.
Error: PowerShell tool unavailable
Branch: A7-CI
Outcome: LOCAL-PESTER-UNAVAILABLE

Dependent criteria AC-30 and AC-31 stay unchecked and are listed as pending-CI. The CI job `poshqc / PowerShell QC` on the PR head is authoritative; the orchestrator checks them off at S9.

## Supplementary: PoshQC MCP test run (scan_folders ["tests/scripts/workflows"])

The MCP result payload carries only an `ok` flag and a summary string composed by the server; it does not carry Pester pass or fail counts, so it is not a substitute for the A7-LOCAL acceptance literal `Passed=11 Failed=0`.

Command: mcp__drm-copilot__run_poshqc_test (workspace_root C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a6e4f01baf096421b, scan_folders ["tests/scripts/workflows"])
Result (verbatim):

```
{"ok":true,"tool":"run_poshqc_test","workspace_root":"C:\\Users\\DanMoisan\\repos\\drm-copilot\\.claude\\worktrees\\agent-a6e4f01baf096421b","summary":"Ran bundled PoshQC test against 'C:\\Users\\DanMoisan\\repos\\drm-copilot\\.claude\\worktrees\\agent-a6e4f01baf096421b' with 1 selected scan folder(s)."}
```
