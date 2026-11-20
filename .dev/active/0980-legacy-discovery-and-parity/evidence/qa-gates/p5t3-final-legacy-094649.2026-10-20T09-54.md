# P5-T3 final legacy

Timestamp: 2026-10-20T09-54
Command: `WORKSPACE\.venv\Scripts\python.exe -u -m pytest -v -o addopts= -p no:cacheprovider tests/scripts/dev_tools/discovery/test_io.py::test_write_report_calls_write_text_with_exact_content tests/scripts/dev_tools/discovery/test_io.py::test_read_artifact_text_returns_stubbed_text tests/scripts/dev_tools/discovery/test_io.py::test_validate_or_raise_raises_with_errors tests/scripts/dev_tools/discovery/test_io.py::test_validate_or_raise_passes_with_no_errors tests/scripts/dev_tools/discovery/test_completion_report.py::test_unexpected_boundary_errors_propagate_without_conversion[write] tests/scripts/dev_tools/discovery/test_completion_report.py::test_unexpected_boundary_errors_propagate_without_conversion[validator] tests/scripts/dev_tools/discovery/test_completion_report.py::test_unexpected_boundary_errors_propagate_without_conversion[read] tests/scripts/dev_tools/discovery/test_completion_report.py::test_missing_required_arguments_fail_before_io[arguments2] tests/scripts/dev_tools/discovery/test_completion_report.py::test_missing_required_arguments_fail_before_io[arguments1] tests/scripts/dev_tools/discovery/test_completion_report.py::test_missing_required_arguments_fail_before_io[arguments0] tests/scripts/dev_tools/discovery/test_completion_report.py::test_none_arguments_use_process_argument_seam tests/scripts/dev_tools/discovery/test_completion_report.py::test_default_validator_bindings_preserve_both_diagnostics "tests/scripts/dev_tools/discovery/test_completion_report.py::test_injected_acceptance_cannot_bypass_strict_runtime_checks[secret-token is not JSON-parity]" "tests/scripts/dev_tools/discovery/test_completion_report.py::test_injected_acceptance_cannot_bypass_strict_runtime_checks[secret-token is not JSON-coverage]" tests/scripts/dev_tools/discovery/test_completion_report.py::test_injected_acceptance_cannot_bypass_strict_runtime_checks[[\"secret-token\"]-parity] tests/scripts/dev_tools/discovery/test_completion_report.py::test_injected_acceptance_cannot_bypass_strict_runtime_checks[[\"secret-token\"]-coverage] tests/scripts/dev_tools/discovery/test_completion_report.py::test_injected_acceptance_cannot_bypass_strict_runtime_checks[{\"entries\":\"secret-token\"}-parity] tests/scripts/dev_tools/discovery/test_completion_report.py::test_injected_acceptance_cannot_bypass_strict_runtime_checks[{\"entries\":\"secret-token\"}-coverage] tests/scripts/dev_tools/discovery/test_completion_report.py::test_injected_acceptance_cannot_bypass_strict_runtime_checks[{\"entries\":NaN}-parity] tests/scripts/dev_tools/discovery/test_completion_report.py::test_injected_acceptance_cannot_bypass_strict_runtime_checks[{\"entries\":NaN}-coverage] tests/scripts/dev_tools/discovery/test_completion_report.py::test_injected_acceptance_cannot_bypass_strict_runtime_checks[{\"entries\":[],\"entries\":[{\"id\":\"secret-token\"}]}-parity] tests/scripts/dev_tools/discovery/test_completion_report.py::test_injected_acceptance_cannot_bypass_strict_runtime_checks[{\"entries\":[],\"entries\":[{\"id\":\"secret-token\"}]}-coverage] tests/scripts/dev_tools/discovery/test_completion_report.py::test_injected_acceptance_cannot_bypass_strict_runtime_checks[{\"schema_version\":2,\"entries\":[]}-parity] tests/scripts/dev_tools/discovery/test_completion_report.py::test_injected_acceptance_cannot_bypass_strict_runtime_checks[{\"schema_version\":2,\"entries\":[]}-coverage] tests/scripts/dev_tools/discovery/test_completion_report.py::test_main_writes_to_stdout_when_output_omitted tests/scripts/dev_tools/discovery/test_completion_report.py::test_main_returns_1_when_either_validator_fails tests/scripts/dev_tools/discovery/test_completion_report.py::test_main_returns_0_when_both_validators_pass tests/scripts/dev_tools/discovery/test_completion_report.py::test_build_completion_summary_handles_missing_entries_key tests/scripts/dev_tools/discovery/test_completion_report.py::test_main_returns_1_on_coverage_validation_failure_and_skips_build tests/scripts/dev_tools/discovery/test_completion_report.py::test_render_completion_report_is_deterministic tests/scripts/dev_tools/discovery/test_completion_report.py::test_build_completion_summary_reports_entry_counts_and_compatibility --cov=drm_copilot_discovery.completion_report --cov=drm_copilot_discovery.validation --cov=drm_copilot_discovery.validation_operation --cov=drm_copilot_discovery.report_models --cov=drm_copilot_discovery.report_rendering --cov=scripts.dev_tools.discovery.completion_report --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH\p5t3-final-094649-legacy-coverage.json`
EXIT_CODE: 0
Output Summary: Stage 6; 2.019 seconds; 31 completed nodes; timeout=False; changed bindings=0.

```text
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0 -- WORKSPACE\.venv\Scripts\python.exe
rootdir: WORKSPACE
configfile: pyproject.toml
plugins: anyio-4.12.1, cov-7.0.0
collecting ... collected 31 items

tests/scripts/dev_tools/discovery/test_io.py::test_write_report_calls_write_text_with_exact_content PASSED [  3%]
tests/scripts/dev_tools/discovery/test_io.py::test_read_artifact_text_returns_stubbed_text PASSED [  6%]
tests/scripts/dev_tools/discovery/test_io.py::test_validate_or_raise_raises_with_errors PASSED [  9%]
tests/scripts/dev_tools/discovery/test_io.py::test_validate_or_raise_passes_with_no_errors PASSED [ 12%]
tests/scripts/dev_tools/discovery/test_completion_report.py::test_unexpected_boundary_errors_propagate_without_conversion[write] PASSED [ 16%]
tests/scripts/dev_tools/discovery/test_completion_report.py::test_unexpected_boundary_errors_propagate_without_conversion[validator] PASSED [ 19%]
tests/scripts/dev_tools/discovery/test_completion_report.py::test_unexpected_boundary_errors_propagate_without_conversion[read] PASSED [ 22%]
tests/scripts/dev_tools/discovery/test_completion_report.py::test_missing_required_arguments_fail_before_io[arguments2] PASSED [ 25%]
tests/scripts/dev_tools/discovery/test_completion_report.py::test_missing_required_arguments_fail_before_io[arguments1] PASSED [ 29%]
tests/scripts/dev_tools/discovery/test_completion_report.py::test_missing_required_arguments_fail_before_io[arguments0] PASSED [ 32%]
tests/scripts/dev_tools/discovery/test_completion_report.py::test_none_arguments_use_process_argument_seam PASSED [ 35%]
tests/scripts/dev_tools/discovery/test_completion_report.py::test_default_validator_bindings_preserve_both_diagnostics PASSED [ 38%]
tests/scripts/dev_tools/discovery/test_completion_report.py::test_injected_acceptance_cannot_bypass_strict_runtime_checks[secret-token is not JSON-parity] PASSED [ 41%]
tests/scripts/dev_tools/discovery/test_completion_report.py::test_injected_acceptance_cannot_bypass_strict_runtime_checks[secret-token is not JSON-coverage] PASSED [ 45%]
tests/scripts/dev_tools/discovery/test_completion_report.py::test_injected_acceptance_cannot_bypass_strict_runtime_checks[["secret-token"]-parity] PASSED [ 48%]
tests/scripts/dev_tools/discovery/test_completion_report.py::test_injected_acceptance_cannot_bypass_strict_runtime_checks[["secret-token"]-coverage] PASSED [ 51%]
tests/scripts/dev_tools/discovery/test_completion_report.py::test_injected_acceptance_cannot_bypass_strict_runtime_checks[{"entries":"secret-token"}-parity] PASSED [ 54%]
tests/scripts/dev_tools/discovery/test_completion_report.py::test_injected_acceptance_cannot_bypass_strict_runtime_checks[{"entries":"secret-token"}-coverage] PASSED [ 58%]
tests/scripts/dev_tools/discovery/test_completion_report.py::test_injected_acceptance_cannot_bypass_strict_runtime_checks[{"entries":NaN}-parity] PASSED [ 61%]
tests/scripts/dev_tools/discovery/test_completion_report.py::test_injected_acceptance_cannot_bypass_strict_runtime_checks[{"entries":NaN}-coverage] PASSED [ 64%]
tests/scripts/dev_tools/discovery/test_completion_report.py::test_injected_acceptance_cannot_bypass_strict_runtime_checks[{"entries":[],"entries":[{"id":"secret-token"}]}-parity] PASSED [ 67%]
tests/scripts/dev_tools/discovery/test_completion_report.py::test_injected_acceptance_cannot_bypass_strict_runtime_checks[{"entries":[],"entries":[{"id":"secret-token"}]}-coverage] PASSED [ 70%]
tests/scripts/dev_tools/discovery/test_completion_report.py::test_injected_acceptance_cannot_bypass_strict_runtime_checks[{"schema_version":2,"entries":[]}-parity] PASSED [ 74%]
tests/scripts/dev_tools/discovery/test_completion_report.py::test_injected_acceptance_cannot_bypass_strict_runtime_checks[{"schema_version":2,"entries":[]}-coverage] PASSED [ 77%]
tests/scripts/dev_tools/discovery/test_completion_report.py::test_main_writes_to_stdout_when_output_omitted PASSED [ 80%]
tests/scripts/dev_tools/discovery/test_completion_report.py::test_main_returns_1_when_either_validator_fails PASSED [ 83%]
tests/scripts/dev_tools/discovery/test_completion_report.py::test_main_returns_0_when_both_validators_pass PASSED [ 87%]
tests/scripts/dev_tools/discovery/test_completion_report.py::test_build_completion_summary_handles_missing_entries_key PASSED [ 90%]
tests/scripts/dev_tools/discovery/test_completion_report.py::test_main_returns_1_on_coverage_validation_failure_and_skips_build PASSED [ 93%]
tests/scripts/dev_tools/discovery/test_completion_report.py::test_render_completion_report_is_deterministic PASSED [ 96%]
tests/scripts/dev_tools/discovery/test_completion_report.py::test_build_completion_summary_reports_entry_counts_and_compatibility PASSED [100%]

=============================== tests coverage ================================
______________ coverage: platform win32, python 3.13.12-final-0 _______________

Name                                                                        Stmts   Miss Branch BrPart  Cover   Missing
-----------------------------------------------------------------------------------------------------------------------
packages\discovery-runtime\src\drm_copilot_discovery\completion_report.py      95     71     24      1    21%   39-41, 51, 71-134, 151-159, 180-228, 259
packages\discovery-runtime\src\drm_copilot_discovery\report_models.py         138     34     64     16    72%   30, 51, 69-71, 79, 89, 95, 97, 99, 101, 119, 125, 142, 148, 151, 162, 165-168, 172, 203, 214-223, 255, 261, 265, 275-277, 336-339
scripts\dev_tools\discovery\completion_report.py                               53      0      6      0   100%
-----------------------------------------------------------------------------------------------------------------------
TOTAL                                                                         286    105     94     17    61%
Coverage JSON written to file SCRATCH\p5t3-final-094649-legacy-coverage.json
============================= 31 passed in 0.46s ==============================
WORKSPACE\.venv\Lib\site-packages\coverage\inorout.py:495: CoverageWarning: Module drm_copilot_discovery.validation was never imported. (module-not-imported); see https://coverage.readthedocs.io/en/7.13.2/messages.html#warning-module-not-imported
  self.warn(f"Module {pkg} was never imported.", slug="module-not-imported")
WORKSPACE\.venv\Lib\site-packages\coverage\inorout.py:495: CoverageWarning: Module drm_copilot_discovery.validation_operation was never imported. (module-not-imported); see https://coverage.readthedocs.io/en/7.13.2/messages.html#warning-module-not-imported
  self.warn(f"Module {pkg} was never imported.", slug="module-not-imported")
WORKSPACE\.venv\Lib\site-packages\coverage\inorout.py:495: CoverageWarning: Module drm_copilot_discovery.report_rendering was never imported. (module-not-imported); see https://coverage.readthedocs.io/en/7.13.2/messages.html#warning-module-not-imported
  self.warn(f"Module {pkg} was never imported.", slug="module-not-imported")

```
