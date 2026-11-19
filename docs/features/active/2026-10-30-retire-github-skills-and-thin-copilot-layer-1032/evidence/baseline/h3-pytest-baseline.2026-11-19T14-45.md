# H3 Pytest Phase 0 Baseline ([P0-T3], GATE-RUN)

Timestamp: 2026-11-19T14-45
Plan: plan-h3-sync-writer-retirement.md
Command: env -u VIRTUAL_ENV sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest --cov --cov-branch --cov-report=term-missing:skip-covered --cov-report=json:SCRATCH/pytest-h3-baseline.json --junitxml=SCRATCH/pytest-h3-baseline.xml -q (one pytest -n auto run through the launcher; integration and golden lanes excluded by the launcher)
EXIT_CODE: 0
Output Summary: 17102 passed, 0 failed, 6 skipped (17108 cases) in 223.61s.
  Repository-wide coverage: line 98.00% (35359/36079), branch 95.46% (13091/13714).
  scripts/dev_tools/push_down_copilot_customizations_rewrites.py: line 98.25% (56/57), branch 90.00% (9/10); missing line set: 1 line.
  test_push_down_copilot_customizations_rewrites.py: 6 tests, 0 failures; test_push_down_copilot_customizations_helpers.py: 16 tests, 0 failures.
