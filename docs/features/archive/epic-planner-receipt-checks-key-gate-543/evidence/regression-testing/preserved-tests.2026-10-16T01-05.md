# Preserved Tests (P6-T6, spec AC12)

Timestamp: 2026-10-16T01-05
Command: poetry run pytest "tests/scripts/dev_tools/test_validate_epic_planner_state.py::test_readiness_requires_epic_preparation_topology_receipts" "tests/scripts/dev_tools/test_validate_epic_planner_state.py::test_readiness_cross_binds_feature_complexity_and_model_context" "tests/scripts/dev_tools/test_validate_epic_planner_state.py::test_ready_checkpoint_passes_execution_readiness" "tests/scripts/dev_tools/test_validate_epic_planner_state.py::test_cli_dispatches_planner_readiness_flag" "tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py::test_consumer_authority_is_typescript_only_and_scope_owners_are_unchanged" -v; git diff main --stat -- <six preserved test files>; git status --porcelain -- <six preserved test files>; git diff -U0 main -- tests/scripts/dev_tools/test_validate_epic_planner_state.py
EXIT_CODE: 0
Anchor: main (git rev-parse main = MAIN_BASE_SHA adb9aa5f02fc0ae84fd7e6060f758a8b0974eb99)
Output Summary:
- pytest: 5 passed in 0.19s (all five named node IDs PASSED; exit 0)
- git diff main --stat over test_validate_epic_planner_state_launch_binding.py, test_epic_planner_readiness.py, test_push_down_codex_and_agents_customizations.py, epic-planner-state-core.test.ts, epic-planner-state-launch-binding.test.ts, epic-planner-readiness-integrity.test.ts: empty output (exit 0)
- git status --porcelain over the same six files: empty output (exit 0)
- git diff -U0 main -- tests/scripts/dev_tools/test_validate_epic_planner_state.py hunk headers (verbatim):
  - `@@ -184 +184,3 @@ def test_readiness_requires_resolved_child_model_receipt() -> None:`
  - `@@ -187 +189,4 @@ def test_readiness_requires_resolved_child_model_receipt() -> None:`
- Every hunk lies within old lines 176-188 (old lines 184 and 187), the body of test_readiness_requires_resolved_child_model_receipt.
- Together with P6-T4 (targeted-python, 78 passed, exit 0) and P6-T5 (targeted-typescript, 96 passed, exit 0), the listed tests pass without modification.
