# Cycle 3 Pass 6 PowerShell Coverage

Timestamp: 2026-08-16T21-00

Command: `independently parse artifacts/pester/pester-junit.xml and artifacts/pester/powershell-coverage.xml using XML root counters and genuine branch-node searches`

EXIT_CODE: 0

Output Summary: Fresh JUnit contains 2,456 tests with 0 failures, 0 errors, and 9 disabled. Fresh bundled line coverage is 4,040/4,260 = 94.835681%. The report has no BRANCH counters, branch-marked lines, condition nodes, or positive mb+cb denominators, so the genuine source-attributable branch result remains 0/0 unavailable and is handled only by the issue-scoped one-time disposition.

## Test Parse

- Total: 2,456
- Passed: 2,447
- Disabled: 9
- Failures: 0
- Errors: 0

## Line Parse

- Covered lines: 4,040
- Missed lines: 220
- Denominator: 4,260
- Percentage: 94.835681%
- Instruction counter: 5,489 covered / 325 missed
- Method counter: 336 covered / 27 missed
- Class counter: 50 covered / 2 missed
- Packages: 8
- Classes: 52

## Genuine Branch Parse

- BRANCH counter nodes: 0
- `branch=true` line nodes: 0
- Condition nodes: 0
- Lines with positive `mb+cb` denominator: 0
- Source-attributable branch numerator: 0
- Source-attributable branch denominator: 0
- `GENUINE_BRANCH_COLLECTOR_ESTABLISHED: NO`
- `RAW_BRANCH_RESULT: 0/0 UNAVAILABLE`
- `COMPLIANCE_DISPOSITION: ONE_TIME_EXCEPTION_AUTHORIZED`
- Proxy-derived or synthetic branch counter used: `false`
- Measured 75% PowerShell branch threshold passed: `false`

No numeric branch percentage is calculated or asserted. The compliance disposition does not modify the raw measurement.

Result: PASS under the authorized one-time disposition; retained test and line gates pass independently.
