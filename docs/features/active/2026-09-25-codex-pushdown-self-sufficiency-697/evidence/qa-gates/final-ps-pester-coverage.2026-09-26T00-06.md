# Final PowerShell Tests with Coverage (Issue #697, Phase 14 iteration 3)

Timestamp: 2026-09-26T00-06
Command: pwsh -NoProfile -Command 'Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root (Get-Location).Path -SettingsPath scripts/powershell/PoshQC/settings/pester.runsettings.psd1'
EXIT_CODE: 0
Output Summary:
- `Tests Passed: 5081, Failed: 0, Skipped: 9, Inconclusive: 0, NotRun: 0` (total 5090 > baseline total 4963).
- Failing `It` blocks: none (the [P0-T19] baseline also had none).
- `artifacts/pester/powershell-coverage.xml` report-root LINE: covered 9793, missed 421 (95.88%).
- `sourcefile` entries present, attributed through their `package` (`<WORKSPACE_ROOT>/.codex/scripts`): `codex-routing-cli-common.ps1`, `Resolve-CodexTopology.ps1`, `Resolve-CodexDeployment.ps1` (AC-6.2 in effect).
