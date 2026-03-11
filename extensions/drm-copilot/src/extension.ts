import * as vscode from "vscode";
import {
  createOutputChannel,
  executeBundledScript,
  getWorkspaceRoot,
} from "./command-runtime";
import {
  type BranchDiscoveryResult,
  discoverPrBaseBranches,
  pickPrBaseBranch,
} from "./pr-context-branches";

// Re-export detectRuntime so existing test imports from this module keep working.
export { detectRuntime } from "./command-runtime";

/**
 * Defines a command that is intentionally registered as a placeholder.
 */
interface PlaceholderCommandSpec {
  readonly commandId: string;
  readonly title: string;
  readonly scriptReference: string;
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

  const pushDownCopilotCustomizationsDisposable =
    vscode.commands.registerCommand(
      "drmCopilotExtension.pushDownCopilotCustomizations",
      async () => {
        const commandId = "drmCopilotExtension.pushDownCopilotCustomizations";
        const workspaceRoot = getWorkspaceRoot();

        await executeBundledScript(context, output, {
          runtimeKind: "python",
          bundledRelativePath:
            "resources/templates/push_down_copilot_customizations.py",
          commandId,
          args: ["--destination", workspaceRoot],
        });
      },
    );

  const placeholderDisposables = registerPlaceholderCommands(output);

  context.subscriptions.push(
    helloPythonDisposable,
    helloPowerShellDisposable,
    collectCommitContextDisposable,
    collectPrContextDisposable,
    pushDownCopilotCustomizationsDisposable,
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
