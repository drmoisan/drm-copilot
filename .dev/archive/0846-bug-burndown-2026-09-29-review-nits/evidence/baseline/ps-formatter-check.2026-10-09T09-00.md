# Baseline: Invoke-Formatter comparison of PublishMcpNpmWorkflow.Tests.ps1 ([P0-T24], A7 branch rule)

Timestamp: 2026-10-09T21-05
Command: $s = Get-Content -Raw -LiteralPath tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1; $f = Invoke-Formatter -ScriptDefinition $s -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1; $s -ceq $f (PowerShell tool)
EXIT_CODE: not-run (no process was started; the PowerShell tool is not in this executor's tool set, so no exit code exists to record)
Output Summary: PowerShell tool unavailable. Branch A7-CI selected. No `True` or `False` comparison result was observed locally. mcp__drm-copilot__run_poshqc_format was deliberately not run during the baseline because it rewrites files (binding adjustment 2). The CI job `poshqc / PowerShell QC` on the PR head is authoritative; AC-38 stays unchecked and is listed as pending-CI.
Error: PowerShell tool unavailable
Outcome: LOCAL-PESTER-UNAVAILABLE
