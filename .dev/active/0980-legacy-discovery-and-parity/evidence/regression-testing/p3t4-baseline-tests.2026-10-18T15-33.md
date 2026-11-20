# p3t4-baseline-tests

Timestamp: 2026-10-18T15-33
Command: poetry run pytest -o addopts=-ra tests/discovery_runtime/test_observation_claims.py tests/discovery_runtime/test_runtime_claims.py -q --cov=drm_copilot_discovery.claim_rules --cov=drm_copilot_discovery.runtime_claim_rules --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-980-p3t4-baseline-coverage.json --junitxml=SCRATCH/issue-980-p3t4-baseline-tests.xml
EXIT_CODE: 0
Output Summary: -------------------------------------------------------------------------------------------------------------------------; TOTAL                                                                           220      3    132      7    97%; Coverage JSON written to file SCRATCH/issue-980-p3t4-baseline-coverage.json; 98 passed in 3.28s

Working directory: .
Started: 2026-10-18T15:33:33.518146+00:00
Duration seconds: 4.486
Phase: P3-T4 contract and scenario drafting; focused task verification.

## Captured output

```text
........................................................................ [ 73%]
..........................                                               [100%]
=============================== tests coverage ================================
______________ coverage: platform win32, python 3.13.12-final-0 _______________

Name                                                                          Stmts   Miss Branch BrPart  Cover   Missing
-------------------------------------------------------------------------------------------------------------------------
packages\discovery-runtime\src\drm_copilot_discovery\claim_rules.py             128      1     72      2    98%   293->291, 301
packages\discovery-runtime\src\drm_copilot_discovery\runtime_claim_rules.py      92      2     60      5    95%   109, 126, 175->177, 198->203, 201->200
-------------------------------------------------------------------------------------------------------------------------
TOTAL                                                                           220      3    132      7    97%
Coverage JSON written to file SCRATCH/issue-980-p3t4-baseline-coverage.json
98 passed in 3.28s
```
