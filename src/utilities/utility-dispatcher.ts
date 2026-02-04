import * as vscode from "vscode";

import type { TaskCommandId } from "../task-command-map";
import { getTaskExecutionSpec } from "../task-command-map";
import { resolveExecutable } from "./tool-preflight";
import { getRequiredInputIds, getUtilitySpec } from "./utility-spec";

/**
 * Utility dispatcher - routes utility commands to their implementations.
 *
 * Purpose:
 *   Central dispatcher for DRM utility commands, handling tool preflight
 *   checks and error reporting before delegating to command implementations.
 */

export interface DispatchContext {
  workspaceRoot: string;
  extensionRoot: string;
  inputValues: Record<string, unknown>;
}

export interface DispatchResult {
  success: boolean;
  error?: string;
}

/**
 * Dispatch a utility command to its implementation.
 *
 * Purpose:
 *   Route commands through preflight checks, validate inputs, and execute
 *   utilities using VS Code ProcessExecution for external tools and PowerShell scripts.
 *
 * Flow:
 *   1. Look up the utility specification for the command
 *   2. Validate that all required inputs are present
 *   3. For external utilities, perform host tool preflight checks
 *   4. Resolve argument templates (${extensionRoot}, ${workspaceFolder}, ${input:*})
 *   5. Execute the utility using VS Code ProcessExecution
 *
 * Args:
 *   commandId: The VS Code command identifier (must be a TaskCommandId)
 *   context: Workspace and extension context with input values
 *
 * Returns:
 *   Result object indicating success/failure with optional error message
 *
 * Raises:
 *   No exceptions; errors are returned in the result object
 *
 * Side Effects:
 *   - May show error messages to user via vscode.window API
 *   - Executes external processes via vscode.tasks API
 */
export async function dispatchUtility(
  commandId: string,
  context: DispatchContext,
): Promise<DispatchResult> {
  try {
    // Look up utility spec
    const spec = getUtilitySpec(commandId as TaskCommandId);

    // Validate required inputs are present
    const requiredInputIds = getRequiredInputIds(commandId as TaskCommandId);
    for (const inputId of requiredInputIds) {
      if (
        context.inputValues[inputId] === undefined ||
        context.inputValues[inputId] === null
      ) {
        const errorMsg = `Missing required input: ${inputId} for command ${commandId}`;
        void vscode.window.showErrorMessage(errorMsg);
        return { success: false, error: errorMsg };
      }
    }

    // Get execution spec for argument resolution
    const execSpec = getTaskExecutionSpec(commandId as TaskCommandId);
    if (!execSpec) {
      const errorMsg = `No execution spec found for command: ${commandId}`;
      void vscode.window.showErrorMessage(errorMsg);
      return { success: false, error: errorMsg };
    }

    // Perform tool preflight for external utilities
    if (spec.kind === "external") {
      const toolPath = resolveExecutable(execSpec.command);
      if (!toolPath) {
        const errorMsg = `Required tool not found in PATH: ${execSpec.command}. Please install ${execSpec.command} and ensure it is available in your system PATH.`;
        void vscode.window.showErrorMessage(errorMsg);
        return { success: false, error: errorMsg };
      }
    }

    // For PowerShell utilities, check pwsh availability
    if (spec.kind === "powershell") {
      const pwshPath = resolveExecutable("pwsh");
      if (!pwshPath) {
        const errorMsg =
          "PowerShell (pwsh) not found in PATH. Please install PowerShell 7+ and ensure it is available in your system PATH.";
        void vscode.window.showErrorMessage(errorMsg);
        return { success: false, error: errorMsg };
      }
    }

    // Resolve argument templates
    const resolvedArgs = execSpec.args.map((arg) => {
      let resolved = arg;
      // Replace ${extensionRoot}
      resolved = resolved.replace(
        /\$\{extensionRoot\}/g,
        context.extensionRoot,
      );
      // Replace ${workspaceFolder}
      resolved = resolved.replace(
        /\$\{workspaceFolder\}/g,
        context.workspaceRoot,
      );
      // Replace ${input:*} tokens
      resolved = resolved.replace(/\$\{input:([^}]+)\}/g, (_, inputId) => {
        const value = context.inputValues[inputId];
        return value !== undefined && value !== null ? String(value) : "";
      });
      return resolved;
    });

    // Build environment variables for external utilities
    const executionEnv: Record<string, string> = {};
    for (const [key, value] of Object.entries(process.env)) {
      if (value !== undefined) {
        executionEnv[key] = value;
      }
    }

    if (spec.kind === "external") {
      for (const [key, value] of Object.entries(spec.env)) {
        let resolvedValue = value;
        resolvedValue = resolvedValue.replace(
          /\$\{extensionRoot\}/g,
          context.extensionRoot,
        );
        resolvedValue = resolvedValue.replace(
          /\$\{workspaceFolder\}/g,
          context.workspaceRoot,
        );
        executionEnv[key] = resolvedValue;
      }
    }

    // Execute using ProcessExecution
    const execution = new vscode.ProcessExecution(
      execSpec.command,
      resolvedArgs,
      {
        cwd: context.workspaceRoot,
        env: executionEnv,
      },
    );

    const task = new vscode.Task(
      { type: "drm-copilot-utility", command: commandId },
      vscode.TaskScope.Workspace,
      commandId,
      "drm-copilot",
      execution,
    );

    await vscode.tasks.executeTask(task);

    return { success: true };
  } catch (error) {
    const errorMsg = `Utility dispatch failed: ${error instanceof Error ? error.message : String(error)}`;
    void vscode.window.showErrorMessage(errorMsg);
    return { success: false, error: errorMsg };
  }
}
