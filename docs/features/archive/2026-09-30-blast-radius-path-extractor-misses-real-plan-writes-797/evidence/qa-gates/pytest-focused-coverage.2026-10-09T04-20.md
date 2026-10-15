# Focused Python Tests with Coverage, Final (P6-T6, AC-15)

Timestamp: 2026-10-09T04-20
Command: poetry run pytest tests/scripts/dev_tools/test_blast_radius_extraction.py tests/scripts/dev_tools/test_blast_radius_extraction_rules.py tests/scripts/dev_tools/test_blast_radius_token_shapes.py tests/scripts/dev_tools/test_blast_radius_write_intent.py tests/scripts/dev_tools/test_blast_radius_parity.py tests/scripts/dev_tools/test_blast_radius_historical_runs.py tests/scripts/dev_tools/test_blast_radius_verification_integrity.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py --cov=scripts.dev_tools._blast_radius_extraction --cov=scripts.dev_tools._blast_radius_token_shapes --cov-branch --cov-report=term-missing --cov-report=json:docs/features/active/2026-09-30-blast-radius-path-extractor-misses-real-plan-writes-797/evidence/qa-gates/python-coverage-final.json
EXIT_CODE: 0
Output Summary: run after the P0-T6 guard (state directory absent, count 0). Final line `316 passed in 23.57s`; 0 failed.
  Name | Stmts | Miss | Branch | BrPart | Cover | Missing
  scripts\dev_tools\_blast_radius_extraction.py | 97 | 0 | 44 | 0 | 100% |
  scripts\dev_tools\_blast_radius_token_shapes.py | 25 | 0 | 8 | 0 | 100% |
  TOTAL | 122 | 0 | 52 | 0 | 100% |
