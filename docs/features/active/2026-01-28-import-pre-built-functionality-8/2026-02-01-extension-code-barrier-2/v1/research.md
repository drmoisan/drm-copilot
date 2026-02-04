<!-- markdownlint-disable-file -->

# Task Research Notes: extension-code-barrier

## Research Executed

### File Analysis

- d:\repos\drm-copilot\docs\features\active\2026-02-01-extension-code-barrier-2\issue.md
  - Describes extension-vs-workspace task execution failure, expected behavior, and repro.
- d:\repos\drm-copilot\docs\features\active\2026-02-01-extension-code-barrier-2\spec.md
  - Draft spec reiterates failure mode and sketches desired boundary between workspace and extension resources.
- d:\repos\drm-copilot\docs\features\active\2026-02-01-extension-code-barrier-2\plan.2026-02-01T11-35.md
  - Draft plan requires regression test first and minimal fix; no design choices captured yet.
- d:\repos\drm-copilot\src\extension.ts
  - Current command execution fetches workspace tasks and fails if label not present in workspace tasks.
- d:\repos\drm-copilot\src\task-command-map.ts
  - Static map of command IDs to task labels; no execution context info.
- d:\repos\drm-copilot\package.json
  - Commands contributed via extension manifest; no task provider contributions.
- d:\repos\drm-copilot\.vscode\tasks.json
  - Defines tasks used by the extension in this repo; commands rely on these labels.
- d:\repos\drm-copilot\.github\instructions\general-unit-test.instructions.md
  - General unit test policy (isolation, determinism, coverage, no temp files).
- d:\repos\drm-copilot\.github\instructions\python-code-change.instructions.md
  - Python tooling and typing standards; strict suppression rules.
- d:\repos\drm-copilot\.github\instructions\python-unit-test.instructions.md
  - Pytest-only testing; coverage command and test layout rules.
- d:\repos\drm-copilot\.github\instructions\python-suppressions.instructions.md
  - Pre-authorized Python suppression patterns and prohibited suppressions.
- d:\repos\drm-copilot\.github\instructions\self-explanatory-code-commenting.instructions.md
  - Mandatory docstrings and intent comments for Python.
- d:\repos\drm-copilot\.github\instructions\typescript-code-change.instructions.md
  - TypeScript tooling (Prettier/ESLint/TSC/Jest) and design rules.
- d:\repos\drm-copilot\.github\instructions\typescript-unit-test.instructions.md
  - Jest-only unit tests; structure and mocking guidance.
- d:\repos\drm-copilot\.github\instructions\typescript-suppressions.instructions.md
  - Pre-authorized ESLint/TypeScript suppression patterns.
- d:\repos\drm-copilot\.github\instructions\powershell-code-change.instructions.md
  - PowerShell tooling (PoshQC format/analyze) and safety rules.
- d:\repos\drm-copilot\.github\instructions\powershell-unit-test.instructions.md
  - Pester-only tests; PoshQC test command.
- d:\repos\drm-copilot\docs\features\templates\policy_audit\AGENTS.md
  - Policy audit instructions apply only when a policy audit is explicitly requested.

### Code Search Results

- tasks.fetchTasks|executeTask
  - d:\repos\drm-copilot\src\extension.ts (runTaskByLabel uses workspace tasks only)
- TaskProvider|ShellExecution|ProcessExecution|TaskScope
  - No existing task provider or programmatic task creation in src/.

### External Research

- #fetch:https://github.com/drmoisan/drm-copilot/issues/2
  - Confirms bug summary and expected behavior; matches local issue.md details.
- #fetch:https://github.com/drmoisan/drm-copilot
  - Repo overview confirms extension scaffolding and command list in README.
- #fetch:https://code.visualstudio.com/api/references/vscode-api#tasks
  - Documents `vscode.tasks.fetchTasks`, `vscode.tasks.executeTask`, `Task`, `TaskScope`, `ShellExecution`, `ProcessExecution`, and `CustomExecution` APIs.
- #fetch:https://code.visualstudio.com/api/extension-guides/task-provider
  - Provides task provider pattern and example for registering tasks programmatically and resolving tasks by definition.
- #fetch:https://github.com/microsoft/vscode-extension-samples/tree/main/task-provider-sample/src/customTaskProvider.ts
  - Concrete TaskProvider + CustomExecution sample showing task construction and shared state handling.
- #fetch:https://code.visualstudio.com/docs/editor/tasks
  - Describes tasks.json semantics, labels, `options.cwd`, and task execution contexts.
- #fetch:https://code.visualstudio.com/docs/reference/tasks-appendix
  - Provides tasks.json schema details including `options.cwd` and task fields.

### Project Conventions

- Standards referenced: general-code-change.instructions.md, general-unit-test.instructions.md, python-code-change.instructions.md, python-unit-test.instructions.md, python-suppressions.instructions.md, self-explanatory-code-commenting.instructions.md, typescript-code-change.instructions.md, typescript-unit-test.instructions.md, typescript-suppressions.instructions.md, powershell-code-change.instructions.md, powershell-unit-test.instructions.md
- Instructions followed: Task Researcher Instructions (research-only, write to artifacts/research/)

## Key Discoveries

### Project Structure

The extension registers commands in `package.json` and wires handlers in `src/extension.ts`. Each command (except the informational `applyCustomizations`) maps to a task label in `TASK_COMMAND_MAP`, which is intended to be a workspace task label. The tasks themselves live in `.vscode/tasks.json` inside this repo and reference `${workspaceFolder}` paths and repo-local scripts. This means the extension expects the user’s workspace to have the same tasks and scripts, which is not true for arbitrary workspaces.

### Implementation Patterns

- Command execution uses `vscode.tasks.fetchTasks()` and matches by `Task.name` (label) only.
- No task provider is registered; no dynamic task creation exists.
- Tasks depend on `${workspaceFolder}` and scripts under `scripts/` in this repo, indicating extension resources are assumed to exist in the user workspace.
- The command-to-task mapping is centralized and testable in `task-command-map.ts`.

### Complete Examples

```typescript
// Custom task provider sample (from vscode-extension-samples).
export class CustomBuildTaskProvider implements vscode.TaskProvider {
  static CustomBuildScriptType = 'custombuildscript';

  public async provideTasks(): Promise<vscode.Task[]> {
    return this.getTasks();
  }

  public resolveTask(_task: vscode.Task): vscode.Task | undefined {
    const flavor: string = _task.definition.flavor;
    if (flavor) {
      const definition = _task.definition as CustomBuildTaskDefinition;
      return this.getTask(definition.flavor, definition.flags ?? [], definition);
    }
    return undefined;
  }
}
```

### API and Schema Documentation

The VS Code API provides `vscode.tasks.executeTask`, `vscode.tasks.fetchTasks`, `vscode.tasks.registerTaskProvider`, and task execution classes (`ShellExecution`, `ProcessExecution`, `CustomExecution`). Task providers allow extensions to supply tasks dynamically without requiring a workspace `.vscode/tasks.json` file. The tasks.json schema documents `command`, `args`, and `options.cwd` for specifying working directory and environment.

### Configuration Examples

```json
{
  "label": "QC: 1 Black: format",
  "type": "shell",
  "command": "poetry",
  "args": ["run", "black", "."],
  "options": { "cwd": "${workspaceFolder}" }
}
```

### Technical Requirements

- Commands must execute in any workspace without requiring repo-local `.vscode/tasks.json` or scripts copied into the workspace.
- Execution must distinguish extension resources (scripts bundled in extension) from workspace resources (target filesystem, cwd).
- Multi-root workspaces must have deterministic folder targeting or explicit selection.
- Errors must be clear and actionable when required prerequisites (e.g., missing tools) are not met.

**Mandatory unachievable objective callout**:
- None identified.

## Recommended Approach

Implement a task provider and programmatic task execution that resolves script paths from the extension while using the workspace folder as the execution cwd.

This approach aligns with VS Code’s task provider model, removes the dependency on workspace `tasks.json`, and keeps command-to-task mapping intact. It allows reuse of the existing task labels for UI stability while creating tasks dynamically. It also provides a natural spot to encode workspace/extension boundary rules.

Key design points:

- **Task definitions and provider**: Introduce a `drm-copilot` task type and register a `TaskProvider` that exposes tasks matching `TASK_COMMAND_MAP`. The provider returns `vscode.Task` instances with `ShellExecution` or `ProcessExecution` pointing to extension-packaged scripts.
- **Workspace targeting**: Select the active workspace folder (single-root) or prompt for a folder (multi-root). The task `scope` should be the selected folder, and `options.cwd` should be set to the workspace root to ensure commands operate on the user’s repo.
- **Extension resource resolution**: Use `context.extensionUri` / `context.asAbsolutePath()` to resolve scripts packaged with the extension. This satisfies the requirement that utilities come from the extension, not the workspace.
- **Command handler**: Replace `fetchTasks()` label lookup with a direct provider-backed task creation or a lookup against provider tasks only, to avoid false negatives when no workspace tasks exist.

Rejected alternatives (non-exhaustive):

- **Auto-generate `.vscode/tasks.json` in the user workspace**: rejected because it mutates user repos and still relies on workspace-local scripts that may not exist or be desired.
- **Bypass Tasks entirely and use `child_process`/terminal directly**: rejected because it loses task integrations (task UI, problem matchers, consistent execution model) and increases platform-specific complexity.

## Implementation Guidance

- **Objectives**: Ensure `drm-copilot` commands run in any workspace by executing extension-packaged scripts with workspace cwd and explicit context selection.
- **Key Tasks**:
  - Add a task provider module to create tasks from `TASK_COMMAND_MAP` with correct execution and cwd.
  - Update command registration to use the provider tasks rather than `fetchTasks()` from the workspace.
  - Add workspace folder selection logic for multi-root workspaces.
  - Update tests to validate task creation and command execution routing without workspace `tasks.json`.
- **Dependencies**: No new runtime dependencies; leverage VS Code task APIs already available.
- **Success Criteria**: Commands execute in a clean workspace without tasks.json; multi-root selection is deterministic; errors are actionable; unit tests cover mapping and task construction behavior.