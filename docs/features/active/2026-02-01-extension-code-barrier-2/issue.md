# extension-code-barrier (Issue #2)

- Date captured: 2026-02-01
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/extension-code-barrier/ (Issue #2)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #2
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/2
- Last Updated: 2026-02-01

## Summary

VS Code command handlers registered by `drm-copilot` attempt to invoke underlying tasks/scripts as if they exist in the *user’s workspace* (codebase), but those tasks/scripts actually live *inside the extension*. As a result, command execution fails (e.g., “task not found”) and none of the extension methods work.

## Environment

- OS/version: Windows (repro observed on Windows; exact version TBD)
- Python version: N/A or varies by workspace (not required to reproduce the core “extension vs workspace barrier” failure)
- Command/flags used: VS Code Command Palette → run any `drm-copilot` registered command that triggers task/script execution (exact command name(s) TBD)
- Data source or fixture: Any workspace (including an empty/sample repo) that does *not* contain the expected tasks/scripts in its own `.vscode/tasks.json` or repo-local script folders

## Steps to Reproduce

1. Install/load the `drm-copilot` VS Code extension.
2. Open a workspace that does not contain the original utility scripts/tasks (i.e., a codebase that is *not* one of the repos the scripts were originally deployed into).
3. Run a `drm-copilot` command from the Command Palette that is implemented by invoking an underlying VS Code Task / script.
4. Observe that execution fails because the command attempts to run a task/script that does not exist in the workspace.

## Expected Behavior

`drm-copilot` commands should work in any workspace as long as the extension is installed:

- If the command needs to operate on the user’s codebase (files, folders, configs), it should target the *workspace filesystem and workspace context*.
- If the command relies on shared utilities packaged with the extension, it should execute those utilities from the *extension installation* while still applying them to the *workspace*.
- Commands should not require the user’s repo to manually copy tasks/scripts that are intended to be centrally provided by the extension.

## Actual Behavior

Commands attempt to invoke underlying tasks/scripts as if they are defined in the workspace, and execution fails because those tasks/scripts exist within the extension instead of the codebase.

Representative error symptoms (exact text may vary by command):

- VS Code reports a task cannot be found / resolved (e.g., “There is no task named …”, “Task not found”, or similar).
- Downstream command logic never runs, so effectively “none of the extension methods are working.”

## Logs / Screenshots

- [ ] Attached minimal logs or screenshot
- Snippet: `Task "Dev: 1 New Potential Entry" not found. Ensure tasks.json is configured.`

## Impact / Severity

- [x] Blocker
- [ ] High
- [ ] Medium
- [ ] Low

## Suspected Cause / Notes

Core issue: the development strategy for exposing shared utilities via a VS Code extension is currently treating extension-internal code/assets as if they are available in (or installed into) the user’s workspace.

This creates a “code barrier” problem:

- Some functions were designed to interact with the filesystem and must operate on the *workspace’s filesystem* (user repo) rather than the extension’s install directory.
- Other functions reference code/assets that live *inside the extension* (scripts, modules, templates), and those references must be resolved relative to the extension.
- The current implementation path appears to invoke workspace-local Tasks (or repo-local scripts) without ensuring they exist, leading to failures in any repo that hasn’t already adopted/copied those utilities.

Design note: this likely requires explicitly modeling “workspace context” vs “extension context” and defining a stable boundary for execution (what runs where, and what paths/URIs are used).

## Proposed Fix / Validation Ideas

- [ ] Unit coverage areas
	- Command execution layer: verify that registered commands do not assume workspace tasks exist.
	- Path resolution: tests for “extension resource path” vs “workspace root path” selection.
	- Execution adapter: if using tasks, verify tasks are created/registered programmatically (or alternative execution path) rather than depending on `.vscode/tasks.json` in the workspace.
	- Filesystem operations: validate that file reads/writes target `vscode.workspace.workspaceFolders[0]` (or selected folder) and not `context.extensionUri`.

- [ ] Integration scenario to retest
	- Install extension → open a clean/scratch repo with no special configuration → run each `drm-copilot` command → confirm the command either:
		- succeeds using extension-packaged utilities against workspace files, or
		- fails with a clear, actionable error that explains required prerequisites.

- [ ] Manual verification notes
	- Validate behavior on:
		- single-root workspace
		- multi-root workspace (ensure the target workspace folder selection is well-defined)
		- workspaces with and without Python/tooling installed (commands should degrade gracefully or provide clear guidance)
	- Confirm that any “runs a script” behavior uses the correct working directory (workspace root) while referencing scripts located in the extension (if applicable).

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch