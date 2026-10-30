# p3t5-baseline-tests

Timestamp: 2026-10-18T16-52
Command: poetry run pytest -o addopts=-ra tests/discovery_runtime/test_evidence_rules.py tests/discovery_runtime/test_revision_rules.py --cov=drm_copilot_discovery.evidence_rules --cov=drm_copilot_discovery.revision_rules --cov-branch --cov-report=term-missing --cov-report=json:docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/baseline/p3t5-evidence-coverage.2026-10-18T16-51.json
EXIT_CODE: 0
Output Summary: --------------------------------------------------------------------------------------------------------------------; TOTAL                                                                      297      1    150      2    99%; Coverage JSON written to file docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/baseline/p3t5-evidence-coverage.2026-10-18T16-51.json; ============================= 90 passed in 19.71s =============================

Working directory: .
Started: 2026-10-18T16:51:53.889418+00:00
Duration seconds: 20.917
Phase: P3-T5 evidence registration and linking; focused task verification.

## Captured output

```text
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0
rootdir: .
configfile: pyproject.toml
plugins: anyio-4.12.1, cov-7.0.0
collected 90 items

tests\discovery_runtime\test_evidence_rules.py ......................... [ 27%]
.....................                                                    [ 51%]
tests\discovery_runtime\test_revision_rules.py ......................... [ 78%]
...................                                                      [100%]

=============================== tests coverage ================================
______________ coverage: platform win32, python 3.13.12-final-0 _______________

Name                                                                     Stmts   Miss Branch BrPart  Cover   Missing
--------------------------------------------------------------------------------------------------------------------
packages\discovery-runtime\src\drm_copilot_discovery\evidence_rules.py     110      0     42      0   100%
packages\discovery-runtime\src\drm_copilot_discovery\revision_rules.py     187      1    108      2    99%   308->exit, 344
--------------------------------------------------------------------------------------------------------------------
TOTAL                                                                      297      1    150      2    99%
Coverage JSON written to file docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/baseline/p3t5-evidence-coverage.2026-10-18T16-51.json
============================= 90 passed in 19.71s =============================
```
