# Python Full-Suite Coverage Baseline (P0-T16)

Timestamp: 2026-09-30T13-54
Task: [P0-T16]
Location: worktree root

## Issue #510 state step (run immediately before pytest; no Write or Edit between this step and the pytest command)

Command: ls -a .claude/state
EXIT_CODE: 2
Output Summary: `ls: cannot access '.claude/state': No such file or directory` (the directory does not exist in this worktree).

Command: rm -f .claude/state/python-batch-budget.*.json .claude/state/powershell-batch-budget.*.json
EXIT_CODE: 0
Output Summary: no output; nothing to delete.

Command: ls -a .claude/state
EXIT_CODE: 2
Output Summary: `ls: cannot access '.claude/state': No such file or directory`.

## Full suite

Command: poetry run pytest --cov=scripts.dev_tools --cov-branch --cov-report=term-missing --cov-report=json:docs/features/active/2026-08-22-promotion-gate-lacks-preexisting-issue-branch-509/evidence/baseline/py-full-coverage.json
EXIT_CODE: 0
Output Summary:
- Pytest summary: `5733 passed, 6 skipped in 112.60s (0:01:52)`.
- Passed 5733, failed 0, skipped 6.
- PY_BASELINE_PASSED = 5733
- Failed node IDs: none. The failed set P8-T9 must reproduce is empty. No #510 condition occurred (`test_bundled_claude_payload_contains_all_repo_runtime_contracts` passed; no `.claude/state/` directory existed).
- Terminal `TOTAL` row (verbatim): `TOTAL  16974   1127   6110    583    92%`
- JSON `totals` object (`docs/features/active/2026-08-22-promotion-gate-lacks-preexisting-issue-branch-509/evidence/baseline/py-full-coverage.json`): `covered_lines` 15847, `num_statements` 16974, `covered_branches` 5275, `num_branches` 6110.
- Line percentage: 15847 / 16974 = 0.93360 -> 93.4%
- Branch percentage: 5275 / 6110 = 0.86334 -> 86.3%
