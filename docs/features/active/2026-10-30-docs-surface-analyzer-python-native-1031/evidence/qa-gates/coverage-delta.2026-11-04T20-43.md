# [P6-T10] Coverage deltas (fresh computation on the post-merge head)

Timestamp: 2026-11-04T20-43
Command: computation over baseline-pytest-coverage.2026-11-04T15-11.md ([P0-T6]), baseline-pester-coverage.2026-11-04T15-53.md ([P0-T8]), qa-pytest-coverage.2026-11-04T19-59.md ([P6-T4]), qa-python-per-file-coverage.2026-11-04T19-59.md ([P6-T5]) and qa-pester-coverage.2026-11-04T20-43.md ([P6-T9])
EXIT_CODE: 0
Output Summary: no total decreased; every new Python file meets 85% line and 75% branch; the four PowerShell modules named by the acceptance are at 100% line coverage and every changed line of the three edited files is covered; no production file is excluded from measurement.

## Python (pytest-cov JSON totals)

| Measure | Baseline [P0-T6] | Post-change [P6-T4] | Delta |
|---|---|---|---|
| Line | 96.67% (32257/33367) | 96.79% (34013/35142) | +0.12 |
| Branch | 93.64% (11720/12516) | 93.82% (12519/13344) | +0.18 |

New-code baseline: PYLIB not present at baseline. Per-file post-change pairs ([P6-T5], line / branch): run_docs_python_native.py 100.00/100.00; __init__.py 100.00/100.00 (0 statements); architecture.py 100.00/97.37; cli.py 99.04/97.83; cli_argparse.py 99.07/95.28; cli_click.py 96.90/93.85; cli_typer.py 99.48/95.83; imports.py 99.54/97.87; protocol.py 100.00/100.00; public_api.py 98.08/96.88; routes.py 100.00/99.14; source.py 97.30/92.31. All twelve at or above 85 line and 75 branch. `[tool.coverage.run]` `source` includes `.claude/lib/docs/python`, so the twelve files are in the full-run denominator.

## PowerShell (Pester line coverage)

| Measure | Baseline [P0-T8] | Post-change [P6-T9] |
|---|---|---|
| Overall | 93.77% (26417/28171) | 94.33% (29998/31800) |
| LIB/DocsAnalyzerPythonNative.psm1 | not present | 100.00% (89/89) |
| LIB/DocsPythonNativeProtocol.psm1 | not present | 100.00% (132/132) |
| LIB/DocsAnalyzerRegistry.psm1 | 100.00% (124/124) | 100.00% (135/135) |
| LIB/DocsInventory.psm1 | 100.00% (100/100) | 100.00% (121/121) |
| LIB/Invoke-DocsCommand.ps1 | 87.74% (136/155) | 87.82% (137/156) |

The post-change population includes the files merged from the integration branch (1024 and 1033), so the overall totals cover different populations; the overall figure did not decrease. The registry total grew by 11 lines, of which 4 are the 1031 native rows (the pre-merge [P6-T9] record shows 128) and 7 come from the integration merge. Changed lines: every line added to DocsAnalyzerRegistry.psm1 and DocsInventory.psm1 is covered (both files have no missed line), and the single changed line of Invoke-DocsCommand.ps1 (line 60, the `inventory` row `Option`) is covered; its missed lines 213, 215-229 and 252-254 are unchanged since the baseline. The coverage population is derived from config/poshqc-coverage.json, which measures `.claude/lib`, so no production file is excluded.

## Result

PASS: every value meets its threshold; none is remediation-required. The zero-failure condition of [P6-T9] remains pending-CI on `poshqc / PowerShell QC`; the coverage figures above are from the complete local coverage XML.
