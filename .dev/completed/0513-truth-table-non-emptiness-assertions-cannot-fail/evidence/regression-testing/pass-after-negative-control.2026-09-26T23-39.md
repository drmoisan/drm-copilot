Timestamp: 2026-09-26T23-39

Command:
```
$Result = Invoke-Pester -Path 'tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1' -Output Detailed -PassThru
'TOTAL=' + $Result.TotalCount + ' PASSED=' + $Result.PassedCount + ' FAILED=' + $Result.FailedCount
$Result.Failed | ForEach-Object { 'FAILED_IT=' + $_.Name }
```

EXIT_CODE: 0

Output Summary: TOTAL=23 PASSED=23 FAILED=0. All 6 new `It` cases in the 'Non-vacuity floor helper' Context now pass after `Test-NonVacuousCollection` was defined in the top-level `BeforeAll` block.
