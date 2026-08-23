# P6-T26 Expanded Full Coverage

Timestamp: 2026-08-23T03:39:52-04:00

COVERAGE_FILE: `docs/features/active/2026-08-17-orchestrator-remediation-loop-control-484/evidence/regression-testing/.expanded-full-coverage`

Command: `poetry run pytest -o "addopts=" --cov=src --cov=scripts/dev_tools --cov-branch --cov-report=term-missing --cov-report=json:docs/features/active/2026-08-17-orchestrator-remediation-loop-control-484/evidence/regression-testing/p6-t26-expanded-full-coverage.json`

EXIT_CODE: 0

Output Summary: The full suite collected 4,479 tests and completed with 4,474 passed, 5 skipped, and 0 failed. Repository line coverage was 16,023/17,458 (91.780273%) and branch coverage was 5,478/6,542 (83.735861%), above the 85% and 75% thresholds. Both added test files and all five P2-T18/P2-T19 nodes were collected and passed; coverage targets were restricted to `src` and `scripts/dev_tools`, so tests were not counted as application coverage.

Named production-module coverage:

- `_orchestrator_state_codex_topology.py`: 144/144 lines (100%), 77/80 branches (96.25%)
- `_orchestrator_state_codex_model_routing.py`: 115/120 lines (95.833333%), 56/64 branches (87.5%)
- `validate_orchestrator_state.py`: 144/147 lines (97.959184%), 72/76 branches (94.736842%)
- `_orchestrator_state_complexity.py`: 50/50 lines (100%), 22/22 branches (100%)
- `analyze_coverage_policy.py`: 104/173 lines (60.115607%), 21/54 branches (38.888889%)
- `_parallel_orchestrator_state_receipt_cohort.py`: 139/145 lines (95.862069%), 52/58 branches (89.655172%)
- `synchronize_customization_bundles.py`: 104/154 lines (67.532468%), 28/54 branches (51.851852%)
- `generate_codex_agent_variants.py`: 162/182 lines (89.010989%), 53/70 branches (75.714286%)
- `generate_orchestration_customization_surfaces.py`: 184/216 lines (85.185185%), 81/100 branches (81%)
