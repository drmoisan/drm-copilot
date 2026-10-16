# Analyzer, HostBootstrap.psm1 (P2-T2)

Timestamp: 2026-10-16T02-54

Command: pwsh -NoProfile -NonInteractive -Command 'Invoke-ScriptAnalyzer -Path scripts/dev-tools/HostBootstrap.psm1 -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 -Severity Error,Warning,Information | Measure-Object | Select-Object -ExpandProperty Count'

EXIT_CODE: 0

Output Summary: Printed integer 0 (zero findings).
