<!-- markdownlint-disable-file -->

# Task Research Notes: push-down copilot customizations implementation approach

## Research Executed

### File Analysis

- `docs/features/active/2026-03-09-push-down-copilot-customizations-84/issue.md`
  - Defines the core requirement: one-way push-down copy of `.github/agents`, `.github/instructions`, `.github/prompts`, and `.github/skills`, destructive overwrite of matching destination files, rewrite of repo-local script references to packaged extension references, and placeholder commands for uncovered scripts.
- `docs/features/active/2026-03-09-push-down-copilot-customizations-84/spec.md`
  - Confirms overwrite semantics, rewrite/placeholder scope, and the expectation that current bidirectional sync behavior must remain unchanged or be cleanly separated behind a new entry point.
- `docs/features/active/2026-03-09-push-down-copilot-customizations-84/user-story.md`
  - Repeats the acceptance criteria that matter most for design selection: preserve relative `.github/` paths, overwrite destination matches, rewrite known references, fail deterministically for placeholder commands, and add Python + extension coverage.
- `scripts/dev_tools/agentic_sync.py`
  - Current implementation is a bidirectional sync engine only: it compares files that exist in both repos, short-circuits on equivalent mtimes/content, syncs both sides to the selected source, and writes a JSON artifact. It does not enumerate one-way missing files, does not rewrite file content, and does not model extension-command mappings.
- `tests/scripts/dev_tools/test_agentic_sync.py`
  - Provides a strong reusable testing seam: `SyncFileSystem` is exercised with an in-memory implementation, proving the repo already prefers pure copy/sync orchestration with fake filesystem tests instead of temp files.
- `extensions/drm-copilot/src/extension.ts`
  - Current extension pattern already registers user-facing commands, resolves bundled resources via `context.extensionUri`, probes Python/PowerShell runtimes, runs bundled scripts with explicit argv arrays and `shell: false`, and binds subprocess `cwd` to the destination workspace.
- `extensions/drm-copilot/test/extension.test.ts`
  - Existing unit tests verify command registration, runtime detection, bundled-path execution, explicit output args, workspace `cwd`, and deterministic non-zero-exit logging for command execution.
- `extensions/drm-copilot/test/extension.integration.test.ts`
  - Existing integration-style tests verify the no-copy invariant (bundled scripts execute from the extension install path, not the workspace) and artifact-path contracts for commit/pr-context commands.
- `extensions/drm-copilot/test/extension.collect-pr-context.test.ts`
  - Confirms the repo already splits more specialized command behavior into a focused extension-side test file when a command needs dedicated branch/argument/error-path coverage.
- `extensions/drm-copilot/package.json`
  - Command contributions exist only for `scaffoldExtension.helloPython`, `scaffoldExtension.helloPowerShell`, `scaffoldExtension.collectCommitContext`, and `scaffoldExtension.collectPrContext`; there is no current command surface for the feature-promotion/orchestration scripts referenced in `.github` content.
- `extensions/drm-copilot/resources/templates/collect_commit_context.py`
  - Confirms the extension can bundle standalone Python entrypoints under `resources/templates/`.
- `extensions/drm-copilot/resources/templates/collect_pr_context.py`
  - Confirms the extension can also bundle thin wrapper scripts that import a packaged Python module tree from `resources/scripts/`, proving packaged Python logic can live beyond single-file templates.
- `artifacts/research/20260301-scaffold-extension-extension-side-execution-research.md`
  - Prior repository research established the accepted extension boundary pattern: bundled resource execution, destination-workspace `cwd`, and no script materialization into the workspace root.
- `artifacts/research/20260303-expose-commit-script-implementation-research.md`
  - Prior repository research already selected a bundle-and-invoke approach for Python scripts exposed through extension commands.
- `artifacts/research/20260305-expose-pr-context-script-implementation-research.md`
  - Prior repository research already selected the same adapter pattern for a more complex Python command, including explicit argument passing and deterministic error handling.

### Code Search Results

- `poetry run python -m scripts\.dev_tools\.[A-Za-z0-9_\.]+`
  - Found repeated `.github` references to `scripts.dev_tools.pr_context.collector`, `scripts.dev_tools.potential_to_issue`, and `scripts.dev_tools.new_active_feature_folder` across orchestrator agents and feature-promotion skills.
- `scripts/dev_tools/[A-Za-z0-9_\-/\.]+|scripts/dev-tools/[A-Za-z0-9_\-/\.]+`
  - Found repeated `.github` references to `${workspaceFolder}/scripts/dev_tools/new_potential_bug_entry.py` and `${workspaceFolder}/scripts/dev-tools/new-potential-entry.ps1`, confirming the rewrite layer must normalize both slash variants.
- `collectCommitContext|collectPrContext|new_active_feature_folder|potential_to_issue|new_potential_bug_entry|new-potential-entry`
  - Verified that `.github` content currently mentions the PR-context collector plus four feature-promotion/orchestration scripts, but only PR-context has a real extension command today.
- `scaffoldExtension\.|drm-copilot:|collectCommitContext|collectPrContext` inside `.github/**`
  - Found no existing extension-command references in copied `.github` content, so the push-down tool must introduce a new canonical textual reference format rather than preserving an existing one.
- `extensions/drm-copilot/resources/**`
  - Found both bundled template entrypoints (`collect_commit_context.py`, `collect_pr_context.py`) and a packaged Python subtree under `resources/scripts/dev_tools/pr_context/*`, proving the extension already supports packaged resource layouts for Python logic.

### External Research

- #githubRepo:"microsoft/vscode-extension-samples helloworld-sample command registration"
  - Official sample repo confirms the standard user-facing command pattern: declare commands in `package.json` and bind them with `commands.registerCommand` during activation.
- #fetch:https://code.visualstudio.com/api/extension-guides/command
  - Confirms two key constraints: user-facing commands require manifest contributions plus `registerCommand`, and `command:` URIs are only documented for hover text, completion item details, and webviews—not generic markdown files copied into a workspace.
- #fetch:https://code.visualstudio.com/api/references/vscode-api#MarkdownString
  - Confirms command execution from markdown requires trusted `MarkdownString` content with explicit command enablement, which does not apply to ordinary `.md` / `.instructions.md` / `SKILL.md` files on disk.
- #fetch:https://docs.python.org/3/library/shutil.html
  - Confirms Python’s standard library already provides correct overwrite semantics for copy operations: `copy()`, `copyfile()`, and `copytree(..., dirs_exist_ok=True)` overwrite destination files, while `copytree` can create missing intermediate directories.

### Project Conventions

- Standards referenced: `.github/prompts/research-issue.prompt.md`, `.github/instructions/general-code-change.instructions.md`, `.github/instructions/general-unit-test.instructions.md`, `.github/instructions/python-code-change.instructions.md`, `.github/instructions/python-unit-test.instructions.md`, and the existing extension-side execution research already captured under `artifacts/research/`.
- Instructions followed: research-only workflow, no source changes outside `artifacts/research/`, one final recommended approach, brief rejected alternatives only, and evidence-backed findings from inspected files plus authoritative docs.

## Key Discoveries

### Project Structure

The existing Python and extension layers already provide most of the building blocks required for this feature, but they are split across two different responsibilities:

- `agentic_sync.py` is a **comparison/synchronization** tool, not a **publishing/packaging** tool.
  - It only considers files present in both repos.
  - It never creates a missing destination file.
  - It never rewrites file content.
  - It writes an artifact summary using a small, testable dataclass model.
- `extensions/drm-copilot/src/extension.ts` is already a **bundled command adapter** layer.
  - It resolves scripts from extension resources.
  - It executes with explicit argv arrays and `shell: false`.
  - It runs in the destination workspace `cwd`.
  - It already has deterministic output/error logging tests.
- The extension currently exposes only four commands:
  - `scaffoldExtension.helloPython`
  - `scaffoldExtension.helloPowerShell`
  - `scaffoldExtension.collectCommitContext`
  - `scaffoldExtension.collectPrContext`
- The current `.github` customization surface references more scripts than the extension exposes today. Verified unique script targets in copied content include:
  - `scripts.dev_tools.pr_context.collector`
  - `scripts.dev_tools.potential_to_issue`
  - `scripts.dev_tools.new_active_feature_folder`
  - `scripts/dev_tools/new_potential_bug_entry.py`
  - `scripts/dev-tools/new-potential-entry.ps1`

That means the first release cannot rely on “implemented command only” rewrites. Placeholder command coverage is not optional—it is necessary to prevent dead workspace-relative script references.

### Implementation Patterns

- **Reusable Python seam already exists**
  - `ROOT_FOLDERS` in `agentic_sync.py` exactly matches the feature scope.
  - `SyncFileSystem` plus the in-memory filesystem in `test_agentic_sync.py` provide a policy-compliant way to test copy/overwrite/rewrite logic without temp files.
- **Extension-side command execution pattern is already standardized**
  - `executeBundledScript(...)` in `extension.ts` is the canonical adapter for real commands backed by bundled scripts.
  - Current tests assert the two invariants the new feature must preserve: bundled resource path usage and workspace-root `cwd` binding.
- **Command URIs are the wrong rewrite target for copied files**
  - Official VS Code docs limit `command:` URI usage to trusted `MarkdownString` contexts such as hovers, completion details, and webviews.
  - The copied `.github` files are plain repository files, not trusted runtime markdown surfaces.
  - Therefore the rewrite output should be a stable textual command reference, not a clickable `command:` URI.
- **Packaged Python modules are already supported**
  - `collect_pr_context.py` is a thin wrapper that prepends `resources/scripts/` to `sys.path` and imports `dev_tools.pr_context.collector`, showing the extension can expose either standalone bundled scripts or wrapper entrypoints over a packaged Python subtree.
- **Current command/catalog drift risk is real**
  - `.github` files contain no existing extension command references.
  - The rewrite map must align with extension registrations.
  - Without a shared catalog, the Python tool and extension command surface will drift quickly.

### Complete Examples

```typescript
// Source: extensions/drm-copilot/src/extension.ts
// Existing canonical extension-side command adapter pattern.
const scriptPath = vscode.Uri.joinPath(
  context.extensionUri,
  spec.bundledRelativePath,
).fsPath;

const specScriptArgs = spec.args ?? [];
const args = [...runtime.argsPrefix, scriptPath, ...specScriptArgs];
await runCommandWithOutput(output, runtime.executable, args, workspaceRoot);
```

```python
# Source: scripts/dev_tools/agentic_sync.py
# Existing canonical Python root-scoping seam for the `.github` trees in scope.
ROOT_FOLDERS: tuple[Path, ...] = (
    Path(".github/agents"),
    Path(".github/instructions"),
    Path(".github/prompts"),
    Path(".github/skills"),
)
```

### API and Schema Documentation

- VS Code command contract (official docs)
  - A user-facing command requires:
    - `contributes.commands[]` in `package.json`
    - `vscode.commands.registerCommand(...)` in `activate(...)`
- VS Code command URI contract (official docs)
  - `command:` links are documented for:
    - hover text
    - completion item details
    - webviews
  - Trusted `MarkdownString` is required to execute them.
  - This does **not** describe general markdown files stored in a workspace.
- Python copy contract (official docs)
  - `shutil.copy()` / `copyfile()` replace an existing destination file.
  - `shutil.copytree(..., dirs_exist_ok=True)` continues into existing directories and overwrites matching files.
- Existing repository command catalog (current codebase)
  - Real commands today:
    - `scaffoldExtension.collectCommitContext`
    - `scaffoldExtension.collectPrContext`
    - two hello/demo commands
  - Missing-but-needed commands for the current `.github` rewrite surface:
    - placeholder equivalents for `new_potential_bug_entry.py`, `new-potential-entry.ps1`, `potential_to_issue`, and `new_active_feature_folder`.

### Configuration Examples

```json
{
  "contributes": {
    "commands": [
      {
        "command": "scaffoldExtension.collectCommitContext",
        "title": "drm-copilot: Collect Commit Context"
      },
      {
        "command": "scaffoldExtension.collectPrContext",
        "title": "drm-copilot: Collect PR Context"
      }
    ]
  }
}
```

### Technical Requirements

- Success conditions
  - Every file under the four scoped `.github` roots is copied into the destination workspace under the same relative `.github/...` path.
  - Existing destination files at the same relative path are overwritten.
  - Known repo-local script references are rewritten to stable extension command references.
  - Unimplemented command targets resolve to placeholder commands that fail deterministically.
  - Existing bidirectional sync flows are not regressed.
- Failure conditions
  - Invalid source or destination root.
  - Non-text rewrite target cannot be decoded safely (should be copied unchanged or explicitly excluded from rewrite).
  - Unknown script reference that matches no catalog rule (should remain unchanged and be reported in the summary rather than silently mangled).
- Ordering rules
  - Enumerate source files by root, then relative path, in sorted order for deterministic artifact output.
  - For each file: detect text eligibility -> apply rewrites -> ensure destination directory -> write destination -> record copy/rewrite result.
- Recommended rewrite boundary
  - Rewrite only text files under the copied roots.
  - Normalize both `scripts/dev_tools` and `scripts/dev-tools` patterns before lookup.
  - Prefer exact/anchored script-command patterns over broad prose rewrites to avoid rewriting unrelated documentation text.
- Proposed state model
  - For each file:
    - `discovered` -> `decoded` -> (`rewritten` | `unchanged`) -> `copied` -> `recorded`
  - For each rewrite target in the shared catalog:
    - `implemented` (backed by bundled command adapter)
    - `placeholder` (registered command that throws deterministic not-implemented error)
  - Run-level summary:
    - `started` -> `copied` -> `artifact-written` -> `completed`
- Reporting/summary contract
  - The push-down run should write a JSON artifact summarizing:
    - source workspace
    - destination workspace
    - files copied
    - files overwritten
    - rewrite replacements applied by command ID/title
    - unmatched script-like references left unchanged
  - A separate artifact folder is clearer than reusing bidirectional sync output; `artifacts/copilot-customizations/` is the least ambiguous destination.

**Mandatory unachievable objective callout**:
- **No unachievable objective identified.** The feature fits current repo architecture because Python already has testable filesystem abstractions and the extension already has a proven bundled-command execution model plus packaged Python resource support.

## Recommended Approach

Implement this feature as a **new one-way Python push-down tool backed by a shared command-rewrite catalog**, while keeping the current bidirectional sync CLI untouched.

Selected design:

1. **Add a separate Python entry point for push-down behavior**
   - Do **not** overload the existing `agentic_sync.py` CLI with a second behavioral mode.
   - Reuse its proven seams (`ROOT_FOLDERS`, filesystem abstraction pattern, JSON artifact style), but keep the publish/copy logic in a dedicated module such as `scripts/dev_tools/push_down_copilot_customizations.py`.
   - Reason: `agentic_sync.py` is conceptually and behaviorally a two-repo reconciliation tool; the new feature is a one-way publisher with overwrite + rewrite semantics.

2. **Make the rewrite map a shared source-of-truth catalog, not duplicated literals**
   - Introduce a small catalog file that both the Python tool and extension layer can consume or validate against.
   - Each catalog entry should include at minimum:
     - canonical source script/module pattern(s)
     - normalized script key
     - extension command ID
     - user-facing command title
     - implementation status: `implemented` or `placeholder`
     - optional bundled resource metadata for implemented commands
   - Reason: current `.github` content already references more scripts than the extension exposes. Without a shared catalog, rewrite rules and placeholder registrations will drift.

3. **Rewrite copied files to canonical textual extension references, not `command:` URIs**
   - Recommended textual form:
     - `VS Code command: \`drm-copilot: Collect PR Context\` (command ID: \`scaffoldExtension.collectPrContext\`)`
   - For placeholder targets, use the same format with the placeholder command title/ID.
   - Reason: official VS Code docs restrict `command:` URIs to trusted runtime markdown contexts, which ordinary copied repo files are not.

4. **Register real and placeholder commands from the same conceptual catalog in the extension**
   - Real commands continue using the existing `executeBundledScript(...)` adapter pattern.
   - Placeholder commands should throw a stable deterministic error, for example:
     - `Not implemented: scaffoldExtension.newActiveFeatureFolderPlaceholder is a placeholder for scripts.dev_tools.new_active_feature_folder.`
   - That deterministic message should also be asserted in extension tests.

5. **Keep the first release intentionally narrow**
   - Immediately map the currently verified rewrite surface:
     - `scripts.dev_tools.pr_context.collector` -> real command (`scaffoldExtension.collectPrContext`)
     - `scripts.dev_tools.new_active_feature_folder` -> placeholder command
     - `scripts.dev_tools.potential_to_issue` -> placeholder command
     - `scripts/dev_tools/new_potential_bug_entry.py` -> placeholder command
     - `scripts/dev-tools/new-potential-entry.ps1` -> placeholder command
   - Leave unmatched references unchanged and report them in the artifact so coverage can expand safely.

Specific implementation hooks likely to change:

- Python layer
  - `scripts/dev_tools/agentic_sync.py`
    - likely minor shared extraction only (for example `ROOT_FOLDERS`, filesystem protocol reuse, or artifact helpers) if implementation chooses to avoid duplication.
  - `scripts/dev_tools/push_down_copilot_customizations.py` (new)
    - CLI entry point
    - file enumeration/copy engine
    - text rewrite pipeline
    - run summary rendering/writing
  - `tests/scripts/dev_tools/test_agentic_sync.py`
    - likely unchanged or only lightly refactored if the in-memory filesystem helper is shared.
  - `tests/scripts/dev_tools/test_push_down_copilot_customizations.py` (new)
    - overwrite/copy/rewrite/no-rewrite/unmatched-reference coverage using in-memory filesystem doubles.
- Extension layer
  - `extensions/drm-copilot/src/extension.ts`
    - extract inline command registrations into a catalog-driven registration flow
    - add placeholder registration helper
    - keep `executeBundledScript(...)` for implemented commands
  - `extensions/drm-copilot/package.json`
    - add command contributions for placeholder commands that the rewritten docs will reference.
  - `extensions/drm-copilot/test/extension.test.ts`
    - assert placeholder registration and deterministic not-implemented errors.
  - `extensions/drm-copilot/test/extension.integration.test.ts`
    - assert rewritten references point to extension commands, not workspace-local script paths.
  - `extensions/drm-copilot/test/extension.collect-pr-context.test.ts`
    - likely unchanged except for any shared command-catalog expectations if the real-command registry is centralized.
  - `extensions/drm-copilot/resources/templates/` and/or `resources/scripts/`
    - only change when a currently-placeholder script graduates to a real bundled command.

Why this is the best fit for repo policies and current architecture:

- Preserves current `agentic_sync.py` behavior rather than making its CLI ambiguous.
- Reuses the repo’s established no-temp-file Python testing style.
- Reuses the repo’s established extension-side bundled-script execution pattern.
- Minimizes initial scope while still satisfying the acceptance criteria for placeholders.
- Creates one durable seam—the shared rewrite/command catalog—that keeps Python copy logic and extension command exposure aligned.

Rejected alternatives (brief, non-exhaustive):

- **Add a push-down mode directly to `agentic_sync.py`’s current CLI**: rejected because it mixes two fundamentally different behaviors (two-way reconciliation vs one-way publishing) into one command surface and increases regression risk for current sync workflows.
- **Hardcode rewrite rules in Python and manually mirror them in TypeScript**: rejected because the feature docs explicitly call out drift risk between rewrite mapping and extension command exposure.
- **Rewrite copied files to clickable `command:` URIs**: rejected because official VS Code docs only support command URIs in trusted runtime markdown contexts such as hovers, completion details, and webviews—not ordinary repository files.

## Implementation Guidance

- **Objectives**: Deliver a one-way customization pack publisher that copies the scoped `.github` trees into a destination workspace, overwrites matching files, rewrites verified repo-local script references to extension command references, and guarantees placeholder coverage for scripts not yet implemented by the extension.
- **Key Tasks**:
  - Introduce a new Python push-down entry point instead of changing the current sync CLI contract.
  - Define a shared rewrite/command catalog with normalized script keys and implementation status.
  - Reuse the in-memory filesystem testing pattern for deterministic Python copy/rewrite tests.
  - Centralize extension command registration so implemented and placeholder commands come from the same conceptual catalog.
  - Rewrite copied text files to canonical textual command references (title + command ID), not `command:` URIs.
  - Emit a push-down summary artifact listing copied/overwritten files and rewrite outcomes.
- **Dependencies**: No new dependency is required. Python standard library `shutil`/`pathlib` already supports overwrite-capable copy operations, and the extension already uses the VS Code command API plus Node built-ins.
- **Success Criteria**:
  - Python tool copies all files under the four scoped `.github` roots into the destination workspace with preserved relative paths.
  - Matching destination files are overwritten deterministically.
  - Verified script references are rewritten to extension command references.
  - Missing extension coverage is handled through placeholder commands with deterministic not-implemented failures.
  - Existing `agentic_sync.py` bidirectional behavior remains intact.
  - Python tests cover enumeration, overwrite, rewrite, pass-through, and summary reporting without temp files.
  - Extension tests cover command exposure, real-command bundled execution, and placeholder failure paths.