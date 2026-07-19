# Final QC — Pytest with Coverage (Issue #369, Remediation Cycle 4)

- Timestamp: 2026-07-19T00-23
- Task: [P2-T5]

## Command

```
poetry run pytest --cov --cov-branch --cov-report=term-missing
```

## EXIT_CODE

0

## Output Summary

- Test result: 2065 passed, 0 failed, 0 skipped.
- Coverage totals (TOTAL row): Stmts 12474, Miss 1336, Branch 4530, BrPart 564, combined Cover 87%.
- Derived line coverage: (12474 - 1336) / 12474 = 89.29% (>= 85% threshold: PASS).
- Derived branch coverage: (4530 - 564) / 4530 = 87.55% (>= 75% threshold: PASS).
- Values are identical to the Phase 0 baseline (`evidence/remediation-baseline/r4c4-phase0-pytest-baseline.2026-07-19T00-23.md`); this cycle added no Python production code, so no coverage change is expected.
- Bundle contract test confirmation: `test_bundled_claude_payload_contains_all_repo_runtime_contracts` remains green (part of the 2065 passing tests; independently re-verified in Phase 0 as 1 passed).
