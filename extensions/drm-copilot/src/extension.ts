import * as cp from "node:child_process";
import * as fs from "node:fs";
import * as path from "node:path";
import * as vscode from "vscode";

/**
 * Identifies which interpreter family is required to launch a bundled script.
 */
type RuntimeKind = "python" | "powershell";

/**
 * Describes the executable and fixed argument prefix needed to launch a script.
 */
interface RuntimeResolution {
  readonly executable: string;
  readonly argsPrefix: ReadonlyArray<string>;
}

/**
 * Defines the information needed to execute a bundled resource as a VS Code command.
 */
interface CommandSpec {
  readonly runtimeKind: RuntimeKind;
  readonly bundledRelativePath: string;
  readonly commandId: string;
  readonly args?: ReadonlyArray<string>;
}

/**
 * Defines a command that is intentionally registered as a placeholder.
 */
interface PlaceholderCommandSpec {
  readonly commandId: string;
  readonly title: string;
  readonly scriptReference: string;
}

/**
 * Captures the candidate base branches that a PR-context collection can use.
 */
interface BranchDiscoveryResult {
  readonly candidates: ReadonlyArray<string>;
  readonly defaultBranch: string;
}

const PLACEHOLDER_COMMAND_SPECS: ReadonlyArray<PlaceholderCommandSpec> = [
  {
    commandId: "drmCopilotExtension.newActiveFeatureFolderPlaceholder",
    title: "drm-copilot: New Active Feature Folder (Placeholder)",
    scriptReference: "scripts.dev_tools.new_active_feature_folder",
  },
  {
    commandId: "drmCopilotExtension.potentialToIssuePlaceholder",
    title: "drm-copilot: Potential To Issue (Placeholder)",
    scriptReference: "scripts.dev_tools.potential_to_issue",
  },
  {
    commandId: "drmCopilotExtension.newPotentialBugEntryPyPlaceholder",
    title: "drm-copilot: New Potential Bug Entry (Python Placeholder)",
    scriptReference: "scripts/dev_tools/new_potential_bug_entry.py",
  },
  {
    commandId: "drmCopilotExtension.newPotentialEntryPsPlaceholder",
    title: "drm-copilot: New Potential Entry (PowerShell Placeholder)",
    scriptReference: "scripts/dev-tools/new-potential-entry.ps1",
  },
];

/**
 * Creates the shared output channel used by the extension's command handlers.
 *
 * @returns A VS Code output channel that records command progress and failures.
 */
function createOutputChannel(): vscode.OutputChannel {
  return vscode.window.createOutputChannel("drm-copilot");
}

/**
 * Resolves the first open workspace folder as the working directory for commands.
 *
 * @returns The filesystem path for the primary workspace folder.
 * @throws Error when the extension is invoked without an open workspace.
 */
function getWorkspaceRoot(): string {
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
 * Runs a git command synchronously and returns trimmed stdout for follow-up parsing.
 *
 * @param output The output channel used for failure diagnostics.
 * @param commandId The logical command name associated with the git invocation.
 * @param cwd The repository root where git should run.
 * @param args The git argv array.
 * @param allowNonZeroExit Whether a non-zero exit should be tolerated.
 * @returns The trimmed stdout emitted by git.
 * @throws Error when git exits non-zero and the call does not allow that failure.
 */
function runGitForTextOutput(
  output: vscode.OutputChannel,
  commandId: string,
  cwd: string,
  args: ReadonlyArray<string>,
  allowNonZeroExit: boolean,
): string {
  const result = cp.spawnSync("git", args, {
    cwd,
    encoding: "utf-8",
    shell: false,
  });

  const status = result.status;
  if (!allowNonZeroExit && status !== 0) {
    const stderr = (result.stderr ?? "").trim();
    output.appendLine(
      `[${commandId}] git command failure: git ${args.join(" ")}`,
    );
    throw new Error(
      `Git command failed (${status ?? "unknown"}): ${stderr || "no stderr output"}`,
    );
  }

  return (result.stdout ?? "").trim();
}

/**
 * Scores a branch name so well-known long-lived branches sort ahead of others.
 *
 * @param branchName The branch name without the `origin/` prefix.
 * @returns A lower number for higher-priority default branch candidates.
 */
function scoreBranchForPriority(branchName: string): number {
  // Keep the priority list explicit so default-branch heuristics stay predictable
  // even when repositories expose many remote refs.
  if (branchName === "main") {
    return 0;
  }

  if (branchName === "master") {
    return 1;
  }

  if (branchName === "develop") {
    return 2;
  }

  if (branchName === "trunk") {
    return 3;
  }

  if (/^release([/.-]|$)/.test(branchName)) {
    return 4;
  }

  return 5;
}

/**
 * Orders remote branch candidates by branch priority and then alphabetically.
 *
 * @param candidates The remote refs returned from git.
 * @returns A new array sorted for quick-pick display and default selection.
 */
function sortRemoteBranchCandidates(
  candidates: ReadonlyArray<string>,
): string[] {
  return [...candidates].sort((left, right) => {
    const leftName = left.replace(/^origin\//, "");
    const rightName = right.replace(/^origin\//, "");
    const scoreDelta =
      scoreBranchForPriority(leftName) - scoreBranchForPriority(rightName);
    if (scoreDelta !== 0) {
      return scoreDelta;
    }

    return left.localeCompare(right);
  });
}

/**
 * Discovers the most suitable branch candidates for PR-context collection.
 *
 * @param output The output channel used for git failure diagnostics.
 * @param commandId The logical command name associated with discovery.
 * @param workspaceRoot The repository root where git commands should run.
 * @returns Candidate base branches and the branch that should be selected by default.
 * @throws Error when the repository exposes no usable local or remote branches.
 */
function discoverPrBaseBranches(
  output: vscode.OutputChannel,
  commandId: string,
  workspaceRoot: string,
): BranchDiscoveryResult {
  const originHead = runGitForTextOutput(
    output,
    commandId,
    workspaceRoot,
    ["symbolic-ref", "--quiet", "--short", "refs/remotes/origin/HEAD"],
    true,
  );

  // Prefer remote branches when available because PR context is typically based on
  // the branch layout tracked in `origin`, not on a contributor's local branches.
  const remoteRefLines = runGitForTextOutput(
    output,
    commandId,
    workspaceRoot,
    ["for-each-ref", "--format=%(refname:short)", "refs/remotes/origin"],
    false,
  )
    .split(/\r?\n/)
    .map((line) => line.trim())
    .filter((line) => line.length > 0)
    .filter((line) => line !== "origin/HEAD");

  const uniqueRemoteRefs = Array.from(new Set(remoteRefLines));
  const sortedRemoteRefs = sortRemoteBranchCandidates(uniqueRemoteRefs);

  if (sortedRemoteRefs.length > 0) {
    // Keep `origin/HEAD` first when it resolves to a listed ref so the quick pick
    // mirrors the repository's advertised default branch.
    if (originHead.length > 0 && sortedRemoteRefs.includes(originHead)) {
      const candidates = [
        originHead,
        ...sortedRemoteRefs.filter((item) => item !== originHead),
      ];
      return {
        candidates,
        defaultBranch: originHead,
      };
    }

    return {
      candidates: sortedRemoteRefs,
      defaultBranch: sortedRemoteRefs[0]!,
    };
  }

  // Fall back to local branches only when no remote refs exist, which keeps the
  // command usable in offline or minimally configured repositories.
  const localRefLines = runGitForTextOutput(
    output,
    commandId,
    workspaceRoot,
    ["for-each-ref", "--format=%(refname:short)", "refs/heads"],
    false,
  )
    .split(/\r?\n/)
    .map((line) => line.trim())
    .filter((line) => line.length > 0);

  const uniqueLocalRefs = Array.from(new Set(localRefLines)).sort(
    (left, right) => left.localeCompare(right),
  );

  if (uniqueLocalRefs.length === 0) {
    throw new Error("No branch candidates found in destination repository.");
  }

  return {
    candidates: uniqueLocalRefs,
    defaultBranch: uniqueLocalRefs[0]!,
  };
}

/**
 * Prompts the user to choose which branch should be treated as the PR base.
 *
 * @param output The output channel used for cancellation and selection logging.
 * @param commandId The logical command requesting the selection.
 * @param candidates The ordered candidate branches displayed to the user.
 * @param defaultBranch The branch labeled as the default suggestion.
 * @returns The chosen branch label, or `undefined` when the user cancels.
 */
async function pickPrBaseBranch(
  output: vscode.OutputChannel,
  commandId: string,
  candidates: ReadonlyArray<string>,
  defaultBranch: string,
): Promise<string | undefined> {
  // Mirror the sorted candidate list in the picker so the user sees the same
  // priority order the extension would otherwise use automatically.
  const quickPickItems = candidates.map((branch) => ({
    label: branch,
    description: branch === defaultBranch ? "default" : "",
  }));

  const selectedItem = await vscode.window.showQuickPick(quickPickItems, {
    title: "Select PR base branch",
    placeHolder: "Choose the base branch used for PR context collection",
    ignoreFocusOut: true,
  });

  if (!selectedItem) {
    output.appendLine(`[${commandId}] branch selection canceled by user`);
    return undefined;
  }

  output.appendLine(
    `[${commandId}] selected base branch: ${selectedItem.label}`,
  );
  return selectedItem.label;
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
async function executeBundledScript(
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

/**
 * Registers placeholder commands that intentionally fail with actionable errors.
 *
 * @param output The output channel used to record placeholder usage.
 * @returns Disposables for each registered placeholder command.
 */
function registerPlaceholderCommands(
  output: vscode.OutputChannel,
): vscode.Disposable[] {
  return PLACEHOLDER_COMMAND_SPECS.map((spec) =>
    vscode.commands.registerCommand(spec.commandId, async () => {
      const message = `Not implemented: ${spec.commandId} is a placeholder for ${spec.scriptReference}.`;
      output.appendLine(`[${spec.commandId}] ${message}`);
      throw new Error(message);
    }),
  );
}

/**
 * Activates the extension by registering all command handlers and shared resources.
 *
 * @param context The extension lifecycle context supplied by VS Code.
 * @returns Nothing.
 * @remarks Each command delegates to a small runtime/script launcher to keep the
 * activation path thin and predictable.
 */
export function activate(context: vscode.ExtensionContext): void {
  const output = createOutputChannel();

  const helloPythonDisposable = vscode.commands.registerCommand(
    "drmCopilotExtension.helloPython",
    async () => {
      await executeBundledScript(context, output, {
        runtimeKind: "python",
        bundledRelativePath: "resources/templates/hello_python.py",
        commandId: "drmCopilotExtension.helloPython",
      });
    },
  );

  const helloPowerShellDisposable = vscode.commands.registerCommand(
    "drmCopilotExtension.helloPowerShell",
    async () => {
      await executeBundledScript(context, output, {
        runtimeKind: "powershell",
        bundledRelativePath: "resources/templates/hello_pwsh.ps1",
        commandId: "drmCopilotExtension.helloPowerShell",
      });
    },
  );

  const collectCommitContextDisposable = vscode.commands.registerCommand(
    "drmCopilotExtension.collectCommitContext",
    async () => {
      await executeBundledScript(context, output, {
        runtimeKind: "python",
        bundledRelativePath: "resources/templates/collect_commit_context.py",
        commandId: "drmCopilotExtension.collectCommitContext",
        args: ["--output", "artifacts/commit_context.txt"],
      });
    },
  );

  const collectPrContextDisposable = vscode.commands.registerCommand(
    "drmCopilotExtension.collectPrContext",
    async () => {
      const commandId = "drmCopilotExtension.collectPrContext";
      const workspaceRoot = getWorkspaceRoot();
      output.appendLine(`[${commandId}] branch discovery start`);

      let discoveryResult: BranchDiscoveryResult;
      try {
        discoveryResult = discoverPrBaseBranches(
          output,
          commandId,
          workspaceRoot,
        );
      } catch (error: unknown) {
        output.appendLine(`[${commandId}] branch discovery failure`);
        throw error;
      }

      output.appendLine(
        `[${commandId}] branch discovery success: ${discoveryResult.candidates.join(", ")}`,
      );

      // Require an explicit branch confirmation so PR-context collection reflects
      // the user's intended comparison target instead of silently guessing.
      const selectedBase = await pickPrBaseBranch(
        output,
        commandId,
        discoveryResult.candidates,
        discoveryResult.defaultBranch,
      );
      if (!selectedBase) {
        return;
      }

      await executeBundledScript(context, output, {
        runtimeKind: "python",
        bundledRelativePath: "resources/templates/collect_pr_context.py",
        commandId,
        args: [
          "--base",
          selectedBase,
          "--repo-root",
          workspaceRoot,
          "--out",
          "artifacts/pr_context.summary.txt",
          "--appendix-out",
          "artifacts/pr_context.appendix.txt",
        ],
      });
    },
  );

  const placeholderDisposables = registerPlaceholderCommands(output);

  context.subscriptions.push(
    helloPythonDisposable,
    helloPowerShellDisposable,
    collectCommitContextDisposable,
    collectPrContextDisposable,
    ...placeholderDisposables,
    output,
  );
}

/**
 * Deactivates the extension.
 *
 * @returns Nothing.
 */
export function deactivate(): void {
  // No-op.
}
