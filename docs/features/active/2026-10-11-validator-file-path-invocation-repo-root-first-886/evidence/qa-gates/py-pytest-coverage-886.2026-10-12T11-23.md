# Final QC tests with coverage (issue #886)

Timestamp: 2026-10-12T11-23

Command: poetry run pytest tests/scripts/dev_tools/test_validate_orchestration_artifacts.py tests/scripts/dev_tools/test_validate_orchestration_artifacts_codex_topology_cli.py tests/scripts/dev_tools/test_validate_orchestration_artifacts_dispatch.py tests/scripts/dev_tools/test_validate_orchestration_artifacts_invocation.py tests/scripts/dev_tools/test_validate_orchestration_artifacts_model_routing.py tests/scripts/dev_tools/test_validate_orchestration_artifacts_parallel_dispatch.py tests/scripts/dev_tools/test_validate_orchestration_artifacts_plan_gates.py tests/scripts/dev_tools/test_validate_orchestration_artifacts_pr_creation_readiness.py tests/scripts/dev_tools/test_validate_orchestration_artifacts_state_shape.py tests/scripts/dev_tools/test_validate_orchestrator_state_cli.py tests/scripts/dev_tools/test_validate_epic_planner_state.py tests/scripts/dev_tools/test_validate_epic_orchestrator_state_merge_status.py tests/scripts/dev_tools/test_plan_gate_parity.py tests/scripts/dev_tools/test_orchestrator_state_required_keys_docs.py --cov=scripts.dev_tools.validate_orchestration_artifacts --cov-branch --cov-report=term-missing --cov-report=json:docs/features/active/2026-10-11-validator-file-path-invocation-repo-root-first-886/evidence/qa-gates/coverage-final-886.json

EXIT_CODE: 0

Output Summary:
- Result line: `198 passed in 1.71s` (no failed count); equals the P0-T7 count 196 plus 2.
- Dispatcher term-missing row: `scripts\dev_tools\validate_orchestration_artifacts.py  Stmts 149  Miss 3  Branch 56  BrPart 4  Cover 97%  Missing 409, 411, 413, 436->440`
- From coverage-final-886.json totals: num_statements=149, covered_lines=146, num_branches=56, covered_branches=52.
- Derived line coverage: 146/149 = 97.99% (>= 85.0%).
- Derived branch coverage: 52/56 = 92.86% (>= 75.0%).
- Side effect: pytest addopts wrote artifacts/python/lcov.info (untracked artifacts path; never staged).
