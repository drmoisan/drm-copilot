# 2026-02-01-extension-code-barrier (Spec)

- **Issue:** #2
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-02-03T00-00
- **Status:** Active
- **Version:** 2.0

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
Replace task-backed shell execution with an extension-owned utility runtime that executes utilities from the extension host, while passing workspace context as explicit inputs. Commands remain registered by ID, but command handlers execute utility logic directly (or through extension-owned assets) rather than invoking workspace-local tasks or scripts.

This specifically eliminates current patterns in `src/task-command-map.ts` where:
- Python commands invoke `scripts.dev_tools.*` modules via `poetry run python -m ...`, which resolves from the workspace instead of the extension.
- PowerShell commands are split between `${extensionRoot}` and `${workspaceFolder}` paths, producing inconsistent code provenance.
- Execution depends on host tools (`poetry`, `python`, `pwsh`, `gh`, `npm`) without extension-owned fallbacks.

### Boundaries and invariants to preserve:
- Command IDs and labels remain stable; UI and keybindings continue to reference existing IDs.
- Workspace operations always target the selected workspace folder and never mutate the extension installation directory.
- Extension-owned utilities are resolved via `context.extensionUri` / `context.asAbsolutePath()` and are never assumed to exist in the user’s repo.
- Multi-root behavior is deterministic and explicit (single-root uses the active folder; multi-root prompts the user).

Additional boundary requirement:
- Workspace-local utilities (e.g., `${workspaceFolder}/scripts/...` or `scripts.dev_tools.*`) are never used as the primary execution path for extension commands.

### Dependencies or blocked work:
- None beyond VS Code extension APIs already in use.

### Implementation strategy (what changes, not sequencing):
	
#### Files/modules to change:
- `src/extension.ts`: route command handlers to execute extension-owned utilities directly (no workspace task lookup).
- `src/task-command-map.ts`: replace shell/task execution specs with utility operation descriptors and required inputs, and remove command definitions that directly reference workspace-local modules (e.g., `scripts.dev_tools.*`).
- `src/drm-task-provider.ts`: keep only if task integration is still required for long-running operations; otherwise remove task-provider dependence from command execution.
- `package.json`: keep command contributions unchanged.

#### Functions/classes/CLI commands impacted:
- Command handlers wired in `src/extension.ts` that currently build `ShellExecution` tasks.
- The execution path that resolves `TASK_COMMAND_MAP` entries into shell commands.

Concrete execution targets to remove from the task map:
- Python `-m scripts.dev_tools.*` invocations that rely on workspace-local modules.
- Mixed `${workspaceFolder}` script references that are intended to be extension-owned.

#### Data flow and validation changes:
- Resolve the target workspace folder from `vscode.workspace.workspaceFolders`:
	- If exactly one folder, use it.
	- If multiple, prompt the user to select.
	- If none, emit a clear error and stop.
- Resolve extension-owned templates/tools using `context.extensionUri` / `context.asAbsolutePath()` and pass the resolved paths into utility execution.
- Execute utilities inside the extension host with explicit workspace paths and inputs; avoid workspace-local module imports such as `scripts.dev_tools.*`.
- Normalize all utility paths to extension-owned locations (using `context.asAbsolutePath()`), and pass workspace paths as explicit parameters (never as implicit module search paths).

#### Error handling and logging updates:
- When no workspace folder exists, show an actionable error (e.g., “Open a workspace folder to run DRM Copilot utilities.”).
- When a command has no utility mapping, surface a clear internal error that includes the command ID.
- If a command still requires a host tool (e.g., `gh`, `python`, `pwsh`), perform a preflight check and emit a guided error if missing.

Preflight checks should cover the current host-tool dependencies visible in `task-command-map.ts`:
- `poetry` / `python`
- `pwsh`
- `gh`
- `npm`

#### Rollback/feature-flag considerations (if applicable):
- No feature flag required; change is isolated to task resolution and execution boundaries.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:
- Inputs: VS Code command invocation, current workspace folders, extension installation path, active file path (when relevant), and user-provided prompt values.
- Outputs: Utility execution inside the extension host, workspace file updates, and error notifications when prerequisites are unmet.

Execution inputs should include the resolved extension asset paths for any bundled templates or scripts, replacing existing `${workspaceFolder}` task arguments.

#### Required configuration keys and defaults:
- No new configuration keys required.

#### Backward-compatibility expectations:
- Existing command IDs and task labels remain unchanged.
- Workspaces that already have matching tasks continue to work, but the extension no longer depends on those tasks or workspace-local scripts for execution.

#### Performance constraints (latency/throughput/memory):
- Utility dispatch should be lightweight; avoid expensive I/O during activation.
- Utility execution should not add measurable overhead beyond the prior task invocation path.

## Assumptions, Constraints, Dependencies
- Assumptions (environment, data, access):
	- User has at least one workspace folder open when invoking a command.
	- Extension installation includes the packaged utilities and templates referenced by commands.
- Constraints (budget, performance, compatibility):
	- Must remain compatible with the VS Code extension activation model.
	- No changes to user repositories (no auto-editing of `.vscode/tasks.json`).
- External dependencies (services, libraries, releases):
	- None required; host tools are treated as optional dependencies with explicit preflight checks.

## Data / API / Config Impact
- User-facing or API changes:
	- Commands run without workspace task definitions or workspace-local scripts; error messaging becomes explicit when no workspace is open or a host tool is missing.
- Data or migration considerations:
	- None; no data storage changes or migrations.
- Logging/telemetry updates (if any):
	- Add user-facing error notifications for missing workspace folders, missing utility mappings, or missing host tools.
- Compatibility notes (CLI flags, config schemas, versioning):
	- No new CLI flags or configuration keys.

## Test Strategy
Seeded from issue:

- [ ] Unit coverage areas
	- Command execution layer: verify that registered commands dispatch to extension-owned utilities and do not assume workspace tasks exist.
	- Path resolution: tests for “extension resource path” vs “workspace root path” selection.
	- Execution adapter: verify utilities run inside the extension host and do not invoke workspace-local modules.
	- Filesystem operations: validate that file reads/writes target the selected workspace folder and not `context.extensionUri`.

- [ ] Integration scenario to retest
	- Install extension → open a clean/scratch repo with no special configuration → run each `drm-copilot` command → confirm the command either:
		- succeeds using extension-owned utilities against workspace files, or
		- fails with a clear, actionable error that explains required prerequisites.

- [ ] Manual verification notes
	- Validate behavior on:
		- single-root workspace
		- multi-root workspace (ensure the target workspace folder selection is well-defined)
		- workspaces with and without host tools installed (commands should degrade gracefully or provide clear guidance)
	- Confirm that any “runs a script” behavior uses the correct working directory (workspace root) while referencing scripts located in the extension (if applicable).

- Regression tests to add or update:
	- Extend `tests/unit/task-command-map.test.ts` with cases for command-to-utility mappings used by extension-owned execution.
	- Update `tests/integration/extension.test.ts` with a scenario that exercises command invocation in a workspace lacking `.vscode/tasks.json` and workspace-local scripts.
- Unit tests (pytest) for the fixed behavior and boundaries:
	- Not applicable (TypeScript change).
- Edge cases and negative scenarios (invalid inputs, missing data, boundary values):
	- No workspace folders open → command reports actionable error and exits without task execution.
	- Multi-root workspace with user cancel → command exits gracefully without task execution.
	- Unknown command ID → clear error referencing the command ID.
	- Host tool required but missing → clear error explaining required tooling.
- Error handling and logging verification:
	- Validate that missing workspace folders, missing utility mappings, and missing host tools produce user-facing errors.
- Coverage impact and targets for changed lines/modules:
	- Maintain repository coverage ≥ 80%; new/changed TypeScript logic ≥ 90% coverage.
- Toolchain commands to run (format → lint → type-check → test):
	- `npm run format`
	- `npm run lint`
	- `npm run typecheck`
	- `npm run test:unit`
- Manual validation steps (if required):
	- Install extension → open empty repo → run a `drm-copilot` command → verify utility executes via extension resources and targets workspace.
	- Multi-root workspace → run command → verify folder selection prompt appears and selected folder is used for workspace operations.


## Acceptance Criteria
- [ ] Repro steps now produce the expected behavior in all documented environments, including a clean workspace with no `.vscode/tasks.json` and no repo-local scripts.
- [ ] Regression tests added and passing:
	- `tests/unit/task-command-map.test.ts` includes command-to-utility mapping cases for extension-owned execution.
	- `tests/integration/extension.test.ts` validates command execution without workspace tasks or workspace-local scripts.
- [ ] Edge cases and invalid inputs handled with correct errors or fallbacks:
	- No workspace folder open → user-facing error and no execution.
	- Multi-root workspace with canceled selection → graceful exit.
	- Host tool required but missing → user-facing error with guidance.
- [ ] No unintended behavior changes outside the defined scope; command IDs and labels remain stable.
- [ ] Required logs/telemetry updated and validated (user-facing errors for missing workspace, missing utility mapping, or missing host tool).
- [ ] Performance constraints met; utility dispatch remains lightweight and does not add noticeable latency.
- [ ] Full toolchain pass completed (format → lint → type-check → test).
- [ ] Docs/config references updated to match the new behavior (if any user-facing guidance exists).

## Risks & Mitigations
- Technical or operational risks:
	- Rewriting utilities into the extension host increases implementation scope and requires parity with existing scripts.
	- Some commands may still depend on external tools, causing failures on clean systems.
	- Multi-root selection adds UX friction if invoked frequently.
- Mitigations and rollbacks:
	- Incrementally migrate utilities, starting with the most frequently used commands and validating behavior parity.
	- Add preflight checks and actionable errors for missing host tools.
	- Cache last-selected workspace folder within the session to reduce repeated prompts.

## Rollout & Follow-up
- Release/rollout steps:
	- Ship extension update with extension-owned utility runtime and updated command execution.
- Post-fix monitoring or clean-up tasks:
	- Monitor user reports for utility execution failures in clean workspaces and missing-tool errors.
- Links: issue, PRs, related docs
	- Issue: #2

---

## Implementation Results

### Scope Deviations

**Current status:** No implementation has been executed for the extension-owned runtime. The prior task-provider approach documented in the v1 spec does not resolve the root cause because utilities still depend on workspace-local scripts and host toolchains.

### Final Test Evidence

**TypeScript Toolchain (current status):**
- Not executed for the v2 approach. Previous toolchain results from the task-provider attempt are not applicable to the extension-owned runtime.

**Test Coverage:**
- No v2-specific tests executed yet. Prior tests validated the task-provider mapping, not extension-owned utility execution.

**Files Modified:**
- None for v2 yet. This spec supersedes the task-provider-only approach.

**Acceptance criteria status:**
- Not yet met for v2. The extension-owned runtime implementation and tests are required before closure.
