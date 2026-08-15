# Cycle 2 PowerShell Coverage Reconciliation

Timestamp: 2026-08-15T01-59
Command: Independently parse `artifacts/pester/pester-junit.xml` and `artifacts/pester/powershell-coverage.xml`; compare the frozen P0-T9 owner receipt.
EXIT_CODE: 0
Output Summary: The fresh repository-default run passed 2,447 of 2,456 tests with 9 disabled and zero failures/errors. Bundled line coverage is 4,040/4,260 (94.835681%). No genuine branch counters exist, so the branch denominator is zero and coverage policy remains FAIL. The unchanged owner receipt preserves 25/25 source-attributed owners.

## Fresh test result

- Test suites: `126`
- Total tests: `2,456`
- Passed: `2,447`
- Disabled/skipped: `9`
- Failures: `0`
- Errors: `0`
- JUnit SHA-256: `340324928F81839E26E6D0A714655107D808FCB0E552C2F5157B6E1896FC2EB1`
- P2-T3 receipt SHA-256: `7374132D4221BBC155970F4858F71F0005658D83261E847143870C7B41E79213`

## Fresh bundled coverage result

- Coverage XML SHA-256: `C329461C8A2F0E32F6876325979577AF6F7C9C3147436305415DE357C5566D24`
- Report-level LINE counter count: `1`
- Line covered: `4,040`
- Line missed: `220`
- Line denominator: `4,260`
- Line coverage: `94.835681%`
- BRANCH counter count: `0`
- Branch covered: `0`
- Branch missed: `0`
- Branch denominator: `0`

## Frozen owner comparison

- P0-T9 owner receipt: `evidence/qa-gates/cycle1-powershell-coverage.2026-08-14T09-36.md`
- P0-T9 owner receipt SHA-256: `47E2FDB7CDB9289700813EE011D6B1D9449AA7DD09E5D02F115D4AB03BA93CCD`
- Source-attributed owners: `25/25`
- Added owners at or above 90%: `17/17`
- Modified owners meeting applicable line/no-regression thresholds: `8/8`
- Source-attributed lines: `6,529/7,035 = 92.807392%`
- Combined owner lines: `2,646/2,934 = 90.184049%`
- Cycle-2 PowerShell production-owner changes: `0`

## Policy disposition

- Line threshold: `85%` — `PASS`
- Branch threshold: `75%` — `FAIL` because the genuine denominator is `0`
- Coverage-policy result: `FAIL`
- `GENUINE_BRANCH_COLLECTOR_ESTABLISHED=NO`
- `POWERSHELL_BRANCH_POLICY_UNRESOLVED`
- Overall disposition: `REMEDIATION_REQUIRED`

Result: PASS for P2-T4 evidence completeness; PowerShell branch policy remains unresolved.
