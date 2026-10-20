# P5-T1 report-boundary4-tests

Timestamp: 2026-10-20T04-55

Command: poetry run pytest tests/discovery_runtime/test_coverage_report_contract.py -k "loaded_report_views or report_output_scope" -vv --cov=drm_copilot_discovery.coverage_scope_rules --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/report-boundary4-coverage.json

EXIT_CODE: 0

Output Summary: The exact completed command result is retained below; no inferred completion is claimed.

Duration seconds: 73.564

```text
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0 -- WORKSPACE\.venv\Scripts\python.exe
cachedir: .pytest_cache
rootdir: WORKSPACE
configfile: pyproject.toml
plugins: anyio-4.12.1, cov-7.0.0
collecting ... collected 26 items / 17 deselected / 9 selected

tests/discovery_runtime/test_coverage_report_contract.py::test_loaded_report_views_do_not_replace_authored_documentation_accounting[reports-] PASSED [ 11%]
tests/discovery_runtime/test_coverage_report_contract.py::test_loaded_report_views_do_not_replace_authored_documentation_accounting[generated/views-nested/] PASSED [ 22%]
tests/discovery_runtime/test_coverage_report_contract.py::test_report_output_scope_preserves_path_segments_and_input_categories[docs/migration/discovery/reports/coverage-report.md-documentation-False] PASSED [ 33%]
tests/discovery_runtime/test_coverage_report_contract.py::test_report_output_scope_preserves_path_segments_and_input_categories[docs/migration/discovery/reports/nested/coverage-report.md-documentation-False] PASSED [ 44%]
tests/discovery_runtime/test_coverage_report_contract.py::test_report_output_scope_preserves_path_segments_and_input_categories[docs/migration/discovery/reports-other/coverage-report.md-documentation-True] PASSED [ 55%]
tests/discovery_runtime/test_coverage_report_contract.py::test_report_output_scope_preserves_path_segments_and_input_categories[docs/migration/discovery/Reports/coverage-report.md-documentation-True] PASSED [ 66%]
tests/discovery_runtime/test_coverage_report_contract.py::test_report_output_scope_preserves_path_segments_and_input_categories[docs/coverage-report.md-documentation-True] PASSED [ 77%]
tests/discovery_runtime/test_coverage_report_contract.py::test_report_output_scope_preserves_path_segments_and_input_categories[docs/migration/discovery/reports/coverage-report.md-source-True] PASSED [ 88%]
tests/discovery_runtime/test_coverage_report_contract.py::test_report_output_scope_preserves_path_segments_and_input_categories[docs/migration/discovery/reports/coverage-report.md-test-True] PASSED [100%]

=============================== tests coverage ================================
______________ coverage: platform win32, python 3.13.12-final-0 _______________

Name                                                                           Stmts   Miss Branch BrPart  Cover   Missing
--------------------------------------------------------------------------------------------------------------------------
packages\discovery-runtime\src\drm_copilot_discovery\coverage_scope_rules.py     142     52     78     18    55%   87, 111-117, 149, 174, 184, 192-221, 229-236, 242->exit, 260-269, 289-295, 311-317, 325, 331->333, 339, 350, 366-372, 374-396, 405-408, 410-416, 418
--------------------------------------------------------------------------------------------------------------------------
TOTAL                                                                            142     52     78     18    55%
Coverage JSON written to file SCRATCH/report-boundary4-coverage.json
Coverage LCOV written to file artifacts/python/lcov.info
================= 9 passed, 17 deselected in 71.02s (0:01:11) =================

```
