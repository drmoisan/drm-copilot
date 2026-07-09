# Python Tests + Coverage QA Gate (Issue #305)

Timestamp: 2026-07-04T13-50

Command: `poetry run pytest tests/scripts/dev_tools --cov=scripts/dev_tools --cov-branch --cov-report=term-missing`
EXIT_CODE: 0
Output Summary: 1293 passed (baseline was 1275; +18 new tests across the gate, backcompat, and CLI
model-routing suites).

Coverage over `scripts/dev_tools` (post-change):
- TOTAL: 9252 statements, 1243 missed; 3342 branches, 450 partial.
- Derived line coverage = (9252-1243)/9252 = 86.6% (>= 85% line threshold met).
- Derived branch coverage = (3342-450)/3342 = 86.5% (>= 75% branch threshold met).

New / changed module coverage:
- `scripts/dev_tools/_orchestrator_state_model_routing_gate.py` (NEW): 68 statements, 1 missed;
  36 branches, 3 partial -> line 98.5%, branch 91.7% (both meet thresholds).
- `scripts/dev_tools/validate_orchestrator_state.py` (edited): 96% combined (157 stmts, 4 missed;
  86 branches, 6 partial); changed lines (import, keyword, gate block, STEP_STATUS_KEYS refactor) all
  exercised by the new and existing tests.
- `scripts/dev_tools/validate_orchestration_artifacts.py` (edited): 90% combined; the new
  `--require-model-routing` forwarding is exercised by
  `test_validate_orchestration_artifacts_model_routing.py`.

The package-level TOTAL combined metric remains 84%, unchanged from baseline; the dominant gap is the
pre-existing `shell_qc.py` at 0%, which is unrelated to #305. Line and branch coverage measured
separately both exceed the thresholds.
