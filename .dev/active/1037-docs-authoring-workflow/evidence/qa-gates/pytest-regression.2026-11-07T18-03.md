# Python Regression Gate at the Merged Head (remediation [P2-T5])

Timestamp: 2026-11-07T18-03
Command: sh SCRATCH/issue-1037-pyfull.sh remfinal (`env -u VIRTUAL_ENV poetry run pytest -n auto -q -rfE -p no:cacheprovider --junitxml=SCRATCH/issue-1037-pyfull-remfinal.xml --cov --cov-branch --cov-report=json:SCRATCH/issue-1037-pycov-remfinal.json --cov-report=term`, the quality-checks7 shape, from the worktree); per-module counts read from that JUnit report with SCRATCH/issue_1037_junit_modules.py; coverage totals from the JSON report with SCRATCH/issue_1037_pycov_totals.py
EXIT_CODE: 0
Output Summary: One `pytest -n auto` run at the merged head: 16446 passed, 0 failed, 0 errors, 6 skipped (16452 testcases in the JUnit report) in 246.18 s. Line coverage 96.85% (34163/35273), branch coverage 93.90% (12570/13386). Each of the twenty contract-test modules of main plan [P6-T6] reports 0 failures (1011 tests in total across the twenty modules).

Owner directive 2026-11-07: parallel test gates only

## Contract-test modules (from the JUnit report of this run)

| Module | Tests | Failed |
|---|---|---|
| `test_push_down_claude_resource_contracts` | 14 | 0 |
| `test_push_down_codex_and_agents_resource_contracts` | 9 | 0 |
| `test_push_down_claude_pack_manifest_completeness` | 2 | 0 |
| `test_push_down_codex_and_agents_pack_manifest_completeness` | 2 | 0 |
| `test_push_down_pack_manifest_dependency_closure` | 18 | 0 |
| `test_codex_agent_wrapper_contracts` | 7 | 0 |
| `test_codex_handoff_contract_parity` | 5 | 0 |
| `test_claude_rules_frontmatter` | 8 | 0 |
| `test_quality_checks_workflow_contracts` | 9 | 0 |
| `test_push_down_issue_824_follow_ups` | 62 | 0 |
| `test_typescript_toolchain_instruction_contracts` | 15 | 0 |
| `test_codex_full_migration_inventory` | 3 | 0 |
| `test_discovery_publication_contracts` | 32 | 0 |
| `test_orchestration_routing_config_parity` | 1 | 0 |
| `test_codex_topology_policy_config_parity` | 5 | 0 |
| `test_skill_bundle_contract_repo` | 10 | 0 |
| `test_codex_agent_role_schema` | 741 | 0 |
| `test_scratch_location_contracts` | 26 | 0 |
| `test_codex_model_policy_config_parity` | 4 | 0 |
| `test_parallel_orchestrator_surface_contracts` | 38 | 0 |

## Comparison with the contract-test baseline (`evidence/baseline/contract-tests.2026-11-07T16-15.md`)

| Measure | Baseline | Merged head | Change |
|---|---|---|---|
| pytest passed | 16350 | 16446 | +96 (the feature's parametrized rows plus tests brought in by the integration tip) |
| pytest failed / errors | 0 / 0 | 0 / 0 | none |
| pytest skipped | 6 | 6 | none |
| Contract modules (20) failed | 0 | 0 | none |

Failure names absent from the baseline: none (the run has no failure or error). No single-process, shuffle or reversed-order run was made.
