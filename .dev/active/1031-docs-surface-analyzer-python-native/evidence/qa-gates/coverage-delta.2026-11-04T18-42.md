# [P6-T10] Coverage deltas

Timestamp: 2026-11-04T18-42
Command: comparison of the [P0-T6], [P0-T8], [P6-T4], [P6-T5] and [P6-T9] coverage reports (SCRATCH/issue-1031-final-coverage.json, SCRATCH/issue-1031-helper-coverage.json, artifacts/pester/powershell-coverage.xml)
EXIT_CODE: 0
Output Summary: every total is at or above its baseline and threshold; every per-file figure meets its threshold; no production file is excluded.

## Totals per language

| Language | Metric | Baseline | Post-change | Delta | Threshold |
|---|---|---|---|---|---|
| Python ([P0-T6] / [P6-T4]) | line | 96.67% | 96.79% (34013 / 35142) | +0.12 | 85% |
| Python ([P0-T6] / [P6-T4]) | branch | 93.64% | 93.82% (12519 / 13344) | +0.18 | 75% |
| PowerShell ([P0-T8] / [P6-T9]) | line | 93.77% (26417 / 28171) | 93.83% (26663 / 28417) | +0.06 | 85% |

PowerShell has no branch gate (Pester does not measure branch coverage).

## Python per file ([P6-T5])

| File | Line % | Branch % |
|---|---|---|
| PKG/__init__.py | 100.00 (no executable statement) | 100.00 |
| PKG/architecture.py | 100.00 | 97.37 |
| PKG/cli.py | 99.04 | 97.83 |
| PKG/cli_argparse.py | 99.07 | 95.28 |
| PKG/cli_click.py | 96.90 | 93.85 |
| PKG/cli_typer.py | 99.48 | 95.83 |
| PKG/imports.py | 99.54 | 97.87 |
| PKG/protocol.py | 100.00 | 100.00 |
| PKG/public_api.py | 98.08 | 96.88 |
| PKG/routes.py | 100.00 | 99.14 |
| PKG/source.py | 97.30 | 92.31 |
| PYLIB/run_docs_python_native.py | 100.00 | 100.00 |

## Pester per file ([P6-T9])

| File | Baseline | Post-change | Changed lines covered |
|---|---|---|---|
| LIB/DocsAnalyzerPythonNative.psm1 (new) | n/a | 100.00% (89 / 89) | all |
| LIB/DocsPythonNativeProtocol.psm1 (new) | n/a | 100.00% (132 / 132) | all |
| LIB/DocsAnalyzerRegistry.psm1 | 100.00% (124 / 124) | 100.00% (128 / 128) | yes (the four native rows) |
| LIB/DocsInventory.psm1 | 100.00% (100 / 100) | 100.00% (121 / 121) | yes |
| LIB/Invoke-DocsCommand.ps1 | 87.74% (136 / 155) | 87.74% (136 / 155) | yes (line 60; the missed lines 212-228 and 251-253 are unchanged pre-existing lines) |

## Exclusions

pyproject.toml coverage `source` gained `.claude/lib/docs/python` and no `omit` entry was added; config/poshqc-coverage.json is unchanged and already measures `.claude/lib`. No production file is excluded from measurement.
