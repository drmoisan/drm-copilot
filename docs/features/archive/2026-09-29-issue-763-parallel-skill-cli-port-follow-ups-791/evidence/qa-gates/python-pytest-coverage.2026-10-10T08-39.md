# Final QC — Pytest and Coverage

Timestamp: 2026-10-10T08-39
Task: [P8-T4] (Phase 8 loop pass 1)
Command: poetry run pytest tests/scripts/dev_tools/test_skill_bundle_contract.py tests/scripts/dev_tools/test_skill_bundle_contract_repo.py tests/scripts/dev_tools/test_skill_bundle_contract_evaluation.py tests/scripts/dev_tools/test_skill_bundle_contract_cli.py tests/scripts/dev_tools/test_parallel_abandon_token_seam.py tests/scripts/dev_tools/test_parallel_mutation_remove_bash_parity.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py tests/scripts/dev_tools/test_parallel_orchestrator_permission_contracts.py tests/scripts/dev_tools/test_parallel_abandon_bash_parity.py tests/scripts/dev_tools/test_parallel_cohort_bash_parity.py --cov=scripts.dev_tools.skill_bundle_contract --cov-branch --cov-report=term-missing --cov-report=json:artifacts/python/skill-bundle-contract-791-final.json
EXIT_CODE: 0

Output Summary:
- `181 passed in 1.42s`; 0 failed.
- Tests that failed in [P0-T7]: none (`python-pytest-contracts.2026-10-10T08-06.md` records an empty failing list), so no post-change status is owed.
- Term-missing row:
  `scripts\dev_tools\skill_bundle_contract.py     141      5     60      3    96%   109, 216, 245-246, 254`
  (Missing column: `109, 216, 245-246, 254`)
- JSON `totals`: covered_lines 136, num_statements 141, covered_branches 57, num_branches 60.
- Line coverage (covered_lines / num_statements x 100): 136 / 141 = 96.45% (threshold 85: met).
- Branch coverage (covered_branches / num_branches x 100): 57 / 60 = 95.00% (threshold 75: met).
- The combined `Cover` column is not used as either value.
- JSON report path (tool output, not evidence): `artifacts/python/skill-bundle-contract-791-final.json`.
