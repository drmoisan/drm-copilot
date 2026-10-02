# Fail-Before: Completion-Gate Documentation Contracts

Timestamp: 2026-10-02T01-31
Timestamp-Correction: original value 2026-10-02T01-17 was a Phase 0 start reading reused through Phase 4; the corrected value is the artifact's observed file write time (remediation-inputs.2026-10-02T02-02.md), an upper bound on the command run time.
Command: poetry run pytest tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py -q -rA
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- Run before any documentation edit (Phases 5-10 not started).
- Result line: `19 failed, 11 passed in 0.17s`
- FAILED nodes (all 19 content items): test_codex_ci_green_gate_names_ci_gate_keys_from_validator; test_codex_ci_green_gate_names_pr_gate_keys_from_validator; test_codex_completion_list_includes_ci_gate_and_pr_gate; test_codex_orchestrate_states_ci_dependent_checkoff_rule; test_orchestrate_pr_creation_gate_condition_two_excludes_ci_dependent_ac; test_orchestrate_s9_requires_ci_dependent_checkoff_push_and_rerun; test_parallel_orchestrate_merge_requires_head_sha_match_and_no_pending_ci_ac; test_parallel_orchestrator_agent_states_child_owns_ci_dependent_checkoffs; test_acceptance_criteria_tracking_skill_defines_ci_dependent_rule[claude|agents|github]; test_feature_review_agent_grants_mcp_artifact_validator; test_feature_review_agent_body_validates_each_review_artifact_type; test_evidence_skill_states_first_occurrence_for_all_schema_fields[claude|agents|github]; test_evidence_skill_states_timestamp_system_clock_source[claude|agents|github].
- PASSED: all eleven test_edited_surface_matches_bundled_mirror cases (agents-orchestrate, claude-orchestrate, claude-parallel-orchestrate, claude-parallel-orchestrator-agent, claude-ac-tracking, agents-ac-tracking, github-ac-tracking, claude-feature-review-agent, claude-evidence, agents-evidence, github-evidence).
- `-rA` was appended to the plan command to print the per-node PASSED/FAILED summary; it does not change selection or outcome (deviation D-TOOLS).
- The S9 test asserts the D-COMPLETED-ATTEMPTS adaptation of Block B2's last sentence (see `## Plan Deviations`).
