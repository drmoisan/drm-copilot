# New Python rule tests — full run with coverage — [P2-T10]

Timestamp: 2026-08-26T01-05
Command: `poetry run pytest tests/scripts/dev_tools/test_plan_gate_observability.py tests/scripts/dev_tools/test_plan_gate_observability_boundaries.py --cov-branch --cov-report=term-missing --cov=scripts.dev_tools.plan_gate_observability`
EXIT_CODE: 0

Output Summary:
**28 passed, 0 failed.** 17 cases from
`tests/scripts/dev_tools/test_plan_gate_observability.py` plus 11 cases from
`tests/scripts/dev_tools/test_plan_gate_observability_boundaries.py`. The
printed terminal table reports the `plan_gate_observability.py` row at
**96%** `Cover` (139 statements, 4 missed; 62 branches, 5 partial), which is at
or above the 85% line threshold and the 75% branch threshold.

The explicit `--cov-report=term-missing` is passed because the project
`addopts` value supplies only an LCOV reporter, so no terminal table would be
printed otherwise and the recorded percentage would have been unreadable.

## Terminal coverage table

```text
Name                                           Stmts   Miss Branch BrPart  Cover   Missing
------------------------------------------------------------------------------------------
scripts\dev_tools\plan_gate_observability.py     139      4     62      5    96%   250, 397->395, 399, 414, 422
------------------------------------------------------------------------------------------
TOTAL                                            139      4     62      5    96%
```

## Full run output

```text
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0
rootdir: C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a6b0c3b38073271d8
configfile: pyproject.toml
plugins: anyio-4.12.1, cov-7.0.0
collected 28 items

tests\scripts\dev_tools\test_plan_gate_observability.py ................ [ 57%]
.                                                                        [ 60%]
tests\scripts\dev_tools\test_plan_gate_observability_boundaries.py ..... [ 78%]
......                                                                   [100%]
============================= 28 passed in 0.21s ==============================
```

## Uncovered lines, named rather than left implicit

| Line | Source | Why it is not reached by these 28 cases |
| --- | --- | --- |
| 250 | `continue` in `_matching_entry` | The excluded-word skip. No fixture invokes a register tool in its non-writing mode (`black --check`, `ruff check --no-fix`), so the loop never continues past a matched-but-excluded entry. |
| 397->395 | loop-back in `project_addopts` | The double-quoted `addopts` pattern matches on the first iteration for every fixture, so the loop never revisits the header for the single-quoted form. |
| 399 | `return ""` in `project_addopts` | Reached only by a project file whose text is non-empty and declares no `addopts` assignment. |
| 414 | early `return` in `_collect_coverage_reporter` | The terminal-reporter short-circuit is exercised, but coverage attributes the exit to the preceding branch line rather than this statement in one of the two guards. |
| 422 | early `return` in `_collect_coverage_reporter` | As above, for the project-value guard. |

None of the five is a rule decision that a plan author can reach without one of
the above configurations; all four rule outcomes (G7 report, G7 exoneration,
G8, G8b, G9 report, G9 exoneration) are covered by named cases.
