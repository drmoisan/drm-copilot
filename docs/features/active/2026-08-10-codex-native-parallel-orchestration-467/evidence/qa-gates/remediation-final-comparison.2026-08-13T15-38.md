# Remediation final comparison

Plan task: `[P7-T6]`

## Final disposition

- Overall status: `REMEDIATION_REQUIRED`
- Accepted plan branch: `(b)`
- R1: `NON_PASS`
- R2-R5: `PASS`
- Required marker: `REMEDIATION_REQUIRED: POWERSHELL_BRANCH_POLICY_UNRESOLVED`

No unsupported coverage metric is described as passing. In particular, PowerShell branch coverage remains unavailable because the authoritative result contains no source-attributable branch denominator. Bash branch coverage remains `N/A/not-PASS` under the applicable Bash policy.

## R1-R5 evidence comparison

| Finding | Baseline evidence | Expected-red evidence | Post-change and final evidence | Threshold | Disposition |
|---|---|---|---|---|---|
| R1 — PowerShell branch coverage | `evidence/remediation-baseline/powershell-test-coverage.2026-08-13T15-38.md` and the remediation inputs record no PowerShell `BRANCH` counter. | `evidence/regression-testing/r1-powershell-branch-red.2026-08-13T15-38.md`: exit 1, 0 counters, 0 covered, 0 missed, denominator 0. | `evidence/other/powershell-branch-capability-decision.2026-08-13T15-38.md`, `evidence/qa-gates/r1-powershell-branch-result.2026-08-13T15-38.md`, and `evidence/qa-gates/powershell-final-test-coverage.2026-08-13T15-38.md`: installed Pester/PoshQC provides command coverage only, the final XML still has no branch counter, and no independently authorized policy resolution exists. | Numeric source-attributable branch coverage >=75%, or a separately authorized policy decision. | `NON_PASS`: `POWERSHELL_BRANCH_POLICY_UNRESOLVED`. |
| R2 — Six modified PowerShell owners | `evidence/remediation-baseline/powershell-test-coverage.2026-08-13T15-38.md`: 79.310345%, 58.227848%, 48.471616%, 32.558140%, 20.000000%, and 22.471910%. | `evidence/regression-testing/r2-modified-owners-batch-a-red.2026-08-13T15-38.md` and `r2-modified-owners-batch-b-red.2026-08-13T15-38.md` preserve the below-floor owner results. | Batch green receipts and `evidence/qa-gates/powershell-final-test-coverage.2026-08-13T15-38.md`: final full-run values are 49/58 = 84.482759%, 68/79 = 86.075949%, 186/229 = 81.222707%, 76/86 = 88.372093%, 182/225 = 80.888889%, and 156/178 = 87.640449%. | Every listed owner >=80%; 25/25 source attribution; 17/17 added owners >=90%; the other two modified owners do not regress. | `PASS`. |
| R3 — Canonical Python no-regression coverage | `evidence/baseline/python-coverage.2026-08-10T20-25.json`: target 91/91 lines and 26/26 branches, both 100%. | `evidence/regression-testing/r3-parallel-kickoff-canonical-red.2026-08-13T15-38.md`: 35 tests passed but the 100% gate exited 1 at 107/109 lines and 36/38 branches. | `evidence/regression-testing/r3-parallel-kickoff-canonical-green.2026-08-13T15-38.md` and `evidence/qa-gates/python-final-test-coverage.2026-08-13T15-38.md`: 36/36 focused tests, 109/109 lines, and 38/38 branches; the full suite passed 3,971 with 5 skipped and all eight changed owners were non-regressing. | Preserve the canonical 100% target line and branch percentages; repository lines >=85% and branches >=75%. | `PASS`. |
| R4 — Complete feature-diff whitespace | The remediation input records the reviewed failing feature diff. | `evidence/regression-testing/r4-full-diff-whitespace-red.2026-08-13T15-38.md`: exit 2 with 262 diagnostics across 46 paths. | Authored and generated normalization receipts preserve semantic digests and coverage-display tuples; `evidence/qa-gates/final-git-diff-check.2026-08-13T15-38.md` records final exit 0 with no output. | `git diff --check fe0413d4aca1e76b2d02d05701fba79a887d5405` exits 0, with affected evidence integrity retained. | `PASS`. |
| R5 — Unintended root Pester report | Merge-base `testResults.xml`: 55,716 bytes, SHA-256 `02628E73BB8A090824E5E97ADEB385AF1068AD905E7DA636A40AB64FD5F0E96A`. | `evidence/regression-testing/r5-root-test-results-red.2026-08-13T15-38.md`: exit 1; the feature copy was a one-test report with 18 not-run cases instead of the tracked 124-test report. | `evidence/qa-gates/root-test-results-restoration.2026-08-13T15-38.md` records the merge-base restoration and retained authoritative feature-scoped Pester evidence; `evidence/qa-gates/final-testresults-diff.2026-08-13T15-38.md` records exit 0 and an empty final delta. | Root delta empty; final Pester evidence remains in approved locations rather than replacing the root report. | `PASS`. |

The R5 restoration receipt retains the required prior authoritative counts of 2,430 discovered, 2,421 passed, 9 skipped, and 0 failed. The later final remediation run is separately recorded as 2,456 total, 2,447 passed, 9 skipped, and 0 failed; it was not written to root `testResults.xml`.

## Final language loops

| Language | Consecutive final loop | Tests and coverage | Result |
|---|---|---|---|
| PowerShell | PoshQC format -> analyze -> Pester/coverage | 2,456 total; 2,447 passed; 9 skipped; 0 failed. Repository lines 6,529/7,035 = 92.807392%. Attribution 25/25; added owners 17/17 >=90%; modified owners 8/8 satisfy their requirements. | Applicable gates `PASS`; branch policy `NON_PASS`. |
| Python | Black -> Ruff -> Pyright -> Pytest/coverage | 3,971 passed; 5 skipped; 0 failed. Repository lines 14,350/15,525 = 92.431562%; branches 4,894/5,772 = 84.788635%. | `PASS`. |
| TypeScript | Prettier -> ESLint -> TSC -> Jest/coverage | 194/194 suites and 2,690/2,690 tests passed. Lines 44,127/45,740 = 96.47%; branches 6,589/7,338 = 89.79%; modified owners 5/5 non-regressing. | `PASS`. |
| Bash | shfmt format -> shfmt/shellcheck check -> Bats/kcov | 255/255 tests passed. Lines 1,339/1,461 = 91.6%. Branch coverage is `N/A/not-PASS`. | Applicable gates `PASS`. |

## Preserved-closure reverification

1. Python added-owner and R5 documentation closure remains current. `evidence/qa-gates/remediation-evidence-validation.2026-08-13T15-38.md` verified all 3/3 R5 executable-AST semantic digests and the unchanged test-owner bindings. The accepted R5 receipts retain 0 callable-contract failures, 0 actionable adjacency failures, and the single structurally verified sole-argument `any(...)` generator adjudication. The final Python loop preserves all changed-owner results.
2. PowerShell attribution and added-owner closure was rerun in the final Pester gate: 25/25 sources were attributed and all 17/17 added owners remained at or above 90%. The two stronger no-regression modified owners also passed.
3. TypeScript closure was rerun in the final full loop: all five audited modified owners were non-regressing, repository thresholds passed, and the coverage-summary SHA-256 remained `D1F43ABFA4FF4200CE315B3E30598B6F7DD320A5F02C873B9EF1063A59B1C5C0`.
4. Dedicated planner/orchestrator authority and distribution closure was reverified through the final Python 51/51 and TypeScript 56/56 customization validators, payload-only Bats 12/12, direct root/bundle byte parity 237/237, and zero `.claude/**` tracked or worktree paths. The receipts are `final-python-customization-integrity.2026-08-13T15-38.md`, `final-typescript-customization-integrity.2026-08-13T15-38.md`, `final-payload-only-integrity.2026-08-13T15-38.md`, `final-root-bundle-byte-parity.2026-08-13T15-38.md`, `final-claude-tracked-diff.2026-08-13T15-38.md`, and `final-claude-worktree-status.2026-08-13T15-38.md`.
5. Bash applicable gates were rerun in the final Bash loop: 255/255 tests and 91.6% numeric line coverage passed, while branch coverage remained explicitly unsupported and was not converted to a passing metric.
6. R4 evidence integrity remains verified: 24/24 authored paths retained their whitespace-insensitive semantic digest, 22/22 generated paths retained their non-whitespace semantic digest, all 72/72 Istanbul display tuples were preserved, and the final evidence-location validator exited 0.

## Final status marker

`REMEDIATION_REQUIRED: POWERSHELL_BRANCH_POLICY_UNRESOLVED`

R1 remains non-PASS. R2, R3, R4, and R5 pass. No threshold was lowered, no policy file was changed to create a pass, and no unsupported branch metric was represented as passing.
