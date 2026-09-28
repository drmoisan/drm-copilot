# Final QC — new Python module coverage — [P8-T5]

Timestamp: 2026-08-26T10-32
Task: [P8-T5]
Command: `poetry run pytest tests/scripts/dev_tools/test_plan_gate_observability.py tests/scripts/dev_tools/test_plan_gate_observability_boundaries.py --cov-branch --cov-report=term-missing --cov=scripts.dev_tools.plan_gate_observability`
Working directory: `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a2c2e891a6977ab65`
EXIT_CODE: 0

Output Summary: **28 passed**, 0 failed, in 0.27s — the 17 cases of `test_plan_gate_observability.py` plus the 11 cases of `test_plan_gate_observability_boundaries.py`. The `Cover` value for the `plan_gate_observability.py` row is **96%**, which is at or above the required 85. The terminal reporter's missing-line list for that row is `250, 397->395, 399, 414, 422`.

The exit code was captured directly with `echo "EXIT=$?"` immediately after the redirect. No pipe stands between the command and the capture.

The coverage target is supplied as the importable dotted name `scripts.dev_tools.plan_gate_observability`, in the `=` form. A filesystem-path spelling would collect no data and the threshold asserted against it could not fail.

This is the second pass of Phase 8; the restart and its cause are recorded in `docs/features/active/2026-08-23-plan-acceptance-gates-miss-unobservable-and-ambient-state-gates-519/evidence/qa-gates/python-format-final.2026-08-24T00-00.md`.

## The coverage table, verbatim

```text
Name                                           Stmts   Miss Branch BrPart  Cover   Missing
------------------------------------------------------------------------------------------
scripts\dev_tools\plan_gate_observability.py     139      4     62      5    96%   250, 397->395, 399, 414, 422
------------------------------------------------------------------------------------------
TOTAL                                            139      4     62      5    96%
```

| Quantity | Value |
| --- | --- |
| Statements | 139 |
| Missed statements | 4 |
| Branches | 62 |
| Partial branches | 5 |
| `Cover` | 96% |
| Required minimum | 85 |
| Missing-line list | `250, 397->395, 399, 414, 422` |

## Summary line, verbatim

```text
============================= 28 passed in 0.27s ==============================
```

## Verdict

**PASS.** Exit code 0, `28 passed`, and a `Cover` value of 96 for `plan_gate_observability.py`, which is at or above 85. The missing-line list is recorded above. Phase 8 proceeds to [P8-T6].
