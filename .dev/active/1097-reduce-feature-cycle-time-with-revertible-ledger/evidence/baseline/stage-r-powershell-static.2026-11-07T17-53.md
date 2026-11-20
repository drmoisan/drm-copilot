# Stage R PowerShell Static Baseline

Timestamp: 2026-11-07T17-52
Command: sh-launched PowerShell 7 importing scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCFormat in check mode (no-op writer, no file written) over scripts/dev-tools/ProcessReductionLedger.psm1, tests/scripts/dev-tools/ProcessReductionLedger.Tests.ps1, tests/scripts/dev-tools/ProcessReductionLedger.Index.Tests.ps1, and tests/scripts/dev-tools/ProcessReductionLedger.Replay.Tests.ps1; then Invoke-ScriptAnalyzer -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 on each file (launcher stored under SCRATCH)
EXIT_CODE: 0
Output Summary:
  Format: all four files already formatted (Formatted: 0 each); files needing format: 0.
  Analyzer: ProcessReductionLedger.psm1 0 findings; ProcessReductionLedger.Tests.ps1 0; ProcessReductionLedger.Index.Tests.ps1 0; ProcessReductionLedger.Replay.Tests.ps1 0; analyzer finding count 0.
  The first Invoke-ScriptAnalyzer call on the module raised the known PSScriptAnalyzer 1.25 first-file NullReferenceException and was retried once in the same run; the retry returned 0 findings.
