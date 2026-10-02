# Split Suites — Routing Suites and Split Test Against the Split Code

Timestamp: 2026-09-30T14-13
Task: P1-T6
Working directory: worktree root

Command: poetry run pytest tests/scripts/dev_tools/test_validate_orchestrator_state_routing_contract.py tests/scripts/dev_tools/test_validate_orchestrator_state_preparation_route.py tests/scripts/dev_tools/test_orchestrator_state_routing_split.py --cov=scripts.dev_tools._orchestrator_state_routing --cov=scripts.dev_tools._orchestrator_state_route_gates --cov=scripts.dev_tools._orchestrator_state_promotion_tools --cov-branch --cov-report=term-missing
EXIT_CODE: 0
Output Summary:
- Summary line: `============================= 62 passed in 0.34s ==============================`
- Failed: 0
- Passed: 62 = PY_ROUTING_BASELINE_PASSED (29) + 33 (split test) = 29 + 33 = 62. Matches.
- term-missing rows (verbatim):
  - `scripts\dev_tools\_orchestrator_state_promotion_tools.py      10      0      2      0   100%`
  - `scripts\dev_tools\_orchestrator_state_route_gates.py          98     11     44     11    85%   126, 131, 136, 225, 274, 315, 323, 361, 366, 377, 380`
  - `scripts\dev_tools\_orchestrator_state_routing.py             120     15     66     16    83%   72, 84, 97->95, 108, 111, 116->109, 133, 136, 157, 168, 170, 174-177, 194, 199, 202, 223`
- Note: these targeted suites exercise only the routing contract; the route-gate helpers are exercised more broadly by other suites in the full run. The task's acceptance requires the pass count and the rows, not a threshold.

## Re-runs (toolchain loop restarts)

The same command was re-run twice more after the P1-T10 Black reformat and the P1-T11 Ruff TC003 fix to the test file. Both re-runs: EXIT_CODE 0, `62 passed`, identical term-missing rows. Final re-run summary line: `============================= 62 passed in 0.34s ==============================`.

Result: PASS
