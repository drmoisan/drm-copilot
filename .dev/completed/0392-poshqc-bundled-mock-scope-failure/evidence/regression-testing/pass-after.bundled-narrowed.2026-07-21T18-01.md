# P4-T2 Bundled Narrowed Verification (Issue #392)

Timestamp: 2026-07-21T18-01
Command: `pwsh -NoProfile -Command "Import-Module ./extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root . -ScanFolders 'tests/scripts/powershell/PoshQC'; Test-Path function:global:Invoke-PoshQCPesterRun"`
EXIT_CODE: 0
Output Summary:
- Test counts (from `artifacts/pester/pester-junit.xml`): tests=105, failures=0, disabled(skipped)=7, errors=0. Passed=98.
- Trailing `Test-Path function:global:Invoke-PoshQCPesterRun` = `False` (LEAKCHECK=False): the trampoline global function did not leak.
- ACCEPTANCE MET (0 failed AND trailing Test-Path = False).
- The 31 original `Mock data are not setup for this scope` failures are resolved via the bundled-manifest import path, which is the exact production reproduction (MCP `run_poshqc_suite`/`run_poshqc_test`).
