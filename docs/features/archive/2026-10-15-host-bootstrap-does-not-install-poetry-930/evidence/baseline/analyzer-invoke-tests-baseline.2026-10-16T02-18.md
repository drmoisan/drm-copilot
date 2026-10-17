# Baseline analyzer count, HostBootstrap.Invoke.Tests.ps1 (P0-T9)

Timestamp: 2026-10-16T02-18

Command: pwsh -NoProfile -NonInteractive -Command 'Invoke-ScriptAnalyzer -Path tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1 -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 -Severity Error,Warning,Information | Measure-Object | Select-Object -ExpandProperty Count'

EXIT_CODE: 0

Output Summary: Printed integer 0. Baseline finding count for the Invoke test file is 0.
