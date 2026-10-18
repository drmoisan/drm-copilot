# p2t8-pass4-tests

Timestamp: 2026-10-18T10-16
Command: poetry run pytest tests/discovery_runtime/test_parity_rules.py tests/discovery_runtime/test_parity_clients.py --cov=drm_copilot_discovery.parity_rules --cov=drm_copilot_discovery.parity_target_rules --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-980-p2t8-coverage.json -o addopts=-ra -q
EXIT_CODE: 0
Output Summary: -------------------------------------------------------------------------------------------------------------------------; TOTAL                                                                           245      7    124     11    95%; Coverage JSON written to file SCRATCH/issue-980-p2t8-coverage.json; 65 passed in 5.80s

Working directory: .
Started: 2026-10-18T10:16:10.392705+00:00
Duration seconds: 7.038
Phase: P2-T8 source-to-target parity rules; focused task verification.

## Captured output

```text
.................................................................        [100%]
=============================== tests coverage ================================
______________ coverage: platform win32, python 3.13.12-final-0 _______________

Name                                                                          Stmts   Miss Branch BrPart  Cover   Missing
-------------------------------------------------------------------------------------------------------------------------
packages\discovery-runtime\src\drm_copilot_discovery\parity_rules.py            146      1     74      2    99%   174->146, 232
packages\discovery-runtime\src\drm_copilot_discovery\parity_target_rules.py      99      6     50      9    90%   82->81, 89, 100, 101->98, 157->164, 161, 194, 224, 228
-------------------------------------------------------------------------------------------------------------------------
TOTAL                                                                           245      7    124     11    95%
Coverage JSON written to file SCRATCH/issue-980-p2t8-coverage.json
65 passed in 5.80s
```
