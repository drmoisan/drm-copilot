# 2026-02-01-extension-code-barrier (Spec)

- **Issue:** #2
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-02-01T11-35
- **Status:** Draft
- **Version:** 0.1

## Context

VS Code command handlers registered by `drm-copilot` attempt to invoke underlying tasks/scripts as if they exist in the *user’s workspace* (codebase), but those tasks/scripts actually live *inside the extension*. As a result, command execution fails (e.g., “task not found”) and none of the extension methods work.

Environment:

- OS/version: Windows (repro observed; exact build not captured in evidence)
- Python version: Varies by workspace; not required to reproduce the “extension vs workspace barrier” failure
- Command/flags used: VS Code Command Palette → run any `drm-copilot` registered command that is mapped to a task label in `TASK_COMMAND_MAP` (excluding the informational `applyCustomizations`)
- Data source or fixture: Any workspace (including an empty/sample repo) that does *not* contain the expected tasks/scripts in its own `.vscode/tasks.json` or repo-local script folders

Impact / Severity:
- [x] Blocker
- [ ] High
- [ ] Medium
- [ ] Low


## Repro & Evidence
Steps to Reproduce:
1. Install/load the `drm-copilot` VS Code extension.
2. Open a workspace that does not contain the original utility scripts/tasks (i.e., a codebase that is *not* one of the repos the scripts were originally deployed into).
3. Run a `drm-copilot` command from the Command Palette that is implemented by invoking an underlying VS Code Task / script.
4. Observe that execution fails because the command attempts to run a task/script that does not exist in the workspace.

Expected:
`drm-copilot` commands should work in any workspace as long as the extension is installed:

- If the command needs to operate on the user’s codebase (files, folders, configs), it should target the *workspace filesystem and workspace context*.
- If the command relies on shared utilities packaged with the extension, it should execute those utilities from the *extension installation* while still applying them to the *workspace*.
- Commands should not require the user’s repo to manually copy tasks/scripts that are intended to be centrally provided by the extension.

Actual:
Commands attempt to invoke underlying tasks/scripts as if they are defined in the workspace, and execution fails because those tasks/scripts exist within the extension instead of the codebase.

Representative error symptoms (exact text may vary by command):

- VS Code reports a task cannot be found / resolved (e.g., “There is no task named …”, “Task not found”, or similar).
- Downstream command logic never runs, so effectively “none of the extension methods are working.”

Logs / Screenshots:

- [ ] Attached minimal logs or screenshot
- Snippet: `Task "Dev: 1 New Potential Entry" not found. Ensure tasks.json is configured.`


## Scope & Non-Goals

- In scope:
	- Execute `drm-copilot` commands in any workspace without requiring workspace-local `.vscode/tasks.json` entries.
	- Resolve extension-packaged scripts/tools from the extension install directory while operating on the workspace filesystem.
	- Define deterministic behavior for single-root and multi-root workspaces, including user selection when needed.
	- Preserve existing command IDs and task labels for UI stability.
- Out of scope / non-goals:
	- Auto-generating or modifying a user’s `.vscode/tasks.json`.
	- Rewriting tasks into direct `child_process` or custom terminal execution.
	- Changing the semantics of the underlying scripts/tools (only fix task discovery and execution boundaries).
- Explicitly excluded systems, integrations, or datasets:
	- External services or network integrations.
	- Workspace-specific task provider contributions outside the extension’s control.

## Root Cause Analysis

Core issue: the development strategy for exposing shared utilities via a VS Code extension is currently treating extension-internal code/assets as if they are available in (or installed into) the user’s workspace.

This creates a “code barrier” problem:

- Some functions were designed to interact with the filesystem and must operate on the *workspace’s filesystem* (user repo) rather than the extension’s install directory.
- Other functions reference code/assets that live *inside the extension* (scripts, modules, templates), and those references must be resolved relative to the extension.
- The current implementation path appears to invoke workspace-local Tasks (or repo-local scripts) without ensuring they exist, leading to failures in any repo that hasn’t already adopted/copied those utilities.

Design note: this likely requires explicitly modeling “workspace context” vs “extension context” and defining a stable boundary for execution (what runs where, and what paths/URIs are used).


## Proposed Fix

### Design summary (what changes where):
Introduce a `drm-copilot` task provider that programmatically creates tasks corresponding to the existing `TASK_COMMAND_MAP` labels. Update command execution to source tasks from the provider (not from workspace `tasks.json`) and to resolve scripts from the extension installation while using the target workspace folder as the execution context (`cwd`).

### Boundaries and invariants to preserve:
- Command IDs and labels remain stable; UI and keybindings continue to reference existing IDs.
- Workspace operations always target the selected workspace folder and never mutate the extension installation directory.
- Extension-packaged utilities are resolved via `context.extensionUri` / `context.asAbsolutePath()` and are never assumed to exist in the user’s repo.
- Multi-root behavior is deterministic and explicit (single-root uses the active folder; multi-root prompts the user).

### Dependencies or blocked work:
- None beyond VS Code task APIs already in use (`vscode.tasks.*`).

### Implementation strategy (what changes, not sequencing):
	
#### Files/modules to change:
- `src/extension.ts`: replace `fetchTasks()` lookup with provider-backed task creation/selection; add workspace folder selection logic.
- `src/task-command-map.ts`: extend mapping to include task definition metadata if needed (e.g., script path or execution mode).
- `package.json`: register the `drm-copilot` task type if required for task provider contribution (no new commands).

#### Functions/classes/CLI commands impacted:
- Command handlers wired in `src/extension.ts` that currently call `runTaskByLabel`.
- `runTaskByLabel` (or equivalent) to use provider-generated tasks rather than workspace tasks.

#### Data flow and validation changes:
- Resolve the target workspace folder from `vscode.workspace.workspaceFolders`:
	- If exactly one folder, use it.
	- If multiple, prompt the user to select.
	- If none, emit a clear error and stop.
- Resolve extension script paths using `context.extensionUri` / `context.asAbsolutePath()` and pass them into task executions.
- Build tasks in-memory with `TaskScope.Workspace` or folder scope and `ShellExecution`/`ProcessExecution`, using `options.cwd` set to the selected workspace folder.

#### Error handling and logging updates:
- When no workspace folder exists, show an actionable error (e.g., “Open a workspace folder to run drm-copilot tasks.”).
- When the command map has no matching task label, surface a clear internal error that includes the command ID.
- When tools referenced by tasks are missing in the user environment, rely on task execution errors but add guidance on required tooling where feasible.

#### Rollback/feature-flag considerations (if applicable):
- No feature flag required; change is isolated to task resolution and execution boundaries.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:
- Inputs: VS Code command invocation (no additional CLI flags), current workspace folders, extension installation path.
- Outputs: VS Code task execution for the selected command; error notifications when prerequisites are unmet.

#### Required configuration keys and defaults:
- No new configuration keys required.

#### Backward-compatibility expectations:
- Existing command IDs and task labels remain unchanged.
- Workspaces that already have matching tasks continue to work, but the extension no longer depends on those tasks being defined in `tasks.json`.

#### Performance constraints (latency/throughput/memory):
- Task creation should be lightweight; provider should avoid expensive I/O.
- Task execution should not add measurable overhead beyond existing task invocation.

## Assumptions, Constraints, Dependencies
- Assumptions (environment, data, access):
	- User has at least one workspace folder open when invoking a command.
	- Extension installation includes the packaged scripts/tools referenced by the command map.
- Constraints (budget, performance, compatibility):
	- Must remain compatible with VS Code task APIs and the extension activation model.
	- No changes to user repositories (no auto-editing of `.vscode/tasks.json`).
- External dependencies (services, libraries, releases):
	- None; uses existing VS Code APIs and extension resources.

## Data / API / Config Impact
- User-facing or API changes:
	- Commands now run without workspace task definitions; error messaging becomes explicit when no workspace is open.
- Data or migration considerations:
	- None; no data storage changes or migrations.
- Logging/telemetry updates (if any):
	- Add user-facing error notifications for missing workspace folders or invalid command mappings.
- Compatibility notes (CLI flags, config schemas, versioning):
	- No new CLI flags or configuration keys.

## Test Strategy
Seeded from issue:

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

- Regression tests to add or update:
- Regression tests to add or update:
	- Extend `tests/unit/task-command-map.test.ts` with cases for the command-to-task-definition mapping used by provider-created tasks.
	- Update `tests/integration/extension.test.ts` with a scenario that exercises command invocation in a workspace lacking `.vscode/tasks.json`.
- Unit tests (pytest) for the fixed behavior and boundaries:
	- Not applicable (TypeScript change).
- Edge cases and negative scenarios (invalid inputs, missing data, boundary values):
	- No workspace folders open → command reports actionable error and exits without task execution.
	- Multi-root workspace with user cancel → command exits gracefully without task execution.
	- Unknown command ID → clear error referencing the command ID.
- Error handling and logging verification:
	- Validate that missing workspace folders and missing command map entries produce user-facing errors.
- Coverage impact and targets for changed lines/modules:
	- Maintain repository coverage ≥ 80%; new/changed TypeScript logic ≥ 90% coverage.
- Toolchain commands to run (format → lint → type-check → test):
	- `npm run format`
	- `npm run lint`
	- `npm run typecheck`
	- `npm run test:unit`
- Manual validation steps (if required):
	- Install extension → open empty repo → run a `drm-copilot` command → verify task executes via extension resources and targets workspace.
	- Multi-root workspace → run command → verify folder selection prompt appears and selected folder is used for `cwd`.


## Acceptance Criteria
- [ ] Repro steps now produce the expected behavior in all documented environments, including a clean workspace with no `.vscode/tasks.json`.
- [ ] Regression tests added and passing:
	- `tests/unit/task-command-map.test.ts` includes provider mapping cases for command IDs → task definitions.
	- `tests/integration/extension.test.ts` validates command execution without workspace tasks.
- [ ] Edge cases and invalid inputs handled with correct errors or fallbacks:
	- No workspace folder open → user-facing error and no task execution.
	- Multi-root workspace with canceled selection → graceful exit.
- [ ] No unintended behavior changes outside the defined scope; command IDs and labels remain stable.
- [ ] Required logs/telemetry updated and validated (user-facing errors for missing workspace or invalid command mapping).
- [ ] Performance constraints met; task creation remains lightweight and does not add noticeable latency.
- [ ] Full toolchain pass completed (format → lint → type-check → test).
- [ ] Docs/config references updated to match the new behavior (if any user-facing guidance exists).

## Risks & Mitigations
- Technical or operational risks:
	- Task provider registration may conflict with user-defined tasks of the same label.
	- Multi-root selection adds UX friction if invoked frequently.
- Mitigations and rollbacks:
	- Scope provider tasks with a distinct `drm-copilot` task type and prefer explicit provider-backed resolution.
	- Cache last-selected workspace folder within the session to reduce repeated prompts.

## Rollout & Follow-up
- Release/rollout steps:
	- Ship extension update with task provider registration and command execution changes.
- Post-fix monitoring or clean-up tasks:
	- Monitor user reports for task execution failures in clean workspaces.
- Links: issue, PRs, related docs
	- Issue: #2
