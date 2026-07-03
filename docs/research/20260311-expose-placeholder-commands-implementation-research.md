<!-- markdownlint-disable-file -->

# Task Research Notes: Expose Placeholder Commands (#92)

## Research Executed

### File Analysis

- `extensions/drm-copilot/src/extension.ts`
  - Contains `PLACEHOLDER_COMMAND_SPECS` array (4 entries) and `registerPlaceholderCommands()` helper
  - Existing real commands: `helloPython`, `helloPowerShell`, `collectCommitContext`, `collectPrContext`, `pushDownCopilotCustomizations`
  - All real commands delegate to `executeBundledScript(context, output, spec)` with a `CommandSpec`
  - Some commands (collectPrContext) gather user input via VS Code UI before calling executeBundledScript

- `extensions/drm-copilot/src/command-runtime.ts`
  - `CommandSpec`: `{ runtimeKind, bundledRelativePath, commandId, args? }`
  - `executeBundledScript()`: resolves script relative to `context.extensionUri`, detects runtime, spawns process
  - `detectRuntime()`: probes PATH for python/pwsh/powershell
  - `runCommandWithOutput()`: spawns subprocess with argv arrays (shell=false), streams stdout/stderr to output channel
  - `getWorkspaceRoot()`: returns first workspace folder fsPath

- `extensions/drm-copilot/resources/templates/collect_pr_context.py`
  - Thin wrapper: `_ensure_bundled_scripts_import_path()` prepends `resources/scripts/` to `sys.path`
  - Imports `dev_tools.pr_context.collector.main` and calls it
  - CLI args forwarded unchanged via `sys.argv`

- `extensions/drm-copilot/resources/templates/push_down_copilot_customizations.py`
  - Thin wrapper: same `_ensure_bundled_scripts_import_path()` pattern
  - Uses `argparse` to parse `--destination`, then `importlib.import_module("dev_tools.push_down_copilot_customizations")`
  - Resolves `source_root` to `resources/customizations` payload directory
  - Calls publisher function with typed Protocol interfaces

- `extensions/drm-copilot/resources/templates/collect_commit_context.py`
  - Self-contained script (no bundled package imports needed)
  - Directly implements git context collection

- `extensions/drm-copilot/resources/scripts/dev_tools/`
  - Contains `__init__.py` (empty), `agentic_sync.py`, `push_down_copilot_customizations*.py`, `pr_context/` subpackage
  - Bundled copies use `from dev_tools.x` imports (NOT `scripts.dev_tools.x`)
  - The `_ensure_bundled_scripts_import_path()` function makes this work by prepending `resources/scripts/` to sys.path

- `extensions/drm-copilot/test/extension.placeholder-commands.test.ts`
  - Tests registration of all 4 placeholder commands
  - Tests that placeholder handler throws deterministic "Not implemented" error
  - Uses same mock pattern as other test files

- `extensions/drm-copilot/test/extension.test.ts`
  - Comprehensive test suite for existing real commands
  - Tests: registration, script path resolution, argv arrays, cwd, exit codes, output channel logging
  - Uses `setExecutablePresence()` helper, `createMockProcess()`, `activateAndGetHandler()` pattern
  - Mocks: `vscode`, `node:fs`, `node:child_process`

- `extensions/drm-copilot/package.json`
  - 9 command contributions currently registered
  - Placeholder commands use "Placeholder" suffix in IDs and titles

### Script Dependency Analysis

#### 1. `new_active_feature_folder` — Full Dependency Tree

Source modules (all under `scripts/dev_tools/`):

- `new_active_feature_folder.py` — facade re-exporting all public symbols
- `new_active_feature_folder_flow.py` — orchestration + CLI (`parse_args`, `create_active_folder`, `main`)
- `new_active_feature_folder_io.py` — filesystem/template/git helpers
- `new_active_feature_folder_models.py` — domain models, protocols, constants (stdlib-only)
- `new_active_feature_folder_markdown.py` — markdown transforms (depends on `_models.PLACEHOLDERS`)
- `new_active_feature_folder_docs.py` — doc update helpers (depends on `_markdown`, `_models`)
- `prompt_mode_contract.py` — work-mode normalization (stdlib-only)

Import graph:

```
_flow.py → _docs, _io, _markdown, _models, prompt_mode_contract
_docs.py → _markdown, _models
_io.py   → _markdown, _models
_markdown.py → _models
_models.py → (stdlib only)
prompt_mode_contract.py → (stdlib only)
```

All modules use `from scripts.dev_tools.X` imports → must be rewritten to `from dev_tools.X` in bundled copies.

External tool dependencies:

- `gh` CLI — used by `default_issue_fetcher()` in `_io.py` (optional; returns None if not found)
- `code` / `code-insiders` — used by `default_code_launcher()` in `_io.py` (optional; prints fallback)
- `git` — NOT directly used by the module itself (only indirectly via `gh`)

#### 2. `potential_to_issue` — Full Dependency Tree

Source modules:

- `potential_to_issue.py` — orchestration + CLI (`parse_args`, `promote_potential`, `main`)
- `potential_to_issue_content.py` — content parsing/body generation (stdlib-only)
- `prompt_mode_contract.py` — work-mode normalization (shared with #1; stdlib-only)

Import graph:

```
potential_to_issue.py → potential_to_issue_content, prompt_mode_contract
potential_to_issue_content.py → (stdlib only)
prompt_mode_contract.py → (stdlib only)
```

Only `potential_to_issue.py` uses `from scripts.dev_tools.X` imports → must be rewritten.

External tool dependencies:

- `gh` CLI — **required** for `RealGhClient.is_authenticated()`, `issue_create()`, `issue_view()`
- `code` / `code-insiders` — NOT used directly (no VS Code launcher)
- `git` — NOT directly used

#### 3. `new_potential_bug_entry` — Full Dependency Tree

Source modules:

- `new_potential_bug_entry.py` — fully self-contained (no `scripts.*` imports)

Import graph:

```
new_potential_bug_entry.py → (stdlib only: argparse, os, re, shutil, subprocess,
                              dataclasses, datetime, pathlib, typing)
```

NO import rewriting needed.

External tool dependencies:

- `git` — used by `default_git_config_lookup()` to fetch `user.name`
- `code` / `code-insiders` — used by `default_code_launcher()` (optional)

#### 4. `new-potential-entry.ps1` — Full Dependency Tree

Source scripts:

- `scripts/dev-tools/new-potential-entry.ps1` — main script
- `scripts/dev-tools/vscode-cli.helpers.ps1` — sourced via `. (Join-Path -Path $PSScriptRoot -ChildPath 'vscode-cli.helpers.ps1')`

The PowerShell script uses `. <path>` (dot-sourcing) with `$PSScriptRoot`-relative path resolution, so the helper **must be co-located** in the same directory as the main script.

External tool dependencies:

- `git` — used by `Get-AuthorName` to fetch `user.name`
- `code` / `code-insiders` — used by `Invoke-VSCodeOpen` (optional)

### CLI Argument Analysis (User Input Requirements)

#### Command 1: `new_active_feature_folder`

| Argument | CLI Flag | Required | Values | VS Code UI Widget |
|----------|----------|----------|--------|-------------------|
| feature-name | `--feature-name` | Conditional | kebab/underscore string | `showInputBox` with validation |
| type | `--type` | No (default: "feature") | feature, refactor, epic, bug | `showQuickPick` with 4 items |
| issue-number | `--issue-number` | No (auto-detected) | digits or "auto" | `showInputBox` (optional) |
| work-mode | `--work-mode` | No (default: "full") | minor-audit, full-feature, full-bug, full | `showQuickPick` with 4 items |
| force | `--force` | No (default: false) | flag | Omit for v1 |
| active-file-for-feature-name | `--active-file-for-feature-name` | No | path to promoted .md | Omit for v1 |

**Recommended UI flow:**

1. `showQuickPick` → type (feature/refactor/epic/bug)
2. `showInputBox` → feature-name (with pattern validation)
3. `showInputBox` → issue-number (optional, allow empty for auto)
4. `showQuickPick` → work-mode (minor-audit/full-feature/full-bug/full)

#### Command 2: `potential_to_issue`

| Argument | CLI Flag | Required | Values | VS Code UI Widget |
|----------|----------|----------|--------|-------------------|
| potential-path | `--potential-path` | Yes | path to .md | `showOpenDialog` with .md filter |
| promotion-type | `--promotion-type` | No (default: "feature") | epic, feature, refactor, bug | `showQuickPick` |
| work-mode | `--work-mode` | No (default: "full") | minor-audit, full-feature, full-bug, full | `showQuickPick` |

**Recommended UI flow:**

1. `showOpenDialog` → potential-path (defaulting to `docs/features/potential/`)
2. `showQuickPick` → promotion-type
3. `showQuickPick` → work-mode

#### Command 3: `new_potential_bug_entry`

| Argument | CLI Flag | Required | Values | VS Code UI Widget |
|----------|----------|----------|--------|-------------------|
| short-name | `--short-name` | Yes | kebab-case string | `showInputBox` with validation |

**Recommended UI flow:**

1. `showInputBox` → short-name (regex: `^[a-z0-9]+(-[a-z0-9]+)*$`)

#### Command 4: `new-potential-entry.ps1`

| Argument | CLI Flag | Required | Values | VS Code UI Widget |
|----------|----------|----------|--------|-------------------|
| ShortName | `-ShortName` | Yes | kebab-case string | `showInputBox` with validation |

**Recommended UI flow:**

1. `showInputBox` → ShortName (regex: `^[a-z0-9]+(-[a-z0-9]+)*$`)

### Bundling Pattern Analysis

#### How `_ensure_bundled_scripts_import_path()` works

```python
def _ensure_bundled_scripts_import_path() -> None:
    scripts_dir = Path(__file__).resolve().parent.parent / "scripts"
    # Template at: resources/templates/foo.py
    # parent.parent = resources/
    # resources/ / "scripts" = resources/scripts/
    scripts_dir_str = str(scripts_dir)
    if scripts_dir_str not in sys.path:
        sys.path.insert(0, scripts_dir_str)
```

This makes `resources/scripts/dev_tools/` importable as `dev_tools.*`. The template at `resources/templates/X.py` resolves its parent twice to get `resources/`, then appends `scripts/`.

#### Layout relationship

```
resources/
├── templates/           # Entry points — thin CLI adapters
│   ├── collect_pr_context.py        → imports dev_tools.pr_context.collector
│   ├── push_down_copilot_customizations.py → imports dev_tools.push_down_...
│   └── (new templates go here)
├── scripts/             # Bundled packages — business logic
│   └── dev_tools/
│       ├── __init__.py
│       ├── pr_context/  # multi-file package
│       ├── push_down_copilot_customizations.py
│       └── (new modules go here)
└── customizations/      # Payload data (not code)
```

#### Import rewrite rule for bundled copies

Source: `from scripts.dev_tools.X import Y` → Bundled: `from dev_tools.X import Y`

Simple textual replacement: strip `scripts.` prefix from all absolute imports.

### Command ID Strategy

**Recommended new IDs (drop "Placeholder" suffix):**

| Old ID | New ID |
|--------|--------|
| `drmCopilotExtension.newActiveFeatureFolderPlaceholder` | `drmCopilotExtension.newActiveFeatureFolder` |
| `drmCopilotExtension.potentialToIssuePlaceholder` | `drmCopilotExtension.potentialToIssue` |
| `drmCopilotExtension.newPotentialBugEntryPyPlaceholder` | `drmCopilotExtension.newPotentialBugEntry` |
| `drmCopilotExtension.newPotentialEntryPsPlaceholder` | `drmCopilotExtension.newPotentialEntry` |

**New titles:**

- `drm-copilot: New Active Feature Folder`
- `drm-copilot: Potential To Issue`
- `drm-copilot: New Potential Bug Entry`
- `drm-copilot: New Potential Entry`

### Test Pattern Analysis

#### Existing patterns to follow

1. **Mock infrastructure** (shared across test files):
   - `jest.mock("vscode", ...)` — `commands.registerCommand`, `window.createOutputChannel`, `window.showQuickPick`, `workspace.workspaceFolders`, `Uri.joinPath`
   - `jest.mock("node:fs")` — `existsSync`
   - `jest.mock("node:child_process")` — `spawn`, `spawnSync`
   - `commandHandlers` Map to capture registrations

2. **Helper functions**:
   - `setExecutablePresence()` — configure which runtimes are available
   - `createMockProcess(exitCode)` — mock child process with EventEmitter
   - `activateAndGetHandler(commandId)` — activate + extract handler

3. **Test categories for new commands**:
   - Registration: `activateAndGetHandler(newId)` should find handler
   - Script path: verify `spawn` called with correct bundled path
   - Args passing: verify CLI args array matches expected values
   - Cancellation: when `showInputBox`/`showQuickPick` returns `undefined`, handler returns early (no spawn)
   - Runtime error: when python/pwsh not found, throws clear error
   - Exit code: non-zero exit throws

4. **Tests to remove**:
   - `extension.placeholder-commands.test.ts` — entire file deleted

5. **New test file strategy**:
   - Dedicated test files for complex commands (newActiveFeatureFolder, potentialToIssue)
   - Simpler tests for newPotentialBugEntry and newPotentialEntry in `extension.test.ts`

### Package.json Changes

Replace placeholder contributions:

```json
{ "command": "drmCopilotExtension.newActiveFeatureFolder", "title": "drm-copilot: New Active Feature Folder" },
{ "command": "drmCopilotExtension.potentialToIssue", "title": "drm-copilot: Potential To Issue" },
{ "command": "drmCopilotExtension.newPotentialBugEntry", "title": "drm-copilot: New Potential Bug Entry" },
{ "command": "drmCopilotExtension.newPotentialEntry", "title": "drm-copilot: New Potential Entry" }
```

### Project Conventions

- Standards referenced: `general-code-change.instructions.md`, `typescript-code-change.instructions.md`
- Instructions followed: established bundled-script template pattern, existing test patterns

## Key Discoveries

### Import Rewrite Requirement

All source modules under `scripts/dev_tools/` use absolute imports like `from scripts.dev_tools.X import Y`. The bundled copies under `resources/scripts/dev_tools/` must use `from dev_tools.X import Y` because `_ensure_bundled_scripts_import_path()` adds `resources/scripts/` to `sys.path`, making `dev_tools` a top-level package.

This is a **manual copy + sed** operation. Each time source modules change, bundled copies must be updated. This is the same sync discipline already required for `pr_context/` and `push_down_copilot_customizations*.py`.

### Shared Module: `prompt_mode_contract.py`

Both `new_active_feature_folder` and `potential_to_issue` depend on `prompt_mode_contract.py`. This module must be bundled once at `resources/scripts/dev_tools/prompt_mode_contract.py` and both wrapper templates will use it via `dev_tools.prompt_mode_contract`.

### PowerShell Script Self-Contained Pattern

The `new-potential-entry.ps1` script dot-sources `vscode-cli.helpers.ps1` using `$PSScriptRoot`. Both files must be placed together under `resources/templates/`. No `_ensure_bundled_scripts_import_path()` mechanism needed for PowerShell.

### User Input Cancellation Pattern

When any `showInputBox` or `showQuickPick` returns `undefined` (user pressed Escape), the command handler must `return` immediately without calling `executeBundledScript`. Same pattern as `collectPrContext`.

### `new_potential_bug_entry.py` Is Self-Contained

Zero `scripts.*` imports. Can be placed directly as a template (like `collect_commit_context.py`). No bundled package needed. This is the recommended approach (Option A).

### Workspace Resolution Must Be Patched

- `new_potential_bug_entry.py` source uses `Path(__file__).resolve().parents[2]` for workspace root. When bundled, `__file__` points to the extension install dir. Bundled copy must use `Path.cwd()` instead.
- `new-potential-entry.ps1` uses `Split-Path -Parent (Split-Path -Parent $PSScriptRoot)`. Bundled copy must use `Get-Location` (or just `$PWD`).

### Risk Analysis

| Risk | Severity | Mitigation |
|------|----------|------------|
| Bundled module sync drift | Medium | Document sync procedure; same discipline as existing modules |
| `gh` CLI not available | Medium | `potential_to_issue` requires `gh`; `new_active_feature_folder` degrades gracefully |
| `git` not available | Low | Only used for author name fallback; degrades to "Unknown" |
| `code`/`code-insiders` unavailable | Low | All scripts degrade gracefully with fallback message |
| Import rewrite errors | Medium | Verify each bundled copy imports work; integration test recommended |
| User cancels mid-flow | Low | Each UI prompt checks for undefined and returns early |
| Workspace root resolution | Low | `getWorkspaceRoot()` handles no-workspace with clear error |
| PowerShell helper co-location | Low | Both `.ps1` files in `resources/templates/`; `$PSScriptRoot` resolves correctly |

**Mandatory unachievable objective callout**:

- None identified. All objectives are achievable with proven patterns.

## Recommended Approach

### Architecture

Follow the established bundled-script pattern:

1. **Python commands with dependencies** (newActiveFeatureFolder, potentialToIssue):
   - Bundle module files under `resources/scripts/dev_tools/` with import rewrites
   - Create thin wrapper templates under `resources/templates/`
   - Wrapper calls `_ensure_bundled_scripts_import_path()` + `importlib.import_module()`

2. **Python command without dependencies** (newPotentialBugEntry):
   - Place script directly in `resources/templates/new_potential_bug_entry.py`
   - Patch `_resolve_workspace()` to use `Path.cwd()`

3. **PowerShell command** (newPotentialEntry):
   - Place `new-potential-entry.ps1` and `vscode-cli.helpers.ps1` in `resources/templates/`
   - Patch workspace resolution to use `Get-Location`

4. **User input gathering**:
   - `showInputBox` / `showQuickPick` / `showOpenDialog` before `executeBundledScript`
   - Return early on cancellation

5. **Command ID rename**: Drop "Placeholder" suffix

6. **Remove placeholder infrastructure**: Delete `PLACEHOLDER_COMMAND_SPECS`, `registerPlaceholderCommands()`, `PlaceholderCommandSpec`, `extension.placeholder-commands.test.ts`

### Complete File Manifest

#### New files under `resources/scripts/dev_tools/` (import-rewritten copies):

For **newActiveFeatureFolder** (6 files):

- `new_active_feature_folder.py`
- `new_active_feature_folder_flow.py`
- `new_active_feature_folder_io.py`
- `new_active_feature_folder_models.py`
- `new_active_feature_folder_markdown.py`
- `new_active_feature_folder_docs.py`

For **potentialToIssue** (2 files):

- `potential_to_issue.py`
- `potential_to_issue_content.py`

Shared (1 file):

- `prompt_mode_contract.py`

#### New files under `resources/templates/` (5 files):

- `new_active_feature_folder.py` — thin wrapper
- `potential_to_issue.py` — thin wrapper
- `new_potential_bug_entry.py` — self-contained (patched workspace resolution)
- `new-potential-entry.ps1` — copy (patched workspace resolution)
- `vscode-cli.helpers.ps1` — co-located helper

#### Modified files:

- `extensions/drm-copilot/src/extension.ts` — remove placeholder infrastructure, add 4 real handlers
- `extensions/drm-copilot/package.json` — update command contributions

#### Deleted files:

- `extensions/drm-copilot/test/extension.placeholder-commands.test.ts`

#### New test files:

- `extensions/drm-copilot/test/extension.new-active-feature-folder.test.ts`
- `extensions/drm-copilot/test/extension.potential-to-issue.test.ts`
- Simpler tests for newPotentialBugEntry and newPotentialEntry in `extension.test.ts`

## Implementation Guidance

- **Objectives**: Replace 4 placeholder commands with real handlers; bundle all dependencies; add user input; update tests and package.json
- **Key Tasks**:
  1. Bundle Python modules under `resources/scripts/dev_tools/` (with import rewrites)
  2. Create wrapper templates under `resources/templates/`
  3. Modify `extension.ts`: remove placeholder infra, add 4 real command handlers with UI input
  4. Update `package.json` command contributions
  5. Delete `extension.placeholder-commands.test.ts`
  6. Add new tests for each command
  7. Run full toolchain: format → lint → typecheck → test
- **Dependencies**: No new npm or Python dependencies required
- **Success Criteria**:
  - All 4 commands execute bundled scripts with correct args
  - User input cancellation returns early without error
  - All TypeScript toolchain gates pass
  - Placeholder infrastructure fully removed

### Recommended Implementation Sequence

| Phase | Description | Files Changed |
|-------|-------------|---------------|
| 1 | Bundle Python modules (import-rewritten) | `resources/scripts/dev_tools/` (9 new files) |
| 2 | Create wrapper templates | `resources/templates/` (5 new files) |
| 3 | Add `showInputBox`/`showOpenDialog` mocks | test files |
| 4 | Implement `newPotentialBugEntry` (simplest Python) | `extension.ts`, `package.json`, tests |
| 5 | Implement `newPotentialEntry` (simplest PowerShell) | `extension.ts`, `package.json`, tests |
| 6 | Implement `potentialToIssue` (medium complexity) | `extension.ts`, `package.json`, tests |
| 7 | Implement `newActiveFeatureFolder` (most complex) | `extension.ts`, `package.json`, tests |
| 8 | Remove placeholder infrastructure | `extension.ts`, delete placeholder test |
| 9 | Full toolchain pass | format → lint → typecheck → test |

Start with simplest command (phase 4) to validate pattern before tackling complex ones. Remove placeholders last to avoid mid-implementation test breakage.