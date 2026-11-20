# p4t3-masking-pass3-unit

Timestamp: 2026-10-19T04-33
Command: poetry run pytest -o addopts=-ra tests/scripts/dev_tools/discovery/analyzer/test_source_text.py tests/discovery_runtime/analyzer/test_source_masking.py -q --cov=drm_copilot_discovery.analyzer.source_text --cov=scripts.dev_tools/discovery/analyzer/source_text --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-980-p4t3-masking-coverage.json
EXIT_CODE: 0
Output Summary: PASS scoped P4-T3 masking stage 4; duration 2.002 seconds. Exact source hashes are in the paired JSON receipt.

```text
........................................................................ [ 66%]
.....................................\.venv\Lib\site-packages\coverage\inorout.py:495: CoverageWarning: Module scripts.dev_tools/discovery/analyzer/source_text was never imported. (module-not-imported); see https://coverage.readthedocs.io/en/7.13.2/messages.html#warning-module-not-imported
  self.warn(f"Module {pkg} was never imported.", slug="module-not-imported")
                                     [100%]
=============================== tests coverage ================================
______________ coverage: platform win32, python 3.13.12-final-0 _______________

Name                                                                           Stmts   Miss Branch BrPart  Cover   Missing
--------------------------------------------------------------------------------------------------------------------------
packages\discovery-runtime\src\drm_copilot_discovery\analyzer\source_text.py     145      0     50      0   100%
--------------------------------------------------------------------------------------------------------------------------
TOTAL                                                                            145      0     50      0   100%
Coverage JSON written to file SCRATCH/issue-980-p4t3-masking-coverage.json
108 passed in 0.34s
```
