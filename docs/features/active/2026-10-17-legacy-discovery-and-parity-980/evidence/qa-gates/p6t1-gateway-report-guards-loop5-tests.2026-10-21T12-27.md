# P6-T1 report guard tests

Timestamp: 2026-10-21T12-20

Command: `WORKSPACE\.venv\Scripts\python.exe -m coverage run --branch --source=drm_copilot_discovery.service_reports -m pytest -v --durations=10 --tb=short --maxfail=1 -o addopts= -p no:cacheprovider tests/discovery_runtime/test_service_report_guards.py`

EXIT_CODE: 0

Output Summary: PASS; 438.309 seconds.

```text
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0 -- WORKSPACE\.venv\Scripts\python.exe
rootdir: WORKSPACE
configfile: pyproject.toml
collecting ... collected 10 items

tests/discovery_runtime/test_service_report_guards.py::test_malformed_report_findings_are_not_an_empty_success[RG1] PASSED [ 10%]
tests/discovery_runtime/test_service_report_guards.py::test_malformed_report_findings_are_not_an_empty_success[RG2] PASSED [ 20%]
tests/discovery_runtime/test_service_report_guards.py::test_projection_errors_propagate_without_fallback_or_publication[RG3] PASSED [ 30%]
tests/discovery_runtime/test_service_report_guards.py::test_projection_errors_propagate_without_fallback_or_publication[RG4] PASSED [ 40%]
tests/discovery_runtime/test_service_report_guards.py::test_malformed_validate_all_retains_public_validator_findings PASSED [ 50%]
tests/discovery_runtime/test_service_report_guards.py::test_invalid_projection_validation_status_is_refused PASSED [ 60%]
tests/discovery_runtime/test_service_report_guards.py::test_acceptance_preview_preserves_ready_and_pending_selected_views[RG7] PASSED [ 70%]
tests/discovery_runtime/test_service_report_guards.py::test_acceptance_preview_preserves_ready_and_pending_selected_views[RG8] PASSED [ 80%]
tests/discovery_runtime/test_service_report_guards.py::test_acceptance_write_plans_complete_sources_and_selected_views PASSED [ 90%]
tests/discovery_runtime/test_service_report_guards.py::test_report_dispatch_refuses_another_operation_family PASSED [100%]

============================ slowest 10 durations =============================
314.82s call     tests/discovery_runtime/test_service_report_guards.py::test_acceptance_write_plans_complete_sources_and_selected_views
31.57s call     tests/discovery_runtime/test_service_report_guards.py::test_acceptance_preview_preserves_ready_and_pending_selected_views[RG7]
31.40s call     tests/discovery_runtime/test_service_report_guards.py::test_acceptance_preview_preserves_ready_and_pending_selected_views[RG8]
20.34s call     tests/discovery_runtime/test_service_report_guards.py::test_malformed_validate_all_retains_public_validator_findings
16.67s setup    tests/discovery_runtime/test_service_report_guards.py::test_projection_errors_propagate_without_fallback_or_publication[RG3]
7.54s call     tests/discovery_runtime/test_service_report_guards.py::test_projection_errors_propagate_without_fallback_or_publication[RG4]
7.46s call     tests/discovery_runtime/test_service_report_guards.py::test_projection_errors_propagate_without_fallback_or_publication[RG3]
7.46s call     tests/discovery_runtime/test_service_report_guards.py::test_invalid_projection_validation_status_is_refused

(2 durations < 0.005s hidden.  Use -vv to show these durations.)
======================= 10 passed in 437.54s (0:07:17) ========================

```
