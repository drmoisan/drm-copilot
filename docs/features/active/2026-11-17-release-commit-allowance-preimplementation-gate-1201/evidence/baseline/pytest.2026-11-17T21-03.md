# Phase 0 baseline - pytest gate

Timestamp: 2026-11-17T20-57
Command: env -u VIRTUAL_ENV sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest --cov --cov-branch --cov-report=term --cov-report=json:SCRATCH/issue-1201-p0-py-coverage.json --junitxml=SCRATCH/issue-1201-p0-py-junit.xml (one pytest -n auto run, launched from SCRATCH/issue-1201-py-gate.sh inside the worktree)
EXIT_CODE: 0
Output Summary:
- Run window 2026-11-17T20-57 to 2026-11-17T21-01 UTC: 16957 passed, 0 failed, 6 skipped in 260.25 s. Failing tests: none.
- Repo-wide coverage (JSON report totals): lines 35100/35910 = 97.74%; branches 13024/13688 = 95.15%; combined 97.03%.
- scripts/dev_tools/push_down_claude_customizations.py: lines 74/79 = 93.67%; branches 14/16 = 87.50%.
