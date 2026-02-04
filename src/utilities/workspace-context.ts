import * as vscode from "vscode";

/**
 * Resolve the workspace folder that DRM Copilot utilities should target.
 *
 * - If there is no workspace folder open, show an error and return undefined.
 * - If there is exactly one folder, return it without prompting.
 * - If there are multiple folders, prompt the user to select one.
 */
export async function resolveWorkspaceFolder(): Promise<
  vscode.WorkspaceFolder | undefined
> {
  const folders = vscode.workspace.workspaceFolders;

  // No workspace: utilities can't safely operate without a target root.
  if (!folders || folders.length === 0) {
    void vscode.window.showErrorMessage(
      "Open a workspace folder to run DRM Copilot utilities.",
    );
    return undefined;
  }

  // Single-root workspaces should be non-interactive for UX and determinism.
  if (folders.length === 1) {
    return folders[0];
  }

  // Multi-root workspaces require explicit user selection.
  return vscode.window.showWorkspaceFolderPick({
    placeHolder: "Select a workspace folder for DRM Copilot utilities",
  });
}
