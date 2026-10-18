# p2t8-pass6-tests

Timestamp: 2026-10-18T10-17
Command: poetry run pytest tests/discovery_runtime/test_parity_rules.py tests/discovery_runtime/test_parity_clients.py --cov=drm_copilot_discovery.parity_rules --cov=drm_copilot_discovery.parity_target_rules --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-980-p2t8-coverage.json -o addopts=-ra -q
EXIT_CODE: 0
Output Summary: -------------------------------------------------------------------------------------------------------------------------; TOTAL                                                                           245      0    124      3    99%; Coverage JSON written to file SCRATCH/issue-980-p2t8-coverage.json; 77 passed in 5.93s

Working directory: .
Started: 2026-10-18T10:17:47.257446+00:00
Duration seconds: 7.200
Phase: P2-T8 source-to-target parity rules; focused task verification.

## Captured output

```text
........................................................................ [ 93%]
.....                                                                    [100%]
=============================== tests coverage ================================
______________ coverage: platform win32, python 3.13.12-final-0 _______________

Name                                                                          Stmts   Miss Branch BrPart  Cover   Missing
-------------------------------------------------------------------------------------------------------------------------
packages\discovery-runtime\src\drm_copilot_discovery\parity_rules.py            146      0     74      1    99%   174->146
packages\discovery-runtime\src\drm_copilot_discovery\parity_target_rules.py      99      0     50      2    99%   101->98, 157->164
-------------------------------------------------------------------------------------------------------------------------
TOTAL                                                                           245      0    124      3    99%
Coverage JSON written to file SCRATCH/issue-980-p2t8-coverage.json
77 passed in 5.93s
```
