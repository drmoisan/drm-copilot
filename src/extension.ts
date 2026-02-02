// The module 'vscode' contains the VS Code extensibility API
// Import the module and reference it with the alias vscode in your code below
import * as vscode from "vscode";

import type { TaskCommandId } from "./task-command-map";
import {
  TASK_COMMAND_MAP,
  getTaskExecutionSpec,
  getTaskLabelForCommandId,
} from "./task-command-map";
import { createDrmCopilotTaskProvider } from "./drm-task-provider";

/**
 * Gets the target workspace folder for task execution.
 *
 * Handles single-root, multi-root, and no-workspace scenarios:
 * - Single workspace folder: returns it directly
 * - Multiple workspace folders: prompts user to select one
 * - No workspace folders: shows error and returns undefined
 *
 * @returns The selected workspace folder, or undefined if none available
 */
async function getTargetWorkspaceFolder(): Promise<
  vscode.WorkspaceFolder | undefined
> {
  const folders = vscode.workspace.workspaceFolders;

  if (!folders || folders.length === 0) {
    vscode.window.showErrorMessage(
      "No workspace folder is open. Please open a folder to run DRM Copilot tasks.",
    );
    return undefined;
  }

  if (folders.length === 1) {
    return folders[0];
  }

  // Multiple workspace folders - prompt user to select
  return await vscode.window.showWorkspaceFolderPick({
    placeHolder: "Select workspace folder for task execution",
  });
}

/**
 * Executes a VS Code task by command ID using the task provider.
 *
 * @param commandId - The command ID to execute
 */
async function runTaskByCommandId(commandId: TaskCommandId): Promise<void> {
  const workspaceFolder = await getTargetWorkspaceFolder();
  if (!workspaceFolder) {
    return;
  }

  const spec = getTaskExecutionSpec(commandId);
  if (!spec) {
    vscode.window.showErrorMessage(
      `No task execution spec found for command: ${commandId}`,
    );
    return;
  }

  const taskLabel = getTaskLabelForCommandId(commandId);
  if (!taskLabel) {
    vscode.window.showErrorMessage(
      `No task label found for command: ${commandId}`,
    );
    return;
  }

  // Fetch tasks from our provider
  const tasks = await vscode.tasks.fetchTasks({ type: "drm-copilot" });
  const targetTask = tasks.find(
    (t) => t.name === taskLabel && t.scope === workspaceFolder,
  );

  if (targetTask) {
    await vscode.tasks.executeTask(targetTask);
  } else {
    vscode.window.showErrorMessage(
      `Task "${taskLabel}" not found in provider. Please report this issue.`,
    );
  }
}

/**
 * Registers a command that executes a task by command ID.
 *
 * @param context - The extension context for managing subscriptions.
 * @param commandId - The VS Code command ID to register.
 */
function registerTaskCommand(
  context: vscode.ExtensionContext,
  commandId: TaskCommandId,
): void {
  const disposable = vscode.commands.registerCommand(commandId, () =>
    runTaskByCommandId(commandId),
  );
  context.subscriptions.push(disposable);
}

/**
 * Called when the extension is activated.
 *
 * Registers all DRM Copilot commands and the task provider,
 * enabling users to invoke tasks via the Command Palette without
 * requiring workspace-local tasks.json entries.
 *
 * @param context - The extension context provided by VS Code.
 */
export function activate(context: vscode.ExtensionContext): void {
  console.log("DRM Copilot extension is now active.");

  // Register the task provider
  const taskProvider = createDrmCopilotTaskProvider(context);
  const taskProviderDisposable = vscode.tasks.registerTaskProvider(
    "drm-copilot",
    taskProvider,
  );
  context.subscriptions.push(taskProviderDisposable);

  // Register the original informational command.
  const applyCustomizations = vscode.commands.registerCommand(
    "drm-copilot.applyCustomizations",
    () => {
      vscode.window.showInformationMessage(
        "DRM Copilot: agentic customization scaffolding is ready.",
      );
    },
  );
  context.subscriptions.push(applyCustomizations);

  // Register all task-mapped commands from the configuration map.
  for (const commandId of Object.keys(TASK_COMMAND_MAP) as TaskCommandId[]) {
    registerTaskCommand(context, commandId);
  }

  vscode.window.showInformationMessage(
    `DRM Copilot: ${Object.keys(TASK_COMMAND_MAP).length + 1} commands registered.`,
  );
}

/**
 * Called when the extension is deactivated.
 * Performs any necessary cleanup.
 */
export function deactivate(): void {
  // No cleanup required at this time.
}
