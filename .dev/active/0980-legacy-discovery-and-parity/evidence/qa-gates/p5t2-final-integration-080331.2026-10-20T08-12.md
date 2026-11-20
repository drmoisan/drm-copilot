# P5-T2 final integration

Timestamp: 2026-10-20T08-12
Command: `WORKSPACE\.venv\Scripts\python.exe -u -m pytest -v -o addopts= -p no:cacheprovider tests/discovery_runtime/test_validation_modes.py::test_report_projection_is_recomputed_and_nonrecursive[completion-report-initialized-root] tests/discovery_runtime/test_validation_modes.py::test_invalid_coverage_inputs_retain_original_findings_and_unavailable_counts[loader] tests/discovery_runtime/test_validation_modes.py::test_invalid_coverage_inputs_retain_original_findings_and_unavailable_counts[missing-profile] tests/discovery_runtime/test_validation_modes.py::test_coverage_preserves_requested_mode_and_independent_discovery_results[planning-True] tests/discovery_runtime/test_validation_modes.py::test_coverage_preserves_requested_mode_and_independent_discovery_results[planning-False] tests/discovery_runtime/test_validation_modes.py::test_coverage_preserves_requested_mode_and_independent_discovery_results[discovery-complete-True] tests/discovery_runtime/test_validation_modes.py::test_coverage_preserves_requested_mode_and_independent_discovery_results[discovery-complete-False] tests/discovery_runtime/test_validation_modes.py::test_coverage_preserves_requested_mode_and_independent_discovery_results[structural-True] tests/discovery_runtime/test_validation_modes.py::test_coverage_preserves_requested_mode_and_independent_discovery_results[structural-False] tests/discovery_runtime/test_validation_modes.py::test_invalid_public_modes_and_unparsed_projection_raise_explicitly tests/discovery_runtime/test_parity_report_projection.py::test_unsupported_parity_report_modes_remain_errors[agent-output] tests/discovery_runtime/test_parity_report_projection.py::test_unsupported_parity_report_modes_remain_errors[automatic] tests/discovery_runtime/test_parity_report_projection.py::test_parity_preflight_rejects_excess_before_graph_work tests/discovery_runtime/test_parity_report_projection.py::test_multiple_derived_reports_reuse_one_complete_assessment tests/discovery_runtime/test_parity_report_projection.py::test_authored_parity_fields_cannot_override_recomputed_output[parity_findings] tests/discovery_runtime/test_parity_report_projection.py::test_authored_parity_fields_cannot_override_recomputed_output[parity_result] tests/discovery_runtime/test_parity_report_projection.py::test_authored_parity_fields_cannot_override_recomputed_output[parity] tests/discovery_runtime/test_parity_report_projection.py::test_invalid_core_reports_unavailable_but_never_valid_output[artifact] tests/discovery_runtime/test_parity_report_projection.py::test_invalid_core_reports_unavailable_but_never_valid_output[loader] tests/discovery_runtime/test_parity_report_projection.py::test_invalid_core_reports_unavailable_but_never_valid_output[missing-profile] tests/discovery_runtime/test_parity_report_projection.py::test_requested_mode_and_independent_parity_results[planning-True] tests/discovery_runtime/test_parity_report_projection.py::test_requested_mode_and_independent_parity_results[planning-False] tests/discovery_runtime/test_parity_report_projection.py::test_requested_mode_and_independent_parity_results[parity-complete-True] tests/discovery_runtime/test_parity_report_projection.py::test_requested_mode_and_independent_parity_results[parity-complete-False] tests/discovery_runtime/test_parity_report_projection.py::test_requested_mode_and_independent_parity_results[structural-True] tests/discovery_runtime/test_parity_report_projection.py::test_requested_mode_and_independent_parity_results[structural-False] --cov=drm_copilot_discovery.parity_models --cov=drm_copilot_discovery.parity_rules --cov=drm_copilot_discovery.parity_entry_rules --cov=drm_copilot_discovery.parity_target_rules --cov=drm_copilot_discovery.parity_report --cov=drm_copilot_discovery.parity_metrics --cov=drm_copilot_discovery.report_models --cov=drm_copilot_discovery.validation --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH\p5t2-final-080331-integration-coverage.json`
EXIT_CODE: 0
Output Summary: Stage 6; 308.635 seconds; 26 completed nodes; timeout=False; changed bindings=0.

```text
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0 -- WORKSPACE\.venv\Scripts\python.exe
rootdir: WORKSPACE
configfile: pyproject.toml
plugins: anyio-4.12.1, cov-7.0.0
collecting ... collected 26 items

tests/discovery_runtime/test_validation_modes.py::test_report_projection_is_recomputed_and_nonrecursive[completion-report-initialized-root] PASSED [  3%]
tests/discovery_runtime/test_validation_modes.py::test_invalid_coverage_inputs_retain_original_findings_and_unavailable_counts[loader] PASSED [  7%]
tests/discovery_runtime/test_validation_modes.py::test_invalid_coverage_inputs_retain_original_findings_and_unavailable_counts[missing-profile] PASSED [ 11%]
tests/discovery_runtime/test_validation_modes.py::test_coverage_preserves_requested_mode_and_independent_discovery_results[planning-True] PASSED [ 15%]
tests/discovery_runtime/test_validation_modes.py::test_coverage_preserves_requested_mode_and_independent_discovery_results[planning-False] PASSED [ 19%]
tests/discovery_runtime/test_validation_modes.py::test_coverage_preserves_requested_mode_and_independent_discovery_results[discovery-complete-True] PASSED [ 23%]
tests/discovery_runtime/test_validation_modes.py::test_coverage_preserves_requested_mode_and_independent_discovery_results[discovery-complete-False] PASSED [ 26%]
tests/discovery_runtime/test_validation_modes.py::test_coverage_preserves_requested_mode_and_independent_discovery_results[structural-True] PASSED [ 30%]
tests/discovery_runtime/test_validation_modes.py::test_coverage_preserves_requested_mode_and_independent_discovery_results[structural-False] PASSED [ 34%]
tests/discovery_runtime/test_validation_modes.py::test_invalid_public_modes_and_unparsed_projection_raise_explicitly PASSED [ 38%]
tests/discovery_runtime/test_parity_report_projection.py::test_unsupported_parity_report_modes_remain_errors[agent-output] PASSED [ 42%]
tests/discovery_runtime/test_parity_report_projection.py::test_unsupported_parity_report_modes_remain_errors[automatic] PASSED [ 46%]
tests/discovery_runtime/test_parity_report_projection.py::test_parity_preflight_rejects_excess_before_graph_work PASSED [ 50%]
tests/discovery_runtime/test_parity_report_projection.py::test_multiple_derived_reports_reuse_one_complete_assessment PASSED [ 53%]
tests/discovery_runtime/test_parity_report_projection.py::test_authored_parity_fields_cannot_override_recomputed_output[parity_findings] PASSED [ 57%]
tests/discovery_runtime/test_parity_report_projection.py::test_authored_parity_fields_cannot_override_recomputed_output[parity_result] PASSED [ 61%]
tests/discovery_runtime/test_parity_report_projection.py::test_authored_parity_fields_cannot_override_recomputed_output[parity] PASSED [ 65%]
tests/discovery_runtime/test_parity_report_projection.py::test_invalid_core_reports_unavailable_but_never_valid_output[artifact] PASSED [ 69%]
tests/discovery_runtime/test_parity_report_projection.py::test_invalid_core_reports_unavailable_but_never_valid_output[loader] PASSED [ 73%]
tests/discovery_runtime/test_parity_report_projection.py::test_invalid_core_reports_unavailable_but_never_valid_output[missing-profile] PASSED [ 76%]
tests/discovery_runtime/test_parity_report_projection.py::test_requested_mode_and_independent_parity_results[planning-True] PASSED [ 80%]
tests/discovery_runtime/test_parity_report_projection.py::test_requested_mode_and_independent_parity_results[planning-False] PASSED [ 84%]
tests/discovery_runtime/test_parity_report_projection.py::test_requested_mode_and_independent_parity_results[parity-complete-True] PASSED [ 88%]
tests/discovery_runtime/test_parity_report_projection.py::test_requested_mode_and_independent_parity_results[parity-complete-False] PASSED [ 92%]
tests/discovery_runtime/test_parity_report_projection.py::test_requested_mode_and_independent_parity_results[structural-True] PASSED [ 96%]
tests/discovery_runtime/test_parity_report_projection.py::test_requested_mode_and_independent_parity_results[structural-False] PASSED [100%]

=============================== tests coverage ================================
______________ coverage: platform win32, python 3.13.12-final-0 _______________

Name                                                                          Stmts   Miss Branch BrPart  Cover   Missing
-------------------------------------------------------------------------------------------------------------------------
packages\discovery-runtime\src\drm_copilot_discovery\parity_entry_rules.py      139    103     56      3    21%   53, 102, 114-131, 141-170, 186-232, 241-303, 318-430, 448-453, 463-468
packages\discovery-runtime\src\drm_copilot_discovery\parity_metrics.py          151     96     56      7    33%   50, 117-121, 125-153, 180-279, 298-302, 308-333, 338-355, 362, 372-374
packages\discovery-runtime\src\drm_copilot_discovery\parity_models.py            35      0      0      0   100%
packages\discovery-runtime\src\drm_copilot_discovery\parity_report.py            45     20      8      0    47%   118-122, 131-135, 148-157, 170-173
packages\discovery-runtime\src\drm_copilot_discovery\parity_rules.py            104     58     38      3    37%   89-255, 304, 334-335, 340-342
packages\discovery-runtime\src\drm_copilot_discovery\parity_target_rules.py      99     77     50      0    15%   24-29, 54-55, 69-89, 96-109, 129-165, 169-236, 247-270, 276-286
packages\discovery-runtime\src\drm_copilot_discovery\report_models.py           142     46     64     18    65%   51, 70, 89, 95, 97, 99, 101, 119, 125, 129, 142, 148, 151, 162, 165-168, 172, 203, 222, 265, 275-284, 292-295, 304-309, 321-330, 343-346
packages\discovery-runtime\src\drm_copilot_discovery\validation.py              162      7     56      6    94%   195, 357, 382, 390-397, 423, 431
-------------------------------------------------------------------------------------------------------------------------
TOTAL                                                                           877    407    328     37    48%
Coverage JSON written to file SCRATCH\p5t2-final-080331-integration-coverage.json
======================= 26 passed in 307.35s (0:05:07) ========================

```
