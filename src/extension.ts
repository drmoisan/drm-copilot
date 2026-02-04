// The module 'vscode' contains the VS Code extensibility API
// Import the module and reference it with the alias vscode in your code below
import * as vscode from "vscode";

import type { TaskCommandId } from "./task-command-map";
import { TASK_COMMAND_MAP } from "./task-command-map";
import { createDrmCopilotTaskProvider } from "./drm-task-provider";
import { collectCommandInputs } from "./utilities/input-collection";
import { dispatchUtility } from "./utilities/utility-dispatcher";
import { resolveWorkspaceFolder } from "./utilities/workspace-context";

/**
 * Executes a utility command by routing through the utility dispatcher.
 *
 * Purpose:
 *   Command handlers collect workspace context and inputs, then delegate
 *   to the utility dispatcher for execution. This eliminates dependency
 *   on workspace tasks.json and ensures utilities execute from extension-owned
 *   assets.
 *
 * Args:
 *   context: Extension context for resolving extension root
 *   commandId: The command ID to execute
 *
 * Side Effects:
 *   Shows prompts to user, executes utilities via dispatchUtility
 */
async function runUtilityByCommandId(
  context: vscode.ExtensionContext,
  commandId: TaskCommandId,
): Promise<void> {
  const workspaceFolder = await resolveWorkspaceFolder();
  if (!workspaceFolder) {
    return;
  }

  const inputValues = await collectCommandInputs(commandId);
  if (!inputValues) {
    return;
  }

  await dispatchUtility(commandId, {
    workspaceRoot: workspaceFolder.uri.fsPath.replace(/\\/g, "/"),
    extensionRoot: context.asAbsolutePath("").replace(/\\/g, "/"),
    inputValues,
  });
}

/**
 * Registers a command that executes a utility by command ID.
 *
 * @param context - The extension context for managing subscriptions.
 * @param commandId - The VS Code command ID to register.
 */
function registerUtilityCommand(
  context: vscode.ExtensionContext,
  commandId: TaskCommandId,
): void {
  const disposable = vscode.commands.registerCommand(commandId, () =>
    runUtilityByCommandId(context, commandId),
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

  // Register all utility commands from the configuration map.
  for (const commandId of Object.keys(TASK_COMMAND_MAP) as TaskCommandId[]) {
    registerUtilityCommand(context, commandId);
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
