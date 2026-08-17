# Cycle 3 Pass 6 Bash Coverage

Timestamp: 2026-08-16T21-00

Command: `Get-FileHash evidence/qa-gates/cycle1-bash-kcov.2026-08-14T09-36/cov.xml,evidence/qa-gates/cycle1-bash-test.2026-08-14T09-36.md,evidence/qa-gates/cycle3-pass6-bash-freshness.2026-08-15T10-36.md -Algorithm SHA256; parse accepted test and line results`

EXIT_CODE: 0

Output Summary: The approved `UNCHANGED` branch applies. The accepted kcov XML and test receipt match their locked hashes. All 255 Bats tests passed, line coverage is 1,339/1,461 = 91.60%, and branch coverage remains explicitly `N/A/not-PASS` without a fabricated numeric result.

- Selected branch: `UNCHANGED`
- Expected/current kcov XML SHA-256: `0C936506F4C73BAF09ADD135951AF05ADECA81D20720745EEC8237AB59570B7E`
- Expected/current test receipt SHA-256: `CB434B268C6089F1F32659CA7CB1960EDC50BAD4107811CCCD19C508463A93B4`
- Current freshness receipt SHA-256: `1C31ED03A29055A4E52121AC4AD490E9D52A22DC1F282AFBEE83C8D71FEE70FE`
- Current Bash selected-path mismatches: 0

## Numeric and Applicability Gates

- Bats tests: 255/255 passed; 0 failed.
- Covered lines: 1,339
- Line denominator: 1,461
- Line coverage: 91.60% >= 85% — PASS.
- Branch coverage: `N/A/not-PASS`.
- Source-attributable numeric branch denominator established: `false`.
- Numeric Bash branch percentage claimed: `false`.
- kcov placeholder branch attributes treated as measured coverage: `false`.

Result: PASS for all applicable Bash gates
