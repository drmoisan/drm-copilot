# Determinism and Floor Invariants — Reference Implementations

Timestamp: 2026-07-03T16-43

Command: `poetry run pytest tests/scripts/dev_tools/test_compute_complexity_floor.py tests/scripts/dev_tools/test_resolve_delegation_model.py -v`
EXIT_CODE: 0

Output Summary: 29 passed. Both reference implementations produce identical output for identical inputs and honor the floor invariants.

## Determinism (identical inputs yield identical output)

- `test_compute_complexity_floor.py::test_determinism_across_repeated_calls` — repeated calls with identical `signals_present` return a single distinct band.
- `test_compute_complexity_floor.py::test_determinism_independent_of_input_ordering` — forward vs reversed signal ordering yields the same floor.
- `test_resolve_delegation_model.py::test_determinism_across_repeated_calls` — five repeated calls with the same `(agent, band, fable_policy)` return an identical mapping.

## Never-exceed-C3 / C4-never-floor-forced invariant

- `test_compute_complexity_floor.py::test_floor_never_exceeds_c3` — a large multiset of floor signals (with repeats) clamps to `C3`; asserts `floor == "C3"` and `floor != "C4"`. The module clamps with `min(highest_rank, rank(C3))`, so no input path can return `C4`. C4 is judgment-only and is never floor-forced.
- `test_compute_complexity_floor.py::test_no_floor_signals_yields_c1` — empty floor-signal set returns `C1` (lower bound).
- `test_compute_complexity_floor.py::test_each_floor_signal_contributes_c3` (4 params) and `test_max_of_multiple_floor_signals_is_c3` — each floor signal contributes candidate `C3`; the max triggered band is `C3`.

## band >= floor lower-bound ordering (validator-level, cross-referenced to P3)

The `band >= floor` lower-bound ordering is enforced at the validator level, implemented and tested in Phase 3:
- `scripts/dev_tools/_orchestrator_state_complexity.py` (P3-T1) checks `band >= floor` and `floor == compute_complexity_floor(signals_present)`.
- `tests/scripts/dev_tools/test_validate_orchestrator_state_complexity.py` (P3-T2) covers the `band < floor` violation and the `floor != compute_complexity_floor(...)` violation.
The band-ordering primitive used by the validator is `BAND_ORDER` exported from `scripts/dev_tools/compute_complexity_floor.py`. This artifact records the determinism and never-exceed-C3 invariants at the reference-implementation level; the ordering-comparison invariant is verified in Phase 3.

## Coverage (from P1-T3 / P1-T6)

- `compute_complexity_floor.py`: 100% line, 100% branch.
- `resolve_delegation_model.py`: 100% line, 100% branch.
