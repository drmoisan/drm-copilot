# Baseline — Pytest and Coverage (skill_bundle_contract)

Timestamp: 2026-10-10T08-05
Task: [P0-T6]
Command: poetry run pytest tests/scripts/dev_tools/test_skill_bundle_contract.py tests/scripts/dev_tools/test_skill_bundle_contract_repo.py tests/scripts/dev_tools/test_skill_bundle_contract_evaluation.py tests/scripts/dev_tools/test_skill_bundle_contract_cli.py tests/scripts/dev_tools/test_parallel_abandon_token_seam.py --cov=scripts.dev_tools.skill_bundle_contract --cov-branch --cov-report=term-missing --cov-report=json:artifacts/python/skill-bundle-contract-791-baseline.json
EXIT_CODE: 0

Output Summary:
- `57 passed in 0.86s`; 0 failed.
- Term-missing row:
  `scripts\dev_tools\skill_bundle_contract.py     141      5     60      3    96%   109, 216, 245-246, 254`
  (Missing column: `109, 216, 245-246, 254`)
- JSON `totals`: covered_lines 136, num_statements 141, covered_branches 57, num_branches 60.
- Line coverage (covered_lines / num_statements x 100): 136 / 141 = 96.45%.
- Branch coverage (covered_branches / num_branches x 100): 57 / 60 = 95.00%.
- The combined `Cover` column (96%) is not used as either value, per the plan Conventions.
- JSON report path (tool output, not evidence): `artifacts/python/skill-bundle-contract-791-baseline.json`.
