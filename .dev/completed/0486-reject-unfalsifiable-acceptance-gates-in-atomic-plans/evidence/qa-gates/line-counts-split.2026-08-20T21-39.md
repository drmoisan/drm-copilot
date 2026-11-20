# Split-Module Line Counts — R6 Closure Check (Issue #486)

Timestamp: 2026-08-20T21-39
Task: [P3-T1]
Working directory: worktree root `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-af11eae4f37cb0d9d`

Command: `wc -l scripts/dev_tools/plan_gate_discrimination.py scripts/dev_tools/plan_gate_coverage.py`

EXIT_CODE: 0

Raw output:

```
  387 scripts/dev_tools/plan_gate_discrimination.py
  243 scripts/dev_tools/plan_gate_coverage.py
  630 total
```

| Module | Lines | <= 450 target | <= 500 ceiling | Margin to ceiling |
| --- | --- | --- | --- | --- |
| `scripts/dev_tools/plan_gate_discrimination.py` | **387** | PASS | PASS | 113 lines |
| `scripts/dev_tools/plan_gate_coverage.py` | **243** | PASS | PASS | 257 lines |

Output Summary: Both post-split modules are at or below the 450-line target and therefore below the
500-line ceiling in `.claude/rules/general-code-change.md` § File Size Limit. The violating module
fell from **505 lines** at the [P0-T2] baseline to **387 lines**, a reduction of 118 lines, closing
finding R6. Neither module is within 100 lines of the ceiling, so an ordinary subsequent edit cannot
immediately recreate the finding. The combined 630 lines exceed the original 505 because the new
module carries the policy-mandated module docstring and the Google-style `Args:`/`Returns:`/`Raises:`
sections that `.claude/rules/self-explanatory-code-commenting.md` requires for every moved function.
