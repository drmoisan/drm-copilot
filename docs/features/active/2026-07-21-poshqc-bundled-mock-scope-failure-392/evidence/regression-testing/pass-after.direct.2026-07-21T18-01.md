# P4-T1 Direct-Mode Verification (Issue #392)

Timestamp: 2026-07-21T18-01
Command: `pwsh -NoProfile -Command "Invoke-Pester -Path tests/scripts/powershell/PoshQC -Output Detailed -PassThru"`
EXIT_CODE: 0
Output Summary:
- Passed=98, Failed=0, Skipped=7, Total=105.
- ACCEPTANCE MET (0 failed).
- Total = 105 = baseline 102 (PoshQC folder) + 3 new `PoshQC.TestingSeamDefaults.Tests.ps1` tests.
- History: before the P3-T4 seam-injection fix, this run showed 3 failures in the Koverage-copy tests of `PoshQC.Comprehensive.Tests.ps1` (their module-scope `Mock Invoke-Pester` could not intercept the global-hosting trampoline default). After P3-T4 injected an `$InvokePester` stub into those 3 tests, all pass. The production fix is unchanged.
