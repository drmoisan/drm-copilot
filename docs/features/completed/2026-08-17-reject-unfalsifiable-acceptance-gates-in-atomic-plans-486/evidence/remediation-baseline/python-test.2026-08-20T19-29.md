Timestamp: 2026-08-20T19-29
Command: poetry run pytest -q --cov=scripts.dev_tools.validate_orchestration_artifacts --cov-branch --cov-report=term-missing tests/scripts/dev_tools
EXIT_CODE: 0

Output Summary: 3967 passed, 5 skipped in 10.27s.

`scripts/dev_tools/validate_orchestration_artifacts.py`: 148 statements, 5 missing; 56 branches, 5 partial.
- Line coverage: 143/148 covered = 96.62%
- Branch coverage: 51/56 covered = 91.07%
- Missing column: `72, 359, 406, 408, 410, 433->437` — line `359` is confirmed present in the `Missing` column, matching R3's finding (the `plan`-route short-circuit in `_validate_from_args` is uncovered).
