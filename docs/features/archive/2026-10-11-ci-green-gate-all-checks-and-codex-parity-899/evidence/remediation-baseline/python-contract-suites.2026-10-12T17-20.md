# Baseline Contract Suites (P0-T9, remediation cycle 2)

Timestamp: 2026-10-12T17-59

Command: poetry run pytest tests/scripts/dev_tools/test_ci_gate_all_checks_contracts.py tests/scripts/dev_tools/test_ci_gate_epic_child_contracts.py tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py tests/scripts/dev_tools/test_skill_bundle_contract_repo.py tests/scripts/dev_tools/test_generate_codex_agent_variants.py tests/scripts/dev_tools/test_orchestrator_state_remediation_docs.py tests/scripts/dev_tools/test_parallel_orchestrator_permission_contracts.py tests/scripts/dev_tools/test_parallel_planner_surface_contracts.py tests/scripts/dev_tools/test_parallel_complexity_routing_contracts.py tests/scripts/dev_tools/test_parallel_issue_adoption_skill_contracts.py tests/scripts/dev_tools/test_claude_rules_frontmatter.py -q

EXIT_CODE: 1

ExpectedExitCode: 1

Output Summary:
- Final summary line (verbatim): `1 failed, 251 passed in 1.31s`
- Only FAILED line (verbatim): `FAILED tests/scripts/dev_tools/test_parallel_orchestrator_permission_contracts.py::test_every_prescribed_command_invocation_has_a_persona_bash_grant`
- The failed node is RED-NODE, the R-2 defect this plan remediates. KL-510 did not fail in this run.
- Assertion excerpt (verbatim): `AssertionError: the parallel-orchestrate procedure prescribes a command invocation no parallel-orchestrator Bash grant covers: ('pwsh -NoProfile -File .claude/lib/ci-gate/Invoke-CiGateParser.ps1 -ChecksJson <checks-json> -HeadSha <headRefOid>', 'no checks reported').`
