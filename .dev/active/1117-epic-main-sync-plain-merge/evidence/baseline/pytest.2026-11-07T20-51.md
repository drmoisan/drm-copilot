Timestamp: 2026-11-07T20-51
Command: env -u VIRTUAL_ENV poetry run pytest -n auto --cov --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-1117-coverage-baseline.json  (PYTHONPATH=packages/discovery-runtime/src)
EXIT_CODE: 0
Output Summary: Phase 0 baseline, one pytest -n auto run: 16213 passed, 0 failed, 6 skipped in 218.08s. No failing tests. Repo-wide coverage computed from the JSON report totals: line = covered_lines/num_statements = 32456/33464 = 96.99 percent; branch = covered_branches/num_branches = 11828/12560 = 94.17 percent (combined terminal TOTAL column prints 96 percent). Per-file production coverage is not applicable: no Python production file is touched by this plan.
