# p5t3-semantics-repair1-precheck

Timestamp: 2026-10-20T09-23
Command: poetry run pytest tests/discovery_runtime/test_completion_projection.py::test_malformed_completion_retains_diagnostics_without_semantic_assessment tests/discovery_runtime/test_completion_projection.py::test_validation_report_preserves_plain_envelope_and_strict_input_boundary -o addopts= -v --cov=drm_copilot_discovery.validation --cov=drm_copilot_discovery.validation_operation --cov-config=SCRATCH/issue-980-coverage.ini --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-980-semantic-repair-precheck-coverage.json
EXIT_CODE: 0
Output Summary: tests, 64.202s; exact raw streams separately bound.

```text
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0 -- .\.venv\Scripts\python.exe
cachedir: .pytest_cache
rootdir: .
configfile: pyproject.toml
plugins: anyio-4.12.1, cov-7.0.0
collecting ... collected 5 items

tests/discovery_runtime/test_completion_projection.py::test_malformed_completion_retains_diagnostics_without_semantic_assessment[missing-profile] PASSED [ 20%]
tests/discovery_runtime/test_completion_projection.py::test_malformed_completion_retains_diagnostics_without_semantic_assessment[malformed] PASSED [ 40%]
tests/discovery_runtime/test_completion_projection.py::test_malformed_completion_retains_diagnostics_without_semantic_assessment[loader] PASSED [ 60%]
tests/discovery_runtime/test_completion_projection.py::test_validation_report_preserves_plain_envelope_and_strict_input_boundary[False] PASSED [ 80%]
tests/discovery_runtime/test_completion_projection.py::test_validation_report_preserves_plain_envelope_and_strict_input_boundary[True] PASSED [100%]

=============================== tests coverage ================================
______________ coverage: platform win32, python 3.13.12-final-0 _______________

Name                                                                           Stmts   Miss Branch BrPart  Cover   Missing
--------------------------------------------------------------------------------------------------------------------------
packages\discovery-runtime\src\drm_copilot_discovery\validation.py                89     33     44     10    56%   95, 97, 110-160, 163, 171, 205, 208, 210, 218-221, 245
packages\discovery-runtime\src\drm_copilot_discovery\validation_operation.py      98     36     22      4    57%   138-153, 161-231, 244, 263-293, 297
--------------------------------------------------------------------------------------------------------------------------
TOTAL                                                                            187     69     66     14    56%
Coverage JSON written to file SCRATCH/issue-980-semantic-repair-precheck-coverage.json
======================== 5 passed in 62.40s (0:01:02) =========================
```
