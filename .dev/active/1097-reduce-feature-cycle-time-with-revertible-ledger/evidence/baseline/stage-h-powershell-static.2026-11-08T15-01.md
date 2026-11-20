# Stage H PowerShell Static Baseline

Timestamp: 2026-11-08T15-01
Command: sh-launched PowerShell 7 running Invoke-ScriptAnalyzer -Path tests/scripts/claude-runtime/planning-contract-wording.Tests.ps1 -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1, then Invoke-Formatter on the file text with the same settings (script stored under SCRATCH); no file modified
EXIT_CODE: 0
Output Summary:
  PSSA findings: 0.
  Format observation: Invoke-Formatter output is identical to the file text (no change would be made).
  File length: 268 lines.
