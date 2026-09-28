# Acceptance-Criteria Reconciliation (issue #671)

Timestamp: 2026-09-17T08-31
Task: [P7-T1]
Command: `grep -cF -- '- [x] ' spec.md` (the `Select-String -SimpleMatch` equivalent) and `grep -cE -- '- \[( |x)\] ' spec.md`, each evaluated against `docs/features/active/2026-09-13-preimplementation-gate-worktree-selector-671/spec.md`, then a line-by-line review of the evidence on disk
EXIT_CODE: 0
Status: INCOMPLETE — 21 of 24 acceptance criteria are checked; 3 remain unmet.

Output Summary:
- `- [x] ` line count: 23. The plan expects 26 (24 criteria plus 2 pre-existing metadata lines).
- Total `- [x] ` / `- [ ] ` line count: 29, as expected, so no criterion was added or removed.
- Acceptance criteria: 24 total, 21 checked, 3 unchecked.
- Source: `spec.md` only (work mode `full-bug`).

## Criterion-by-criterion

| # | Criterion (leading text) | State | Delivering task | Evidence |
| --- | --- | --- | --- | --- |
| 1 | The seven `issue #671 LACS allow` rows all pass (Claude) | checked | [P3-T1], [P3-T3] | `evidence/regression-testing/claude-exemption-suite.2026-09-14T00-20.md` |
| 2 | The same seven allow rows ... (Codex) | checked | [P3-T4], [P3-T5] | `evidence/regression-testing/codex-exemption-suite.2026-09-14T00-20.md` |
| 3 | The chained-segment allow is pinned | checked | [P3-T3], [P3-T5] | both suite artifacts above |
| 4 | The `cd`-chain denial is pinned | checked | [P3-T3], [P3-T5] | both suite artifacts above |
| 5 | Each LACS condition L1 through L8 has at least one deny row in both suites, and all of them pass | **UNCHECKED** | [P3-T2], [P3-T4] | the literal-search half holds (all 12 tokens present in both suites), but L3a, L3b, and L8 fail in both suites; see `evidence/qa-gates/poshqc-test-coverage.2026-09-14T01-00.md` |
| 6 | The pathspec, option, and metacharacter restrictions are not weakened | checked | [P3-T3], [P3-T5] | both suite artifacts above |
| 7 | No existing assertion is reversed | checked | [P5-T5], [P3-T6] | `evidence/qa-gates/diff-additive-only-test-suites.2026-09-14T01-00.md`, `evidence/regression-testing/exemption-regression-guards.2026-09-14T00-20.md` |
| 8 | The four gate files are byte-unchanged | checked | [P5-T1] | `evidence/qa-gates/diff-confinement-gate-files.2026-09-14T01-00.md` |
| 9 | The four modes files are byte-unchanged | checked | [P5-T2] | `evidence/qa-gates/diff-confinement-modes-files.2026-09-14T01-00.md` |
| 10 | The epic-merge gate's matcher is not widened | checked | [P5-T3] | `evidence/qa-gates/diff-confinement-shared-parser.2026-09-14T01-00.md` |
| 11 | The helpers diff is confined to one axis | checked | [P5-T4] | `evidence/qa-gates/diff-confinement-helpers.2026-09-14T01-00.md` |
| 12 | Gates still deny when a required document is genuinely absent | checked | [P6-T6] | `evidence/qa-gates/must-not-regress-rollup.2026-09-14T01-00.md` |
| 13 | Epic and standalone topologies behave exactly as now | checked | [P6-T6] | same roll-up artifact |
| 14 | Node `keeps all four surface copies of the helpers module byte-identical by SHA256 hash` ... passes | checked | [P4-T2], [P4-T3] | `evidence/regression-testing/helpers-parity-suite.2026-09-14T00-20.md` |
| 15 | Bundled-payload mirroring is complete | checked | [P2-T1]-[P2-T5], [P5-T6], [P6-T5], [P6-T6] | `evidence/other/helpers-surface-parity.2026-09-14T00-20.md`, `evidence/qa-gates/changed-path-set.2026-09-14T01-00.md`, `evidence/qa-gates/python-pushdown-contracts.2026-09-14T01-00.md`, roll-up artifact |
| 16 | No file exceeds the 500-line cap | checked | [P4-T3], [P6-T3], [P6-T6] | parity-suite artifact, `evidence/qa-gates/poshqc-test-coverage.2026-09-14T01-00.md` (433 lines each), roll-up artifact |
| 17 | An **executed** fail-before capture exists | checked | [P0-T4], [P0-T10] | `evidence/regression-testing/fail-before-lacs-repro.2026-09-13T22-40.md` |
| 18 | An **executed** pass-after capture exists | checked | [P5-T9] | `evidence/regression-testing/pass-after-lacs-repro.2026-09-14T01-00.md` |
| 19 | Line coverage is at or above 85% ... and coverage on the changed lines of the helpers file does not regress | **UNCHECKED** | [P6-T3], [P6-T4] | repository line coverage is 95.41% (meets the floor), but 4 changed lines (253, 254, 258, 259) are unreached because of the defects behind criterion 5, and unchanged line 319 lost coverage (per-file 94.92% -> 92.72%); see `evidence/qa-gates/coverage-comparison.2026-09-14T01-00.md` |
| 20 | The full PowerShell toolchain passes in a single pass | **UNCHECKED** | [P6-T1]-[P6-T3], [P6-T7] | format clean and analyze 0 findings, but the test step reports failures; see `evidence/qa-gates/toolchain-single-pass.2026-09-14T01-00.md` |
| 21 | No Python leg is introduced | checked | [P5-T6] | `evidence/qa-gates/changed-path-set.2026-09-14T01-00.md` |
| 22 | The change adds no new production file and no F1 dependency | checked | [P5-T6], [P5-T7] | changed-path-set artifact, `evidence/qa-gates/helpers-purity.2026-09-14T01-00.md` |
| 23 | The helpers module's declared purity survives | checked | [P5-T7] | `evidence/qa-gates/helpers-purity.2026-09-14T01-00.md` |
| 24 | The nested-subdirectory widening is recorded in the helpers file | checked | [P1-T4], [P5-T8] | `evidence/qa-gates/accepted-widening-record.2026-09-14T01-00.md` |

## Gaps (unmet criteria)

1. **Criterion 5**: rows L3a and L3b cannot deny at gate level, because their commands carry no `add`/`commit` and the gate trigger never classifies them. Row L8 cannot deny because of the pre-existing empty-token fail-open at helpers line 221, which the plan does not permit editing.
2. **Criterion 19**: follows from gap 1, which leaves four changed lines unreached; the loss of coverage on unchanged line 319 is a separate effect of routing every non-`add`/`commit` token at index 1 through the selector predicate.
3. **Criterion 20**: follows from gap 1, because the test step cannot pass.

All three require a plan and spec revision. The proposed delta is in the executor completion report.
