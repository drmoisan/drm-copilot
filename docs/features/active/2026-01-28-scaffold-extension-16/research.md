<!-- markdownlint-disable-file -->

# Task Research Notes: scaffold-extension extension-side execution implementation

## Research Executed

### File Analysis

- c:\Users\DanMoisan\repos\drm-copilot\docs\features\active\2026-01-28-scaffold-extension-16\spec.md
  - Confirms the required target architecture: scripts execute from extension resources, artifacts are written to destination workspace, and hello scripts must never be copied to workspace root.
- c:\Users\DanMoisan\repos\drm-copilot\docs\features\active\2026-01-28-scaffold-extension-16\user-story.md
  - Defines the user-facing contract and acceptance criteria for self-contained extension behavior and no-copy invariants.
- c:\Users\DanMoisan\repos\drm-copilot\docs\features\active\2026-01-28-scaffold-extension-16\research.md
  - Contains earlier strategy notes that still describe template-copy behavior; this is superseded by current spec/user-story requirements.
- c:\Users\DanMoisan\repos\drm-copilot\package.json
  - Shows the repository already has TypeScript/Jest/ESLint/Prettier tooling and `@types/vscode`, providing a baseline to host extension code and tests.
- c:\Users\DanMoisan\repos\drm-copilot\src\hello-typescript.ts
  - Indicates no existing extension entrypoint or runtime orchestration code; extension scaffold must be added.

### Code Search Results

- extension scaffold / extension entry search (`src/extension.ts`, `contributes.commands`, `extensionUri`)
  - No existing in-repo extension implementation found; behavior must be introduced from scratch.
- bundled-resource execution patterns (`resolveBundledScriptPath`, `executeBundledScriptInWorkspace`)
  - No existing helper implementations found.
- repo command/test tooling (`package.json` scripts, TypeScript/Jest config)
  - Confirmed development/test toolchain exists and can support extension implementation and verification.

### External Research

- #githubRepo:"microsoft/vscode-extension-samples helloworld-sample command registration"
  - Baseline sample confirms extension structure (`package.json` manifest + `src/extension.ts`) and command registration flow.
- #fetch:https://code.visualstudio.com/api/get-started/extension-anatomy
  - Confirms required extension structure, activation model, and command contribution/registration baseline.
- #fetch:https://code.visualstudio.com/api/references/extension-manifest
  - Confirms manifest requirements: `engines.vscode`, `main`, `contributes.commands`, optional `activationEvents` depending on minimum supported VS Code.
- #fetch:https://code.visualstudio.com/api/extension-guides/command
  - Confirms `commands.registerCommand` and user-facing command contribution patterns.
- #fetch:https://code.visualstudio.com/api/references/vscode-api
  - Confirms APIs needed for this design: `ExtensionContext.extensionUri`, `Uri.joinPath`, `window.createOutputChannel`, `workspace.workspaceFolders`, and task/process abstractions.
- #fetch:https://github.com/microsoft/vscode-extension-samples/tree/main/helloworld-sample
  - Confirms practical scaffold layout and build/test loops for a TypeScript extension.

### Project Conventions

- Standards referenced: `.github/instructions/general-code-change.instructions.md`, `.github/instructions/general-unit-test.instructions.md`.
- Instructions followed: self-contained extension behavior from current `spec.md` and `user-story.md` takes precedence over older research notes.

## Key Discoveries

### Project Structure

The workspace has TypeScript and test tooling but no existing extension runtime implementation. This is a greenfield extension implementation inside the existing monorepo layout.

### Implementation Patterns

The required pattern is now explicit and stable:

- Resolve workspace context from `vscode.workspace.workspaceFolders`.
- Resolve script file paths from extension resources via `context.extensionUri` + `vscode.Uri.joinPath`.
- Execute bundled scripts via subprocess with destination workspace as execution context (`cwd`).
- Write artifacts to destination workspace only (for example: `<workspace>/artifacts/hello_python.txt`).
- Never copy `hello_python.py` / `hello_pwsh.ps1` into destination workspace root.

### Complete Examples

```ts
import * as cp from 'node:child_process';
import * as vscode from 'vscode';

type RuntimeKind = 'python' | 'powershell';

interface RuntimeResolution {
  executable: string;
  argsPrefix: string[];
}

export function activate(context: vscode.ExtensionContext): void {
  const output = vscode.window.createOutputChannel('Scaffold Utils');

  const helloPython = vscode.commands.registerCommand(
    'drmCopilotExtension.helloPython',
    async () => {
      await runBundledScriptCommand({
        context,
        output,
        runtimeKind: 'python',
        bundledRelativePath: 'resources/templates/hello_python.py',
      });
    }
  );

  const helloPowerShell = vscode.commands.registerCommand(
    'drmCopilotExtension.helloPowerShell',
    async () => {
      await runBundledScriptCommand({
        context,
        output,
        runtimeKind: 'powershell',
        bundledRelativePath: 'resources/templates/hello_pwsh.ps1',
      });
    }
  );

  context.subscriptions.push(output, helloPython, helloPowerShell);
}

async function runBundledScriptCommand(input: {
  context: vscode.ExtensionContext;
  output: vscode.OutputChannel;
  runtimeKind: RuntimeKind;
  bundledRelativePath: string;
}): Promise<void> {
  const workspaceRoot = requireWorkspaceRoot();
  const runtime = await resolveRuntime(input.runtimeKind);

  const scriptUri = vscode.Uri.joinPath(
    input.context.extensionUri,
    input.bundledRelativePath
  );

  input.output.appendLine(`Running ${scriptUri.fsPath} in ${workspaceRoot.fsPath}`);

  await execProcess(runtime.executable, [...runtime.argsPrefix, scriptUri.fsPath], {
    cwd: workspaceRoot.fsPath,
  });
}

function requireWorkspaceRoot(): vscode.Uri {
  const folder = vscode.workspace.workspaceFolders?.[0];
  if (!folder) {
    throw new Error('No workspace is open. Open a folder and rerun the command.');
  }
  return folder.uri;
}

async function resolveRuntime(kind: RuntimeKind): Promise<RuntimeResolution> {
  if (kind === 'python') {
    return { executable: 'python', argsPrefix: [] };
  }

  // Prefer pwsh first; fallback to powershell if needed.
  return { executable: 'pwsh', argsPrefix: ['-NoProfile', '-File'] };
}

function execProcess(
  executable: string,
  args: string[],
  options: cp.SpawnOptions
): Promise<void> {
  return new Promise((resolve, reject) => {
    const child = cp.spawn(executable, args, {
      ...options,
      stdio: 'pipe',
    });

    child.on('error', reject);
    child.on('close', (code) => {
      if (code === 0) {
        resolve();
      } else {
        reject(new Error(`Process exited with code ${code ?? -1}`));
      }
    });
  });
}
```

### API and Schema Documentation

- `commands.registerCommand` + `contributes.commands` are the canonical user-facing command path.
- `ExtensionContext.extensionUri` and `Uri.joinPath` are the canonical way to locate packaged resources.
- `window.createOutputChannel` is the canonical pattern for traceable command diagnostics.
- `workspace.workspaceFolders` provides destination workspace resolution.
- `child_process.spawn` with explicit args is the safest cross-platform process invocation pattern for file paths with spaces.

### Configuration Examples

```json
{
  "name": "scaffold-extension",
  "displayName": "Scaffold Extension",
  "version": "0.0.1",
  "publisher": "drm-copilot",
  "engines": {
    "vscode": "^1.100.0"
  },
  "main": "./out/extension.js",
  "contributes": {
    "commands": [
      {
        "command": "drmCopilotExtension.helloPython",
        "title": "Hello Python"
      },
      {
        "command": "drmCopilotExtension.helloPowerShell",
        "title": "Hello PowerShell"
      }
    ]
  },
  "scripts": {
    "compile": "tsc -p ./",
    "watch": "tsc -watch -p ./",
    "test": "jest"
  }
}
```

### Technical Requirements

- Extension must be self-contained for script assets (`hello_python.py`, `hello_pwsh.ps1`).
- Commands must execute bundled scripts directly from extension resources.
- Artifacts must be created in destination workspace (`artifacts/hello_python.txt`, `artifacts/hello_pwsh.txt`).
- No bundled hello script files may be copied into workspace root.
- Missing workspace and missing runtime errors must be explicit, actionable, and logged.
- Behavior must run on Windows/macOS/Linux with runtime probing (`python`, `pwsh` then `powershell`).
- Test strategy must verify both positive behavior and no-copy invariant.

**Mandatory unachievable objective callout**:
- **None identified.** The self-contained execution model is achievable with standard VS Code extension APIs and Node subprocess primitives.

## Recommended Approach

Implement a command-only, extension-side execution architecture (no workspace script materialization) with three concrete layers:

1. **Command/UX Layer**
   - Register `drmCopilotExtension.helloPython` and `drmCopilotExtension.helloPowerShell`.
   - Validate workspace presence before any runtime or script execution.
   - Emit start/success/failure telemetry to a dedicated OutputChannel.

2. **Execution Orchestration Layer**
   - Resolve runtime executable (`python`; `pwsh` with fallback to `powershell`).
   - Resolve script paths from extension resources with `context.extensionUri` + `Uri.joinPath`.
   - Execute scripts through subprocess with `cwd` set to destination workspace root.
   - Ensure process errors and non-zero exits are surfaced as actionable user errors.

3. **Script Contract Layer**
   - Bundled scripts are responsible for creating `artifacts/*` under current working directory.
   - Scripts must avoid assumptions about local source tree layout in destination workspace.
   - Scripts should produce deterministic, testable output markers.

Why this is optimal:
- Fully matches current `spec.md`/`user-story.md` no-copy requirement.
- Keeps destination workspaces clean and independent from extension internals.
- Provides the reusable production pattern the feature is intended to teach.

Rejected alternatives (brief, non-exhaustive):
- **Copying scripts into workspace root before execution**: rejected because it directly violates current acceptance criteria and no-copy invariants.
- **Task-provider-first execution model for MVP**: rejected because it adds complexity without improving the core self-contained command flow.

## Implementation Guidance

- **Objectives**: Deliver a minimal VS Code extension that runs bundled hello scripts extension-side and writes only artifacts into destination workspace.
- **Key Tasks**:
  - Scaffold extension under `extensions/scaffold-extension/` with manifest and TypeScript entrypoint.
  - Add bundled scripts under `resources/templates/hello_python.py` and `resources/templates/hello_pwsh.ps1`.
  - Implement runtime probe helpers and bundled script path resolver.
  - Implement subprocess execution helper with explicit args and workspace `cwd`.
  - Add error handling + OutputChannel logging paths.
  - Add tests for command registration, runtime detection, script path resolution, subprocess success/failure, and no-copy invariant.
  - Update README with architecture explanation and first-run validation.
- **Dependencies**: Use existing repo TypeScript/Jest toolchain and Node built-ins (`child_process`, `path`, `fs`) plus VS Code API; no new runtime dependency is required.
- **Success Criteria**:
  - Both commands run bundled scripts and generate artifacts in workspace.
  - Missing workspace/runtime produces clear actionable error.
  - Tests confirm no `hello_python.py`/`hello_pwsh.ps1` is copied into workspace root.
  - Final implementation behavior matches `spec.md` and `user-story.md` exactly.