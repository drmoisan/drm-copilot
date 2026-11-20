# P5-T3 final semantic

Timestamp: 2026-10-20T09-57
Command: `WORKSPACE\.venv\Scripts\python.exe -u -m pytest -v -o addopts= -p no:cacheprovider tests/discovery_runtime/test_validation_modes.py::test_report_projection_is_recomputed_and_nonrecursive[coverage-report-initialized-root] tests/discovery_runtime/test_validation_modes.py::test_invalid_public_modes_and_unparsed_projection_raise_explicitly tests/discovery_runtime/test_completion_projection.py::test_validation_report_preserves_plain_envelope_and_strict_input_boundary[True] tests/discovery_runtime/test_completion_projection.py::test_validation_report_preserves_plain_envelope_and_strict_input_boundary[False] tests/discovery_runtime/test_completion_projection.py::test_completion_rejects_unsupported_modes[agent-output-True] tests/discovery_runtime/test_completion_projection.py::test_completion_rejects_unsupported_modes[agent-output-False] tests/discovery_runtime/test_completion_projection.py::test_completion_rejects_unsupported_modes[automatic-True] tests/discovery_runtime/test_completion_projection.py::test_completion_rejects_unsupported_modes[automatic-False] tests/discovery_runtime/test_completion_projection.py::test_completion_preflight_precedes_input_validation tests/discovery_runtime/test_completion_projection.py::test_completion_preserves_bounded_warning_and_truncation_authority[101] tests/discovery_runtime/test_completion_projection.py::test_completion_preserves_bounded_warning_and_truncation_authority[100] tests/discovery_runtime/test_completion_projection.py::test_completion_recomputation_reuses_assessment_and_rejects_authored_override tests/discovery_runtime/test_completion_projection.py::test_malformed_completion_retains_diagnostics_without_semantic_assessment[loader] tests/discovery_runtime/test_completion_projection.py::test_malformed_completion_retains_diagnostics_without_semantic_assessment[malformed] tests/discovery_runtime/test_completion_projection.py::test_malformed_completion_retains_diagnostics_without_semantic_assessment[missing-profile] tests/discovery_runtime/test_completion_projection.py::test_completion_uses_only_selected_mode_with_trusted_warnings[planning-True] tests/discovery_runtime/test_completion_projection.py::test_completion_uses_only_selected_mode_with_trusted_warnings[planning-False] tests/discovery_runtime/test_completion_projection.py::test_completion_uses_only_selected_mode_with_trusted_warnings[parity-complete-True] tests/discovery_runtime/test_completion_projection.py::test_completion_uses_only_selected_mode_with_trusted_warnings[parity-complete-False] tests/discovery_runtime/test_completion_projection.py::test_completion_uses_only_selected_mode_with_trusted_warnings[discovery-complete-True] tests/discovery_runtime/test_completion_projection.py::test_completion_uses_only_selected_mode_with_trusted_warnings[discovery-complete-False] tests/discovery_runtime/test_completion_projection.py::test_completion_uses_only_selected_mode_with_trusted_warnings[structural-True] tests/discovery_runtime/test_completion_projection.py::test_completion_uses_only_selected_mode_with_trusted_warnings[structural-False] --cov=drm_copilot_discovery.completion_report --cov=drm_copilot_discovery.validation --cov=drm_copilot_discovery.validation_operation --cov=drm_copilot_discovery.report_models --cov=drm_copilot_discovery.report_rendering --cov=scripts.dev_tools.discovery.completion_report --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH\p5t3-final-094649-semantic-coverage.json`
EXIT_CODE: 0
Output Summary: Stage 6; 178.39 seconds; 23 completed nodes; timeout=False; changed bindings=0.

```text
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0 -- WORKSPACE\.venv\Scripts\python.exe
rootdir: WORKSPACE
configfile: pyproject.toml
plugins: anyio-4.12.1, cov-7.0.0
collecting ... collected 23 items

tests/discovery_runtime/test_validation_modes.py::test_report_projection_is_recomputed_and_nonrecursive[coverage-report-initialized-root] PASSED [  4%]
tests/discovery_runtime/test_validation_modes.py::test_invalid_public_modes_and_unparsed_projection_raise_explicitly PASSED [  8%]
tests/discovery_runtime/test_completion_projection.py::test_validation_report_preserves_plain_envelope_and_strict_input_boundary[True] PASSED [ 13%]
tests/discovery_runtime/test_completion_projection.py::test_validation_report_preserves_plain_envelope_and_strict_input_boundary[False] PASSED [ 17%]
tests/discovery_runtime/test_completion_projection.py::test_completion_rejects_unsupported_modes[agent-output-True] PASSED [ 21%]
tests/discovery_runtime/test_completion_projection.py::test_completion_rejects_unsupported_modes[agent-output-False] PASSED [ 26%]
tests/discovery_runtime/test_completion_projection.py::test_completion_rejects_unsupported_modes[automatic-True] PASSED [ 30%]
tests/discovery_runtime/test_completion_projection.py::test_completion_rejects_unsupported_modes[automatic-False] PASSED [ 34%]
tests/discovery_runtime/test_completion_projection.py::test_completion_preflight_precedes_input_validation PASSED [ 39%]
tests/discovery_runtime/test_completion_projection.py::test_completion_preserves_bounded_warning_and_truncation_authority[101] PASSED [ 43%]
tests/discovery_runtime/test_completion_projection.py::test_completion_preserves_bounded_warning_and_truncation_authority[100] PASSED [ 47%]
tests/discovery_runtime/test_completion_projection.py::test_completion_recomputation_reuses_assessment_and_rejects_authored_override PASSED [ 52%]
tests/discovery_runtime/test_completion_projection.py::test_malformed_completion_retains_diagnostics_without_semantic_assessment[loader] PASSED [ 56%]
tests/discovery_runtime/test_completion_projection.py::test_malformed_completion_retains_diagnostics_without_semantic_assessment[malformed] PASSED [ 60%]
tests/discovery_runtime/test_completion_projection.py::test_malformed_completion_retains_diagnostics_without_semantic_assessment[missing-profile] PASSED [ 65%]
tests/discovery_runtime/test_completion_projection.py::test_completion_uses_only_selected_mode_with_trusted_warnings[planning-True] PASSED [ 69%]
tests/discovery_runtime/test_completion_projection.py::test_completion_uses_only_selected_mode_with_trusted_warnings[planning-False] PASSED [ 73%]
tests/discovery_runtime/test_completion_projection.py::test_completion_uses_only_selected_mode_with_trusted_warnings[parity-complete-True] PASSED [ 78%]
tests/discovery_runtime/test_completion_projection.py::test_completion_uses_only_selected_mode_with_trusted_warnings[parity-complete-False] PASSED [ 82%]
tests/discovery_runtime/test_completion_projection.py::test_completion_uses_only_selected_mode_with_trusted_warnings[discovery-complete-True] PASSED [ 86%]
tests/discovery_runtime/test_completion_projection.py::test_completion_uses_only_selected_mode_with_trusted_warnings[discovery-complete-False] PASSED [ 91%]
tests/discovery_runtime/test_completion_projection.py::test_completion_uses_only_selected_mode_with_trusted_warnings[structural-True] PASSED [ 95%]
tests/discovery_runtime/test_completion_projection.py::test_completion_uses_only_selected_mode_with_trusted_warnings[structural-False] PASSED [100%]

=============================== tests coverage ================================
______________ coverage: platform win32, python 3.13.12-final-0 _______________

Name                                                                           Stmts   Miss Branch BrPart  Cover   Missing
--------------------------------------------------------------------------------------------------------------------------
packages\discovery-runtime\src\drm_copilot_discovery\completion_report.py         95     30     24      4    65%   40, 73, 106, 122->124, 180-228, 241-243, 257-261
packages\discovery-runtime\src\drm_copilot_discovery\report_models.py            138     42     64     18    66%   51, 70, 89, 95, 97, 99, 101, 119, 125, 129, 142, 148, 151, 162, 165-168, 172, 203, 222, 265, 275-277, 285-288, 297-302, 314-323, 336-339
packages\discovery-runtime\src\drm_copilot_discovery\validation.py                89     15     44      9    80%   97, 122, 130-137, 154, 156-160, 163, 171, 210, 218-221
packages\discovery-runtime\src\drm_copilot_discovery\validation_operation.py      98      2     22      3    96%   147, 163->208, 278
--------------------------------------------------------------------------------------------------------------------------
TOTAL                                                                            420     89    154     34    75%
Coverage JSON written to file SCRATCH\p5t3-final-094649-semantic-coverage.json
======================= 23 passed in 176.87s (0:02:56) ========================
WORKSPACE\.venv\Lib\site-packages\coverage\inorout.py:495: CoverageWarning: Module drm_copilot_discovery.report_rendering was never imported. (module-not-imported); see https://coverage.readthedocs.io/en/7.13.2/messages.html#warning-module-not-imported
  self.warn(f"Module {pkg} was never imported.", slug="module-not-imported")
WORKSPACE\.venv\Lib\site-packages\coverage\inorout.py:495: CoverageWarning: Module scripts.dev_tools.discovery.completion_report was never imported. (module-not-imported); see https://coverage.readthedocs.io/en/7.13.2/messages.html#warning-module-not-imported
  self.warn(f"Module {pkg} was never imported.", slug="module-not-imported")

```
