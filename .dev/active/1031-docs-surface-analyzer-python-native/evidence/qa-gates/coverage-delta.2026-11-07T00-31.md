# [P6-T11] Coverage deltas (S9, U9)

Timestamp: 2026-11-07T00-31
Command: comparison of the merged-tree baselines of [P0-T6] and [P0-T9] with [P6-T4], [P6-T5], [P6-T9] and [P6-T10]
EXIT_CODE: 0
Output Summary: every per-file value meets its threshold and no value regresses. Python line 96.82 to 96.84, branch 93.83 to 93.88; TypeScript unchanged; PowerShell per-file figures unchanged or equal at 100.00. No production file is excluded from measurement.

Canonical artifacts: `artifacts/python/lcov.info`, `artifacts/pester/powershell-coverage.xml`, `extensions/drm-copilot/coverage/lcov.info`.

## Totals

| Language | Baseline | Post-change | Change |
|---|---|---|---|
| Python line | 96.82 (34026/35142) | 96.84 (34071/35181) | +0.02 |
| Python branch | 93.83 (12521/13344) | 93.88 (12527/13344) | +0.05 |
| PowerShell overall line | 27.17 (docs suites only, per [P0-T6]) | 95.26 (all of tests/scripts) | not comparable: different run scope; the per-file rows are the comparison |
| TypeScript statements | 97.1 (63029/64911) | 97.1 (63029/64911) | 0 |
| TypeScript branches | 93.76 (9596/10234) | 93.76 (9596/10234) | 0 |
| TypeScript functions | 92.06 (1890/2053) | 92.06 (1890/2053) | 0 |
| TypeScript lines | 97.1 (63029/64911) | 97.1 (63029/64911) | 0 |

## PowerShell per file

| File | Baseline | Post-change |
|---|---|---|
| `LIB/DocsAnalyzerPythonNative.psm1` | 100.00 (91/91) | 100.00 (93/93) |
| `LIB/DocsPythonNativeProtocol.psm1` | 100.00 (132/132) | 100.00 (132/132) |
| `LIB/DocsAnalyzerRegistry.psm1` | 100.00 (135/135) | 100.00 (135/135) |
| `LIB/DocsInventory.psm1` | 100.00 (121/121) | 100.00 (121/121) |
| `LIB/Invoke-DocsCommand.ps1` | 87.82 (137/156) | 87.82 (137/156) |

## Python per file (post-change; the six new modules have no baseline row)

| File | Line % (covered/statements) | Branch % (covered/branches) |
|---|---|---|
| `PKG/__init__.py` | 100.00 (0/0) | 100.00 (0/0) |
| `PKG/architecture.py` | 100.00 (72/72) | 97.37 (37/38) |
| `PKG/call_sites.py` | 100.00 (91/91) | 100.00 (38/38) |
| `PKG/cli_argparse.py` | 100.00 (159/159) | 96.51 (83/86) |
| `PKG/cli_click.py` | 98.51 (199/202) | 96.43 (108/112) |
| `PKG/cli_typer.py` | 99.48 (192/193) | 95.83 (92/96) |
| `PKG/cli.py` | 99.06 (105/106) | 97.83 (45/46) |
| `PKG/facts.py` | 100.00 (33/33) | 100.00 (2/2) |
| `PKG/imports.py` | 100.00 (138/138) | 100.00 (56/56) |
| `PKG/module_names.py` | 98.11 (52/53) | 94.44 (34/36) |
| `PKG/protocol.py` | 100.00 (150/150) | 100.00 (50/50) |
| `PKG/public_api.py` | 98.11 (156/159) | 96.88 (93/96) |
| `PKG/route_model.py` | 100.00 (46/46) | 100.00 (0/0) |
| `PKG/route_sites.py` | 100.00 (129/129) | 98.44 (63/64) |
| `PKG/routes.py` | 100.00 (116/116) | 100.00 (52/52) |
| `PKG/source.py` | 97.35 (110/113) | 92.86 (39/42) |
| `PKG/walk.py` | 97.44 (38/39) | 90.00 (9/10) |
| `PYLIB/run_docs_python_native.py` | 100.00 (15/15) | 100.00 (4/4) |

Baseline per-file pairs for the twelve existing files are in the newest `baseline-python-per-file` artifact. Symbols moved out of `imports.py`, `routes.py`, `source.py`, `cli_argparse.py` and `cli_click.py` change those files' statement totals, so the helper total is the like-for-like comparison: line 98.93 (1756/1775) to 99.28 (1801/1814), branch 96.50 (799/828) to 97.22 (805/828).
