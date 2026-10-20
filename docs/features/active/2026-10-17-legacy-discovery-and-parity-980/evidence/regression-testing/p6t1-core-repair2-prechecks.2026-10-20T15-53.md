# P6-T1 core service prechecks

Timestamp: 2026-10-20T15-52

Command: `poetry run pytest -v --tb=short --maxfail=3 -o addopts= -p no:cacheprovider tests/discovery_runtime/test_service.py::test_catalog_failure_keeps_only_bounded_recognized_context tests/discovery_runtime/test_service.py::test_provider_mismatch_has_actionable_unavailable_context tests/discovery_runtime/test_service.py::test_installed_identity_failure_is_not_a_resource_only_success tests/discovery_runtime/test_service_boundaries.py::test_failed_freshness_preserves_observation_without_second_read tests/discovery_runtime/test_service_boundaries.py::test_projection_prepays_work_before_hashing_and_carrier_construction tests/discovery_runtime/test_service_boundaries.py::test_result_prepays_incremental_comparison_work_and_preserves_findings`

EXIT_CODE: 0

Output Summary: PASS; 22.260 seconds.

```text
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0 -- <WORKSPACE>\.venv\Scripts\python.exe
rootdir: <WORKSPACE>
configfile: pyproject.toml
collecting ... collected 12 items

tests/discovery_runtime/test_service.py::test_catalog_failure_keeps_only_bounded_recognized_context[fields0] PASSED [  8%]
tests/discovery_runtime/test_service.py::test_catalog_failure_keeps_only_bounded_recognized_context[fields1] PASSED [ 16%]
tests/discovery_runtime/test_service.py::test_catalog_failure_keeps_only_bounded_recognized_context[fields2] PASSED [ 25%]
tests/discovery_runtime/test_service.py::test_catalog_failure_keeps_only_bounded_recognized_context[fields3] PASSED [ 33%]
tests/discovery_runtime/test_service.py::test_catalog_failure_keeps_only_bounded_recognized_context[fields4] PASSED [ 41%]
tests/discovery_runtime/test_service.py::test_provider_mismatch_has_actionable_unavailable_context PASSED [ 50%]
tests/discovery_runtime/test_service.py::test_installed_identity_failure_is_not_a_resource_only_success PASSED [ 58%]
tests/discovery_runtime/test_service_boundaries.py::test_failed_freshness_preserves_observation_without_second_read PASSED [ 66%]
tests/discovery_runtime/test_service_boundaries.py::test_projection_prepays_work_before_hashing_and_carrier_construction[False] PASSED [ 75%]
tests/discovery_runtime/test_service_boundaries.py::test_projection_prepays_work_before_hashing_and_carrier_construction[True] PASSED [ 83%]
tests/discovery_runtime/test_service_boundaries.py::test_result_prepays_incremental_comparison_work_and_preserves_findings[False] PASSED [ 91%]
tests/discovery_runtime/test_service_boundaries.py::test_result_prepays_incremental_comparison_work_and_preserves_findings[True] PASSED [100%]

============================= 12 passed in 20.67s =============================

```
