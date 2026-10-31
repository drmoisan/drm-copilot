# Wording Constraint Inventory

Timestamp: 2026-10-31T12-51
Source: current text of the six test modules under tests/scripts/dev_tools/ named in plan task P1-T1, plus test_claude_rules_frontmatter.py (spec-section citation scan). Every test function below was located by search in the current tree.

| Fragment | Presence | Asserting test | Scope read |
| --- | --- | --- | --- |
| pinned (case-insensitive) | required-absent | test_skill_cites_two_parameter_cohort_seeding_signature (test_parallel_planner_surface_contracts_landed.py) | whole skill |
| compute_cohorts(item_keys, conflict_edges) | required-present (existing, untouched) | test_skill_cites_two_parameter_cohort_seeding_signature | whole skill |
| conflicts(a, b) (two-argument form) | required-absent | test_skill_cites_three_argument_contention_signature (landed) | whole skill |
| python -m scripts.dev_tools.compute_blast_radius | required-absent | test_skill_uses_import_only_upstream_invocation (landed) | whole skill |
| python -m scripts.dev_tools.parallel_cohort_computation | required-absent | test_skill_uses_import_only_upstream_invocation (landed) | whole skill |
| integration branch is created | required-absent | test_skill_contains_no_integration_branch_creation_instruction (test_parallel_planner_surface_contracts.py) | whole skill |
| create the integration branch | required-absent | test_skill_contains_no_integration_branch_creation_instruction | whole skill |
| Create the integration branch | required-absent | test_skill_contains_no_integration_branch_creation_instruction | whole skill |
| integration_branch: | required-absent | test_skill_contains_no_integration_branch_creation_instruction | whole skill |
| epic/<epic-slug>-integration | required-absent | test_skill_contains_no_integration_branch_creation_instruction | whole skill |
| explicitly not an integration branch | required-present | test_skill_contains_no_integration_branch_creation_instruction | whole skill |
| There is no fan-in merge step | required-present | test_skill_contains_no_integration_branch_creation_instruction | whole skill |
| depends_on: | required-absent | test_skill_contains_no_dependency_authoring_instruction | whole skill |
| record `depends_on` | required-absent | test_skill_contains_no_dependency_authoring_instruction | whole skill |
| set `depends_on` | required-absent | test_skill_contains_no_dependency_authoring_instruction | whole skill |
| logical_agent | required-absent | test_parallel_plan_uses_claude_receipt_agent_field (test_parallel_complexity_routing_contracts.py) | whole skill |
| **Git integrity is F4-owned.** | required-present | test_skill_attributes_git_integrity_verification_to_f4 (landed) | whole skill |
| Per-branch git-integrity requirement — F4-owned | required-present | test_skill_attributes_git_integrity_verification_to_f4 | whole skill |
| against each per-item | required-present | test_skill_attributes_git_integrity_verification_to_f4 | whole skill |
| Create each preparation worktree's branch from `origin/main`. | required-present | test_skill_branches_preparation_worktrees_from_origin_main (test_parallel_planner_surface_contracts.py) | whole skill (section Preparation Fan-Out) |
| (P10) | required-present | test_parallel_planner_agent_requires_routing_record (test_parallel_complexity_routing_contracts.py) | agent section Completion Requirements |
| model_routing_receipt | required-present | test_parallel_planner_agent_requires_routing_record | agent section Completion Requirements |
| script-extension path (.sh, .ps1, .py) in new text | required-absent | test_every_skill_script_reference_is_bundled (test_skill_bundle_contract_repo.py) | whole skill |
| spec.md citation followed by a section sign | required-absent | test_no_unqualified_spec_section_citation_under_claude (test_claude_rules_frontmatter.py) | every Markdown document under .claude/ |
| issue-number shape (issue num/number followed by colon or equals) and docs/features/active/ | required-absent | test_added_skill_text_does_not_match_hook_issue_number_pattern (test_parallel_issue_adoption_skill_contracts.py) | three named added-text sources, not the new paragraphs (confirmatory, new text avoids both) |
| Issue-number items are adopted, not promoted. | required-present | test_parallel_plan_item_intake_declares_issue_number_items_adopted (test_parallel_issue_adoption_skill_contracts.py) | section Item Intake |
| kickoff template markers (# Parallel Kickoff: <slug>, ## Invocation Prompt, ## Item Summary, ## Integrity, planning_commit: <hex>) | required-present | test_parallel_kickoff_template_seam.py module (seam reads the Kickoff Artifact fenced template) | section Kickoff Artifact |
