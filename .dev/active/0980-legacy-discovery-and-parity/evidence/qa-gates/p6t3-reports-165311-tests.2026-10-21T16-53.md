# P6-T3 compatibility subset tests

Timestamp: 2026-10-21T16-53

Command: `WORKSPACE\.venv\Scripts\python.exe -u -m pytest -v --tb=short --maxfail=0 -o addopts= -p no:cacheprovider -p pytest_cov --cov=scripts.dev_tools.discovery.coverage_report --cov=scripts.dev_tools.discovery.parity_report --cov=scripts.dev_tools.discovery.completion_report --cov-branch -p p6t1_failure_reports --cov-report=term-missing --cov-report=json:SCRATCH\p6t3-reports-165311-tests-coverage.json tests/scripts/dev_tools/discovery/test_coverage_report.py tests/scripts/dev_tools/discovery/test_parity_report.py tests/scripts/dev_tools/discovery/test_completion_report.py`

EXIT_CODE: 0

Output Summary: PASS; 1.213 seconds; 97 passed nodes.

```text
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0 -- WORKSPACE\.venv\Scripts\python.exe
rootdir: WORKSPACE
configfile: pyproject.toml
plugins: cov-7.0.0
collecting ... collected 97 items

tests/scripts/dev_tools/discovery/test_coverage_report.py::test_build_and_render_coverage_report_sorts_and_counts_entries PASSED [  1%]
tests/scripts/dev_tools/discovery/test_coverage_report.py::test_render_coverage_report_is_deterministic PASSED [  2%]
tests/scripts/dev_tools/discovery/test_coverage_report.py::test_main_returns_1_and_prints_errors_on_validation_failure PASSED [  3%]
tests/scripts/dev_tools/discovery/test_coverage_report.py::test_build_coverage_rows_handles_missing_entries_key PASSED [  4%]
tests/scripts/dev_tools/discovery/test_coverage_report.py::test_main_returns_0_on_success PASSED [  5%]
tests/scripts/dev_tools/discovery/test_coverage_report.py::test_main_returns_1_on_failure PASSED [  6%]
tests/scripts/dev_tools/discovery/test_coverage_report.py::test_main_writes_to_stdout_when_output_omitted PASSED [  7%]
tests/scripts/dev_tools/discovery/test_coverage_report.py::test_true_v1_preserves_unit_fields_without_completion_claims[1.0.0] PASSED [  8%]
tests/scripts/dev_tools/discovery/test_coverage_report.py::test_true_v1_preserves_unit_fields_without_completion_claims[1.2.3] PASSED [  9%]
tests/scripts/dev_tools/discovery/test_coverage_report.py::test_accepted_invalid_text_never_reaches_output[secret malformed text] PASSED [ 10%]
tests/scripts/dev_tools/discovery/test_coverage_report.py::test_accepted_invalid_text_never_reaches_output[null] PASSED [ 11%]
tests/scripts/dev_tools/discovery/test_coverage_report.py::test_accepted_invalid_text_never_reaches_output[[]] PASSED [ 12%]
tests/scripts/dev_tools/discovery/test_coverage_report.py::test_accepted_invalid_text_never_reaches_output[{"entries": null}] PASSED [ 13%]
tests/scripts/dev_tools/discovery/test_coverage_report.py::test_accepted_invalid_text_never_reaches_output[{"entries": {}}] PASSED [ 14%]
tests/scripts/dev_tools/discovery/test_coverage_report.py::test_accepted_invalid_text_never_reaches_output[{"entries": ["secret"]}] PASSED [ 15%]
tests/scripts/dev_tools/discovery/test_coverage_report.py::test_accepted_invalid_text_never_reaches_output[{"entries": [], "entries": []}] PASSED [ 16%]
tests/scripts/dev_tools/discovery/test_coverage_report.py::test_accepted_invalid_text_never_reaches_output[{"entries": [{"secret": NaN}]}] PASSED [ 17%]
tests/scripts/dev_tools/discovery/test_coverage_report.py::test_accepted_invalid_text_never_reaches_output[{"schema_version": "2.0.0", "entries": []}] PASSED [ 18%]
tests/scripts/dev_tools/discovery/test_coverage_report.py::test_accepted_invalid_text_never_reaches_output[{"schema_version": "2.99.0", "entries": []}] PASSED [ 19%]
tests/scripts/dev_tools/discovery/test_coverage_report.py::test_accepted_invalid_text_never_reaches_output[{"schema_version": "unknown", "entries": []}] PASSED [ 20%]
tests/scripts/dev_tools/discovery/test_coverage_report.py::test_helper_value_errors_are_redacted_before_any_output[parse_coverage_ledger] PASSED [ 21%]
tests/scripts/dev_tools/discovery/test_coverage_report.py::test_helper_value_errors_are_redacted_before_any_output[build_coverage_rows] PASSED [ 22%]
tests/scripts/dev_tools/discovery/test_coverage_report.py::test_helper_value_errors_are_redacted_before_any_output[render_coverage_report] PASSED [ 23%]
tests/scripts/dev_tools/discovery/test_coverage_report.py::test_path_and_validator_seams_preserve_call_order PASSED [ 24%]
tests/scripts/dev_tools/discovery/test_coverage_report.py::test_default_validator_and_sys_argv_remain_injectable PASSED [ 25%]
tests/scripts/dev_tools/discovery/test_coverage_report.py::test_missing_input_arguments_fail_before_read[arguments0] PASSED [ 26%]
tests/scripts/dev_tools/discovery/test_coverage_report.py::test_missing_input_arguments_fail_before_read[arguments1] PASSED [ 27%]
tests/scripts/dev_tools/discovery/test_coverage_report.py::test_missing_input_arguments_fail_before_read[arguments2] PASSED [ 28%]
tests/scripts/dev_tools/discovery/test_coverage_report.py::test_io_errors_propagate_without_a_success_report[read_artifact_text] PASSED [ 29%]
tests/scripts/dev_tools/discovery/test_coverage_report.py::test_io_errors_propagate_without_a_success_report[write_report] PASSED [ 30%]
tests/scripts/dev_tools/discovery/test_coverage_report.py::test_workspace_route_forwards_exact_command_and_exit[False] PASSED [ 31%]
tests/scripts/dev_tools/discovery/test_coverage_report.py::test_workspace_route_forwards_exact_command_and_exit[True] PASSED [ 32%]
tests/scripts/dev_tools/discovery/test_coverage_report.py::test_workspace_refusal_precedes_every_callback[mixed] PASSED [ 34%]
tests/scripts/dev_tools/discovery/test_coverage_report.py::test_workspace_refusal_precedes_every_callback[injected] PASSED [ 35%]
tests/scripts/dev_tools/discovery/test_coverage_report.py::test_workspace_refusal_precedes_every_callback[invalid] PASSED [ 36%]
tests/scripts/dev_tools/discovery/test_parity_report.py::test_build_and_render_parity_report_sorts_and_counts_entries PASSED [ 37%]
tests/scripts/dev_tools/discovery/test_parity_report.py::test_render_parity_report_is_deterministic PASSED [ 38%]
tests/scripts/dev_tools/discovery/test_parity_report.py::test_main_returns_1_and_prints_errors_on_validation_failure PASSED [ 39%]
tests/scripts/dev_tools/discovery/test_parity_report.py::test_build_parity_rows_handles_missing_entries_key PASSED [ 40%]
tests/scripts/dev_tools/discovery/test_parity_report.py::test_main_returns_0_on_success PASSED [ 41%]
tests/scripts/dev_tools/discovery/test_parity_report.py::test_main_returns_1_on_failure PASSED [ 42%]
tests/scripts/dev_tools/discovery/test_parity_report.py::test_main_writes_to_stdout_when_output_omitted PASSED [ 43%]
tests/scripts/dev_tools/discovery/test_parity_report.py::test_actual_v1_rows_keep_their_fields_and_feature_order[1.0.0] PASSED [ 44%]
tests/scripts/dev_tools/discovery/test_parity_report.py::test_actual_v1_rows_keep_their_fields_and_feature_order[1.12.34] PASSED [ 45%]
tests/scripts/dev_tools/discovery/test_parity_report.py::test_injected_acceptance_cannot_bypass_safe_compatibility_boundary[{] PASSED [ 46%]
tests/scripts/dev_tools/discovery/test_parity_report.py::test_injected_acceptance_cannot_bypass_safe_compatibility_boundary[[]] PASSED [ 47%]
tests/scripts/dev_tools/discovery/test_parity_report.py::test_injected_acceptance_cannot_bypass_safe_compatibility_boundary[{"entries":null}] PASSED [ 48%]
tests/scripts/dev_tools/discovery/test_parity_report.py::test_injected_acceptance_cannot_bypass_safe_compatibility_boundary[{"entries":[null]}] PASSED [ 49%]
tests/scripts/dev_tools/discovery/test_parity_report.py::test_injected_acceptance_cannot_bypass_safe_compatibility_boundary[{"entries":[],"entries":[]}] PASSED [ 50%]
tests/scripts/dev_tools/discovery/test_parity_report.py::test_injected_acceptance_cannot_bypass_safe_compatibility_boundary[{"entries":[{"score":NaN}]}] PASSED [ 51%]
tests/scripts/dev_tools/discovery/test_parity_report.py::test_injected_acceptance_cannot_bypass_safe_compatibility_boundary[{"schema_version":"2.0.0","entries":[]}] PASSED [ 52%]
tests/scripts/dev_tools/discovery/test_parity_report.py::test_injected_acceptance_cannot_bypass_safe_compatibility_boundary[{"schema_version":"1.bad","rows":[]}] PASSED [ 53%]
tests/scripts/dev_tools/discovery/test_parity_report.py::test_default_validator_uses_existing_lazy_upstream_seam PASSED [ 54%]
tests/scripts/dev_tools/discovery/test_parity_report.py::test_unexpected_boundary_failures_propagate[read] PASSED [ 55%]
tests/scripts/dev_tools/discovery/test_parity_report.py::test_unexpected_boundary_failures_propagate[write] PASSED [ 56%]
tests/scripts/dev_tools/discovery/test_parity_report.py::test_unexpected_boundary_failures_propagate[validator] PASSED [ 57%]
tests/scripts/dev_tools/discovery/test_parity_report.py::test_missing_input_is_an_argument_error PASSED [ 58%]
tests/scripts/dev_tools/discovery/test_parity_report.py::test_helper_rejection_never_writes_partial_report[build] PASSED [ 59%]
tests/scripts/dev_tools/discovery/test_parity_report.py::test_helper_rejection_never_writes_partial_report[render] PASSED [ 60%]
tests/scripts/dev_tools/discovery/test_parity_report.py::test_workspace_route_forwards_exact_command_and_exit[False] PASSED [ 61%]
tests/scripts/dev_tools/discovery/test_parity_report.py::test_workspace_route_forwards_exact_command_and_exit[True] PASSED [ 62%]
tests/scripts/dev_tools/discovery/test_parity_report.py::test_workspace_refusal_precedes_every_callback[mixed] PASSED [ 63%]
tests/scripts/dev_tools/discovery/test_parity_report.py::test_workspace_refusal_precedes_every_callback[injected] PASSED [ 64%]
tests/scripts/dev_tools/discovery/test_parity_report.py::test_workspace_refusal_precedes_every_callback[invalid] PASSED [ 65%]
tests/scripts/dev_tools/discovery/test_completion_report.py::test_build_completion_summary_reports_entry_counts_and_compatibility PASSED [ 67%]
tests/scripts/dev_tools/discovery/test_completion_report.py::test_render_completion_report_is_deterministic PASSED [ 68%]
tests/scripts/dev_tools/discovery/test_completion_report.py::test_main_returns_1_on_coverage_validation_failure_and_skips_build PASSED [ 69%]
tests/scripts/dev_tools/discovery/test_completion_report.py::test_build_completion_summary_handles_missing_entries_key PASSED [ 70%]
tests/scripts/dev_tools/discovery/test_completion_report.py::test_main_returns_0_when_both_validators_pass PASSED [ 71%]
tests/scripts/dev_tools/discovery/test_completion_report.py::test_main_returns_1_when_either_validator_fails PASSED [ 72%]
tests/scripts/dev_tools/discovery/test_completion_report.py::test_main_writes_to_stdout_when_output_omitted PASSED [ 73%]
tests/scripts/dev_tools/discovery/test_completion_report.py::test_injected_acceptance_cannot_bypass_strict_runtime_checks[{"schema_version":2,"entries":[]}-coverage] PASSED [ 74%]
tests/scripts/dev_tools/discovery/test_completion_report.py::test_injected_acceptance_cannot_bypass_strict_runtime_checks[{"schema_version":2,"entries":[]}-parity] PASSED [ 75%]
tests/scripts/dev_tools/discovery/test_completion_report.py::test_injected_acceptance_cannot_bypass_strict_runtime_checks[{"entries":[],"entries":[{"id":"secret-token"}]}-coverage] PASSED [ 76%]
tests/scripts/dev_tools/discovery/test_completion_report.py::test_injected_acceptance_cannot_bypass_strict_runtime_checks[{"entries":[],"entries":[{"id":"secret-token"}]}-parity] PASSED [ 77%]
tests/scripts/dev_tools/discovery/test_completion_report.py::test_injected_acceptance_cannot_bypass_strict_runtime_checks[{"entries":NaN}-coverage] PASSED [ 78%]
tests/scripts/dev_tools/discovery/test_completion_report.py::test_injected_acceptance_cannot_bypass_strict_runtime_checks[{"entries":NaN}-parity] PASSED [ 79%]
tests/scripts/dev_tools/discovery/test_completion_report.py::test_injected_acceptance_cannot_bypass_strict_runtime_checks[{"entries":"secret-token"}-coverage] PASSED [ 80%]
tests/scripts/dev_tools/discovery/test_completion_report.py::test_injected_acceptance_cannot_bypass_strict_runtime_checks[{"entries":"secret-token"}-parity] PASSED [ 81%]
tests/scripts/dev_tools/discovery/test_completion_report.py::test_injected_acceptance_cannot_bypass_strict_runtime_checks[["secret-token"]-coverage] PASSED [ 82%]
tests/scripts/dev_tools/discovery/test_completion_report.py::test_injected_acceptance_cannot_bypass_strict_runtime_checks[["secret-token"]-parity] PASSED [ 83%]
tests/scripts/dev_tools/discovery/test_completion_report.py::test_injected_acceptance_cannot_bypass_strict_runtime_checks[secret-token is not JSON-coverage] PASSED [ 84%]
tests/scripts/dev_tools/discovery/test_completion_report.py::test_injected_acceptance_cannot_bypass_strict_runtime_checks[secret-token is not JSON-parity] PASSED [ 85%]
tests/scripts/dev_tools/discovery/test_completion_report.py::test_default_validator_bindings_preserve_both_diagnostics PASSED [ 86%]
tests/scripts/dev_tools/discovery/test_completion_report.py::test_none_arguments_use_process_argument_seam PASSED [ 87%]
tests/scripts/dev_tools/discovery/test_completion_report.py::test_missing_required_arguments_fail_before_io[arguments0] PASSED [ 88%]
tests/scripts/dev_tools/discovery/test_completion_report.py::test_missing_required_arguments_fail_before_io[arguments1] PASSED [ 89%]
tests/scripts/dev_tools/discovery/test_completion_report.py::test_missing_required_arguments_fail_before_io[arguments2] PASSED [ 90%]
tests/scripts/dev_tools/discovery/test_completion_report.py::test_unexpected_boundary_errors_propagate_without_conversion[read] PASSED [ 91%]
tests/scripts/dev_tools/discovery/test_completion_report.py::test_unexpected_boundary_errors_propagate_without_conversion[validator] PASSED [ 92%]
tests/scripts/dev_tools/discovery/test_completion_report.py::test_unexpected_boundary_errors_propagate_without_conversion[write] PASSED [ 93%]
tests/scripts/dev_tools/discovery/test_completion_report.py::test_workspace_route_forwards_exact_command_and_exit[False] PASSED [ 94%]
tests/scripts/dev_tools/discovery/test_completion_report.py::test_workspace_route_forwards_exact_command_and_exit[True] PASSED [ 95%]
tests/scripts/dev_tools/discovery/test_completion_report.py::test_workspace_refusal_precedes_every_callback[mixed] PASSED [ 96%]
tests/scripts/dev_tools/discovery/test_completion_report.py::test_workspace_refusal_precedes_every_callback[coverage] PASSED [ 97%]
tests/scripts/dev_tools/discovery/test_completion_report.py::test_workspace_refusal_precedes_every_callback[parity] PASSED [ 98%]
tests/scripts/dev_tools/discovery/test_completion_report.py::test_workspace_refusal_precedes_every_callback[invalid] PASSED [100%]

=============================== tests coverage ================================
______________ coverage: platform win32, python 3.13.12-final-0 _______________

Name                                               Stmts   Miss Branch BrPart  Cover   Missing
----------------------------------------------------------------------------------------------
scripts\dev_tools\discovery\completion_report.py      65      0     10      0   100%
scripts\dev_tools\discovery\coverage_report.py        50      0      8      0   100%
scripts\dev_tools\discovery\parity_report.py          50      0      8      0   100%
----------------------------------------------------------------------------------------------
TOTAL                                                165      0     26      0   100%
Coverage JSON written to file SCRATCH\p6t3-reports-165311-tests-coverage.json
============================= 97 passed in 0.54s ==============================

```
