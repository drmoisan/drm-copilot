# Final QC: pytest gate (P5-T5)

Timestamp: 2026-11-24T13-06
Command: env -u VIRTUAL_ENV sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest --cov --cov-branch --cov-report=term --cov-report=json:SCRATCH/p5c-py-coverage.json (run from the item worktree root through SCRATCH/issue-1233-gate-py.sh; the launcher runs poetry run pytest -n auto; SCRATCH run p5c-py after the second loop restart)
EXIT_CODE: 0
Output Summary:
- Result: 17126 passed, 6 skipped, 0 failed in 190.41 s (baseline 17104 passed, 6 skipped; no new failing test).
- Repo-wide (JSON report totals): lines 35411/36128 (98.02%), branches 13119/13740 (95.48%); baseline 98.01% and 95.47%.
- scripts/dev_tools/validate_orchestrator_state.py: lines 209/210 (99.52%), branches 99/100 (99%); missing line 135 (pre-existing, line 133 at the baseline). Baseline 170/172 (98.84%) and 80/82 (97.56%).
- An earlier final pass (SCRATCH run p5-py) recorded 98.57% / 97% for this file; the drop was fixed by two corpus cases (final-qa-remediation.2026-11-24T12-54.md).
