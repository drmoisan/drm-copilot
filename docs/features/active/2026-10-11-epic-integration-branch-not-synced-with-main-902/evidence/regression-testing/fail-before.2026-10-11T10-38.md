# Fail-Before — Main-Sync Contract Tests (before skill edits)

Timestamp: 2026-10-12T23-38
Command: poetry run pytest tests/scripts/dev_tools/test_epic_orchestrate_main_sync_contract.py -v -p no:cacheprovider
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- `10 failed, 3 passed in 0.12s` (matches the expected fail-before counts).
- The four presence nodes `[claude-skill]`, `[claude-bundle]`, `[codex-skill]`, `[codex-bundle]` FAILED with `missing main-sync fragment: `git fetch origin main` and then`.
- Both ordering nodes FAILED with `rev-list count not found`; both numbering nodes FAILED with `['1', '2', '3', '4', '5']` versus the expected six steps.
- Both removal tests FAILED because the start marker (`3. Before each wave launches` / `Before each wave launches`) is not yet present, so `remove_block` raises `ValueError`.
- `test_contract_fails_on_pre_change_lifecycle_text`, `test_remove_block_rejects_missing_start_marker`, and `test_section_body_returns_none_for_absent_heading` PASSED.

Verbatim per-node result lines:

```text
tests/scripts/dev_tools/test_epic_orchestrate_main_sync_contract.py::test_main_sync_step_present_in_lifecycle_section[claude-skill] FAILED [  7%]
tests/scripts/dev_tools/test_epic_orchestrate_main_sync_contract.py::test_main_sync_step_present_in_lifecycle_section[claude-bundle] FAILED [ 15%]
tests/scripts/dev_tools/test_epic_orchestrate_main_sync_contract.py::test_main_sync_step_present_in_lifecycle_section[codex-skill] FAILED [ 23%]
tests/scripts/dev_tools/test_epic_orchestrate_main_sync_contract.py::test_main_sync_step_present_in_lifecycle_section[codex-bundle] FAILED [ 30%]
tests/scripts/dev_tools/test_epic_orchestrate_main_sync_contract.py::test_main_sync_step_sits_between_integration_fetch_and_child_branching[claude-skill] FAILED [ 38%]
tests/scripts/dev_tools/test_epic_orchestrate_main_sync_contract.py::test_main_sync_step_sits_between_integration_fetch_and_child_branching[claude-bundle] FAILED [ 46%]
tests/scripts/dev_tools/test_epic_orchestrate_main_sync_contract.py::test_lifecycle_steps_are_numbered_one_through_six[claude-skill] FAILED [ 53%]
tests/scripts/dev_tools/test_epic_orchestrate_main_sync_contract.py::test_lifecycle_steps_are_numbered_one_through_six[claude-bundle] FAILED [ 61%]
tests/scripts/dev_tools/test_epic_orchestrate_main_sync_contract.py::test_contract_fails_when_claude_main_sync_step_removed FAILED [ 69%]
tests/scripts/dev_tools/test_epic_orchestrate_main_sync_contract.py::test_contract_fails_when_codex_main_sync_paragraph_removed FAILED [ 76%]
tests/scripts/dev_tools/test_epic_orchestrate_main_sync_contract.py::test_contract_fails_on_pre_change_lifecycle_text PASSED [ 84%]
tests/scripts/dev_tools/test_epic_orchestrate_main_sync_contract.py::test_remove_block_rejects_missing_start_marker PASSED [ 92%]
tests/scripts/dev_tools/test_epic_orchestrate_main_sync_contract.py::test_section_body_returns_none_for_absent_heading PASSED [100%]
======================== 10 failed, 3 passed in 0.12s =========================
```
