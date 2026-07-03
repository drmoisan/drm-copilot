<!-- markdownlint-disable-file -->

# Task Research Notes: bundle-sync-agents

## Research Executed

### File Analysis

- `docs/features/active/2026-03-21-bundle-sync-agents-113/issue.md`
  - Defines the feature goal: expose `sync-agents-from-instructions` through the VS Code extension, make AGENTS generation discovery-based, deterministic, idempotent, and fail-fast on missing required inputs.
- `docs/features/active/2026-03-21-bundle-sync-agents-113/spec.md`
  - Confirms the execution model should match the existing bundled workspace-targeted commands and that repository-local CLI invocation of the root PowerShell script must remain supported.
- `docs/features/active/2026-03-21-bundle-sync-agents-113/user-story.md`
  - Restates the five acceptance criteria that drive command contribution, discovery scope, deterministic generation, failure handling, and automatic inclusion of new instruction files.
- `scripts/dev-tools/sync-agents-from-instructions.ps1`
  - Current implementation is a single PowerShell script with a hard-coded `$sections` array, a frontmatter-stripping helper, a renderer that emits `AGENTS.md`, and a `SupportsShouldProcess` write path; it does not discover instruction files and currently generates from only a subset of `.github/instructions/*.instructions.md`.
- `tests/scripts/dev-tools/sync-agents-from-instructions.Tests.ps1`
  - Current Pester coverage validates frontmatter stripping, empty-file handling, section aggregation, and write behavior, but it does not yet cover discovery, deterministic ordering, missing-input failure modes, or bundled-script parity.
- `extensions/drm-copilot/src/extension.ts`
  - Existing command handlers follow a stable pattern: compute `workspaceRoot` with `getWorkspaceRoot()`, call `executeBundledScript(...)`, and execute a bundled resource relative to the extension installation while using the active workspace as `cwd`.
- `extensions/drm-copilot/package.json`
  - The extension contributes ten live commands today; no sync-agents command is currently contributed.
- `extensions/drm-copilot/src/command-runtime.ts`
  - The execution contract is explicit: bundled scripts are resolved from the extension install path, launched with `python` or `pwsh`/`powershell`, and executed with the active workspace root as `cwd`.
- `extensions/drm-copilot/resources/templates/`
  - Current bundled templates include `new-potential-entry.ps1`, `hello_pwsh.ps1`, and several Python wrappers, but there is no bundled `sync-agents-from-instructions` template today.
- `extensions/drm-copilot/resources/templates/new-potential-entry.ps1`
  - Shows the repository’s current PowerShell bundling pattern: ship a self-contained PowerShell template inside `resources/templates/` and execute it directly through the extension runtime.
- `tests/scripts/dev-tools/new-potential-entry.Tests.ps1`
  - Demonstrates an existing parity-testing pattern that reads both the repo-root PowerShell script and the bundled extension template and asserts shared structure/behavior across both copies.
- `extensions/drm-copilot/test/extension.test.ts`
  - Covers command registration in `activate()`.
- `extensions/drm-copilot/test/extension.integration.test.ts`
  - Covers bundled execution path, runtime selection, bundled script path resolution, and workspace-root argument forwarding for live commands such as `pushDownCopilotCustomizations`.
- `scripts/dev_tools/push_down_copilot_customizations_rewrites.py`
  - Holds the rewrite catalog that maps documented script references to live VS Code command IDs for pushed-down customization content.
- `extensions/drm-copilot/resources/scripts/dev_tools/push_down_copilot_customizations_rewrites.py`
  - Bundled mirror of the rewrite catalog used by the extension-packaged customization publisher.
- `tests/scripts/dev_tools/test_push_down_copilot_customizations.py`
  - Already tests rewrite-catalog behavior for live extension commands and is the natural place to add sync-agents rewrite coverage if the new command should replace raw script references in pushed-down documentation.
- `.vscode/tasks.json`
  - Already exposes `Dev: Sync AGENTS.md from Instructions`, which invokes the repo-root script directly and confirms the root PowerShell script is part of the supported repository-local workflow.
- `README.md`
  - Documents the currently implemented extension commands and the repo-standard quality loops.
- `extensions/drm-copilot/README.md`
  - Documents the extension command surface and bundled execution model; it will likely need a sync-agents command entry when implementation occurs.

### Code Search Results

- `sync-agents-from-instructions|AGENTS.md`
  - Found the root script, the current Pester tests, the existing developer task, and multiple pushed-down agent docs that still mention the raw script path.
- `pushDownCopilotCustomizations`
  - Found the canonical live-command pattern across `extensions/drm-copilot/package.json`, `extensions/drm-copilot/src/extension.ts`, `extensions/drm-copilot/test/extension.test.ts`, `extensions/drm-copilot/test/extension.integration.test.ts`, `scripts/dev_tools/push_down_copilot_customizations_rewrites.py`, and the mirrored bundled rewrite module.
- `.github/**/*.instructions.md`
  - Found 16 current instruction files under `.github/instructions/`, including `typescript-*`, `csharp-*`, and `github-actions-ci-cd-best-practices.instructions.md`; the current hard-coded sync script only includes 10 section definitions, so AGENTS generation is already drifting from the real instruction set.
- `.github/**/*.prompt.md`
  - Found many prompt files under `.github/prompts/` and `.github/codex/`; these are not instruction files and should remain excluded from AGENTS generation under the feature’s stated scope.
- `.github/**/*.agent.md`
  - Found many agent files under `.github/agents/`; these are not instruction files, but some of them reference `sync-agents-from-instructions.ps1`, which makes the push-down rewrite catalog relevant if the new extension command should replace raw script references in copied content.
- `extensions/drm-copilot/resources/templates/*sync*agents*`
  - No bundled sync-agents template exists today.

### External Research

- #fetch:https://code.visualstudio.com/api/references/contribution-points#contributes.commands
  - Confirms that a user-facing VS Code command must be contributed in `package.json` under `contributes.commands`; contributed commands show in the Command Palette by default and invoking a command emits the corresponding `onCommand:${command}` activation event.
- #fetch:https://code.visualstudio.com/api/extension-guides/command
  - Confirms that `vscode.commands.registerCommand(...)` binds the command ID to the handler in code, while `package.json` command contributions make the command user-discoverable; this exactly matches the current extension pattern already used by `pushDownCopilotCustomizations`.
- #fetch:https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/sort-object?view=powershell-7.5
  - Confirms that PowerShell sorting behavior depends on the chosen properties and that `-Stable` preserves input order when sort keys tie; this supports the requirement that discovery order must be explicit rather than inherited from filesystem enumeration.
- #fetch:https://learn.microsoft.com/en-us/dotnet/api/system.stringcomparer.ordinal?view=net-9.0
  - Confirms that `StringComparer.Ordinal` performs a simple byte comparison independent of language/culture and is appropriate for programmatically generated strings; this is the strongest fit for deterministic relative-path ordering across machines.

### Project Conventions

- Standards referenced: `.github/copilot-instructions.md`, `.github/instructions/general-code-change.instructions.md`, `.github/instructions/general-unit-test.instructions.md`, `.github/instructions/powershell-code-change.instructions.md`, `.github/instructions/powershell-unit-test.instructions.md`, `.github/instructions/typescript-code-change.instructions.md`, `.github/instructions/typescript-unit-test.instructions.md`.
- Instructions followed: research-only output restricted to `artifacts/research/`; PowerShell changes should remain PowerShell 7+ compatible and use Pester; TypeScript changes should keep VS Code API wiring thin and use Jest; tests must stay deterministic and avoid temp files or external services.

## Key Discoveries

### Project Structure

The implementation naturally spans four existing seams:

1. **Repo-root PowerShell generator**
   - `scripts/dev-tools/sync-agents-from-instructions.ps1`
   - Directly invoked by `.vscode/tasks.json` for repository-local regeneration.

2. **Bundled extension execution surface**
   - `extensions/drm-copilot/package.json`
   - `extensions/drm-copilot/src/extension.ts`
   - `extensions/drm-copilot/src/command-runtime.ts`
   - `extensions/drm-copilot/resources/templates/`
   - All live commands follow the same pattern: contribute in `package.json`, register in `activate()`, then execute a bundled resource with the active workspace as `cwd`.

3. **Bundled payload / rewrite catalog**
   - `scripts/dev_tools/push_down_copilot_customizations_rewrites.py`
   - `extensions/drm-copilot/resources/scripts/dev_tools/push_down_copilot_customizations_rewrites.py`
   - Because pushed-down `.github` content already references `sync-agents-from-instructions.ps1`, the new live command is likely relevant here if copied documentation should prefer stable command IDs over raw script references.

4. **Test surfaces already aligned to those seams**
   - Pester for the root PowerShell script.
   - Jest for extension registration and bundled execution behavior.
   - Python tests for push-down rewrite behavior and bundled Python helper mirrors.

The current implementation gap is broader than just missing command wiring:

- The root sync script hard-codes only 10 instruction entries.
- The repository currently contains 16 `.instructions.md` files under `.github/instructions/`.
- The hard-coded header list and the hard-coded section list are already inconsistent: the script body includes `codexer` and `self-explanatory-code-commenting`, while the generated-source note in the header omits both and also omits all TypeScript and C# policy files.

This means the feature is not only an extension exposure task; it is also a correctness fix for the generator contract itself.

### Implementation Patterns

- **Live extension command pattern**
  - `package.json` contributes the command ID and title.
  - `extension.ts` registers the command with `vscode.commands.registerCommand`.
  - The handler obtains `workspaceRoot` via `getWorkspaceRoot()` and executes a bundled script through `executeBundledScript(...)`.
  - `command-runtime.ts` always resolves the script from the extension install path and launches it with the workspace root as `cwd`.

- **Bundled PowerShell template pattern**
  - PowerShell templates live directly under `extensions/drm-copilot/resources/templates/`.
  - The `new-potential-entry.ps1` template is a full PowerShell implementation, not a Python wrapper.
  - Existing Pester tests already validate parity assumptions between repo-root and bundled PowerShell scripts.

- **Discovery/generation risk in current sync script**
  - The script’s renderer depends on `$sections`, which manually controls both inclusion and section titles.
  - Any new `.instructions.md` file requires a code change today.
  - The current design therefore fails the feature’s “automatic inclusion on next sync run” requirement.

- **Determinism pattern already valued elsewhere in the repo**
  - In-memory filesystem tests for push-down helpers sort returned files deterministically.
  - Extension integration tests assert exact bundled resource paths and forwarded arguments.
  - The repository’s policies explicitly prioritize small, testable, deterministic behavior.

### Complete Examples

```typescript
// Current live-command pattern used by the extension.
// Source: extensions/drm-copilot/src/extension.ts
const pushDownCopilotCustomizationsDisposable = vscode.commands.registerCommand(
  "drmCopilotExtension.pushDownCopilotCustomizations",
  async () => {
    const commandId = "drmCopilotExtension.pushDownCopilotCustomizations";
    const workspaceRoot = getWorkspaceRoot();

    await executeBundledScript(context, output, {
      runtimeKind: "python",
      bundledRelativePath: "resources/templates/push_down_copilot_customizations.py",
      commandId,
      args: ["--destination", workspaceRoot],
    });
  },
);
```

### API and Schema Documentation

- **Recommended extension command contract**
  - Command ID: `drmCopilotExtension.syncAgentsFromInstructions`
  - Command title: `drm-copilot: Sync AGENTS.md from Instructions`
  - Runtime: PowerShell
  - Bundled template path: `resources/templates/sync-agents-from-instructions.ps1`
  - Arguments: `-RepoRoot <workspaceRoot>`

- **Existing root CLI contract**
  - Script: `scripts/dev-tools/sync-agents-from-instructions.ps1`
  - Parameter: `[string]$RepoRoot = (Resolve-Path "$PSScriptRoot/../..")`
  - Side effect: writes `<RepoRoot>/AGENTS.md`

- **Recommended internal generator contract**
  - `Get-InstructionsBody(Path)`
    - Reads a required Markdown file.
    - Strips YAML frontmatter.
    - Returns trimmed body content.
  - `Get-DiscoveredInstructionFiles(RepoRoot)`
    - Requires `.github/copilot-instructions.md`.
    - Discovers `*.instructions.md` under `.github/`.
    - Excludes non-instruction assets by pattern rather than name-specific allowlists.
    - Returns files sorted by normalized relative path using ordinal comparison.
  - `Get-AgentContent(RepoRoot)`
    - Builds the generated-source note and section blocks from the same discovered file list.
    - Derives section labels from file content with a deterministic fallback.
  - `Invoke-SyncAgentInstruction(RepoRoot)`
    - Preserves the existing write behavior and `ShouldProcess` contract.

- **Acceptance-criteria mapping to design/test implications**
  - AC1 command contribution and workspace execution
    - Requires `package.json` contribution, `extension.ts` registration, bundled PowerShell template creation, and Jest assertions for registration plus `-RepoRoot <workspaceRoot>` forwarding.
  - AC2 discovery-based workflow
    - Requires removal of the fixed `$sections` source-of-truth and new discovery helpers exercised by Pester.
  - AC3 deterministic, frontmatter-stripped, idempotent output
    - Requires discovery-order normalization, frontmatter stripping retained, and tests that the same inputs produce identical `Content` strings on repeated calls.
  - AC4 actionable failure on missing required inputs
    - Requires explicit failure when `.github/copilot-instructions.md` is absent or when no instruction files are found.
  - AC5 automatic inclusion of new instruction files
    - Requires tests that add a previously unseen `*.instructions.md` file to the discovered set and assert it appears in the next generated output without any section-array change.

### Configuration Examples

```json
{
  "contributes": {
    "commands": [
      {
        "command": "drmCopilotExtension.syncAgentsFromInstructions",
        "title": "drm-copilot: Sync AGENTS.md from Instructions"
      }
    ]
  }
}
```

### Technical Requirements

- Discovery scope should be **input-driven, not allowlist-driven**:
  - Mandatory preamble source: `.github/copilot-instructions.md`
  - Discovered instruction sources: `*.instructions.md` under the destination workspace’s `.github/` tree
  - Excluded by scope: `.prompt.md`, `.agent.md`, generated `AGENTS.md`, and any non-instruction assets

- Deterministic ordering should use **normalized relative paths** with **ordinal comparison**:
  - Do not rely on `Get-ChildItem` enumeration order.
  - Do not rely on culture-sensitive sort defaults for final ordering.
  - The generated-source note and the rendered section order should both derive from the same sorted file list.

- Section labeling should be deterministic and resilient:
  - First preference: first Markdown heading in the stripped body.
  - Fallback: frontmatter `name` if present.
  - Final fallback: filename-derived title.

- Error handling should remain fail-fast and actionable:
  - Missing `.github/copilot-instructions.md` should stop generation with an explicit error.
  - Zero discovered instruction files should stop generation with an explicit error.

- Alignment between repo-root and bundle should be enforced by tests:
  - The bundled template should not evolve independently from the root script.
  - If push-down rewrite behavior is included, the root and bundled rewrite catalogs must also stay aligned.

**Mandatory unachievable objective callout**:
- None identified. The feature is achievable within the current repo structure without introducing new runtime dependencies.

## Recommended Approach

Implement a **discovery-based, self-contained PowerShell sync script** at the repo root and ship an **identical bundled PowerShell copy** inside the extension, then expose that bundled copy through a new live extension command that follows the existing `executeBundledScript(...)` pattern.

Why this is the best fit:

- It matches the current extension’s command architecture exactly.
- It preserves repository-local CLI usage through the existing root PowerShell entrypoint and VS Code task.
- It keeps the AGENTS generator in one language and one implementation style instead of splitting logic across PowerShell and Python.
- It uses the existing repository pattern for bundled PowerShell scripts (`new-potential-entry.ps1`) rather than introducing a new packaging model just for this feature.
- It makes alignment testable: the bundled script can be compared directly to the root script, while Jest continues to validate extension registration and workspace execution.

Recommended design details:

1. **Replace the hard-coded `$sections` array with discovery helpers** inside `scripts/dev-tools/sync-agents-from-instructions.ps1`.
   - Discover `.github/copilot-instructions.md` explicitly.
   - Discover `*.instructions.md` recursively under `.github/`.
   - Normalize each discovered file to a repo-relative path using forward slashes.
   - Sort using ordinal comparison on the normalized relative path.

2. **Generate both the header source list and the section blocks from the same discovered collection**.
   - This removes the current drift where the header and body disagree.
   - It also makes repeated runs idempotent because the same ordered inputs always produce the same output.

3. **Create `extensions/drm-copilot/resources/templates/sync-agents-from-instructions.ps1` as the bundled execution target**.
   - The bundled copy should remain byte-for-byte aligned with the repo-root script except for path location.
   - The extension command should call it with `runtimeKind: "powershell"` and `args: ["-RepoRoot", workspaceRoot]`.

4. **Expose the live command through the extension**.
   - Add the `package.json` contribution.
   - Register the handler in `extension.ts` next to the other live commands.
   - Push the disposable into `context.subscriptions`.

5. **Update the rewrite catalog if destination customization content should advertise the live command instead of the raw script**.
   - The repo already copies agent files that mention `sync-agents-from-instructions.ps1`.
   - If the intended UX is “use the extension command when available,” add a rewrite target for the new command in both the root and bundled rewrite catalogs and cover it in `tests/scripts/dev_tools/test_push_down_copilot_customizations.py`.

Suggested internal pseudocode for generation:

- Discover required preamble and instruction files.
- Normalize all discovered relative paths.
- Ordinal-sort the normalized paths.
- For each file:
  - read raw text
  - strip YAML frontmatter
  - derive a stable section title
  - render section block
- Render header note from discovered relative paths
- Concatenate header + preamble section + discovered instruction sections
- Write `AGENTS.md` only after successful generation

Rejected alternatives (brief, non-exhaustive):

- **Reimplement the bundled workflow in Python while keeping the root script in PowerShell**
  - Rejected because it would duplicate generation logic across languages and weaken the required alignment between the repo-root script and the bundled copy.
- **Keep the current allowlist and only append the missing files**
  - Rejected because it still fails AC5 and would continue to drift whenever new instruction files are added.
- **Rely on ambient `Get-ChildItem`/`Sort-Object` defaults for ordering**
  - Rejected because the feature explicitly requires deterministic output across repeated runs and environments.

## Implementation Guidance

- **Objectives**: expose a new live extension command for AGENTS sync; make generation discovery-based and deterministic; preserve root CLI behavior; keep repo-root and bundled implementations aligned.
- **Key Tasks**:
  - Update `scripts/dev-tools/sync-agents-from-instructions.ps1` to discover instruction files and derive output from the discovered list.
  - Add bundled template `extensions/drm-copilot/resources/templates/sync-agents-from-instructions.ps1`.
  - Add `drmCopilotExtension.syncAgentsFromInstructions` to `extensions/drm-copilot/package.json` and `extensions/drm-copilot/src/extension.ts`.
  - Extend Pester tests for discovery, missing inputs, deterministic output, and bundled parity.
  - Extend Jest tests for command registration and bundled execution/argument forwarding.
  - Optionally extend rewrite-catalog logic and tests if pushed-down docs should prefer the new live command reference.
  - Update `README.md` and `extensions/drm-copilot/README.md` if the implemented command is intended to be documented alongside the existing command surface.
- **Dependencies**: no new runtime dependencies are required; the design can use existing PowerShell, TypeScript, Pester, and Jest infrastructure.
- **Success Criteria**:
  - The extension contributes and registers `drmCopilotExtension.syncAgentsFromInstructions`.
  - Invoking the command runs the bundled PowerShell script with the active workspace as `cwd` and forwards that workspace as `-RepoRoot`.
  - The generator fails when `.github/copilot-instructions.md` is missing or no instruction files are discovered.
  - A newly added `*.instructions.md` file appears automatically in generated `AGENTS.md` without code changes.
  - Repeated generation from identical inputs produces identical content.
  - Root and bundled sync scripts stay aligned under automated tests.