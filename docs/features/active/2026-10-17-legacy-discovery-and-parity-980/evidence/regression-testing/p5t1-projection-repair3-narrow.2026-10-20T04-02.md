# p5t1-projection-repair3-narrow

Timestamp: 2026-10-20T04-02
Command: poetry run pytest tests/discovery_runtime/test_validation_modes.py::test_invalid_coverage_inputs_retain_original_findings_and_unavailable_counts tests/discovery_runtime/test_validation_modes.py::test_invalid_public_modes_and_unparsed_projection_raise_explicitly tests/discovery_runtime/test_validation_modes.py::test_coverage_preserves_requested_mode_and_independent_discovery_results tests/discovery_runtime/test_agent_output.py::test_valid_failed_review_can_finish_without_authorizing_planning -o addopts= -v --cov=drm_copilot_discovery.validation --cov-config=SCRATCH/coverage.ini --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/repair-narrow-coverage.json
EXIT_CODE: 0
Output Summary: scoped narrow-tests; duration 134.381 seconds. Raw stdout/stderr hashes and SCRATCH-relative locations are separate from sanitized presentation.

```text
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0 -- .\.venv\Scripts\python.exe
cachedir: .pytest_cache
rootdir: .
configfile: pyproject.toml
plugins: anyio-4.12.1, cov-7.0.0
collecting ... collected 13 items

tests/discovery_runtime/test_validation_modes.py::test_invalid_coverage_inputs_retain_original_findings_and_unavailable_counts[missing-profile] PASSED [  7%]
tests/discovery_runtime/test_validation_modes.py::test_invalid_coverage_inputs_retain_original_findings_and_unavailable_counts[loader] PASSED [ 15%]
tests/discovery_runtime/test_validation_modes.py::test_invalid_public_modes_and_unparsed_projection_raise_explicitly PASSED [ 23%]
tests/discovery_runtime/test_validation_modes.py::test_coverage_preserves_requested_mode_and_independent_discovery_results[structural-False] PASSED [ 30%]
tests/discovery_runtime/test_validation_modes.py::test_coverage_preserves_requested_mode_and_independent_discovery_results[structural-True] PASSED [ 38%]
tests/discovery_runtime/test_validation_modes.py::test_coverage_preserves_requested_mode_and_independent_discovery_results[discovery-complete-False] PASSED [ 46%]
tests/discovery_runtime/test_validation_modes.py::test_coverage_preserves_requested_mode_and_independent_discovery_results[discovery-complete-True] PASSED [ 53%]
tests/discovery_runtime/test_validation_modes.py::test_coverage_preserves_requested_mode_and_independent_discovery_results[planning-False] PASSED [ 61%]
tests/discovery_runtime/test_validation_modes.py::test_coverage_preserves_requested_mode_and_independent_discovery_results[planning-True] PASSED [ 69%]
tests/discovery_runtime/test_agent_output.py::test_valid_failed_review_can_finish_without_authorizing_planning[discovery-complete-completion-report] PASSED [ 76%]
tests/discovery_runtime/test_agent_output.py::test_valid_failed_review_can_finish_without_authorizing_planning[discovery-complete-coverage-report] PASSED [ 84%]
tests/discovery_runtime/test_agent_output.py::test_valid_failed_review_can_finish_without_authorizing_planning[parity-complete-completion-report] PASSED [ 92%]
tests/discovery_runtime/test_agent_output.py::test_valid_failed_review_can_finish_without_authorizing_planning[parity-complete-coverage-report] PASSED [100%]

=============================== tests coverage ================================
______________ coverage: platform win32, python 3.13.12-final-0 _______________

Name                                                                 Stmts   Miss Branch BrPart  Cover   Missing
----------------------------------------------------------------------------------------------------------------
packages\discovery-runtime\src\drm_copilot_discovery\validation.py     150      9     52      8    92%   185, 187, 329, 354, 362-369, 374, 395, 403
----------------------------------------------------------------------------------------------------------------
TOTAL                                                                  150      9     52      8    92%
Coverage JSON written to file SCRATCH/repair-narrow-coverage.json
======================= 13 passed in 132.64s (0:02:12) ========================
```
