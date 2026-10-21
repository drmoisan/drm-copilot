# P6-T1 core service tests

Timestamp: 2026-10-20T16-38

Command: `poetry run coverage run --branch --source=drm_copilot_discovery.service,drm_copilot_discovery.operations,drm_copilot_discovery.service_inspection,drm_copilot_discovery.service_reports,drm_copilot_discovery.service_mutations,drm_copilot_discovery.service_bootstrap -m pytest -v --tb=short --maxfail=8 -o addopts= -p no:cacheprovider @<SCRATCH>\p6t1-core-continuation2-nodes.txt`

EXIT_CODE: 1

Output Summary: FAIL or changed bytes; 1201.913 seconds.

```text
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0 -- <WORKSPACE>\.venv\Scripts\python.exe
rootdir: <WORKSPACE>
configfile: pyproject.toml
collecting ... collected 69 items

tests/discovery_runtime/test_service_publication.py::test_report_preview_and_failed_gate_publication_keep_selected_status[parity-report] PASSED [  1%]
tests/discovery_runtime/test_service_publication.py::test_report_preview_and_failed_gate_publication_keep_selected_status[completion-report] PASSED [  2%]
tests/discovery_runtime/test_service_publication.py::test_pure_report_format_does_not_publish[json] PASSED [  4%]
tests/discovery_runtime/test_service_publication.py::test_pure_report_format_does_not_publish[markdown] PASSED [  5%]
tests/discovery_runtime/test_service_publication.py::test_pure_report_format_does_not_publish[both] PASSED [  7%]
tests/discovery_runtime/test_service_publication.py::test_validate_all_defaults_to_paired_reports_and_rejects_outside_root PASSED [  8%]
tests/discovery_runtime/test_service_publication.py::test_malformed_core_cannot_publish_a_diagnostic_report PASSED [ 10%]
tests/discovery_runtime/test_service_publication.py::test_explicit_bootstrap_preserves_actual_directory_and_file_units[True] PASSED [ 11%]
tests/discovery_runtime/test_service_publication.py::test_explicit_bootstrap_preserves_actual_directory_and_file_units[False] PASSED [ 13%]
tests/discovery_runtime/test_service_publication.py::test_configuration_preserves_protected_effect_accounting[activate] PASSED [ 14%]
tests/discovery_runtime/test_service_publication.py::test_configuration_preserves_protected_effect_accounting[deactivate] PASSED [ 15%]
tests/discovery_runtime/test_service_publication.py::test_scenario_creation_keeps_unknown_expectation_and_unexecuted_state PASSED [ 17%]
tests/discovery_runtime/test_service_publication.py::test_exact_replacement_requires_identity_cas_path_and_explicit_approval[None]

```
