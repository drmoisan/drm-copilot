# Scratch Contract Red Run (expect-fail)

Timestamp: 2026-10-12T17-30

Command: poetry run pytest tests/scripts/dev_tools/test_scratch_location_contracts.py -v

EXIT_CODE: 1

ExpectedExitCode: 1

Output Summary:
- Run against the pre-change sources confirmed in `red-run-precondition.2026-10-11T10-38.md`.
- Summary line: `14 failed, 1 passed`
- FAILED (prefix `tests/scripts/dev_tools/test_scratch_location_contracts.py::`):
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
- PASSED:
  - `test_normative_surfaces_name_no_bare_fixed_scratch_path`
- This artifact records this one gate only.
