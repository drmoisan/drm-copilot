# P6-T3 installed entry tests

Timestamp: 2026-10-21T17-06

Command: `WORKSPACE\.venv\Scripts\python.exe -m coverage run --branch --source=drm_copilot_discovery.cli -m pytest -v --tb=short --maxfail=1 -o addopts= -p no:cacheprovider tests/discovery_runtime/test_legacy_adapters.py`

EXIT_CODE: 0

Output Summary: PASS; 4.416 seconds.

```text
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0 -- WORKSPACE\.venv\Scripts\python.exe
rootdir: WORKSPACE
configfile: pyproject.toml
collecting ... collected 22 items

tests/discovery_runtime/test_legacy_adapters.py::test_installed_entry_preserves_explicit_arguments_and_process_state[False] PASSED [  4%]
tests/discovery_runtime/test_legacy_adapters.py::test_installed_entry_preserves_explicit_arguments_and_process_state[True] PASSED [  9%]
tests/discovery_runtime/test_legacy_adapters.py::test_installed_entry_default_arguments_preserve_process_vector PASSED [ 13%]
tests/discovery_runtime/test_legacy_adapters.py::test_installed_entry_rejects_explicit_count_before_argument_access PASSED [ 18%]
tests/discovery_runtime/test_legacy_adapters.py::test_unknown_installed_command_refuses_before_provider_access PASSED [ 22%]
tests/discovery_runtime/test_legacy_adapters.py::test_direct_legacy_routes_reach_installed_dispatch_with_original_arguments[profile] PASSED [ 27%]
tests/discovery_runtime/test_legacy_adapters.py::test_direct_legacy_routes_reach_installed_dispatch_with_original_arguments[init] PASSED [ 31%]
tests/discovery_runtime/test_legacy_adapters.py::test_direct_legacy_routes_reach_installed_dispatch_with_original_arguments[inventory] PASSED [ 36%]
tests/discovery_runtime/test_legacy_adapters.py::test_direct_legacy_routes_reach_installed_dispatch_with_original_arguments[dotnet] PASSED [ 40%]
tests/discovery_runtime/test_legacy_adapters.py::test_direct_legacy_routes_reach_installed_dispatch_with_original_arguments[vsto] PASSED [ 45%]
tests/discovery_runtime/test_legacy_adapters.py::test_direct_legacy_routes_reach_installed_dispatch_with_original_arguments[acceptance] PASSED [ 50%]
tests/discovery_runtime/test_legacy_adapters.py::test_report_legacy_routes_retain_bounded_captured_arguments[coverage] PASSED [ 54%]
tests/discovery_runtime/test_legacy_adapters.py::test_report_legacy_routes_retain_bounded_captured_arguments[parity] PASSED [ 59%]
tests/discovery_runtime/test_legacy_adapters.py::test_report_legacy_routes_retain_bounded_captured_arguments[completion] PASSED [ 63%]
tests/discovery_runtime/test_legacy_adapters.py::test_fixed_validator_routes_select_process_tokens_without_mutation[profile] PASSED [ 68%]
tests/discovery_runtime/test_legacy_adapters.py::test_fixed_validator_routes_select_process_tokens_without_mutation[feature] PASSED [ 72%]
tests/discovery_runtime/test_legacy_adapters.py::test_fixed_validator_routes_select_process_tokens_without_mutation[coverage] PASSED [ 77%]
tests/discovery_runtime/test_legacy_adapters.py::test_fixed_validator_routes_select_process_tokens_without_mutation[runtime] PASSED [ 81%]
tests/discovery_runtime/test_legacy_adapters.py::test_fixed_validator_routes_select_process_tokens_without_mutation[parity] PASSED [ 86%]
tests/discovery_runtime/test_legacy_adapters.py::test_fixed_validator_routes_select_process_tokens_without_mutation[unknown] PASSED [ 90%]
tests/discovery_runtime/test_legacy_adapters.py::test_fixed_validator_routes_select_process_tokens_without_mutation[decision] PASSED [ 95%]
tests/discovery_runtime/test_legacy_adapters.py::test_fixed_validator_routes_select_process_tokens_without_mutation[evidence] PASSED [100%]

============================= 22 passed in 3.79s ==============================

```
