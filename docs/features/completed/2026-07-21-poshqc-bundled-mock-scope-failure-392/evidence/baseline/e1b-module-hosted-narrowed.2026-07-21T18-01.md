# Experiment E1b — Module-hosted bundled path narrowed to PoshQC folder (Issue #392)

Timestamp: 2026-07-21T18-01
Command: `pwsh -NoProfile -Command "Import-Module ./extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root . -ScanFolders 'tests/scripts/powershell/PoshQC'"`
EXIT_CODE: 31
Output Summary:
- Test counts (from `artifacts/pester/pester-junit.xml`): tests=102, failures=31, disabled(skipped)=7, errors=0. Passed = 102 - 31 - 7 = 64.
- Every failure is `RuntimeException: Mock data are not setup for this scope, what happened?`.
- Compared with E1a (same 102 tests, same pre-imported bundled module, but global-hosted: 95 passed / 0 failed): the only difference is that `Invoke-PoshQCTest`'s default `$InvokePester` seam hosts the run in the PoshQC module's session state. The 31 failures reproduce exactly under module-hosting, confirming module-session-state hosting as the necessary and sufficient condition.
