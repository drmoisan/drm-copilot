Timestamp: 2026-10-21T12-14
Command: `.venv/Scripts/python.exe -B -m pytest -o addopts= -p no:cacheprovider -vv --tb=short --maxfail=1 --cov=drm_copilot_discovery.service_reports --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH\issue-980-p6t1-gateway-report-guards-loop4.coverage.json tests/discovery_runtime/test_service_report_guards.py`
EXIT_CODE: 124
Output Summary: report-guards-loop4-focused; 8 retained test IDs; elapsed 300.014 seconds.

```text
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0 -- WORKSPACE\.venv\Scripts\python.exe
rootdir: WORKSPACE
configfile: pyproject.toml
plugins: anyio-4.12.1, cov-7.0.0
collecting ... collected 10 items

tests/discovery_runtime/test_service_report_guards.py::test_malformed_report_findings_are_not_an_empty_success[RG1] PASSED [ 10%]
tests/discovery_runtime/test_service_report_guards.py::test_malformed_report_findings_are_not_an_empty_success[RG2] PASSED [ 20%]
tests/discovery_runtime/test_service_report_guards.py::test_projection_errors_propagate_without_fallback_or_publication[RG3] PASSED [ 30%]
tests/discovery_runtime/test_service_report_guards.py::test_projection_errors_propagate_without_fallback_or_publication[RG4] PASSED [ 40%]
tests/discovery_runtime/test_service_report_guards.py::test_malformed_validate_all_retains_public_validator_findings PASSED [ 50%]
tests/discovery_runtime/test_service_report_guards.py::test_invalid_projection_validation_status_is_refused PASSED [ 60%]
tests/discovery_runtime/test_service_report_guards.py::test_acceptance_preview_preserves_ready_and_pending_selected_views[RG7] PASSED [ 70%]
tests/discovery_runtime/test_service_report_guards.py::test_acceptance_preview_preserves_ready_and_pending_selected_views[RG8] PASSED [ 80%]
tests/discovery_runtime/test_service_report_guards.py::test_acceptance_write_plans_complete_sources_and_selected_views
```
