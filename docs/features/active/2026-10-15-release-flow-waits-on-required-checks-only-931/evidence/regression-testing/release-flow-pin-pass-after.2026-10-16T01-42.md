# Release-Flow Pin Pass-After (Issue #931)

Timestamp: 2026-10-16T01-42
Command: poetry run pytest tests/scripts/dev_tools/test_ci_gate_all_checks_contracts.py::test_release_flow_waits_on_every_check_without_required_wording -q
EXIT_CODE: 0
Output Summary: PASS. Summary line `1 passed in 0.20s`. The same node recorded `1 failed` before the script edit (release-flow-pin-fail-before.2026-10-16T01-29.md).

Output (tail):

```
.                                                                        [100%]
1 passed in 0.20s
```

This run verifies the pin clauses of P1-T4 (fragment `every GitHub check on the pull request head`), P1-T5 (fragment `every check on the pull request head`), and P1-T9 (fragment `@('pr', 'checks', $PrNumber, '--json', 'bucket')` and absence of `--required`).
