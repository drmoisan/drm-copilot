# Cycle 2 Final QA Comparison

Timestamp: 2026-08-15T02-20
Command: Reconcile P2-T4, P2-T6 through P2-T8, and P2-T9 through P2-T18 receipts; re-hash every cited receipt and language artifact.
EXIT_CODE: 0
Output Summary: Python, TypeScript, and applicable Bash gates remain valid under exact executable-input and artifact-hash equality. Fresh PowerShell formatting, analysis, tests, line coverage, and owner attribution pass, but no genuine branch counter or denominator exists. Overall disposition is REMEDIATION_REQUIRED solely because PowerShell branch coverage has denominator 0.

## Language results

| Language | Lines | Branches | Tests | Owners | Gate result |
|---|---|---|---|---|---|
| Python | `14,350/15,525 = 92.431562%` | `4,894/5,772 = 84.788635%` genuine coverage.py result | `3,971 passed; 5 skipped; 0 failed` | Added `5/5` at least 90%; changed `8/8` non-regressing | PASS, exact reuse |
| PowerShell | Bundled `4,040/4,260 = 94.835681%`; source-attributed `6,529/7,035 = 92.807392%` | Covered `0`; missed `0`; denominator `0`; counter count `0`; FAIL | `2,447 passed; 9 disabled; 0 failures/errors` | Source-attributed `25/25`; added `17/17`; modified `8/8` | REMEDIATION_REQUIRED |
| TypeScript | `44,127/45,740 = 96.47%` | `6,589/7,338 = 89.79%` genuine Istanbul result | `2,690/2,690 passed; 0 failed` | Modified `5/5` non-regressing | PASS, exact reuse |
| Bash | `1,339/1,461 = 91.60%` | `N/A/not-PASS`; no genuine numeric branch claim | `255/255 passed; 0 failed` | N/A under the applicable aggregate Bash gate | PASS for applicable gates, exact reuse |

## Exact language artifact hashes

- Python coverage JSON: `B8837FD7C02CDC1F3C3D0D6AB4A32197DD63C48FF54DC78D3191ED40D5F91709`
- Python test receipt: `1C8E297BC483C164023B312C4B94C3AD5B8B5EF0E127B139CB0CC5FCBDB7B166`
- Fresh PowerShell JUnit XML: `340324928F81839E26E6D0A714655107D808FCB0E552C2F5157B6E1896FC2EB1`
- Fresh PowerShell coverage XML: `C329461C8A2F0E32F6876325979577AF6F7C9C3147436305415DE357C5566D24`
- TypeScript coverage summary: `D1F43ABFA4FF4200CE315B3E30598B6F7DD320A5F02C873B9EF1063A59B1C5C0`
- TypeScript test receipt: `41245C2DC5F113864AFAB445A61FB541A6D52AD63E41098F9DF5237C8296CDD7`
- Bash kcov XML: `0C936506F4C73BAF09ADD135951AF05ADECA81D20720745EEC8237AB59570B7E`
- Bash test receipt: `CB434B268C6089F1F32659CA7CB1960EDC50BAD4107811CCCD19C508463A93B4`

## Source receipt hashes

- P2-T4 PowerShell coverage: `12AF0DBFE19C6093B7CC691F4F192088A40A5689AD959493CE4F25892C778213`
- P2-T6 Python reuse: `F9DD046DADCF4BA7B365E77B9A0E3A22226B1449765BE6EF7B830D5E2B998916`
- P2-T7 TypeScript reuse: `4A6D0F70319F39ADC85313A18A41FA42D1B6FE57E83B900CA022515FDBF0E21F`
- P2-T8 Bash reuse: `5D220CD720B9AF08DB301025F57BDF5F966A2D58A3218329501C01972321E9E9`
- P2-T9 whitespace: `532505B56B4D3D08DDF5E80EA54852F3CC9DB4B00746ECCDBC14DEF415CA4DAD`
- P2-T10 root test-results invariance: `66DD38ADA4D0969C807CF877229433A24BC09EDF0550A227922F2E25F8666AAA`
- P2-T11 Claude invariance: `F2DBA46B81F56E6086B57D247474FC29CB1715B83E1CB98EC7CE7B1B817D3FFB`
- P2-T12 root/bundle parity: `D7582AF31E98C3B6886C32CE93DD28FD948AB52A913915E64F962BAEA9438BF9`
- P2-T13 file sizes: `0A9470B66DC8315DEAABA88BE06CB33E06327EF7DB9150887DF5ED3CE4FF3A98`
- P2-T14 suppressions: `03F8507FFEB74CC682F5A08EE910580FDACFDD2AE9FC775A0192CE306CEFC5B7`
- P2-T15 dependencies: `7ECBA27CDB993DACCF9C23ACDE1374F70FE79B9AE760B68BB83DF8797D77F5DC`
- P2-T16 policy and thresholds: `FF417758A32798F692E92FB6090B8E80E8CF8544F10DF8F7391DFD562DDBEB34`
- P2-T17 evidence locations: `8B6C5D0FAD5315BBCE47B2DF6DE29C8B3374F9C87C83D91B81AD0CC82C3E7221`
- P2-T18 final scope: `A4D4E673F72812FACAD2FD178CB023A37C27B614E411AC0D2B68D08D690FBDBB`

## Repository gates

- Whitespace and EOF: PASS
- Root `testResults.xml` invariance: PASS
- `.claude/**` path/byte invariance: PASS, `150/150`
- Root/bundle byte parity: PASS, `237/237`
- File-size ceiling: PASS, `0` cycle-2 executable/test/script paths above 500
- Suppressions: PASS, `0` new
- Dependencies: PASS, `0` changed
- Policies, thresholds, exclusions, coverage configuration, waivers, exceptions: PASS, `0` changed
- Evidence locations: PASS, validator exit `0`
- Scope: PASS, `0` unrelated or overwritten path; index `0`

## Binding disposition

- `GENUINE_BRANCH_COLLECTOR_ESTABLISHED=NO`
- `POWERSHELL_BRANCH_POLICY_UNRESOLVED`
- PowerShell coverage-policy result: `FAIL`
- Bash branch result remains `N/A/not-PASS` under its applicable gate and is not an additional remediation blocker.
- Overall result: `REMEDIATION_REQUIRED`
- Sole overall remediation reason: PowerShell genuine branch denominator is `0`.

Result: REMEDIATION_REQUIRED
