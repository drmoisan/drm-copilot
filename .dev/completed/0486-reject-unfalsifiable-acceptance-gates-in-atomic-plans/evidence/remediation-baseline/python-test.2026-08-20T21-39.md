# Python Coverage Baseline for the Module Being Split — Remediation Cycle 3 (Issue #486)

Timestamp: 2026-08-20T21-39
Task: [P0-T3]
Working directory: worktree root `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-af11eae4f37cb0d9d`

Command: `poetry run pytest -q --cov=scripts.dev_tools.plan_gate_discrimination --cov-branch --cov-report=term-missing tests/scripts/dev_tools`

EXIT_CODE: 0

Coverage table as reported:

```
Name                                            Stmts   Miss Branch BrPart  Cover   Missing
-------------------------------------------------------------------------------------------
scripts\dev_tools\plan_gate_discrimination.py     174      3     74      7    96%   77->exit, 79->exit, 81->exit, 83->exit, 326, 365, 394
-------------------------------------------------------------------------------------------
TOTAL                                             174      3     74      7    96%
```

Output Summary: **3971 passed, 5 skipped, 0 failed** in 12.43s. Coverage of
`scripts/dev_tools/plan_gate_discrimination.py`: statements 174 with 3 missed, branches 74 with 7
partial. Derived numeric percentages — **line coverage 98.28%** ((174 - 3) / 174 = 0.98275) and
**branch coverage 90.54%** ((74 - 7) / 74 = 0.90540). These match the values the remediation inputs
record as the cycle-entry figures and are the combined floor the post-split module pair must meet at
[P3-T4] and [P4-T4]. The `96%` shown in the `Cover` column is pytest-cov's combined
statement-plus-branch figure, not the line percentage. The 5 skips are the pre-existing
`test_parallel_manifest_bash_parity.py` accessor-expectation skips, unrelated to this cycle.
