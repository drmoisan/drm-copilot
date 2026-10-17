# P0-T11 Baseline EXISTING-SET Pytest

Timestamp: 2026-10-09T02-59 (corrected to the host-clock reading; the value first written was composed and ahead of the clock)
Command: poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_skill_bundle_contract_repo.py tests/scripts/dev_tools/test_orchestrator_state_remediation_docs.py tests/scripts/dev_tools/test_orchestrator_state_blocked_reason.py tests/scripts/dev_tools/test_validate_orchestrator_state_cli.py tests/scripts/dev_tools/test_validate_orchestration_artifacts.py tests/scripts/dev_tools/test_validate_orchestration_artifacts_codex_topology_cli.py tests/scripts/dev_tools/test_validate_orchestration_artifacts_dispatch.py tests/scripts/dev_tools/test_validate_orchestration_artifacts_model_routing.py tests/scripts/dev_tools/test_validate_orchestration_artifacts_parallel_dispatch.py tests/scripts/dev_tools/test_validate_orchestration_artifacts_plan_gates.py tests/scripts/dev_tools/test_validate_orchestration_artifacts_pr_creation_readiness.py tests/scripts/dev_tools/test_validate_orchestration_artifacts_state_shape.py tests/scripts/dev_tools/test_parallel_complexity_routing_contracts.py tests/scripts/dev_tools/test_orchestration_guardrail_contracts.py tests/scripts/dev_tools/test_claude_rules_frontmatter.py
EXIT_CODE: 0
Output Summary:
- Summary line: `196 passed in 1.84s`
- BASELINE_EXISTING_PASSED = 196
- KL-510: not observed (test_bundled_claude_payload_contains_all_repo_runtime_contracts passed)
- Note: the run was invoked with an added `-q` display flag; it does not change selection or outcome.
- Result: PASS
