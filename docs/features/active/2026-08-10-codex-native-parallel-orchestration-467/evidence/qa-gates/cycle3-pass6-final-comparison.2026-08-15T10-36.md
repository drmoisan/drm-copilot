# Cycle 3 Pass 6 Final Comparison

Timestamp: 2026-08-16T21-00

Command: Reconcile the Phase 0 baseline, exception reconciliation, Phase 3 PowerShell loop, retained Phase 4 language gates, Phase 5 audit-readiness gates, acceptance criteria, artifact hashes, and final scope.

EXIT_CODE: 0

Output Summary: Every applicable non-excepted measurement passes with zero regression. PowerShell test, line, and owner results match baseline; its genuine source-attributable branch denominator remains zero and is handled only by the authorized issue-scoped disposition. Python and TypeScript genuine branch thresholds pass. Bash branch coverage remains N/A/not-PASS without a fabricated numeric claim. Acceptance criteria are 41 PASS, 0 FAIL, 2 UNVERIFIED.

## PowerShell baseline/final comparison

| Measurement | Baseline | Final | Delta | Requirement/result |
|---|---:|---:|---:|---|
| Total tests | 2,456 | 2,456 | 0 | PASS |
| Passed tests | 2,447 | 2,447 | 0 | PASS |
| Disabled tests | 9 | 9 | 0 | PASS |
| Test failures | 0 | 0 | 0 | PASS |
| Test errors | 0 | 0 | 0 | PASS |
| Covered lines | 4,040 | 4,040 | 0 | PASS |
| Missed lines | 220 | 220 | 0 | PASS |
| Line denominator | 4,260 | 4,260 | 0 | PASS |
| Line percentage | 94.835681% | 94.835681% | 0.000000 pp | >=85%, PASS |
| Source-attributed owners | 25/25 | 25/25 | 0 | PASS |
| Added owners >=90% | 17/17 | 17/17 | 0 | PASS |
| Modified owners threshold/no-regression | 8/8 | 8/8 | 0 | PASS |
| Added-owner minimum | 90.000000% | 90.000000% | 0.000000 pp | PASS |
| Modified-owner minimum | 80.888889% | 80.888889% | 0.000000 pp | PASS |
| Source-attributable branch numerator | 0 | 0 | 0 | Unavailable |
| Source-attributable branch denominator | 0 | 0 | 0 | Unavailable |

- Format: `ok=true`, exit 0, zero mutation.
- Analyze: `ok=true`, exit 0, zero findings.
- Test: `ok=true`, exit 0.
- `GENUINE_BRANCH_COLLECTOR_ESTABLISHED: NO`
- `RAW_BRANCH_RESULT: 0/0 UNAVAILABLE`
- `COMPLIANCE_DISPOSITION: ONE_TIME_EXCEPTION_AUTHORIZED`
- Measured 75% PowerShell branch PASS claimed: `NO`
- Proxy-derived or synthetic branch counter used: `NO`

## Retained non-PowerShell comparisons

| Language/measurement | Accepted baseline | Final | Delta | Result |
|---|---:|---:|---:|---|
| Python selected input paths | 435 | 435 | 0 | 0 mismatches, UNCHANGED |
| Python passed tests | 3,971 | 3,971 | 0 | PASS |
| Python skipped tests | 5 | 5 | 0 | retained |
| Python failed tests | 0 | 0 | 0 | PASS |
| Python covered lines/statements | 14,350 | 14,350 | 0 | PASS |
| Python line denominator | 15,525 | 15,525 | 0 | PASS |
| Python line percentage | 92.431562% | 92.431562% | 0.000000 pp | >=85%, PASS |
| Python covered branches | 4,894 | 4,894 | 0 | PASS |
| Python branch denominator | 5,772 | 5,772 | 0 | PASS |
| Python branch percentage | 84.788635% | 84.788635% | 0.000000 pp | >=75%, PASS |
| Python added owners >=90% | 5/5 | 5/5 | 0 | PASS |
| Python changed owners non-regressing | 8/8 | 8/8 | 0 | PASS |
| TypeScript selected input paths | 421 | 421 | 0 | 0 mismatches, UNCHANGED |
| TypeScript passed tests | 2,690 | 2,690 | 0 | PASS |
| TypeScript failed tests | 0 | 0 | 0 | PASS |
| TypeScript covered lines | 44,127 | 44,127 | 0 | PASS |
| TypeScript line denominator | 45,740 | 45,740 | 0 | PASS |
| TypeScript line percentage | 96.47% | 96.47% | 0.00 pp | >=85%, PASS |
| TypeScript covered branches | 6,589 | 6,589 | 0 | PASS |
| TypeScript branch denominator | 7,338 | 7,338 | 0 | PASS |
| TypeScript branch percentage | 89.79% | 89.79% | 0.00 pp | >=75%, PASS |
| TypeScript modified owners non-regressing | 5/5 | 5/5 | 0 | PASS |
| Bash selected input paths | 58 | 58 | 0 | 0 mismatches, UNCHANGED |
| Bash passed tests | 255 | 255 | 0 | PASS |
| Bash failed tests | 0 | 0 | 0 | PASS |
| Bash covered lines | 1,339 | 1,339 | 0 | PASS |
| Bash line denominator | 1,461 | 1,461 | 0 | PASS |
| Bash line percentage | 91.60% | 91.60% | 0.00 pp | >=85%, PASS |
| Bash source-attributable numeric branch denominator | unavailable | unavailable | unchanged | N/A/not-PASS; no numeric claim |

- Python: formatter exit 0, Ruff findings 0, Pyright errors 0.
- TypeScript: Prettier exit 0, ESLint findings 0, TypeScript errors 0.
- Bash: shfmt diff 0, ShellCheck errors 0, `.claude/**` mutations 0.
- All applicable non-PowerShell numeric branch thresholds pass: Python and TypeScript.
- Bash remains explicitly `N/A/not-PASS`; no numeric Bash branch threshold result is fabricated.

## Cross-cutting audit-readiness comparison

| Measurement | Baseline | Final | Delta | Result |
|---|---:|---:|---:|---|
| Governed executable-input paths | 2,576 | 2,576 | 0 | 0 content mismatches |
| `.claude/**` paths | 150 | 150 | 0 | 0 path/byte deltas |
| Root/bundle customization paths | 237 | 237 | 0 | 0 missing/extra/mismatch |
| Root/bundled PoshQC module mismatches | 0 | 0 | 0 | PASS |
| P0-T6 owner path/byte mutations | 0 | 0 | 0 | PASS |
| Dependency changes | 0 | 0 | 0 | PASS |
| Lockfile changes | 0 | 0 | 0 | PASS |
| Suppression/reusable-waiver changes | 0 | 0 | 0 | PASS |
| Policy/threshold/exclusion changes | 0 | 0 | 0 | PASS |
| Coverage-configuration changes | 0 | 0 | 0 | PASS |
| Non-canonical evidence paths | 0 | 0 | 0 | PASS |
| `git diff --check` output lines | 0 | 0 | 0 | PASS |
| Staged paths | 0 | 0 | 0 | PASS |

## Acceptance-criteria comparison

| Disposition | P0-T5 baseline | Final | Delta |
|---|---:|---:|---:|
| Checked/PASS | 39 | 41 | +2 |
| FAIL | 2 | 0 | -2 |
| Unchecked/UNVERIFIED | 2 | 2 | 0 |
| PARTIAL | 0 | 0 | 0 |

- S-D14 and U20 changed to PASS only through `COMPLIANCE_DISPOSITION: ONE_TIME_EXCEPTION_AUTHORIZED` after every other coverage and evidence-location element passed.
- S-D15 and U21 remain unchecked/UNVERIFIED pending exact-current-head hosted CI.
- Criterion-text changes: `0`.
- Other requirement-source changes: `0`.

## Raw measurement artifact hashes

| Artifact | SHA-256 |
|---|---|
| `artifacts/pester/pester-junit.xml` | `2425960D72E68B985377A7A8D9D2E9984751805FBF53CF5E88037DF7F2F48DA7` |
| `artifacts/pester/powershell-coverage.xml` | `A85578B4501F0F5D154B866F4A568CB0A36191BC83F17791BD3C68684F652330` |
| `evidence/qa-gates/cycle1-python-coverage.2026-08-14T09-36.json` | `B8837FD7C02CDC1F3C3D0D6AB4A32197DD63C48FF54DC78D3191ED40D5F91709` |
| `extensions/drm-copilot/coverage/coverage-summary.json` | `D1F43ABFA4FF4200CE315B3E30598B6F7DD320A5F02C873B9EF1063A59B1C5C0` |
| `evidence/qa-gates/cycle1-bash-kcov.2026-08-14T09-36/cov.xml` | `0C936506F4C73BAF09ADD135951AF05ADECA81D20720745EEC8237AB59570B7E` |

## Pre-P6-T1 cycle-3 receipt hashes

The following 49 receipts were hashed immediately before this comparison. This comparison's own hash is recorded by P6-T3.

| Receipt | SHA-256 |
|---|---|
| `evidence/issue-updates/cycle3-pass6-acceptance-reconciliation.2026-08-15T10-36.md` | `D19EC6B599506D390D85F38F26C30D8EED835B2723690EB1B0651C477F39CDF3` |
| `evidence/other/cycle3-pass6-branch-capability-decision.2026-08-15T10-36.md` | `864DE2814858B2DF63D85032999B27AA9884D39F485C487995A336050A3B4C7F` |
| `evidence/other/cycle3-pass6-branch-capability-inventory.2026-08-15T10-36.md` | `D48FF4359F85751ED6F3367A9F179EAFDD419443B709AD1D4CE795590864D529` |
| `evidence/other/cycle3-pass6-exception-continuation-decision.2026-08-16T21-00.md` | `D04B4B8BC15DF3A1862123D4142326DCFAA05526A9B7970920D48677894C6DA6` |
| `evidence/other/cycle3-pass6-exception-no-implementation-delta.2026-08-16T21-00.md` | `19445103551437B97E9F3BA5237DA5D73DFF202F1530E6B50E587FF3209231B7` |
| `evidence/other/cycle3-pass6-exception-raw-branch-reconciliation.2026-08-16T21-00.md` | `1E01A5CAE52326A63871521A962B7FD77E7E2C836DA8F648D21AB63DA346A678` |
| `evidence/other/cycle3-pass6-exception-resume-verification.2026-08-16T21-00.md` | `683A050B9BEE5B9644DE42AC1B386A5550B02B1C18A73AEC330A785B0112A68C` |
| `evidence/other/cycle3-pass6-exception-retained-gates.2026-08-16T21-00.md` | `372CC3B3E7C6697D0223E47A93F6C2B2E8FA68FD6F494F6F18D14083D93CABA8` |
| `evidence/other/cycle3-pass6-exception-runbook-conformance.2026-08-16T21-00.md` | `93D21D3077A930936FC2BB74562721C402C8366A314D4F8C09728DA7AD7C9ADE` |
| `evidence/other/cycle3-pass6-executor-to-orchestrator-handback.2026-08-15T10-36.md` | `A5D03071312D75107C4350554750E745F6EBB769A1F430326C9C6A32FFB67281` |
| `evidence/other/cycle3-pass6-fail-closed-decision.2026-08-15T10-36.md` | `60EEFB00F9EAEDCC3863787066A32243EA4128338114AA33A76F2C29386D60D8` |
| `evidence/other/cycle3-pass6-powershell-branch-one-time-exception.2026-08-16T21-00.md` | `1BBD4C323BEB8D9F76BF4FB4916452D9087EC89C1AD88C6B9F41AAA625B68B65` |
| `evidence/qa-gates/cycle3-pass6-bash-check.2026-08-15T10-36.md` | `7B46E72B0CBC16E67632608A0B574D386B947237DA548F6FAB5DD3BB460BCAE3` |
| `evidence/qa-gates/cycle3-pass6-bash-coverage.2026-08-15T10-36.md` | `56AC5E3296D1FAF7CA3D6050DB490FF132DB9FFCF9D0E7653012E7E7BC2571D0` |
| `evidence/qa-gates/cycle3-pass6-bash-freshness.2026-08-15T10-36.md` | `1C31ED03A29055A4E52121AC4AD490E9D52A22DC1F282AFBEE83C8D71FEE70FE` |
| `evidence/qa-gates/cycle3-pass6-claude-invariance.2026-08-15T10-36.md` | `5B4FB737BE317DB7BF14A5CCC63171B03DEC3AF2950430D11B09D0136B614FBF` |
| `evidence/qa-gates/cycle3-pass6-diff-check.2026-08-15T10-36.md` | `178ABF84E2B250655D8A153BAAD558AB4A5F104CF7DF526D0EB354158AE1866D` |
| `evidence/qa-gates/cycle3-pass6-evidence-locations.2026-08-15T10-36.md` | `733AD7AA22D2BBD7DB68E7D2D86857FDFF4306CD54E39148185E3AA2DF562E00` |
| `evidence/qa-gates/cycle3-pass6-file-sizes.2026-08-15T10-36.md` | `4339F45892749783BE48D435747FA7DBA04108D520CEE18AA46DC8936D298469` |
| `evidence/qa-gates/cycle3-pass6-final-scope.2026-08-15T10-36.md` | `C219E1BB0E9FB961EE78B9339000EC814243C7B469F3D4CEECC96EA91B2FBAAF` |
| `evidence/qa-gates/cycle3-pass6-policy-scope.2026-08-15T10-36.md` | `71B592A0CAD517A39C66D69201506DF3274ABDA21C846F07A8076E18C81C1DFE` |
| `evidence/qa-gates/cycle3-pass6-powershell-analyze.2026-08-15T10-36.md` | `0D813D40AC23E119EB8C1978696170E6D4B4E9AC79C20D5A0AD67F3A8237388A` |
| `evidence/qa-gates/cycle3-pass6-powershell-coverage.2026-08-15T10-36.md` | `68E0A5EE77247B50CC8AD7EF6705017B239B8647B41302FFF92C20A0B02B354B` |
| `evidence/qa-gates/cycle3-pass6-powershell-format.2026-08-15T10-36.md` | `FEEA63C5FBD75B5FD57E1C87C0D05BFF06F72CC1EDC6FA4BC9D80E0A6590475C` |
| `evidence/qa-gates/cycle3-pass6-powershell-owner-comparison.2026-08-15T10-36.md` | `CDD6D523FCB8E9BB0C6FBE4796218ECA20DBFD575C46E80FA2E489F2462DB452` |
| `evidence/qa-gates/cycle3-pass6-powershell-test.2026-08-15T10-36.md` | `B30E7BDDE38C16BA5AB6A2CA3AACBC1D48C73162D6C6578F3FEB2496A7DF7451` |
| `evidence/qa-gates/cycle3-pass6-python-coverage.2026-08-15T10-36.md` | `884E20EDAF8FD41C12CCB873F0B2AC639367EA1B4F20A2D16AB0403419E569A4` |
| `evidence/qa-gates/cycle3-pass6-python-format.2026-08-15T10-36.md` | `B830B0F5C5F1C1C9EFA0474C37C7210DDCC9B69D06309C3B2B94FD26C177E9C8` |
| `evidence/qa-gates/cycle3-pass6-python-freshness.2026-08-15T10-36.md` | `4E0EFEBA42CEAB27665F00B6A9767E67A4A6EF60AD326BAD9974DB94F0E9027B` |
| `evidence/qa-gates/cycle3-pass6-python-lint.2026-08-15T10-36.md` | `8EF856255244CC3B29E2A5BEB6E60851668FE055CE25AC81F3065EF4708A88F1` |
| `evidence/qa-gates/cycle3-pass6-python-typecheck.2026-08-15T10-36.md` | `374CE17E03AA3737D8C5F12479CAE77C78AC934359DC4858DBF94B17F9D7A164` |
| `evidence/qa-gates/cycle3-pass6-root-bundle-parity.2026-08-15T10-36.md` | `7ABB12EBBD51C0414A5C4AF7BEF32F4FBE53DF32A4666B6BAA0F4D89190C9F74` |
| `evidence/qa-gates/cycle3-pass6-typescript-coverage.2026-08-15T10-36.md` | `DFA6A1E93109130AD796DC41EAE82AE48240A860C6128BAB42297CD1AC4CDBDF` |
| `evidence/qa-gates/cycle3-pass6-typescript-format.2026-08-15T10-36.md` | `1EEA0FE6CEDCF2175F89A2A40F58C32DEEF9246C6CB7977839094B2306539BF7` |
| `evidence/qa-gates/cycle3-pass6-typescript-freshness.2026-08-15T10-36.md` | `AEFFE77108ED4CE9182D1004AE165A898BE02120BC88FA68EBF5C1DD577D7273` |
| `evidence/qa-gates/cycle3-pass6-typescript-lint.2026-08-15T10-36.md` | `B5590B2A9473F42E716E26C04BAB7AF4F8CCF51CDA1400F9F9B651EE86D0A01D` |
| `evidence/qa-gates/cycle3-pass6-typescript-typecheck.2026-08-15T10-36.md` | `19E99370EB5E904A24FBF8BC61541F583517804F4237EEBC6EA8B1EB0CFD1574` |
| `evidence/regression-testing/cycle3-pass6-branch-capability-probe.2026-08-15T10-36.md` | `171C1006277C925B280A6AAC657E5684C2526B797AFEA323D1772E9ED14D2D45` |
| `evidence/remediation-baseline/cycle3-pass6-acceptance-baseline.2026-08-15T10-36.md` | `750F1C6D1EFF7F167CA9A01C950CA5A9333ACE7CFFB9F7789AA8690B224E6D99` |
| `evidence/remediation-baseline/cycle3-pass6-authorization-gate.2026-08-15T10-36.md` | `7931E0742C72DF0328CA2D909864FBCCBFE33AFDCD6C19EDCA24419D9AB748D0` |
| `evidence/remediation-baseline/cycle3-pass6-context-integrity.2026-08-15T10-36.md` | `DAC37D53928B67F956A548FDE3FCFA5A86932ABC3EF8A999965CB117B062DA87` |
| `evidence/remediation-baseline/cycle3-pass6-executable-input-fingerprint.2026-08-15T10-36.md` | `3383208E92209AB5D68CAE1CF21180402AEBB0B7FECA0B53D8FA5A4174245776` |
| `evidence/remediation-baseline/cycle3-pass6-phase0-instructions-read.2026-08-15T10-36.md` | `A22664E6C34E15648D6527FD971E39E8ABD694A65DCC24F4CB49A6C101E55AF8` |
| `evidence/remediation-baseline/cycle3-pass6-powershell-analyze.2026-08-15T10-36.md` | `3F1C67341025C195A676CBCB445DEFA6450FE9ABD61FB2A511E06768049C8992` |
| `evidence/remediation-baseline/cycle3-pass6-powershell-coverage.2026-08-15T10-36.md` | `AB48291C6E511C51555865F6DFED2C73FFCD148B07775C2C5475ED1754703187` |
| `evidence/remediation-baseline/cycle3-pass6-powershell-format.2026-08-15T10-36.md` | `72A1CB444E37E53006282B94040329F2B290C909FC402FC2F113F0E6FB9C114D` |
| `evidence/remediation-baseline/cycle3-pass6-powershell-ownership.2026-08-15T10-36.md` | `81ED0DE68F634080CC32E729CB8F063DC4FEA27F42FDCECFF62DB7CCF8374738` |
| `evidence/remediation-baseline/cycle3-pass6-powershell-test.2026-08-15T10-36.md` | `230BC99FB86879ECADE4BEDFD6B1C722E2F1BC45F78ACBAA4FA6A744EC52DD63` |
| `evidence/remediation-baseline/cycle3-pass6-repository-state.2026-08-15T10-36.md` | `6B026E1D6153A23C08DF8D566EC7075760E59C861713CE7E900DE5BB7E660E96` |

## Final disposition

- Retained gate regression count: `0`.
- Policy violations: `0`.
- Scope violations: `0`.
- Acceptance criteria: `41 PASS / 0 FAIL / 2 UNVERIFIED / 0 PARTIAL`.
- `requested=2 consumed=0 remaining=2`.
- Pass 6 status: `active`; R5 has not occurred.

Result: PASS under the issue-scoped one-time PowerShell branch compliance disposition; no measured PowerShell branch PASS is claimed.
