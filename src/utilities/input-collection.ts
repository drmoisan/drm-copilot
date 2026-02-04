import * as vscode from "vscode";

import type { TaskCommandId } from "../task-command-map";
import {
  getDefaultInputValuesForCommand,
  getTaskInputDefinition,
  getTaskInputIdsForCommand,
} from "../task-command-map";

/**
 * Collects any `${input:<id>}` values required by a command.
 *
 * Purpose:
 *     Tasks in this extension are provider-backed and don't participate in VS Code's
 *     tasks.json input system. When a task argument references `${input:<id>}` tokens,
 *     we prompt directly via `vscode.window`.
 *
 * Args:
 *     commandId (TaskCommandId): The command whose inputs should be collected.
 *
 * Returns:
 *     Record<string, string> | undefined: The resolved input values, or undefined
 *     when the user cancels any prompt.
 *
 * Side Effects:
 *     Prompts the user via VS Code UI APIs.
 */
export async function collectCommandInputs(
  commandId: TaskCommandId,
): Promise<Record<string, string> | undefined> {
  const inputIds = getTaskInputIdsForCommand(commandId);
  if (inputIds.length === 0) {
    return {};
  }

  const inputValues = getDefaultInputValuesForCommand(commandId);

  // Prompt for each required input in a stable order (as discovered in args).
  for (const inputId of inputIds) {
    const def = getTaskInputDefinition(inputId);
    if (!def) {
      vscode.window.showErrorMessage(
        `Task input is referenced but not defined: ${inputId} (command: ${commandId})`,
      );
      return undefined;
    }

    if (def.type === "promptString") {
      const value = await vscode.window.showInputBox({
        prompt: def.description,
        value: inputValues[inputId] ?? def.default,
      });
      if (value === undefined) {
        return undefined;
      }
      inputValues[inputId] = value;
      continue;
    }

    if (def.type === "pickString") {
      const options = def.options ?? [];
      const picked = await vscode.window.showQuickPick(options, {
        placeHolder: def.description,
      });
      if (picked === undefined) {
        return undefined;
      }
      inputValues[inputId] = picked;
      continue;
    }
  }

  return inputValues;
}
