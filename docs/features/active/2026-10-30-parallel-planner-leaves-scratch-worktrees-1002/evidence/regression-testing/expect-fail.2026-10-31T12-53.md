# Expect-Fail Regression Run (before any planner-surface change)

Timestamp: 2026-10-31T12-53
Command: poetry run pytest -p no:cacheprovider --no-cov -rfp --tb=line -q tests/scripts/dev_tools/test_parallel_planner_no_scratch_worktree_contracts.py
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: 10 failed, 4 passed in 0.10s. The ten failures are the first nine tests of the module (the two git-worktree-add cases included); the four passes are the pinned-word/forbidden-fragment test, the untouched-sections test, and both byte-identity cases (both pairs EQUAL per the Phase 0 mirror-hash artifact).

| Test case | Outcome | Failure reason |
| --- | --- | --- |
| test_skill_artifact_home_states_planner_runs_no_worktree_add | FAILED | paragraph marker not found: No planner worktrees. |
| test_skill_no_planner_worktrees_names_runtime_as_remover | FAILED | paragraph marker not found: No planner worktrees. |
| test_skill_artifact_home_contains_plan_home_checkout_command | FAILED | Artifact Home lacks `git fetch origin main` |
| test_skill_plan_home_checkout_is_ordered_after_preparation_children | FAILED | paragraph marker not found: Plan-home checkout. |
| test_skill_plan_home_checkout_stops_on_refusal_without_stash_force_or_reset | FAILED | paragraph marker not found: Plan-home checkout. |
| test_skill_read_access_names_planner_and_git_show | FAILED | Read access paragraph lacks "the planner itself" |
| test_every_git_worktree_add_occurrence_is_inside_prohibition_sentence[skill] | FAILED | skill lacks the prohibition (count 0, required at least 1) |
| test_every_git_worktree_add_occurrence_is_inside_prohibition_sentence[agent] | FAILED | agent lacks the prohibition (count 0, required at least 1) |
| test_agent_delegation_model_points_to_no_worktree_prohibition | FAILED | Delegation Model lacks "No planner worktrees." |
| test_agent_completion_requirements_new_item_requires_no_worktree_and_pushed_plan_branch | FAILED | last numbered item is 7, not 8 |
| test_skill_contains_no_pinned_word_and_no_forbidden_fragments | PASSED | not applicable |
| test_edited_sections_exclude_preparation_fan_out_item_intake_and_kickoff_artifact_changes | PASSED | not applicable |
| test_bundled_copies_are_byte_identical_to_canonical[skill] | PASSED | not applicable |
| test_bundled_copies_are_byte_identical_to_canonical[agent] | PASSED | not applicable |
