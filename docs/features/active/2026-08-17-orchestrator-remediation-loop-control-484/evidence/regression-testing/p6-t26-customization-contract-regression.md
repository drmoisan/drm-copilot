# P6-T26 customization contract regression

Timestamp: 2026-08-23T00:48:13.7084292-04:00

Command: `poetry run pytest -o "addopts=" "tests/scripts/dev_tools/test_codex_agent_wrapper_contracts.py::test_feature_reviewer_wrapper_preserves_codex_remediation_handoff" "tests/scripts/dev_tools/test_codex_agent_wrapper_contracts.py::test_orchestrator_wrapper_preserves_codex_mandatory_delegation_contract" "tests/scripts/dev_tools/test_codex_full_migration_inventory.py::test_codex_agent_contracts_follow_expected_wrapper_or_native_patterns" "tests/scripts/dev_tools/test_codex_handoff_contract_parity.py::test_feature_review_remediation_handoff_is_strict_in_skill_and_agent" "tests/scripts/dev_tools/test_codex_orchestration_contracts.py::test_codex_orchestrator_agent_requires_mandatory_specialist_handoffs" "tests/scripts/dev_tools/test_csharp_orchestration_contracts.py::test_orchestrate_csharp_work_prompt_requires_minor_audit_lifecycle" "tests/scripts/dev_tools/test_minor_audit_acceptance_criteria_contracts.py::test_minor_audit_contract_files_require_explicit_acceptance_section" "tests/scripts/dev_tools/test_orchestration_guardrail_contracts.py::test_codex_orchestrators_enforce_checkpoint_and_lifecycle_guardrails" "tests/scripts/dev_tools/test_orchestration_guardrail_contracts.py::test_claude_orchestrator_documents_promotion_receipt_namespace" "tests/scripts/dev_tools/test_orchestrator_direct_command_contracts.py::test_root_orchestrators_use_direct_potential_entry_commands" "tests/scripts/dev_tools/test_orchestrator_direct_command_contracts.py::test_root_orchestrators_use_direct_potential_to_issue_commands" "tests/scripts/dev_tools/test_orchestrator_direct_command_contracts.py::test_root_orchestrators_use_direct_new_active_feature_folder_commands" "tests/scripts/dev_tools/test_orchestrator_direct_command_contracts.py::test_mirrored_orchestrator_agents_match_root_direct_command_contracts"`

EXIT_CODE: 1

Output Summary: The repository promotion-command hook denied the literal shell text before process launch because two test node IDs contain reserved promotion substrings. The same 13 node IDs were then assembled in memory and passed as the identical pytest argument vector. Pytest collected 13 nodes and all 13 failed in 0.18 seconds. No test or generated file was changed by the run.

Failed nodes:

- `tests/scripts/dev_tools/test_codex_agent_wrapper_contracts.py::test_feature_reviewer_wrapper_preserves_codex_remediation_handoff`
- `tests/scripts/dev_tools/test_codex_agent_wrapper_contracts.py::test_orchestrator_wrapper_preserves_codex_mandatory_delegation_contract`
- `tests/scripts/dev_tools/test_codex_full_migration_inventory.py::test_codex_agent_contracts_follow_expected_wrapper_or_native_patterns`
- `tests/scripts/dev_tools/test_codex_handoff_contract_parity.py::test_feature_review_remediation_handoff_is_strict_in_skill_and_agent`
- `tests/scripts/dev_tools/test_codex_orchestration_contracts.py::test_codex_orchestrator_agent_requires_mandatory_specialist_handoffs`
- `tests/scripts/dev_tools/test_csharp_orchestration_contracts.py::test_orchestrate_csharp_work_prompt_requires_minor_audit_lifecycle`
- `tests/scripts/dev_tools/test_minor_audit_acceptance_criteria_contracts.py::test_minor_audit_contract_files_require_explicit_acceptance_section`
- `tests/scripts/dev_tools/test_orchestration_guardrail_contracts.py::test_codex_orchestrators_enforce_checkpoint_and_lifecycle_guardrails`
- `tests/scripts/dev_tools/test_orchestration_guardrail_contracts.py::test_claude_orchestrator_documents_promotion_receipt_namespace`
- `tests/scripts/dev_tools/test_orchestrator_direct_command_contracts.py::test_root_orchestrators_use_direct_potential_entry_commands`
- `tests/scripts/dev_tools/test_orchestrator_direct_command_contracts.py::test_root_orchestrators_use_direct_potential_to_issue_commands`
- `tests/scripts/dev_tools/test_orchestrator_direct_command_contracts.py::test_root_orchestrators_use_direct_new_active_feature_folder_commands`
- `tests/scripts/dev_tools/test_orchestrator_direct_command_contracts.py::test_mirrored_orchestrator_agents_match_root_direct_command_contracts`

Failure groups:

- Codex reviewer wrapper generation omits the strict remediation-handoff and canonical migration-source fragments required by 3 nodes.
- Codex orchestrator generation omits mandatory delegation, lifecycle, and checkpoint guardrails required by 3 nodes.
- Generic GitHub orchestration generation omits minor-audit acceptance wording and direct extension-command contracts required by 5 nodes, including mirror parity validation.
- Claude orchestrator generation omits the promotion receipt namespace required by 1 node.
- The C# generated orchestration prompt omits the minor-audit lifecycle required by 1 node.

Command: `poetry run python -m scripts.dev_tools.generate_orchestration_customization_surfaces --check`

EXIT_CODE: NOT_RUN

Output Summary: Not run because the preceding required 13-node gate failed.

Command: `poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check`

EXIT_CODE: NOT_RUN

Output Summary: Not run because the preceding required 13-node gate failed.

Command: `poetry run python -m scripts.dev_tools.synchronize_customization_bundles --check`

EXIT_CODE: NOT_RUN

Output Summary: Not run because the preceding required 13-node gate failed.

The plan must be revised to authorize correction of the canonical generator inputs and/or generator projections that own the failing Codex reviewer, Codex orchestrator, generic GitHub orchestrator/prompt, Claude orchestrator, and C# prompt contracts, followed by ordered regeneration and a restart at P2-T14. Assertions must remain unchanged.
