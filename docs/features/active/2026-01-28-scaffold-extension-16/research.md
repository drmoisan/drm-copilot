<!-- markdownlint-disable-file -->

# Task Research Notes: scaffold-extension implementation approach

## Research Executed

### File Analysis

- d:\repos\drm-copilot.worktrees\wt-master-rebuild\docs\features\active\2026-01-28-scaffold-extension-16\issue.md
  - Defines problem, acceptance criteria, constraints, and test conditions for the scaffold extension.
- d:\repos\drm-copilot.worktrees\wt-master-rebuild\docs\features\active\2026-01-28-scaffold-extension-16\spec.md
  - Draft spec with behavior summary, constraints, and definition of done.
- d:\repos\drm-copilot.worktrees\wt-master-rebuild\docs\features\active\2026-01-28-scaffold-extension-16\user-story.md
  - Draft user story; acceptance criteria mirror issue.md.
- d:\repos\drm-copilot.worktrees\wt-master-rebuild\docs\features\active\2026-01-28-scaffold-extension-16\plan.2026-02-11T20-01.md
  - Plan template referencing required policy docs; no implementation plan yet.
- d:\repos\drm-copilot.worktrees\wt-master-rebuild\.vscode\settings.json
  - Workspace tooling hints (e.g., tasks/tsc auto-detect off), no extension scaffold present.

### Code Search Results

- package.json
  - No package.json files exist in this repo snapshot.
- **/*.{ps1,psm1,py,sh,ts,js}
  - Only docs and policy files; no implementation sources found.

### External Research

- #githubRepo:"microsoft/vscode-extension-samples task-provider-sample"
  - Not available in this environment; used #fetch GitHub page instead for sample structure.
- #fetch:https://github.com/drmoisan/drm-copilot/issues/16
  - Issue URL returned 404 (likely private); no additional details accessible.
- #fetch:https://code.visualstudio.com/api/get-started/extension-anatomy
  - Extension structure, activation/command registration, entry point conventions.
- #fetch:https://code.visualstudio.com/api/references/extension-manifest
  - package.json extension manifest fields (name, publisher, main, contributes, activationEvents, engines.vscode).
- #fetch:https://code.visualstudio.com/api/references/activation-events
  - onCommand activation and implicit activation for commands declared in contributes.commands.
- #fetch:https://code.visualstudio.com/api/references/contribution-points
  - contributes.commands and contributes.taskDefinitions usage and structure.
- #fetch:https://code.visualstudio.com/api/extension-guides/command
  - registerCommand and user-facing command contributions (commands + activation guidance).
- #fetch:https://code.visualstudio.com/api/extension-guides/task-provider
  - TaskProvider, task definitions, and ShellExecution vs ProcessExecution guidance.
- #fetch:https://code.visualstudio.com/docs/editor/tasks
  - tasks.json usage, platform-specific properties, and variable substitution.
- #fetch:https://code.visualstudio.com/docs/reference/tasks-appendix
  - tasks.json schema details for task definitions and properties.
- #fetch:https://code.visualstudio.com/docs/reference/variables-reference
  - ${workspaceFolder}, ${pathSeparator}, and variable substitution constraints.
- #fetch:https://code.visualstudio.com/api/references/vscode-api
  - vscode.commands.registerCommand, tasks API, workspace.fs for file copying.
- #fetch:https://code.visualstudio.com/api/references/when-clause-contexts
  - when-clause contexts for conditional command visibility if needed.
- #fetch:https://code.visualstudio.com/api/references/commands
  - Built-in command list and examples for executeCommand.
- #fetch:https://github.com/microsoft/vscode-extension-samples/tree/main/task-provider-sample
  - Sample layout and task-provider sample references.
- #fetch:https://docs.npmjs.com/cli/v7/configuring-npm/package-json
  - Base package.json fields and constraints for naming/versioning.

### Project Conventions

- Standards referenced: general code change policy; general unit test policy.
- Instructions followed: .github/instructions/general-code-change.instructions.md; .github/instructions/general-unit-test.instructions.md.

## Key Discoveries

### Project Structure

The repo snapshot contains only documentation and policy files. There is no existing VS Code extension scaffold or runtime code. Any implementation will require creating a new extension folder and baseline project files.

### Implementation Patterns

No internal patterns exist for extensions or runtime detection. External documentation establishes expected VS Code extension structure (package.json manifest + extension entry point) and the task provider contract.

### Complete Examples

```ts
// From VS Code extension anatomy docs: command registration pattern.
import * as vscode from 'vscode';

export function activate(context: vscode.ExtensionContext) {
  const disposable = vscode.commands.registerCommand('helloworld.helloWorld', () => {
    vscode.window.showInformationMessage('Hello World!');
  });

  context.subscriptions.push(disposable);
}

export function deactivate() {}
```

```ts
// From Task Provider guide: registerTaskProvider with resolveTask/provideTasks.
import * as vscode from 'vscode';

const taskProvider = vscode.tasks.registerTaskProvider('rake', {
  provideTasks: () => getRakeTasks(),
  resolveTask(_task: vscode.Task): vscode.Task | undefined {
    const taskName = _task.definition.task;
    if (!taskName) {
      return undefined;
    }

    const definition = _task.definition as { type: string; task: string };
    return new vscode.Task(
      definition,
      _task.scope ?? vscode.TaskScope.Workspace,
      definition.task,
      'rake',
      new vscode.ShellExecution(`rake ${definition.task}`)
    );
  }
});
```

### API and Schema Documentation

- Extension manifest fields: name, publisher, engines.vscode, main, contributes.commands, contributes.taskDefinitions, activationEvents. (VS Code extension manifest docs)
- Task provider API: vscode.tasks.registerTaskProvider, TaskDefinition, Task, ShellExecution/ProcessExecution. (Task Provider guide)
- tasks.json schema for custom tasks and platform-specific overrides. (tasks-appendix)
- Variable substitution for ${workspaceFolder} and OS-specific path handling. (variables-reference)

### Configuration Examples

```json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "Run tests",
      "type": "shell",
      "command": "./scripts/test.sh",
      "windows": {
        "command": ".\\scripts\\test.cmd"
      },
      "group": "test",
      "presentation": {
        "reveal": "always",
        "panel": "new"
      }
    }
  ]
}
```

### Technical Requirements

- Scaffolding must create `hello_python.py` in the destination repo.
- Extension must expose command **Hello Python** that runs the `hello_python.py` script and creates `artifacts/hello_python.txt` in the destination repo.
- Scaffolding must create `hello_pwsh.ps1` in the destination repo.
- Extension must expose command **Hello PowerShell** that runs the `hello_pwsh.ps1` script and creates `artifacts/hello_pwsh.txt` in the destination repo.
- Commands must run without manual path edits in consuming workspaces.
- Errors for missing Python/PowerShell runtimes must be explicit.
- Cross-platform support for Windows/macOS/Linux with documented caveats.

**Mandatory unachievable objective callout**:
- **None identified.** The requirements are achievable with a standard VS Code extension scaffold and task provider approach.

## Recommended Approach

Create a minimal TypeScript-based VS Code extension scaffold in-repo (e.g., `extensions/scaffold-extension/`) with two user-facing commands and a lightweight scaffolding step.

1) **Scaffold templates**
  - Bundle `hello_python.py` and `hello_pwsh.ps1` under `resources/templates/`.
  - On first command invocation (or via a dedicated “Scaffold Hello Scripts” helper), copy these templates into the destination repo root using `vscode.workspace.fs`.
2) **Commands**
  - Register commands:
    - `scaffoldExtension.helloPython` → **Hello Python**
    - `scaffoldExtension.helloPowerShell` → **Hello PowerShell**
  - Each command:
    - Validates runtime availability (python/pwsh/powershell).
    - Ensures templates exist in the workspace (copy if missing).
    - Executes the workspace script (so the scaffolded file is the one that runs).
    - Creates `artifacts/hello_python.txt` or `artifacts/hello_pwsh.txt` in the workspace.
3) **Execution model**
  - Use `ProcessExecution` or `ShellExecution` with args to avoid quoting issues and ensure paths with spaces work reliably across platforms.
4) **README**
  - Document “Hello Python” and “Hello PowerShell” commands, and the expected artifacts output.

### Rationale

- Directly matches the new minimum viable requirements (scaffolded scripts + command execution + artifacts output).
- Running the copied workspace scripts ensures the scaffolded files are actually used.
- Uses only built-in Node.js + VS Code APIs; no new dependencies.

### Rejected alternatives (brief)

- **Running only extension-bundled scripts**: conflicts with the requirement that scaffolding creates scripts in the destination repo and implies those scripts should be used.
- **Templates-only with no commands**: fails explicit command requirements.

## Implementation Guidance

- **Objectives**: Build a minimal extension scaffold with commands, task provider, template copy, runtime detection, and README.
- **Key Tasks**:
  - Add `extensions/scaffold-extension/package.json` manifest with `contributes.commands`, `contributes.taskDefinitions`, and `activationEvents` (or rely on implicit command activation for modern VS Code).
  - Add `src/extension.ts` implementing command registration, runtime detection, task provider, and template copy handler.
  - Bundle template assets under `resources/templates/` and use `context.extensionUri` + `vscode.Uri.joinPath` for copy.
  - Provide sample utilities under `resources/scripts/` (Python/PowerShell/Bash) invoked by commands/tasks.
  - Add README with installation + first-run steps.
- **Dependencies**: Built-in `child_process`, `path`, `os` only; no new external npm deps unless future testing requires `@vscode/test-electron`.
- **Success Criteria**: Commands and tasks run for all three runtimes, template copy succeeds, and missing runtimes yield actionable errors; README covers first run.

### Proposed State Model (runtime + execution)

States: `Idle` → `CheckingRuntime` → (`RuntimeMissing` | `RuntimeAvailable`) → `RunningTask` → (`Succeeded` | `Failed`) → `Idle`

Transitions:
- `Idle` → `CheckingRuntime` on command invocation.
- `CheckingRuntime` → `RuntimeMissing` on detection failure (surface error, stop).
- `CheckingRuntime` → `RuntimeAvailable` on detection success.
- `RuntimeAvailable` → `RunningTask` when task execution begins.
- `RunningTask` → `Succeeded` or `Failed` on completion.

### Update/Reporting Strategy

- Use a dedicated `OutputChannel` to report status per command invocation.
- Surface user-facing errors with `vscode.window.showErrorMessage` and detailed logs in the OutputChannel.

### Pseudocode (command + execution flow)

```ts
const output = vscode.window.createOutputChannel('Scaffold Utils');

async function runHello(kind: 'python' | 'powershell') {
  output.appendLine(`[${kind}] Checking runtime...`);
  const runtime = await detectRuntime(kind);
  if (!runtime.found) {
    output.appendLine(`[${kind}] Missing runtime: ${runtime.message}`);
    vscode.window.showErrorMessage(runtime.message);
    return;
  }

  const workspaceRoot = getWorkspaceRootOrThrow();
  await ensureScaffoldedScripts(workspaceRoot); // copies hello_python.py + hello_pwsh.ps1

  const scriptPath = kind === 'python'
    ? path.join(workspaceRoot, 'hello_python.py')
    : path.join(workspaceRoot, 'hello_pwsh.ps1');

  output.appendLine(`[${kind}] Running ${path.basename(scriptPath)}...`);
  const task = buildTaskForScript(kind, runtime.path, scriptPath, workspaceRoot);
  const execution = await vscode.tasks.executeTask(task);

  const onEnd = vscode.tasks.onDidEndTaskProcess((e) => {
    if (e.execution === execution) {
      if (e.exitCode === 0) {
        output.appendLine(`[${kind}] Success.`);
      } else {
        output.appendLine(`[${kind}] Failed with exit code ${e.exitCode}.`);
      }
      onEnd.dispose();
    }
  });
}
```

### Implementation Hooks (target files/locations)

- Create new extension scaffold at `extensions/scaffold-extension/`:
  - `package.json`: manifest, `contributes.commands` for **Hello Python** and **Hello PowerShell**, `activationEvents`, `main`.
  - `src/extension.ts`: activate/deactivate, command registration, runtime detection, scaffold copy, task execution.
  - `resources/templates/hello_python.py` and `resources/templates/hello_pwsh.ps1`: scaffolded scripts.
  - `README.md`: install + first run (commands + artifacts output).

### Risks and Mitigations

- **Windows runtime naming**: PowerShell may be `pwsh` or `powershell`. Mitigate by probing both and reporting detected path.
- **Shell quoting differences**: Prefer `ProcessExecution` with args or `ShellExecution` with args array. Avoid single-line shell strings for paths with spaces.
- **Workspace missing**: Commands must guard against no workspace and surface actionable errors.

### Testing Implications (design-level)

- Unit tests for runtime detection helper (pure function, no external calls; inject a command-runner abstraction for stubbing).
- Unit tests for scaffold copy helper (uses mocked `workspace.fs` to avoid temp files).
- Unit tests for task creation (ensures correct command/args and cwd).
- Integration test concept: run Hello commands in extension host test, verify artifacts files appear in workspace without using temp files.
