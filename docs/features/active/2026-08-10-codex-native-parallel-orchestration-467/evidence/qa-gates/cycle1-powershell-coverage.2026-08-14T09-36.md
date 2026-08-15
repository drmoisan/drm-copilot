# Cycle 1 PowerShell Coverage Reconciliation

Timestamp: 2026-08-15T00-14
Command: Independently parse `artifacts/pester/pester-junit.xml` and `artifacts/pester/powershell-coverage.xml`; re-read and hash the prior 25-owner source-attributed receipt.
EXIT_CODE: 0
Output Summary: The full run passed 2,447 of 2,456 tests with 9 disabled and zero failures/errors. The bundled report records 4,040/4,260 lines (94.835681%) but zero branch counters and a zero branch denominator. The unchanged authoritative receipt preserves 25/25 owner attribution. Coverage policy remains FAIL because PowerShell branch coverage is unavailable.

## Test result

- Test suites: `126`
- Total tests: `2,456`
- Passed: `2,447`
- Disabled: `9`
- Failures: `0`
- Errors: `0`
- JUnit SHA-256: `D068B5EE15ABBC3A657799B21FC7A23F0811F1963305A40AEB2B13A0CA785586`

## Bundled coverage result

- Coverage XML SHA-256: `D2F68C4C2949C926FB8DF2ADB30B9B5BB642A9EB5BB647073F0159B8A624633F`
- Line covered: `4,040`
- Line missed: `220`
- Line denominator: `4,260`
- Line coverage: `94.835681%`
- BRANCH counter count: `0`
- Branch covered: `0`
- Branch missed: `0`
- Branch denominator: `0`

## Authoritative owner preservation

- Prior owner receipt: `evidence/qa-gates/powershell-final-test-coverage.2026-08-13T15-38.md`
- Prior owner receipt SHA-256: `0EB357342E614E3077DD880465A4395D4F33D069E6B307440CB0D96B654082A3`
- Source-attributed owners: `25/25`
- Added owners at or above 90%: `17/17`
- Modified owners meeting applicable line/no-regression thresholds: `8/8`
- Authoritative repository lines: `6,529/7,035 = 92.807392%`
- Combined owner lines: `2,646/2,934 = 90.184049%`
- Cycle change to PowerShell production owners: `0`

## Policy disposition

- Line threshold: `85%` — `PASS`
- Branch threshold: `75%` — `FAIL` because denominator=`0`
- Coverage-policy result: `FAIL`
- `GENUINE_BRANCH_COLLECTOR_ESTABLISHED: NO`
- `POWERSHELL_BRANCH_POLICY_UNRESOLVED`
- Overall disposition: `REMEDIATION_REQUIRED`
