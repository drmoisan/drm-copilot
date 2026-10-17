# P8-T8 CLI-Module Tests with Coverage

Timestamp: 2026-10-02T03-37
Command: poetry run pytest tests/scripts/dev_tools/test_check_quality_tiers.py --cov=scripts.dev_tools.check_quality_tiers --cov-branch --cov-report=term-missing --cov-report=json:artifacts/python/coverage-check-quality-tiers.json
EXIT_CODE: 0
Output Summary: `14 passed in 0.16s`; no failed count. Term-missing row: `scripts\dev_tools\check_quality_tiers.py  64 stmts, 0 miss, 12 branches, 1 partial, Cover 99%` (partial branch 146->149: the absolute `--file` path case, where the relative-path join is skipped, is not exercised).
