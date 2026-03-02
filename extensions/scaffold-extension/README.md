# Scaffold Extension

This extension executes bundled hello scripts directly from extension resources while targeting the active workspace as runtime `cwd`.

## Commands

- `scaffoldExtension.helloPython`
- `scaffoldExtension.helloPowerShell`

## Runtime Requirements

- Python command: `python`
- PowerShell commands: `pwsh` (preferred), then `powershell`

If runtime detection fails, handlers throw actionable runtime-named errors.

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
