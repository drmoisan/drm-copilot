# P5-T2 outcomes8-tests

Timestamp: 2026-10-20T06-19

Command: poetry run pytest -q -o addopts= tests/discovery_runtime/test_parity_models.py tests/discovery_runtime/test_parity_rules.py tests/discovery_runtime/test_parity_clients.py --cov=drm_copilot_discovery.parity_models --cov=drm_copilot_discovery.parity_rules --cov=drm_copilot_discovery.parity_entry_rules --cov=drm_copilot_discovery.parity_target_rules --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/outcomes8-coverage.json

EXIT_CODE: 0

Output Summary: Exact scoped stage completed in 13.745s; raw bytes are retained in the JSON receipt.

```text
........................................................................ [ 79%]
...................                                                      [100%]
=============================== tests coverage ================================
______________ coverage: platform win32, python 3.13.12-final-0 _______________

Name                                                                          Stmts   Miss Branch BrPart  Cover   Missing
-------------------------------------------------------------------------------------------------------------------------
packages\discovery-runtime\src\drm_copilot_discovery\parity_entry_rules.py      139      2     56      3    97%   218->191, 266, 319
packages\discovery-runtime\src\drm_copilot_discovery\parity_models.py            35      0      0      0   100%
packages\discovery-runtime\src\drm_copilot_discovery\parity_rules.py            104      0     38      0   100%
packages\discovery-runtime\src\drm_copilot_discovery\parity_target_rules.py      99      0     50      2    99%   101->98, 157->164
-------------------------------------------------------------------------------------------------------------------------
TOTAL                                                                           377      2    144      5    99%
Coverage JSON written to file SCRATCH/outcomes8-coverage.json
91 passed in 11.98s
```
