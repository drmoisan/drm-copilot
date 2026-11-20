# Gate — push-down contract tests after the documentation edit (AC23, risk R6)

Timestamp: 2026-08-20T09-53

Task: [P6-T5]

Command: poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py
EXIT_CODE: 0

## Result

```
......                                                                   [ 55%]
tests\scripts\dev_tools\test_push_down_codex_and_agents_resource_contracts.py . [ 61%]
.......                                                                  [100%]

============================= 18 passed in 0.27s ==============================
```

- Passed: 18
- Failed: 0

These are the tests that assert byte identity between each canonical customization tree and its
bundled root. They pass after the three canonical schema edits and the three mirror propagations,
which is the mechanical confirmation that no mirror was left stale (risk R6). Each canonical file and
its mirror were additionally compared byte-for-byte during the propagation step, and each pair
reported `identical=True`.

Output Summary: 18 passed, 0 failed; exit code 0. The push-down contract tests confirm the three
bundled mirrors are byte-identical to their canonical sources after the documentation edit, so the
six-copy fan-out is consistent.
