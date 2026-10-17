# Regression: R2.8 Pinned Parallel-Surface Nodes

Timestamp: 2026-10-02T01-42
Command: poetry run pytest "tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py::test_orchestrate_skill_section_states_its_required_obligations[merge-on-green-parent-executes-merge]" "tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py::test_orchestrate_skill_first_thirteen_headings_match_required_layout" "tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py::test_agent_body_contains_exactly_the_nine_required_headings" tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py::test_delivered_runtime_files_carry_no_prescriptive_epic_literal tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py::test_frozen_epic_surface_matches_pinned_baseline_digest -q -p no:cacheprovider
EXIT_CODE: 0
Output Summary:
- Result line: `8 passed in 0.07s`; no `failed`.
- 8 = 1 (merge-on-green obligation) + 1 (first thirteen headings) + 1 (nine agent headings) + 3 (delivered-file epic-literal cases) + 2 (frozen-digest cases).
- Command note: `-p no:cacheprovider` appended (no `.pytest_cache` write). Deviation D-TOOLS.
