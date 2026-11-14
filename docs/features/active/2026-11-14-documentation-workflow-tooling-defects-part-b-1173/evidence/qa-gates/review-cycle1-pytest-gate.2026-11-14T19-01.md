# Review Rerun: pytest Coverage Gate (feature review, cycle 1 re-audit)

Timestamp: 2026-11-14T19-01
Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest --cov --cov-branch --cov-report=term (from the item worktree root, through a scratch runner; the launcher runs pytest with xdist workers and the repository addopts write artifacts/python/lcov.info)
EXIT_CODE: 0
Output Summary:
- Reason: the feature-review coverage Stop hook compares artifacts/python/lcov.info with the newest commit touching Python files (the merge commit aea5742dc, 2026-11-14T18:44:43Z); the existing report was written at 2026-11-14T17:44Z, before it.
- Run window (UTC, clock-read): 2026-11-14T18:57:36Z to 2026-11-14T19:00:20Z at head aea5742dc2b628f2c095ce9cf71aa53f18a538de, clean tree. 24 xdist workers.
- 16941 passed, 6 skipped, 0 failed in 160.00 s.
- Repository-configured coverage sources: TOTAL 35910 statements, 810 missed, 13688 branches, 551 partial. From artifacts/python/lcov.info (written 2026-11-14T19:00:11Z): lines 97.74% (35100/35910), branches 95.16% (13025/13688).
- Changed modules: docs_python_native/call_sites.py 105 statements 0 missed, 38 branches 0 partial; cli.py 141 statements 1 missed, 64 branches 1 partial; cli_argparse.py 213 statements 0 missed, 114 branches 1 partial (same figures as the prior review rerun and the final QC run).
