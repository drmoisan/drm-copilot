# Coverage Delta and Threshold Verification

- Timestamp: 2026-07-18T21-15
- Task: [P6-T5]
- Baseline artifact: evidence/baseline/phase0-pytest.2026-07-18T21-15.md
- Post-change artifact: evidence/qa-gates/final-qc-pytest.2026-07-18T21-15.md

## Baseline coverage (pre-change)

- Command: `poetry run pytest --cov --cov-branch --cov-report=term-missing`
- Result: 1839 passed.
- TOTAL: Stmts=11842, Miss=1318, Branch=4354, BrPart=554.
- Line coverage: 88.87%.
- Branch coverage: 87.28%.

## Post-change coverage

- Command: `poetry run pytest --cov --cov-branch --cov-report=term-missing`
- Result: 1975 passed (136 net-new tests).
- TOTAL: Stmts=12314, Miss=1328, Branch=4512, BrPart=564.
- Line coverage: 89.21%.
- Branch coverage: 87.50%.

## New-code (new-module) coverage

| Module | Line coverage |
| --- | --- |
| source_text.py | 99% |
| dotnet_inventory.py | 95% |
| vsto_office.py | 96% |
| vsto_patterns.py | 100% |
| stack_cli.py | 94% |

## Threshold verification

- Post-change line coverage 89.21% >= 85% required: PASS.
- Post-change branch coverage 87.50% >= 75% required: PASS.
- No regression: line coverage rose from 88.87% to 89.21% (+0.34 pts); branch rose
  from 87.28% to 87.50% (+0.22 pts). No coverage regression is attributable to the
  changed lines; the new modules are covered at >= 94% line each.
- New-code coverage: every new production module is at or above 94% line coverage,
  exceeding both the 85% floor and the general-unit-test 90% new-module target.

## Verdict

PASS. Post-change coverage meets all thresholds with no regression; the feature
outcome is not remediation-required.
