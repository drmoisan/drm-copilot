# p1t8-tests-pass6

Timestamp: 2026-10-18T06-24
Command: poetry run pytest tests/discovery_runtime -q -o addopts= --cov=drm_copilot_discovery.parsing --cov=drm_copilot_discovery.findings --cov=drm_copilot_discovery.models --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-980-p1t8-coverage.json
EXIT_CODE: 0
Output Summary: --------------------------------------------------------------------------------------------------------------; TOTAL                                                                368      6    158      3    98%; Coverage JSON written to file SCRATCH/issue-980-p1t8-coverage.json; 387 passed in 3.40s

Working directory: .
Started: 2026-10-18T06:24:11.096056+00:00
Duration seconds: 4.571
Phase: P1-T8 strict parsing and immutable diagnostics; focused task verification.

## Captured output

```text
........................................................................ [ 18%]
........................................................................ [ 37%]
........................................................................ [ 55%]
........................................................................ [ 74%]
........................................................................ [ 93%]
...........................                                              [100%]
=============================== tests coverage ================================
______________ coverage: platform win32, python 3.13.12-final-0 _______________

Name                                                               Stmts   Miss Branch BrPart  Cover   Missing
--------------------------------------------------------------------------------------------------------------
packages\discovery-runtime\src\drm_copilot_discovery\findings.py      78      0     36      1    99%   122->126
packages\discovery-runtime\src\drm_copilot_discovery\models.py        84      0     36      0   100%
packages\discovery-runtime\src\drm_copilot_discovery\parsing.py      206      6     86      2    97%   230-231, 260-261, 407-408
--------------------------------------------------------------------------------------------------------------
TOTAL                                                                368      6    158      3    98%
Coverage JSON written to file SCRATCH/issue-980-p1t8-coverage.json
387 passed in 3.40s
```
