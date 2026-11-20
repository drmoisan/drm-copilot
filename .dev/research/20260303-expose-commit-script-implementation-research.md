<!-- markdownlint-disable-file -->

# Task Research Notes: expose-commit-script extension boundary implementation

## Research Executed

### File Analysis

- docs/features/active/2026-03-03-expose-commit-script-74/issue.md
  - Defines acceptance criteria for extension-side execution, destination-workspace `cwd` semantics, output path contract (`artifacts/commit_context.txt`), and explicit error-path test coverage.
- docs/features/active/2026-03-03-expose-commit-script-74/spec.md
  - Confirms scope: add commit-context collector command in scaffold extension, keep no-copy invariant, and preserve cross-platform deterministic runtime behavior.
- .github/prompts/research-issue.prompt.md
  - Requires one recommended approach, brief rejected alternatives, and implementation/test mapping grounded in codebase + external authoritative sources.
- extensions/scaffold-extension/src/extension.ts
  - Current command framework already provides reusable seams: command registration, runtime probing (`python`/`pwsh` fallback), bundled resource path resolution, subprocess spawn with explicit argv arrays, and workspace `cwd` binding.
- extensions/scaffold-extension/package.json
  - Existing command contribution model can be extended with a new `scaffoldExtension.collectCommitContext` command without architectural change.
- extensions/scaffold-extension/test/extension.test.ts
  - Existing deterministic unit strategy already validates registration, runtime probing, bundled script path usage, no-copy invariant, and spawn options (`shell: false`, `cwd`).
- extensions/scaffold-extension/test/extension.integration.test.ts
  - Existing integration pattern validates handler-to-spawn pipeline deterministically via mocked process APIs and concrete path assertions.
- scripts/dev_tools/collect_commit_context.py
  - Collector already implements required output sections and CLI (`--output` default `artifacts/commit_context.txt`), with explicit git resolution (`shutil.which("git")`) and no-staged marker semantics.
- tests/scripts/dev_tools/test_collect_commit_context.py
  - Existing deterministic Python tests encode expected section structure and edge conditions, enabling low-risk adaptation into bundled extension resource behavior.

### Code Search Results

- scaffoldExtension.helloPython|scaffoldExtension.helloPowerShell
  - Found in extension manifest + registration path, demonstrating established command contribution and activation flow.
- detectRuntime|getWorkspaceRoot|executeBundledScript
  - Found in `extensions/scaffold-extension/src/extension.ts` and directly reusable for new command orchestration.
- collect_commit_context|run_git|artifacts/commit_context.txt
  - Found in `scripts/dev_tools/collect_commit_context.py` and corresponding tests, confirming functional parity targets.
- workspaceFolders\?\[0\]|spawn\(.*cwd
  - Existing first-workspace-root selection and destination `cwd` propagation already present in command execution layer.

### External Research

- #githubRepo:"microsoft/vscode-extension-samples helloworld-sample command contribution registerCommand"
  - Official sample confirms canonical pattern: `contributes.commands` in manifest + `commands.registerCommand` during `activate`.
- #fetch:https://code.visualstudio.com/api/extension-guides/command
  - Confirms user-facing commands require manifest contribution; command handlers are bound with `registerCommand`; command visibility/enablement can be controlled via `menus.commandPalette` when needed.
- #fetch:https://code.visualstudio.com/api/references/contribution-points
  - Confirms `contributes.commands` contract and that invoking commands emits `onCommand:${command}` activation behavior.
- #fetch:https://code.visualstudio.com/api/references/activation-events
  - Confirms for VS Code 1.74+ contributed commands do not require explicit `activationEvents` entries for command activation.
- #fetch:https://code.visualstudio.com/docs/editor/workspaces
  - Confirms multi-root workspaces are first-class and that deterministic folder-selection policy is required to avoid ambiguous target repositories.
- #fetch:https://nodejs.org/api/child_process.html
  - Confirms `spawn(command, args, { cwd, shell: false })` is the deterministic cross-platform primitive; `cwd` controls repository context; missing `cwd` path or executable emits `ENOENT` on `error` event.

### Project Conventions

- Standards referenced: `.github/instructions/general-code-change.instructions.md`, `.github/instructions/general-unit-test.instructions.md`, TypeScript/Python policy files captured in workspace instructions.
- Instructions followed: research-only workflow, evidence-first recommendation, no code implementation, and single-solution recommendation with brief rejected alternatives.

## Key Discoveries

### Project Structure

The target behavior can be delivered by extending existing `extensions/scaffold-extension` command wiring rather than introducing a new execution subsystem. The Python collector already exists and is heavily tested under `scripts/dev_tools`, so extension work is primarily boundary orchestration: package-time resource placement + runtime execution in destination workspace context.

### Implementation Patterns

- Existing extension pattern already satisfies core security/runtime expectations:
  - explicit executable + argv arrays,
  - `shell: false`,
  - `cwd` set to workspace root,
  - output channel lifecycle logging,
  - no script copy to workspace root.
- Existing collector script already satisfies content requirements:
  - all requested sections,
  - graceful `(no staged changes)` markers,
  - default output at `artifacts/commit_context.txt`.
- Missing piece is packaging boundary:
  - collector must be bundled as extension resource and invoked from extension install path while targeting destination workspace Git repo via `cwd`.

### Complete Examples

```ts
// Existing extension orchestration pattern (current codebase)
const scriptPath = vscode.Uri.joinPath(
  context.extensionUri,
  spec.bundledRelativePath,
).fsPath;

const args = [...runtime.argsPrefix, scriptPath];
await runCommandWithOutput(output, runtime.executable, args, workspaceRoot);
```

### API and Schema Documentation

- VS Code command contract:
  - `package.json` -> `contributes.commands[]`
  - runtime binding -> `vscode.commands.registerCommand(commandId, handler)`
- Workspace selection contract:
  - `vscode.workspace.workspaceFolders` can contain multiple roots; extension must choose deterministically.
- Process execution contract:
  - Node `spawn(..., { cwd, shell: false })` executes in target working directory and avoids shell interpolation risk.
- Collector CLI contract:
  - `collect_commit_context.py` supports `--output/-o`, defaulting to `artifacts/commit_context.txt` relative to process `cwd`.

### Configuration Examples

```json
{
  "contributes": {
    "commands": [
      {
        "command": "scaffoldExtension.collectCommitContext",
        "title": "Scaffold: Collect Commit Context"
      }
    ]
  }
}
```

### Technical Requirements

- Preserve extension-side execution boundary:
  - bundled resource path in extension install dir,
  - destination workspace as runtime `cwd`.
- Runtime probing must remain deterministic:
  - Python command resolution for collector execution,
  - collector-internal git executable validation preserved.
- Multi-root policy must be explicit (deterministic first-root or explicit folder picker).
- Tests must remain deterministic and non-networked:
  - unit tests for registration/runtime/path/cwd arguments/logs,
  - integration tests for artifact generation and no-script-materialization invariant,
  - error-path tests for missing workspace/runtime/git and non-zero exits.

**Mandatory unachievable objective callout**:
- **No unachievable objective identified.** Required behavior is achievable by reusing existing extension/process seams and adapting an already-tested collector script into bundled resources.

## Recommended Approach

Use a **bundle-and-invoke adapter approach**:

1. Keep `collect_commit_context.py` as the canonical collector logic source and add an extension-bundled copy under `extensions/scaffold-extension/resources/templates/` (or `resources/scripts/`) generated/synced from the canonical script.
2. Add `scaffoldExtension.collectCommitContext` command in `extensions/scaffold-extension` that reuses current execution pipeline (`getWorkspaceRoot` -> `detectRuntime("python")` -> resolve bundled script path -> spawn with workspace `cwd`).
3. Invoke collector with explicit `--output artifacts/commit_context.txt` so destination artifact path is deterministic regardless of script defaults.
4. Preserve output-channel lifecycle logging with command-scoped prefixes for probe start/success/failure, script path, command start/success/failure, and surfaced stderr/stdout chunks.
5. Keep deterministic root-selection policy explicit:
   - short-term: first workspace folder (consistent with current extension behavior),
   - optional enhancement: explicit folder selection if acceptance criteria expands for multi-root UX.

Why this is the best fit:
- Maximizes reuse of existing proven seams and tested collector behavior.
- Minimizes divergence risk versus reimplementing git context logic in TypeScript.
- Aligns directly with acceptance criteria about extension boundary and destination workspace git-context targeting.

Rejected alternatives (brief, non-exhaustive):
- Reimplement collector logic directly in TypeScript: rejected due to duplication risk and parity drift against existing Python tests/behavior.
- Shelling out to a workspace-local copied script: rejected because it violates no-materialization boundary requirements.

## Implementation Guidance

- **Objectives**: Add one command that executes bundled collector logic from extension resources while targeting destination workspace repository context and emitting deterministic artifact/log outputs.
- **Key Tasks**:
  - Extend `extensions/scaffold-extension/package.json` command contributions.
  - Extend `extensions/scaffold-extension/src/extension.ts` command spec + handler wiring.
  - Add/sync bundled collector script resource.
  - Add deterministic unit/integration/error-path tests in scaffold-extension test suite.
  - Add extension README command/runtime documentation update.
- **Dependencies**: No new runtime dependency required; uses existing VS Code API + Node child_process + existing Python runtime contract.
- **Success Criteria**:
  - Command available in Command Palette and executes from bundled resource path.
  - Spawn uses destination workspace `cwd` and emits `artifacts/commit_context.txt` with expected sections.
  - `(no staged changes)` markers persist when staged set is empty.
  - No collector script appears in destination workspace root.
  - Deterministic tests cover unit, integration, and required error paths.