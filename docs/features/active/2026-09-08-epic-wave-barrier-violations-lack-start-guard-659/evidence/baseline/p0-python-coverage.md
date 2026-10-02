# Phase 0 Python Coverage Baseline

Timestamp: 2026-09-30T09-33

Plan task: [P0-T9]

Command: poetry run pytest tests/scripts/dev_tools/test_validate_epic_orchestrator_state.py tests/scripts/dev_tools/test_validate_epic_orchestrator_state_launch_binding.py tests/scripts/dev_tools/test_validate_epic_orchestrator_state_codex_routing.py tests/scripts/dev_tools/test_validate_epic_orchestrator_state_codex_topology.py --cov=scripts.dev_tools.validate_epic_orchestrator_state --cov-branch --cov-report=term-missing

EXIT_CODE: 0

Output Summary: 67 passed, 0 failed, 0 errors. `validate_epic_orchestrator_state.py` terminal Cover 95%. From lcov.info: line 96.64% (LH 144 / LF 149), branch 93.06% (BRH 67 / BRF 72).

## Final summary line (verbatim)

```text
============================= 67 passed in 0.39s ==============================
```

## Coverage row (verbatim)

```text
Name                                                    Stmts   Miss Branch BrPart  Cover   Missing
---------------------------------------------------------------------------------------------------
scripts\dev_tools\validate_epic_orchestrator_state.py     149      5     72      5    95%   188, 195, 280, 340, 345
---------------------------------------------------------------------------------------------------
TOTAL                                                     149      5     72      5    95%
Coverage LCOV written to file artifacts/python/lcov.info
```

## lcov.info derivation (plan rule 5)

Source: `artifacts/python/lcov.info`. The `SF:` record reads `SF:scripts\dev_tools\validate_epic_orchestrator_state.py`; after replacing `\` with `/` it ends with `scripts/dev_tools/validate_epic_orchestrator_state.py`.

- LF: 149
- LH: 144
- BRF: 72
- BRH: 67
- Terminal Cover: 95%

BASELINE_PY_VALIDATOR_LINE_PCT: 96.64 (144 / 149 * 100)

BASELINE_PY_VALIDATOR_BRANCH_PCT: 93.06 (67 / 72 * 100)

## Result

GREEN: EXIT_CODE 0; summary `67 passed in` with no failed or error count; both percentages numeric.
