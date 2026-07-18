Timestamp: 2026-07-18T16-32

## Purpose

This artifact corrects a mislabeled coverage metric identified as Finding 2
(non-blocking, documentation accuracy) in
`remediation-inputs.2026-07-18T16-04.md`. It does not replace or modify the
original artifact; it is an additive correction.

## Original artifact (unmodified)

`docs/features/active/2026-07-17-legacy-discovery-validators-361/evidence/qa-gates/final-qc-pytest-new-code.2026-07-18T10-42.md`

That artifact's per-file note states: "The full-suite run (P7-T4) confirms
`schema_loading.py` reaches 82% line coverage once those pre-existing tests
are included."

That "82%" figure (81.63% precise, per independent verification recorded in
`remediation-inputs.2026-07-18T16-04.md`) is `coverage.py`'s blended
`percent_covered` metric — statements and branches combined into a single
percentage — not pure line (statement) coverage. The pure full-suite line
coverage for `schema_loading.py` is 85.71%; the full-suite branch coverage
is 71.43% (the figure that actually failed the 75% threshold, and which the
original artifact did not state at all).

The original artifact file at the path above is left unmodified by this
remediation cycle; this file is the correction.

## Corrected figures (post-remediation, stated separately, not blended)

Source: `evidence/qa-gates/schema-loading-branch-coverage-fix.2026-07-18T16-30.md`
(Phase 2, task P2-T1 of `remediation-plan.2026-07-18T16-04.md`), a
test-file-scoped rerun of `tests/scripts/dev_tools/test_schema_loading.py`
after the three Phase 1 test additions:

- `schema_loading.py` line (statement) coverage: **85.71%** (30/35 statements
  covered).
- `schema_loading.py` branch coverage: **92.86%** (13/14 branches covered).
- Blended `percent_covered` (for reference only, not to be cited as "line
  coverage"): 87.76%.

Both figures are now well above the uniform thresholds (line >= 85%, branch
>= 75%) defined in `.claude/rules/quality-tiers.md`.

## Correction statement

Any future reference to `schema_loading.py`'s coverage should cite line and
branch percentages separately and by name (`percent_statements_covered`,
`percent_branches_covered`), and should not reuse `coverage.py`'s blended
`percent_covered` value under the label "line coverage".
