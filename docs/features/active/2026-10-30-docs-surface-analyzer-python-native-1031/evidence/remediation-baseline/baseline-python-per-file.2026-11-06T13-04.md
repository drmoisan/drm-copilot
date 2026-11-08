# [P0-T5] Remediation baseline: helper per-file coverage

Timestamp: 2026-11-06T13-04
Command: poetry run python -m pytest tests/scripts/claude-lib/docs/python --cov=docs_python_native --cov=run_docs_python_native --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-1031-baseline-helper.json
EXIT_CODE: 0
Output Summary: 208 passed in 2.39 s (0 failed). Helper totals from JSON: line 98.93% (1756/1775), branch 96.50% (799/828). Every one of the twelve PYLIB files is at or above 85 line and 75 branch.

| File | Line % (covered/statements) | Branch % (covered/branches) |
|---|---|---|
| `PKG/__init__.py` | 100.00 (0/0) | 100.00 (0/0) |
| `PKG/architecture.py` | 100.00 (69/69) | 97.37 (37/38) |
| `PKG/cli_argparse.py` | 99.07 (214/216) | 95.28 (101/106) |
| `PKG/cli_click.py` | 96.90 (219/226) | 93.85 (122/130) |
| `PKG/cli_typer.py` | 99.48 (190/191) | 95.83 (92/96) |
| `PKG/cli.py` | 99.04 (103/104) | 97.83 (45/46) |
| `PKG/imports.py` | 99.54 (218/219) | 97.87 (92/94) |
| `PKG/protocol.py` | 100.00 (150/150) | 100.00 (50/50) |
| `PKG/public_api.py` | 98.08 (153/156) | 96.88 (93/96) |
| `PKG/routes.py` | 100.00 (281/281) | 99.14 (115/116) |
| `PKG/source.py` | 97.30 (144/148) | 92.31 (48/52) |
| `PYLIB/run_docs_python_native.py` | 100.00 (15/15) | 100.00 (4/4) |

Pass count used by [P2-T1]: 208.
