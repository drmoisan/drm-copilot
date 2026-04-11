import * as vscode from "vscode";
import {
  getFeatureNameValidationMessage,
  getShortNameValidationMessage,
  validateFeatureName,
  validateIssueNumber,
  validateShortName,
  type WorkflowCommandInvocation,
} from "./workflow-command-arguments";

/**
 * Directory paths for features in the repository, used to detect context from
 * the active editor when the user has an appropriate file open.
 */
export const ACTIVE_FEATURE_DOCS_DIRECTORY = "docs/features/active";
export const POTENTIAL_DOCS_DIRECTORY = "docs/features/potential";

/**
 * Normalize a file path to use forward slashes for cross-platform comparison.
 *
 * @param filePath The path to normalize.
 * @returns The normalized path string.
 */
export function normalizePath(filePath: string): string {
  return filePath.replace(/\\/g, "/");
}

/**
 * Return the fsPath of the active editor if it is a potential-entry file.
 *
 * @param workspaceRoot The root of the current workspace.
 * @returns The active editor path when it is under the potential docs folder, or
 *   `undefined` if no qualifying file is open.
 */
export function getActivePotentialPath(
  workspaceRoot: string,
): string | undefined {
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

/**
 * Return the fsPath of the active editor if it is a feature plan file.
 *
 * @param workspaceRoot The root of the current workspace.
 * @returns The active editor path when it is under the active feature folder,
 *   or `undefined` if no qualifying file is open.
 */
export function getActiveFeaturePlanPath(
  workspaceRoot: string,
): string | undefined {
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

/**
 * Prompt the user to enter a kebab-case short name.
 *
 * @param title The input box title string.
 * @param prompt The input box prompt string.
 * @returns The validated short name, or `undefined` if the user cancelled.
 */
export async function promptForShortName(
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

/**
 * Prompt the user to choose one item from a list.
 *
 * @param title The quick-pick title string.
 * @param prompt The quick-pick prompt string.
 * @param items The selectable items.
 * @returns The selected item, or `undefined` if the user cancelled.
 */
export async function promptForChoice<TItem extends string>(
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

/**
 * Prompt the user to enter a feature name string.
 *
 * @param title The input box title string.
 * @param prompt The input box prompt string.
 * @returns The validated feature name, or `undefined` if the user cancelled.
 */
export async function promptForFeatureName(
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

/**
 * Prompt the user to enter an optional issue number for a new folder.
 *
 * @returns The issue number string, `null` when left blank, or `undefined` if
 *   the user cancelled.
 */
export async function promptForIssueNumber(): Promise<
  string | null | undefined
> {
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

/**
 * Resolve the path to the potential-entry file to promote.
 *
 * Uses the active editor path when it is a qualifying potential file;
 * otherwise opens a file-picker dialog starting in the potential folder.
 *
 * @param workspaceRoot The root of the current workspace.
 * @returns The selected file path, or `undefined` if the user cancelled.
 */
export async function promptForPotentialPath(
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

/**
 * Resolve the path to the active feature plan file.
 *
 * Uses the active editor path when it is a qualifying plan file; otherwise
 * opens a file-picker dialog starting in the active features folder.
 *
 * @param workspaceRoot The root of the current workspace.
 * @returns The selected file path, or `undefined` if the user cancelled.
 */
export async function promptForActiveFeaturePlan(
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

/**
 * Prompt the user to choose one or more workspace folders to scan.
 *
 * @param workspaceRoot The root of the current workspace.
 * @returns The selected folder paths, or `undefined` if the user cancelled.
 */
export async function promptForWorkspaceScanFolders(
  workspaceRoot: string,
): Promise<string[] | undefined> {
  const selectedFolders = await vscode.window.showOpenDialog({
    canSelectMany: true,
    canSelectFiles: false,
    canSelectFolders: true,
    defaultUri: vscode.Uri.file(workspaceRoot),
    openLabel: "Select folders to scan",
    title: "drm-copilot: Run PoshQC Suite",
  });

  if (!selectedFolders) {
    return undefined;
  }

  return selectedFolders.map((folder) => folder.fsPath);
}

/**
 * Resolve a workflow command invocation, logging its mode to the output channel.
 *
 * @param output The extension output channel for logging.
 * @param commandId The VS Code command ID being resolved.
 * @param resolver A callback that produces the invocation; throws on failure.
 * @returns The resolved invocation.
 * @throws Re-throws any error raised by the resolver after logging the failure.
 */
export function resolveWorkflowInvocation<TInput>(
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
