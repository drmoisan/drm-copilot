# P3-T4 Final Python pytest coverage

Timestamp: 2026-10-09T20-21
Command: poetry run pytest tests/scripts/dev_tools/test_validate_epic_orchestrator_state_merge_status.py tests/scripts/dev_tools/test_validate_epic_orchestrator_state.py --cov=scripts.dev_tools.validate_epic_orchestrator_state --cov-branch --cov-report=term-missing
EXIT_CODE: 0
Output Summary:
- 53 passed in 0.31s, no failures (21 new tests plus N_base 32 from P0-T11).
- Terminal Cover value for the validate_epic_orchestrator_state.py row: 92% (combined; Stmts 128, Miss 8, Branch 62, BrPart 8)
- Missing column: 191, 198, 278, 283, 408, 414, 423, 425
- Derived from artifacts/python/lcov.info (SF record tail scripts/dev_tools/validate_epic_orchestrator_state.py): LF 128, LH 120, BRF 62, BRH 54
- Line percent: 93.75 (120 / 128 * 100)
- Branch percent: 87.10 (54 / 62 * 100)

```
collected 53 items

tests\scripts\dev_tools\test_validate_epic_orchestrator_state_merge_status.py . [  1%]
....................                                                     [ 39%]
tests\scripts\dev_tools\test_validate_epic_orchestrator_state.py ....... [ 52%]
.........................                                                [100%]

Name                                                    Stmts   Miss Branch BrPart  Cover   Missing
---------------------------------------------------------------------------------------------------
scripts\dev_tools\validate_epic_orchestrator_state.py     128      8     62      8    92%   191, 198, 278, 283, 408, 414, 423, 425
---------------------------------------------------------------------------------------------------
TOTAL                                                     128      8     62      8    92%
Coverage LCOV written to file artifacts/python/lcov.info
============================= 53 passed in 0.31s ==============================
```
