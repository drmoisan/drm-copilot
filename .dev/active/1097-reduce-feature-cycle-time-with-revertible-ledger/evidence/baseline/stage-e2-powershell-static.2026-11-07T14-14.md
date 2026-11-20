# Stage E2 PowerShell Static Baseline

Timestamp: 2026-11-07T14-14
Command: sh-launched PowerShell 7 importing scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCFormat in check mode (no-op writer) over tests/scripts/claude-runtime/parallel-gate-wording.Tests.ps1 and tests/scripts/dev-tools/ProcessReductionLedger.Index.Tests.ps1, then Invoke-ScriptAnalyzer -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 on each file (launcher stored under SCRATCH)
EXIT_CODE: 0
Output Summary:
  Format: parallel-gate-wording.Tests.ps1 already formatted (Formatted: 0); ProcessReductionLedger.Index.Tests.ps1 already formatted (Formatted: 0); targets not formatted 0.
  Analyzer: parallel-gate-wording.Tests.ps1 0 findings; ProcessReductionLedger.Index.Tests.ps1 0 findings; total 0.
