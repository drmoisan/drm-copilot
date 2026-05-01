# Baseline Python Test + Coverage State

**Task:** P0-T5  
**Timestamp:** 2026-04-30T22:00  
**Command:** `poetry run pytest --cov=src --cov=scripts/dev_tools --cov-report=term-missing`  
**EXIT_CODE:** 0  

## Output Summary

- **Test Results:** 1060 passed, 14 skipped
- **Overall Repo-Wide Coverage:** 84% (8024 statements, 1253 missed)

## Converter Package Coverage (codex_native_converter)

| File | Stmts | Miss | Cover | Missing Lines |
|------|-------|------|-------|---------------|
| `__init__.py` | 2 | 0 | 100% | |
| `__main__.py` | 1 | 0 | 100% | |
| `classifier.py` | 79 | 6 | 92% | 84-85, 162, 229, 338, 407 |
| `cli.py` | 44 | 0 | 100% | |
| `engine.py` | 203 | 8 | **96%** | 200, 209, 317, 331, 469, 477, 521, 734 |
| `intermediate_state.py` | 30 | 4 | **87%** | 96, 128, 150, 174 |
| `inventory.py` | 45 | 2 | 96% | 156, 215 |
| `mapping.py` | 48 | 2 | 96% | 164-165 |
| `models.py` | 134 | 1 | **99%** | 586 |
| `parser.py` | 88 | 9 | 90% | 89, 94, 141-142, 174-175, 257-259 |
| `reporting.py` | 117 | 3 | **97%** | 110, 132-133 |
| `rewrites.py` | 46 | 4 | 91% | 75, 81-83 |
| `section_intent.py` | 41 | 10 | **76%** | 163-166, 179-182, 203-204, 214-215, 240-243 |
| `validation.py` | 59 | 1 | 98% | 247 |

## Coverage Targets

| File | Baseline | Target | Gap |
|------|---------|--------|-----|
| `section_intent.py` | **76%** | ≥90% | -14% |
| `intermediate_state.py` | **87%** | ≥90% | -3% |
| `engine.py` | 96% | ≥90% (no regression) | OK |
| `models.py` | 99% | ≥90% (no regression) | OK |
| `reporting.py` | 97% | ≥90% (no regression) | OK |
| Repo-wide | 84% | ≥84% | OK |

## Skipped Tests

14 tests skipped (all `.codex/agents` gitignored unavailability — pre-existing, not a defect).
