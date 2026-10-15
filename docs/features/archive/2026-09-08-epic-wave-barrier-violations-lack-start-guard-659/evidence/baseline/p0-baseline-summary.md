# Phase 0 Baseline Summary

Timestamp: 2026-09-30T10-16

Plan task: [P0-T15] (re-run under plan revision 3, version 1.3)

Output Summary: 13 of 13 rows are GREEN. [P0-T14] was re-run against the revision-3 digest literal and is now GREEN. B_TS is `none`. Phase 1 may proceed.

| Task | Artifact | Status |
|---|---|---|
| [P0-T2] | `evidence/baseline/minor-audit-preconditions.md` | GREEN |
| [P0-T3] | `evidence/baseline/p0-base-ref.md` | GREEN |
| [P0-T4] | `evidence/baseline/p0-line-counts.md` | GREEN |
| [P0-T5] | `evidence/baseline/p0-npm-ci.md` | GREEN |
| [P0-T6] | `evidence/baseline/p0-python-black.md` | GREEN |
| [P0-T7] | `evidence/baseline/p0-python-ruff.md` | GREEN |
| [P0-T8] | `evidence/baseline/p0-python-pyright.md` | GREEN |
| [P0-T9] | `evidence/baseline/p0-python-coverage.md` | GREEN |
| [P0-T10] | `evidence/baseline/p0-typescript-prettier.md` | GREEN |
| [P0-T11] | `evidence/baseline/p0-typescript-lint.md` | GREEN |
| [P0-T12] | `evidence/baseline/p0-typescript-typecheck.md` | GREEN |
| [P0-T13] | `evidence/baseline/p0-typescript-coverage.md` | GREEN |
| [P0-T14] | `evidence/baseline/p0-frozen-surface-pin.md` | GREEN |

## Baseline headline values

- BASELINE_PY_VALIDATOR_LINE_PCT: 96.64 (LH 144 / LF 149); BASELINE_PY_VALIDATOR_BRANCH_PCT: 93.06 (BRH 67 / BRF 72); terminal Cover 95%; 67 passed.
- BASELINE_TS_CORE_LINE_PCT: 97.79; BASELINE_TS_CORE_BRANCH_PCT: 89.87; full suite 3315 of 3315 tests passed across 236 suites.
- Skill digest: `4e9c47c36aeb3c0a6c3c1f06c7c21012a9027a279b81e5e1c0a1e8ce5bb093c8` (matches pin at `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` line 150).
- B_TS: none.

## Result

ALL GREEN. Proceed to Phase 1.
