# Baseline Python coverage (P0-T2)

Timestamp: 2026-10-31T17-47
Command: poetry run pytest tests/scripts/dev_tools/test_blast_radius_combination.py --cov=scripts.dev_tools._blast_radius_combination --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-1013-cov-base.json
EXIT_CODE: 0
Output Summary: 25 passed. Module scripts.dev_tools._blast_radius_combination: line coverage 79/80 = 98.75 percent; branch coverage 22/24 = 91.67 percent (JSON report). term-missing: `217->215, 246`; the only missing line is 246, the duplicate-key `raise ValueError`.
