# Isolation and Hermeticity

Timestamp: 2026-10-31T13-01
Command: poetry run pytest -q -p no:cacheprovider --no-cov with the files in reversed order (NEW_TEST first), followed by a search of NEW_TEST for five tokens
EXIT_CODE: 0
Output Summary: 136 passed, 0 failed in one process (14 new tests plus the 122 contract-module tests). Zero matches for every token. An earlier pass found one match for the token `artifacts/` in the module docstring; the docstring was reworded and the whole QA loop was re-run.

File order (NEW_TEST first, then the contract module list reversed):

1. tests/scripts/dev_tools/test_parallel_planner_no_scratch_worktree_contracts.py
2. tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py
3. tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py
4. tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py
5. tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py
6. tests/scripts/dev_tools/test_claude_rules_frontmatter.py
7. tests/scripts/dev_tools/test_skill_bundle_contract_repo.py
8. tests/scripts/dev_tools/test_parallel_kickoff_template_seam.py
9. tests/scripts/dev_tools/test_parallel_complexity_routing_contracts.py
10. tests/scripts/dev_tools/test_parallel_issue_adoption_skill_contracts.py
11. tests/scripts/dev_tools/test_parallel_planner_surface_contracts_landed.py
12. tests/scripts/dev_tools/test_parallel_planner_surface_contracts.py

Token match counts in NEW_TEST: tmp_path 0, tempfile 0, write_text 0, write_bytes 0, artifacts/ 0.
