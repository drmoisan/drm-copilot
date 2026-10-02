# Final QC: Python Coverage

Timestamp: 2026-09-30T09-54

Plan task: [P2-T4]

QC_PASS: 3

Command: poetry run pytest tests/scripts/dev_tools/test_validate_epic_orchestrator_state.py tests/scripts/dev_tools/test_validate_epic_orchestrator_state_wave_barrier.py tests/scripts/dev_tools/test_validate_epic_orchestrator_state_launch_binding.py tests/scripts/dev_tools/test_validate_epic_orchestrator_state_codex_routing.py tests/scripts/dev_tools/test_validate_epic_orchestrator_state_codex_topology.py --cov=scripts.dev_tools._epic_orchestrator_state_wave_barrier --cov=scripts.dev_tools.validate_epic_orchestrator_state --cov-branch --cov-report=term-missing

EXIT_CODE: 0

Output Summary: 92 passed, 0 failed, 0 errors (baseline [P0-T9] 67 + 25 = 92). Helper module: line 100.00% (35/35), branch 100.00% (16/16), terminal Cover 100%. Validator: line 96.85% (123/127), branch 93.55% (58/62), terminal Cover 96%. All thresholds (line >= 85, branch >= 75) met.

## Summary line (verbatim)

```text
============================= 92 passed in 0.47s ==============================
```

## Coverage rows (verbatim)

```text
Name                                                         Stmts   Miss Branch BrPart  Cover   Missing
--------------------------------------------------------------------------------------------------------
scripts\dev_tools\_epic_orchestrator_state_wave_barrier.py      35      0     16      0   100%
scripts\dev_tools\validate_epic_orchestrator_state.py          127      4     62      4    96%   191, 198, 276, 281
--------------------------------------------------------------------------------------------------------
TOTAL                                                          162      4     78      4    97%
Coverage LCOV written to file artifacts/python/lcov.info
```

## lcov.info derivation (plan rule 5)

Source: `artifacts/python/lcov.info`. `SF:` paths normalized by replacing `\` with `/`.

`SF:scripts\dev_tools\_epic_orchestrator_state_wave_barrier.py` (normalized `scripts/dev_tools/_epic_orchestrator_state_wave_barrier.py`):

- LF: 35
- LH: 35
- BRF: 16
- BRH: 16
- Terminal Cover: 100%

FINAL_PY_HELPER_LINE_PCT: 100.00 (35 / 35 * 100)

FINAL_PY_HELPER_BRANCH_PCT: 100.00 (16 / 16 * 100)

`SF:scripts\dev_tools\validate_epic_orchestrator_state.py` (normalized `scripts/dev_tools/validate_epic_orchestrator_state.py`):

- LF: 127
- LH: 123
- BRF: 62
- BRH: 58
- Terminal Cover: 96%

FINAL_PY_VALIDATOR_LINE_PCT: 96.85 (123 / 127 * 100)

FINAL_PY_VALIDATOR_BRANCH_PCT: 93.55 (58 / 62 * 100)

## Result

PASS: EXIT_CODE 0; summary has no `failed` or `error` count; passed count 92 equals 67 + 25; every line percentage >= 85 and every branch percentage >= 75.
