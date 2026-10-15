# Python Dotted-Module Coverage — P8-T8

Timestamp: 2026-09-30T14-50
Task: P8-T8
Working directory: worktree root

## Issue #510 state step

Command: ls -a .claude/state
EXIT_CODE: 2
Output Summary: `ls: cannot access '.claude/state': No such file or directory` (empty listing).

Command: rm -f .claude/state/python-batch-budget.*.json .claude/state/powershell-batch-budget.*.json
EXIT_CODE: 0
Output Summary: no output; no file matched.

Command: ls -a .claude/state
EXIT_CODE: 2
Output Summary: `ls: cannot access '.claude/state': No such file or directory` (empty listing). No Write or Edit occurred between this step and the pytest command.

## Coverage run

Command: poetry run pytest tests/scripts/dev_tools --cov=scripts.dev_tools._orchestrator_state_routing --cov=scripts.dev_tools._orchestrator_state_route_gates --cov=scripts.dev_tools._orchestrator_state_promotion_tools --cov=scripts.dev_tools._orchestrator_state_issue_adoption --cov-branch --cov-report=term-missing --cov-report=json:docs/features/active/2026-08-22-promotion-gate-lacks-preexisting-issue-branch-509/evidence/qa-gates/py-module-coverage.json
EXIT_CODE: 0
Output Summary:
- Summary line: `5753 passed, 6 skipped in 39.14s`; 0 failed (no Issue #510 condition arose).
- `term-missing` rows (verbatim):
```
Name                                                       Stmts   Miss Branch BrPart  Cover   Missing
scripts\dev_tools\_orchestrator_state_issue_adoption.py      113      0     46      0   100%
scripts\dev_tools\_orchestrator_state_promotion_tools.py      10      0      2      0   100%
scripts\dev_tools\_orchestrator_state_route_gates.py          98      8     44      8    89%   126, 131, 136, 225, 274, 323, 366, 380
scripts\dev_tools\_orchestrator_state_routing.py             125      9     68     10    90%   87, 100->98, 114, 119->112, 139, 173, 177-180, 197, 202, 205
TOTAL                                                        346     17    160     18    93%
```
- Per-module percentages from each file's JSON `summary` object (`covered_lines / num_statements`, `covered_branches / num_branches`):

| Module | Line | Branch |
| --- | --- | --- |
| `_orchestrator_state_routing.py` | 116 / 125 = 92.8 | 58 / 68 = 85.3 |
| `_orchestrator_state_route_gates.py` | 90 / 98 = 91.8 | 36 / 44 = 81.8 |
| `_orchestrator_state_promotion_tools.py` | 10 / 10 = 100.0 | 2 / 2 = 100.0 |
| `_orchestrator_state_issue_adoption.py` | 113 / 113 = 100.0 | 46 / 46 = 100.0 |

Every line percentage is at least 85.0 and every branch percentage is at least 75.0.

Result: PASS
