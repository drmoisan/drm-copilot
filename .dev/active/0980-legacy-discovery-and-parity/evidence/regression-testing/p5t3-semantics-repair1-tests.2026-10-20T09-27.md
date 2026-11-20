# p5t3-semantics-repair1-tests

Timestamp: 2026-10-20T09-27
Command: poetry run pytest tests/discovery_runtime/test_completion_projection.py tests/discovery_runtime/test_validation_modes.py::test_invalid_public_modes_and_unparsed_projection_raise_explicitly tests/discovery_runtime/test_validation_modes.py::test_report_projection_is_recomputed_and_nonrecursive[coverage-report-initialized-root] -o addopts= -v --cov=drm_copilot_discovery.validation --cov=drm_copilot_discovery.validation_operation --cov-config=SCRATCH/issue-980-coverage.ini --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-980-semantic-repair-coverage.json
EXIT_CODE: 0
Output Summary: tests, 179.518s; exact raw streams separately bound.

```text
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0 -- .\.venv\Scripts\python.exe
cachedir: .pytest_cache
rootdir: .
configfile: pyproject.toml
plugins: anyio-4.12.1, cov-7.0.0
collecting ... collected 23 items

tests/discovery_runtime/test_completion_projection.py::test_completion_uses_only_selected_mode_with_trusted_warnings[structural-False] PASSED [  4%]
tests/discovery_runtime/test_completion_projection.py::test_completion_uses_only_selected_mode_with_trusted_warnings[structural-True] PASSED [  8%]
tests/discovery_runtime/test_completion_projection.py::test_completion_uses_only_selected_mode_with_trusted_warnings[discovery-complete-False] PASSED [ 13%]
tests/discovery_runtime/test_completion_projection.py::test_completion_uses_only_selected_mode_with_trusted_warnings[discovery-complete-True] PASSED [ 17%]
tests/discovery_runtime/test_completion_projection.py::test_completion_uses_only_selected_mode_with_trusted_warnings[parity-complete-False] PASSED [ 21%]
tests/discovery_runtime/test_completion_projection.py::test_completion_uses_only_selected_mode_with_trusted_warnings[parity-complete-True] PASSED [ 26%]
tests/discovery_runtime/test_completion_projection.py::test_completion_uses_only_selected_mode_with_trusted_warnings[planning-False] PASSED [ 30%]
tests/discovery_runtime/test_completion_projection.py::test_completion_uses_only_selected_mode_with_trusted_warnings[planning-True] PASSED [ 34%]
tests/discovery_runtime/test_completion_projection.py::test_malformed_completion_retains_diagnostics_without_semantic_assessment[missing-profile] PASSED [ 39%]
tests/discovery_runtime/test_completion_projection.py::test_malformed_completion_retains_diagnostics_without_semantic_assessment[malformed] PASSED [ 43%]
tests/discovery_runtime/test_completion_projection.py::test_malformed_completion_retains_diagnostics_without_semantic_assessment[loader] PASSED [ 47%]
tests/discovery_runtime/test_completion_projection.py::test_completion_recomputation_reuses_assessment_and_rejects_authored_override PASSED [ 52%]
tests/discovery_runtime/test_completion_projection.py::test_completion_preserves_bounded_warning_and_truncation_authority[100] PASSED [ 56%]
tests/discovery_runtime/test_completion_projection.py::test_completion_preserves_bounded_warning_and_truncation_authority[101] PASSED [ 60%]
tests/discovery_runtime/test_completion_projection.py::test_completion_preflight_precedes_input_validation PASSED [ 65%]
tests/discovery_runtime/test_completion_projection.py::test_completion_rejects_unsupported_modes[automatic-False] PASSED [ 69%]
tests/discovery_runtime/test_completion_projection.py::test_completion_rejects_unsupported_modes[automatic-True] PASSED [ 73%]
tests/discovery_runtime/test_completion_projection.py::test_completion_rejects_unsupported_modes[agent-output-False] PASSED [ 78%]
tests/discovery_runtime/test_completion_projection.py::test_completion_rejects_unsupported_modes[agent-output-True] PASSED [ 82%]
tests/discovery_runtime/test_completion_projection.py::test_validation_report_preserves_plain_envelope_and_strict_input_boundary[False] PASSED [ 86%]
tests/discovery_runtime/test_completion_projection.py::test_validation_report_preserves_plain_envelope_and_strict_input_boundary[True] PASSED [ 91%]
tests/discovery_runtime/test_validation_modes.py::test_invalid_public_modes_and_unparsed_projection_raise_explicitly PASSED [ 95%]
tests/discovery_runtime/test_validation_modes.py::test_report_projection_is_recomputed_and_nonrecursive[coverage-report-initialized-root] PASSED [100%]

=============================== tests coverage ================================
______________ coverage: platform win32, python 3.13.12-final-0 _______________

Name                                                                           Stmts   Miss Branch BrPart  Cover   Missing
--------------------------------------------------------------------------------------------------------------------------
packages\discovery-runtime\src\drm_copilot_discovery\validation.py                89     15     44      9    80%   97, 122, 130-137, 154, 156-160, 163, 171, 210, 218-221
packages\discovery-runtime\src\drm_copilot_discovery\validation_operation.py      98      2     22      3    96%   147, 163->208, 278
--------------------------------------------------------------------------------------------------------------------------
TOTAL                                                                            187     17     66     12    88%
Coverage JSON written to file SCRATCH/issue-980-semantic-repair-coverage.json
======================= 23 passed in 177.59s (0:02:57) ========================
```
