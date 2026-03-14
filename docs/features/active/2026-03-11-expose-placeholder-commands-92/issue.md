# expose-placeholder-commands (Issue #92)

- Date captured: 2026-03-11
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/expose-placeholder-commands/ (Issue #92)

- Issue: #92
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/92
- Last Updated: 2026-03-12
- Work Mode: full-feature

## Problem / Why

The VS Code extension registers four placeholder commands that intentionally throw errors when invoked. These commands reference real scripts (`new_active_feature_folder`, `potential_to_issue`, `new_potential_bug_entry`, `new-potential-entry.ps1`) but provide no runtime functionality. Users who discover these commands via the command palette encounter unhelpful "Not implemented" errors instead of executing the underlying dev-tool scripts. The existing PR-context and push-down commands demonstrate a proven pattern for bundling and executing scripts through the extension — the placeholder commands should follow the same approach.

## Proposed Behavior

Replace each placeholder command with a real command handler that bundles the corresponding script as a template resource within the extension and executes it against the destination workspace, following the same pattern established by `collectPrContext` and `pushDownCopilotCustomizations`:

1. **New Active Feature Folder** — Bundle `new_active_feature_folder` module and its dependencies under `resources/scripts/dev_tools/`, create a thin wrapper template at `resources/templates/new_active_feature_folder.py`, and register a real command handler that prompts for required arguments (feature name, type, issue number, work mode) and delegates to `executeBundledScript`.

2. **Potential To Issue** — Bundle `potential_to_issue` module and its dependency (`potential_to_issue_content`) under `resources/scripts/dev_tools/`, create a thin wrapper template at `resources/templates/potential_to_issue.py`, and register a real command handler that prompts for the potential file path, promotion type, and work mode.

3. **New Potential Bug Entry (Python)** — Bundle `new_potential_bug_entry` module under `resources/scripts/dev_tools/`, create a thin wrapper template at `resources/templates/new_potential_bug_entry.py`, and register a real command handler that prompts for the short name.

4. **New Potential Entry (PowerShell)** — Bundle `new-potential-entry.ps1` and its helper `vscode-cli.helpers.ps1` under `resources/templates/`, and register a real command handler that prompts for the short name and delegates to `executeBundledScript` with `runtimeKind: "powershell"`.

Each command should use VS Code input boxes or quick picks to gather user input before execution. Command IDs should drop the "Placeholder" suffix. Package.json command contributions should be updated to match the new titles.

## Acceptance Criteria (early draft)

- [x] All four placeholder commands are replaced with real command handlers that invoke the bundled scripts
- [x] Each command's Python/PowerShell modules and dependencies are bundled under `resources/scripts/dev_tools/` or `resources/templates/` as appropriate
- [ ] Wrapper templates follow the same thin-adapter pattern as `collect_pr_context.py` and `push_down_copilot_customizations.py`
- [x] Each command gathers required user input (file paths, names, types) via VS Code input boxes or quick picks before execution
- [x] Command IDs are renamed (drop "Placeholder" suffix) and `package.json` contributions are updated
- [x] The `PLACEHOLDER_COMMAND_SPECS` array and `registerPlaceholderCommands` function are removed
- [x] Existing placeholder command tests are replaced with tests for the new real commands
- [x] All TypeScript toolchain gates pass (Prettier, ESLint, TSC, Jest)
- [x] Extension activation registers all new commands without errors

## Constraints & Risks

- Python wrapper templates must not duplicate business logic — they delegate to bundled modules only.
- Bundled module copies must stay in sync with the repo-root source modules. A manual copy-sync discipline or documented procedure is required.
- The `new-potential-entry.ps1` script sources `vscode-cli.helpers.ps1` via a relative path — the bundled copy needs that helper co-located or the path adjusted.
- The `new_active_feature_folder` module has 6 sub-modules — all must be bundled together.
- Input gathering via VS Code UI adds user-facing surface that must handle cancellation gracefully.

## Test Conditions to Consider

- [x] Unit tests for each new command registration (mock `executeBundledScript`, verify correct `CommandSpec`)
- [x] Unit tests for user-input gathering (mock `showInputBox` / `showQuickPick`, verify cancellation returns early)
- [x] Integration-level tests verifying wrapper templates can import bundled modules
- [x] TypeScript type-check, lint, and format pass

## Next Step

- [ ] Promote to GitHub issue (feature request template)
- [ ] Create `docs/features/active/expose-placeholder-commands/` folder from the template