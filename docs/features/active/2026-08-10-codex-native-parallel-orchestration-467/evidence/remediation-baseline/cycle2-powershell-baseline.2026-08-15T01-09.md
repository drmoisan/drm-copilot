# Cycle 2 PowerShell Baseline Receipt

Timestamp: 2026-08-15T01-37
Command: Get-FileHash artifacts/pester/pester-junit.xml,artifacts/pester/powershell-coverage.xml,cycle1-powershell-coverage.2026-08-14T09-36.md,powershell-branch-capability-decision.2026-08-14T09-36.md -Algorithm SHA256; parse JUnit testcases and JaCoCo report counters; parse frozen cycle-1 coverage and owner values.
EXIT_CODE: 0
Output Summary: The authoritative frozen cycle-1 receipt records 2,447 passed, 9 disabled, 4,040/4,260 = 94.835681% bundled lines, 6,529/7,035 = 92.807392% source-attributed lines, and 25/25 owners. Branch covered=0 and denominator=0, so coverage policy remains FAIL. Exact current hashes are recorded below.

## Exact current artifact hashes

- `artifacts/pester/pester-junit.xml`: `63ECE403E6789D89F97D1EACCAE905E15008B887ACCE311A051514C73C44D208`
- `artifacts/pester/powershell-coverage.xml`: `6670C8861CE497FB53C48B36BB20913E52EBC950C49ABF44F5A9AA095AB65A48`
- `evidence/qa-gates/cycle1-powershell-coverage.2026-08-14T09-36.md`: `47E2FDB7CDB9289700813EE011D6B1D9449AA7DD09E5D02F115D4AB03BA93CCD`
- `evidence/other/powershell-branch-capability-decision.2026-08-14T09-36.md`: `CECD63A502AF7B66D8805F0B4F3240F8D3776F93F399763F6E2CF02962845A10`

## Authoritative frozen cycle-1 baseline

- Tests: 2,447 passed; 9 disabled; 0 failed/errors
- Bundled lines: 4,040/4,260 = 94.835681%
- Source-attributed lines: 6,529/7,035 = 92.807392%
- Source-attributed owners: 25/25
- Branch covered: 0
- Branch missed: 0
- Branch denominator: 0
- Coverage-policy result: FAIL
- `GENUINE_BRANCH_COLLECTOR_ESTABLISHED=NO`
- `POWERSHELL_BRANCH_POLICY_UNRESOLVED`

## Current generated-output parse

The current generated XML files postdate the frozen cycle-1 receipt and contain a later partial scan: 701 JUnit testcases, 701 passed, 0 disabled/failures/errors, and a report-level LINE counter of 1,108 covered plus 3,152 missed (4,260 total). The current XML contains zero BRANCH counters. These partial generated outputs are hashed for launch integrity but are not substituted for the frozen full-run metrics; P2-T3 is required to refresh the repository-default full scan.

Result: PASS for baseline integrity; coverage policy remains FAIL.
