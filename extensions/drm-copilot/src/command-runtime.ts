import * as cp from "node:child_process";
import * as fs from "node:fs";
import * as path from "node:path";
import * as vscode from "vscode";

/**
 * Identifies which interpreter family is required to launch a bundled script.
 */
export type RuntimeKind = "python" | "powershell";

/**
 * Describes the executable and fixed argument prefix needed to launch a script.
 */
export interface RuntimeResolution {
  readonly executable: string;
  readonly argsPrefix: ReadonlyArray<string>;
}

/**
 * Defines the information needed to execute a bundled resource as a VS Code command.
 */
export interface CommandSpec {
  readonly runtimeKind: RuntimeKind;
  readonly bundledRelativePath: string;
  readonly commandId: string;
  readonly args?: ReadonlyArray<string>;
}

/**
 * Creates the shared output channel used by the extension's command handlers.
 *
 * @returns A VS Code output channel that records command progress and failures.
 */
export function createOutputChannel(): vscode.OutputChannel {
  return vscode.window.createOutputChannel("drm-copilot");
}

/**
 * Resolves the first open workspace folder as the working directory for commands.
 *
 * @returns The filesystem path for the primary workspace folder.
 * @throws Error when the extension is invoked without an open workspace.
 */
export function getWorkspaceRoot(): string {
  const folder = vscode.workspace.workspaceFolders?.[0];
  if (!folder) {
    throw new Error("No workspace folder is open.");
  }

  return folder.uri.fsPath;
}

/**
 * Determines whether an executable can be resolved from the current process PATH.
 *
 * @param executable The executable name to probe, without a file extension.
 * @returns True when a matching file exists in one of the PATH directories.
 * @remarks On Windows the lookup also tries each PATHEXT suffix to mirror shell resolution.
 */
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

  // Probe each PATH directory against each allowed extension so runtime detection
  // behaves consistently across Windows and non-Windows environments.
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

/**
 * Resolves the interpreter required to execute a bundled script.
 *
 * @param runtimeKind The runtime family requested by the command.
 * @returns The executable name and fixed argument prefix needed to launch the script.
 * @throws Error when the required runtime cannot be found on PATH.
 */
export function detectRuntime(runtimeKind: RuntimeKind): RuntimeResolution {
  // Python commands have a single acceptable runtime, so fail fast with a
  // targeted error message instead of falling through the PowerShell probes.
  if (runtimeKind === "python") {
    if (!executableExists("python")) {
      throw new Error("Python runtime 'python' not found on PATH.");
    }

    return {
      executable: "python",
      argsPrefix: [],
    };
  }

  // Prefer PowerShell Core when available, then fall back to Windows PowerShell
  // so the extension works across newer and older developer environments.
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

/**
 * Executes a subprocess and streams its stdout/stderr into the output channel.
 *
 * @param output The output channel that should receive process diagnostics.
 * @param executable The executable to launch.
 * @param args The argv array passed to the executable.
 * @param cwd The working directory used for process execution.
 * @returns A promise that resolves on exit code 0 and rejects otherwise.
 * @throws Error when process spawning fails or the command exits non-zero.
 */
export function runCommandWithOutput(
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
      // Treat any non-zero exit as a command failure so the command surface keeps
      // the original process status visible to users and tests.
      if (code === 0) {
        resolve();
        return;
      }

      reject(new Error(`Command exited with code ${code ?? "unknown"}.`));
    });
  });
}

/**
 * Resolves a bundled script, selects its runtime, and executes it in the workspace.
 *
 * @param context The extension context that provides the extension installation URI.
 * @param output The output channel used for command progress and diagnostics.
 * @param spec The command configuration describing the bundled script to execute.
 * @returns A promise that resolves when the bundled script exits successfully.
 * @throws Error when runtime detection fails or the spawned command exits non-zero.
 */
export async function executeBundledScript(
  context: vscode.ExtensionContext,
  output: vscode.OutputChannel,
  spec: CommandSpec,
): Promise<void> {
  const workspaceRoot = getWorkspaceRoot();
  output.appendLine(`[${spec.commandId}] runtime probe start`);
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

  // Resolve scripts relative to the installed extension so commands always use the
  // bundled resources rather than depending on workspace copies.
  const scriptPath = vscode.Uri.joinPath(
    context.extensionUri,
    spec.bundledRelativePath,
  ).fsPath;
  output.appendLine(`[${spec.commandId}] resolved script path: ${scriptPath}`);

  const specScriptArgs = spec.args ?? [];
  const args = [...runtime.argsPrefix, scriptPath, ...specScriptArgs];
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
