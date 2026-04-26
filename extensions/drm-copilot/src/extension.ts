import * as fs from "node:fs";
import * as path from "node:path";
import * as vscode from "vscode";
import {
  buildBranchName,
  buildWorktreePath,
  buildWorktreeSessionCommands,
  formatWorktreeTimestamp,
} from "./claude-worktree-session";
import {
  createOutputChannel,
  detectRuntime,
  executeBundledScript,
  getWorkspaceRoot,
} from "./command-runtime";
import { registerDocumentWorkflowCommands } from "./document-workflow-commands";
import {
  promptForChoice,
  promptForShortName,
  promptForWorkspaceScanFolders,
  resolveWorkflowInvocation,
} from "./extension-command-helpers";
import { registerMcpProvider } from "./mcp-provider";
import { registerPoshQcCommands } from "./poshqc-command-registration";
import { createRepoAutomationService } from "./repo-automation-service";
import { registerRepoAutomationCommands } from "./repo-automation-command-registration";
import { resolveRunPoshQCSuiteInvocation } from "./workflow-command-arguments";

// Re-export detectRuntime so existing test imports from this module keep working.
export { detectRuntime };

/**
 * Grace period (milliseconds) between sending the pre-claude commands
 * (`git worktree add`, `Set-Location`, optional venv activate) and the final
 * `claude` invocation. VS Code's Python extension auto-injects venv
 * activation via terminal.sendText after a short asynchronous delay; this
 * constant must be long enough that any such injection lands while the host
 * shell is still at its prompt and is consumed normally, otherwise the
 * injected text gets buffered into claude's TUI input.
 */
const TERMINAL_AUTO_ACTIVATION_GRACE_MS = 5000;

/**
 * Detects whether the workspace's `pyproject.toml` declares poetry as the
 * dependency-management tool, signalling that the worktree should run
 * `poetry install --with dev` and activate the resulting in-project venv
 * before starting Claude.
 *
 * @param workspaceRoot The absolute path of the source repository.
 * @returns `true` when a `pyproject.toml` exists at the workspace root and
 *          the literal substring "poetry" appears anywhere in the file.
 */
function pyprojectHasPoetry(workspaceRoot: string): boolean {
  const normalizedRoot = workspaceRoot.replace(/\\/g, "/").replace(/\/+$/, "");
  const pyprojectPath = `${normalizedRoot}/pyproject.toml`;
  if (!fs.existsSync(pyprojectPath)) {
    return false;
  }

  const contents = fs.readFileSync(pyprojectPath, "utf-8");
  return contents.includes("poetry");
}

/**
 * Activates the extension by registering all command handlers and shared resources.
 *
 * @param context The extension lifecycle context supplied by VS Code.
 * @returns Nothing.
 */
export function activate(context: vscode.ExtensionContext): void {
  const output = createOutputChannel();
  const service = createRepoAutomationService({
    extensionRoot: context.extensionUri.fsPath,
    output,
  });

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

  const repoAutomationDisposables = registerRepoAutomationCommands({
    context,
    output,
    service,
  });

  const newClaudeWorktreeSessionDisposable = vscode.commands.registerCommand(
    "drmCopilotExtension.newClaudeWorktreeSession",
    async () => {
      const commandId = "drmCopilotExtension.newClaudeWorktreeSession";

      const shortName = await promptForShortName(
        "drm-copilot: New Claude Worktree Session",
        "Enter a kebab-case short name for the worktree and branch.",
      );
      if (!shortName) {
        return;
      }

      const objective = await vscode.window.showInputBox({
        title: "drm-copilot: New Claude Worktree Session",
        prompt:
          "Enter the objective to pass to claude as a prompt. Leave blank to skip.",
        ignoreFocusOut: true,
      });
      if (objective === undefined) {
        return;
      }

      // Resolve the PowerShell runtime first so a missing host fails fast with
      // the established error message rather than after creating a terminal.
      const runtime = detectRuntime("powershell");
      const workspaceRoot = getWorkspaceRoot();
      const workspaceParent = path.dirname(workspaceRoot);
      const timestamp = formatWorktreeTimestamp(new Date());
      const worktreePath = buildWorktreePath(
        workspaceParent,
        timestamp,
        shortName,
      );
      const branchName = buildBranchName(timestamp, shortName);
      const usePoetry = pyprojectHasPoetry(workspaceRoot);
      const commands = buildWorktreeSessionCommands({
        repoRoot: workspaceRoot,
        worktreePath,
        branchName,
        usePoetry,
        objective,
      });

      // The terminal must start inside the source repository so that
      // `git worktree add` can locate `.git`. The new worktree itself is
      // created at worktreePath (which lives under workspaceParent) by the
      // command sent to the terminal.
      const terminal = vscode.window.createTerminal({
        name: `Claude: ${branchName}`,
        cwd: workspaceRoot,
        shellPath: runtime.executable,
        shellArgs: ["-NoLogo"],
      });
      terminal.show();

      // Send the pre-claude commands as separate sendText calls so each is
      // processed at its own PowerShell prompt: git worktree add, then
      // Set-Location into the new worktree, then (when the workspace uses
      // poetry) install dependencies and activate the resulting venv.
      // PowerShell's stdin is line-buffered, so queued lines are read one at
      // a time once each prior command finishes.
      terminal.sendText(commands.git, true);
      terminal.sendText(commands.setLocation, true);
      if (commands.poetryInstall !== undefined) {
        terminal.sendText(commands.poetryInstall, true);
      }
      if (commands.activate !== undefined) {
        terminal.sendText(commands.activate, true);
      }

      // Defer the final claude command. VS Code's Python extension auto-
      // injects its own venv activation via a deferred terminal.sendText.
      // If we start claude before that injection arrives, claude takes over
      // stdin and the injected text is buffered into claude's TUI prompt.
      // The grace window lets any such injection land at the host shell's
      // prompt and be consumed normally before claude takes over.
      setTimeout(() => {
        terminal.sendText(commands.claude, true);
      }, TERMINAL_AUTO_ACTIVATION_GRACE_MS);

      // Log only the objective length so the channel record is useful for
      // diagnostics without recording potentially sensitive prompt text.
      const objectiveLength = objective.trim().length;
      const poetryNote = usePoetry
        ? "with poetry install and activation"
        : "no poetry";
      output.appendLine(
        `[${commandId}] opened terminal for branch ${branchName} at ${worktreePath} (objective length: ${objectiveLength}, ${poetryNote}); claude send deferred by ${TERMINAL_AUTO_ACTIVATION_GRACE_MS}ms`,
      );
    },
  );

  const runPoshQCSuiteDisposable = vscode.commands.registerCommand(
    "drmCopilotExtension.runPoshQCSuite",
    async (...rawArgs: unknown[]) => {
      const commandId = "drmCopilotExtension.runPoshQCSuite";
      const invocation = resolveWorkflowInvocation(output, commandId, () =>
        resolveRunPoshQCSuiteInvocation(rawArgs),
      );
      const workspaceRoot = getWorkspaceRoot();
      if (invocation.mode === "direct") {
        await service.runPoshQCSuite({
          workspaceRoot,
          invocationId: commandId,
          ...invocation.input,
        });
        return;
      }

      const scopeChoice = await promptForChoice(
        "drm-copilot: Run PoshQC Suite",
        "Choose the scan scope.",
        ["Scan entire workspace", "Select folders to scan"],
      );
      if (!scopeChoice) {
        return;
      }

      if (scopeChoice === "Select folders to scan") {
        const selectedFolders =
          await promptForWorkspaceScanFolders(workspaceRoot);
        if (!selectedFolders) {
          return;
        }

        await service.runPoshQCSuite({
          workspaceRoot,
          invocationId: commandId,
          scanFolders: selectedFolders,
        });
        return;
      }

      await service.runPoshQCSuite({
        workspaceRoot,
        invocationId: commandId,
      });
    },
  );

  const [
    runPoshQCFormatDisposable,
    runPoshQCAnalyzeDisposable,
    runPoshQCTestDisposable,
    runPoshQCAnalyzeAutofixDisposable,
  ] = registerPoshQcCommands({
    output,
    service,
  });

  const [
    resolvePolicyAuditTemplateAssetDisposable,
    resolveExecuteHardLockPromptDisposable,
    resolveAtomicPlanPromptDisposable,
  ] = registerDocumentWorkflowCommands({
    output,
    service,
  });

  const mcpDisposables = registerMcpProvider(context);

  context.subscriptions.push(
    helloPythonDisposable,
    helloPowerShellDisposable,
    newClaudeWorktreeSessionDisposable,
    runPoshQCSuiteDisposable,
    runPoshQCFormatDisposable,
    runPoshQCAnalyzeDisposable,
    runPoshQCTestDisposable,
    runPoshQCAnalyzeAutofixDisposable,
    resolvePolicyAuditTemplateAssetDisposable,
    resolveExecuteHardLockPromptDisposable,
    resolveAtomicPlanPromptDisposable,
    ...repoAutomationDisposables,
    ...mcpDisposables,
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
