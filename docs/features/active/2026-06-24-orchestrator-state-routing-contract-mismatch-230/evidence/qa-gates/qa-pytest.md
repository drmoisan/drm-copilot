# QA Gate — Pytest with Coverage

Timestamp: 2026-06-24T17-55

Command: poetry run pytest --cov --cov-branch --cov-report=term-missing

EXIT_CODE: 0

Output Summary:
- Tests: 1169 passed, 19 skipped, 0 failed.
  (One more passing test than baseline's 1168; the added test is
  tests/scripts/dev_tools/test_orchestration_routing_config_parity.py.)
- TOTAL coverage row: Stmts=8391, Miss=1218, Branch=2994, BrPart=420.
- Line coverage (TOTAL): 83%.
- Branch coverage (TOTAL): (2994 - 420) / 2994 = 85.97% (~86%).
- Routing module scripts/dev_tools/_orchestrator_state_routing.py:
  Stmts=128, Miss=10, Branch=68, BrPart=11, coverage 89% (unchanged vs baseline).

Loop status: A single clean pass of black -> ruff -> pyright -> pytest
completed after the bundled-mirror sync of .claude/skills/orchestrate/SKILL.md.
No stage changed files or failed on the final pass.

Coverage threshold note: TOTAL line coverage of 83% is the pre-existing
branch baseline (also 83%). No production Python source was changed by this
work (changes are JSON config, Markdown, and tests), so the changed-source set
contains no coverage-measured production lines. There is no coverage regression
versus baseline; the routing module coverage is identical at 89%.
