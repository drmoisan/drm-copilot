# P6-T26 Python Full Coverage QA Gate

Timestamp: 2026-08-23T04:07:57-04:00

Command: `poetry run pytest -o "addopts=" --cov=src --cov=scripts/dev_tools --cov-branch --cov-report=term-missing --cov-report=json:docs/features/active/2026-08-17-orchestrator-remediation-loop-control-484/evidence/qa-gates/p6-t26-python-coverage.json`

EXIT_CODE: 0

Output Summary: With `COVERAGE_FILE` set to `docs/features/active/2026-08-17-orchestrator-remediation-loop-control-484/evidence/qa-gates/.coverage`, the full suite collected 4,479 tests and completed with 4,474 passed, 5 skipped, and zero failures in 19.28 seconds. Repository line coverage was 16,026/17,461 (91.781685%) and branch coverage was 5,480/6,544 (83.740831%), above the required 85% and 75% floors. Both added validator test files, all five P2-T18/P2-T19 nodes, and both generator test files were collected and passed without assertion changes.

## Required module coverage

| Module | Line coverage | Branch coverage | P0 comparison |
|---|---:|---:|---|
| `_orchestrator_state_codex_topology.py` | 144/144 = 100.000000% | 77/80 = 96.250000% | PASS without regression |
| `_orchestrator_state_codex_model_routing.py` | 115/120 = 95.833333% | 56/64 = 87.500000% | PASS without regression |
| `validate_orchestrator_state.py` | 144/147 = 97.959184% | 72/76 = 94.736842% | added path, changed line covered |
| `_orchestrator_state_complexity.py` | 53/53 = 100.000000% | 24/24 = 100.000000% | added path, changed lines covered |
| `analyze_coverage_policy.py` | 104/173 = 60.115607% | 21/54 = 38.888889% | unchanged |
| `_parallel_orchestrator_state_receipt_cohort.py` | 139/145 = 95.862069% | 52/58 = 89.655172% | numeric post-remediation value |
| `synchronize_customization_bundles.py` | 104/154 = 67.532468% | 28/54 = 51.851852% | numeric post-remediation value |
| `generate_codex_agent_variants.py` | 162/182 = 89.010989% | 53/70 = 75.714286% | numeric post-remediation value |
| `generate_orchestration_customization_surfaces.py` | 184/216 = 85.185185% | 81/100 = 81.000000% | numeric post-remediation value |

All nine required production modules have numeric line and branch coverage without regression from their applicable P0/P2 evidence. The generated-surface modules also pass the changed-code and new-symbol gates in the policy-analysis artifact.
