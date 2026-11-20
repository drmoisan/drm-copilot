# Neighbour Contract Modules

Timestamp: 2026-10-12T17-45

Command: poetry run pytest tests/scripts/dev_tools/test_claude_planning_integrity_contracts.py tests/scripts/dev_tools/test_typescript_toolchain_instruction_contracts.py tests/scripts/dev_tools/test_codex_handoff_contract_parity.py -v

EXIT_CODE: 0

Output Summary:
- Summary line: `26 passed` (0 failed, 0 skipped)
- `tests/scripts/dev_tools/test_claude_planning_integrity_contracts.py::test_planner_review_contract_requires_all_three_dimensions` PASSED
- `tests/scripts/dev_tools/test_typescript_toolchain_instruction_contracts.py::test_mirror_does_not_name_the_vitest_framework[.claude/agents/atomic-executor.md]` PASSED
- `tests/scripts/dev_tools/test_codex_handoff_contract_parity.py::test_atomic_executor_handoff_contract_is_strict_in_skill_and_agent` PASSED
