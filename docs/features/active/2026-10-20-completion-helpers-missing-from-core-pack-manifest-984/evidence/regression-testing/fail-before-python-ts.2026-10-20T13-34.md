# Fail-Before Run, Python and Jest (Issue #984)

Timestamp: 2026-10-20T13-34
Command: poetry run pytest tests/scripts/dev_tools/test_pack_manifest_dependency_scan.py tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py -v (one process); then in extensions/drm-copilot/: node run-jest.cjs test/lib/push-down/claude-pack-manifest-completeness.test.ts
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: run against the unchanged manifests. Pytest 11 failed, 22 passed (exit 1). Jest 8 failed, 16 passed of 24 (exit 1). Both failing sets equal the sets the plan expects.

## Pytest (EXIT_CODE 1): 11 failed, 22 passed

`test_pack_manifest_dependency_scan.py`: 15 passed, 0 failed.

Failing tests:

1. `test_push_down_pack_manifest_dependency_closure.py::test_claude_manifest_powershell_dependency_closure` reports `core: .claude/hooks/enforce-completion-consistency.ps1 -> .claude/hooks/enforce-completion-helpers.ps1`.
2. `test_push_down_pack_manifest_dependency_closure.py::test_claude_command_text_closure` reports `core: .claude/settings.json names` each of `.claude/hooks/check-powershell-test-purity.ps1`, `.claude/hooks/check-python-test-purity.ps1`, `.claude/hooks/enforce-powershell-batch-budget.ps1`, `.claude/hooks/enforce-python-batch-budget.ps1`, `.claude/hooks/validate-pr-author-output.ps1` (the five FR-1 hooks registered by `.claude/settings.json`).
3. to 9. `test_push_down_pack_manifest_dependency_closure.py::test_core_only_selection_publishes_issue_984_path` for each of the seven FR-1 paths: `.claude/hooks/enforce-completion-helpers.ps1`, `.claude/agents/pr-author.md`, `.claude/hooks/validate-pr-author-output.ps1`, `.claude/hooks/check-python-test-purity.ps1`, `.claude/hooks/enforce-python-batch-budget.ps1`, `.claude/hooks/check-powershell-test-purity.ps1`, `.claude/hooks/enforce-powershell-batch-budget.ps1`.
10. `test_push_down_pack_manifest_dependency_closure.py::test_codex_core_selection_publishes_issue_984_path[.codex/scripts/post-codex-worktree-session.ps1]`.
11. `test_push_down_claude_pack_manifest_completeness.py::test_bundled_claude_files_are_listed_in_some_pack_manifest` reports `['.claude/agents/pr-author.md', '.claude/hooks/enforce-completion-helpers.ps1', '.claude/hooks/validate-pr-author-output.ps1']`.

Passing closure rows (hold before the fix): `test_scanned_source_floor`, `test_codex_manifest_powershell_dependency_closure`, `test_every_psscriptroot_occurrence_is_recognized`, `test_codex_routing_module_candidates_are_in_codex_core`, `test_codex_command_text_closure`, `test_codex_core_selection_publishes_issue_984_path[.codex/hooks/enforce-completion-helpers.ps1]`; completeness `test_pre_existing_exception_set_is_empty`.

## Jest (EXIT_CODE 1): 8 failed, 16 passed, 24 total

Failing tests (suite `claude pack manifest completeness (real filesystem)`):

1. `lists every bundled .claude agent, skill, and hook file in some pack manifest`
2. to 8. `issue #984: <path> is present in the core pack manifest` for each of the seven FR-1 paths listed above.

Passing: `keeps the pre-existing exception set empty (issue #984)`, the config row, the eight issue #462 rows, and the six issue #279 rows.
