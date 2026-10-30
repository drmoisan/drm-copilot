# p3t6-baseline-tests

Timestamp: 2026-10-18T17-30
Command: poetry run python SCRATCH/issue-980-p3t6-baseline.py
EXIT_CODE: 0
Output Summary: TOTAL                                                                        543     63    302     31    84%; Coverage JSON written to file SCRATCH\issue-980-p3t6-baseline-coverage.json; 85 passed in 49.47s; {"baseline_raw": "docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/baseline/p3t6-transport-coverage.2026-10-18T17-30.json"}

Working directory: .
Started: 2026-10-18T17:30:03.682690+00:00
Duration seconds: 50.664
Phase: P3-T6 immutable source snapshot transport; focused task verification.

## Captured output

```text
{"arguments": ["-o", "addopts=-ra", "tests/discovery_runtime/test_snapshot_imports.py", "tests/discovery_runtime/test_references.py", "tests/discovery_runtime/test_revision_rules.py", "-q", "--cov=drm_copilot_discovery.snapshot_loading", "--cov=drm_copilot_discovery.references", "--cov=drm_copilot_discovery.revision_rules", "--cov-branch", "--cov-report=term-missing", "--cov-report=json:EXTERNAL_PATH"]}
........................................................................ [ 84%]
.............                                                            [100%]
=============================== tests coverage ================================
______________ coverage: platform win32, python 3.13.12-final-0 _______________

Name                                                                       Stmts   Miss Branch BrPart  Cover   Missing
----------------------------------------------------------------------------------------------------------------------
packages\discovery-runtime\src\drm_copilot_discovery\references.py           154     18     76     12    83%   179, 193, 223, 232, 234-242, 244-252, 258-266, 279-280, 300, 317, 336, 350
packages\discovery-runtime\src\drm_copilot_discovery\revision_rules.py       187      4    108      5    97%   97, 187, 194, 308->exit, 344
packages\discovery-runtime\src\drm_copilot_discovery\snapshot_loading.py     202     41    118     14    73%   105-109, 121->127, 159-168, 178-179, 200-206, 226->exit, 294->306, 297-305, 307->exit, 363->360, 384, 401, 405-410, 439-467
----------------------------------------------------------------------------------------------------------------------
TOTAL                                                                        543     63    302     31    84%
Coverage JSON written to file SCRATCH\issue-980-p3t6-baseline-coverage.json
85 passed in 49.47s
{"baseline_raw": "docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/baseline/p3t6-transport-coverage.2026-10-18T17-30.json"}
```
