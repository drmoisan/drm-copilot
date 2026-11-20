# Baseline — Production Coverage Comparison Value (scripts.dev_tools)

Timestamp: 2026-10-12T23-30
Command: COVERAGE_FILE=artifacts/.coverage-902 poetry run pytest tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py tests/scripts/dev_tools/test_codex_full_migration_inventory.py tests/scripts/dev_tools/test_skill_bundle_contract_repo.py tests/scripts/dev_tools/test_epic_bounded_child_return_contract.py tests/scripts/dev_tools/test_orchestrator_state_remediation_docs.py tests/scripts/dev_tools/test_epic_run_kickoff_discovery_contract.py --cov=scripts.dev_tools --cov-branch --cov-report=term-missing --cov-report=lcov:artifacts/python/lcov-902.info --cov-fail-under=0 -q -p no:cacheprovider
EXIT_CODE: 0
Output Summary:
- Test result: `98 passed in 5.95s`.
- TOTAL row as printed: Stmts 17636, Miss 16896, Branch 6366, BrPart 20, Cover 4%.
- Statement line coverage = (17636 - 16896) / 17636 = 740 / 17636 = 4.20%.
- This is a like-for-like comparison value over a subset run, not a repository threshold measurement; no production module changes in this plan.

Verbatim header and TOTAL row:

```text
Name                                                                  Stmts   Miss Branch BrPart  Cover   Missing
TOTAL                                                                 17636  16896   6366     20     4%
Coverage LCOV written to file artifacts/python/lcov-902.info
98 passed in 5.95s
```
