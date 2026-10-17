# Python Targeted Routing Coverage Baseline (P0-T15)

Timestamp: 2026-09-30T13-52
Task: [P0-T15]
Location: worktree root

Command: poetry run pytest tests/scripts/dev_tools/test_validate_orchestrator_state_routing_contract.py tests/scripts/dev_tools/test_validate_orchestrator_state_preparation_route.py --cov=scripts.dev_tools._orchestrator_state_routing --cov-branch --cov-report=term-missing --cov-report=json:docs/features/active/2026-08-22-promotion-gate-lacks-preexisting-issue-branch-509/evidence/baseline/py-routing-coverage.json
EXIT_CODE: 0
Output Summary:
- Pytest summary: `29 passed in 0.30s` (29 collected; 0 failed).
- PY_ROUTING_BASELINE_PASSED = 29
- `term-missing` row (verbatim):
  `scripts\dev_tools\_orchestrator_state_routing.py     219     26    112     27    84%   92, 97, 102, 191, 240, 281, 289, 327, 332, 343, 346, 416, 428, 441->439, 452, 455, 460->453, 477, 480, 501, 512, 514, 518-521, 538, 543, 546, 567`
- JSON report: `docs/features/active/2026-08-22-promotion-gate-lacks-preexisting-issue-branch-509/evidence/baseline/py-routing-coverage.json`. The `files` key for the module is `scripts\\dev_tools\\_orchestrator_state_routing.py` (matched by suffix `_orchestrator_state_routing.py`). Its `summary` object: `covered_lines` 193, `num_statements` 219, `covered_branches` 85, `num_branches` 112.
- Line percentage: 193 / 219 = 0.88128 -> 88.1%
- Branch percentage: 85 / 112 = 0.75893 -> 75.9%
