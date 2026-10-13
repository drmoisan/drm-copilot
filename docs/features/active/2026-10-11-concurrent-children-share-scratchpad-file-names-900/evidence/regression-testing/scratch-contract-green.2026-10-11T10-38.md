# Scratch Contract Green Run

Timestamp: 2026-10-12T17-45

Command: poetry run pytest tests/scripts/dev_tools/test_scratch_location_contracts.py -v

EXIT_CODE: 0

Output Summary:
- Summary line: `15 passed`
- PASSED (prefix `tests/scripts/dev_tools/test_scratch_location_contracts.py::`):
  - `test_scratch_location_section_states_the_rule[claude-planner]`
  - `test_scratch_location_section_states_the_rule[claude-executor]`
  - `test_scratch_location_section_states_the_rule[agents-planner]`
  - `test_scratch_location_section_states_the_rule[agents-executor]`
  - `test_scratch_location_section_avoids_forbidden_shapes[claude-planner]`
  - `test_scratch_location_section_avoids_forbidden_shapes[claude-executor]`
  - `test_scratch_location_section_avoids_forbidden_shapes[agents-planner]`
  - `test_scratch_location_section_avoids_forbidden_shapes[agents-executor]`
  - `test_planner_scratch_location_placement[claude-planner]`
  - `test_planner_scratch_location_placement[agents-planner]`
  - `test_executor_scratch_location_placement[claude-executor]`
  - `test_executor_scratch_location_placement[agents-executor]`
  - `test_executor_scratch_location_handles_pre_rule_plans[claude-executor]`
  - `test_executor_scratch_location_handles_pre_rule_plans[agents-executor]`
  - `test_normative_surfaces_name_no_bare_fixed_scratch_path`
- The 14 nodes that failed in `scratch-contract-red.2026-10-11T10-38.md` now pass.
