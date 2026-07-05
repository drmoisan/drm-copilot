# Python Coverage Delta (Issue #305)

Timestamp: 2026-07-04T13-50

Comparison of `evidence/baseline/python-baseline.md` and `evidence/qa-gates/python-tests.md`.

Command (both runs): `poetry run pytest tests/scripts/dev_tools --cov=scripts/dev_tools --cov-branch --cov-report=term-missing`
EXIT_CODE: 0

## Package-level (`scripts/dev_tools`)

| Metric | Baseline | Post-change |
|---|---|---|
| Statements | 9179 | 9252 |
| Missed | 1242 | 1243 |
| Line coverage | 86.5% | 86.6% |
| Branches | 3304 | 3342 |
| Branch partial | 447 | 450 |
| Branch coverage | 86.5% | 86.5% |
| Combined TOTAL (Cover column) | 84% | 84% |

No coverage regression: line coverage improved slightly (86.5% -> 86.6%) and branch coverage held at
86.5%. Both remain above the >= 85% line / >= 75% branch thresholds.

## New / changed-code coverage

- `_orchestrator_state_model_routing_gate.py` (NEW gate module): line 98.5% (67/68), branch 91.7%
  (33/36). Meets >= 85% line / >= 75% branch on the new code.
- `validate_orchestrator_state.py` (edited): 96% combined; the added import, `require_model_routing`
  keyword, gate block, and the `STEP_STATUS_KEYS` DRY refactor are all covered by the existing and
  new orchestrator-state tests.
- `validate_orchestration_artifacts.py` (edited): 90% combined; the new `--require-model-routing`
  flag and forwarding are covered by `test_validate_orchestration_artifacts_model_routing.py`.

Conclusion: no regression on changed lines; new module lines meet the coverage thresholds.
