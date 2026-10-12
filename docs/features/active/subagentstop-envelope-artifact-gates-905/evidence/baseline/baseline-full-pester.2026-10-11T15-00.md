# Baseline full PowerShell test run with coverage ([P0-T24], issue #905)

Timestamp: 2026-10-11T15-00
Command: sh <SCRATCHPAD>/route.sh <SCRATCHPAD>/r-full.ps1 (Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root (Get-Location).Path), then sh <SCRATCHPAD>/route.sh <SCRATCHPAD>/r-junit.ps1
EXIT_CODE: 0
Output Summary: Tests Passed: 9867, Failed: 0, Skipped: 10, NotRun: 0 (574.01s). JUNIT: tests=9877 failures=0 errors=0 skipped=10. Coverage headline: Covered 88.67% / 0%. 25,950 analyzed Commands in 198 Files. No FAILED-TESTCASE lines; BASELINE-FAILED-SET is empty.

JUNIT: tests=9877 failures=0 errors=0 skipped=10
Pester coverage headline: `Covered 88.67% / 0%. 25,950 analyzed Commands in 198 Files.`
Pester summary line: `Tests Passed: 9867, Failed: 0, Skipped: 10, Inconclusive: 0, NotRun: 0`
BASELINE-FAILED-SET: NONE (r-junit printed no FAILED-TESTCASE line)

Reports written by the run: `artifacts/pester/pester-junit.xml`, `artifacts/pester/powershell-coverage.xml` (and the Koverage copy `artifacts/pester/powershell-coverage.koverage.xml`). No MCP call ran between this task and [P0-T25].

Execution note: [P0-T26] to [P0-T29] (read-only captures with no shared state) were run while this task's R-FULL process ran in the background; they were checked off only after this task and [P0-T25] completed (recorded in `evidence/other/deviations.md`).

## r-junit output

```text
JUNIT: tests=9877 failures=0 errors=0 skipped=10
```
