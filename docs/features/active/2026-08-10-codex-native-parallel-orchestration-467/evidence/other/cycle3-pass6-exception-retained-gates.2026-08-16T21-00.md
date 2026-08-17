# Cycle 3 Pass 6 Exception Retained Gates

Timestamp: 2026-08-16T21-00

Command: `parse evidence/remediation-baseline/cycle3-pass6-powershell-test.2026-08-15T10-36.md and cycle3-pass6-powershell-coverage.2026-08-15T10-36.md; reconcile test, line, and 25-owner results after the zero-delta executable-input comparison`

EXIT_CODE: 0

Output Summary: PASS for every retained PowerShell gate. The accepted baseline contains 2,456 total tests, 2,447 passed, 9 disabled, no failures or errors, 4,040/4,260 line coverage (94.835681%), complete 25-owner attribution, all 17 added owners at or above 90%, and all 8 modified owners satisfying their threshold or no-regression requirement. These gates remain mandatory and are not covered by the one-time branch disposition.

## Retained Evidence Identity

- Test receipt SHA-256: `230BC99FB86879ECADE4BEDFD6B1C722E2F1BC45F78ACBAA4FA6A744EC52DD63`
- Coverage/owner receipt SHA-256: `AB48291C6E511C51555865F6DFED2C73FFCD148B07775C2C5475ED1754703187`
- Governed executable-input delta since capture: 0 paths and 0 bytes.

## Test Gate

- Total: 2,456
- Passed: 2,447
- Disabled: 9
- Failed: 0
- Errors: 0
- Retained test gate: PASS

## Line-Coverage Gate

- Covered lines: 4,040
- Missed lines: 220
- Denominator: 4,260
- Line coverage: 94.835681%
- Required threshold: 85%
- Retained line gate: PASS

## Owner Gates

- Source-attributed owners: 25/25
- Added owners at or above 90%: 17/17
- Modified owners meeting the applicable at-least-80% or no-regression requirement: 8/8
- Added-owner minimum: 90.000000%
- Modified-owner minimum: 80.888889%
- Combined owner lines: 2,646/2,934 = 90.184049%
- Retained owner gates: PASS

## Mandatory Scope

PowerShell formatting, analysis, tests, line coverage, and owner coverage remain mandatory. The one-time exception applies only to the unavailable raw source-attributable PowerShell branch measurement and does not waive or substitute for any retained gate.

RETAINED_GATES: PASS
