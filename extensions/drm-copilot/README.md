# drm-copilot

`extensions/drm-copilot` provides two workspace-facing adapter surfaces over the same bundled repo-automation workflows:

- VS Code commands for interactive editor use.
- A stdio MCP server for Codex and other MCP clients.

The bundled workflows continue to execute from extension package resources. They do not copy repo-local scripts into the destination workspace before execution.

## VS Code Commands

The extension continues to contribute these stable command IDs:

- `drmCopilotExtension.helloPython`
- `drmCopilotExtension.helloPowerShell`
- `drmCopilotExtension.collectCommitContext`
- `drmCopilotExtension.collectPrContext`
- `drmCopilotExtension.pushDownCopilotCustomizations`
- `drmCopilotExtension.pushDownCodexAndAgentsCustomizations`
- `drmCopilotExtension.newPotentialBugEntry`
- `drmCopilotExtension.newPotentialEntry`
- `drmCopilotExtension.potentialToIssue`
- `drmCopilotExtension.newActiveFeatureFolder`
- `drmCopilotExtension.resolveExecuteHardLockPrompt`
- `drmCopilotExtension.syncAgentsFromInstructions`

The interactive VS Code flows keep their current prompts and branch/file pickers, but now delegate through the shared repo-automation service used by the MCP bridge.

## Sync AGENTS.md from Instructions

Use the `drm-copilot: Sync AGENTS.md from Instructions` command (command ID: `drmCopilotExtension.syncAgentsFromInstructions`) from the Command Palette to regenerate `AGENTS.md` in the active workspace. The bundled PowerShell script discovers all `.github/instructions/*.instructions.md` files under the active workspace root, aggregates their content in a deterministic order, and writes the consolidated result to `AGENTS.md` at the workspace root. This replaces any manual edits to `AGENTS.md` with a fully generated output derived from the workspace's canonical `.github` instruction files.

## MCP Server

The extension package also builds a stdio MCP server named `drmCopilotExtension`.

Downstream Codex skills should depend on the MCP server name `drmCopilotExtension`, not on raw VS Code command IDs such as `drmCopilotExtension.collectPrContext`.

### Exposed MCP Tools

- `collect_commit_context`
- `collect_pr_context`
- `push_down_copilot_customizations`
- `push_down_codex_and_agents_customizations`
- `new_potential_bug_entry`
- `new_potential_entry`
- `potential_to_issue`
- `new_active_feature_folder`
- `resolve_execute_hard_lock_prompt`

### MCP Runtime Expectations

- MCP tools are fully non-interactive.
- `workspace_root` is accepted by all workspace-targeted tools and defaults to `process.cwd()` when omitted.
- `collect_pr_context` requires an explicit `base` branch/ref in MCP mode.
- Bundled scripts are resolved from `extensions/drm-copilot/resources/...` at runtime.
- Subprocesses are launched with explicit argv arrays and `shell: false`.

### Codex Configuration Example

Build the extension package first:

```powershell
npm --prefix extensions/drm-copilot run build
```

Then configure the repo checkout as an MCP server:

```json
{
  "mcpServers": {
    "drmCopilotExtension": {
      "command": "node",
      "args": ["extensions/drm-copilot/out/mcp-server.js"]
    }
  }
}
```

If the server is launched from a different working directory, pass `workspace_root` explicitly in tool calls so the destination workspace stays deterministic.

### MCP Input Summary

- `collect_commit_context`: optional `workspace_root`
- `collect_pr_context`: optional `workspace_root`, required `base`
- `push_down_copilot_customizations`: optional `workspace_root`
- `push_down_codex_and_agents_customizations`: optional `workspace_root`
- `new_potential_bug_entry`: optional `workspace_root`, required `short_name`
- `new_potential_entry`: optional `workspace_root`, required `short_name`
- `potential_to_issue`: optional `workspace_root`, required `potential_path`, `promotion_type`, `work_mode`
- `new_active_feature_folder`: optional `workspace_root`, required `feature_name`, `type`, `work_mode`, optional `issue_number`
- `resolve_execute_hard_lock_prompt`: optional `workspace_root`, required `target`

### MCP Result Shape

MCP tool calls return structured JSON with:

- `ok`
- `tool`
- `workspace_root`
- `artifacts` when the workflow has deterministic or discovered output paths
- `summary`
- `stderr_excerpt` when a subprocess failure surfaces stderr diagnostics

## Runtime Requirements

- Python commands expect `python` on `PATH`.
- PowerShell commands prefer `pwsh` and fall back to `powershell` on Windows when available.
- An open workspace folder is required for workspace-targeted VS Code commands.
- MCP clients must build the package so `out/mcp-server.js` exists before launching the server.

`Resolve Execute Hard-Lock Prompt` depends on Python because it delegates to bundled Python resources at execution time.

## Execution Model

The shared repo-automation service executes these bundled wrapper resources:

- `resources/templates/collect_commit_context.py`
- `resources/templates/collect_pr_context.py`
- `resources/templates/push_down_copilot_customizations.py`
- `resources/templates/push_down_codex_and_agents_customizations.py`
- `resources/templates/new_potential_bug_entry.py`
- `resources/templates/new-potential-entry.ps1`
- `resources/templates/potential_to_issue.py`
- `resources/templates/new_active_feature_folder.py`
- `resources/templates/resolve_hard_lock_prompt.py`
- `resources/templates/run-poshqc-format.ps1`
- `resources/templates/run-poshqc-analyze.ps1`
- `resources/templates/run-poshqc-test.ps1`
- `resources/templates/run-poshqc-analyze-autofix.ps1`
- `resources/templates/run-poshqc-suite.ps1`
- `resources/powershell/PoshQC/`

The VS Code command adapters and the MCP server both call that same service layer. This preserves backward compatibility for the command IDs while providing a semantic MCP tool surface for downstream automation.

## Push Down Codex and Agents Customizations

Use the `drm-copilot: Push Down Codex and Agents Customizations` command (command ID: `drmCopilotExtension.pushDownCodexAndAgentsCustomizations`) from the Command Palette to copy the bundled `.codex` and `.agents` payload into the active workspace. The bundled Python wrapper executes the packaged publisher from `resources/templates/push_down_codex_and_agents_customizations.py`, uses the extension-packaged payload root at `resources/codex-and-agents-customizations/`, and writes a JSON summary artifact under `artifacts/codex-and-agents-customizations/` in the destination workspace.

## Run PoshQC Suite

Use the `drm-copilot: Run PoshQC Suite` command (command ID: `drmCopilotExtension.runPoshQCSuite`) from the Command Palette to run the bundled PowerShell quality gate from extension resources against the destination workspace. The bundled PowerShell wrapper executes `resources/templates/run-poshqc-suite.ps1`, imports the colocated `resources/powershell/PoshQC/` module copy, and can limit scanning to one or more selected destination-workspace folders.

Additional granular bundled PoshQC surfaces are also available through both VS Code commands and semantic MCP tools:

- `drmCopilotExtension.runPoshQCFormat` / `run_poshqc_format`
- `drmCopilotExtension.runPoshQCAnalyze` / `run_poshqc_analyze`
- `drmCopilotExtension.runPoshQCTest` / `run_poshqc_test`
- `drmCopilotExtension.runPoshQCAnalyzeAutofix` / `run_poshqc_analyze_autofix`

Each command/tool uses the same `workspace_root` plus optional `scan_folders` contract as the bundled suite. The autofix operation is intentionally mutating: it applies `PSScriptAnalyzer -Fix` to the selected PowerShell files, then reruns bundled analysis and fails if findings remain.
