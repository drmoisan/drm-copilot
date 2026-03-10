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
  readonly args?: ReadonlyArray<string>;
}

interface PlaceholderCommandSpec {
  readonly commandId: string;
  readonly title: string;
  readonly scriptReference: string;
}

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

function createOutputChannel(): vscode.OutputChannel {
  return vscode.window.createOutputChannel("drm-copilot");
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

function scoreBranchForPriority(branchName: string): number {
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

async function pickPrBaseBranch(
  output: vscode.OutputChannel,
  commandId: string,
  candidates: ReadonlyArray<string>,
  defaultBranch: string,
): Promise<string | undefined> {
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

export function deactivate(): void {
  // No-op.
}
