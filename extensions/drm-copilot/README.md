# Scaffold Extension

This extension executes bundled hello scripts directly from extension resources while targeting the active workspace as runtime `cwd`.

## Commands

- `drmCopilotExtension.helloPython`
- `drmCopilotExtension.helloPowerShell`
- `drmCopilotExtension.collectCommitContext`

### Commit Context Command Contract

- Command Palette title: `Scaffold: Collect Commit Context`
- Requires an open workspace folder.
- Executes bundled collector resource: `resources/templates/collect_commit_context.py`
- Writes output artifact to: `artifacts/commit_context.txt` under the active workspace.

## Runtime Requirements

- Python command: `python`
- PowerShell commands: `pwsh` (preferred), then `powershell`

If runtime detection fails, handlers throw actionable runtime-named errors.

## Platform Runtime Notes

- **Windows**
	- Python runtime lookup expects `python` on `PATH`.
	- PowerShell runtime prefers `pwsh`; falls back to `powershell` when `pwsh` is unavailable.
- **macOS**
	- Python runtime lookup expects `python` on `PATH`.
	- PowerShell runtime lookup expects `pwsh` (PowerShell 7) when installed.
- **Linux**
	- Python runtime lookup expects `python` on `PATH`.
	- PowerShell runtime lookup expects `pwsh` when installed.

Runtime probing emits clear output-channel messages so users can identify missing runtime dependencies quickly.

## Output Channel

The extension logs command lifecycle events to the `Scaffold Utils` output channel:

- Runtime probe start/success/failure
- Resolved bundled script path
- Command start/success/failure

## Execution Model

Bundled scripts are resolved from extension resources:

- `resources/templates/hello_python.py`
- `resources/templates/hello_pwsh.ps1`

Artifacts are generated under workspace `artifacts/` by the script runtime. The implementation enforces **no workspace-root script copying**.

## First-run workflow

1. Open a workspace folder in VS Code.
2. Open the Command Palette and run `drmCopilotExtension.helloPython`.
3. Confirm Python runtime probe and command logs in the `Scaffold Utils` output channel.
4. Open the Command Palette and run `drmCopilotExtension.helloPowerShell`.
5. Confirm PowerShell runtime probe and command logs in the `Scaffold Utils` output channel.
6. Verify output artifacts under workspace `artifacts/`.

## Production foundation

This scaffold is a **Production foundation** for extension-to-workspace execution. It demonstrates a deterministic pattern for resolving bundled extension resources, validating runtimes, and invoking subprocesses with explicit argv arrays against the active workspace context.
