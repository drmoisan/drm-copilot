# Additional Remediation Cycle 1 Final Comparison

Timestamp: `2026-08-15T00:40:00-04:00`

Plan task: `[P5-T21]`

Overall result: `REMEDIATION_REQUIRED: POWERSHELL_BRANCH_POLICY_UNRESOLVED`

`GENUINE_BRANCH_COLLECTOR_ESTABLISHED: NO`

## Repository QA comparison

| Language | Baseline tests | Final tests | Baseline lines | Final lines | Baseline branches | Final branches | Result |
|---|---:|---:|---:|---:|---:|---:|---|
| Python | 3,934 passed; 5 skipped | 3,971 passed; 5 skipped | 14,290/15,505 = 92.163818% | 14,350/15,525 = 92.431562% | 4,866/5,776 = 84.245152% | 4,894/5,772 = 84.788635% | Line/branch `PASS` |
| PowerShell | 2,285 passed; 9 disabled | 2,447 passed; 9 disabled | 4,040/4,260 = 94.835681% | 4,040/4,260 = 94.835681% | unavailable; denominator 0 | unavailable; 0 counters and denominator 0 | Line `PASS`; branch `FAIL` |
| TypeScript | 193 suites; 2,678 tests | 194 suites; 2,690 tests | 44,076/45,740 = 96.36% | 44,127/45,740 = 96.47% | 6,562/7,326 = 89.57% | 6,589/7,338 = 89.79% | Line/branch `PASS` |
| Bash | 255 passed | 255 passed | 1,339/1,461 = 91.6% | 1,339/1,461 = 91.6% | unsupported | unsupported | Line `PASS`; branch `N/A/not-PASS` |

Python line coverage increased by 0.267744 percentage points, and supported branch coverage increased by 0.543483 percentage points. TypeScript line coverage increased by 0.11 percentage points, and supported branch coverage increased by 0.22 percentage points. The comparable configured PowerShell and Bash line values are unchanged.

## Python owner deltas

| Owner | Baseline lines | Final lines | Delta | Result |
|---|---:|---:|---:|:---:|
| `_parallel_orchestrator_state_completion_receipts.py` | 91/100 = 91.000000% | 95/102 = 93.137255% | +2.137255 pp | PASS |
| `_parallel_orchestrator_state_mutation_receipts.py` | 131/143 = 91.608392% | 136/145 = 93.793103% | +2.184711 pp | PASS |
| `parallel_codex_readiness_filesystem.py` | 147/173 = 84.971098% | 163/177 = 92.090395% | +7.119297 pp | PASS |
| `push_down_codex_routing_merge.py` | 87/101 = 86.138614% | 100/104 = 96.153846% | +10.015232 pp | PASS |
| `validate_parallel_codex_readiness.py` | 173/200 = 86.500000% | 184/202 = 91.089109% | +4.589109 pp | PASS |
| `parallel_kickoff_contract.py` | 104/106 = 98.113208% | 109/109 = 100.000000% | +1.886792 pp | PASS |
| `resolve_codex_deployment.py` | 89/90 = 98.888889% | 92/92 = 100.000000% | +1.111111 pp | PASS |
| `resolve_codex_topology.py` | 107/108 = 99.074074% | 110/110 = 100.000000% | +0.925926 pp | PASS |

- Added owners at or above 90%: `5/5`.
- Changed owners non-regressing: `8/8`.
- `parallel_kickoff_contract.py`: `109/109` lines and `38/38` supported branches.

## PowerShell owner deltas

The final configured bundled report remains 4,040/4,260 lines and omits six remediated modified owners. Owner conclusions therefore remain bound to the preserved source-attributed receipt: 6,529/7,035 repository lines, 25/25 owners, and 2,646/2,934 combined owner lines.

| Modified owner | Baseline line coverage | Final line coverage | Delta | Result |
|---|---:|---:|---:|:---:|
| `codex-authority-store.ps1` | 79.310345% | 49/58 = 84.482759% | +5.172414 pp | PASS |
| `enforce-codex-model-routing.ps1` | 58.227848% | 68/79 = 86.075949% | +27.848101 pp | PASS |
| `record-subagent-routing-attestation.ps1` | 48.471616% | 186/229 = 81.222707% | +32.751091 pp | PASS |
| `validate-codex-subagent-routing.ps1` | 32.558140% | 76/86 = 88.372093% | +55.813953 pp | PASS |
| `launch-epic-child-wave.ps1` | 20.000000% | 182/225 = 80.888889% | +60.888889 pp | PASS |
| `resume-epic-child.ps1` | 22.471910% | 156/178 = 87.640449% | +65.168539 pp | PASS |
| `enforce-completion-consistency.ps1` | 157/159 = 98.742138% | 157/159 = 98.742138% | 0.000000 pp | PASS |
| `epic-child-launch-contract.ps1` | 134/160 = 83.750000% | 135/160 = 84.375000% | +0.625000 pp | PASS |

- Source-attributed owners: `25/25`.
- Added owners at or above 90%: `17/17`.
- Modified owners meeting applicable thresholds: `8/8`.
- PowerShell branch counters: `0`; covered `0`; missed `0`; denominator `0`.
- PowerShell branch disposition: `FAIL — POWERSHELL_BRANCH_POLICY_UNRESOLVED`.

## TypeScript owner deltas

| Modified owner | Baseline lines | Final lines | Delta | Result |
|---|---:|---:|---:|:---:|
| `claude-routing-merge.ts` | 466/491 = 94.908350% | 484/491 = 98.574338% | +3.665988 pp | PASS |
| `codex-topology-resolver.ts` | 308/320 = 96.250000% | 315/320 = 98.437500% | +2.187500 pp | PASS |
| `orchestration-artifacts.ts` | 354/360 = 98.333333% | 360/360 = 100.000000% | +1.666667 pp | PASS |
| `orchestrator-state-codex-model-routing.ts` | 466/497 = 93.762575% | 478/497 = 96.177062% | +2.414487 pp | PASS |
| `parallel-kickoff-artifact.ts` | 409/417 = 98.081535% | 417/417 = 100.000000% | +1.918465 pp | PASS |

Modified owners non-regressing: `5/5`.

## Bash disposition

Bash retained `255/255` passing tests and `1,339/1,461 = 91.6%` line coverage. The configured kcov aggregation does not provide a source-attributable branch denominator. Bash branch coverage is `N/A/not-PASS`, not a numeric pass.

## Artifact integrity

| Artifact | SHA-256 |
|---|---|
| Baseline Python coverage JSON | `A9A11854E77CC2879615EE1D280A0911468B82CEF1561422447E4FCC2D2E3F81` |
| Cycle 1 Python coverage JSON | `B8837FD7C02CDC1F3C3D0D6AB4A32197DD63C48FF54DC78D3191ED40D5F91709` |
| Cycle 1 Python test receipt | `1C8E297BC483C164023B312C4B94C3AD5B8B5EF0E127B139CB0CC5FCBDB7B166` |
| Baseline PowerShell receipt | `89EC3199BC38121CBB731CD9B0CEB5A66430FA48C578CC1E30AA8A34218F1D76` |
| Cycle 1 full PowerShell JUnit at P5-T4 | `D068B5EE15ABBC3A657799B21FC7A23F0811F1963305A40AEB2B13A0CA785586` |
| Cycle 1 full PowerShell coverage XML at P5-T4 | `D2F68C4C2949C926FB8DF2ADB30B9B5BB642A9EB5BB647073F0159B8A624633F` |
| Cycle 1 PowerShell test receipt | `0E1F594AA6A3F0A089776EE6D5940A5AB13D8C6CE84FA72F46D76FE1541ADA00` |
| Cycle 1 PowerShell coverage receipt | `47E2FDB7CDB9289700813EE011D6B1D9449AA7DD09E5D02F115D4AB03BA93CCD` |
| Baseline TypeScript coverage summary | `7C5DD9808621285FA2E3EA16A71EE2A5524559A964294DAEF4ADD97F2300DD36` |
| Cycle 1 TypeScript coverage summary | `D1F43ABFA4FF4200CE315B3E30598B6F7DD320A5F02C873B9EF1063A59B1C5C0` |
| Cycle 1 TypeScript test receipt | `41245C2DC5F113864AFAB445A61FB541A6D52AD63E41098F9DF5237C8296CDD7` |
| Baseline Bash Cobertura XML | `83E23E7079F1CCD4AC2202575A4757302572338FB9D8C3B094A750EAD43177C6` |
| Cycle 1 Bash Cobertura XML | `0C936506F4C73BAF09ADD135951AF05ADECA81D20720745EEC8237AB59570B7E` |
| Cycle 1 Bash test receipt | `CB434B268C6089F1F32659CA7CB1960EDC50BAD4107811CCCD19C508463A93B4` |

The focused P5-T15 PoshQC run subsequently replaced the tool-owned current JUnit file with its 701-test native-hook receipt; the P5-T4 full-run hashes above remain bound to the immutable cycle receipts and are not represented as the current tool-owned file hash.

## Final policy disposition

- Python: `PASS`.
- PowerShell line and owner gates: `PASS`.
- PowerShell branch gate: `FAIL`.
- TypeScript: `PASS`.
- Bash applicable gates: `PASS`; branch `N/A/not-PASS`.
- `GENUINE_BRANCH_COLLECTOR_ESTABLISHED: NO`.
- `POWERSHELL_BRANCH_POLICY: POWERSHELL_BRANCH_POLICY_UNRESOLVED`.
- Overall: `REMEDIATION_REQUIRED`.
