# Experiment E3 — Module topology at failure time (Issue #392)

Timestamp: 2026-07-21T18-01
Command:
- Instrumentation temporarily inserted at the top of the first failing `It` in `tests/scripts/powershell/PoshQC/PoshQC.Comprehensive.Tests.ps1` (before the `InModuleScope` call): `Get-Module -Name PoshQC -All | Select-Object Name, Path, Guid | Out-Host` and `$ExecutionContext.SessionState.Module | Select-Object Name, Path | Out-Host`.
- Bundled/module-hosted run: `pwsh -NoProfile -Command "Import-Module ./extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root . -ScanFolders 'tests/scripts/powershell/PoshQC/PoshQC.Comprehensive.Tests.ps1'"`
- Direct/global-hosted run: `pwsh -NoProfile -Command "Invoke-Pester -Path tests/scripts/powershell/PoshQC/PoshQC.Comprehensive.Tests.ps1 -Output Detailed"`
- Instrumentation reverted with `git checkout -- tests/scripts/powershell/PoshQC/PoshQC.Comprehensive.Tests.ps1`.
EXIT_CODE: 0 (both diagnostic runs executed; revert confirmed clean)
Output Summary:
- `Get-Module -Name PoshQC -All` observed hosting module in EACH mode: exactly ONE `PoshQC` instance, path `scripts\powershell\PoshQC\PoshQC.psm1` (repo-root), in BOTH the bundled and direct runs. The BeforeAll guard successfully removed the pre-imported bundled instance, so at container run time only the repo-root instance is loaded.
- `$ExecutionContext.SessionState.Module` at the It-body observation point (above `InModuleScope`) printed no rows in both modes; the module-vs-global hosting difference is at the `Invoke-Pester` caller session state (captured deeper in the run), not observable as a distinct module object at the It body.
- Conclusion: the defect is NOT an unresolved multi-instance `InModuleScope` ambiguity (only one PoshQC instance is visible). This corroborates research deduction 1 and directs the fix to the hosting session state at the `Invoke-PoshQCTest` seam.
- Post-task `git diff -- tests/scripts/powershell/PoshQC/PoshQC.Comprehensive.Tests.ps1` is empty; the E3 marker `E3-TOPOLOGY` is absent from the file.
