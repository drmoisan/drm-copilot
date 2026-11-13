# pytest final gate with coverage, after the #1163 main sync (issue #1157, P6-T7 repeat)

Timestamp: 2026-11-13T17-40
Command: sh SCRATCH/issue-1157-pytest.sh --cov-branch --cov-report=term-missing --cov (in the item worktree with VIRTUAL_ENV unset: poetry run pytest -n auto -q -rfE -p no:cacheprovider --junitxml=SCRATCH/issue-1157-pytest-junit.xml --cov-branch --cov-report=term-missing --cov; the project addopts adds --cov-report=lcov:artifacts/python/lcov.info); named-test results read from that JUnit file by SCRATCH/issue-1157-sync2-named.ps1
EXIT_CODE: 0
Output Summary:
- "16598 passed, 6 skipped in 186.14s (0:03:06)"; failed 0; errors 0 (JUnit: tests=16604, failures=0, errors=0, skipped=6). Run start 2026-11-13T17-36; one gate run, no fix needed.
- Phase 0 baseline comparison: baseline 16590 passed, 0 failed; no node fails here, so no node that passed in the Phase 0 baseline fails.
- Terminal TOTAL row: Stmts 35355, Miss 1021, Branch 13424, BrPart 555, Cover 96%.
- artifacts/python/lcov.info (written by this run, mtime 2026-11-13T17:39:41Z): LF 35355, LH 34334 (line coverage 97.11%); BRF 13424, BRH 12669 (branch coverage 94.37%).
- No production Python file is in the branch diff; the only Python path is tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py, unchanged by this sync.
- Files named in acceptances bound to P6-T7 (cases/failed/skipped): test_push_down_claude_resource_contracts 14/0/0; test_push_down_claude_pack_manifest_completeness 2/0/0; test_push_down_pack_manifest_dependency_closure 18/0/0; test_push_down_codex_and_agents_resource_contracts 9/0/0; test_push_down_issue_824_follow_ups 62/0/0; test_execution_environment_brief_contracts 23/0/0; test_claude_rules_frontmatter 9/0/0; test_parallel_orchestrator_surface_contracts 38/0/0; test_parallel_issue_adoption_skill_contracts 16/0/0; test_parallel_issue_combination_contracts 24/0/0.
- Tests named in acceptances bound to P6-T7 (cases/not passed): test_frozen_epic_surface_matches_pinned_baseline_digest 2/0 (both pinned entries, AC-46); test_brief_copies_are_byte_identical 1/0; test_brief_has_no_g11_or_g12_findings 1/0; test_brief_is_preloaded_by_four_claude_agents 1/0; test_orchestrate_prerequisites_reference_brief 1/0; test_delivered_runtime_files_carry_no_prescriptive_epic_literal 3/0; test_kickoff_section_carries_no_child_merge_instruction 1/0; test_kickoff_element_three_carries_the_combined_issues_line 1/0.
