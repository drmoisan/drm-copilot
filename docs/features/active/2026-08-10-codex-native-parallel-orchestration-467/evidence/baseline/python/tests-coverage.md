# Python Tests and Coverage Baseline

Timestamp: 2026-08-12T05-12

Command: `$env:COVERAGE_FILE='docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/baseline/python/.coverage'; poetry run pytest -o "addopts=" -q --cov --cov-branch --cov-report=term-missing --cov-report=json:docs/features/active/2026-08-10-codex-native-parallel-orchestration-467/evidence/baseline/python/coverage.json`

EXIT_CODE: 0

Output Summary: Pytest passed 3,934 tests and skipped 5 tests in 15.38 seconds. Repository line coverage was 92.16381812318608% (14,290 covered lines out of 15,505 statements), and repository branch coverage was 84.24515235457064% (4,866 covered branches out of 5,776). Coverage JSON and the coverage data file were retained in this canonical evidence directory.

## Required per-file line baselines

Line coverage is calculated from covered executable lines divided by statements, using the `percent_statements_covered` value in `coverage.json`. Exact uncovered executable lines are listed for attribution.

| Status | Production path | Covered/statements | Line coverage | Exact uncovered lines |
|---|---|---:|---:|---|
| Added; at or above 90% | `scripts/dev_tools/_parallel_orchestrator_state_completion_receipts.py` | 91/100 | 91.00000000000000% | 35, 87, 89, 95, 106, 110, 128, 151, 203 |
| Added; at or above 90% | `scripts/dev_tools/_parallel_orchestrator_state_mutation_receipts.py` | 131/143 | 91.60839160839161% | 60, 97, 100, 101, 126, 133, 181, 186, 205, 224, 228, 287 |
| Added; below 90% | `scripts/dev_tools/parallel_codex_readiness_filesystem.py` | 147/173 | 84.97109826589596% | 49, 72, 73, 78, 79, 84, 85, 90, 91, 186, 190, 197, 198, 201, 205, 209, 214, 218, 252, 253, 255, 267, 290, 292, 320, 323 |
| Added; below 90% | `scripts/dev_tools/push_down_codex_routing_merge.py` | 87/101 | 86.13861386138613% | 40, 41, 45, 62, 63, 71, 72, 83, 105, 106, 107, 119, 184, 185 |
| Added; below 90% | `scripts/dev_tools/validate_parallel_codex_readiness.py` | 173/200 | 86.50000000000000% | 131, 135, 156, 171, 174, 192, 193, 198, 200, 204, 220, 251, 257, 263, 265, 283, 288, 292, 310, 351, 358, 362, 368, 377, 403, 407, 426 |
| Modified; P9-T4 threshold | `scripts/dev_tools/parallel_kickoff_contract.py` | 104/106 | 98.11320754716981% | 374, 378 |
| Modified; P9-T4 threshold | `scripts/dev_tools/resolve_codex_deployment.py` | 89/90 | 98.88888888888889% | 233 |
| Modified; P9-T4 threshold | `scripts/dev_tools/resolve_codex_topology.py` | 107/108 | 99.07407407407408% | 250 |

The five added-file coverage gaps are attributable to the exact uncovered lines above. The three modified-file percentages are the individual no-regression thresholds for P9-T4.
