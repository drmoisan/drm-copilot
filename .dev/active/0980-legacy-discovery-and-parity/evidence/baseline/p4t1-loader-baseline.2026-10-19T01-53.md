Timestamp: 2026-10-19T01-53
Command: poetry run pytest -o addopts='' tests/discovery_runtime/test_snapshot_loading.py tests/discovery_runtime/test_snapshot_imports.py --cov=drm_copilot_discovery.snapshot_loading --cov-branch --cov-report=term-missing --cov-report=json:docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/baseline/p4t1-loader-baseline.2026-10-19T01-53.json
EXIT_CODE: 0
Output Summary: Focused accepted loader baseline before edits. Ruff and Pyright passed. Prior attempted test_snapshot_loading_edges.py command failed collection because that file does not exist; zero tests ran, preserved as rejected invocation.
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0
rootdir: WORKSPACE
configfile: pyproject.toml
plugins: anyio-4.12.1, cov-7.0.0
collected 44 items

tests\discovery_runtime\test_snapshot_loading.py ....................... [ 52%]
.......                                                                  [ 68%]
tests\discovery_runtime\test_snapshot_imports.py ..............          [100%]

=============================== tests coverage ================================
______________ coverage: platform win32, python 3.13.12-final-0 _______________

Name                                                                       Stmts   Miss Branch BrPart  Cover   Missing
----------------------------------------------------------------------------------------------------------------------
packages\discovery-runtime\src\drm_copilot_discovery\snapshot_loading.py     202      0    118      6    98%   121->127, 294->306, 297->306, 304->306, 363->360, 444->448
----------------------------------------------------------------------------------------------------------------------
TOTAL                                                                        202      0    118      6    98%
Coverage JSON written to file docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/baseline/p4t1-loader-baseline.2026-10-19T01-53.json
======================= 44 passed in 114.52s (0:01:54) ========================

EvidenceNormalization: WORKSPACE denotes the repository root. Only machine-path rendering, retained coverage references, and known command destination transcription were corrected; executable results and failure/success history are unchanged.
OriginalReceipt: SCRATCH/p4t1-loader-evidence-2026-10-19T02-09-23cc9efa/baseline/p4t1-loader-baseline.2026-10-19T01-53.md
OriginalReceiptSHA256: 869f34028ef30e3a98a720610b8a1ac437532dee6bd2341ea100c6d7f91f1212
