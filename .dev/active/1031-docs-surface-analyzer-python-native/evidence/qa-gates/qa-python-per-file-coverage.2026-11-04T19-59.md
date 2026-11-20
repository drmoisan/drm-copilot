# [P6-T5] Helper per-file coverage (fresh run on the post-merge head)

Timestamp: 2026-11-04T19-59
Command: poetry run python -m pytest --strict-markers --strict-config tests/scripts/claude-lib/docs/python --cov=docs_python_native --cov=run_docs_python_native --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-1031-helper-coverage.json (second step of SCRATCH/issue-1031-pytest.sh)
EXIT_CODE: 0
Output Summary: 208 passed, 0 failed in 2.85 s. The JSON report has 12 `files` entries; every file meets line >= 85 and branch >= 75.

| File | Line % (covered/statements) | Branch % (covered/branches) |
|---|---|---|
| .claude/lib/docs/python/run_docs_python_native.py | 100.00 (15/15) | 100.00 (4/4) |
| .claude/lib/docs/python/docs_python_native/__init__.py | 100.00 (0/0) | 100.00 (0/0) |
| .claude/lib/docs/python/docs_python_native/architecture.py | 100.00 (69/69) | 97.37 (37/38) |
| .claude/lib/docs/python/docs_python_native/cli.py | 99.04 (103/104) | 97.83 (45/46) |
| .claude/lib/docs/python/docs_python_native/cli_argparse.py | 99.07 (214/216) | 95.28 (101/106) |
| .claude/lib/docs/python/docs_python_native/cli_click.py | 96.90 (219/226) | 93.85 (122/130) |
| .claude/lib/docs/python/docs_python_native/cli_typer.py | 99.48 (190/191) | 95.83 (92/96) |
| .claude/lib/docs/python/docs_python_native/imports.py | 99.54 (218/219) | 97.87 (92/94) |
| .claude/lib/docs/python/docs_python_native/protocol.py | 100.00 (150/150) | 100.00 (50/50) |
| .claude/lib/docs/python/docs_python_native/public_api.py | 98.08 (153/156) | 96.88 (93/96) |
| .claude/lib/docs/python/docs_python_native/routes.py | 100.00 (281/281) | 99.14 (115/116) |
| .claude/lib/docs/python/docs_python_native/source.py | 97.30 (144/148) | 92.31 (48/52) |

`__init__.py` has no executable statement, so its figures are reported as 100 (0 of 0); it remains in the measured set.
