Timestamp: 2026-09-26T23-39

Command:
```
$Result = Invoke-Pester -Path 'tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1' -Output Detailed -PassThru
'TOTAL=' + $Result.TotalCount + ' PASSED=' + $Result.PassedCount + ' FAILED=' + $Result.FailedCount
$Result.Failed | ForEach-Object { 'FAILED_IT=' + $_.Name }
```

EXIT_CODE: 0

Output Summary:
TOTAL=23 PASSED=18 FAILED=5 (baseline file It-count of 17 plus the 6 newly inserted cases equals 23; 5 fail because `Test-NonVacuousCollection` is not yet defined).
FAILED_IT=returns false for a null value
FAILED_IT=returns false for an empty array
FAILED_IT=returns false for an array of only null elements
FAILED_IT=returns true for a non-empty array
FAILED_IT=returns true for a non-empty hashtable Keys property

The sixth new case, "documents that the legacy expression @($null).Count -gt 0 evaluates to $true", passed as expected because it needs no helper.
