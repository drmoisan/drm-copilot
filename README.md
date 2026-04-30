# drm-copilot

`drm-copilot` is a mixed Python + VS Code extension workspace for packaging, publishing, and validating agentic development customizations.

Today the repository contains two main deliverables:

- a **Python/Poetry toolchain** at the repo root for documentation, context collection, customization publishing, shell quality checks, and developer workflows;
- a **VS Code extension and stdio MCP bridge** in `extensions/drm-copilot` that runs bundled scripts against the active workspace.

## Current repository layout

- `scripts/dev_tools/` — Python developer tools and CLI entrypoints.
- `extensions/drm-copilot/` — the extension that bundles and executes workspace-facing helpers.
- `docs/features/` — feature, backlog, and planning documents.
- `.github/skills/` — repository skill definitions.
- `.github/workflows/ci.yml` — CI for Python, PowerShell, shell tooling, docs checks, and extension tests.

## What works today

### Root Python tooling

The Poetry project provides CLI entrypoints and supporting modules for tasks such as:

- collecting commit context;
- collecting PR context;
- pushing down Copilot customization trees into another workspace;
- JSON formatting/validation;
- shell quality checks;
- feature-folder and issue-support workflows.

Selected CLI entrypoints exposed by Poetry include:

- `atomic-executor`
- `shell-qc`
- `dev.collect-commit-context`
- `dev.pr-context`
- `dev.new-active-feature`
- `dev.potential-to-issue`

## Codex-native converter

The Codex-native converter is a Python-first workflow that reviews or applies a deterministic migration from GitHub Copilot or Claude runtime customization surfaces into the native Codex layout expected by this repository.

The Python CLI is the authoritative converter surface. The VS Code command and MCP tool added under `extensions/drm-copilot` are thin wrappers over the same bundled Python runner.

### Python review and apply commands

- Review mode: `poetry run codex-native-converter review --source-root <source-root> --source-ecosystem <github-copilot|claude>`
- Apply mode: `poetry run codex-native-converter apply --source-root <source-root> --source-ecosystem <github-copilot|claude> --destination-root <destination-root>`

Optional flags include:

- `--selected-path <path>` repeated to restrict the reviewed source surface
- `--artifact-root <artifact-root>` to override the default report location
- `--enable-repo-prompts` to allow `.codex/prompts/**` output when repository prompts are intentionally enabled

Repo-wide GitHub instruction files that declare `applyTo: "**"` are merged into the converter's generated `AGENTS.md`. Narrower `.github/instructions/*.instructions.md` files continue to map to `.agents/skills/**`.

GitHub prompt assets under `.github/prompts/*.md`, including template-style files such as `execute-plan-template.md`, are treated as optional launcher inputs. They do not block validation by themselves when prompt output is intentionally disabled, but generated content that still references prompt surfaces will continue to fail validation until those references are rewritten or prompt output is enabled.

### Artifact outputs

Each run writes a deterministic report set beneath the selected artifact root:

- `conversion-report.md`
- `mapping-catalog.json`
- `validation-results.json`
- `proposed-tree/`

The Markdown conversion report includes three Mermaid topology views: a shared-node source-to-destination graph, a source-to-destination graph with repeated destination nodes for readability, and a destination-to-source graph with repeated source nodes for readability.

The CLI prints the resolved artifact root and the final validation outcome to stdout so wrapper layers can surface or collect the generated evidence.

### Fail-closed validation model

The converter blocks destination writes when it finds unresolved hard-gate mappings, unresolved handoff mappings, unresolved MCP rewrites, duplicate targets, lingering `.github`, `.claude`, or `CLAUDE.md` runtime references in generated native output, malformed artifacts, unsupported ecosystems, or missing required inputs. Review mode still writes the report set so the caller can inspect the blocking findings without mutating the destination tree.

Informational source files such as `.github/skills/README.md` are still cataloged in the reports, but they are treated as optional documentation rather than required runtime artifacts.

### VS Code extension

The active extension package lives in `extensions/drm-copilot`. It now exposes both the existing VS Code command surface and a Codex-facing stdio MCP server named `drmCopilotExtension`.

The VS Code side continues to contribute these implemented commands:

- `drmCopilotExtension.helloPython`
- `drmCopilotExtension.helloPowerShell`
- `drmCopilotExtension.collectCommitContext`
- `drmCopilotExtension.collectPrContext`
- `drmCopilotExtension.runCodexNativeConverter`
- `drmCopilotExtension.pushDownCopilotCustomizations`
- `drmCopilotExtension.pushDownCodexAndAgentsCustomizations`
- `drmCopilotExtension.newPotentialBugEntry`
- `drmCopilotExtension.newPotentialEntry`
- `drmCopilotExtension.potentialToIssue`
- `drmCopilotExtension.newActiveFeatureFolder`
- `drmCopilotExtension.resolveExecuteHardLockPrompt`
- `drmCopilotExtension.syncAgentsFromInstructions`

The MCP side exposes semantic repo-automation tools such as:

- `collect_commit_context`
- `collect_pr_context`
- `run_codex_native_converter`
- `push_down_copilot_customizations`
- `push_down_codex_and_agents_customizations`
- `new_potential_bug_entry`
- `new_potential_entry`
- `potential_to_issue`
- `new_active_feature_folder`
- `resolve_execute_hard_lock_prompt`

Downstream Codex skills should depend on the MCP server name `drmCopilotExtension`, not on raw VS Code command IDs.

## Requirements

### For the root toolchain

- Python 3.10+
- Poetry

### For extension development

- VS Code
- Node.js 20+ recommended
- npm

### Runtime expectations for extension commands

- Python commands expect `python` on `PATH`.
- PowerShell commands prefer `pwsh` and fall back to `powershell` on Windows when available.
- An open workspace folder is required for workspace-targeted extension commands.
- The MCP bridge must be built before launch: `npm --prefix extensions/drm-copilot run build`.
- The checked-in workspace settings pin the VS Code PowerShell extension to `C:\Program Files\PowerShell\7\pwsh.exe` on Windows so the Pester Test Explorer runs under PowerShell 7 instead of Windows PowerShell 5.1. If your local `pwsh.exe` lives elsewhere, override `powershell.powerShellAdditionalExePaths` and `powershell.powerShellDefaultVersion` in local VS Code settings.

## Development workflows

### Root Python quality loop

The repository CI and local tasks are centered on:

- formatting with Black;
- linting with Ruff;
- type checking with Pyright;
- testing with Pytest;
- PowerShell validation with PoshQC;
- shell validation with `shell-qc` and Bats/kcov in CI.

Common local commands:

- `poetry run black .`
- `poetry run ruff check`
- `poetry run pyright`
- `poetry run pytest`

### Extension quality loop

Run extension-specific checks from the extension folder (or by using `npm --prefix extensions/drm-copilot ...`):

- build: `npm --prefix extensions/drm-copilot run build`
- format: `npm --prefix extensions/drm-copilot run format`
- lint: `npm --prefix extensions/drm-copilot run lint`
- type-check: `npm --prefix extensions/drm-copilot run typecheck`
- unit tests: `npm --prefix extensions/drm-copilot run test:unit`

## Sync AGENTS.md from instructions

The `drmCopilotExtension.syncAgentsFromInstructions` command regenerates `AGENTS.md` in the destination workspace by discovering all `.github/instructions/*.instructions.md` files under the active workspace root, aggregating their content deterministically, and writing the consolidated result to `AGENTS.md`. This replaces any manual edits to `AGENTS.md` with a fully generated output derived from the workspace's canonical `.github` instruction files.

### Extension command

Use `drmCopilotExtension.syncAgentsFromInstructions` from the Command Palette to trigger the bundled PowerShell generator against the currently open workspace root.

## Push-down customizations

You can publish the scoped `.github` customization tree into another workspace from either side of the repo.

### Python entrypoint

Use the root Python publisher to copy customization files into a target workspace:

`poetry run python -m scripts.dev_tools.push_down_copilot_customizations --destination <workspace-root>`

### Extension command

Use `drmCopilotExtension.pushDownCopilotCustomizations` from the Command Palette to apply the bundled customization payload to the currently open workspace.

### Rewrite behavior

During publication, supported script references are rewritten to stable live VS Code command references contributed by the extension.

## Push-down Codex and agents customizations

You can also publish the scoped `.codex` and `.agents` trees into another workspace from either side of the repo.

### Python entrypoint

Use the root Python publisher to copy Codex/agents files into a target workspace:

`poetry run python -m scripts.dev_tools.push_down_codex_and_agents_customizations --destination <workspace-root>`

### Extension command

Use `drmCopilotExtension.pushDownCodexAndAgentsCustomizations` from the Command Palette to apply the bundled `.codex` / `.agents` payload to the currently open workspace.

### MCP tool

Use `push_down_codex_and_agents_customizations` from the `drmCopilotExtension` MCP server to invoke the same bundled publisher non-interactively.

## CI coverage

The current CI workflow validates:

- Python quality and tests across Python 3.10 through 3.13;
- package build/install behavior;
- README and license presence;
- PowerShell formatting, analysis, and tests;
- shell coverage flows;
- `extensions/drm-copilot` tests on Ubuntu and Windows.

## Skills

- [Skills taxonomy](.github/skills/README.md)
