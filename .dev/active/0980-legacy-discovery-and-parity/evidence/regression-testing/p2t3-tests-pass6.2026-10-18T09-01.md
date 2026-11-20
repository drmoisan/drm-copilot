# p2t3-tests-pass6

Timestamp: 2026-10-18T09-01
Original capture timestamp: 2026-10-18T08-31
Source aggregate: docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p2t3-gates.2026-10-18T08-27.md
Source block ordinal: 16
Command: poetry run pytest -q -o addopts= tests/discovery_runtime/test_evidence_rules.py tests/discovery_runtime/test_revision_rules.py --cov=drm_copilot_discovery.evidence_rules --cov=drm_copilot_discovery.revision_rules --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-980-p2t3-coverage.json
EXIT_CODE: 0
Output Summary: --------------------------------------------------------------------------------------------------------------------; TOTAL                                                                      297      3    150      4    98%; Coverage JSON written to file SCRATCH/issue-980-p2t3-coverage.json; 88 passed in 17.89s

Working directory: .
Started: 2026-10-18T08:31:11.373045+00:00
Duration seconds: 19.045
Phase: P2-T3 evidence integrity and declared repository revisions; focused task verification.

## Captured output

```text
........................................................................ [ 81%]
................                                                         [100%]
=============================== tests coverage ================================
______________ coverage: platform win32, python 3.13.12-final-0 _______________

Name                                                                     Stmts   Miss Branch BrPart  Cover   Missing
--------------------------------------------------------------------------------------------------------------------
packages\discovery-runtime\src\drm_copilot_discovery\evidence_rules.py     110      0     42      0   100%
packages\discovery-runtime\src\drm_copilot_discovery\revision_rules.py     187      3    108      4    98%   187, 194, 308->exit, 344
--------------------------------------------------------------------------------------------------------------------
TOTAL                                                                      297      3    150      4    98%
Coverage JSON written to file SCRATCH/issue-980-p2t3-coverage.json
88 passed in 17.89s
```
