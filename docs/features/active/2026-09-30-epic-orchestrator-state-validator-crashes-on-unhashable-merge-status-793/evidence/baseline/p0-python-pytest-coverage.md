# P0-T11 Python pytest coverage baseline

Timestamp: 2026-10-09T20-04
Command: poetry run pytest tests/scripts/dev_tools/test_validate_epic_orchestrator_state.py --cov=scripts.dev_tools.validate_epic_orchestrator_state --cov-branch --cov-report=term-missing
EXIT_CODE: 0
Output Summary:
- N_base: 32 (32 passed in 0.16s)
- Terminal Cover value for the validate_epic_orchestrator_state.py row: 82% (combined line plus branch; Stmts 127, Miss 19, Branch 62, BrPart 9)
- Missing column: 191, 198, 276, 281, 318-338, 405, 411, 418, 420, 422
- Derived from artifacts/python/lcov.info (SF record tail scripts/dev_tools/validate_epic_orchestrator_state.py): LF 127, LH 108, BRF 62, BRH 47
- Line percent: 85.04 (108 / 127 * 100)
- Branch percent: 75.81 (47 / 62 * 100)

```
collected 32 items

tests\scripts\dev_tools\test_validate_epic_orchestrator_state.py ....... [ 21%]
.........................                                                [100%]

Name                                                    Stmts   Miss Branch BrPart  Cover   Missing
---------------------------------------------------------------------------------------------------
scripts\dev_tools\validate_epic_orchestrator_state.py     127     19     62      9    82%   191, 198, 276, 281, 318-338, 405, 411, 418, 420, 422
---------------------------------------------------------------------------------------------------
TOTAL                                                     127     19     62      9    82%
Coverage LCOV written to file artifacts/python/lcov.info
============================= 32 passed in 0.16s ==============================
```
