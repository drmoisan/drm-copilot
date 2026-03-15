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
import {
  resolveNewActiveFeatureFolderInvocation,
  resolveNewPotentialBugEntryInvocation,
  resolveNewPotentialEntryInvocation,
  resolvePotentialToIssueInvocation,
} from "./workflow-command-arguments";

// Re-export detectRuntime so existing test imports from this module keep working.
export { detectRuntime } from "./command-runtime";

const SHORT_NAME_PATTERN = /^[a-z0-9]+(-[a-z0-9]+)*$/;
const FEATURE_NAME_PATTERN = /^[a-z0-9]+(?:[-_][a-z0-9]+)*$/;
const POTENTIAL_PROMOTION_TYPES = ["epic", "feature", "refactor", "bug"];
const WORK_MODE_OPTIONS = ["minor-audit", "full-feature", "full-bug", "full"];
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

async function promptForActiveFeaturePlan(
  workspaceRoot: string,
): Promise<string | undefined> {
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

async function promptForShortName(
  title: string,
  prompt: string,
): Promise<string | undefined> {
  const shortName = await vscode.window.showInputBox({
    title,
    prompt,
    ignoreFocusOut: true,
    validateInput: (value) => {
      const trimmed = value.trim();
      if (trimmed.length === 0) {
        return "Short name is required.";
      }

      return SHORT_NAME_PATTERN.test(trimmed)
        ? undefined
        : "Use kebab-case letters and numbers only (e.g., api-timeout).";
    },
  });

  if (shortName === undefined) {
    return undefined;
  }

  const trimmed = shortName.trim();
  if (!SHORT_NAME_PATTERN.test(trimmed)) {
    throw new Error(
      "Short name must use kebab-case letters and numbers only (e.g., api-timeout).",
    );
  }

  return trimmed;
}

async function promptForChoice(
  title: string,
  prompt: string,
  items: ReadonlyArray<string>,
): Promise<string | undefined> {
  return vscode.window.showQuickPick([...items], {
    title,
    prompt,
    ignoreFocusOut: true,
  });
}

async function promptForFeatureName(
  title: string,
  prompt: string,
): Promise<string | undefined> {
  const featureName = await vscode.window.showInputBox({
    title,
    prompt,
    ignoreFocusOut: true,
    validateInput: (value) => {
      const trimmed = value.trim();
      if (trimmed.length === 0) {
        return "Feature name is required.";
      }

      return FEATURE_NAME_PATTERN.test(trimmed)
        ? undefined
        : "Use kebab-case or underscore-case letters and numbers only.";
    },
  });

  if (featureName === undefined) {
    return undefined;
  }

  const trimmed = featureName.trim();
  if (!FEATURE_NAME_PATTERN.test(trimmed)) {
    throw new Error(
      "Feature name must use kebab-case or underscore-case letters and numbers only.",
    );
  }

  return trimmed;
}

function resolveWorkflowInvocation(
  output: vscode.OutputChannel,
  commandId: string,
  resolver: () => ReturnType<typeof resolveNewPotentialEntryInvocation>,
): ReturnType<typeof resolveNewPotentialEntryInvocation> {
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
 * @remarks Each command delegates to a small runtime/script launcher to keep the
 * activation path thin and predictable.
 */
export function activate(context: vscode.ExtensionContext): void {
  const output = createOutputChannel();
  const templateRoot = vscode.Uri.joinPath(
    context.extensionUri,
    "resources/feature-templates",
  ).fsPath;

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

  const newPotentialBugEntryDisposable = vscode.commands.registerCommand(
    "drmCopilotExtension.newPotentialBugEntry",
    async (...rawArgs: unknown[]) => {
      const commandId = "drmCopilotExtension.newPotentialBugEntry";
      const invocation = resolveWorkflowInvocation(output, commandId, () =>
        resolveNewPotentialBugEntryInvocation(rawArgs, templateRoot),
      );
      if (invocation.mode === "direct") {
        await executeBundledScript(context, output, {
          runtimeKind: "python",
          bundledRelativePath: "resources/templates/new_potential_bug_entry.py",
          commandId,
          args: invocation.forwardedArgs,
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

      await executeBundledScript(context, output, {
        runtimeKind: "python",
        bundledRelativePath: "resources/templates/new_potential_bug_entry.py",
        commandId,
        args: ["--short-name", shortName, "--template-root", templateRoot],
      });
    },
  );

  const newPotentialEntryDisposable = vscode.commands.registerCommand(
    "drmCopilotExtension.newPotentialEntry",
    async (...rawArgs: unknown[]) => {
      const commandId = "drmCopilotExtension.newPotentialEntry";
      const invocation = resolveWorkflowInvocation(output, commandId, () =>
        resolveNewPotentialEntryInvocation(rawArgs, templateRoot),
      );
      if (invocation.mode === "direct") {
        await executeBundledScript(context, output, {
          runtimeKind: "powershell",
          bundledRelativePath: "resources/templates/new-potential-entry.ps1",
          commandId,
          args: invocation.forwardedArgs,
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

      await executeBundledScript(context, output, {
        runtimeKind: "powershell",
        bundledRelativePath: "resources/templates/new-potential-entry.ps1",
        commandId,
        args: ["-ShortName", shortName, "-TemplateRoot", templateRoot],
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
      if (invocation.mode === "direct") {
        await executeBundledScript(context, output, {
          runtimeKind: "python",
          bundledRelativePath: "resources/templates/potential_to_issue.py",
          commandId,
          args: invocation.forwardedArgs,
        });
        return;
      }

      const workspaceRoot = getWorkspaceRoot();
      const activePotentialPath = getActivePotentialPath(workspaceRoot);
      const selectedFile = activePotentialPath
        ? undefined
        : await vscode.window.showOpenDialog({
            canSelectMany: false,
            openLabel: "Select potential file",
            defaultUri: vscode.Uri.file(
              `${workspaceRoot}/${POTENTIAL_DOCS_DIRECTORY}`,
            ),
            filters: {
              Markdown: ["md"],
            },
          });
      const potentialPath = activePotentialPath ?? selectedFile?.[0]?.fsPath;
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

      await executeBundledScript(context, output, {
        runtimeKind: "python",
        bundledRelativePath: "resources/templates/potential_to_issue.py",
        commandId,
        args: [
          "--potential-path",
          potentialPath,
          "--promotion-type",
          promotionType,
          "--work-mode",
          workMode,
        ],
      });
    },
  );

  const newActiveFeatureFolderDisposable = vscode.commands.registerCommand(
    "drmCopilotExtension.newActiveFeatureFolder",
    async (...rawArgs: unknown[]) => {
      const commandId = "drmCopilotExtension.newActiveFeatureFolder";
      const invocation = resolveWorkflowInvocation(output, commandId, () =>
        resolveNewActiveFeatureFolderInvocation(rawArgs, templateRoot),
      );
      if (invocation.mode === "direct") {
        await executeBundledScript(context, output, {
          runtimeKind: "python",
          bundledRelativePath:
            "resources/templates/new_active_feature_folder.py",
          commandId,
          args: invocation.forwardedArgs,
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

      const args = ["--feature-name", featureName, "--type", featureType];
      const trimmedIssueNumber = issueNumber.trim();
      if (trimmedIssueNumber.length > 0) {
        args.push("--issue-number", trimmedIssueNumber);
      }
      args.push("--work-mode", workMode);
      args.push("--template-root", templateRoot);

      await executeBundledScript(context, output, {
        runtimeKind: "python",
        bundledRelativePath: "resources/templates/new_active_feature_folder.py",
        commandId,
        args,
      });
    },
  );

  const resolveExecuteHardLockPromptDisposable =
    vscode.commands.registerCommand(
      "drmCopilotExtension.resolveExecuteHardLockPrompt",
      async () => {
        const commandId = "drmCopilotExtension.resolveExecuteHardLockPrompt";
        const workspaceRoot = getWorkspaceRoot();
        const activePlanPath = getActiveFeaturePlanPath(workspaceRoot);
        const planPath =
          activePlanPath ?? (await promptForActiveFeaturePlan(workspaceRoot));
        if (!planPath) {
          return;
        }

        await executeBundledScript(context, output, {
          runtimeKind: "python",
          bundledRelativePath:
            "resources/templates/resolve_hard_lock_prompt.py",
          commandId,
          args: ["--target", planPath, "--workspace", workspaceRoot],
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
