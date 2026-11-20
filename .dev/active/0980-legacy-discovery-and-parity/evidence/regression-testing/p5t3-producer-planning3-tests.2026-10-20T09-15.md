# P5-T3 producer tests

Timestamp: 2026-10-20T09-13

Command: `poetry run coverage run --branch --source=drm_copilot_discovery.completion_report -m pytest -v --tb=short -o addopts= -p no:cacheprovider tests/discovery_runtime/test_completion_planning.py`

EXIT_CODE: 0

Output Summary: PASS; 132.548 seconds.

```text
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0 -- <WORKSPACE>\.venv\Scripts\python.exe
rootdir: <WORKSPACE>
configfile: pyproject.toml
collecting ... collected 19 items

tests/discovery_runtime/test_completion_planning.py::test_public_builder_delegates_one_exact_mode_and_identifier PASSED [  5%]
tests/discovery_runtime/test_completion_planning.py::test_planning_rejects_any_nonexact_grant_pair_before_projection[none] PASSED [ 10%]
tests/discovery_runtime/test_completion_planning.py::test_planning_rejects_any_nonexact_grant_pair_before_projection[one] PASSED [ 15%]
tests/discovery_runtime/test_completion_planning.py::test_planning_rejects_any_nonexact_grant_pair_before_projection[extra] PASSED [ 21%]
tests/discovery_runtime/test_completion_planning.py::test_planning_rejects_any_nonexact_grant_pair_before_projection[duplicate] PASSED [ 26%]
tests/discovery_runtime/test_completion_planning.py::test_planning_rejects_any_nonexact_grant_pair_before_projection[kind] PASSED [ 31%]
tests/discovery_runtime/test_completion_planning.py::test_planning_rejects_any_nonexact_grant_pair_before_projection[identifier] PASSED [ 36%]
tests/discovery_runtime/test_completion_planning.py::test_planning_rejects_any_nonexact_grant_pair_before_projection[json] PASSED [ 42%]
tests/discovery_runtime/test_completion_planning.py::test_planning_rejects_any_nonexact_grant_pair_before_projection[md] PASSED [ 47%]
tests/discovery_runtime/test_completion_planning.py::test_planning_rejects_any_nonexact_grant_pair_before_projection[member] PASSED [ 52%]
tests/discovery_runtime/test_completion_planning.py::test_planning_rejects_any_nonexact_grant_pair_before_projection[list] PASSED [ 57%]
tests/discovery_runtime/test_completion_planning.py::test_planning_rejects_unsupported_modes_before_capture_or_grants[agent-output] PASSED [ 63%]
tests/discovery_runtime/test_completion_planning.py::test_planning_rejects_unsupported_modes_before_capture_or_grants[custom] PASSED [ 68%]
tests/discovery_runtime/test_completion_planning.py::test_planning_rejects_unsupported_modes_before_capture_or_grants[] PASSED [ 73%]
tests/discovery_runtime/test_completion_planning.py::test_planning_rejects_unsupported_modes_before_capture_or_grants[True] PASSED [ 78%]
tests/discovery_runtime/test_completion_planning.py::test_planning_requires_an_actual_captured_workspace PASSED [ 84%]
tests/discovery_runtime/test_completion_planning.py::test_planning_reserves_captured_file_comparisons_before_projection PASSED [ 89%]
tests/discovery_runtime/test_completion_planning.py::test_paired_views_support_dry_run_replacement_and_exact_unchanged_skip PASSED [ 94%]
tests/discovery_runtime/test_completion_planning.py::test_malformed_core_diagnostic_cannot_pass_prospective_mutation_validation PASSED [100%]

======================= 19 passed in 130.73s (0:02:10) ========================

```
