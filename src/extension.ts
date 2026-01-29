// The module 'vscode' contains the VS Code extensibility API
// Import the module and reference it with the alias vscode in your code below
import * as vscode from "vscode";

import { TASK_COMMAND_MAP } from "./task-command-map";

/**
 * Executes a VS Code task by its label.
 *
 * Fetches all workspace tasks, finds one matching the given label,
 * and executes it. Shows an error message if the task is not found.
 *
 * @param taskLabel - The label of the task to execute (from tasks.json).
 */
async function runTaskByLabel(taskLabel: string): Promise<void> {
  const tasks = await vscode.tasks.fetchTasks();
  const targetTask = tasks.find((t) => t.name === taskLabel);

  if (targetTask) {
    await vscode.tasks.executeTask(targetTask);
  } else {
    vscode.window.showErrorMessage(
      `Task "${taskLabel}" not found. Ensure tasks.json is configured.`,
    );
  }
}

/**
 * Registers a command that executes a task by label.
 *
 * @param context - The extension context for managing subscriptions.
 * @param commandId - The VS Code command ID to register.
 * @param taskLabel - The task label to execute when the command is invoked.
 */
function registerTaskCommand(
  context: vscode.ExtensionContext,
  commandId: string,
  taskLabel: string,
): void {
  const disposable = vscode.commands.registerCommand(commandId, () =>
    runTaskByLabel(taskLabel),
  );
  context.subscriptions.push(disposable);
}

/**
 * Called when the extension is activated.
 *
 * Registers all DRM Copilot commands that map to workspace tasks,
 * enabling users to invoke tasks via the Command Palette.
 *
 * @param context - The extension context provided by VS Code.
 */
export function activate(context: vscode.ExtensionContext): void {
  console.log("DRM Copilot extension is now active.");

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
  for (const [commandId, taskLabel] of Object.entries(TASK_COMMAND_MAP)) {
    registerTaskCommand(context, commandId, taskLabel);
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
