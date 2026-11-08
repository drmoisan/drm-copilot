# [P6-T5] Helper per-file coverage

Timestamp: 2026-11-04T17-33
Command: sh SCRATCH/issue-1031-helpercov.sh, which runs poetry run python -m pytest --strict-markers --strict-config tests/scripts/claude-lib/docs/python --cov=docs_python_native --cov=run_docs_python_native --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-1031-helper-coverage.json -q
EXIT_CODE: 0
Output Summary: 208 passed, 0 failed. Every file meets line >= 85 and branch >= 75 in the JSON files entries.

| File | Lines covered / statements | Line % | Branches covered / branches | Branch % |
|---|---|---|---|---|
| .claude/lib/docs/python/docs_python_native/__init__.py | 0 / 0 | 100.00 (no executable statement; coverage.py reports percent_covered 100) | 0 / 0 | 100.00 |
| .claude/lib/docs/python/docs_python_native/architecture.py | 69 / 69 | 100.00 | 37 / 38 | 97.37 |
| .claude/lib/docs/python/docs_python_native/cli.py | 103 / 104 | 99.04 | 45 / 46 | 97.83 |
| .claude/lib/docs/python/docs_python_native/cli_argparse.py | 214 / 216 | 99.07 | 101 / 106 | 95.28 |
| .claude/lib/docs/python/docs_python_native/cli_click.py | 219 / 226 | 96.90 | 122 / 130 | 93.85 |
| .claude/lib/docs/python/docs_python_native/cli_typer.py | 190 / 191 | 99.48 | 92 / 96 | 95.83 |
| .claude/lib/docs/python/docs_python_native/imports.py | 218 / 219 | 99.54 | 92 / 94 | 97.87 |
| .claude/lib/docs/python/docs_python_native/protocol.py | 150 / 150 | 100.00 | 50 / 50 | 100.00 |
| .claude/lib/docs/python/docs_python_native/public_api.py | 153 / 156 | 98.08 | 93 / 96 | 96.88 |
| .claude/lib/docs/python/docs_python_native/routes.py | 281 / 281 | 100.00 | 115 / 116 | 99.14 |
| .claude/lib/docs/python/docs_python_native/source.py | 144 / 148 | 97.30 | 48 / 52 | 92.31 |
| .claude/lib/docs/python/run_docs_python_native.py | 15 / 15 | 100.00 | 4 / 4 | 100.00 |

## Loop re-run 2026-11-04T17-58

The loop restarted from [P6-T1] after the [P6-T8] PSScriptAnalyzer remediation of four new Pester files (no LIB or PYLIB file changed, so [P5-T1] was not repeated). The same commands were re-run through SCRATCH/issue-1031-loop-py.sh with EXIT_CODE 0 and identical results to those recorded above.
