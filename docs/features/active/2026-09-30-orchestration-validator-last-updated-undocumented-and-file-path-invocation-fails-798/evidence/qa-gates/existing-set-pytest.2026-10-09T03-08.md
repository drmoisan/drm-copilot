# P6-T5 Final EXISTING-SET Pytest

Timestamp: 2026-10-09T03-08
Command: poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_skill_bundle_contract_repo.py tests/scripts/dev_tools/test_orchestrator_state_remediation_docs.py tests/scripts/dev_tools/test_orchestrator_state_blocked_reason.py tests/scripts/dev_tools/test_validate_orchestrator_state_cli.py tests/scripts/dev_tools/test_validate_orchestration_artifacts.py tests/scripts/dev_tools/test_validate_orchestration_artifacts_codex_topology_cli.py tests/scripts/dev_tools/test_validate_orchestration_artifacts_dispatch.py tests/scripts/dev_tools/test_validate_orchestration_artifacts_model_routing.py tests/scripts/dev_tools/test_validate_orchestration_artifacts_parallel_dispatch.py tests/scripts/dev_tools/test_validate_orchestration_artifacts_plan_gates.py tests/scripts/dev_tools/test_validate_orchestration_artifacts_pr_creation_readiness.py tests/scripts/dev_tools/test_validate_orchestration_artifacts_state_shape.py tests/scripts/dev_tools/test_parallel_complexity_routing_contracts.py tests/scripts/dev_tools/test_orchestration_guardrail_contracts.py tests/scripts/dev_tools/test_claude_rules_frontmatter.py
EXIT_CODE: 0
Output Summary:
- Loop iteration: 1
- Summary line: `============================= 196 passed in 1.51s =============================`
- Passed count 196 = BASELINE_EXISTING_PASSED 196 + 0 (P0-T11 KL-510) - 0 (this run KL-510)
- PASSED tests/scripts/dev_tools/test_skill_bundle_contract_repo.py::test_every_skill_script_reference_is_bundled
- PASSED tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_handoff_runtime_has_bundle_pack_and_effective_install_parity
- PASSED tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts (not KL-510)
- No FAILED lines.
- Note: invoked with an added `-rA` report flag so per-test PASSED lines are printed; selection and outcome are unchanged.
- Result: PASS
