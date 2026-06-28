# drm-copilot

`drm-copilot` is a mixed Python + VS Code extension workspace for packaging, publishing, and validating agentic development customizations. It provides a runtime that maps a single orchestration model onto three coding-agent ecosystems — GitHub Copilot, Claude Code, and Codex — and ships the tooling needed to author, distribute, and enforce that model.

The repository contains four primary deliverables:

- a **multi-ecosystem agentic runtime** under `.github/`, `.claude/`, `.codex/`, and `.agents/` that defines standing instructions, skills, subagents, rules, and enforcement hooks;
- a **VS Code extension and stdio MCP bridge** in [extensions/drm-copilot/](extensions/drm-copilot/) that runs bundled scripts against the active workspace and exposes them as MCP tools;
- a **standalone npm MCP package** in [packages/mcp-server/](packages/mcp-server/) that publishes the same stdio MCP server for `npx` or global npm usage outside the VS Code extension host.
- a **Python/Poetry toolchain** at the repo root for documentation, context collection, customization conversion/publishing, shell quality checks, and developer workflows, plus a per-language quality toolchain for Python, TypeScript, PowerShell, modern C# (.NET 8+, No-COM), legacy VSTO C# (.NET Framework), and Bash;

## Repository layout

- [scripts/dev_tools/](scripts/dev_tools/) — Python developer tools and CLI entrypoints.
- [scripts/powershell/](scripts/powershell/) — PowerShell tooling, including the PoshQC quality module.
- [scripts/bash/](scripts/bash/) — shell tooling validated by `shell-qc`.
- [extensions/drm-copilot/](extensions/drm-copilot/) — the VS Code extension that bundles and executes workspace-facing helpers and hosts the MCP server.
- [packages/mcp-server/](packages/mcp-server/) — the standalone npm package for the `drm-copilot` stdio MCP server.
- [.github/](.github/) — GitHub Copilot customization surface: `copilot-instructions.md`, `instructions/`, `prompts/`, `skills/`, `agents/`, `codex/`, and CI workflows.
- [.claude/](.claude/) — the Claude Code runtime surface: `rules/`, `skills/`, `agents/`, `hooks/`, `agent-memory/`, and `settings.json`.
- [.codex/](.codex/) and [.agents/](.agents/) — the Codex-native runtime surface: prompts and skills.
- [docs/features/](docs/features/) — feature, backlog, and planning documents.
- [CLAUDE.md](CLAUDE.md) and [AGENTS.md](AGENTS.md) — generated standing-instruction roots for Claude Code and Codex respectively.

## Agentic runtime architecture

The repository maintains parallel customization surfaces for three coding-agent ecosystems, derived from one canonical policy set. The Claude Code surface ([.claude/](.claude/), documented in [CLAUDE.md](CLAUDE.md)) is the primary runtime and follows a four-layer architecture.

1. **Standing instructions** — [CLAUDE.md](CLAUDE.md) and [.claude/rules/](.claude/rules/) provide persistent policy context. `CLAUDE.md` carries repository-wide tone, the policy-compliance reading order, and architectural context. Rule files carry language-specific toolchain and coding standards, scoped by file path through YAML frontmatter (for example `python.md`, `typescript.md`, `powershell.md`, `csharp.md`, `quality-tiers.md`, `architecture-boundaries.md`, `orchestrator-state.md`, `ci-workflows.md`, `benchmark-baselines.md`).
2. **Skills** — [.claude/skills/](.claude/skills/) define reusable, user-invocable workflows. Each `SKILL.md` declares its own `allowed-tools`, `context`, and `agent` routing. The catalog includes `orchestrate`, `feature-promotion-lifecycle`, `atomic-plan-contract`, `execute-hard-lock`, `feature-review-workflow`, `pr-author`, `pr-context-artifacts`, `commit-message`, `research-issue`, `acceptance-criteria-tracking`, `policy-compliance-order`, the per-language change-budget routers and QA gates (`python-`, `powershell-`, `csharp-`), the orchestration state machines, `remediation-handoff-atomic-planner`, `human-exception-runbook`, and the cross-ecosystem translators (`translate-copilot-to-claude`, `translate-claude-to-codex`).
3. **Subagents** — [.claude/agents/](.claude/agents/) define named specialist personas, each declaring its tool allowlist, model, preloaded skills, hooks, and memory scope. The current roster is `orchestrator`, `atomic-planner`, `atomic-executor`, `feature-review`, `epic-review`, `staged-review`, `task-researcher`, `prd-feature`, `status-updater`, `pr-author`, and the language engineers `python-typed-engineer`, `typescript-engineer`, `powershell-typed-engineer`, and `csharp-typed-engineer`.
4. **Enforcement** — [.claude/settings.json](.claude/settings.json) defines tool/path permissions, and [.claude/hooks/](.claude/hooks/) contains `PreToolUse` and `SubagentStop` scripts that block dangerous commands and validate completion gates (for example `enforce-pr-author-skill.ps1`, `enforce-promotion-mcp-only.ps1`, `enforce-orchestration-preimplementation-gate.ps1`, `enforce-checkpoint-monotonic.ps1`, the per-language batch-budget and test-purity checks, and the `validate-*-output.ps1` gates for each subagent).

### Orchestration model

The runtime is orchestrator-driven. The `orchestrator` agent runs in the main thread and delegates all deep implementation to specialist subagents; it does not implement directly when a delegated specialist exists.

- **Startup** — on each invocation the orchestrator reads `CLAUDE.md`, the applicable `.claude/rules/` files, and the checkpoint at `artifacts/orchestration/orchestrator-state.json`, resuming from the recorded `next_step` when a matching objective exists.
- **Change-budget routing** — the orchestrator first estimates the change budget. A **small path** (1–3 production files plus tests) runs promotion → active folder → minimal plan → implementation → QC → small-audit review. A **large path** (4+ production files or cross-cutting changes) runs scope → promotion → research → spec → atomic planning → atomic execution → feature review.
- **Delegation** — planning goes to `atomic-planner`, task-by-task execution to `atomic-executor`, audits to `feature-review`/`epic-review`/`staged-review`, investigation to `task-researcher`, and PR creation exclusively to `pr-author` (the only authorized caller of `gh pr create`/`gh pr edit --body`, gated by the `enforce-pr-author-skill.ps1` hook, which verifies a SHA-256 receipt that binds the `--body-file` body bytes to a sibling `artifacts/pr_body_<N>.receipt.json`).
- **Checkpointing** — the orchestrator persists `artifacts/orchestration/orchestrator-state.json` after every completed step, including the selected path, workflow variables, per-step statuses, delegation receipts, and any blocked reason. The structural invariants are enforced by `validate_orchestration_artifacts` and `scripts/dev_tools/validate_orchestrator_state.py`.
- **Memory** — agents maintain persistent, file-based, project-scoped memory under [.claude/agent-memory/](.claude/agent-memory/), indexed per agent in a `MEMORY.md`.

### Other ecosystem surfaces

The `.github/` directory mirrors this model for GitHub Copilot (`copilot-instructions.md`, `instructions/*.instructions.md`, `skills/`, `prompts/`). The `.codex/` and `.agents/` directories provide the Codex-native equivalent (prompts plus `.agents/skills/`). The canonical policy source is the `.github/instructions/*` set; the other surfaces mirror or are generated from it (see the Codex-native converter and the push-down tools). The published MCP server is the runtime bridge that exposes the repository automation tools to all three ecosystems.

## Root Python tooling

The Poetry project (`drm-copilot`, see [pyproject.toml](pyproject.toml)) provides CLI entrypoints and supporting modules for tasks such as:

- collecting commit context and PR context;
- converting customization trees between ecosystems (Codex-native converter);
- publishing customization trees into another workspace;
- JSON formatting/validation and Markdown label formatting;
- shell quality checks;
- feature-folder, potential-entry, and issue-support workflows;
- resolving execute-plan and file prompts.

Selected CLI entrypoints exposed by Poetry:

- `atomic-executor` (also `dev.atomic-executor`)
- `codex-native-converter`
- `shell-qc`, `shell-qc-check`, `shell-qc-format`, `shell-qc-test`
- `dev.collect-commit-context`
- `dev.pr-context`
- `dev.new-active-feature`
- `dev.new-potential-bug`
- `dev.potential-to-issue`
- `dev.format-json`, `dev.validate-json`, `dev.format-markdown`
- `dev.fix-all`
- `dev.resolve-execute-plan`, `dev.resolve-file-prompt`
- `dev.clean-devcontainer`

## Codex-native converter

The Codex-native converter is a Python-first workflow that reviews or applies a deterministic migration from GitHub Copilot or Claude runtime customization surfaces into the native Codex layout. The Python CLI is the authoritative converter surface; the VS Code command and MCP tool are thin wrappers over the same bundled Python runner.

### Review and apply commands

- Review mode: `poetry run codex-native-converter review --source-root <source-root> --source-ecosystem <github-copilot|claude>`
- Apply mode: `poetry run codex-native-converter apply --source-root <source-root> --source-ecosystem <github-copilot|claude> --destination-root <destination-root>`

Optional flags:

- `--selected-path <path>` (repeatable) restricts the reviewed source surface.
- `--artifact-root <artifact-root>` overrides the default report location.
- `--enable-repo-prompts` allows `.codex/prompts/**` output when repository prompts are intentionally enabled.

Repo-wide GitHub instruction files that declare `applyTo: "**"` are merged into the generated `AGENTS.md`. Narrower `.github/instructions/*.instructions.md` files map to `.agents/skills/**`. GitHub prompt assets under `.github/prompts/*.md` are treated as optional launcher inputs and do not block validation by themselves when prompt output is disabled.

### Artifact outputs

Each run writes a deterministic report set beneath the selected artifact root:

- `conversion-report.md` (includes three Mermaid topology views of the source-to-destination mapping)
- `mapping-catalog.json`
- `validation-results.json`
- `proposed-tree/`

The CLI prints the resolved artifact root and the final validation outcome to stdout so wrapper layers can surface or collect the generated evidence.

### Fail-closed validation model

The converter blocks destination writes when it finds unresolved hard-gate mappings, unresolved handoff mappings, unresolved MCP rewrites, duplicate targets, lingering `.github`, `.claude`, or `CLAUDE.md` runtime references in generated native output, malformed artifacts, unsupported ecosystems, or missing required inputs. Review mode still writes the report set so the caller can inspect blocking findings without mutating the destination tree. The converter is implemented in [scripts/dev_tools/codex_native_converter/](scripts/dev_tools/codex_native_converter/), with modules split to satisfy the 500-line file-size policy.

## VS Code extension

The active extension package lives in [extensions/drm-copilot/](extensions/drm-copilot/). It contributes a VS Code command surface and a Codex-facing stdio MCP server named `drm-copilot` (contributed through an `mcpServerDefinitionProviders` entry). The extension is the authoritative development surface; [packages/mcp-server/](packages/mcp-server/) provides an external distribution channel for the same MCP server source.

### Contributed commands

Context collection:

- `drmCopilotExtension.collectCommitContext`
- `drmCopilotExtension.collectPrContext`

Feature and issue workflows:

- `drmCopilotExtension.newActiveFeatureFolder`
- `drmCopilotExtension.newPotentialEntry`
- `drmCopilotExtension.newPotentialBugEntry`
- `drmCopilotExtension.potentialToIssue`
- `drmCopilotExtension.linkParentChild`

Customization conversion and publishing:

- `drmCopilotExtension.runCodexNativeConverter`
- `drmCopilotExtension.pushDownCopilotCustomizations`
- `drmCopilotExtension.pushDownCodexAndAgentsCustomizations`
- `drmCopilotExtension.pushDownClaudeCustomizations`
- `drmCopilotExtension.syncAgentsFromInstructions`

PowerShell quality control (PoshQC):

- `drmCopilotExtension.runPoshQCSuite`
- `drmCopilotExtension.runPoshQCFormat`
- `drmCopilotExtension.runPoshQCAnalyze`
- `drmCopilotExtension.runPoshQCTest`
- `drmCopilotExtension.runPoshQCAnalyzeAutofix`

Orchestration assets and templates:

- `drmCopilotExtension.resolvePolicyAuditTemplateAsset`
- `drmCopilotExtension.resolveExecuteHardLockPrompt`
- `drmCopilotExtension.resolveAtomicPlanPrompt`

Worktree sessions:

- `drmCopilotExtension.newClaudeWorktreeSession`
- `drmCopilotExtension.newCodexWorktreeSession`
- `drmCopilotExtension.removeSecondaryWorktrees`

Diagnostics:

- `drmCopilotExtension.helloPython`
- `drmCopilotExtension.helloPowerShell`
- `drmCopilotExtension.listMcpTools`

### Worktree session commands

- `newClaudeWorktreeSession` creates or reuses a git worktree, optionally activates the workspace Poetry environment, runs an optional pre-session PowerShell script, and starts `claude` in an integrated terminal. The pre-session script path defaults to `.claude/hooks/pre-claude-session.ps1` and is configurable via `drmCopilotExtension.newClaudeWorktreeSession.preClaudeScriptPath`. A missing script at that path is not an error.
- `newCodexWorktreeSession` performs the equivalent flow for Codex: it adds the worktree to the Codex trusted-projects list, runs an optional post-session script (default `.codex/scripts/post-codex-worktree-session.ps1`, configurable via `drmCopilotExtension.newCodexWorktreeSession.postCodexScriptPath`), and starts `codex`.
- `removeSecondaryWorktrees` removes secondary git worktrees created by these commands.

### MCP tool surface

The `drm-copilot` MCP server exposes the following repo-automation tools (tool prefix `mcp__drm-copilot__` when consumed by Claude Code):

- `collect_commit_context`
- `collect_pr_context`
- `run_codex_native_converter`
- `push_down_copilot_customizations`
- `push_down_codex_and_agents_customizations`
- `push_down_claude_customizations`
- `new_potential_entry`
- `new_potential_bug_entry`
- `potential_to_issue`
- `new_active_feature_folder`
- `link_parent_child`
- `run_poshqc_format`
- `run_poshqc_analyze`
- `run_poshqc_test`
- `run_poshqc_analyze_autofix`
- `run_poshqc_suite`
- `resolve_policy_audit_template_asset`
- `resolve_execute_hard_lock_prompt`
- `resolve_atomic_plan_prompt`
- `validate_orchestration_artifacts`

Every tool accepts an optional `workspace_root` argument and defaults to `process.cwd()` when it is omitted. Downstream skills should depend on the MCP server name `drm-copilot` rather than on raw VS Code command IDs. The same tool surface is available through the published npm package `@danmoisan/drm-copilot-mcp`.

## Standalone npm MCP package

[packages/mcp-server/](packages/mcp-server/) publishes the same stdio MCP server implemented in `extensions/drm-copilot/src/mcp-server.ts`, so consumers can run the server without cloning this repository or building from source.

### Consumer usage

- `npx -y @danmoisan/drm-copilot-mcp`
- `npm install -g @danmoisan/drm-copilot-mcp`
- `drm-copilot-mcp`

### MCP client configuration

Add the following to an MCP client configuration file such as `claude_desktop_config.json`:

```json
{
  "mcpServers": {
    "drm-copilot": {
      "command": "npx",
      "args": ["-y", "@danmoisan/drm-copilot-mcp"],
      "cwd": "/absolute/path/to/your/workspace"
    }
  }
}
```

Set `cwd` to the absolute path of the destination workspace root. The MCP server uses `process.cwd()` as the default workspace root when the tool caller does not provide one.

### Package behavior and contents

- The published package name is `@danmoisan/drm-copilot-mcp`.
- The package bundles `extensions/drm-copilot/src/mcp-server.ts` into `packages/mcp-server/out/mcp-server.js` as a CommonJS executable with a `#!/usr/bin/env node` shebang.
- The `prepack` flow copies `extensions/drm-copilot/resources/` into `packages/mcp-server/resources/` so the published tarball contains the script-backed tools and templates required at runtime.
- The npm tarball intentionally includes only `out/mcp-server.js` and `resources/`.
- The MCP tool API surface matches the VS Code extension.

### Local package build and validation

Run the standalone package workflow from the repository root:

- `npm --prefix packages/mcp-server ci`
- `npm --prefix packages/mcp-server run prepack`
- `npm --prefix packages/mcp-server run build`
- `Push-Location packages/mcp-server; npm pack; Pop-Location`
- `Push-Location packages/mcp-server; npm publish --dry-run --access public; Pop-Location`

## Push-down customizations

The repository can publish each scoped customization tree into another workspace from the Python CLI, a VS Code command, or an MCP tool.

| Surface | Python entrypoint | VS Code command | MCP tool |
|---|---|---|---|
| Copilot (`.github`) | `poetry run python -m scripts.dev_tools.push_down_copilot_customizations --destination <root>` | `pushDownCopilotCustomizations` | `push_down_copilot_customizations` |
| Codex + agents (`.codex`, `.agents`) | `poetry run python -m scripts.dev_tools.push_down_codex_and_agents_customizations --destination <root>` | `pushDownCodexAndAgentsCustomizations` | `push_down_codex_and_agents_customizations` |
| Claude Code (`.claude`, `CLAUDE.md`) | bundled publisher | `pushDownClaudeCustomizations` | `push_down_claude_customizations` |

During Copilot publication, supported script references are rewritten to stable live VS Code command references contributed by the extension. The Claude push-down tool accepts optional `packs` (language pack selection; `core` is always included), a `csharp_variant` (`modern` default or `legacy`), and a `memory_mode` (`overwrite` default, `merge`, or `skip`).

### Sync AGENTS.md from instructions

`drmCopilotExtension.syncAgentsFromInstructions` regenerates `AGENTS.md` in the destination workspace by discovering all `.github/instructions/*.instructions.md` files under the active workspace root, aggregating their content deterministically, and writing the consolidated result. This replaces any manual edits to `AGENTS.md` with a fully generated output derived from the canonical instruction files.

## Requirements

### Root toolchain

- Python 3.10+
- Poetry

### Extension development

- VS Code (engine `^1.108.0`)
- Node.js 20+ recommended
- npm

### Standalone MCP package

- Node.js 18+
- npm or `npx`

### Runtime expectations for extension and MCP commands

- Python commands expect `python` on `PATH`.
- PowerShell commands prefer `pwsh` and fall back to `powershell` on Windows when available.
- An open workspace folder is required for workspace-targeted extension commands.
- The MCP bridge must be built before launch: `npm --prefix extensions/drm-copilot run build`.
- The standalone npm package requires `cwd` in the MCP client configuration to point at the target workspace root.
- Script-backed MCP tools require Python 3 and PowerShell 7+ on the consumer machine even when the server is started through npm.
- The checked-in workspace settings pin the VS Code PowerShell extension to `C:\Program Files\PowerShell\7\pwsh.exe` on Windows so the Pester Test Explorer runs under PowerShell 7 instead of Windows PowerShell 5.1. If your local `pwsh.exe` lives elsewhere, override `powershell.powerShellAdditionalExePaths` and `powershell.powerShellDefaultVersion` in local VS Code settings.

### Per-language toolchains (only when working in that language)

- Python: Poetry-managed Black, Ruff, Pyright, and Pytest (installed via `poetry install`).
- TypeScript: Node.js with Prettier, ESLint, `tsc`, and the configured test runner (installed via `npm ci`).
- PowerShell: PowerShell 7+ and the bundled PoshQC module (PSScriptAnalyzer, Pester 5.x); install tooling with `Install-PoshQCTools`.
- Modern C#: the .NET 8+ SDK with the CSharpier dotnet tool and the analyzer/test packages restored by the solution.
- Legacy VSTO C#: the .NET Framework build toolchain (`msbuild`, `vstest.console.exe`) plus CSharpier.
- Bash: `shfmt`, `shellcheck`, `bats`, and (for coverage) `kcov`.

## Language toolchain ecosystems

The repository defines a separate, fully specified quality toolchain for each supported language. Every toolchain is run in a fixed stage order and the loop restarts from stage 1 whenever a stage fails or rewrites files. The canonical definitions live in [.claude/rules/](.claude/rules/) and `.github/instructions/`. Coverage thresholds are uniform across all module tiers (T1–T4): line coverage >= 85% and branch coverage >= 75%, with no regression on changed lines.

| Ecosystem | Format | Lint / analyze | Type / nullable | Test | Coverage |
|---|---|---|---|---|---|
| Python | Black | Ruff | Pyright (strict) | Pytest | pytest-cov |
| TypeScript | Prettier | ESLint (typescript-eslint) | `tsc` | Vitest (Jest in the bundled extension) | c8 / coverage provider |
| PowerShell | PoshQC `Invoke-Formatter` | PSScriptAnalyzer (PoshQC) | n/a | Pester v5 | Pester + kcov export |
| Modern C# (.NET 8+, No-COM) | CSharpier | .NET / Roslyn analyzers | Nullable reference types | xUnit + NSubstitute + FluentAssertions | XPlat Code Coverage |
| Legacy VSTO C# (.NET Framework) | CSharpier | .NET analyzers via `msbuild` | Nullable via `msbuild` | MSTest via `vstest.console.exe` | `/EnableCodeCoverage` |
| Bash / shell | shfmt | shellcheck | n/a | Bats | kcov |

### Python (Black → Ruff → Pyright → Pytest)

Canonical rule: [.claude/rules/python.md](.claude/rules/python.md).

- format: `poetry run black .`
- lint: `poetry run ruff check .`
- type-check (strict): `poetry run pyright`
- test: `poetry run pytest --cov --cov-branch --cov-report=term-missing`

### TypeScript (Prettier → ESLint → tsc → Vitest)

Canonical rule: [.claude/rules/typescript.md](.claude/rules/typescript.md). Architecture boundaries are enforced with `dependency-cruiser` (`.dependency-cruiser.cjs`); T1/T2 modules add `fast-check` property tests and T1 modules add `StrykerJS` mutation testing in pre-merge or nightly pipelines.

The bundled VS Code extension uses the same format/lint/type-check stages with a Jest-based unit runner. Run extension checks from the extension folder or with `npm --prefix extensions/drm-copilot ...`:

- build: `npm --prefix extensions/drm-copilot run build`
- format: `npm --prefix extensions/drm-copilot run format`
- lint: `npm --prefix extensions/drm-copilot run lint`
- type-check: `npm --prefix extensions/drm-copilot run typecheck`
- unit tests: `npm --prefix extensions/drm-copilot run test`

### PowerShell (PoshQC format → analyze → Pester)

Canonical rule: [.claude/rules/powershell.md](.claude/rules/powershell.md). All scripts target PowerShell 7+. The toolchain runs through the bundled PoshQC module ([scripts/powershell/PoshQC/](scripts/powershell/PoshQC/)), invoked either via the MCP tools or directly:

- format: `mcp__drm-copilot__run_poshqc_format` (or `Invoke-PoshQCFormat`)
- analyze: `mcp__drm-copilot__run_poshqc_analyze` (autofix: `mcp__drm-copilot__run_poshqc_analyze_autofix`)
- test (Pester v5): `mcp__drm-copilot__run_poshqc_test` (or `Invoke-PoshQCTest`)
- full suite: `mcp__drm-copilot__run_poshqc_suite`

There is no type-check stage for PowerShell. Pester runs use the repo config at `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`.

### Modern C# (.NET 8+, No-COM)

Canonical rule: [.claude/rules/csharp.md](.claude/rules/csharp.md). This ecosystem targets the No-COM .NET foundation and is distributed as the `csharp-modern` Claude pack.

- format: `dotnet tool restore` then `dotnet csharpier check .` (auto-format with `dotnet csharpier .`)
- lint + nullable: `dotnet build` (analyzers and `Nullable=enable` enforced as errors via `Directory.Build.props`)
- architecture: `NetArchTest.Rules` in `*.ArchitectureTests` projects
- test: `dotnet test --collect:"XPlat Code Coverage"` (xUnit + NSubstitute + FluentAssertions)

Determinism is enforced through an injected `TimeProvider` (`FakeTimeProvider` in tests); `DateTime.Now`, `DateTime.UtcNow`, `Random.Shared`, `Thread.Sleep`, and `Task.Delay` are banned via `BannedApiAnalyzers`. T1/T2 modules add `CsCheck` property tests, T1 modules add `Stryker.NET` mutation testing, and T1 classifier modules add `Verify.Xunit` golden tests.

### Legacy VSTO C# (.NET Framework)

Distributed as the `csharp-legacy` Claude pack ([.claude-variants/csharp-legacy](extensions/drm-copilot/resources/claude-customizations/.claude-variants/csharp-legacy/)), selectable through the `push_down_claude_customizations` tool with `csharp_variant: "legacy"`. It applies the same stage order on the .NET Framework / VSTO toolchain:

- format: `dotnet tool run csharpier .`
- analyze: `msbuild <solution>.sln /t:Build /p:Configuration=Debug /p:EnableNETAnalyzers=true /p:EnforceCodeStyleInBuild=true`
- nullable: `msbuild <solution>.sln /t:Build /p:Nullable=enable /p:TreatWarningsAsErrors=true`
- test: `vstest.console.exe <test-assembly-paths> /EnableCodeCoverage` (MSTest)

The legacy variant uses the `IClock` clock seam rather than `TimeProvider`, reflecting pre-.NET 8 contexts that have not been migrated.

### Bash / shell (shfmt → shellcheck → Bats + kcov)

Validated through the `shell-qc` CLI ([scripts/dev_tools/shell_qc.py](scripts/dev_tools/shell_qc.py)) and the `shell-qc-*` entrypoints:

- format: `poetry run shell-qc-format` (shfmt write mode)
- check (format + lint): `poetry run shell-qc-check` (shfmt diff mode + shellcheck)
- test: `poetry run shell-qc-test` or `poetry run shell-qc test --coverage` (Bats with kcov coverage)

CI builds `kcov` from source and uploads the Bash coverage artifacts.

## Development workflows

### PowerShell repo session

To activate the workspace virtual environment and replace the default PowerShell prompt with a repo-relative prompt, run:

- `& ./scripts/dev-tools/Enter-DrmCopilotShell.ps1`

When the current directory is inside this repository, the prompt renders as `(drm-copilot):\` plus the relative path from the repo root.

### Fix-all helper

- `poetry run dev.fix-all` runs the available auto-fixing stages across the repository.

## CI and release workflows

The repository uses the following GitHub Actions workflows under [.github/workflows/](.github/workflows/):

- `ci.yml` — Python quality and tests across Python 3.10–3.13, security scanning, documentation validation (README and LICENSE presence), package build/install verification, PowerShell formatting/analysis/tests (PoshQC on Windows), shell coverage (Bats + kcov), and `extensions/drm-copilot` tests on Ubuntu and Windows.
- `publish-mcp-npm.yml` — tag-driven npm publication of `@danmoisan/drm-copilot-mcp`, gated on the extension test matrix.
- `publish-extension.yml` — tag-driven publication of the VS Code extension to the Marketplace, gated on the extension test matrix; pull requests that touch the extension build and package without publishing.
- `validate-orchestrator-state.yml` — validation of the orchestrator-state checkpoint artifact.
- `npm-audit-gate.yml` — npm dependency audit gate.

### npm publish release procedure

- Trigger: push a git tag matching `mcp-server-v*` such as `mcp-server-v0.0.1`.
- Gate: the workflow runs the extension test matrix on Ubuntu and Windows before publish.
- Publish steps: install `packages/mcp-server` dependencies, run `prepack`, build `out/mcp-server.js`, then `npm publish --access public`.
- Credential: publication requires the repository secret `NPM_TOKEN`.
- Release prerequisite: keep `packages/mcp-server/package.json` and `extensions/drm-copilot/package.json` version values aligned before tagging.

### VS Code extension release procedure

- Trigger: push a git tag matching `v*`.
- Gate: the extension test matrix runs before publish.
- Publish: the workflow builds and packages the extension with `@vscode/vsce` and publishes with `@vscode/vsce publish`, using the repository secret `VSCE_PAT`.

## Policy and skills references

- Repository tone and policy: [CLAUDE.md](CLAUDE.md), `.github/copilot-instructions.md`, and `.github/instructions/`.
- Language-specific rules: [.claude/rules/](.claude/rules/) (Python, PowerShell, TypeScript, C#), scoped by file path.
- Skills taxonomy: [.github/skills/README.md](.github/skills/README.md), [.claude/skills/](.claude/skills/), and [.agents/skills/](.agents/skills/).
