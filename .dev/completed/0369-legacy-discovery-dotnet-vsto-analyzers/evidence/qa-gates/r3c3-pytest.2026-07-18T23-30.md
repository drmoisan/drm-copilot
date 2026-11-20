# r3c3 QA Gate — Pytest (coverage)

Timestamp: 2026-07-18T23-30

Command: `poetry run pytest --cov --cov-branch --cov-report=term-missing`

EXIT_CODE: 0

Output Summary:
- Test result: 2065 passed, 0 failed, 0 skipped in 8.53s.
- TOTAL coverage row: Stmts 12474, Miss 1336, Branch 4530, BrPart 564, Cover 87% (coverage.py combined line+branch metric).
- Derived line coverage: (12474 - 1336) / 12474 = 89.29% (>= 85% threshold: PASS).
- Derived branch coverage: (4530 - 564) / 4530 = 87.55% (>= 75% threshold: PASS).
- The full suite is green, including the contract test `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` (verified separately: 1 passed).
- Values match the Phase 0 baseline exactly; no regression. This cycle adds no Python production code.
