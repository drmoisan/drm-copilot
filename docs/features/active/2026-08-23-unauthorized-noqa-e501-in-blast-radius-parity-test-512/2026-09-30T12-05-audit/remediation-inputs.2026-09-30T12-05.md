# Remediation Inputs (Issue #512)

- Timestamp: 2026-09-30T12-05
- Source artifacts:
  - `docs/features/active/2026-08-23-unauthorized-noqa-e501-in-blast-radius-parity-test-512/2026-09-30T12-05-audit/policy-audit.2026-09-30T12-05.md`
  - `docs/features/active/2026-08-23-unauthorized-noqa-e501-in-blast-radius-parity-test-512/2026-09-30T12-05-audit/code-review.2026-09-30T12-05.md`
  - `docs/features/active/2026-08-23-unauthorized-noqa-e501-in-blast-radius-parity-test-512/2026-09-30T12-05-audit/feature-audit.2026-09-30T12-05.md`
- Blocking count: 1

## Remediation-Required Findings

### R1 (Blocking): Python repo-wide coverage artifact does not meet thresholds

- Policy audit item 14. The only coverage artifact, `artifacts/python/lcov.info`, holds one module (`scripts\dev_tools\compute_blast_radius.py`): line 70.0% (LH 56 / LF 80), branch 21.43% (BRH 3 / BRF 14). Thresholds are line >= 85% and branch >= 75%.
- The branch does not change that module and shows no regression, so the fix is evidence, not code. Produce a full-suite Python coverage artifact (the repository's standard full-suite pytest run with coverage) and record its repo-wide line and branch figures under `evidence/qa-gates/`. If the repo-wide figures meet the thresholds, the finding closes. If they do not, record the result and the pre-existing gap for a user decision; do not modify production code under this issue.
- Note: the review procedure prohibits the reviewer from regenerating coverage, so this action belongs to the remediation executor.

### R2 (Major, non-blocking): Incorrect branch-coverage derivation in evidence

- `evidence/baseline/pytest-coverage-baseline.2026-09-29T15-16.md`, `evidence/qa-gates/final-pytest-coverage.2026-09-29T15-16.md`, and `evidence/qa-gates/coverage-comparison.2026-09-29T15-16.md` derive branch coverage as `(Branch - BrPart) / Branch` = 78.57%. Coverage.py `BrPart` is the count of partially covered branches; the lcov file shows 3 of 14 branches hit (21.43%).
- Correct the derivation and the figure cited in `spec.md` AC8 (line 222) to 21.43%. The no-regression conclusion (identical rows) is unchanged.

## Optional Minor Items

- Update `spec.md` and `plan.2026-09-29T15-16.md` `Status` and `Last Updated` fields.
- Correct "17 tests" to "20 tests" in `spec.md` Test Strategy (line 181-182).
