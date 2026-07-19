# Phase 0 Baseline — Pytest with Coverage (Issue #369, Remediation Cycle 4)

- Timestamp: 2026-07-19T00-23
- Task: [P0-T6]

## Command

```
poetry run pytest --cov --cov-branch --cov-report=term-missing
```

## EXIT_CODE

0

## Output Summary

- Test result: 2065 passed, 0 failed, 0 skipped.
- Coverage totals (from the TOTAL row): Stmts 12474, Miss 1336, Branch 4530, BrPart 564, combined Cover 87%.
- Derived line coverage: (12474 - 1336) / 12474 = 89.29% (>= 85% threshold: PASS).
- Derived branch coverage: (4530 - 564) / 4530 = 87.55% (>= 75% threshold: PASS).
- Bundle contract test confirmation: `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` PASSES (verified both within the full run and by a targeted re-run: 1 passed).
