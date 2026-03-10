# 2026-01-28-scaffold-extension — Spec

- **Issue:** #16
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-02-11T20-01
- **Status:** Draft
- **Version:** 1.0

## Overview

The repo contains Python, PowerShell, JSON, and Bash QC tooling, but there is no extension framework that demonstrates how to invoke these tools from within a destination workspace.
This MVP provides a minimal VS Code Extension scaffold that establishes the foundational pattern for extension-based workspace scripting:
TypeScript command handler → runtime validation → extension-resource script resolution → subprocess execution against destination workspace context → artifact generation.
Two "hello" commands serve as the proof-of-concept and test harness for future production extensions.
The extension executes packaged scripts in place from extension resources and writes only output artifacts to the destination workspace; it does not materialize hello scripts into workspace root.


## Behavior

Provide a minimal VS Code Extension that demonstrates the extension-to-workspace scripting pattern:

- **Hello Python**
	- Discover active workspace root; fail with clear error if no workspace is open.
	- Validate Python runtime availability (`python` on PATH); fail with clear error if missing.
	- Resolve bundled `hello_python.py` path from inside the extension package.
	- Execute bundled `hello_python.py` using subprocess, targeting the active destination workspace context.
	- Ensure `artifacts/hello_python.txt` is created by the script.
	- Log command lifecycle details to OutputChannel (runtime probe result, script path, start, completion, failure).
- **Hello PowerShell**
	- Discover active workspace root; fail with clear error if no workspace is open.
	- Validate PowerShell runtime availability (`pwsh` preferred, fallback to `powershell`); fail with clear error if missing.
	- Resolve bundled `hello_pwsh.ps1` path from inside the extension package.
	- Execute bundled `hello_pwsh.ps1` using subprocess, targeting the active destination workspace context.
	- Ensure `artifacts/hello_pwsh.txt` is created by the script.
	- Log command lifecycle details to OutputChannel (runtime probe result, script path, start, completion, failure).

General behavior:
- Commands run from TypeScript extension code via VS Code extension API after command registration in extension manifest and activation entrypoint.
- Bundled script paths are resolved from extension installation resources; hello scripts are never copied into destination workspace root.
- Runtimes are detected in extension code using deterministic probe order: `python` for Python; `pwsh` then `powershell` for PowerShell.
- Output is logged to a dedicated OutputChannel ("Scaffold Utils") for traceability and debugging.
- Error messages are clear and actionable (missing workspace, missing runtime, script non-zero exit), and failures include runtime/command context.


## Inputs / Outputs

- Inputs
	- Workspace root folder (required; extension fails if no workspace is open).
	- Runtime availability: `python` on PATH; `pwsh` or `powershell` on PATH (probe order: `pwsh` then `powershell`).
	- Bundled extension scripts: `resources/templates/hello_python.py`, `resources/templates/hello_pwsh.ps1`.
- Outputs
	- Artifacts written by scripts: `artifacts/hello_python.txt`, `artifacts/hello_pwsh.txt`.
	- Logs: OutputChannel ("Scaffold Utils") entries for runtime detection attempts/results, script resolution path, execution start/end, and error details.
	- No `hello_python.py` or `hello_pwsh.ps1` files are created in workspace root during command execution.
- Config keys and defaults: None for the MVP.
- Versioning or backward-compatibility constraints: None; MVP is additive and does not change existing runtime behavior.

## API / CLI Surface

Commands (Command Palette):
- **Hello Python**
	- Command ID: `drmCopilotExtension.helloPython`
	- Example: run “Hello Python” → `artifacts/hello_python.txt` created
- **Hello PowerShell**
	- Command ID: `drmCopilotExtension.helloPowerShell`
	- Example: run “Hello PowerShell” → `artifacts/hello_pwsh.txt` created

Contracts and validation rules:
- If no workspace root is open, commands must fail with a clear user-facing error.
- If the required runtime is missing, commands must fail with an error that names the runtime (`python`, `pwsh`, `powershell`).
- Commands must execute bundled extension scripts against destination workspace context and must not require manual path edits.
- Commands must not copy bundled hello scripts into workspace root.
- Command registration and invocation behavior must be testable via command IDs `drmCopilotExtension.helloPython` and `drmCopilotExtension.helloPowerShell`.

## Data & State

Data flow and state:
- On command invocation, resolve workspace root → detect runtime → resolve bundled script path → execute script.
- Runtime detection is ephemeral per invocation (no caching).

Data transformations and invariants:
- `artifacts/hello_python.txt` and `artifacts/hello_pwsh.txt` are always written under the active workspace root.
- Script execution uses extension-bundled script paths with workspace root passed as execution context.
- `hello_python.py` and `hello_pwsh.ps1` are never materialized in destination workspace root by command execution.

Caching or persistence details:
- None; no persistent extension state beyond created workspace files.

Migration or backfill requirements (if any):
- None.

## Constraints & Risks

- Must not assume global installs beyond typical runtimes; detect and clearly report missing Python/PowerShell runtimes.
- Extension packaging size must stay small; use only bundled `hello_*.py` and `hello_*.ps1` scripts.
- Cross-platform shell invocation differences require robust platform-specific handling (path separators, shell paths).
- Cross-platform invocation must handle Windows and POSIX differences without shell-string concatenation (explicit executable + args).
- Commands require an active workspace root; running without a workspace is an explicit error path.
- Scope risk: keep this MVP minimal and focused on the scripting pattern; future production extensions will extend this foundation.
- No feature flags or staged rollout; extension loads in all environments but commands gracefully fail with clear errors.


## Implementation Strategy

- Implementation scope (what changes, not sequencing):
	- Create a minimal VS Code extension under `extensions/scaffold-extension/` with manifest (`package.json`) and TypeScript entry point (`src/extension.ts`).
	- Implement two commands (`drmCopilotExtension.helloPython` and `drmCopilotExtension.helloPowerShell`) that demonstrate the scripting pattern.
	- Include bundled scripts (`resources/templates/hello_python.py` and `resources/templates/hello_pwsh.ps1`) executed directly from extension resources.
	- Provide unit and integration tests with clear documentation of the extension-to-workspace scripting model.
- New classes/functions/commands to add or update:
	- `activate` function and command registrations in `src/extension.ts`.
	- `detectRuntime(kind: string): Promise<string | null>` helper (checks `python`, and `pwsh` then `powershell` on PATH).
	- `resolveBundledScriptPath(scriptName: string): string` helper (locates packaged script files in extension resources).
	- Command handlers for `drmCopilotExtension.helloPython` and `drmCopilotExtension.helloPowerShell`.
	- `executeBundledScriptInWorkspace(workspaceRoot: string, scriptPath: string, timeout?: number): Promise<void>` helper (runs packaged script via subprocess, captures output).
- Dependency changes (new/removed packages) and rationale:
	- None; use built-in Node.js and VS Code APIs only (no external npm packages beyond dev dependencies).
- Logging/telemetry additions and locations:
	- OutputChannel ("Scaffold Utils") for runtime detection, execution start/end, and error details.
	- No telemetry in MVP.
- Rollout plan (feature flags, staged deploys, fallback path):
	- No feature flags; extension loads in all environments. Commands fail gracefully with clear errors on missing workspace or runtimes.

## Definition of Done

- [ ] Extension manifest and entry point are present and register both hello commands.
- [ ] Both commands execute successfully on Windows and POSIX platforms without manual edits.
- [ ] Unit tests cover: command registration, runtime detection (present/missing cases), bundled script path resolution logic.
- [ ] Integration tests verify end-to-end execution of both commands with artifact creation.
- [ ] Error cases are tested: no open workspace, missing Python, missing PowerShell, non-zero script exit.
- [ ] Output is logged to the "Scaffold Utils" OutputChannel with appropriate detail.
- [ ] Tests verify no `hello_*.py`/`hello_*.ps1` files are copied into workspace root during command execution.
- [ ] Runtime detection behavior is verified: Python probes `python`; PowerShell probes `pwsh` then `powershell` with actionable failure messaging.
- [ ] README documents the scripting pattern, required runtimes, and first-run workflow.
- [ ] README includes a section on how the extension demonstrates the foundation for production extensions.
- [ ] Toolchain pass completed (format → lint → type-check → test).

## Seeded Test Conditions (from potential)

- [ ] Unit test: command registration (both commands are registered correctly).
- [ ] Unit test: runtime detection logic (happy path and missing runtime cases).
- [ ] Unit test: bundled script path resolution logic (extension resource path discovery and validation).
- [ ] Integration test: end-to-end execution of Hello Python on available platform.
- [ ] Integration test: end-to-end execution of Hello PowerShell on available platform.
- [ ] Test error case: no open workspace when running command.
- [ ] Test error case: Python not available on PATH.
- [ ] Test error case: PowerShell not available on PATH.
- [ ] Test error case: script exits with non-zero status.
- [ ] Artifact verification: `artifacts/hello_python.txt` created with expected content.
- [ ] Artifact verification: `artifacts/hello_pwsh.txt` created with expected content.
- [ ] OutputChannel logging verified for normal and error paths.
- [ ] Invariant test: command execution does not create `hello_python.py` or `hello_pwsh.ps1` in workspace root.
