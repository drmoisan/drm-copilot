Timestamp: 2026-10-19T02-02
Command: poetry run pytest -o addopts= tests/discovery_runtime/test_snapshot_loading_inventory.py tests/discovery_runtime/test_snapshot_imports.py tests/discovery_runtime/test_snapshot_loading.py --cov=drm_copilot_discovery.snapshot_loading --cov=drm_copilot_discovery.snapshot_inventory_inputs --cov-branch --cov-report=term-missing --cov-report=json:docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/qa-gates/p4t1-loader-final.pending.json
EXIT_CODE: 0
Output Summary: ======================= 62 passed in 169.44s (0:02:49) ========================

============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0
rootdir: WORKSPACE
configfile: pyproject.toml
plugins: anyio-4.12.1, cov-7.0.0
collected 62 items

tests\discovery_runtime\test_snapshot_loading_inventory.py ............. [ 20%]
.....                                                                    [ 29%]
tests\discovery_runtime\test_snapshot_imports.py ..............          [ 51%]
tests\discovery_runtime\test_snapshot_loading.py ....................... [ 88%]
.......                                                                  [100%]

=============================== tests coverage ================================
______________ coverage: platform win32, python 3.13.12-final-0 _______________

Name                                                                                Stmts   Miss Branch BrPart  Cover   Missing
-------------------------------------------------------------------------------------------------------------------------------
packages\discovery-runtime\src\drm_copilot_discovery\snapshot_inventory_inputs.py      22      0     14      0   100%
packages\discovery-runtime\src\drm_copilot_discovery\snapshot_loading.py              204      0    118      6    98%   122->128, 295->307, 298->307, 305->307, 364->361, 454->458
-------------------------------------------------------------------------------------------------------------------------------
TOTAL                                                                                 226      0    132      6    98%
Coverage JSON written to file docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/qa-gates/p4t1-loader-final.pending.json
======================= 62 passed in 169.44s (0:02:49) ========================

EvidenceNormalization: WORKSPACE denotes the repository root. Only machine-path rendering, retained coverage references, and known command destination transcription were corrected; executable results and failure/success history are unchanged.
OriginalReceipt: SCRATCH/p4t1-loader-evidence-2026-10-19T02-09-23cc9efa/qa-gates/p4t1-loader-final-pytest-reversed.2026-10-19T02-05.md
OriginalReceiptSHA256: 1209b0f6f711a0bd3f7914829b939dfa90f8a22a9a8ece3d9604c8a74ba98032
