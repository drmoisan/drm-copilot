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
- `drmCopilotExtension.runCodexNativeConverter`
- `drmCopilotExtension.pushDownCopilotCustomizations`
- `drmCopilotExtension.pushDownCodexAndAgentsCustomizations`
- `drmCopilotExtension.newPotentialBugEntry`
- `drmCopilotExtension.newPotentialEntry`
- `drmCopilotExtension.linkParentChild`
- `drmCopilotExtension.potentialToIssue`
- `drmCopilotExtension.newActiveFeatureFolder`
- `drmCopilotExtension.resolvePolicyAuditTemplateAsset`
- `drmCopilotExtension.resolveExecuteHardLockPrompt`
- `drmCopilotExtension.resolveAtomicPlanPrompt`
- `drmCopilotExtension.syncAgentsFromInstructions`
- `drmCopilotExtension.listMcpTools`

The interactive VS Code flows keep their current prompts and branch/file pickers, but now delegate through the shared repo-automation service used by the MCP bridge.

## Sync AGENTS.md from Instructions

Use the `drm-copilot: Sync AGENTS.md from Instructions` command (command ID: `drmCopilotExtension.syncAgentsFromInstructions`) from the Command Palette to regenerate `AGENTS.md` in the active workspace. The bundled PowerShell script discovers all `.github/instructions/*.instructions.md` files under the active workspace root, aggregates their content in a deterministic order, and writes the consolidated result to `AGENTS.md` at the workspace root. This replaces any manual edits to `AGENTS.md` with a fully generated output derived from the workspace's canonical `.github` instruction files.

## MCP Server

The extension package also builds a stdio MCP server named `drmCopilotExtension`.

## List MCP Tools

Use the `drm-copilot: List MCP Tools` command (command ID: `drmCopilotExtension.listMcpTools`) from the Command Palette to inspect the tools currently exposed by the `drmCopilotExtension` MCP server. The command shows the semantic tool names, each tool's description, and its required input fields in a Quick Pick list, and it also writes the full list to the `drm-copilot` output channel for reference.

Downstream Codex skills should depend on the MCP server name `drmCopilotExtension`, not on raw VS Code command IDs such as `drmCopilotExtension.collectPrContext`.

### Exposed MCP Tools

- `collect_commit_context`
- `collect_pr_context`
- `run_codex_native_converter`
- `push_down_copilot_customizations`
- `push_down_codex_and_agents_customizations`
- `new_potential_bug_entry`
- `new_potential_entry`
- `link_parent_child`
- `potential_to_issue`
- `new_active_feature_folder`
- `resolve_atomic_plan_prompt`
- `resolve_execute_hard_lock_prompt`
- `run_poshqc_format`
- `run_poshqc_analyze`
- `run_poshqc_test`
- `run_poshqc_analyze_autofix`
- `run_poshqc_suite`
- `resolve_policy_audit_template_asset`
- `validate_orchestration_artifacts`

### MCP Runtime Expectations

- MCP tools are fully non-interactive.
- `workspace_root` is accepted by all workspace-targeted tools and defaults to `process.cwd()` when omitted.
- `collect_pr_context` requires an explicit `base` branch/ref in MCP mode.
- `resolve_policy_audit_template_asset` requires `asset` and optionally accepts `target_path`; valid selectors are `template`, `code-review-template`, `feature-audit-template`, and `agents`. When `target_path` is omitted, callers receive the bundled source path for the requested asset.
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
- `run_codex_native_converter`: optional `workspace_root`, required `mode`, required `source_ecosystem`, required `source_root`, optional `selected_paths`, optional `destination_root`, optional `artifact_root`, optional `enable_repo_prompts`
- `push_down_copilot_customizations`: optional `workspace_root`
- `push_down_codex_and_agents_customizations`: optional `workspace_root`
- `new_potential_bug_entry`: optional `workspace_root`, required `short_name`
- `new_potential_entry`: optional `workspace_root`, required `short_name`
- `link_parent_child`: optional `workspace_root`, required `child_issue_number`, required `parent_issue_number`
- `potential_to_issue`: optional `workspace_root`, required `potential_path`, `promotion_type`, `work_mode`
- `new_active_feature_folder`: optional `workspace_root`, required `feature_name`, `type`, `work_mode`, optional `issue_number`
- `resolve_policy_audit_template_asset`: optional `workspace_root`, required `asset` (`template` | `code-review-template` | `feature-audit-template` | `agents`), optional `target_path`
- `resolve_atomic_plan_prompt`: optional `workspace_root`, required `target`
- `resolve_execute_hard_lock_prompt`: optional `workspace_root`, required `target`
- run_poshqc_format: optional `workspace_root`, optional `scan_folders`
- run_poshqc_analyze: optional `workspace_root`, optional `scan_folders`
- run_poshqc_test: optional `workspace_root`, optional `scan_folders`
- run_poshqc_analyze_autofix: optional `workspace_root`, optional `scan_folders`
- run_poshqc_suite: optional `workspace_root`, optional `scan_folders`
- validate_orchestration_artifacts: optional `workspace_root`, required `artifact_type`, required `artifact_path`, optional `require_complete`

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

`Resolve Atomic Plan Prompt` also depends on Python because it delegates to bundled Python resources at execution time.

## Execution Model

The shared repo-automation service executes these bundled wrapper resources:

- `resources/templates/collect_commit_context.py`
- `resources/templates/collect_pr_context.py`
- `resources/templates/codex_native_converter.py`
- `resources/templates/push_down_copilot_customizations.py`
- `resources/templates/push_down_codex_and_agents_customizations.py`
- `resources/templates/new_potential_bug_entry.py`
- `resources/templates/new-potential-entry.ps1`
- `resources/templates/link-parent-child.ps1`
- `resources/templates/potential_to_issue.py`
- `resources/templates/new_active_feature_folder.py`
- `resources/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md`
- `resources/templates/policy_audit/code-review.yyyy-MM-ddTHH-mm.md`
- `resources/templates/policy_audit/feature-audit.yyyy-MM-ddTHH-mm.md`
- `resources/templates/policy_audit/AGENTS.md`
- `resources/templates/resolve_atomic_plan_prompt.py`
- `resources/templates/resolve_hard_lock_prompt.py`
- `resources/templates/run-poshqc-format.ps1`
- `resources/templates/run-poshqc-analyze.ps1`
- `resources/templates/run-poshqc-test.ps1`
- `resources/templates/run-poshqc-analyze-autofix.ps1`
- `resources/templates/run-poshqc-suite.ps1`
- `resources/powershell/PoshQC/`

The VS Code command adapters and the MCP server both call that same service layer. This preserves backward compatibility for the command IDs while providing a semantic MCP tool surface for downstream automation.

`resolve_policy_audit_template_asset` and `drmCopilotExtension.resolvePolicyAuditTemplateAsset` are additive surface adapters over the same bundled policy-audit assets. They support the selectors `template`, `code-review-template`, `feature-audit-template`, and `agents`. In MCP mode, callers receive the canonical asset id plus the bundled source path and, when requested, the copied destination path. In VS Code, interactive use opens the bundled asset when no target is supplied and copies it into the workspace when `-target <path>` is supplied.

## Codex-native converter wrapper

Use the `drm-copilot: Run Codex-native Converter` command (command ID: `drmCopilotExtension.runCodexNativeConverter`) from the Command Palette to run the bundled Python converter against the active workspace. The command prompts for review or apply mode and the source ecosystem, then delegates to `resources/templates/codex_native_converter.py`.

The same workflow is available through the semantic MCP tool `run_codex_native_converter`. MCP callers provide the non-interactive input contract directly:

- required `mode`: `review` or `apply`
- required `source_ecosystem`: `github-copilot` or `claude`
- required `source_root`: workspace-relative or absolute source runtime root
- optional `selected_paths`: repeated workspace-relative or absolute source paths to limit the run scope
- optional `destination_root`: required when `mode` is `apply`
- optional `artifact_root`: override for the report-set root
- optional `enable_repo_prompts`: allow `.codex/prompts/**` output when the destination repository explicitly uses that surface

The wrapper remains thin by design: it does not implement a second converter. It forwards arguments to the bundled Python CLI, surfaces the printed artifact root, and relies on the converter's fail-closed validation model before any destination writes occur.

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
