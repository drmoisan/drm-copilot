# Phase 7 gate — zero-edge cohort and validator tolerance (Python)

Timestamp: 2026-09-07T18-08

Command: `poetry run pytest tests/scripts/dev_tools/test_parallel_mergeable_cohort.py tests/scripts/dev_tools/test_parallel_cohort_bash_parity.py tests/scripts/dev_tools/test_validate_parallel_orchestrator_state_mergeable.py tests/scripts/dev_tools/test_validate_parallel_orchestrator_state.py tests/scripts/dev_tools/test_validate_parallel_orchestrator_state_cohort_barrier.py -v`

EXIT_CODE: 0

## Output Summary

Result line, verbatim:

```text
150 passed in 0.46s
```

The three node IDs the task names, verbatim from the run output:

```text
tests/scripts/dev_tools/test_parallel_mergeable_cohort.py::test_csproj_only_overlaps_place_every_item_in_a_single_cohort PASSED [  1%]
tests/scripts/dev_tools/test_parallel_cohort_bash_parity.py::test_reference_implementation_reproduces_the_fixture[cohorts_mergeable_only_overlaps] PASSED [ 17%]
tests/scripts/dev_tools/test_validate_parallel_orchestrator_state_mergeable.py::test_item_carrying_mergeable_conflicts_resolved_yields_no_errors PASSED [ 24%]
```

No failures. The cohort-barrier validator suite
(`test_validate_parallel_orchestrator_state_cohort_barrier.py`) ran unmodified and passed, which is
the constraint C8 out-of-scope confirmation on the Python side; P7-T7 records the file-level
confirmation.
