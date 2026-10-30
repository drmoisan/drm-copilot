# P5-T1 final scope-reverse

Timestamp: 2026-10-20T05-07
Command: `WORKSPACE\.venv\Scripts\python.exe -u -m pytest -v -o addopts= -p no:cacheprovider tests/discovery_runtime/test_coverage_scope.py::test_malformed_inventory_rows_do_not_crash_or_shift_selection tests/discovery_runtime/test_coverage_scope.py::test_current_configuration_is_checked_only_against_its_own_profile tests/discovery_runtime/test_coverage_scope.py::test_excluded_selected_scan_input_requires_scope_rationale tests/discovery_runtime/test_coverage_scope.py::test_skipped_paths_require_explicit_inventory_exclusion_accounting tests/discovery_runtime/test_coverage_scope.py::test_scan_failures_block_only_global_or_selected_inputs tests/discovery_runtime/test_coverage_scope.py::test_complete_scan_requires_exact_captured_input_accounting --cov=drm_copilot_discovery.coverage_report --cov=drm_copilot_discovery.coverage_population --cov=drm_copilot_discovery.validation --cov=drm_copilot_discovery.coverage_scope_rules --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH\issue-980-p5t1-repaired-final-050607-scope-coverage.raw.json`
EXIT_CODE: 0
Output Summary: Stage 6; elapsed 3.015 seconds; completed nodes 17; timeout=False.

```text
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0 -- WORKSPACE\.venv\Scripts\python.exe
rootdir: WORKSPACE
configfile: pyproject.toml
plugins: anyio-4.12.1, cov-7.0.0
collecting ... collected 17 items

tests/discovery_runtime/test_coverage_scope.py::test_malformed_inventory_rows_do_not_crash_or_shift_selection PASSED [  5%]
tests/discovery_runtime/test_coverage_scope.py::test_current_configuration_is_checked_only_against_its_own_profile[False] PASSED [ 11%]
tests/discovery_runtime/test_coverage_scope.py::test_current_configuration_is_checked_only_against_its_own_profile[True] PASSED [ 17%]
tests/discovery_runtime/test_coverage_scope.py::test_excluded_selected_scan_input_requires_scope_rationale PASSED [ 23%]
tests/discovery_runtime/test_coverage_scope.py::test_skipped_paths_require_explicit_inventory_exclusion_accounting[Generated files.] PASSED [ 29%]
tests/discovery_runtime/test_coverage_scope.py::test_skipped_paths_require_explicit_inventory_exclusion_accounting[] PASSED [ 35%]
tests/discovery_runtime/test_coverage_scope.py::test_scan_failures_block_only_global_or_selected_inputs[None-True] PASSED [ 41%]
tests/discovery_runtime/test_coverage_scope.py::test_scan_failures_block_only_global_or_selected_inputs[src/component.cs-True] PASSED [ 47%]
tests/discovery_runtime/test_coverage_scope.py::test_scan_failures_block_only_global_or_selected_inputs[src/new.cs-True] PASSED [ 52%]
tests/discovery_runtime/test_coverage_scope.py::test_scan_failures_block_only_global_or_selected_inputs[src2/other.cs-False] PASSED [ 58%]
tests/discovery_runtime/test_coverage_scope.py::test_complete_scan_requires_exact_captured_input_accounting[missing-COVERAGE_INPUTS] PASSED [ 64%]
tests/discovery_runtime/test_coverage_scope.py::test_complete_scan_requires_exact_captured_input_accounting[extra-COVERAGE_INPUTS] PASSED [ 70%]
tests/discovery_runtime/test_coverage_scope.py::test_complete_scan_requires_exact_captured_input_accounting[changed-hash-COVERAGE_INPUTS] PASSED [ 76%]
tests/discovery_runtime/test_coverage_scope.py::test_complete_scan_requires_exact_captured_input_accounting[duplicate-COVERAGE_FILES] PASSED [ 82%]
tests/discovery_runtime/test_coverage_scope.py::test_complete_scan_requires_exact_captured_input_accounting[unsorted-COVERAGE_FILES] PASSED [ 88%]
tests/discovery_runtime/test_coverage_scope.py::test_complete_scan_requires_exact_captured_input_accounting[unreadable-COVERAGE_SCAN] PASSED [ 94%]
tests/discovery_runtime/test_coverage_scope.py::test_complete_scan_requires_exact_captured_input_accounting[excluded-COVERAGE_SCAN] PASSED [100%]

=============================== tests coverage ================================
______________ coverage: platform win32, python 3.13.12-final-0 _______________

Name                                                                           Stmts   Miss Branch BrPart  Cover   Missing
--------------------------------------------------------------------------------------------------------------------------
packages\discovery-runtime\src\drm_copilot_discovery\coverage_scope_rules.py     142     15     78     14    87%   112, 149, 289-295, 311-317, 325, 331->333, 339, 350, 366-372, 383, 390, 407->404, 416, 418
--------------------------------------------------------------------------------------------------------------------------
TOTAL                                                                            142     15     78     14    87%
Coverage JSON written to file SCRATCH\issue-980-p5t1-repaired-final-050607-scope-coverage.raw.json
============================= 17 passed in 1.66s ==============================
WORKSPACE\.venv\Lib\site-packages\coverage\inorout.py:495: CoverageWarning: Module drm_copilot_discovery.coverage_report was never imported. (module-not-imported); see https://coverage.readthedocs.io/en/7.13.2/messages.html#warning-module-not-imported
  self.warn(f"Module {pkg} was never imported.", slug="module-not-imported")
WORKSPACE\.venv\Lib\site-packages\coverage\inorout.py:495: CoverageWarning: Module drm_copilot_discovery.coverage_population was never imported. (module-not-imported); see https://coverage.readthedocs.io/en/7.13.2/messages.html#warning-module-not-imported
  self.warn(f"Module {pkg} was never imported.", slug="module-not-imported")
WORKSPACE\.venv\Lib\site-packages\coverage\inorout.py:495: CoverageWarning: Module drm_copilot_discovery.validation was never imported. (module-not-imported); see https://coverage.readthedocs.io/en/7.13.2/messages.html#warning-module-not-imported
  self.warn(f"Module {pkg} was never imported.", slug="module-not-imported")

```
