# Contract Tests for the Edited Mirrored Files (Issue #1074)

Timestamp: 2026-11-04T15-45
Task: [P4-T6]
Command: poetry run pytest tests/scripts/dev_tools/test_execution_environment_brief_contracts.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py tests/scripts/dev_tools/test_discovery_documentation_contracts.py tests/scripts/dev_tools/test_single_pass_preflight_contracts.py tests/scripts/dev_tools/test_evidence_timestamp_contracts.py -q -p no:cacheprovider; then poetry run python -m scripts.dev_tools.generate_codex_agent_variants --check (both from the worktree root through SCRATCH/issue-1074-contracts.sh)
EXIT_CODE: 0
Output Summary:
- Pytest: `167 passed in 2.08s`; passed 167, failed 0; exit code 0. This includes `test_brief_copies_are_byte_identical`, `test_brief_ci_section_names_jobs_and_required_contexts`, `test_execution_environment_fact_is_unchanged_across_copies`, `test_copilot_bundle_copies_match_canonical`, and `test_atomic_plan_contract_matches_bundled_mirror`.
- Codex generator `--check`: exit code 0, no output (no generated variant differs); failed 0.
- `sha256sum` of the six execution-environment brief copies prints one hash for all six files.
- The two `atomic-plan-contract` copies are byte-identical (`cmp` reports no difference) and each contains `CI Required Gate` once.
