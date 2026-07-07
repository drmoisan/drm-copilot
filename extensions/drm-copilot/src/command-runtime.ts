import * as cp from "node:child_process";
import * as fs from "node:fs";
import * as path from "node:path";
import * as vscode from "vscode";

/**
 * Identifies which interpreter family is required to launch a bundled script.
 *
 * Only PowerShell remains: all formerly-interpreted commands run in-process in
 * TypeScript, so no interpreter is detected or spawned beyond PowerShell.
 */
export type RuntimeKind = "powershell";

/**
 * Describes the executable and fixed argument prefix needed to launch a script.
 */
export interface RuntimeResolution {
  readonly executable: string;
  readonly argsPrefix: ReadonlyArray<string>;
}

/**
 * Minimal output sink used by command adapters and the MCP bridge.
 */
export interface CommandOutput {
  appendLine(line: string): void;
}

/**
 * Defines the information needed to execute a bundled resource.
 */
export interface CommandSpec {
  readonly runtimeKind: RuntimeKind;
  readonly bundledRelativePath: string;
  readonly commandId: string;
  readonly args?: ReadonlyArray<string>;
}

/**
 * Defines the filesystem context required to execute a bundled resource.
 */
export interface BundledScriptExecutionSpec extends CommandSpec {
  readonly extensionRoot: string;
  readonly workspaceRoot: string;
}

/**
 * Describes the captured process output from a completed subprocess execution.
 */
export interface ProcessExecutionResult {
  readonly exitCode: number;
  readonly stdout: string;
  readonly stderr: string;
}

/**
 * Describes the completed execution of a bundled script.
 */
export interface BundledScriptExecutionResult extends ProcessExecutionResult {
  readonly executable: string;
  readonly args: ReadonlyArray<string>;
  readonly scriptPath: string;
  readonly workspaceRoot: string;
}

/**
 * Rich error raised when a spawned command exits non-zero.
 */
export class CommandExecutionError extends Error {
  readonly executable: string;
  readonly args: ReadonlyArray<string>;
  readonly cwd: string;
  readonly exitCode: number | null;
  readonly stdout: string;
  readonly stderr: string;

  constructor(input: {
    readonly executable: string;
    readonly args: ReadonlyArray<string>;
    readonly cwd: string;
    readonly exitCode: number | null;
    readonly stdout: string;
    readonly stderr: string;
  }) {
    super(`Command exited with code ${input.exitCode ?? "unknown"}.`);
    this.name = "CommandExecutionError";
    this.executable = input.executable;
    this.args = input.args;
    this.cwd = input.cwd;
    this.exitCode = input.exitCode;
    this.stdout = input.stdout;
    this.stderr = input.stderr;
  }
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
 * Creates an in-memory output sink for MCP and unit-test scenarios.
 *
 * @returns A writable sink plus the collected log lines.
 */
export function createBufferedOutput(): {
  readonly output: CommandOutput;
  readonly lines: string[];
} {
  const lines: string[] = [];
  return {
    output: {
      appendLine(line: string): void {
        lines.push(line);
      },
    },
    lines,
  };
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
 * Resolves the user-global Claude projects directory (`~/.claude/projects`).
 *
 * Claude Code writes session transcripts to a per-user global directory, not
 * inside the open workspace. Resolution order:
 * 1. `env.CLAUDE_CONFIG_DIR` when set (non-empty after trimming) — the
 *    directory's `projects` subfolder is used directly, mirroring Claude
 *    Code's own config-dir override.
 * 2. Otherwise the user's home directory (`env.HOME`, then
 *    `env.USERPROFILE`) plus `.claude/projects`.
 *
 * The `env` parameter defaults to `process.env` but accepts an injected
 * override so unit tests can resolve a fake root without depending on the
 * real `HOME`/`USERPROFILE`/`CLAUDE_CONFIG_DIR` values of the host running
 * the tests.
 *
 * @param env Environment variables to resolve from; defaults to `process.env`.
 * @returns The absolute, forward-slash-normalized path to the user-global
 *   Claude projects directory.
 * @throws Error when neither `CLAUDE_CONFIG_DIR` nor `HOME`/`USERPROFILE` is set.
 */
export function getClaudeProjectsRoot(
  env: NodeJS.ProcessEnv = process.env,
): string {
  const configDirOverride = env["CLAUDE_CONFIG_DIR"]?.trim();
  if (configDirOverride !== undefined && configDirOverride.length > 0) {
    return path.join(configDirOverride, "projects").replace(/\\/g, "/");
  }

  const home = env["HOME"]?.trim() || env["USERPROFILE"]?.trim();
  if (home === undefined || home.length === 0) {
    throw new Error(
      "Cannot resolve the user-global Claude projects directory: none of CLAUDE_CONFIG_DIR, HOME, or USERPROFILE is set.",
    );
  }

  return path.join(home, ".claude", "projects").replace(/\\/g, "/");
}

/**
 * Minimal terminal-writing seam used by host-bound commands that render
 * multi-line output to an integrated VS Code terminal rather than an
 * `OutputChannel`.
 *
 * Purpose:
 *     Let command handlers (e.g. `registerSubagentTreeCommand`) depend on an
 *     injectable interface instead of `vscode.window.createTerminal`
 *     directly, so unit tests can assert on captured terminal output without
 *     a live VS Code host, mirroring how the `FileSystem` seam is injected.
 */
export interface TerminalWriter {
  /**
   * Write `header` and `body` to the terminal, joined by `\r\n`. Replaces any
   * previously written content rather than appending to it.
   *
   * @param header A single header line describing the rendered content.
   * @param body The full rendered body to display beneath the header.
   */
  write(header: string, body: string): void;

  /** Reveal (focus) the underlying terminal. */
  reveal(): void;
}

/** Stable, recognizable name for the Subagent Tree integrated terminal. */
export const SUBAGENT_TREE_TERMINAL_NAME = "drm-copilot: Subagent Tree";

/**
 * `TerminalWriter` backed by a single reusable VS Code integrated terminal
 * whose content is driven by a `vscode.Pseudoterminal`.
 *
 * Purpose:
 *     Render output to a stably-named integrated terminal, reusing the same
 *     terminal instance across repeated command invocations instead of
 *     accumulating a new terminal per run. When the previously created
 *     terminal has exited (e.g. the user closed it), the next `write` call
 *     replaces it with a freshly created terminal of the same name.
 */
class PseudoterminalTerminalWriter implements TerminalWriter {
  private terminal: vscode.Terminal | undefined;
  private writeEmitter: vscode.EventEmitter<string> | undefined;
  private isOpen = false;
  private pendingContent = "";

  /** @inheritdoc */
  write(header: string, body: string): void {
    this.pendingContent = `${header}\r\n${body}`;

    const hasLiveTerminal =
      this.terminal !== undefined && this.terminal.exitStatus === undefined;
    if (hasLiveTerminal) {
      if (this.isOpen && this.writeEmitter !== undefined) {
        this.writeEmitter.fire(this.pendingContent);
      }
      return;
    }

    this.createTerminal();
  }

  /** @inheritdoc */
  reveal(): void {
    this.terminal?.show();
  }

  private createTerminal(): void {
    const writeEmitter = new vscode.EventEmitter<string>();
    this.writeEmitter = writeEmitter;
    this.isOpen = false;

    const pty: vscode.Pseudoterminal = {
      onDidWrite: writeEmitter.event,
      open: () => {
        this.isOpen = true;
        writeEmitter.fire(this.pendingContent);
      },
      close: () => {
        this.isOpen = false;
      },
    };

    this.terminal = vscode.window.createTerminal({
      name: SUBAGENT_TREE_TERMINAL_NAME,
      pty,
    });
  }
}

/**
 * Create the real `TerminalWriter` used by `registerSubagentTreeCommand`.
 *
 * @returns A `TerminalWriter` backed by a single reusable integrated
 *   terminal named `"drm-copilot: Subagent Tree"`.
 */
export function createSubagentTreeTerminalWriter(): TerminalWriter {
  return new PseudoterminalTerminalWriter();
}

/**
 * Determines whether an executable can be resolved from the current process PATH.
 *
 * @param executable The executable name to probe, without a file extension.
 * @returns True when a matching file exists in one of the PATH directories.
 * @remarks On Windows the lookup also tries each PATHEXT suffix to mirror shell resolution.
 */
function executableExists(executable: string): boolean {
  return findExecutableOnPath(executable) !== undefined;
}

function getPathExtensions(): ReadonlyArray<string> {
  return process.platform === "win32"
    ? (process.env["PATHEXT"] ?? ".COM;.EXE;.BAT;.CMD")
        .split(";")
        .filter((part) => part.length > 0)
    : [""];
}

function findExecutableOnPath(executable: string): string | undefined {
  const pathValue = process.env["PATH"] ?? "";
  const pathParts = pathValue
    .split(path.delimiter)
    .filter((part) => part.length > 0);
  const pathExtensions = getPathExtensions();

  // Probe each PATH directory against each allowed extension so runtime detection
  // behaves consistently across Windows and non-Windows environments.
  for (const directory of pathParts) {
    for (const extension of pathExtensions) {
      const candidate = path.join(
        directory,
        process.platform === "win32" ? `${executable}${extension}` : executable,
      );
      if (fs.existsSync(candidate)) {
        return candidate.replace(/\\/g, "/");
      }
    }
  }

  return undefined;
}

function normalizeExecutablePath(executablePath: string): string {
  return executablePath.replace(/\\/g, "/");
}

function buildCodexExecutableCandidates(
  extensionRoot: string,
): ReadonlyArray<string> {
  const normalizedRoot = normalizeExecutablePath(extensionRoot).replace(
    /\/+$/,
    "",
  );
  const pathExtensions = getPathExtensions();
  const relativeCandidates =
    process.platform === "win32"
      ? ["bin/windows-x86_64/codex", "bin/codex", "codex"]
      : ["bin/codex", "codex"];

  return relativeCandidates.flatMap((relativePath) =>
    pathExtensions.map(
      (extension) => `${normalizedRoot}/${relativePath}${extension}`,
    ),
  );
}

function findCodexInInstalledExtensionRoots(
  installedExtensionCandidateRoots: ReadonlyArray<string>,
): string | undefined {
  for (const extensionRoot of installedExtensionCandidateRoots) {
    const trimmedRoot = extensionRoot.trim();
    if (trimmedRoot.length === 0) {
      continue;
    }

    for (const candidate of buildCodexExecutableCandidates(trimmedRoot)) {
      if (fs.existsSync(candidate)) {
        return normalizeExecutablePath(candidate);
      }
    }
  }

  return undefined;
}

/**
 * Resolves the Codex CLI executable before a terminal is created.
 *
 * @param configuredExecutable Optional configured command name or executable path.
 * @returns The resolved command or path to invoke through PowerShell.
 * @throws Error when the configured executable or PATH fallback cannot be found.
 */
export function resolveCodexExecutable(
  configuredExecutable: string | undefined,
  installedExtensionCandidateRoots: ReadonlyArray<string> = [],
): string {
  const trimmedConfiguredExecutable = configuredExecutable?.trim() ?? "";
  if (trimmedConfiguredExecutable.length > 0) {
    const normalizedConfiguredExecutable = trimmedConfiguredExecutable.replace(
      /\\/g,
      "/",
    );
    const isPathLike = /[\\/]/.test(trimmedConfiguredExecutable);
    if (isPathLike) {
      if (fs.existsSync(trimmedConfiguredExecutable)) {
        return normalizedConfiguredExecutable;
      }

      throw new Error(
        "Codex CLI not found. Configure drmCopilotExtension.newCodexWorktreeSession.codexExecutablePath or install codex on PATH.",
      );
    }

    const resolvedConfiguredExecutable = findExecutableOnPath(
      trimmedConfiguredExecutable,
    );
    if (resolvedConfiguredExecutable !== undefined) {
      return resolvedConfiguredExecutable;
    }

    throw new Error(
      "Codex CLI not found. Configure drmCopilotExtension.newCodexWorktreeSession.codexExecutablePath or install codex on PATH.",
    );
  }

  const resolvedCodex = findExecutableOnPath("codex");
  if (resolvedCodex !== undefined) {
    return resolvedCodex;
  }

  const resolvedInstalledExtensionCodex = findCodexInInstalledExtensionRoots(
    installedExtensionCandidateRoots,
  );
  if (resolvedInstalledExtensionCodex !== undefined) {
    return resolvedInstalledExtensionCodex;
  }

  throw new Error(
    "Codex CLI not found. Configure drmCopilotExtension.newCodexWorktreeSession.codexExecutablePath or install codex on PATH.",
  );
}

/**
 * Resolves the PowerShell interpreter required to execute a bundled script.
 *
 * PowerShell is the only supported runtime: every formerly-Python command now
 * runs in-process in TypeScript, so this function resolves only PowerShell and
 * never probes a Python interpreter.
 *
 * @param runtimeKind The runtime family requested by the command (always
 *   `"powershell"`).
 * @returns The executable name and fixed argument prefix needed to launch the script.
 * @throws Error when neither `pwsh` nor `powershell` can be found on PATH.
 */
export function detectRuntime(runtimeKind: RuntimeKind): RuntimeResolution {
  // The parameter is retained so call sites remain explicit about the runtime
  // they request; only the PowerShell family is supported.
  void runtimeKind;

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
 * Builds the absolute path to a bundled script inside the installed extension package.
 *
 * @param extensionRoot The extension installation root.
 * @param bundledRelativePath The bundled resource path relative to the extension root.
 * @returns The resolved absolute path to the bundled resource.
 */
export function resolveBundledScriptPath(
  extensionRoot: string,
  bundledRelativePath: string,
): string {
  const normalizedExtensionRoot = extensionRoot.replace(/\\/g, "/");
  const normalizedBundledRelativePath = bundledRelativePath
    .replace(/\\/g, "/")
    .replace(/^\/+/, "");

  // Preserve Windows drive-prefixed roots as absolute paths even when the host
  // process uses POSIX path semantics, where `path.resolve` would otherwise
  // treat `C:/...` as a relative segment and prefix the checkout directory.
  if (/^[A-Za-z]:\//.test(normalizedExtensionRoot)) {
    return `${normalizedExtensionRoot.replace(/\/+$/, "")}/${normalizedBundledRelativePath}`;
  }

  return path.resolve(extensionRoot, bundledRelativePath).replace(/\\/g, "/");
}

/**
 * Executes a subprocess and streams its stdout/stderr into the output sink.
 *
 * @param output The output sink that should receive process diagnostics.
 * @param executable The executable to launch.
 * @param args The argv array passed to the executable.
 * @param cwd The working directory used for process execution.
 * @returns The aggregated stdout/stderr emitted by the child process.
 * @throws Error when process spawning fails or the command exits non-zero.
 */
export function runCommandWithOutput(
  output: CommandOutput,
  executable: string,
  args: ReadonlyArray<string>,
  cwd: string,
): Promise<ProcessExecutionResult> {
  return new Promise((resolve, reject) => {
    const stdoutChunks: string[] = [];
    const stderrChunks: string[] = [];
    const child = cp.spawn(executable, args, {
      cwd,
      stdio: ["ignore", "pipe", "pipe"],
      shell: false,
    });

    child.stdout.on("data", (chunk: Buffer) => {
      const text = chunk.toString("utf-8");
      stdoutChunks.push(text);
      const trimmed = text.trimEnd();
      if (trimmed.length > 0) {
        output.appendLine(trimmed);
      }
    });

    child.stderr.on("data", (chunk: Buffer) => {
      const text = chunk.toString("utf-8");
      stderrChunks.push(text);
      const trimmed = text.trimEnd();
      if (trimmed.length > 0) {
        output.appendLine(trimmed);
      }
    });

    child.on("error", (error: Error) => {
      reject(error);
    });

    child.on("close", (code: number | null) => {
      const stdout = stdoutChunks.join("");
      const stderr = stderrChunks.join("");
      if (code === 0) {
        resolve({
          exitCode: 0,
          stdout,
          stderr,
        });
        return;
      }

      reject(
        new CommandExecutionError({
          executable,
          args,
          cwd,
          exitCode: code,
          stdout,
          stderr,
        }),
      );
    });
  });
}

/**
 * Resolves a bundled script, selects its runtime, and executes it in the workspace.
 *
 * @param output The output sink used for command progress and diagnostics.
 * @param spec The command configuration describing the bundled script to execute.
 * @returns A promise that resolves when the bundled script exits successfully.
 * @throws Error when runtime detection fails or the spawned command exits non-zero.
 */
export async function executeBundledScriptFromExtensionRoot(
  output: CommandOutput,
  spec: BundledScriptExecutionSpec,
): Promise<BundledScriptExecutionResult> {
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
  const scriptPath = resolveBundledScriptPath(
    spec.extensionRoot,
    spec.bundledRelativePath,
  );
  output.appendLine(`[${spec.commandId}] resolved script path: ${scriptPath}`);

  const specScriptArgs = spec.args ?? [];
  const args = [...runtime.argsPrefix, scriptPath, ...specScriptArgs];
  output.appendLine(
    `[${spec.commandId}] command start: ${runtime.executable} ${args.join(" ")}`,
  );

  try {
    const processResult = await runCommandWithOutput(
      output,
      runtime.executable,
      args,
      spec.workspaceRoot,
    );
    output.appendLine(`[${spec.commandId}] command success`);
    return {
      ...processResult,
      executable: runtime.executable,
      args,
      scriptPath,
      workspaceRoot: spec.workspaceRoot,
    };
  } catch (error: unknown) {
    output.appendLine(`[${spec.commandId}] command failure`);
    throw error;
  }
}

/**
 * Resolves a bundled script and executes it against the active VS Code workspace.
 *
 * @param context The extension context that provides the extension installation URI.
 * @param output The output sink used for command progress and diagnostics.
 * @param spec The command configuration describing the bundled script to execute.
 * @returns A promise that resolves when the bundled script exits successfully.
 */
export function executeBundledScript(
  context: vscode.ExtensionContext,
  output: CommandOutput,
  spec: CommandSpec,
): Promise<BundledScriptExecutionResult> {
  return executeBundledScriptFromExtensionRoot(output, {
    ...spec,
    extensionRoot: context.extensionUri.fsPath,
    workspaceRoot: getWorkspaceRoot(),
  });
}

/**
 * Extracts a short stderr diagnostic snippet from a command-execution failure.
 *
 * @param error The thrown error to inspect.
 * @returns A trimmed stderr excerpt when available.
 */
export function getStderrExcerpt(error: unknown): string | undefined {
  if (!(error instanceof CommandExecutionError)) {
    return undefined;
  }

  const trimmed = error.stderr
    .split(/\r?\n/)
    .map((line) => line.trim())
    .filter((line) => line.length > 0)
    .slice(0, 8)
    .join("\n");

  return trimmed.length > 0 ? trimmed : undefined;
}
