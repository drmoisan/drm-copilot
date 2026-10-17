# Full Pester Suite with Coverage (self-hosted), Final QC Iteration 3

Timestamp: 2026-10-08T19-13
Command: Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root (Get-Location).Path
Shell: sh <scratchpad>/c2-565-run.sh <scratchpad>/c2-565-P10-T8-3.ps1 (run_in_background; clock-read start 2026-10-08T19-06-29, end 2026-10-08T19-13-40)
EXIT_CODE: 2
ExpectedExitCode: 2
Output Summary: Tests Passed: 6752, Failed: 2, Skipped: 10, Inconclusive: 0, NotRun: 0. Covered 84.6% / 0%. 22,279 analyzed Commands in 176 Files. Exit code 2 equals the failed-test count; P10-T9 (qa-gates/junit-failing-set.3.2026-10-08T19-13.md) shows both failures are the two pre-existing P0-T20 baseline failures, so ExpectedExitCode is set to the observed 2. Baseline: 6522 passed, 2 failed, 84.33%.

Console lines:

```
Tests Passed: 6752, Failed: 2, Skipped: 10, Inconclusive: 0, NotRun: 0
Covered 84.6% / 0%. 22,279 analyzed Commands in 176 Files.
```

Coverage file: `artifacts/pester/powershell-coverage.xml` last written 2026-10-08 19:11:19 local, during this run (start 19:06:29). `artifacts/pester/pester-junit.xml` last written 19:13:40.
