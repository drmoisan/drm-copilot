# Scratch Contract Suite — Issue #932

Timestamp: 2026-10-16T01-13
Task: [P4-T6]
Command: poetry run pytest tests/scripts/dev_tools/test_scratch_location_contracts.py -v
EXIT_CODE: 0

Output Summary: `26 passed`; 0 failed. Required Codex parametrizations (verbatim `-v` lines):

```text
tests/scripts/dev_tools/test_scratch_location_contracts.py::test_scratch_location_section_states_the_rule[codex-planner] PASSED
tests/scripts/dev_tools/test_scratch_location_contracts.py::test_scratch_location_section_states_the_rule[codex-executor] PASSED
tests/scripts/dev_tools/test_scratch_location_contracts.py::test_scratch_location_section_avoids_forbidden_shapes[codex-planner] PASSED
tests/scripts/dev_tools/test_scratch_location_contracts.py::test_scratch_location_section_avoids_forbidden_shapes[codex-executor] PASSED
tests/scripts/dev_tools/test_scratch_location_contracts.py::test_planner_scratch_location_placement[codex-planner] PASSED
tests/scripts/dev_tools/test_scratch_location_contracts.py::test_executor_scratch_location_placement[codex-executor] PASSED
tests/scripts/dev_tools/test_scratch_location_contracts.py::test_executor_scratch_location_handles_pre_rule_plans[codex-executor] PASSED
```

The suite also includes `test_normative_surfaces_name_no_bare_fixed_scratch_path` (now scanning `.codex/agents/*.toml` as well) and the four `test_scratch_pattern_check_self_test` parametrizations, all passing.
