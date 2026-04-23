import * as vscode from "vscode";
import {
  createOutputChannel,
  executeBundledScript,
  getWorkspaceRoot,
} from "./command-runtime";
import { registerDocumentWorkflowCommands } from "./document-workflow-commands";
import {
  promptForChoice,
  promptForFeatureName,
  promptForIssueNumber,
  promptForRequiredIssueNumber,
  promptForPotentialPath,
  promptForShortName,
  promptForWorkspaceScanFolders,
  resolveWorkflowInvocation,
} from "./extension-command-helpers";
import { registerMcpProvider } from "./mcp-provider";
import { listRepoAutomationTools } from "./mcp-tools";
import { registerPoshQcCommands } from "./poshqc-command-registration";
import {
  discoverPrBaseBranches,
  pickPrBaseBranch,
} from "./pr-context-branches";
import { createRepoAutomationService } from "./repo-automation-service";
import {
  POTENTIAL_PROMOTION_TYPES,
  resolveCollectPrContextInvocation,
  resolveLinkParentChildInvocation,
  resolveNewActiveFeatureFolderInvocation,
  resolveNewPotentialBugEntryInvocation,
  resolveNewPotentialEntryInvocation,
  resolvePotentialToIssueInvocation,
  resolveRunPoshQCSuiteInvocation,
  WORK_MODE_OPTIONS,
} from "./workflow-command-arguments";

// Re-export detectRuntime so existing test imports from this module keep working.
export { detectRuntime } from "./command-runtime";

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

  const collectCommitContextDisposable = vscode.commands.registerCommand(
    "drmCopilotExtension.collectCommitContext",
    async () => {
      const commandId = "drmCopilotExtension.collectCommitContext";
      await service.collectCommitContext({
        workspaceRoot: getWorkspaceRoot(),
        invocationId: commandId,
      });
    },
  );

  const collectPrContextDisposable = vscode.commands.registerCommand(
    "drmCopilotExtension.collectPrContext",
    async (...rawArgs: unknown[]) => {
      const commandId = "drmCopilotExtension.collectPrContext";
      const invocation = resolveWorkflowInvocation(output, commandId, () =>
        resolveCollectPrContextInvocation(rawArgs),
      );
      const workspaceRoot = getWorkspaceRoot();
      if (invocation.mode === "direct") {
        await service.collectPrContext({
          workspaceRoot,
          invocationId: commandId,
          ...invocation.input,
        });
        return;
      }

      output.appendLine(`[${commandId}] branch discovery start`);
      let discoveryResult: ReturnType<typeof discoverPrBaseBranches>;
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

      await service.collectPrContext({
        workspaceRoot,
        invocationId: commandId,
        base: selectedBase,
      });
    },
  );

  const pushDownCopilotCustomizationsDisposable =
    vscode.commands.registerCommand(
      "drmCopilotExtension.pushDownCopilotCustomizations",
      async () => {
        const commandId = "drmCopilotExtension.pushDownCopilotCustomizations";
        await service.pushDownCopilotCustomizations({
          workspaceRoot: getWorkspaceRoot(),
          invocationId: commandId,
        });
      },
    );

  const pushDownCodexAndAgentsCustomizationsDisposable =
    vscode.commands.registerCommand(
      "drmCopilotExtension.pushDownCodexAndAgentsCustomizations",
      async () => {
        const commandId =
          "drmCopilotExtension.pushDownCodexAndAgentsCustomizations";
        await service.pushDownCodexAndAgentsCustomizations({
          workspaceRoot: getWorkspaceRoot(),
          invocationId: commandId,
        });
      },
    );

  const syncAgentsFromInstructionsDisposable = vscode.commands.registerCommand(
    "drmCopilotExtension.syncAgentsFromInstructions",
    async () => {
      const commandId = "drmCopilotExtension.syncAgentsFromInstructions";
      const workspaceRoot = getWorkspaceRoot();

      await executeBundledScript(context, output, {
        runtimeKind: "powershell",
        bundledRelativePath:
          "resources/templates/sync-agents-from-instructions.ps1",
        commandId,
        args: ["-RepoRoot", workspaceRoot],
      });
    },
  );

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

      const scriptArgs: string[] = ["-ShortName", shortName];
      const trimmedObjective = objective.trim();
      if (trimmedObjective.length > 0) {
        scriptArgs.push("-Objective", trimmedObjective);
      }

      await executeBundledScript(context, output, {
        runtimeKind: "powershell",
        bundledRelativePath:
          "resources/templates/new-claude-worktree-session.ps1",
        commandId,
        args: scriptArgs,
      });
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

  const listMcpToolsDisposable = vscode.commands.registerCommand(
    "drmCopilotExtension.listMcpTools",
    async () => {
      const commandId = "drmCopilotExtension.listMcpTools";
      const toolItems = listRepoAutomationTools().map((tool) => ({
        label: tool.name,
        description: tool.description,
        detail:
          tool.inputSchema.required === undefined ||
          tool.inputSchema.required.length === 0
            ? "Required inputs: none"
            : `Required inputs: ${tool.inputSchema.required.join(", ")}`,
      }));

      output.appendLine(`[${commandId}] available MCP tools:`);
      for (const toolItem of toolItems) {
        output.appendLine(
          `- ${toolItem.label}: ${toolItem.description} (${toolItem.detail})`,
        );
      }

      await vscode.window.showQuickPick(toolItems, {
        title: "drm-copilot: List MCP Tools",
        placeHolder: "Available tools on the drmCopilotExtension MCP server.",
        matchOnDescription: true,
        matchOnDetail: true,
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

  const newPotentialBugEntryDisposable = vscode.commands.registerCommand(
    "drmCopilotExtension.newPotentialBugEntry",
    async (...rawArgs: unknown[]) => {
      const commandId = "drmCopilotExtension.newPotentialBugEntry";
      const invocation = resolveWorkflowInvocation(output, commandId, () =>
        resolveNewPotentialBugEntryInvocation(rawArgs),
      );
      const workspaceRoot = getWorkspaceRoot();
      if (invocation.mode === "direct") {
        await service.newPotentialBugEntry({
          workspaceRoot,
          invocationId: commandId,
          ...invocation.input,
        });
        return;
      }

      const shortName = await promptForShortName(
        "drm-copilot: New Potential Bug Entry",
        "Enter a kebab-case short name for the potential bug entry.",
      );
      if (!shortName) {
        return;
      }

      await service.newPotentialBugEntry({
        workspaceRoot,
        invocationId: commandId,
        shortName,
      });
    },
  );

  const newPotentialEntryDisposable = vscode.commands.registerCommand(
    "drmCopilotExtension.newPotentialEntry",
    async (...rawArgs: unknown[]) => {
      const commandId = "drmCopilotExtension.newPotentialEntry";
      const invocation = resolveWorkflowInvocation(output, commandId, () =>
        resolveNewPotentialEntryInvocation(rawArgs),
      );
      const workspaceRoot = getWorkspaceRoot();
      if (invocation.mode === "direct") {
        await service.newPotentialEntry({
          workspaceRoot,
          invocationId: commandId,
          ...invocation.input,
        });
        return;
      }

      const shortName = await promptForShortName(
        "drm-copilot: New Potential Entry",
        "Enter a kebab-case short name for the potential entry.",
      );
      if (!shortName) {
        return;
      }

      await service.newPotentialEntry({
        workspaceRoot,
        invocationId: commandId,
        shortName,
      });
    },
  );

  const linkParentChildDisposable = vscode.commands.registerCommand(
    "drmCopilotExtension.linkParentChild",
    async (...rawArgs: unknown[]) => {
      const commandId = "drmCopilotExtension.linkParentChild";
      const invocation = resolveWorkflowInvocation(output, commandId, () =>
        resolveLinkParentChildInvocation(rawArgs),
      );
      const workspaceRoot = getWorkspaceRoot();
      if (invocation.mode === "direct") {
        await service.linkParentChild({
          workspaceRoot,
          invocationId: commandId,
          ...invocation.input,
        });
        return;
      }

      const childIssueNumber = await promptForRequiredIssueNumber(
        "drm-copilot: Link Parent/Child Issues",
        "Enter the child issue number.",
        "Child issue number",
      );
      if (!childIssueNumber) {
        return;
      }

      const parentIssueNumber = await promptForRequiredIssueNumber(
        "drm-copilot: Link Parent/Child Issues",
        "Enter the parent tracking issue number.",
        "Parent issue number",
      );
      if (!parentIssueNumber) {
        return;
      }

      await service.linkParentChild({
        workspaceRoot,
        invocationId: commandId,
        childIssueNumber,
        parentIssueNumber,
      });
    },
  );

  const potentialToIssueDisposable = vscode.commands.registerCommand(
    "drmCopilotExtension.potentialToIssue",
    async (...rawArgs: unknown[]) => {
      const commandId = "drmCopilotExtension.potentialToIssue";
      const invocation = resolveWorkflowInvocation(output, commandId, () =>
        resolvePotentialToIssueInvocation(rawArgs),
      );
      const workspaceRoot = getWorkspaceRoot();
      if (invocation.mode === "direct") {
        await service.potentialToIssue({
          workspaceRoot,
          invocationId: commandId,
          ...invocation.input,
        });
        return;
      }

      const potentialPath = await promptForPotentialPath(workspaceRoot);
      if (!potentialPath) {
        return;
      }

      const promotionType = await promptForChoice(
        "drm-copilot: Potential To Issue",
        "Choose a promotion type.",
        POTENTIAL_PROMOTION_TYPES,
      );
      if (!promotionType) {
        return;
      }

      const workMode = await promptForChoice(
        "drm-copilot: Potential To Issue",
        "Choose a work mode.",
        WORK_MODE_OPTIONS,
      );
      if (!workMode) {
        return;
      }

      await service.potentialToIssue({
        workspaceRoot,
        invocationId: commandId,
        potentialPath,
        promotionType,
        workMode,
      });
    },
  );

  const newActiveFeatureFolderDisposable = vscode.commands.registerCommand(
    "drmCopilotExtension.newActiveFeatureFolder",
    async (...rawArgs: unknown[]) => {
      const commandId = "drmCopilotExtension.newActiveFeatureFolder";
      const invocation = resolveWorkflowInvocation(output, commandId, () =>
        resolveNewActiveFeatureFolderInvocation(rawArgs),
      );
      const workspaceRoot = getWorkspaceRoot();
      if (invocation.mode === "direct") {
        await service.newActiveFeatureFolder({
          workspaceRoot,
          invocationId: commandId,
          ...invocation.input,
        });
        return;
      }

      const featureType = await promptForChoice(
        "drm-copilot: New Active Feature Folder",
        "Choose the feature folder type.",
        POTENTIAL_PROMOTION_TYPES,
      );
      if (!featureType) {
        return;
      }

      const featureName = await promptForFeatureName(
        "drm-copilot: New Active Feature Folder",
        "Enter the feature name (kebab-case or underscore-case).",
      );
      if (!featureName) {
        return;
      }

      const issueNumber = await promptForIssueNumber();
      if (issueNumber === undefined) {
        return;
      }

      const workMode = await promptForChoice(
        "drm-copilot: New Active Feature Folder",
        "Choose a work mode.",
        WORK_MODE_OPTIONS,
      );
      if (!workMode) {
        return;
      }

      await service.newActiveFeatureFolder({
        workspaceRoot,
        invocationId: commandId,
        featureName,
        type: featureType,
        workMode,
        ...(issueNumber === null ? {} : { issueNumber }),
      });
    },
  );

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
    collectCommitContextDisposable,
    collectPrContextDisposable,
    newActiveFeatureFolderDisposable,
    potentialToIssueDisposable,
    pushDownCopilotCustomizationsDisposable,
    pushDownCodexAndAgentsCustomizationsDisposable,
    syncAgentsFromInstructionsDisposable,
    newClaudeWorktreeSessionDisposable,
    runPoshQCSuiteDisposable,
    listMcpToolsDisposable,
    runPoshQCFormatDisposable,
    runPoshQCAnalyzeDisposable,
    runPoshQCTestDisposable,
    runPoshQCAnalyzeAutofixDisposable,
    newPotentialBugEntryDisposable,
    newPotentialEntryDisposable,
    linkParentChildDisposable,
    resolvePolicyAuditTemplateAssetDisposable,
    resolveExecuteHardLockPromptDisposable,
    resolveAtomicPlanPromptDisposable,
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
