/**
 * VS Code Task Provider for DRM Copilot commands.
 *
 * This provider programmatically creates tasks for each command ID,
 * resolving extension script paths and workspace context without
 * requiring workspace-local tasks.json entries.
 */

import * as vscode from "vscode";

import {
  type TaskCommandId,
  type TaskExecutionSpec,
  getAllTaskCommandIds,
  getTaskExecutionSpec,
  getTaskLabelForCommandId,
  resolveTaskArgs,
} from "./task-command-map";

/**
 * Task provider for DRM Copilot commands.
 *
 * Implements vscode.TaskProvider to programmatically create tasks
 * based on command IDs and execution specs.
 */
class DrmCopilotTaskProvider implements vscode.TaskProvider {
  private readonly context: vscode.ExtensionContext;

  constructor(context: vscode.ExtensionContext) {
    this.context = context;
  }

  /**
   * Provides all DRM Copilot tasks for the workspace.
   */
  provideTasks(): vscode.Task[] {
    const tasks: vscode.Task[] = [];

    for (const commandId of getAllTaskCommandIds()) {
      const task = this.createTaskForCommand(commandId);
      if (task) {
        tasks.push(task);
      }
    }

    return tasks;
  }

  /**
   * Resolves a task definition into a fully configured task.
   */
  resolveTask(task: vscode.Task): vscode.Task | undefined {
    // For now, we don't support resolving user-provided task definitions
    return undefined;
  }

  /**
   * Creates a VS Code task for a specific command ID.
   */
  private createTaskForCommand(
    commandId: TaskCommandId,
  ): vscode.Task | undefined {
    const spec = getTaskExecutionSpec(commandId);
    if (!spec) {
      return undefined;
    }

    const taskLabel = getTaskLabelForCommandId(commandId);
    if (!taskLabel) {
      return undefined;
    }

    // Get the workspace folder for task scope and cwd
    const workspaceFolder = this.getWorkspaceFolder();
    if (!workspaceFolder) {
      return undefined;
    }

    // Create task definition
    const taskDefinition: vscode.TaskDefinition = {
      type: "drm-copilot",
      commandId,
    };

    // Resolve extension root tokens before passing to resolveTaskArgs
    const argsWithExtensionRoot = spec.args.map((arg) =>
      arg.replace(
        /\$\{extensionRoot\}/g,
        this.context.asAbsolutePath("").replace(/\\/g, "/"),
      ),
    );

    // Resolve remaining tokens (workspace, file, input tokens)
    const resolvedArgs = resolveTaskArgs(argsWithExtensionRoot, {
      workspaceRoot: workspaceFolder.uri.fsPath.replace(/\\/g, "/"),
      extensionRoot: this.context.asAbsolutePath("").replace(/\\/g, "/"),
      activeFilePath:
        vscode.window.activeTextEditor?.document.uri.fsPath.replace(/\\/g, "/"),
      activeRelativePath: vscode.window.activeTextEditor
        ? vscode.workspace.asRelativePath(
            vscode.window.activeTextEditor.document.uri,
          )
        : undefined,
      inputValues: {}, // Inputs will be resolved at execution time
    });

    // Create shell execution with workspace folder as cwd
    const execution = new vscode.ShellExecution(spec.command, resolvedArgs, {
      cwd: workspaceFolder.uri.fsPath,
    });

    // Create task with workspace folder scope
    const task = new vscode.Task(
      taskDefinition,
      workspaceFolder,
      taskLabel,
      "drm-copilot",
      execution,
    );

    return task;
  }

  /**
   * Gets the target workspace folder for task execution.
   *
   * Returns the first workspace folder if available.
   * In multi-root workspaces, this should be enhanced to prompt the user.
   */
  private getWorkspaceFolder(): vscode.WorkspaceFolder | undefined {
    const folders = vscode.workspace.workspaceFolders;
    if (!folders || folders.length === 0) {
      return undefined;
    }

    // For now, use the first folder
    // TODO: In Phase 2-T5, add multi-root workspace selection
    return folders[0];
  }
}

/**
 * Creates and returns a DRM Copilot task provider.
 *
 * @param context - The extension context for resolving extension paths
 * @returns A task provider instance ready to be registered
 */
export function createDrmCopilotTaskProvider(
  context: vscode.ExtensionContext,
): vscode.TaskProvider {
  return new DrmCopilotTaskProvider(context);
}
