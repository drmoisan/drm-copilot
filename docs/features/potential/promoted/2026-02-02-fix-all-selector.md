# fix-all-selector (Issue #3)

- Date captured: 2026-02-02
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/fix-all-selector/ (Issue #3)

- Issue: #3
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/3
- Last Updated: 2026-02-02
## Problem / Why

In a multi-language repo, "Fix All" is often too blunt: it runs every toolchain (Python, PowerShell, Shell, JSON, etc.) even when the developer only changed one area. This wastes time and creates friction, especially when certain toolchains are slow, flaky on a given workstation, or intentionally not installed (e.g., PowerShell tooling on a minimal environment).

We need a quick, discoverable way in VS Code to choose which toolchains run when invoking "QC: 0 Fix All", and to persist that choice so developers don’t have to re-select it every time.

## Proposed Behavior

Provide a VS Code selector (multi-select checkboxes) that lets the user choose which "Fix All" toolchains/branches to run, then persist that selection until changed.

Behavior details (targeting existing repo behavior):

- The selector presents toolchains that currently exist in the fix-all workflow (see `scripts/dev_tools/fix_all.py`):
	- JSON (format + validate)
	- Shell (format + check + test)
	- Python (Black + Ruff + Pyright + Pytest)
	- PowerShell (PoshQC format + analyze + test)
- The selection is persisted (workspace-scoped preferred) and used as the default for subsequent "Fix All" runs.
- A one-off override is available so users can run:
	- all toolchains (ignoring saved selection), or
	- a custom selection for a single run without overwriting the saved configuration.

Suggested precedence rules (to make behavior deterministic):

1) One-off override (explicit command invocation choice) wins
2) Persisted selection (workspace setting/state)
3) Default when unset: run all toolchains (preserves current behavior)

Suggested UX shape (VS Code):

- Command palette entry: "QC: Fix All (Select Toolchains)"
	- Opens a checkbox Quick Pick with the toolchains
	- Pre-checks the last saved selection
	- Provides actions like:
		- Save selection + run now
		- Run once (do not save)
		- Reset to default (all)

Notes:

- The existing task-backed command `drm-copilot.qcFixAll` currently maps to the task label "QC: 0 Fix All" (see `src/task-command-map.ts` and `.vscode/tasks.json`). This feature likely requires a dedicated extension command (not a pure task mapping) so we can show a multi-select UI and then invoke the correct underlying command(s) with the selected branches.

## Acceptance Criteria (early draft)

- [ ] VS Code provides a command that opens a multi-select (checkbox) UI for selecting Fix All toolchains.
- [ ] The selectable toolchains match the current fix-all branches in `scripts/dev_tools/fix_all.py`: json, shell, python, powershell.
- [ ] The UI defaults to the last saved selection when present; otherwise it defaults to "all selected".
- [ ] The selection is persisted (workspace-scoped) and remains in effect until changed.
- [ ] The user can run Fix All with a one-off override that does not modify the persisted selection.
- [ ] If the user selects zero toolchains and chooses to run, VS Code shows a clear message and does not start the workflow.
- [ ] When a subset is selected, only those toolchains execute; non-selected toolchains are explicitly reported as "skipped" (either in the status board or in the final summary).
- [ ] Default behavior remains backwards compatible: if no persisted selection exists and no override is used, Fix All runs all toolchains.

## Constraints & Risks

- VS Code Task inputs do not naturally support a checkbox UI; implementing this as a pure `.vscode/tasks.json` workflow is likely insufficient.
- The extension currently only maps commands to static tasks (see `src/extension.ts`). Adding a selector implies introducing "real" extension logic (Quick Pick UI + persisted configuration + dynamic execution).
- Cross-platform behavior:
	- PowerShell steps require `pwsh` availability.
	- Python steps assume `poetry` is available.
	- Shell steps require the repo’s shell QC tooling dependencies.
	The selector should not hide underlying environment problems; it should make it easy to avoid running toolchains you don’t currently support on the machine.
- Persisted configuration scope choice (workspace vs global) impacts teams:
	- Workspace-scoped is safer (repo-specific expectations).
	- Global might surprise users across projects.
- Changes to `scripts/dev_tools/fix_all.py` may be required to support running only a subset of branches while keeping output/summary clear.

## Test Conditions to Consider

- [ ] Unit coverage areas
	- [ ] Persist/load selection: verify default (all), saved selection, and one-off override precedence.
	- [ ] UI model: verify toolchain list matches the known branch IDs (json/shell/python/powershell).
	- [ ] Command execution plan creation: selected toolchains map to the correct underlying invocation(s).
- [ ] Integration scenarios
	- [ ] User selects only Python and runs Fix All; verify only Python branch executes and others are skipped.
	- [ ] User selects none; verify nothing runs and an informative message is shown.
	- [ ] User runs "Fix All (All toolchains)" once; verify it does not overwrite the saved subset.
	- [ ] Persisted selection survives VS Code reload.
- [ ] CLI/API examples
	- [ ] `poetry run python -m scripts.dev_tools.fix_all` continues to run all branches by default.
	- [ ] (If added) a branch-selection CLI option supports running a subset, e.g. `--toolchains python,shell`, and produces a summary that marks non-selected toolchains as skipped.

## Next Step

- [ ] Promote to GitHub issue (feature request template)
- [ ] Create `docs/features/active/fix-all-selector/` folder from the template

Additional suggested next step (optional):

- [ ] Capture a concrete persistence mechanism decision (workspace setting vs extension state) and document the exact key name to use (e.g., `drm-copilot.fixAll.selectedToolchains`).
