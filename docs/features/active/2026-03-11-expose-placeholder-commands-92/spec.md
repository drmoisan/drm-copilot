# 2026-03-11-expose-placeholder-commands — Spec

- **Issue:** #92
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-03-11T21-40
- **Status:** Draft
- **Version:** 0.1

## Overview

The VS Code extension registers four placeholder commands that intentionally throw errors when invoked. These commands reference real scripts (`new_active_feature_folder`, `potential_to_issue`, `new_potential_bug_entry`, `new-potential-entry.ps1`) but provide no runtime functionality. Users who discover these commands via the command palette encounter unhelpful "Not implemented" errors instead of executing the underlying dev-tool scripts. The existing PR-context and push-down commands demonstrate a proven pattern for bundling and executing scripts through the extension — the placeholder commands should follow the same approach.


## Behavior

Replace each placeholder command with a real command handler that bundles the corresponding script as a template resource within the extension and executes it against the destination workspace, following the same pattern established by `collectPrContext` and `pushDownCopilotCustomizations`:

1. **New Active Feature Folder** — Bundle `new_active_feature_folder` module and its dependencies under `resources/scripts/dev_tools/`, create a thin wrapper template at `resources/templates/new_active_feature_folder.py`, and register a real command handler that prompts for required arguments (feature name, type, issue number, work mode) and delegates to `executeBundledScript`.

2. **Potential To Issue** — Bundle `potential_to_issue` module and its dependency (`potential_to_issue_content`) under `resources/scripts/dev_tools/`, create a thin wrapper template at `resources/templates/potential_to_issue.py`, and register a real command handler that prompts for the potential file path, promotion type, and work mode.

3. **New Potential Bug Entry (Python)** — Bundle `new_potential_bug_entry` module under `resources/scripts/dev_tools/`, create a thin wrapper template at `resources/templates/new_potential_bug_entry.py`, and register a real command handler that prompts for the short name.

4. **New Potential Entry (PowerShell)** — Bundle `new-potential-entry.ps1` and its helper `vscode-cli.helpers.ps1` under `resources/templates/`, and register a real command handler that prompts for the short name and delegates to `executeBundledScript` with `runtimeKind: "powershell"`.

Each command should use VS Code input boxes or quick picks to gather user input before execution. Command IDs should drop the "Placeholder" suffix. Package.json command contributions should be updated to match the new titles.


## Inputs / Outputs

### Inputs

**User inputs gathered via VS Code UI (per command):**

| Command | Input | Widget | Validation / Default |
|---------|-------|--------|---------------------|
| `newActiveFeatureFolder` | type | `showQuickPick` | `feature`, `refactor`, `epic`, `bug` (default: `feature`) |
| `newActiveFeatureFolder` | feature-name | `showInputBox` | kebab/underscore pattern; required |
| `newActiveFeatureFolder` | issue-number | `showInputBox` | digits or empty for auto-detect; optional |
| `newActiveFeatureFolder` | work-mode | `showQuickPick` | `minor-audit`, `full-feature`, `full-bug`, `full` (default: `full`) |
| `potentialToIssue` | potential-path | `showOpenDialog` | `.md` filter, defaults to `docs/features/potential/` |
| `potentialToIssue` | promotion-type | `showQuickPick` | `epic`, `feature`, `refactor`, `bug` (default: `feature`) |
| `potentialToIssue` | work-mode | `showQuickPick` | same values as above |
| `newPotentialBugEntry` | short-name | `showInputBox` | regex `^[a-z0-9]+(-[a-z0-9]+)*$`; required |
| `newPotentialEntry` | ShortName | `showInputBox` | regex `^[a-z0-9]+(-[a-z0-9]+)*$`; required |

**Environment inputs:**

- `python3` or `python` on PATH (required for the three Python commands)
- `pwsh` or `powershell` on PATH (required for the PowerShell command)
- `gh` CLI authenticated (required by `potentialToIssue`; optional graceful degradation for `newActiveFeatureFolder`)
- `git` on PATH (optional; used for author name lookup; degrades to "Unknown")
- Workspace folder open in VS Code (passed as `cwd` to subprocess)

### Outputs

| Command | Artifacts | Location |
|---------|-----------|----------|
| `newActiveFeatureFolder` | Active feature folder with `issue.md`, `spec.md`, `user-story.md`, `research.md`, `change-plan.md` | `docs/features/active/<date>-<name>-<issue>/` in workspace |
| `potentialToIssue` | GitHub issue created; potential file updated with issue URL | GitHub; `docs/features/potential/promoted/` |
| `newPotentialBugEntry` | New potential bug markdown file | `docs/features/potential/` in workspace |
| `newPotentialEntry` | New potential entry markdown file | `docs/features/potential/` in workspace |

- All commands stream stdout/stderr to the `drm-copilot` VS Code output channel.
- Non-zero exit codes from spawned scripts are surfaced as VS Code error messages.

### Config keys and defaults

No new VS Code settings are introduced. All behavior is driven by command arguments.

### Versioning or backward-compatibility constraints

- Command IDs change (drop "Placeholder" suffix). Any keybinding or `tasks.json` reference to old IDs will break. This is acceptable because placeholder commands were non-functional.

## API / CLI Surface

### VS Code Commands

| Command ID | Title | Runtime |
|------------|-------|---------|
| `drmCopilotExtension.newActiveFeatureFolder` | `drm-copilot: New Active Feature Folder` | python |
| `drmCopilotExtension.potentialToIssue` | `drm-copilot: Potential To Issue` | python |
| `drmCopilotExtension.newPotentialBugEntry` | `drm-copilot: New Potential Bug Entry` | python |
| `drmCopilotExtension.newPotentialEntry` | `drm-copilot: New Potential Entry` | powershell |

### CommandSpec shapes

Each command constructs a `CommandSpec` and passes it to `executeBundledScript(context, output, spec)`:

```typescript
// newPotentialBugEntry
{ runtimeKind: "python", bundledRelativePath: "resources/templates/new_potential_bug_entry.py",
  commandId: "drmCopilotExtension.newPotentialBugEntry",
  args: ["--short-name", shortName] }

// newPotentialEntry
{ runtimeKind: "powershell", bundledRelativePath: "resources/templates/new-potential-entry.ps1",
  commandId: "drmCopilotExtension.newPotentialEntry",
  args: ["-ShortName", shortName] }

// potentialToIssue
{ runtimeKind: "python", bundledRelativePath: "resources/templates/potential_to_issue.py",
  commandId: "drmCopilotExtension.potentialToIssue",
  args: ["--potential-path", potentialPath, "--promotion-type", promotionType,
         "--work-mode", workMode] }

// newActiveFeatureFolder
{ runtimeKind: "python", bundledRelativePath: "resources/templates/new_active_feature_folder.py",
  commandId: "drmCopilotExtension.newActiveFeatureFolder",
  args: ["--feature-name", featureName, "--type", type,
         "--issue-number", issueNumber, "--work-mode", workMode] }
```

### Example invocations with expected outputs

1. User runs `drm-copilot: New Potential Bug Entry` → input box "Short name" → enters `blank-pr-context` → extension spawns `python3 resources/templates/new_potential_bug_entry.py --short-name blank-pr-context` with cwd = workspace root → output channel shows script output.

2. User runs `drm-copilot: New Potential Entry` → input box "Short name" → enters `stale-cache` → extension spawns `pwsh resources/templates/new-potential-entry.ps1 -ShortName stale-cache` with cwd = workspace root.

3. User runs `drm-copilot: Potential To Issue` → file dialog selects `docs/features/potential/2026-03-05-blank-pr-context.md` → quick pick "feature" → quick pick "full" → spawns `python3 resources/templates/potential_to_issue.py --potential-path <path> --promotion-type feature --work-mode full`.

### Contracts and validation rules

- If the user cancels any input prompt (`undefined` return), the handler returns immediately without spawning a process.
- If the required runtime (`python3`/`pwsh`) is not found on PATH, the command throws a descriptive error via `detectRuntime()`.
- Non-zero exit codes from the spawned script produce a VS Code error notification.

## Data & State

### Data flow

1. User invokes command via command palette.
2. Extension handler gathers inputs via VS Code UI widgets (`showInputBox`, `showQuickPick`, `showOpenDialog`).
3. Handler constructs a `CommandSpec` with the bundled script path and collected args.
4. `executeBundledScript` resolves the absolute script path relative to `context.extensionUri`, detects the runtime, and spawns a subprocess via `runCommandWithOutput`.
5. The subprocess runs in cwd = `getWorkspaceRoot()` (first open workspace folder).
6. Script stdout/stderr streams to the VS Code output channel in real time.
7. On non-zero exit, an error is thrown and surfaced to the user.

### Data transformations and invariants

- Bundled Python modules under `resources/scripts/dev_tools/` use `from dev_tools.X import Y` imports (rewritten from `from scripts.dev_tools.X import Y` in the source).
- `_ensure_bundled_scripts_import_path()` in each Python wrapper template prepends `resources/scripts/` to `sys.path` so `dev_tools` resolves as a top-level package.
- `_resolve_workspace()` in `new_potential_bug_entry.py` (bundled copy) uses `Path.cwd()` instead of `Path(__file__).resolve().parents[2]`.
- `new-potential-entry.ps1` (bundled copy) uses `Get-Location` instead of `Split-Path -Parent (Split-Path -Parent $PSScriptRoot)` for workspace root.
- Shared module `prompt_mode_contract.py` is bundled once and used by both `new_active_feature_folder` and `potential_to_issue`.

### Caching or persistence details

No caching. Commands are stateless; each invocation runs a fresh subprocess.

### Migration or backfill requirements

- Remove `PLACEHOLDER_COMMAND_SPECS` array, `PlaceholderCommandSpec` type, and `registerPlaceholderCommands()` function from `extension.ts`.
- Delete `extension.placeholder-commands.test.ts`.
- Update `package.json` command contributions to use new IDs and titles.

## Constraints & Risks

- Python wrapper templates must not duplicate business logic — they delegate to bundled modules only.
- Bundled module copies must stay in sync with the repo-root source modules. A manual copy-sync discipline or documented procedure is required.
- The `new-potential-entry.ps1` script sources `vscode-cli.helpers.ps1` via a relative path — the bundled copy needs that helper co-located or the path adjusted.
- The `new_active_feature_folder` module has 6 sub-modules — all must be bundled together.
- Input gathering via VS Code UI adds user-facing surface that must handle cancellation gracefully.


## Implementation Strategy

### Implementation scope

- **Remove**: `PLACEHOLDER_COMMAND_SPECS`, `PlaceholderCommandSpec`, `registerPlaceholderCommands()` from `extension.ts`; delete `extension.placeholder-commands.test.ts`.
- **Add bundled modules** (import-rewritten copies under `resources/scripts/dev_tools/`): `new_active_feature_folder.py`, `new_active_feature_folder_flow.py`, `new_active_feature_folder_io.py`, `new_active_feature_folder_models.py`, `new_active_feature_folder_markdown.py`, `new_active_feature_folder_docs.py`, `potential_to_issue.py`, `potential_to_issue_content.py`, `prompt_mode_contract.py`.
- **Add wrapper templates** (under `resources/templates/`): `new_active_feature_folder.py`, `potential_to_issue.py`, `new_potential_bug_entry.py`, `new-potential-entry.ps1`, `vscode-cli.helpers.ps1`.
- **Modify `extension.ts`**: add four real command handlers with VS Code UI input gathering and `executeBundledScript` delegation.
- **Modify `package.json`**: update four command contributions (new IDs, new titles).
- **Add test files**: `extension.new-active-feature-folder.test.ts`, `extension.potential-to-issue.test.ts`; add simpler tests for `newPotentialBugEntry` and `newPotentialEntry` in `extension.test.ts`.

### New classes/functions/commands to add or update

- Four async command handler functions in `extension.ts` (one per command), each following the pattern: gather UI input → check for cancellation → construct `CommandSpec` → call `executeBundledScript`.
- No new classes or exported APIs.

### Dependency changes

None. No new npm or Python packages required.

### Logging/telemetry additions

- All subprocess stdout/stderr already streams to the `drm-copilot` output channel via existing `runCommandWithOutput` infrastructure.
- No additional telemetry.

### Rollout plan

- Ship as a single extension update. No feature flags needed — commands replace non-functional placeholders.
- Users with keybindings referencing old placeholder IDs will need to update them (minor, documented in release notes).

### Recommended implementation sequence

| Phase | Description |
|-------|-------------|
| 1 | Bundle Python modules (9 import-rewritten files under `resources/scripts/dev_tools/`) |
| 2 | Create 5 wrapper templates/scripts under `resources/templates/` |
| 3 | Implement `newPotentialBugEntry` handler (simplest; 1 input, self-contained script) |
| 4 | Implement `newPotentialEntry` handler (1 input, PowerShell) |
| 5 | Implement `potentialToIssue` handler (3 inputs, 2 bundled modules) |
| 6 | Implement `newActiveFeatureFolder` handler (4 inputs, 6 bundled modules) |
| 7 | Remove placeholder infrastructure (`PLACEHOLDER_COMMAND_SPECS`, `registerPlaceholderCommands`, `extension.placeholder-commands.test.ts`) |
| 8 | Update `package.json` command contributions |
| 9 | Full toolchain pass: Prettier → ESLint → TSC → Jest |

## Definition of Done

- [x] Acceptance criteria documented and mapped to tests or demos
- [x] All four commands execute the correct bundled script with the correct args (verified by unit tests mocking `executeBundledScript`/`spawn`)
- [x] User input cancellation (Escape) returns early without spawning a process (verified by unit tests returning `undefined` from mocked UI widgets)
- [x] Placeholder infrastructure fully removed: no `PLACEHOLDER_COMMAND_SPECS`, `PlaceholderCommandSpec`, or `registerPlaceholderCommands` in codebase
- [x] `extension.placeholder-commands.test.ts` deleted
- [x] `package.json` command contributions use new IDs and titles (4 entries updated)
- [x] Bundled Python module imports use `from dev_tools.X` (not `from scripts.dev_tools.X`)
- [x] `new_potential_bug_entry.py` (bundled) uses `Path.cwd()` for workspace resolution
- [x] `new-potential-entry.ps1` (bundled) uses `Get-Location` for workspace resolution
- [x] `vscode-cli.helpers.ps1` is co-located with `new-potential-entry.ps1` in `resources/templates/`
- [x] Tests added: registration, script path, args, cancellation, runtime-not-found, exit code for each command
- [x] Docs updated (this spec, user-story, README if needed)
- [x] Toolchain pass completed: `npm run format` → `npm run lint` → `npm run typecheck` → `npm run test:unit` all pass

## Seeded Test Conditions (from potential)
- [x] Unit tests for each new command registration (mock `executeBundledScript`, verify correct `CommandSpec`)
- [x] Unit tests for user-input gathering (mock `showInputBox` / `showQuickPick`, verify cancellation returns early)
- [x] Integration-level tests verifying wrapper templates can import bundled modules
- [x] TypeScript type-check, lint, and format pass
