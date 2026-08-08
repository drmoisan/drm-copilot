# Surface-Contract Regression After B2

Timestamp: 2026-08-08T15-25

Task: [P2-T6]
Working directory: repository root

Command: `poetry run pytest tests/scripts/dev_tools/test_parallel_planner_surface_contracts.py tests/scripts/dev_tools/test_parallel_planner_surface_contracts_landed.py -q`

EXIT_CODE: 0

Output Summary: PASS. 23 tests passed, 0 failed, in 0.14s. No text-fragment assertion in either surface-contract module was broken by the [P2-T1] template edit (`parallel/<slug>-plan head commit: <hex>` -> `planning_commit: <hex>`) or the [P2-T2] prose-bullet edit. No assertion required updating, and [P2-T1] was not reverted.

## Raw Output

```
.......................                                                  [100%]
23 passed in 0.14s
```

## Assertion Disposition

The two surface-contract modules assert heading presence and structural fragments of `.claude/skills/parallel-plan/SKILL.md`. Neither asserts the literal text of the integrity commit line, so the field-name correction passed without any assertion change. Had a fragment assertion failed, the correct response per the task text would have been to update the assertion to the corrected template text, never to revert [P2-T1].
