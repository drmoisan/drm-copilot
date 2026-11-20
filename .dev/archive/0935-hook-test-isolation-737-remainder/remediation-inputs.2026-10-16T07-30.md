# Remediation Inputs — Issue #935 (hook-test-isolation-737-remainder), re-audit after remediation cycle 1

Review-Verdict: AWAITING_CI

One finding blocks completion, and it can only be resolved by a PR CI result. No autonomous finding remains, so no remediation plan is created for this review. No code defect was found.

## BLOCKING COV-1: PowerShell line coverage cannot be measured like-for-like until PR CI runs

Remediability: awaiting_ci
Remediability-Evidence: Awaited workflow is the `poshqc / PowerShell QC` job (artifact `poshqc-test-results`, Pester coverage file) on the final PR head, read by plan task P7-T6 (AC-24); remediation cycle R1 showed the local runner measures a 12280-line population rather than the 18116-line CI population, and that job cannot run before the pull request exists.

- Source: `policy-audit.2026-10-16T07-30.md` sections 1.2 and 1.2.1; carried from `remediation-inputs.2026-10-16T03-20.md`.
- Observed: on-disk `artifacts/pester/powershell-coverage.xml` LINE covered 8110, missed 4170 (66.04%), written by a two-folder run after the R1 record. R1 full-scan run (scan set `scripts`, `tests/powershell`, `tests/scripts`): 11598/12280 = 94.45% (`evidence/qa-gates/coverage-comparison.2026-10-16T06-56.md`, outcome `MEASUREMENT-POPULATION-MISMATCH (DENOMINATOR)`). Baseline 90.42% (16381/18116, CI run 38730332356). Floor 85% (default; root `CLAUDE.md` states none).
- Why it is not autonomous: item 3 of the prior remediation inputs states that the finding becomes `awaiting_ci` on P7-T6 when the local runner cannot reproduce the CI population. R1 recorded that condition. Another local run would reproduce the same 12280-line population.
- Resolution at S9: P7-T6 reads the root LINE counter of the CI coverage file on the final PR head and records it in `FEATURE/evidence/qa-gates/coverage-comparison.<timestamp>.md`. If it is at or above 85% and not below 90.42%, COV-1 closes and AC-24 is checked off. If either comparison fails, COV-1 becomes an autonomous finding and a remediation cycle is required.
- Do not: edit any production file, `config/poshqc-coverage.json`, or any coverage exclusion; add or remove tests to move the figure.

## Pending CI (orchestrator at S9, plan Phase 7)

- PC-1: AC-1..AC-8, AC-10..AC-12, AC-14..AC-19, AC-23, AC-24 require PR CI JUnit artifacts, job conclusions, the CI coverage file, or the JUnit artifact of run 38404520141. Mapping: P7-T2 (AC-23), P7-T3 (AC-1..AC-5, AC-10..AC-12), P7-T4 (AC-7, AC-8), P7-T5 (AC-14..AC-18), P7-T6 (AC-24), P7-T7 (AC-12 report), P7-T8 (AC-6), P7-T9 (AC-19, AC-26 PR half), P7-T10 (ledger and check-off). Local post-merge JUnit (6342 testcases, 0 failures) is consistent with all of them.

## Non-blocking Observations (orchestrator may address)

- O-1: AC-26 PR-description half. The PR body must list the operator follow-ups (F-3 enforcement using the AC-5b report after splitting `legacy-codex-hook-contracts.Tests.ps1`; shape-B limit for hook-local seams; F-6 mirror drift in `.claude/rules/powershell.md` line 31; I-3 residue of 13 files at 490-499 lines and `BlastRadiusConfig.Tests.ps1`) and the N-2 and F-6 decisions.
- O-2: `origin/main` advanced to `b6be46b5e` (PR #948, issue #931) after merge-base `5bc97774b`; update the branch from main before opening the PR. No file overlap.
- O-3: the on-disk coverage artifact was overwritten after the R1 measurement; cite `coverage-comparison.2026-10-16T06-56.md` for the R1 figure, not the on-disk file.
- O-4: CI baseline `adb9aa5f0` differs from the current merge-base; P7 artifacts should record both SHAs.
- CR-R1 (Low): `Test-EpicStateIsolationSeparateValue` has no direct rows for its boundary shapes (last element, followed by a parameter, attached argument, abbreviated name), and its value-parameter list omits the common parameters; report-only impact.
- CR-R2 (Info): residual duplication of the hook-name exclusion and of the `$isJoinPath`/`$isVariable` predicate script blocks in `EpicStateIsolation.HookReference.Helpers.ps1`.
- CR-R3 (Info): no-op `.Replace('__SPAWN__', ...)` in the CR-N3 `-Credential` row.

## Prior Findings Status (cycle R1)

- COV-1: executed; reclassified `awaiting_ci` (above).
- CR-N1, CR-N2, CR-N3, CR-N5, CR-N6, CR-N8: fixed and verified at HEAD.
- CR-N4, CR-N7: NO-CHANGE dispositions accepted.

Artifacts:
- `docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/policy-audit.2026-10-16T07-30.md`
- `docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/code-review.2026-10-16T07-30.md`
- `docs/features/active/2026-10-15-hook-test-isolation-737-remainder-935/feature-audit.2026-10-16T07-30.md`
