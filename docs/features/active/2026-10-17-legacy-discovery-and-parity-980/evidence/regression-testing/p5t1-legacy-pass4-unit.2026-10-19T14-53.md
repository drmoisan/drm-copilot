# p5t1-legacy-pass4-unit

Timestamp: 2026-10-19T14-53
Command: poetry run pytest tests/scripts/dev_tools/discovery/test_coverage_report.py tests/scripts/dev_tools/discovery/test_rendering.py -o addopts= -v --cov=scripts.dev_tools.discovery.coverage_report --cov-config=SCRATCH/coverage.ini --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/coverage.json
EXIT_CODE: 0
Output Summary: scoped unit; duration 2.005 seconds. Raw stdout/stderr hashes and SCRATCH-relative locations are separate from sanitized presentation.

```text
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0 -- .\.venv\Scripts\python.exe
cachedir: .pytest_cache
rootdir: .
configfile: pyproject.toml
plugins: anyio-4.12.1, cov-7.0.0
collecting ... collected 37 items

tests/scripts/dev_tools/discovery/test_coverage_report.py::test_build_and_render_coverage_report_sorts_and_counts_entries PASSED [  2%]
tests/scripts/dev_tools/discovery/test_coverage_report.py::test_render_coverage_report_is_deterministic PASSED [  5%]
tests/scripts/dev_tools/discovery/test_coverage_report.py::test_main_returns_1_and_prints_errors_on_validation_failure PASSED [  8%]
tests/scripts/dev_tools/discovery/test_coverage_report.py::test_build_coverage_rows_handles_missing_entries_key PASSED [ 10%]
tests/scripts/dev_tools/discovery/test_coverage_report.py::test_main_returns_0_on_success PASSED [ 13%]
tests/scripts/dev_tools/discovery/test_coverage_report.py::test_main_returns_1_on_failure PASSED [ 16%]
tests/scripts/dev_tools/discovery/test_coverage_report.py::test_main_writes_to_stdout_when_output_omitted PASSED [ 18%]
tests/scripts/dev_tools/discovery/test_coverage_report.py::test_true_v1_preserves_unit_fields_without_completion_claims[1.0.0] PASSED [ 21%]
tests/scripts/dev_tools/discovery/test_coverage_report.py::test_true_v1_preserves_unit_fields_without_completion_claims[1.2.3] PASSED [ 24%]
tests/scripts/dev_tools/discovery/test_coverage_report.py::test_accepted_invalid_text_never_reaches_output[secret malformed text] PASSED [ 27%]
tests/scripts/dev_tools/discovery/test_coverage_report.py::test_accepted_invalid_text_never_reaches_output[null] PASSED [ 29%]
tests/scripts/dev_tools/discovery/test_coverage_report.py::test_accepted_invalid_text_never_reaches_output[[]] PASSED [ 32%]
tests/scripts/dev_tools/discovery/test_coverage_report.py::test_accepted_invalid_text_never_reaches_output[{"entries": null}] PASSED [ 35%]
tests/scripts/dev_tools/discovery/test_coverage_report.py::test_accepted_invalid_text_never_reaches_output[{"entries": {}}] PASSED [ 37%]
tests/scripts/dev_tools/discovery/test_coverage_report.py::test_accepted_invalid_text_never_reaches_output[{"entries": ["secret"]}] PASSED [ 40%]
tests/scripts/dev_tools/discovery/test_coverage_report.py::test_accepted_invalid_text_never_reaches_output[{"entries": [], "entries": []}] PASSED [ 43%]
tests/scripts/dev_tools/discovery/test_coverage_report.py::test_accepted_invalid_text_never_reaches_output[{"entries": [{"secret": NaN}]}] PASSED [ 45%]
tests/scripts/dev_tools/discovery/test_coverage_report.py::test_accepted_invalid_text_never_reaches_output[{"schema_version": "2.0.0", "entries": []}] PASSED [ 48%]
tests/scripts/dev_tools/discovery/test_coverage_report.py::test_accepted_invalid_text_never_reaches_output[{"schema_version": "2.99.0", "entries": []}] PASSED [ 51%]
tests/scripts/dev_tools/discovery/test_coverage_report.py::test_accepted_invalid_text_never_reaches_output[{"schema_version": "unknown", "entries": []}] PASSED [ 54%]
tests/scripts/dev_tools/discovery/test_coverage_report.py::test_helper_value_errors_are_redacted_before_any_output[parse_coverage_ledger] PASSED [ 56%]
tests/scripts/dev_tools/discovery/test_coverage_report.py::test_helper_value_errors_are_redacted_before_any_output[build_coverage_rows] PASSED [ 59%]
tests/scripts/dev_tools/discovery/test_coverage_report.py::test_helper_value_errors_are_redacted_before_any_output[render_coverage_report] PASSED [ 62%]
tests/scripts/dev_tools/discovery/test_coverage_report.py::test_path_and_validator_seams_preserve_call_order PASSED [ 64%]
tests/scripts/dev_tools/discovery/test_coverage_report.py::test_default_validator_and_sys_argv_remain_injectable PASSED [ 67%]
tests/scripts/dev_tools/discovery/test_coverage_report.py::test_missing_input_arguments_fail_before_read[arguments0] PASSED [ 70%]
tests/scripts/dev_tools/discovery/test_coverage_report.py::test_missing_input_arguments_fail_before_read[arguments1] PASSED [ 72%]
tests/scripts/dev_tools/discovery/test_coverage_report.py::test_missing_input_arguments_fail_before_read[arguments2] PASSED [ 75%]
tests/scripts/dev_tools/discovery/test_coverage_report.py::test_io_errors_propagate_without_a_success_report[read_artifact_text] PASSED [ 78%]
tests/scripts/dev_tools/discovery/test_coverage_report.py::test_io_errors_propagate_without_a_success_report[write_report] PASSED [ 81%]
tests/scripts/dev_tools/discovery/test_rendering.py::test_sort_rows_sorts_ascending_by_id_field PASSED [ 83%]
tests/scripts/dev_tools/discovery/test_rendering.py::test_sort_rows_falls_back_to_joined_field_sort_when_id_absent PASSED [ 86%]
tests/scripts/dev_tools/discovery/test_rendering.py::test_sort_rows_falls_back_when_id_field_partially_present PASSED [ 89%]
tests/scripts/dev_tools/discovery/test_rendering.py::test_render_pretty_json_exact_literal_output PASSED [ 91%]
tests/scripts/dev_tools/discovery/test_rendering.py::test_render_pretty_json_is_deterministic PASSED [ 94%]
tests/scripts/dev_tools/discovery/test_rendering.py::test_coverage_adapter_retains_pretty_json_escaping_and_single_lf PASSED [ 97%]
tests/scripts/dev_tools/discovery/test_rendering.py::test_explicit_v1_unit_sort_preserves_rows_and_original_order PASSED [100%]

=============================== tests coverage ================================
______________ coverage: platform win32, python 3.13.12-final-0 _______________

Name                                             Stmts   Miss Branch BrPart  Cover   Missing
--------------------------------------------------------------------------------------------
scripts\dev_tools\discovery\coverage_report.py      38      0      4      0   100%
--------------------------------------------------------------------------------------------
TOTAL                                               38      0      4      0   100%
Coverage JSON written to file SCRATCH/coverage.json
============================= 37 passed in 0.28s ==============================
```
