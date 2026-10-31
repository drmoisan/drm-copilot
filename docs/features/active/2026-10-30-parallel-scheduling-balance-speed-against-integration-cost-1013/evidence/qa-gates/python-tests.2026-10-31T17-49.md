# Python tests with coverage (P3-T2)

Timestamp: 2026-10-31T17-49
Command: poetry run pytest tests/scripts/dev_tools/test_blast_radius_combination.py --cov=scripts.dev_tools._blast_radius_combination --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-1013-cov-post.json
EXIT_CODE: 0
Output Summary: 26 passed (baseline 25). Module scripts.dev_tools._blast_radius_combination: line coverage 80/80 = 100 percent (baseline 79/80 = 98.75 percent); branch coverage 23/24 = 95.83 percent (baseline 22/24 = 91.67 percent) from the JSON report. term-missing reports only the partial branch `217->215`; line 246 is now covered.
