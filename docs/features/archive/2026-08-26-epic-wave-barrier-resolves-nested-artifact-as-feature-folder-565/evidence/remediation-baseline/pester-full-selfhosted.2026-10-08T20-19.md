# Remediation Baseline: Full Pester Suite with Coverage (self-hosted)

Timestamp: 2026-10-08T20-19
Command: Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root (Get-Location).Path
Shell: sh <scratchpad>/c2-565-r1-run.sh <scratchpad>/c2-565-r1-P0-T23.ps1 (run_in_background; clock-read start 2026-10-08 20:12:18, completion observed 20:19:24)
EXIT_CODE: 2
ExpectedExitCode: 2
Output Summary: Tests Passed: 6752, Failed: 2, Skipped: 10, Inconclusive: 0, NotRun: 0. Covered 84.6% / 0%. 22,279 analyzed Commands in 176 Files. Exit code 2 equals the failed-test count; P0-T24 (remediation-baseline/junit-failing-set.2026-10-08T20-19.md) shows the two failures are identical to the baseline failing set, so ExpectedExitCode is set to 2.

```
Tests Passed: 6752, Failed: 2, Skipped: 10, Inconclusive: 0, NotRun: 0
Covered 84.6% / 0%. 22,279 analyzed Commands in 176 Files.
```

Coverage file: `artifacts/pester/powershell-coverage.xml` last written 2026-10-08 20:17:15 local; `artifacts/pester/pester-junit.xml` last written 20:19:21. Both are after the run start (20:12:18), so both were written by this run (write times read by the P0-T24 body).
