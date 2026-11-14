# pytest final gate (issue #1157, P6-T7, re-run on the tree containing the origin/main merge with #1167)

Timestamp: 2026-11-13T13-46
Command: sh SCRATCH/issue-1157-pytest.sh (in the item worktree with VIRTUAL_ENV unset: poetry run pytest -n auto -q -rfE -p no:cacheprovider --junitxml=SCRATCH/issue-1157-pytest-junit.xml)
EXIT_CODE: 0
Output Summary:
- Tree: branch feature/owner-directive-pass-down-1157 at 85384d9e4 (contains the merge 4fb158d74 of origin/main 1d62aa292, which carries #1167); origin/main had no newer commits when this run started.
- "16598 passed, 6 skipped in 86.81s (0:01:26)"; failed 0; errors 0 (JUnit testsuite: tests=16604, failures=0, errors=0, skipped=6).
- Phase 0 baseline comparison: the baseline recorded 16590 passed, 6 skipped, 0 failed; no node fails in this run, so no node that passed in the baseline fails here.
- This run supersedes pytest-final.2026-11-11T06-58.md, which predates the #1167 merge; that file is not edited.
- Tests named in acceptances bound to P6-T7, all passed in this run (test cases counted in the JUnit file): test_push_down_claude_resource_contracts.py 14; test_push_down_claude_pack_manifest_completeness.py 2; test_push_down_pack_manifest_dependency_closure.py 18; test_push_down_codex_and_agents_resource_contracts.py 9; test_push_down_issue_824_follow_ups.py 62; test_execution_environment_brief_contracts.py 23 (including test_brief_copies_are_byte_identical, test_brief_has_no_g11_or_g12_findings, test_brief_is_preloaded_by_four_claude_agents, test_orchestrate_prerequisites_reference_brief); test_claude_rules_frontmatter.py 9; test_parallel_orchestrator_surface_contracts.py 38 (including both test_frozen_epic_surface_matches_pinned_baseline_digest entries, the three test_delivered_runtime_files_carry_no_prescriptive_epic_literal cases, and test_kickoff_section_carries_no_child_merge_instruction); test_parallel_issue_adoption_skill_contracts.py 16; test_parallel_issue_combination_contracts.py 24 (including test_kickoff_element_three_carries_the_combined_issues_line).
- Coverage: N/A - no production Python file in scope.
