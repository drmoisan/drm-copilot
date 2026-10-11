# Baseline: Full Pester Run with Coverage

Timestamp: 2026-10-08T17-32
Command: sh <SCRATCHPAD>/s-full-run.sh (Bash run_in_background: true; runs Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCTest -Root .)
EXIT_CODE: 2
ExpectedExitCode: 2
Output Summary:
FULL_RUN_EXIT_CODE: 2
Tests completed in 308.75s
Tests Passed: 6522, Failed: 2, Skipped: 10, Inconclusive: 0, NotRun: 0
Covered 84.33% / 0%. 21,894 analyzed Commands in 174 Files.
artifacts/pester/pester-junit.xml and artifacts/pester/powershell-coverage.xml were written by the run.
The non-zero exit code is caused by the two pre-existing failures recorded as B_FULL in the pester-full-coverage artifact; the in-scope production paths equal BASE_SHA (production-equals-base artifact).
