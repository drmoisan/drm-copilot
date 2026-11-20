# Pytest Phase 0 Baseline ([P0-T7])

Timestamp: 2026-11-19T07-59
Plan: plan.2026-10-30T18-39.md
Command: env -u VIRTUAL_ENV sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest --cov --cov-branch --cov-report=term-missing:skip-covered --cov-report=json:SCRATCH/pytest-baseline.json --junitxml=SCRATCH/pytest-baseline.xml -q
EXIT_CODE: 0
Output Summary: 17122 passed, 0 failed, 6 skipped in 161.42s (one `pytest -n auto` run over the configured `testpaths` with the integration and golden lanes excluded by the launcher). Repository-wide coverage (JSON report totals): line 98.00% (35359/36079), branch 95.46% (13091/13714), combined 97.30%. `scripts/dev_tools/agentic_sync.py`: line 98.02% (99/101), branch 94.12% (32/34), combined 97.04%; missing lines 208 and 363.
