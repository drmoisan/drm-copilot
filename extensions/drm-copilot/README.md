# drm-copilot

`extensions/drm-copilot` provides repository automation, customization publishing, and MCP bridge for drm-copilot workflows. It exposes two workspace-facing adapter surfaces over the same bundled repo-automation workflows:

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
- `drmCopilotExtension.newClaudeWorktreeSession`
- `drmCopilotExtension.removeSecondaryWorktrees`

The interactive VS Code flows keep their current prompts and branch/file pickers, but now delegate through the shared repo-automation service used by the MCP bridge.

## Sync AGENTS.md from Instructions

Use the `drm-copilot: Sync AGENTS.md from Instructions` command (command ID: `drmCopilotExtension.syncAgentsFromInstructions`) from the Command Palette to regenerate `AGENTS.md` in the active workspace. The bundled PowerShell script discovers all `.github/instructions/*.instructions.md` files under the active workspace root, aggregates their content in a deterministic order, and writes the consolidated result to `AGENTS.md` at the workspace root. This replaces any manual edits to `AGENTS.md` with a fully generated output derived from the workspace's canonical `.github` instruction files.

## New Claude Worktree Session

Use the `drm-copilot: New Claude Worktree Session` command (command ID: `drmCopilotExtension.newClaudeWorktreeSession`) from the Command Palette to open an integrated PowerShell terminal that creates a new git worktree, navigates into it, optionally installs and activates the poetry environment when the workspace declares poetry, and then starts an interactive `claude` session. The command prompts for an optional objective to pass to `claude` as the initial prompt.

### Injecting a pre-`claude` script

The command can run a local PowerShell script in the new worktree immediately before `claude` is started. This lets a repository carry its own pre-session setup (for example, copying machine-local configuration, seeding environment variables, or running a repo-specific bootstrap) in the local repository rather than centrally in the extension.

How it works:

- The script path is read from the `drmCopilotExtension.newClaudeWorktreeSession.preClaudeScriptPath` configuration setting.
- The default value is `.claude/hooks/pre-claude-session.ps1`, resolved relative to the new worktree root.
- After the worktree is created, navigated into, and (when applicable) the poetry environment is installed and activated, the command runs the configured script if it exists in the worktree, then starts `claude`.
- The script runs only when it exists: the command emits a runtime existence guard (`if (Test-Path -LiteralPath '<path>') { & '<path>' }`), so a missing script is not an error and the session proceeds directly to `claude`.

To use the default convention, commit a PowerShell script to the repository at `.claude/hooks/pre-claude-session.ps1`. Because the script lives in the repository, it is present in the new worktree after `git worktree add` and runs automatically on the next worktree session.

To use a different path, set the configuration value in the repository's `.vscode/settings.json` so the setting travels with the local repository:

```json
{
  "drmCopilotExtension.newClaudeWorktreeSession.preClaudeScriptPath": ".claude/hooks/my-bootstrap.ps1"
}
```

Notes:

- The path is resolved relative to the worktree root and is embedded with PowerShell single-quote escaping, so paths containing spaces or apostrophes are preserved literally.
- Leaving the setting empty or whitespace-only suppresses the pre-`claude` step entirely; no additional command is sent.
- The script runs in the worktree's PowerShell session before `claude` takes over the terminal.

## Remove Secondary Worktrees

Use the `drm-copilot: Remove Secondary Worktrees` command (command ID: `drmCopilotExtension.removeSecondaryWorktrees`) from the Command Palette to remove all secondary git worktrees of the current repository. The primary (main) worktree is never removed.

How it works:

- The command first shows a modal confirmation. It proceeds only when you select "Remove All"; any other choice (including dismissal) cancels the operation without issuing any git command.
- It enumerates worktrees via `git worktree list --porcelain` and excludes the primary worktree by position (the first reported block), so the primary is never selected for removal.
- Each secondary worktree is removed with NON-force `git worktree remove <path>`. The `--force` option is never used, so a worktree that cannot be fully removed (for example, one with modified or untracked files) fails the removal cleanly and is left intact rather than partially deleted.
- Locked worktrees and prunable worktrees (those whose working directory is missing on disk) are skipped with a reason and left intact; no removal is attempted for them.
- `git worktree prune` is not invoked automatically. Prunable worktrees are reported as skipped rather than pruned.
- A worktree that cannot be removed does not abort the operation; the command continues with the remaining worktrees.
- Removed and skipped outcomes (with reasons) are written to the `drm-copilot` output channel. A summary notification is shown when the command completes: an information message when everything was removed or no secondary worktrees were found, and a warning message when one or more worktrees were skipped.

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
- `workspace_root` is required by all workspace-targeted tools; the MCP server cannot infer the calling agent's checkout, so callers must pass the absolute worktree/checkout root explicitly. An omitted value returns a structured `ok: false` error rather than silently defaulting.
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

- `collect_commit_context`: required `workspace_root`
- `collect_pr_context`: required `workspace_root`, required `base`
- `run_codex_native_converter`: required `workspace_root`, required `mode`, required `source_ecosystem`, required `source_root`, optional `selected_paths`, optional `destination_root`, optional `artifact_root`, optional `enable_repo_prompts`
- `push_down_copilot_customizations`: required `workspace_root`
- `push_down_codex_and_agents_customizations`: required `workspace_root`, optional `packs`, optional `csharp_variant`, optional `memory_mode`
- `new_potential_bug_entry`: required `workspace_root`, required `short_name`
- `new_potential_entry`: required `workspace_root`, required `short_name`
- `link_parent_child`: required `workspace_root`, required `child_issue_number`, required `parent_issue_number`
- `potential_to_issue`: required `workspace_root`, required `potential_path`, `promotion_type`, `work_mode`
- `new_active_feature_folder`: required `workspace_root`, required `feature_name`, `type`, `work_mode`, optional `issue_number`
- `resolve_policy_audit_template_asset`: required `workspace_root`, required `asset` (`template` | `code-review-template` | `feature-audit-template` | `agents`), optional `target_path`
- `resolve_atomic_plan_prompt`: required `workspace_root`, required `target`
- `resolve_execute_hard_lock_prompt`: required `workspace_root`, required `target`
- run_poshqc_format: required `workspace_root`, optional `scan_folders`
- run_poshqc_analyze: required `workspace_root`, optional `scan_folders`
- run_poshqc_test: required `workspace_root`, optional `scan_folders`
- run_poshqc_analyze_autofix: required `workspace_root`, optional `scan_folders`
- run_poshqc_suite: required `workspace_root`, optional `scan_folders`
- validate_orchestration_artifacts: required `workspace_root`, required `artifact_type`, required `artifact_path`, optional `require_complete`

### MCP Result Shape

MCP tool calls return structured JSON with:

- `ok`
- `tool`
- `workspace_root`
- `artifacts` when the workflow has deterministic or discovered output paths
- `summary`
- `stderr_excerpt` when a subprocess failure surfaces stderr diagnostics

## Runtime Requirements

- All commands run in-process in TypeScript; no `python` interpreter is required for any extension or MCP command.
- PowerShell commands prefer `pwsh` and fall back to `powershell` on Windows when available.
- An open workspace folder is required for workspace-targeted VS Code commands.
- MCP clients must build the package so `out/mcp-server.js` exists before launching the server.

`Resolve Execute Hard-Lock Prompt` and `Resolve Atomic Plan Prompt` run entirely in-process in TypeScript; they no longer require a Python runtime.

## Execution Model

The shared repo-automation service runs the formerly-Python commands in-process in TypeScript (no interpreter is spawned). The remaining bundled wrapper resources it executes are PowerShell scripts and data assets:

- `resources/templates/new-potential-entry.ps1`
- `resources/templates/link-parent-child.ps1`
- `resources/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md`
- `resources/templates/policy_audit/code-review.yyyy-MM-ddTHH-mm.md`
- `resources/templates/policy_audit/feature-audit.yyyy-MM-ddTHH-mm.md`
- `resources/templates/policy_audit/AGENTS.md`
- `resources/templates/run-poshqc-format.ps1`
- `resources/templates/run-poshqc-analyze.ps1`
- `resources/templates/run-poshqc-test.ps1`
- `resources/templates/run-poshqc-analyze-autofix.ps1`
- `resources/templates/run-poshqc-suite.ps1`
- `resources/powershell/PoshQC/`

In-process commands (commit context, PR context, Codex-native converter, push-down publishers, new potential bug entry, potential-to-issue, new active feature folder, resolve hard-lock prompt, resolve atomic-plan prompt, and the `helloPython` smoke test) execute directly in TypeScript against the workspace and the bundled data payloads under `resources/`; they spawn no Python.

The VS Code command adapters and the MCP server both call that same service layer. This preserves backward compatibility for the command IDs while providing a semantic MCP tool surface for downstream automation.

`resolve_policy_audit_template_asset` and `drmCopilotExtension.resolvePolicyAuditTemplateAsset` are additive surface adapters over the same bundled policy-audit assets. They support the selectors `template`, `code-review-template`, `feature-audit-template`, and `agents`. In MCP mode, callers receive the canonical asset id plus the bundled source path and, when requested, the copied destination path. In VS Code, interactive use opens the bundled asset when no target is supplied and copies it into the workspace when `-target <path>` is supplied.

## Codex-native converter wrapper

Use the `drm-copilot: Run Codex-native Converter` command (command ID: `drmCopilotExtension.runCodexNativeConverter`) from the Command Palette to run the in-process TypeScript converter against the active workspace. The command prompts for review or apply mode and the source ecosystem, then runs the converter in-process.

The same workflow is available through the semantic MCP tool `run_codex_native_converter`. MCP callers provide the non-interactive input contract directly:

- required `mode`: `review` or `apply`
- required `source_ecosystem`: `github-copilot` or `claude`
- required `source_root`: workspace-relative or absolute source runtime root
- optional `selected_paths`: repeated workspace-relative or absolute source paths to limit the run scope
- optional `destination_root`: required when `mode` is `apply`
- optional `artifact_root`: override for the report-set root
- optional `enable_repo_prompts`: allow `.codex/prompts/**` output when the destination repository explicitly uses that surface

The command adapter remains thin by design: it does not implement a second converter. It passes the resolved input to the in-process TypeScript converter, surfaces the artifact root, and relies on the converter's fail-closed validation model before any destination writes occur.

## Push Down Codex and Agents Customizations

Use the `drm-copilot: Push Down Codex and Agents Customizations` command (command ID: `drmCopilotExtension.pushDownCodexAndAgentsCustomizations`) from the Command Palette to copy the bundled `.codex` and `.agents` payload into the active workspace. The in-process TypeScript publisher uses the extension-packaged payload root at `resources/codex-and-agents-customizations/` and writes a JSON summary artifact under `artifacts/codex-and-agents-customizations/` in the destination workspace.

The command and MCP tool accept optional Codex language-pack selection. Omitted or empty `packs` publishes the complete `.codex` and `.agents` trees. When `packs` is supplied, `core` is included automatically. Supported public pack names are `core`, `python`, `powershell`, `typescript`, and `csharp`. Use `csharp_variant` to select the modern or legacy C# content.

The optional `csharp_variant` field accepts `modern` or `legacy`. The `modern` value uses the root Codex C# profile. The `legacy` value reads C# content from the bundle-only `.agents-variants/csharp-legacy/` and `.codex-variants/csharp-legacy/` roots and writes it to the canonical `.agents` and `.codex` destination paths. The variant roots are not destination roots.

The optional `memory_mode` field accepts `overwrite`, `merge`, or `skip` for schema parity with Claude push-down. It is inert for the current Codex bundle because no Codex memory subtree is present.

## Run PoshQC Suite

Use the `drm-copilot: Run PoshQC Suite` command (command ID: `drmCopilotExtension.runPoshQCSuite`) from the Command Palette to run the bundled PowerShell quality gate from extension resources against the destination workspace. The bundled PowerShell wrapper executes `resources/templates/run-poshqc-suite.ps1`, imports the colocated `resources/powershell/PoshQC/` module copy, and can limit scanning to one or more selected destination-workspace folders.

Additional granular bundled PoshQC surfaces are also available through both VS Code commands and semantic MCP tools:

- `drmCopilotExtension.runPoshQCFormat` / `run_poshqc_format`
- `drmCopilotExtension.runPoshQCAnalyze` / `run_poshqc_analyze`
- `drmCopilotExtension.runPoshQCTest` / `run_poshqc_test`
- `drmCopilotExtension.runPoshQCAnalyzeAutofix` / `run_poshqc_analyze_autofix`

Each command/tool uses the same `workspace_root` plus optional `scan_folders` contract as the bundled suite. The autofix operation is intentionally mutating: it applies `PSScriptAnalyzer -Fix` to the selected PowerShell files, then reruns bundled analysis and fails if findings remain.
