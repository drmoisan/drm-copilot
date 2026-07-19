# r2c2 Final QC — Pytest with Coverage

Timestamp: 2026-07-18T22-58

Command: `poetry run pytest --cov --cov-branch --cov-report=term-missing`

EXIT_CODE: 0

Output Summary:
- Result: 2065 passed, 0 failed, 0 skipped. Full suite is green.
- The previously-failing `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` now PASSES; the whole module (7 tests) passes.
- Coverage totals (TOTAL row): Stmts=12474, Miss=1336, Branch=4530, BrPart=564, combined Cover=87%.
- Derived line coverage = (12474 - 1336) / 12474 = 89.29%.
- Derived branch coverage = (4530 - 564) / 4530 = 87.55%.
- Both values exceed policy thresholds (line >= 85%, branch >= 75%).
- Coverage is unchanged from the Phase 0 baseline because no Python production code was added or modified; the change adds two byte-identical PowerShell resource files and mirrors one JSON settings file into the bundle payload only.
