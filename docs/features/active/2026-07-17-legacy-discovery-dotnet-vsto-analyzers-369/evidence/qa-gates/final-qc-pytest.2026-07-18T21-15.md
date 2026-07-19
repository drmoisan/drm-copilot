# Final QC — Pytest Coverage

- Timestamp: 2026-07-18T21-15
- Task: [P6-T4]
- Command: `poetry run pytest --cov --cov-branch --cov-report=term-missing`
- EXIT_CODE: 0

## Output Summary

- Result: 1975 passed, 0 failed.
- TOTAL coverage row: Stmts=12314, Miss=1328, Branch=4512, BrPart=564, Cover=87%.
- Derived post-change line coverage: (12314 - 1328) / 12314 = 89.21%.
- Derived post-change branch coverage: (4512 - 564) / 4512 = 87.50%.

### Per new-module coverage (line %)

| Module | Stmts | Miss | Branch | BrPart | Cover |
| --- | --- | --- | --- | --- | --- |
| scripts/dev_tools/discovery/analyzer/source_text.py | 144 | 0 | 52 | 2 | 99% |
| scripts/dev_tools/discovery/analyzer/dotnet_inventory.py | 126 | 4 | 44 | 4 | 95% |
| scripts/dev_tools/discovery/analyzer/vsto_office.py | 134 | 3 | 60 | 4 | 96% |
| scripts/dev_tools/discovery/analyzer/vsto_patterns.py | 16 | 0 | 0 | 0 | 100% |
| scripts/dev_tools/discovery/analyzer/stack_cli.py | 52 | 3 | 2 | 0 | 94% |

Post-change line coverage 89.21% and branch coverage 87.50% both exceed the policy
thresholds (line >= 85%, branch >= 75%). Every new production module is at or above
94% line coverage.
