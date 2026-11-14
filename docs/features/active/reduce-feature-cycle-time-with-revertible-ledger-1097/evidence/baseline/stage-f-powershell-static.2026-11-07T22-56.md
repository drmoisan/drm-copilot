# Stage F PowerShell Static Baseline

Timestamp: 2026-11-07T22-56
Command: sh-launched PowerShell 7 importing scripts/powershell/PoshQC/PoshQC.psd1: Invoke-PoshQCFormat with a no-op -WriteFile (check mode) and a direct Invoke-ScriptAnalyzer run with scripts/powershell/PoshQC/settings/pssa.settings.psd1 over tests/scripts/claude-runtime/planning-contract-wording.Tests.ps1 (launcher stored under SCRATCH)
EXIT_CODE: 0
Output Summary:
  PoshQC format: 1 Already formatted line, 0 Formatted lines (0 files to format).
  PSScriptAnalyzer (direct run, not MCP output): 0 findings.
  No production PowerShell file is in scope for this stage.
