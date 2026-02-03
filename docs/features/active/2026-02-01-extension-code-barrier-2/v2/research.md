<!-- markdownlint-disable-file -->

# Task Research Notes: extension-code-barrier

## Research Executed

### File Analysis

- d:\repos\drm-copilot\src\drm-task-provider.ts
  - Provider creates tasks but still executes host commands; no embedded utility runtime.
- d:\repos\drm-copilot\src\extension.ts
  - Command handlers build `ShellExecution` directly and call `vscode.tasks.executeTask`.
- d:\repos\drm-copilot\src\task-command-map.ts
  - Execution specs invoke host tools (`poetry`, `pwsh`, `gh`, `npm`) and many Python module paths without extension-root resolution.
- d:\repos\drm-copilot\.vscode\tasks.json
  - Canonical task definitions reference `${workspaceFolder}` scripts and workspace-local Python modules.
- d:\repos\drm-copilot\package.json
  - Contributes command IDs and taskDefinitions, but no mechanism to ship an executable utility runtime.

### Code Search Results

- scripts\.dev_tools|extensionRoot
  - d:\repos\drm-copilot\src\task-command-map.ts (mixed use of `${extensionRoot}` vs workspace-local Python modules)
- poetry|pwsh|gh|npm
  - d:\repos\drm-copilot\src\task-command-map.ts (host executables required for most commands)

### External Research

- #fetch:https://raw.githubusercontent.com/microsoft/vscode-extension-samples/main/task-provider-sample/src/customTaskProvider.ts
  - Shows TaskProvider usage with CustomExecution for tasks that need extension-side execution and shared state.

### Project Conventions

- Standards referenced: general-code-change.instructions.md, general-unit-test.instructions.md, typescript-code-change.instructions.md, typescript-unit-test.instructions.md, typescript-suppressions.instructions.md
- Instructions followed: Task Researcher Instructions (research-only, write to artifacts/research/)

## Key Discoveries

### Project Structure

The extension now registers a TaskProvider and executes tasks by building `ShellExecution` directly. However, the command execution specs still rely on host tools and workspace-local modules that are not shipped with the extension. This means the extension still assumes the workspace contains the same scripts or dependencies, so the original “extension vs workspace barrier” persists.

### Implementation Patterns

- Task execution is still driven by `ShellExecution` with commands like `poetry`, `pwsh`, `gh`, and `npm`.
- Some tasks use `${extensionRoot}` for PowerShell scripts, but many Python commands still invoke `scripts.dev_tools.*` without an extension-root path or `PYTHONPATH` override.
- The provider is used only to create tasks; it does not provide a runtime that guarantees utility code presence.

### Complete Examples

```typescript
// task-command-map.ts: Python modules still resolve from the workspace, not the extension.
"drm-copilot.qcFixAll": {
  command: "poetry",
  args: ["run", "python", "-m", "scripts.dev_tools.fix_all"],
},

// task-command-map.ts: some PowerShell scripts reference extensionRoot.
"drm-copilot.devNewPotentialEntry": {
  command: "pwsh",
  args: [
    "-NoLogo",
    "-NoProfile",
    "-ExecutionPolicy",
    "Bypass",
    "-File",
    "${extensionRoot}/scripts/dev-tools/new-potential-entry.ps1",
    "-ShortName",
    "${input:PotentialShortName}",
  ],
},
```

### API and Schema Documentation

The VS Code task provider sample uses `CustomExecution` when tasks need extension-side execution or shared state. This is relevant when the extension must run code that is bundled with the extension rather than relying on workspace tasks or host tools.

### Configuration Examples

```json
{
  "label": "Dev: 1 New Potential Entry",
  "type": "shell",
  "command": "pwsh",
  "args": [
    "-File",
    "${workspaceFolder}/scripts/dev-tools/new-potential-entry.ps1"
  ]
}
```

### Technical Requirements

- Utility code must execute from the extension or a shared, extension-managed runtime rather than the workspace.
- Updates to utility code must propagate to all workspaces that use the extension without manual copying.
- Workspace targeting (cwd, file paths) must remain tied to the workspace, even when code executes from the extension.
- Host tool dependencies should be explicit and minimized; otherwise commands will still fail in clean workspaces.

**Mandatory unachievable objective callout**:
- None identified.

## Recommended Approach

Adopt an extension-owned utility runtime and execute utilities from that runtime rather than from workspace-local scripts or toolchains.

### What the extension-owned utility runtime means

- **Utilities live inside the extension package** and are versioned/deployed with the extension. This makes every command deterministic and independent of the workspace contents.
- **Execution happens from the extension runtime** (Extension Host), with explicit workspace context passed in as parameters. The workspace is treated strictly as input/output data, never as a source of utility code.
- **Updates propagate automatically** because updating the extension updates the embedded utilities for every workspace.

### How to achieve it (deep dive)

#### 1) Inventory + classify utilities

- Enumerate each command and identify:
  - Current entry point (PowerShell script, Python module, or external CLI)
  - Workspace dependencies (paths, file operations, config expectations)
  - External tool requirements (`poetry`, `python`, `pwsh`, `gh`, `npm`)

Resulting classification:
- **Pure logic utilities** (string transforms, file templating, JSON edits) → best rewritten in TypeScript and executed directly in the extension.
- **Automation utilities that use CLI tooling** (git, gh, poetry) → either re-implement using Node libraries or provide explicit tool checks + guided error messages.
- **PowerShell utilities** → either rewrite in TypeScript or bundle a PowerShell host strategy only when absolutely necessary.

#### 2) Choose the runtime shape (extension-first)

Preferred path (lowest friction for the goal):
- **TypeScript/Node utilities** built into the extension and executed in-process.
- Create a single utility dispatcher: `runUtility(commandId, context)` that uses native Node APIs and the VS Code API for filesystem, prompts, and UI.

When external tools are unavoidable:
- Implement preflight checks (e.g., `which`/`where` for `gh`, `python`, `pwsh`).
- Provide actionable errors with guidance on installation steps.

#### 3) Establish a strict execution boundary

- Workspace is **data only** (inputs/outputs).
- Extension is **code only** (utilities, logic, templates). Store templates under `extensionRoot` and access them via `context.asAbsolutePath()`.
- Provide all workspace paths to utilities as explicit arguments; do not reference workspace-local module imports like `scripts.dev_tools.*`.

#### 4) Replace task specs with extension entry points

- Replace `ShellExecution` commands that point to workspace-local modules.
- Use a single command handler to invoke the extension-owned dispatcher.
- Reserve task integration only for long-running or user-visible processes; for most utilities, use direct execution inside the extension host.

#### 5) Handle cross-language dependencies

- If a subset of utilities must remain in Python or PowerShell:
  - Bundle them with the extension and call them using a known runtime.
  - Do not rely on workspace `poetry` or `pip` unless the utility is inherently workspace-specific.
- If a bundled runtime is too heavy, prioritize rewriting those utilities in TypeScript.

#### 6) Testing and validation strategy

- Unit-test the dispatcher logic without `vscode` by isolating pure utility functions.
- Integration tests should validate that a command works in a workspace with no `.vscode/tasks.json` and no repo-local scripts.
- Add an explicit “runtime integrity” check that validates required extension assets exist at activation time.

### Why this aligns with the stated goal

- The utility code is authored once (inside the extension) and updates propagate to all consuming workspaces when the extension updates.
- The workspace no longer needs a replica of the repo’s task definitions or scripts.

### Rejected alternatives (brief summary)

- **External shared package (pip/npm)**: reuses existing utilities but introduces installs, version management, and runtime drift across environments.
- **Workspace bootstrap/sync**: simpler execution but violates “write once” and mutates user repos.
- **Keep tasks calling workspace-local toolchains**: preserves the current failure mode and does not remove the barrier.

## Implementation Guidance

- **Objectives**: Ensure utilities run from a single, extension-managed runtime; eliminate reliance on workspace-local scripts; keep workspace context for file operations.
- **Key Tasks**:
  - Build a command/utility inventory with dependency classification.
  - Implement a TypeScript utility dispatcher as the primary execution path.
  - Rewrite highest-value utilities first (those most used and most broken).
  - Replace task specs with extension-owned entry points and preflight checks.
- **Dependencies**: VS Code APIs; optional Node libraries for git/gh functionality if replacing CLI calls.
- **Success Criteria**: A clean workspace with no copied scripts can run the utilities; updates to the extension update utility behavior across all projects.
