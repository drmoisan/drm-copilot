# PowerShell Bundled Coverage Baseline

Timestamp: 2026-08-14T23-26
Command: Hash `artifacts/pester/powershell-coverage.xml` with `Get-FileHash -Algorithm SHA256` and parse the existing root coverage counters, source filenames, and branch counters without rerunning Pester.
EXIT_CODE: 0
Output Summary: The bundled report covers 4,040 of 4,260 lines (94.835681%) across 46 unique source names. It contains zero `BRANCH` counters, so branch covered=0 and denominator=0. The repository branch-coverage policy result is FAIL.

- SHA-256: `FC146941FA72DB4488278B952A3A2FA3808250757CACD6514181D31395768F67`
- Line Covered: `4,040`
- Line Missed: `220`
- Line Denominator: `4,260`
- Line Coverage: `94.835681%`
- Unique Source Names: `46`
- BRANCH Counter Count: `0`
- Branch Covered: `0`
- Branch Missed: `0`
- Branch Denominator: `0`
- Coverage Policy Result: `FAIL`
- Disposition: `POWERSHELL_BRANCH_POLICY_UNRESOLVED`

The zero branch denominator means the metric is unavailable. It is not a passing branch percentage.
