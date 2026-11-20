# p3t5-pass1-contracts

Timestamp: 2026-10-18T17-21
Command: poetry run pytest -o addopts=-ra tests/discovery_runtime/test_package_contract.py tests/discovery_runtime/test_resources.py tests/schemas/discovery/test_v1_schema_documents.py tests/schemas/discovery/test_v1_fixtures.py tests/scripts/dev_tools/discovery/test_package_exports.py tests/schemas/discovery/test_v2_observation_schemas.py tests/schemas/discovery/test_v2_runtime_schemas.py tests/discovery_runtime/test_evidence_rules.py tests/discovery_runtime/test_revision_rules.py -q --junitxml=SCRATCH\issue-980-p3t5-pass1-contracts.xml --cov=drm_copilot_discovery.evidence_rules --cov=drm_copilot_discovery.revision_rules --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH\issue-980-p3t5-pass1-compatibility-coverage.json
EXIT_CODE: 0
Output Summary: --------------------------------------------------------------------------------------------------------------------; TOTAL                                                                      297      1    150      2    99%; Coverage JSON written to file SCRATCH\issue-980-p3t5-pass1-compatibility-coverage.json; 543 passed in 26.37s

Working directory: .
Started: 2026-10-18T17:20:47.817640+00:00
Duration seconds: 27.646
Phase: P3-T5 evidence registration and linking; focused task verification.

## Captured output

```text
........................................................................ [ 13%]
........................................................................ [ 26%]
........................................................................ [ 39%]
........................................................................ [ 53%]
........................................................................ [ 66%]
........................................................................ [ 79%]
........................................................................ [ 92%]
.......................................                                  [100%]
=============================== tests coverage ================================
______________ coverage: platform win32, python 3.13.12-final-0 _______________

Name                                                                     Stmts   Miss Branch BrPart  Cover   Missing
--------------------------------------------------------------------------------------------------------------------
packages\discovery-runtime\src\drm_copilot_discovery\evidence_rules.py     110      0     42      0   100%
packages\discovery-runtime\src\drm_copilot_discovery\revision_rules.py     187      1    108      2    99%   308->exit, 344
--------------------------------------------------------------------------------------------------------------------
TOTAL                                                                      297      1    150      2    99%
Coverage JSON written to file SCRATCH\issue-980-p3t5-pass1-compatibility-coverage.json
543 passed in 26.37s
```
