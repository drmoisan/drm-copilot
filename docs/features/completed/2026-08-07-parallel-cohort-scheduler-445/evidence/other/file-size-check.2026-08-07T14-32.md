# File-Size Compliance Check — [P1-T17]

Timestamp: 2026-08-07T14-32

Command: `wc -l scripts/dev_tools/parallel_cohort_computation.py tests/scripts/dev_tools/test_parallel_cohort_computation.py tests/scripts/dev_tools/test_parallel_cohort_computation_errors.py`

EXIT_CODE: 0

Output Summary: The split condition triggered and the pre-approved split was applied. Before the split the single test file measured 474 lines, meeting the >= 450-line trigger stated in [P1-T17]. The malformed-input tests and the slot-filling boundary tests were moved into `tests/scripts/dev_tools/test_parallel_cohort_computation_errors.py`, which is the only permitted split layout. No other new file was created. All three delivered files are under the 500-line limit.

## Split Decision

- Trigger threshold: test file at or above 450 lines.
- Measured before split: `tests/scripts/dev_tools/test_parallel_cohort_computation.py` = 474 lines.
- Decision: SPLIT APPLIED.
- Tests moved: the malformed-input matrix (`MALFORMED_GRAPH_CASES`, `test_compute_cohorts_rejects_malformed_graph_input`, `test_compute_concurrency_batches_rejects_non_positive_max_concurrency`, `test_parallel_cohort_input_error_message_names_the_unknown_key_and_edge`, `test_parallel_cohort_input_error_is_catchable_as_value_error`) and the slot-filling boundary matrix (`SLOT_FILLING_CASES`, `test_compute_concurrency_batches_matches_the_expected_batch_layout`, `test_compute_concurrency_batches_concatenate_to_the_sorted_cohort`).
- Tests retained in the primary file: graph shapes, Welsh-Powell ordering, ascending tie-break, determinism permutations, edge symmetry, structural invariants, and both non-mutation tests.

## Post-Split Line Counts

| File | Lines | Under 500 |
| --- | --- | --- |
| `scripts/dev_tools/parallel_cohort_computation.py` | 468 | Yes |
| `tests/scripts/dev_tools/test_parallel_cohort_computation.py` | 310 | Yes |
| `tests/scripts/dev_tools/test_parallel_cohort_computation_errors.py` | 187 | Yes |

## Post-Split Toolchain Confirmation

- `poetry run black tests/ scripts/` — 337 files left unchanged (EXIT_CODE: 0).
- `poetry run ruff check .` — All checks passed (EXIT_CODE: 0).
- `poetry run pyright` — 0 errors, 0 warnings, 0 informations (EXIT_CODE: 0).
- `poetry run pytest` on both new test files — 38 passed (EXIT_CODE: 0).
