import * as vscode from "vscode";

import { getWorkspaceRoot } from "./command-runtime";
import {
  promptForChoice,
  resolveWorkflowInvocation,
} from "./extension-command-helpers";
import type { RepoAutomationCommandRegistrationOptions } from "./repo-automation-command-registration-types";
import { registerDiscoveryArtifactCommands } from "./discovery-artifact-command-registration";
import { registerDiscoveryWorkspaceCommands } from "./discovery-workspace-command-registration";

/**
 * Shared registration plumbing for the discovery VS Code commands.
 *
 * Every discovery command is a thin front-end over one method of the shared
 * service contract: a direct invocation passes structured arguments through
 * the same MCP input resolver the server uses, an interactive invocation
 * prompts only for the inputs the operation requires, and cancellation at any
 * prompt resolves without calling the service. No command composes a request,
 * computes discovery semantics or creates a terminal. Prepare, finalize and
 * bounded source reads are agent/service operations and have no command.
 */

/** One command: its resolver, its service call and its interactive collector. */
export interface DiscoveryCommandSpec<TInput extends object> {
  readonly commandId: string;
  readonly resolve: (
    rawInput: unknown,
    fallbackWorkspaceRoot?: string,
  ) => TInput;
  readonly invoke: (
    input: TInput & { readonly invocationId: string },
  ) => Promise<unknown>;
  /** Collect the required inputs interactively; `undefined` means cancelled. */
  readonly interactive: (workspaceRoot: string) => Promise<TInput | undefined>;
}

/**
 * Prompts for a required non-empty text value.
 *
 * @returns The trimmed value, or `undefined` when cancelled or left blank.
 */
export async function promptForText(
  title: string,
  prompt: string,
  value?: string,
): Promise<string | undefined> {
  const entered = await vscode.window.showInputBox({
    title,
    prompt,
    ignoreFocusOut: true,
    ...(value === undefined ? {} : { value }),
  });
  if (entered === undefined) {
    return undefined;
  }
  const trimmed = entered.trim();
  return trimmed.length === 0 ? undefined : trimmed;
}

/**
 * Prompts for a comma-separated list of identifiers or paths.
 *
 * @returns The non-empty trimmed entries, or `undefined` when cancelled or blank.
 */
export async function promptForList(
  title: string,
  prompt: string,
): Promise<ReadonlyArray<string> | undefined> {
  const text = await promptForText(title, prompt);
  if (text === undefined) {
    return undefined;
  }
  const entries = text
    .split(",")
    .map((entry) => entry.trim())
    .filter((entry) => entry.length > 0);
  return entries.length === 0 ? undefined : entries;
}

export { promptForChoice };

/** Whether a direct (non-interactive) invocation was supplied. */
export function isDirectInvocation(rawArgs: readonly unknown[]): boolean {
  return rawArgs.length > 0;
}

/**
 * Register one discovery command from its specification.
 *
 * Direct invocations resolve the first argument through the MCP resolver with
 * the current workspace as the fallback root; interactive invocations collect
 * only the required inputs and stop silently on cancellation.
 */
export function registerDiscoveryCommand<TInput extends object>(
  options: RepoAutomationCommandRegistrationOptions,
  spec: DiscoveryCommandSpec<TInput>,
): vscode.Disposable {
  return vscode.commands.registerCommand(
    spec.commandId,
    async (...rawArgs: unknown[]) => {
      const workspaceRoot = getWorkspaceRoot();
      const invocation = resolveWorkflowInvocation(
        options.output,
        spec.commandId,
        () =>
          isDirectInvocation(rawArgs)
            ? { mode: "direct", input: spec.resolve(rawArgs[0], workspaceRoot) }
            : { mode: "interactive" },
      );
      if (invocation.mode === "direct") {
        await spec.invoke({
          ...invocation.input,
          invocationId: spec.commandId,
        });
        return;
      }
      const input = await spec.interactive(workspaceRoot);
      if (input === undefined) {
        return;
      }
      await spec.invoke({ ...input, invocationId: spec.commandId });
    },
  );
}

/**
 * Registers every discovery VS Code command: the workspace-level operations
 * (validate, initialize, inventory, reports, doctor, configure, transfer,
 * migrate) and the artifact operations (create, link, generate).
 *
 * @param options The shared registration context (context, output, service).
 * @returns The registered command disposables.
 */
export function registerDiscoveryCommands(
  options: RepoAutomationCommandRegistrationOptions,
): ReadonlyArray<vscode.Disposable> {
  return [
    ...registerDiscoveryWorkspaceCommands(options),
    ...registerDiscoveryArtifactCommands(options),
  ];
}
