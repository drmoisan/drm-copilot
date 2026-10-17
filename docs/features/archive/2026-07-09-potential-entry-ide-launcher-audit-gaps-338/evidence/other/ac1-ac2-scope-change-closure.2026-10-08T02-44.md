# AC-1 / AC-2 Scope-Change Closure Record (Issue #338)

Timestamp: 2026-10-08T02-44

Response: scope_change

Finding (C): AC-1 and AC-2 live-Windows verification of issue #116 (observing `code --reuse-window` on a live Windows desktop) is closed by scope change. Deterministic contract tests stand in for live observation.

## Deterministic contract tests

Python:

- tests/scripts/dev_tools/test_new_potential_bug_entry.py::test_default_code_launcher_runs_when_code_present
- tests/scripts/dev_tools/test_new_potential_bug_entry.py::test_default_code_launcher_prefers_code_insiders_for_insiders_session
- tests/scripts/dev_tools/test_new_potential_bug_entry.py::test_launcher_converts_backslashes_to_forward_slashes
- tests/scripts/dev_tools/test_new_active_feature_folder.py::test_default_code_launcher_uses_code_with_reuse_window
- tests/scripts/dev_tools/test_new_active_feature_folder.py::test_default_code_launcher_prefers_code_insiders_for_insiders_session
- tests/scripts/dev_tools/test_new_active_feature_folder_launcher.py::test_launcher_converts_backslashes_to_forward_slashes

TypeScript:

- extensions/drm-copilot/test/lib/new-potential-bug-entry-launcher.test.ts case "returns true and invokes the resolved CLI with --reuse-window and the file path"
- extensions/drm-copilot/test/lib/new-potential-bug-entry-launcher.test.ts case "launcher-gap: converts backslash file paths to forward slashes"
- extensions/drm-copilot/test/lib/new-active-feature-folder/io.test.ts case "defaultCodeLauncher runs --reuse-window with posix paths when a CLI resolves"
- extensions/drm-copilot/test/lib/new-active-feature-folder/io.test.ts case "resolveCodeCli prefers code-insiders in an Insiders session"
- extensions/drm-copilot/test/lib/new-active-feature-folder/io-launcher.test.ts case "launcher-gap: defaultCodeLauncher passes every file after --reuse-window in order"

These tests cover `--reuse-window`, file arguments, and Insiders-first CLI selection.

## AC-3 placement

AC-3 names `extensions/drm-copilot/test/lib/new-active-feature-folder/io.test.ts`, but the new default-helper tests are in the sibling `extensions/drm-copilot/test/lib/new-active-feature-folder/io-launcher.test.ts` because adding them to `io.test.ts` (455 lines) would exceed the 500-line limit. The AC-3 verification set runs both files (P1-T12 as written in issue.md, P1-T13 with the sibling added).

## Coverage standard

`.claude/rules/general-unit-test.md` requires line >= 85 and branch >= 75, while the parallel `.github/instructions/general-unit-test.instructions.md` states 90% for new modules. The 85/75 gate is the closure standard and 90% is informational.

## Residual risk

VS Code's own window selection for `code --reuse-window` on a live Windows desktop with VS Code or VS Code Insiders was not observed. The two user-facing AC-1/AC-2 checkboxes of issue #116 remain a human observation.
