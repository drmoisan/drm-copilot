# Final QC — Pytest with Coverage

Timestamp: 2026-07-18T11-43
Command: poetry run pytest --cov --cov-branch --cov-report=term-missing
EXIT_CODE: 0
Output Summary: Pass. 1735 passed (baseline 1679 + 56 new analyzer tests).

Post-change coverage headline (whole repo; denominator `src` + `scripts/dev_tools`):
- Combined coverage reported by pytest-cov TOTAL row: 86%
- Statements: 11428 total, 1322 missed -> line coverage = 88.43%
- Branches: 4248 total, 550 partial -> branch coverage = 87.05%

New analyzer production modules (all 100% line and branch):
- scripts/dev_tools/discovery/analyzer/__init__.py   11 stmts, 0 miss, 4 branch, 0 partial -> 100%
- scripts/dev_tools/discovery/analyzer/__main__.py    2 stmts, 0 miss, 0 branch, 0 partial -> 100%
- scripts/dev_tools/discovery/analyzer/cli.py        47 stmts, 0 miss, 2 branch, 0 partial -> 100%
- scripts/dev_tools/discovery/analyzer/emitter.py    18 stmts, 0 miss, 2 branch, 0 partial -> 100%
- scripts/dev_tools/discovery/analyzer/inventory.py  68 stmts, 0 miss, 16 branch, 0 partial -> 100%
- scripts/dev_tools/discovery/analyzer/models.py     52 stmts, 0 miss, 6 branch, 0 partial -> 100%
- scripts/dev_tools/discovery/analyzer/pipeline.py   42 stmts, 0 miss, 6 branch, 0 partial -> 100%

Type-only `Protocol` stage bodies (`...`) in pipeline.py are excluded from coverage via the
`[tool.coverage.report] exclude_lines` ellipsis pattern, per the spec contract.
