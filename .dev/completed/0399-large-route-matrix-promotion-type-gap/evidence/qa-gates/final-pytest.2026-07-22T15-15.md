# Final QC — Pytest with Coverage (Issue #399)

Timestamp: 2026-07-22T15-15
Command: `poetry run pytest --cov --cov-branch --cov-report=term-missing`
EXIT_CODE: 0
Output Summary:
- Tests: 2073 passed, 0 failed (baseline 2069 + 4 new routing-contract tests).
- Coverage headline (TOTAL): 88% (statements 12259, missed 1114; branches 4448, partial 564).
- Derived line coverage: (12259 - 1114) / 12259 = 90.9%.
- Derived branch coverage: (4448 - 564) / 4448 = 87.3%.
- Targeted module `scripts/dev_tools/_orchestrator_state_routing.py`: 217 statements, 17 missed, 110 branches, 18 partial, 89%. Statements rose from 210 to 217 (+7 new lines from `_resolve_promotion_entry_tools` and its wiring) while missed count stayed at 17, so every added statement is covered. Branches rose from 108 to 110 (+2) with partial count unchanged at 18, so both added branches are covered.
- All thresholds (>= 85% line, >= 75% branch) satisfied. No regression on changed lines.
