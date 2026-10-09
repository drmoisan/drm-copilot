# Final QC (Remediation Cycle 1, Iteration 1): Full Pester Suite with Coverage (self-hosted)

Timestamp: 2026-10-08T20-47
Command: Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root (Get-Location).Path
Shell: sh <scratchpad>/c2-565-r1-run.sh <scratchpad>/c2-565-r1-P0-T23.ps1 (run_in_background; clock-read start 2026-10-08 20:39:28, completion observed 20:47:00)
EXIT_CODE: 2
ExpectedExitCode: 2
Output Summary: Tests Passed: 6770, Failed: 2, Skipped: 10, Inconclusive: 0, NotRun: 0. Covered 84.61% / 0%. 22,297 analyzed Commands in 176 Files. Tests Passed equals the P0-T23 value (6752) plus 18, the nine CAT-R1 cases on each surface. Exit code 2 equals the failed-test count; P5-T10 (qa-gates/junit-failing-set.rem1-1.2026-10-08T20-47.md) shows the two failures are identical to the baseline failing set, so ExpectedExitCode is set to 2.

```
Tests Passed: 6770, Failed: 2, Skipped: 10, Inconclusive: 0, NotRun: 0
Covered 84.61% / 0%. 22,297 analyzed Commands in 176 Files.
```

Coverage file: `artifacts/pester/powershell-coverage.xml` last written 2026-10-08 20:44:39 local; `artifacts/pester/pester-junit.xml` last written 20:46:58. Both are after the run start (20:39:28).
