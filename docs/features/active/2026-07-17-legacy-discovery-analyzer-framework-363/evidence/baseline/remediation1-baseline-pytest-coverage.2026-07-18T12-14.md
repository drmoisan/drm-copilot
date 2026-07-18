# Remediation Cycle 1 — Pre-Merge Baseline: Pytest Coverage

Timestamp: 2026-07-18T12-14

Command: poetry run pytest --cov --cov-branch --cov-report=term-missing

EXIT_CODE: 0

Output Summary:
- Tests: 1735 passed, 0 failed (runtime 8.40s).
- Coverage TOTAL row: Stmts=11428, Miss=1322, Branch=4248, BrPart=550, combined Cover=86%.
- Derived line coverage = (11428 - 1322) / 11428 = 88.43%.
- Derived branch coverage = (4248 - 550) / 4248 = 87.05%.
- Both derived figures exceed the mandatory thresholds (line >= 85%, branch >= 75%).
- This is the pre-merge baseline on branch feature/legacy-discovery-analyzer-framework-363 at HEAD cfc17114b8559cf5886a19e33b4280b0f3db1ccb.
