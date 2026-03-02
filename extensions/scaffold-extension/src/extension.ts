import * as cp from "node:child_process";
import * as fs from "node:fs";
import * as path from "node:path";
import * as vscode from "vscode";

type RuntimeKind = "python" | "powershell";

interface RuntimeResolution {
  readonly executable: string;
  readonly argsPrefix: ReadonlyArray<string>;
}

interface CommandSpec {
  readonly runtimeKind: RuntimeKind;
  readonly bundledRelativePath: string;
  readonly commandId: string;
}

function createOutputChannel(): vscode.OutputChannel {
  return vscode.window.createOutputChannel("Scaffold Utils");
}

function getWorkspaceRoot(): string {
  const folder = vscode.workspace.workspaceFolders?.[0];
  if (!folder) {
    throw new Error("No workspace folder is open.");
  }

  return folder.uri.fsPath;
}

function executableExists(executable: string): boolean {
  const pathValue = process.env["PATH"] ?? "";
  const pathParts = pathValue
    .split(path.delimiter)
    .filter((part) => part.length > 0);
  const pathExtensions =
    process.platform === "win32"
      ? (process.env["PATHEXT"] ?? ".COM;.EXE;.BAT;.CMD")
          .split(";")
          .filter((part) => part.length > 0)
      : [""];

  for (const directory of pathParts) {
    for (const extension of pathExtensions) {
      const candidate = path.join(
        directory,
        process.platform === "win32" ? `${executable}${extension}` : executable,
      );
      if (fs.existsSync(candidate)) {
        return true;
      }
    }
  }

  return false;
}

export function detectRuntime(runtimeKind: RuntimeKind): RuntimeResolution {
  if (runtimeKind === "python") {
    if (!executableExists("python")) {
      throw new Error("Python runtime 'python' not found on PATH.");
    }

    return {
      executable: "python",
      argsPrefix: [],
    };
  }

  if (executableExists("pwsh")) {
    return {
      executable: "pwsh",
      argsPrefix: [
        "-NoLogo",
        "-NoProfile",
        "-ExecutionPolicy",
        "Bypass",
        "-File",
      ],
    };
  }

  if (executableExists("powershell")) {
    return {
      executable: "powershell",
      argsPrefix: [
        "-NoLogo",
        "-NoProfile",
        "-ExecutionPolicy",
        "Bypass",
        "-File",
      ],
    };
  }

  throw new Error(
    "PowerShell runtime not found. Expected 'pwsh' or 'powershell' on PATH.",
  );
}

function runCommandWithOutput(
  output: vscode.OutputChannel,
  executable: string,
  args: ReadonlyArray<string>,
  cwd: string,
): Promise<void> {
  return new Promise((resolve, reject) => {
    const child = cp.spawn(executable, args, {
      cwd,
      stdio: ["ignore", "pipe", "pipe"],
      shell: false,
    });

    child.stdout.on("data", (chunk: Buffer) => {
      output.appendLine(chunk.toString("utf-8").trimEnd());
    });

    child.stderr.on("data", (chunk: Buffer) => {
      output.appendLine(chunk.toString("utf-8").trimEnd());
    });

    child.on("error", (error: Error) => {
      reject(error);
    });

    child.on("close", (code: number | null) => {
      if (code === 0) {
        resolve();
        return;
      }

      reject(new Error(`Command exited with code ${code ?? "unknown"}.`));
    });
  });
}

async function executeBundledScript(
  context: vscode.ExtensionContext,
  output: vscode.OutputChannel,
  spec: CommandSpec,
): Promise<void> {
  output.appendLine(`[${spec.commandId}] runtime probe start`);
  const workspaceRoot = getWorkspaceRoot();
  let runtime: RuntimeResolution;
  try {
    runtime = detectRuntime(spec.runtimeKind);
  } catch (error: unknown) {
    output.appendLine(`[${spec.commandId}] runtime probe failure`);
    throw error;
  }

  output.appendLine(
    `[${spec.commandId}] runtime probe success: ${runtime.executable}`,
  );

  const scriptPath = vscode.Uri.joinPath(
    context.extensionUri,
    spec.bundledRelativePath,
  ).fsPath;
  output.appendLine(`[${spec.commandId}] resolved script path: ${scriptPath}`);

  const args = [...runtime.argsPrefix, scriptPath];
  output.appendLine(
    `[${spec.commandId}] command start: ${runtime.executable} ${args.join(" ")}`,
  );

  try {
    await runCommandWithOutput(output, runtime.executable, args, workspaceRoot);
    output.appendLine(`[${spec.commandId}] command success`);
  } catch (error: unknown) {
    output.appendLine(`[${spec.commandId}] command failure`);
    throw error;
  }
}

export function activate(context: vscode.ExtensionContext): void {
  const output = createOutputChannel();

  const helloPythonDisposable = vscode.commands.registerCommand(
    "scaffoldExtension.helloPython",
    async () => {
      await executeBundledScript(context, output, {
        runtimeKind: "python",
        bundledRelativePath: "resources/templates/hello_python.py",
        commandId: "scaffoldExtension.helloPython",
      });
    },
  );

  const helloPowerShellDisposable = vscode.commands.registerCommand(
    "scaffoldExtension.helloPowerShell",
    async () => {
      await executeBundledScript(context, output, {
        runtimeKind: "powershell",
        bundledRelativePath: "resources/templates/hello_pwsh.ps1",
        commandId: "scaffoldExtension.helloPowerShell",
      });
    },
  );

  context.subscriptions.push(
    helloPythonDisposable,
    helloPowerShellDisposable,
    output,
  );
}

export function deactivate(): void {
  // No-op.
}
