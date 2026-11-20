# Analyzer, HostBootstrap.Invoke.Tests.ps1 (P2-T3)

Timestamp: 2026-10-16T02-54

Command: pwsh -NoProfile -NonInteractive -Command 'Invoke-ScriptAnalyzer -Path tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1 -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 -Severity Error,Warning,Information | Measure-Object | Select-Object -ExpandProperty Count'

EXIT_CODE: 0

Output Summary: Printed integer 0 (zero findings). A prior pass printed 1 (PSReviewUnusedParameter, test line 317), which was fixed and triggered the loop restart recorded in format-check.2026-10-16T02-54.md.
