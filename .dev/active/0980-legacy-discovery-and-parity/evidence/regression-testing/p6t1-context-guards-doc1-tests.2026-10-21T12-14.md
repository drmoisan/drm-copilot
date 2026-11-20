# P6-T1 core service tests

Timestamp: 2026-10-21T12-13

Command: `WORKSPACE\.venv\Scripts\python.exe -m coverage run --branch --source=drm_copilot_discovery.service,drm_copilot_discovery.operations,drm_copilot_discovery.service_bootstrap -m pytest -v --tb=short --maxfail=1 -o addopts= -p no:cacheprovider tests/discovery_runtime/test_service_context_guards.py`

EXIT_CODE: 0

Output Summary: PASS; 51.706 seconds.

```text
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0 -- WORKSPACE\.venv\Scripts\python.exe
rootdir: WORKSPACE
configfile: pyproject.toml
collecting ... collected 7 items

tests/discovery_runtime/test_service_context_guards.py::test_configured_uncaptured_read_refuses_before_physical_io PASSED [ 14%]
tests/discovery_runtime/test_service_context_guards.py::test_required_read_none_contract_violation_refuses_fabricated_bytes PASSED [ 28%]
tests/discovery_runtime/test_service_context_guards.py::test_naive_trusted_clock_refuses_before_capture_or_publication PASSED [ 42%]
tests/discovery_runtime/test_service_context_guards.py::test_missing_activation_profile_refuses_without_graph_authority PASSED [ 57%]
tests/discovery_runtime/test_service_context_guards.py::test_profile_change_between_selection_and_capture_refuses_publication PASSED [ 71%]
tests/discovery_runtime/test_service_context_guards.py::test_changed_reauthorization_actor_refuses_dispatch_and_writes PASSED [ 85%]
tests/discovery_runtime/test_service_context_guards.py::test_bootstrap_rejects_wrong_operation_family_without_effects PASSED [100%]

============================= 7 passed in 51.12s ==============================

```
