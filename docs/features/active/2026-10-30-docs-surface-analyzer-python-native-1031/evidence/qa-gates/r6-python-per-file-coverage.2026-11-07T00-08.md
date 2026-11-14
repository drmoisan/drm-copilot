# [P6-T5] Helper per-file coverage

Timestamp: 2026-11-07T00-08
Command: poetry run python -m pytest tests/scripts/claude-lib/docs/python --cov=docs_python_native --cov=run_docs_python_native --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-1031-final-helper.json
EXIT_CODE: 0
Output Summary: 251 passed, 0 failed. Helper totals from JSON: line 99.28% (1801/1814), branch 97.22% (805/828). Each of the eighteen PYLIB files is at or above 85 line and 75 branch; the lowest line figure is source.py 97.35 and the lowest branch figure is walk.py 90.00.

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
