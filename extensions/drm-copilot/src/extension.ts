import * as vscode from "vscode";
import {
  createOutputChannel,
  executeBundledScript,
  getWorkspaceRoot,
} from "./command-runtime";
import {
  discoverPrBaseBranches,
  pickPrBaseBranch,
} from "./pr-context-branches";
import { createRepoAutomationService } from "./repo-automation-service";
import {
  getFeatureNameValidationMessage,
  getShortNameValidationMessage,
  POTENTIAL_PROMOTION_TYPES,
  resolveCollectPrContextInvocation,
  resolveNewActiveFeatureFolderInvocation,
  resolveNewPotentialBugEntryInvocation,
  resolveNewPotentialEntryInvocation,
  resolvePotentialToIssueInvocation,
  validateFeatureName,
  validateIssueNumber,
  validateShortName,
  WORK_MODE_OPTIONS,
  type WorkflowCommandInvocation,
} from "./workflow-command-arguments";

// Re-export detectRuntime so existing test imports from this module keep working.
export { detectRuntime } from "./command-runtime";

const ACTIVE_FEATURE_DOCS_DIRECTORY = "docs/features/active";
const POTENTIAL_DOCS_DIRECTORY = "docs/features/potential";

function normalizePath(filePath: string): string {
  return filePath.replace(/\\/g, "/");
}

function getActivePotentialPath(workspaceRoot: string): string | undefined {
  const activeEditorPath = vscode.window.activeTextEditor?.document.uri.fsPath;
  if (!activeEditorPath) {
    return undefined;
  }

  const normalizedWorkspaceRoot = normalizePath(workspaceRoot).toLowerCase();
  const normalizedActiveEditorPath =
    normalizePath(activeEditorPath).toLowerCase();
  const normalizedPotentialRoot = `${normalizedWorkspaceRoot}/${POTENTIAL_DOCS_DIRECTORY}`;

  if (!normalizedActiveEditorPath.endsWith(".md")) {
    return undefined;
  }

  if (!normalizedActiveEditorPath.startsWith(`${normalizedPotentialRoot}/`)) {
    return undefined;
  }

  return activeEditorPath;
}

function getActiveFeaturePlanPath(workspaceRoot: string): string | undefined {
  const activeEditorPath = vscode.window.activeTextEditor?.document.uri.fsPath;
  if (!activeEditorPath) {
    return undefined;
  }

  const normalizedWorkspaceRoot = normalizePath(workspaceRoot).toLowerCase();
  const normalizedActiveEditorPath =
    normalizePath(activeEditorPath).toLowerCase();
  const normalizedActiveFeatureRoot = `${normalizedWorkspaceRoot}/${ACTIVE_FEATURE_DOCS_DIRECTORY}`;

  if (!normalizedActiveEditorPath.endsWith(".md")) {
    return undefined;
  }

  if (
    !normalizedActiveEditorPath.startsWith(`${normalizedActiveFeatureRoot}/`)
  ) {
    return undefined;
  }

  return activeEditorPath;
}

async function promptForShortName(
  title: string,
  prompt: string,
): Promise<string | undefined> {
  const shortName = await vscode.window.showInputBox({
    title,
    prompt,
    ignoreFocusOut: true,
    validateInput: (value) =>
      getShortNameValidationMessage(value, "Short name"),
  });

  if (shortName === undefined) {
    return undefined;
  }

  return validateShortName(shortName.trim(), "Short name");
}

async function promptForChoice<TItem extends string>(
  title: string,
  prompt: string,
  items: ReadonlyArray<TItem>,
): Promise<TItem | undefined> {
  const selected = await vscode.window.showQuickPick([...items], {
    title,
    prompt,
    ignoreFocusOut: true,
  });

  return selected as TItem | undefined;
}

async function promptForFeatureName(
  title: string,
  prompt: string,
): Promise<string | undefined> {
  const featureName = await vscode.window.showInputBox({
    title,
    prompt,
    ignoreFocusOut: true,
    validateInput: getFeatureNameValidationMessage,
  });

  if (featureName === undefined) {
    return undefined;
  }

  return validateFeatureName(featureName.trim(), "Feature name");
}

async function promptForIssueNumber(): Promise<string | null | undefined> {
  const issueNumber = await vscode.window.showInputBox({
    title: "drm-copilot: New Active Feature Folder",
    prompt: "Enter the issue number, or leave blank to omit it.",
    ignoreFocusOut: true,
    validateInput: (value) => {
      const trimmed = value.trim();
      if (trimmed.length === 0) {
        return undefined;
      }

      return /^\d+$/.test(trimmed)
        ? undefined
        : "Issue number must be digits only when provided.";
    },
  });

  if (issueNumber === undefined) {
    return undefined;
  }

  const trimmed = issueNumber.trim();
  if (trimmed.length === 0) {
    return null;
  }

  return validateIssueNumber(trimmed);
}

async function promptForPotentialPath(
  workspaceRoot: string,
): Promise<string | undefined> {
  const activePotentialPath = getActivePotentialPath(workspaceRoot);
  if (activePotentialPath) {
    return activePotentialPath;
  }

  const selectedFile = await vscode.window.showOpenDialog({
    canSelectMany: false,
    openLabel: "Select potential file",
    defaultUri: vscode.Uri.file(`${workspaceRoot}/${POTENTIAL_DOCS_DIRECTORY}`),
    filters: {
      Markdown: ["md"],
    },
  });

  return selectedFile?.[0]?.fsPath;
}

async function promptForActiveFeaturePlan(
  workspaceRoot: string,
): Promise<string | undefined> {
  const activePlanPath = getActiveFeaturePlanPath(workspaceRoot);
  if (activePlanPath) {
    return activePlanPath;
  }

  const selectedFile = await vscode.window.showOpenDialog({
    canSelectMany: false,
    openLabel: "Select feature plan",
    defaultUri: vscode.Uri.file(
      `${workspaceRoot}/${ACTIVE_FEATURE_DOCS_DIRECTORY}`,
    ),
    filters: {
      Markdown: ["md"],
    },
  });

  return selectedFile?.[0]?.fsPath;
}

function resolveWorkflowInvocation<TInput>(
  output: vscode.OutputChannel,
  commandId: string,
  resolver: () => WorkflowCommandInvocation<TInput>,
): WorkflowCommandInvocation<TInput> {
  try {
    const invocation = resolver();
    output.appendLine(`[${commandId}] ${invocation.mode} mode`);
    return invocation;
  } catch (error: unknown) {
    const detail = error instanceof Error ? error.message : String(error);
    output.appendLine(`[${commandId}] validation failure: ${detail}`);
    throw error;
  }
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

  const resolveExecuteHardLockPromptDisposable =
    vscode.commands.registerCommand(
      "drmCopilotExtension.resolveExecuteHardLockPrompt",
      async () => {
        const commandId = "drmCopilotExtension.resolveExecuteHardLockPrompt";
        const workspaceRoot = getWorkspaceRoot();
        const planPath = await promptForActiveFeaturePlan(workspaceRoot);
        if (!planPath) {
          return;
        }

        await service.resolveExecuteHardLockPrompt({
          workspaceRoot,
          invocationId: commandId,
          target: planPath,
        });
      },
    );

  context.subscriptions.push(
    helloPythonDisposable,
    helloPowerShellDisposable,
    collectCommitContextDisposable,
    collectPrContextDisposable,
    newActiveFeatureFolderDisposable,
    potentialToIssueDisposable,
    pushDownCopilotCustomizationsDisposable,
    newPotentialBugEntryDisposable,
    newPotentialEntryDisposable,
    resolveExecuteHardLockPromptDisposable,
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
