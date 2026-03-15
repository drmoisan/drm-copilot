# drm-copilot

This extension executes bundled scripts directly from extension resources while targeting the active workspace as runtime `cwd`.

## Commands

- `drmCopilotExtension.helloPython`
- `drmCopilotExtension.helloPowerShell`
- `drmCopilotExtension.collectCommitContext`
- `drmCopilotExtension.collectPrContext`
- `drmCopilotExtension.pushDownCopilotCustomizations`
- `drmCopilotExtension.newPotentialBugEntry`
- `drmCopilotExtension.newPotentialEntry`
- `drmCopilotExtension.potentialToIssue`
- `drmCopilotExtension.newActiveFeatureFolder`
- `drmCopilotExtension.resolveExecuteHardLockPrompt`

### Resolve Execute Hard-Lock Prompt

- Command Palette title: `drm-copilot: Resolve Execute Hard-Lock Prompt`
- Requires an open workspace folder.
- Reuses the active Markdown feature plan under `docs/features/active/` when possible; otherwise prompts for a Markdown plan file under that folder.
- Executes bundled Python wrapper: `resources/templates/resolve_hard_lock_prompt.py`
- The wrapper injects bundled hard-lock prompt templates from `resources/customizations/.github/codex/` so the command works even when the active workspace does not contain repo-local `.github/codex` assets.
- Passes only `--target <selected-plan-path>` and `--workspace <workspace-root>` to the bundled resolver entrypoint.

### Push Down Copilot Customizations

- Command Palette title: `drm-copilot: Push Down Copilot Customizations`
- Requires an open workspace folder.
- Executes bundled wrapper: `resources/templates/push_down_copilot_customizations.py`
- Passes `--destination` with the open workspace root.
- Source customizations are read from the bundled `resources/customizations/.github/` payload.
- The summary artifact is written under the destination workspace.
- Script references in copied files are rewritten to the live VS Code command IDs contributed by the extension.

### Commit Context Command Contract

- Command Palette title: `drm-copilot: Collect Commit Context`
- Requires an open workspace folder.
- Executes bundled collector resource: `resources/templates/collect_commit_context.py`
- Writes output artifact to: `artifacts/commit_context.txt` under the active workspace.

## Runtime Requirements

- Python command: `python`
- PowerShell commands: `pwsh` (preferred), then `powershell`

`Resolve Execute Hard-Lock Prompt` depends on a Python runtime being available on `PATH` because the command delegates to bundled Python resources at execution time.

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

The extension logs command lifecycle events to the `drm-copilot` output channel:

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
3. Confirm Python runtime probe and command logs in the `drm-copilot` output channel.
4. Open the Command Palette and run `drmCopilotExtension.helloPowerShell`.
5. Confirm PowerShell runtime probe and command logs in the `drm-copilot` output channel.
6. Verify output artifacts under workspace `artifacts/`.

## Production foundation

This scaffold is a **Production foundation** for extension-to-workspace execution. It demonstrates a deterministic pattern for resolving bundled extension resources, validating runtimes, and invoking subprocesses with explicit argv arrays against the active workspace context.
