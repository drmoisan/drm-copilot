# `2026-03-11-expose-placeholder-commands` — User Story

- Issue: #92
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-03-11T21-40

## Story Statement

- As a **developer using the VS Code extension**, I want the four placeholder commands (New Active Feature Folder, Potential To Issue, New Potential Bug Entry, New Potential Entry) to execute their underlying scripts with guided input prompts, so that I can run dev-tool workflows directly from the command palette without switching to a terminal.
- As a **repository maintainer**, I want placeholder command infrastructure removed and replaced with tested, real command handlers, so that the extension surface area is reliable and every registered command produces a useful result.

## Problem / Why

The VS Code extension registers four placeholder commands that intentionally throw errors when invoked. These commands reference real scripts (`new_active_feature_folder`, `potential_to_issue`, `new_potential_bug_entry`, `new-potential-entry.ps1`) but provide no runtime functionality. Users who discover these commands via the command palette encounter unhelpful "Not implemented" errors instead of executing the underlying dev-tool scripts. The existing PR-context and push-down commands demonstrate a proven pattern for bundling and executing scripts through the extension — the placeholder commands should follow the same approach.


## Personas & Scenarios

- Persona: **Feature Developer (Dan)**
  - A solo developer who maintains the drm-copilot repository and uses the VS Code extension daily.
  - Cares about fast, low-friction scaffolding of feature folders, potential entries, and issue promotions.
  - Constrained by context-switching cost: leaving the editor to run CLI scripts breaks flow.
  - Goal: invoke any dev-tool script from the command palette with guided prompts and see output in the editor.
  - Frustration: discovering a "Not implemented" error after selecting a command palette entry.

- Scenario: **Creating a new potential bug entry from the command palette**
  - Dan notices a defect while reviewing code in VS Code.
  - He opens the command palette (`Ctrl+Shift+P`) and types "New Potential Bug Entry".
  - The extension prompts for a short name via an input box (e.g., `blank-pr-context`).
  - Dan enters the name and presses Enter.
  - The extension executes the bundled `new_potential_bug_entry.py` script against the workspace root.
  - A new potential bug markdown file is created under `docs/features/potential/` and the output channel shows the result.
  - If Dan presses Escape at the input box, the command exits silently without error.

- Scenario: **Promoting a potential entry to a GitHub issue**
  - Dan has a potential feature file he wants to promote.
  - He opens the command palette and selects "Potential To Issue".
  - The extension shows a file-open dialog defaulting to `docs/features/potential/`, then quick picks for promotion type and work mode.
  - After confirming all inputs, the bundled `potential_to_issue.py` script runs, creating a GitHub issue via `gh` CLI and printing the issue URL to the output channel.
  - If `gh` is not authenticated, the script fails with a clear error message in the output channel.


## Acceptance Criteria

- [x] All four placeholder commands are replaced with real command handlers that invoke the bundled scripts
- [x] Each command's Python/PowerShell modules and dependencies are bundled under `resources/scripts/dev_tools/` or `resources/templates/` as appropriate
- [x] Wrapper templates follow the same thin-adapter pattern as `collect_pr_context.py` and `push_down_copilot_customizations.py`
- [x] Each command gathers required user input (file paths, names, types) via VS Code input boxes or quick picks before execution
- [x] Command IDs are renamed (drop "Placeholder" suffix) and `package.json` contributions are updated
- [x] The `PLACEHOLDER_COMMAND_SPECS` array and `registerPlaceholderCommands` function are removed
- [x] Existing placeholder command tests are replaced with tests for the new real commands
- [x] All TypeScript toolchain gates pass (Prettier, ESLint, TSC, Jest)
- [x] Extension activation registers all new commands without errors


## Non-Goals

- **Automated sync of bundled module copies.** Bundled scripts are manual copies with import rewrites; an automated sync tool is out of scope.
- **New business logic in wrapper templates.** Templates must remain thin adapters that delegate to bundled modules; no new domain behavior is added in this feature.
- **Additional commands beyond the four placeholders.** Only the four existing placeholder commands are replaced; no new commands are introduced.
- **GUI beyond input boxes and quick picks.** Webview panels, tree views, or other complex UI are not in scope.
- **Cross-extension integration.** The commands operate within the drm-copilot extension only; no APIs are exposed to other extensions.
- **`--force` or `--active-file-for-feature-name` flags** for `newActiveFeatureFolder`. These advanced CLI flags are omitted from the VS Code UI in v1.
