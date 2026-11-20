# p2t2-tests-pass3

Timestamp: 2026-10-18T09-01
Original capture timestamp: 2026-10-18T08-13
Source aggregate: docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p2t2-gates.2026-10-18T08-12.md
Source block ordinal: 7
Command: poetry run pytest -q -o addopts= tests/discovery_runtime/test_references.py tests/discovery_runtime/test_reference_uniqueness.py --cov=drm_copilot_discovery.references --cov=drm_copilot_discovery.reference_links --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-980-p2t2-coverage.json
EXIT_CODE: 0
Output Summary: ---------------------------------------------------------------------------------------------------------------------; TOTAL                                                                       247      2    144      5    98%; Coverage JSON written to file SCRATCH/issue-980-p2t2-coverage.json; 64 passed in 3.08s

Working directory: .
Started: 2026-10-18T08:13:42.391781+00:00
Duration seconds: 4.291
Phase: P2-T2 typed artifact identities and references; focused task verification.

## Captured output

```text
................................................................         [100%]
=============================== tests coverage ================================
______________ coverage: platform win32, python 3.13.12-final-0 _______________

Name                                                                      Stmts   Miss Branch BrPart  Cover   Missing
---------------------------------------------------------------------------------------------------------------------
packages\discovery-runtime\src\drm_copilot_discovery\reference_links.py      93      0     68      3    98%   74->80, 84->83, 218->216
packages\discovery-runtime\src\drm_copilot_discovery\references.py          154      2     76      2    98%   193, 300
---------------------------------------------------------------------------------------------------------------------
TOTAL                                                                       247      2    144      5    98%
Coverage JSON written to file SCRATCH/issue-980-p2t2-coverage.json
64 passed in 3.08s
```
