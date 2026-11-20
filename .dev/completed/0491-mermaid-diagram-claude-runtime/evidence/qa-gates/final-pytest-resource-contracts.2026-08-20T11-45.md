# Final QA Gate: pytest resource contracts (issue #491, [P7-T7])

Timestamp: 2026-08-20T11-45

Command: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -q`
EXIT_CODE: 0
Output Summary: `10 passed in 0.13s`. Precondition applied: the session batch-budget state file was deleted immediately before the run, because this suite enumerates repo `.claude/**` via rglob without reading .gitignore. Pairs with the [P5-T1] failing run. AC-19 final evidence.
