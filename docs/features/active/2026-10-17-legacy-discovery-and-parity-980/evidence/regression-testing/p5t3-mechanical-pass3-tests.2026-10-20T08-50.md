# p5t3-mechanical-pass3-tests

Timestamp: 2026-10-20T08-50
Command: poetry run pytest tests/discovery_runtime/test_parity_report_projection.py::test_multiple_derived_reports_reuse_one_complete_assessment tests/discovery_runtime/test_parity_report_projection.py::test_parity_preflight_rejects_excess_before_graph_work tests/discovery_runtime/test_agent_output.py::test_valid_failed_review_can_finish_without_authorizing_planning tests/discovery_runtime/test_validation_modes.py::test_invalid_public_modes_and_unparsed_projection_raise_explicitly tests/discovery_runtime/test_validation_modes.py::test_report_projection_is_recomputed_and_nonrecursive[completion-report-initialized-root] -o addopts= -v --cov=drm_copilot_discovery.validation --cov=drm_copilot_discovery.validation_operation --cov-config=SCRATCH/issue-980-coverage.ini --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-980-mechanical-coverage.json
EXIT_CODE: 0
Output Summary: tests, 74.922s; exact raw streams separately bound.

```text
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0 -- .\.venv\Scripts\python.exe
cachedir: .pytest_cache
rootdir: .
configfile: pyproject.toml
plugins: anyio-4.12.1, cov-7.0.0
collecting ... collected 8 items

tests/discovery_runtime/test_parity_report_projection.py::test_multiple_derived_reports_reuse_one_complete_assessment PASSED [ 12%]
tests/discovery_runtime/test_parity_report_projection.py::test_parity_preflight_rejects_excess_before_graph_work PASSED [ 25%]
tests/discovery_runtime/test_agent_output.py::test_valid_failed_review_can_finish_without_authorizing_planning[discovery-complete-completion-report] PASSED [ 37%]
tests/discovery_runtime/test_agent_output.py::test_valid_failed_review_can_finish_without_authorizing_planning[discovery-complete-coverage-report] PASSED [ 50%]
tests/discovery_runtime/test_agent_output.py::test_valid_failed_review_can_finish_without_authorizing_planning[parity-complete-completion-report] PASSED [ 62%]
tests/discovery_runtime/test_agent_output.py::test_valid_failed_review_can_finish_without_authorizing_planning[parity-complete-coverage-report] PASSED [ 75%]
tests/discovery_runtime/test_validation_modes.py::test_invalid_public_modes_and_unparsed_projection_raise_explicitly PASSED [ 87%]
tests/discovery_runtime/test_validation_modes.py::test_report_projection_is_recomputed_and_nonrecursive[completion-report-initialized-root] PASSED [100%]

=============================== tests coverage ================================
______________ coverage: platform win32, python 3.13.12-final-0 _______________

Name                                                                           Stmts   Miss Branch BrPart  Cover   Missing
--------------------------------------------------------------------------------------------------------------------------
packages\discovery-runtime\src\drm_copilot_discovery\validation.py                82     10     38      7    84%   93, 105->157, 118, 126-133, 159, 167, 211-214
packages\discovery-runtime\src\drm_copilot_discovery\validation_operation.py      92      1     18      1    98%   137
--------------------------------------------------------------------------------------------------------------------------
TOTAL                                                                            174     11     56      8    91%
Coverage JSON written to file SCRATCH/issue-980-mechanical-coverage.json
======================== 8 passed in 72.52s (0:01:12) =========================
```
