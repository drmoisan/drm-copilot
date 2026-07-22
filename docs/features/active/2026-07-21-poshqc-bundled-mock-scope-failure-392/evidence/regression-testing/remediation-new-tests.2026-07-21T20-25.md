Timestamp: 2026-07-21T20-25

Command: Invoke-Pester -Path tests/scripts/powershell/PoshQC/PoshQC.TestingSeamDefaults.Tests.ps1,tests/scripts/powershell/PoshQC/PoshQC.TestingInvokeConfigPaths.Tests.ps1,tests/scripts/powershell/PoshQC/PoshQC.TestingInvokeSummary.Tests.ps1 -PassThru
EXIT_CODE: 0

Output Summary:
- PoshQC.TestingSeamDefaults.Tests.ps1: 4 tests, 0 failed (includes the new P1-T1 It block for Convert-PoshQCCoverageToRelative line 98).
- PoshQC.TestingInvokeConfigPaths.Tests.ps1: 5 tests, 0 failed (new file, P1-T2, targets lines 291, 309, 314-316, 322, 332, 340-342, 346, 350-354, 356-357, 359, 368-369).
- PoshQC.TestingInvokeSummary.Tests.ps1: 3 tests, 0 failed (new file, P1-T3, targets lines 401-403, 410-415, 417-420, 423-424, 427-428, 433-439).
- Total: 12 tests, 0 failed, 0 skipped, 0 inconclusive across all three files when run directly (not nested inside test code; this was an interactive Invoke-Pester invocation from the command line, consistent with the plan's permitted verification mechanism).

Per-file standalone coverage verification (informational, captured via a separate ad hoc Pester+CodeCoverage invocation against PoshQC.Testing.psm1, not part of the required evidence schema but recorded here for traceability): when each of the three files is run in isolation (or in the two-file P1-T1+P1-T2 combination) against PoshQC.Testing.psm1, every one of the target lines listed in the plan Objective is measured as covered. However, when combined with the full bundled suite (all 8 test files under tests/scripts/powershell/PoshQC/ plus other-scoped test files) via scripts/dev-tools/run-poshqc-suite.ps1, a pre-existing Pester/PowerShell code-coverage-instrumentation defect (module reimport across test files losing coverage credit for functions also exercised by a later-running file) causes a substantial fraction of these lines, and some previously-covered lines in Convert-PoshQCCoverageToRelative, to report as uncovered in the merged JaCoCo report. This finding is documented in full under evidence/qa-gates/remediation-coverage-delta and is a discovered infrastructure constraint, not a defect in the new tests themselves (each new test independently exercises its target lines and passes; see the per-file isolation coverage figures above).
