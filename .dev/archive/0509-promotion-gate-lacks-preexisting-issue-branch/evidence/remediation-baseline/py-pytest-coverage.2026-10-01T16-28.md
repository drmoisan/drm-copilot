# Baseline Full Python Suite with Coverage (Remediation Cycle 1)

Timestamp: 2026-10-01T16-28
Task: [P0-T11]
Location: worktree root

## Issue #510 state step

Command: `rm -f .claude/state/python-batch-budget.*.json .claude/state/powershell-batch-budget.*.json`
EXIT_CODE: 0
Output Summary: no output.

Command: `find .claude -maxdepth 2 -name "*-batch-budget.*.json"`
EXIT_CODE: 0
Output Summary: printed nothing (no batch-budget state file remains). No Write or Edit occurred between this step and the pytest command.

## Full suite

Command: `poetry run pytest --cov=scripts.dev_tools --cov-branch --cov-report=term-missing --cov-report=json:docs/features/active/2026-08-22-promotion-gate-lacks-preexisting-issue-branch-509/evidence/remediation-baseline/py-full-coverage.json`
EXIT_CODE: 0

Output Summary:

- Pytest summary line: `================= 6029 passed, 6 skipped in 76.27s (0:01:16) ==================`
- `RB_FULL_PASSED` = 6029 (6 skipped).
- `RB_FULL_FAILED` = {} (empty set; no failed test, no #510 condition observed).
- `term-missing` TOTAL row (verbatim):

```text
TOTAL                                                                 17144   1117   6174    574    92%
```

- JSON `totals`:
  - `RB_FULL_LINE` = covered_lines / num_statements = 16027 / 17144 = 93.5%
  - `RB_FULL_BRANCH` = covered_branches / num_branches = 5348 / 6174 = 86.6%
