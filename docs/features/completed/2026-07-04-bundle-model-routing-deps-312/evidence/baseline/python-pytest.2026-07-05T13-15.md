# Python Test + Coverage Baseline — Issue #312

Timestamp: 2026-07-05T13-15
Command: poetry run pytest --cov --cov-branch --cov-report=term-missing
EXIT_CODE: 0

Output Summary:
- Tests: 1298 passed, 0 failed.
- Coverage TOTAL (coverage.py combined line+branch headline): 84%.
  Statements=9252, Missed=1243 => line coverage = (9252-1243)/9252 = 86.6%.
  Branches=3342, BrPart=450 => branch coverage = (3342-450)/3342 = 86.5%.
  The reported combined "Cover" headline is 84% (pre-existing repository baseline; Python production is untouched by this change).
- resolve_delegation_model.py reports 100% coverage; compute_complexity_floor and resolve_delegation_model reference implementations are covered by the untouched dev_tools suite.
- Confirmed passing (explicit re-run, 24 tests, 0 failed): tests/scripts/dev_tools/test_orchestration_routing_config_parity.py, tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py, tests/scripts/dev_tools/test_push_down_claude_pack_selection.py.
