# 2026-01-28-scaffold-extension — Spec

- **Issue:** #16
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-02-11T20-01
- **Status:** Draft
- **Version:** 1.0

## Overview

Teams want to reuse proven Python and PowerShell utilities from this repo, but there is no single, consistent extension scaffold that packages a minimal runnable starter.
This leads to copy-paste adoption, inconsistent setup, and higher onboarding costs across projects.
The MVP scaffold provides a pair of “hello” scripts plus commands that run them and generate deterministic workspace artifacts, giving teams a reliable smoke test and a clear starting point for customization.


## Behavior

Provide a minimal VS Code Extension scaffold that exposes two commands and ensures the corresponding scripts exist in the destination repo:

- **Hello Python**
	- Ensures `hello_python.py` exists in the workspace (copy from bundled template if missing).
	- Verifies a Python runtime is available; if missing, shows a clear error.
	- Executes `hello_python.py` from the workspace root.
	- Ensures `artifacts/hello_python.txt` is created in the workspace.
- **Hello PowerShell**
	- Ensures `hello_pwsh.ps1` exists in the workspace (copy from bundled template if missing).
	- Verifies a PowerShell runtime is available (`pwsh` preferred, fallback to `powershell`); if missing, shows a clear error.
	- Executes `hello_pwsh.ps1` from the workspace root.
	- Ensures `artifacts/hello_pwsh.txt` is created in the workspace.

General behavior:
- Commands run without manual path edits by resolving paths relative to the active workspace root.
- If no workspace is open, commands fail with an actionable error.
- Output is logged to a dedicated OutputChannel for traceability.
- README provides a minimal “first run” walkthrough using both commands.
- Scaffolded environments include:
	- Python tooling with Poetry, Black, Ruff, Pyright, and Pytest.
	- PowerShell tooling with the PoshQC package.
- Python scaffolding must be expressed in `pyproject.toml` and `poetry.toml` using the exact content specified in this spec.


## Inputs / Outputs

- Inputs
	- Workspace root folder (required).
	- Runtime availability: `python` on PATH; `pwsh` or `powershell` on PATH.
	- Bundled templates: `resources/templates/hello_python.py`, `resources/templates/hello_pwsh.ps1`.
	- Python environment scaffold assets/config for Poetry, Black, Ruff, Pyright, and Pytest (`pyproject.toml`, `poetry.toml`).
	- PowerShell environment scaffold assets/config for PoshQC.
- Outputs
	- Workspace files created (if missing): `hello_python.py`, `hello_pwsh.ps1`.
	- Artifacts written by scripts: `artifacts/hello_python.txt`, `artifacts/hello_pwsh.txt`.
	- Logs: OutputChannel entries for runtime detection, execution start/end, and error details.
	- Environment scaffold files for Python and PowerShell (see Implementation Strategy).
	  - `pyproject.toml`
	  - `poetry.toml`
- Config keys and defaults: None for the MVP.
- Versioning or backward-compatibility constraints: None; MVP is additive and does not change existing runtime behavior.

## API / CLI Surface

Commands (Command Palette):
- **Hello Python**
	- Command ID: `scaffoldExtension.helloPython`
	- Example: run “Hello Python” → `artifacts/hello_python.txt` created
- **Hello PowerShell**
	- Command ID: `scaffoldExtension.helloPowerShell`
	- Example: run “Hello PowerShell” → `artifacts/hello_pwsh.txt` created

Contracts and validation rules:
- If no workspace root is open, commands must fail with a user-facing error.
- If the required runtime is missing, commands must fail with an error that names the runtime (`python`, `pwsh`, `powershell`).
- Commands must execute the workspace scripts (not only bundled templates) and must not require manual path edits.
- Environment scaffolded files must be created in the workspace without requiring manual edits to run the hello commands.
- The generated `pyproject.toml` must match the exact content specified below.

## Data & State

Data flow and state:
- On command invocation, resolve workspace root → ensure template scripts are copied → execute script → write artifact file.
- Runtime detection is ephemeral per invocation (no caching).
- State transitions follow: `Idle` → `CheckingRuntime` → (`RuntimeMissing` | `RuntimeAvailable`) → `RunningTask` → (`Succeeded` | `Failed`) → `Idle`.

Data transformations and invariants:
- `artifacts/hello_python.txt` and `artifacts/hello_pwsh.txt` are always written under the active workspace root.
- Script execution must use absolute paths derived from the workspace root to avoid manual edits.
- Python and PowerShell environment scaffolds are additive and must not overwrite existing user configuration without explicit intent.

Caching or persistence details:
- None; no persistent extension state beyond created workspace files.

Migration or backfill requirements (if any):
- None.

## Constraints & Risks

- Must not assume global installs beyond typical runtimes; must detect and report missing Python/PowerShell runtimes.
- Extension packaging size should stay small; avoid bundling large binaries.
- Cross-platform shell invocation differences may require platform-specific handling (especially on Windows paths with spaces).
- Commands require a workspace root; running without a workspace is an explicit error path.
- Scope risk: avoid turning into a full toolbox; keep the scaffold minimal and extensible.
- Environment scaffolds should avoid pinning tool versions too tightly to reduce maintenance overhead.


## Implementation Strategy

- Implementation scope (what changes, not sequencing):
	- Add a minimal VS Code extension scaffold under `extensions/scaffold-extension/` with a manifest, entry point, and bundled templates.
	- Provide two commands that copy templates (if missing), detect runtimes, and execute the workspace scripts to produce artifacts.
	- Add Python environment scaffold assets/config for Poetry, Black, Ruff, Pyright, and Pytest via `pyproject.toml` and `poetry.toml`.
	- Add PowerShell environment scaffold assets/config for PoshQC.
- New classes/functions/commands to add or update:
	- `activate` and command registrations in `src/extension.ts`.
	- `detectRuntime(kind)` helper (checks `python`, `pwsh`, `powershell`).
	- `ensureScaffoldedScripts(workspaceRoot)` helper (copies templates to repo root if missing).
	- Command handlers for `scaffoldExtension.helloPython` and `scaffoldExtension.helloPowerShell`.
	- `ensureScaffoldedEnvironments(workspaceRoot)` helper (copies Python/PowerShell environment scaffold files if missing).
- Dependency changes (new/removed packages) and rationale:
	- None; use built-in Node.js and VS Code APIs only.
- Logging/telemetry additions and locations:
	- OutputChannel (e.g., “Scaffold Utils”) for runtime detection, execution, and errors.
	- No telemetry in MVP.
- Rollout plan (feature flags, staged deploys, fallback path):
	- No feature flags; local scaffold only. Fail fast with clear errors on missing workspace or runtimes.

## Definition of Done

- [ ] Acceptance criteria documented and mapped to tests or demos (Evidence: linked test plan and demo steps for both commands)
- [ ] Behavior matches acceptance criteria in all documented environments (Evidence: command runs on Windows/macOS/Linux)
- [ ] Tests updated/added (unit/integration as applicable) (Evidence: unit tests for runtime detection + scaffold copy)
- [ ] Edge cases and error handling covered by tests (Evidence: missing workspace and missing runtime cases)
- [ ] Docs updated (README, docs/features/active/... links) (Evidence: README includes first-run section)
- [ ] Telemetry/logging added or updated (if applicable) (Evidence: OutputChannel logging verified)
- [ ] Toolchain pass completed (format → lint → type-check → test) (Evidence: CI or local pass log)
- [ ] Environment scaffolds documented and validated (Evidence: Python tooling + PoshQC setup present in scaffold output)
- [ ] `pyproject.toml` and `poetry.toml` content matches the spec (Evidence: file comparison to spec template)

## Seeded Test Conditions (from potential)
- [ ] Unit tests for command registration and runtime detection logic.
- [ ] Integration tests for running Hello Python and Hello PowerShell end-to-end.
- [ ] Template copy logic verifies `hello_python.py` and `hello_pwsh.ps1` land in workspace root.
- [ ] Errors when runtimes are missing or scripts exit non-zero.
- [ ] Environment scaffold copy logic verifies Python tooling config and PoshQC assets land in workspace.
- [ ] `pyproject.toml` content matches the specified template.

## Python Scaffold Template (pyproject.toml)

```toml
[build-system]
requires = ["poetry-core>=1.9.0"]
build-backend = "poetry.core.masonry.api"

[tool.poetry]
name = "drm-copilot"
version = "0.1.1"
description = "Tool for optimizing use of copilot and streamlining documentation."
authors = ["Dan Moisan"]
license = "MIT"
readme = "README.md"
packages = [
	{ include = "scripts" },
]

[tool.poetry.dependencies]
python = ">=3.10,<4.0"
typer = ">=0.9.0"
PyYAML = ">=6.0"
numpy = ">=1.23"
click = ">=8.1"
pandas = ">=2.0"
scikit-learn = ">=1.3"
scipy = ">=1.10"
requests = ">=2.31"
beautifulsoup4 = ">=4.12"
lxml = ">=5.3.0"
pyarrow = ">=15.0"
pdfplumber = ">=0.10.0"
tensorflow = { version = ">=2.10.0", optional = true }
joblib = { version = ">=1.1.0", optional = true }
nltk = { version = ">=3.8", optional = true }
keras-preprocessing = { version = ">=1.1", optional = true }
openai = { version = ">=1.40.0", optional = true }

[tool.poetry.group.dev.dependencies]
pytest = ">=7.0"
pytest-cov = ">=7.0"
black = ">=23.0"
ruff = "^0.5.3"
pyright = "^1.1.407"
pyperclip = "^1.11.0"
jsonschema = "^4.25.1"
types-beautifulsoup4 = ">=4.12.0.0"
types-requests = ">=2.31.0.6"

[tool.poetry.scripts]
atomic-executor = "scripts.dev_tools.atomic_executor.cli:main"
shell-qc = "scripts.dev_tools.shell_qc:main"
shell-qc-check = "scripts.dev_tools.shell_qc:main_check"
shell-qc-format = "scripts.dev_tools.shell_qc:main_format"
shell-qc-test = "scripts.dev_tools.shell_qc:main_test"

# Dev Tools Aliases
"dev.atomic-executor" = "scripts.dev_tools.atomic_executor.cli:main"
"dev.clean-devcontainer" = "scripts.dev_tools.clean_devcontainer:main"
"dev.collect-commit-context" = "scripts.dev_tools.collect_commit_context:main"
"dev.fix-all" = "scripts.dev_tools.fix_all:main"
"dev.format-json" = "scripts.dev_tools.format_json:main"
"dev.format-markdown" = "scripts.dev_tools.markdown_label_formatter:main"
"dev.new-active-feature" = "scripts.dev_tools.new_active_feature_folder:main"
"dev.new-potential-bug" = "scripts.dev_tools.new_potential_bug_entry:main"
"dev.potential-to-issue" = "scripts.dev_tools.potential_to_issue:main"
"dev.pr-context" = "scripts.dev_tools.pr_context.collector:main"
"dev.resolve-execute-plan" = "scripts.dev_tools.resolve_execute_plan_prompt:main"
"dev.resolve-file-prompt" = "scripts.dev_tools.resolve_file_prompt:main"
"dev.shell-qc" = "scripts.dev_tools.shell_qc:main"
"dev.validate-json" = "scripts.dev_tools.validate_json:main"

[tool.black]
line-length = 88
target-version = ["py310"]

[tool.ruff]
line-length = 88
target-version = "py310"
fix = true
show-fixes = true

[tool.ruff.lint]
select = [
	"E",    # pycodestyle errors
	"F",    # pyflakes
	"I",    # isort
	"B",    # flake8-bugbear
	"UP",   # pyupgrade
	"S",    # flake8-bandit (security)
	"TID",  # flake8-tidy-imports
	"TCH",  # flake8-type-checking
]

[tool.ruff.lint.per-file-ignores]
"tests/**/*" = ["S101"]
"src/lexile_corpus_tuner/cli.py" = ["B008"]

[tool.pytest.ini_options]
minversion = "7.0"
addopts = "-ra"
testpaths = ["tests"]

[tool.coverage.run]
source = ["src", "scripts/dev_tools"]
data_file = "artifacts/.coverage"
omit = [
	"tests/*",
	"*/tests/*",
	"*/__pycache__/*",
	"*/site-packages/*",
]

[tool.coverage.report]
exclude_lines = [
	"pragma: no cover",
	"def __repr__",
	"raise AssertionError",
	"raise NotImplementedError",
	"if __name__ == .__main__.:",
	"if TYPE_CHECKING:",
	"@abstractmethod",
	"@abc.abstractmethod",
]

[tool.pyright]
include = ["src", "tests", "scripts"]
extraPaths = ["src", "scripts"]
typeCheckingMode = "strict"
diagnosticMode = "workspace"
reportMissingTypeArgument = "none"
venvPath = "."
venv = ".venv"
exclude = [
  "**/__pycache__",
  ".idea",
  ".ruff_cache",
  ".venv",
  "build",
	"dist",
	"artifacts"
]
reportUnknownParameterType = "error"
reportUnknownArgumentType = "error"
reportUnknownVariableType = "error"
reportUnknownMemberType = "error"
reportMissingImports = "error"
reportGeneralTypeIssues = "error"
reportOptionalMemberAccess = "error"
reportOptionalSubscript = "error"
reportPrivateUsage = "error"
reportUntypedFunctionDecorator = "error"
reportUntypedClassDecorator = "error"
```
