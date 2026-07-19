# r2c2 Phase 0 Baseline — Pytest with Coverage

Timestamp: 2026-07-18T22-58

Command: `poetry run pytest --cov --cov-branch --cov-report=term-missing`

EXIT_CODE: 1

Output Summary:
- Result: 1 failed, 2064 passed.
- The single failure is the expected pre-existing blocking finding: `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` (two `.claude` hook files missing from the bundle). This is the defect Phase 1 remediates.
- Coverage totals (TOTAL row): Stmts=12474, Miss=1336, Branch=4530, BrPart=564, combined Cover=87%.
- Derived line coverage = (12474 - 1336) / 12474 = 89.29%.
- Derived branch coverage = (4530 - 564) / 4530 = 87.55%.
- Both derived values exceed the policy thresholds (line >= 85%, branch >= 75%) at baseline.
