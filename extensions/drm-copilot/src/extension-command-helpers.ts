import * as vscode from "vscode";
import {
  type DevelopmentDocsReader,
  developmentDocsPath,
  knownRootPrefixes,
  resolveDevelopmentDocsRoot,
} from "./lib/development-docs/root";
import { RealFileSystem } from "./lib/file-system";
import {
  getFeatureNameValidationMessage,
  getRequiredIssueNumberValidationMessage,
  getShortNameValidationMessage,
  validateRequiredIssueNumber,
  validateFeatureName,
  validateIssueNumber,
  validateShortName,
  type WorkflowCommandInvocation,
} from "./workflow-command-arguments";

/**
 * Return whether a lower-cased forward-slash path lies under an area of any
 * known development-docs root (matchers accept the union, spec
 * "Writer/matcher split").
 *
 * @param normalizedWorkspaceRoot Lower-cased forward-slash workspace root.
 * @param normalizedPath Lower-cased forward-slash candidate path.
 * @param area Area of the area map.
 * @returns True when the path is under the area of either known root.
 */
function isUnderKnownArea(
  normalizedWorkspaceRoot: string,
  normalizedPath: string,
  area: "active" | "potential",
): boolean {
  return knownRootPrefixes(area).some((prefix) =>
    normalizedPath.startsWith(`${normalizedWorkspaceRoot}/${prefix}`),
  );
}

/**
 * Return the workspace path of an area under the resolved development-docs
 * root, used as the default location of a file picker.
 *
 * @param workspaceRoot Workspace root.
 * @param area Area of the area map.
 * @param reader Reader for the routing file and directory probes.
 * @returns The workspace-joined area path.
 */
function resolvedAreaPath(
  workspaceRoot: string,
  area: "active" | "potential",
  reader: DevelopmentDocsReader,
): string {
  const root = resolveDevelopmentDocsRoot(reader, workspaceRoot);
  return `${workspaceRoot}/${developmentDocsPath(root, area)}`;
}

/**
 * Normalize a file path to use forward slashes for cross-platform comparison.
 *
 * @param filePath The path to normalize.
 * @returns The normalized path string.
 */
export function normalizePath(filePath: string): string {
  return filePath.replace(/\\/g, "/");
}

function isEligibleActiveFeaturePlanPath(
  workspaceRoot: string,
  filePath: string,
): boolean {
  const normalizedWorkspaceRoot = normalizePath(workspaceRoot).toLowerCase();
  const normalizedFilePath = normalizePath(filePath).toLowerCase();

  if (!normalizedFilePath.endsWith(".md")) {
    return false;
  }

  if (
    !isUnderKnownArea(normalizedWorkspaceRoot, normalizedFilePath, "active")
  ) {
    return false;
  }

  const basename = normalizedFilePath.split("/").at(-1);
  return basename?.startsWith("plan") ?? false;
}

function getActiveFeaturePlanValidationMessage(): string {
  return "This command requires an active or selected plan markdown file under docs/features/active/**/plan*.md.";
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

  if (!normalizedActiveEditorPath.endsWith(".md")) {
    return undefined;
  }

  if (
    !isUnderKnownArea(
      normalizedWorkspaceRoot,
      normalizedActiveEditorPath,
      "potential",
    )
  ) {
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

  if (!isEligibleActiveFeaturePlanPath(workspaceRoot, activeEditorPath)) {
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
 * Prompt the user to enter a required numeric issue number.
 *
 * @param title The input box title string.
 * @param prompt The input box prompt string.
 * @param fieldName The user-facing field label used in validation messaging.
 * @returns The validated issue number, or `undefined` if the user cancelled.
 */
export async function promptForRequiredIssueNumber(
  title: string,
  prompt: string,
  fieldName: string,
): Promise<string | undefined> {
  const issueNumber = await vscode.window.showInputBox({
    title,
    prompt,
    ignoreFocusOut: true,
    validateInput: (value) =>
      getRequiredIssueNumberValidationMessage(value, fieldName),
  });

  if (issueNumber === undefined) {
    return undefined;
  }

  return validateRequiredIssueNumber(issueNumber.trim(), fieldName);
}

/**
 * Resolve the path to the potential-entry file to promote.
 *
 * Uses the active editor path when it is a qualifying potential file;
 * otherwise opens a file-picker dialog starting in the potential folder.
 *
 * @param workspaceRoot The root of the current workspace.
 * @param reader Reader that resolves the development-docs root; defaults to
 *   the real file system.
 * @returns The selected file path, or `undefined` if the user cancelled.
 */
export async function promptForPotentialPath(
  workspaceRoot: string,
  reader: DevelopmentDocsReader = new RealFileSystem(),
): Promise<string | undefined> {
  const activePotentialPath = getActivePotentialPath(workspaceRoot);
  if (activePotentialPath) {
    return activePotentialPath;
  }

  const selectedFile = await vscode.window.showOpenDialog({
    canSelectMany: false,
    openLabel: "Select potential file",
    defaultUri: vscode.Uri.file(
      resolvedAreaPath(workspaceRoot, "potential", reader),
    ),
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
 * @param reader Reader that resolves the development-docs root; defaults to
 *   the real file system.
 * @returns The selected file path, or `undefined` if the user cancelled.
 */
export async function promptForActiveFeaturePlan(
  workspaceRoot: string,
  reader: DevelopmentDocsReader = new RealFileSystem(),
): Promise<string | undefined> {
  const activePlanPath = getActiveFeaturePlanPath(workspaceRoot);
  if (activePlanPath) {
    return activePlanPath;
  }

  const selectedFile = await vscode.window.showOpenDialog({
    canSelectMany: false,
    openLabel: "Select feature plan",
    defaultUri: vscode.Uri.file(
      resolvedAreaPath(workspaceRoot, "active", reader),
    ),
    filters: {
      Markdown: ["md"],
    },
  });

  const selectedPlanPath = selectedFile?.[0]?.fsPath;
  if (selectedPlanPath === undefined) {
    return undefined;
  }

  if (!isEligibleActiveFeaturePlanPath(workspaceRoot, selectedPlanPath)) {
    throw new Error(getActiveFeaturePlanValidationMessage());
  }

  return selectedPlanPath;
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
