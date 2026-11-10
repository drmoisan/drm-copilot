# Pytest Final Gate (issue #1165)

Timestamp: 2026-11-10T00-56
Command: env -u VIRTUAL_ENV poetry run pytest -n auto tests/scripts/dev_tools -q -p no:cacheprovider --junitxml=SCRATCH/pytest-p4.xml (from the item worktree root through sh SCRATCH/issue-1165-pytest.sh); per-module results read from the JUnit file by SCRATCH/issue-1165-pyjunit.ps1
EXIT_CODE: 0
Output Summary:
- Result line: "8852 passed, 6 skipped in 24.81s" (Phase 0 baseline: 8844 passed, 6 skipped, 0 failed).
- passed=8852 failed=0 skipped=6; no pre-existing failures were listed in [P0-T5], and none occur here.
- Named modules and tests:
  - test_claude_rules_frontmatter cases=9 failed=0 skipped=0
  - test_execution_environment_brief_contracts cases=23 failed=0 skipped=0
  - test_bash_command_shape_surfaces cases=6 failed=0 skipped=0
  - test_push_down_claude_resource_contracts cases=14 failed=0 skipped=0
  - test_push_down_claude_pack_manifest_completeness cases=2 failed=0 skipped=0
  - test_push_down_pack_manifest_dependency_closure cases=18 failed=0 skipped=0
  - test_push_down_codex_and_agents_resource_contracts cases=9 failed=0 skipped=0
  - test_push_down_codex_and_agents_pack_manifest_completeness cases=2 failed=0 skipped=0
  - test_push_down_issue_824_follow_ups cases=62 failed=0 skipped=0
  - test_discovery_documentation_contracts cases=32 failed=0 skipped=0
  - test_launch_loaded_rules_carry_description_and_no_paths_key found=1 failed=0
  - test_unconditional_rule_set_is_exactly_the_deliberate_files found=1 failed=0
  - test_brief_command_text_restrictions_states_preferred_forms found=1 failed=0
  - test_brief_copies_are_byte_identical found=1 failed=0
  - test_brief_worktree_python_environment_section_states_bootstrap found=1 failed=0
  - test_brief_has_no_g11_or_g12_findings found=1 failed=0
  - test_command_shape_forms_are_consistent_across_surfaces found=1 failed=0
  - test_rule_states_command_shape_rule_and_isolated_refusal found=1 failed=0
  - test_codex_skill_frontmatter_source_and_claude_only_statement found=1 failed=0
  - test_copilot_instruction_frontmatter_is_always_loaded found=1 failed=0
  - test_copilot_instruction_matches_bundle_copy found=1 failed=0
  - test_parallel_orchestrate_step_c_uses_keep_and_references_brief_table found=1 failed=0
- Coverage: no Python production file changed (plan Pre-Mortem, Coverage); no coverage obligation applies to this gate.
