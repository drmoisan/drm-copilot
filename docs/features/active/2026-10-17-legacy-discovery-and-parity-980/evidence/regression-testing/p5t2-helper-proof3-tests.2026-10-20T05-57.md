# P5-T2 helper-proof3-tests

Timestamp: 2026-10-20T05-57

Command: poetry run pytest -o addopts= -vv tests/scripts/dev_tools/discovery/test_parity_report.py tests/discovery_runtime/test_parity_report.py --cov=drm_copilot_discovery.parity_report --cov=scripts.dev_tools.discovery.parity_report --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/helper-proof3-coverage.json

EXIT_CODE: 0

Output Summary: Exact scoped stage completed in 1.981s; raw bytes are retained in the JSON receipt.

```text
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0 -- WORKSPACE\.venv\Scripts\python.exe
cachedir: .pytest_cache
rootdir: WORKSPACE
configfile: pyproject.toml
plugins: anyio-4.12.1, cov-7.0.0
collecting ... collected 44 items

tests/scripts/dev_tools/discovery/test_parity_report.py::test_build_and_render_parity_report_sorts_and_counts_entries PASSED [  2%]
tests/scripts/dev_tools/discovery/test_parity_report.py::test_render_parity_report_is_deterministic PASSED [  4%]
tests/scripts/dev_tools/discovery/test_parity_report.py::test_main_returns_1_and_prints_errors_on_validation_failure PASSED [  6%]
tests/scripts/dev_tools/discovery/test_parity_report.py::test_build_parity_rows_handles_missing_entries_key PASSED [  9%]
tests/scripts/dev_tools/discovery/test_parity_report.py::test_main_returns_0_on_success PASSED [ 11%]
tests/scripts/dev_tools/discovery/test_parity_report.py::test_main_returns_1_on_failure PASSED [ 13%]
tests/scripts/dev_tools/discovery/test_parity_report.py::test_main_writes_to_stdout_when_output_omitted PASSED [ 15%]
tests/scripts/dev_tools/discovery/test_parity_report.py::test_actual_v1_rows_keep_their_fields_and_feature_order[1.0.0] PASSED [ 18%]
tests/scripts/dev_tools/discovery/test_parity_report.py::test_actual_v1_rows_keep_their_fields_and_feature_order[1.12.34] PASSED [ 20%]
tests/scripts/dev_tools/discovery/test_parity_report.py::test_injected_acceptance_cannot_bypass_safe_compatibility_boundary[{] PASSED [ 22%]
tests/scripts/dev_tools/discovery/test_parity_report.py::test_injected_acceptance_cannot_bypass_safe_compatibility_boundary[[]] PASSED [ 25%]
tests/scripts/dev_tools/discovery/test_parity_report.py::test_injected_acceptance_cannot_bypass_safe_compatibility_boundary[{"entries":null}] PASSED [ 27%]
tests/scripts/dev_tools/discovery/test_parity_report.py::test_injected_acceptance_cannot_bypass_safe_compatibility_boundary[{"entries":[null]}] PASSED [ 29%]
tests/scripts/dev_tools/discovery/test_parity_report.py::test_injected_acceptance_cannot_bypass_safe_compatibility_boundary[{"entries":[],"entries":[]}] PASSED [ 31%]
tests/scripts/dev_tools/discovery/test_parity_report.py::test_injected_acceptance_cannot_bypass_safe_compatibility_boundary[{"entries":[{"score":NaN}]}] PASSED [ 34%]
tests/scripts/dev_tools/discovery/test_parity_report.py::test_injected_acceptance_cannot_bypass_safe_compatibility_boundary[{"schema_version":"2.0.0","entries":[]}] PASSED [ 36%]
tests/scripts/dev_tools/discovery/test_parity_report.py::test_injected_acceptance_cannot_bypass_safe_compatibility_boundary[{"schema_version":"1.bad","rows":[]}] PASSED [ 38%]
tests/scripts/dev_tools/discovery/test_parity_report.py::test_default_validator_uses_existing_lazy_upstream_seam PASSED [ 40%]
tests/scripts/dev_tools/discovery/test_parity_report.py::test_unexpected_boundary_failures_propagate[read] PASSED [ 43%]
tests/scripts/dev_tools/discovery/test_parity_report.py::test_unexpected_boundary_failures_propagate[write] PASSED [ 45%]
tests/scripts/dev_tools/discovery/test_parity_report.py::test_unexpected_boundary_failures_propagate[validator] PASSED [ 47%]
tests/scripts/dev_tools/discovery/test_parity_report.py::test_missing_input_is_an_argument_error PASSED [ 50%]
tests/scripts/dev_tools/discovery/test_parity_report.py::test_helper_rejection_never_writes_partial_report[build] PASSED [ 52%]
tests/scripts/dev_tools/discovery/test_parity_report.py::test_helper_rejection_never_writes_partial_report[render] PASSED [ 54%]
tests/discovery_runtime/test_parity_report.py::test_parsed_and_projected_rows_have_independent_nested_values PASSED [ 56%]
tests/discovery_runtime/test_parity_report.py::test_explicit_non_v1_versions_cannot_establish_compatibility[True] PASSED [ 59%]
tests/discovery_runtime/test_parity_report.py::test_explicit_non_v1_versions_cannot_establish_compatibility[1] PASSED [ 61%]
tests/discovery_runtime/test_parity_report.py::test_explicit_non_v1_versions_cannot_establish_compatibility[2.0.0] PASSED [ 63%]
tests/discovery_runtime/test_parity_report.py::test_explicit_non_v1_versions_cannot_establish_compatibility[1.bad] PASSED [ 65%]
tests/discovery_runtime/test_parity_report.py::test_parsing_failures_use_a_fixed_redacted_message[{"SECRET":] PASSED [ 68%]
tests/discovery_runtime/test_parity_report.py::test_parsing_failures_use_a_fixed_redacted_message[{"SECRET":1,"SECRET":2}] PASSED [ 70%]
tests/discovery_runtime/test_parity_report.py::test_parsing_failures_use_a_fixed_redacted_message[{"SECRET":NaN}] PASSED [ 72%]
tests/discovery_runtime/test_parity_report.py::test_parsing_failures_use_a_fixed_redacted_message[["SECRET"]] PASSED [ 75%]
tests/discovery_runtime/test_parity_report.py::test_row_shape_is_checked_before_returning_any_projection[artifact0] PASSED [ 77%]
tests/discovery_runtime/test_parity_report.py::test_row_shape_is_checked_before_returning_any_projection[artifact1] PASSED [ 79%]
tests/discovery_runtime/test_parity_report.py::test_row_shape_is_checked_before_returning_any_projection[artifact2] PASSED [ 81%]
tests/discovery_runtime/test_parity_report.py::test_row_shape_is_checked_before_returning_any_projection[artifact3] PASSED [ 84%]
tests/discovery_runtime/test_parity_report.py::test_rendering_rejects_non_json_values_before_encoding[value0-JSON-compatible] PASSED [ 86%]
tests/discovery_runtime/test_parity_report.py::test_rendering_rejects_non_json_values_before_encoding[nan-finite] PASSED [ 88%]
tests/discovery_runtime/test_parity_report.py::test_rendering_rejects_non_json_values_before_encoding[\ud800-invalid Unicode] PASSED [ 90%]
tests/discovery_runtime/test_parity_report.py::test_build_rejects_excess_before_detaching_any_rows PASSED [ 93%]
tests/discovery_runtime/test_parity_report.py::test_pretty_render_budget_accounts_for_unicode_and_escape_expansion[\xe9] PASSED [ 95%]
tests/discovery_runtime/test_parity_report.py::test_pretty_render_budget_accounts_for_unicode_and_escape_expansion[\U0001f600] PASSED [ 97%]
tests/discovery_runtime/test_parity_report.py::test_pretty_render_budget_accounts_for_unicode_and_escape_expansion[\x01] PASSED [100%]

=============================== tests coverage ================================
______________ coverage: platform win32, python 3.13.12-final-0 _______________

Name                                                                    Stmts   Miss Branch BrPart  Cover   Missing
-------------------------------------------------------------------------------------------------------------------
packages\discovery-runtime\src\drm_copilot_discovery\parity_report.py      31      0      8      0   100%
scripts\dev_tools\discovery\parity_report.py                               38      0      4      0   100%
-------------------------------------------------------------------------------------------------------------------
TOTAL                                                                      69      0     12      0   100%
Coverage JSON written to file SCRATCH/helper-proof3-coverage.json
============================= 44 passed in 0.28s ==============================
```
