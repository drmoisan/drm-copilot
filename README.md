# drm-copilot

`drm-copilot` is a mixed Python + VS Code extension workspace for packaging, publishing, and validating agentic development customizations.

Today the repository contains two main deliverables:

- a **Python/Poetry toolchain** at the repo root for documentation, context collection, customization publishing, shell quality checks, and developer workflows;
- a **VS Code extension** in `extensions/drm-copilot` that runs bundled scripts against the active workspace.

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

### VS Code extension

The active extension package lives in `extensions/drm-copilot` and currently contributes these implemented commands:

- `drmCopilotExtension.helloPython`
- `drmCopilotExtension.helloPowerShell`
- `drmCopilotExtension.collectCommitContext`
- `drmCopilotExtension.collectPrContext`
- `drmCopilotExtension.pushDownCopilotCustomizations`

It also registers intentional placeholder commands that fail with a deterministic `Not implemented:` message when invoked:

- `drmCopilotExtension.newActiveFeatureFolderPlaceholder`
- `drmCopilotExtension.potentialToIssuePlaceholder`
- `drmCopilotExtension.newPotentialBugEntryPyPlaceholder`
- `drmCopilotExtension.newPotentialEntryPsPlaceholder`

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

- format: `npm --prefix extensions/drm-copilot run format`
- lint: `npm --prefix extensions/drm-copilot run lint`
- type-check: `npm --prefix extensions/drm-copilot run typecheck`
- unit tests: `npm --prefix extensions/drm-copilot run test:unit`

## Push-down customizations

You can publish the scoped `.github` customization tree into another workspace from either side of the repo.

### Python entrypoint

Use the root Python publisher to copy customization files into a target workspace:

`poetry run python -m scripts.dev_tools.push_down_copilot_customizations --destination <workspace-root>`

### Extension command

Use `drmCopilotExtension.pushDownCopilotCustomizations` from the Command Palette to apply the bundled customization payload to the currently open workspace.

### Rewrite behavior

During publication, supported script references are rewritten to stable VS Code command references.

When a referenced workflow is known but not yet implemented in the extension, it is rewritten to a placeholder command ID that fails explicitly instead of silently drifting into chaos. Polite chaos, perhaps, but still chaos.

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
