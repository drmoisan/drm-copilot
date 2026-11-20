# p3t5-coverage-report-preflight

Timestamp: 2026-10-18T17-16
Command: poetry run pytest -o addopts=-ra tests/discovery_runtime/test_evidence_payloads.py -k payload_requires_exact_immutable_bytes -q --cov=drm_copilot_discovery.evidence_linking --cov-branch --cov-report=json:SCRATCH/issue-980-p3t5-report-preflight-coverage.json
EXIT_CODE: 0
Output Summary: ______________ coverage: platform win32, python 3.13.12-final-0 _______________; ; Coverage JSON written to file SCRATCH/issue-980-p3t5-report-preflight-coverage.json; 1 passed, 27 deselected in 0.19s

Working directory: .
Started: 2026-10-18T17:16:52.930219+00:00
Duration seconds: 1.381
Phase: P3-T5 evidence registration and linking; focused task verification.

## Captured output

```text
.                                                                        [100%]
=============================== tests coverage ================================
______________ coverage: platform win32, python 3.13.12-final-0 _______________

Coverage JSON written to file SCRATCH/issue-980-p3t5-report-preflight-coverage.json
1 passed, 27 deselected in 0.19s
```
