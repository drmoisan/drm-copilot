# Baseline Focused Python Tests with Coverage (P0-T10)

Timestamp: 2026-10-09T02-51
Command: poetry run pytest tests/scripts/dev_tools/test_blast_radius_extraction.py tests/scripts/dev_tools/test_blast_radius_extraction_rules.py tests/scripts/dev_tools/test_blast_radius_token_shapes.py tests/scripts/dev_tools/test_blast_radius_write_intent.py tests/scripts/dev_tools/test_blast_radius_parity.py tests/scripts/dev_tools/test_blast_radius_historical_runs.py tests/scripts/dev_tools/test_blast_radius_verification_integrity.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py --cov=scripts.dev_tools._blast_radius_extraction --cov=scripts.dev_tools._blast_radius_token_shapes --cov-branch --cov-report=term-missing --cov-report=json:docs/features/active/2026-09-30-blast-radius-path-extractor-misses-real-plan-writes-797/evidence/baseline/python-coverage-baseline.json
EXIT_CODE: 0
Output Summary: run after the P0-T6 guard printed 0. Final line `274 passed in 27.52s`.
  Name | Stmts | Miss | Branch | BrPart | Cover
  scripts\dev_tools\_blast_radius_extraction.py | 101 | 0 | 46 | 0 | 100%
  scripts\dev_tools\_blast_radius_token_shapes.py | 14 | 0 | 4 | 0 | 100%
  TOTAL | 115 | 0 | 50 | 0 | 100%
