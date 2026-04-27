import * as vscode from "vscode";

import { registerRepoAutomationAdminCommands } from "./repo-automation-command-registration-admin";
import { registerRepoAutomationFeatureWorkflowCommands } from "./repo-automation-command-registration-feature-workflows";
import type { RepoAutomationCommandRegistrationOptions } from "./repo-automation-command-registration-types";

/**
 * Registers the interactive repo-automation workflow commands so `extension.ts`
 * can remain a thin activation coordinator.
 *
 * @param options Shared command-registration dependencies.
 * @returns The disposables that must be added to the extension subscriptions.
 */
export function registerRepoAutomationCommands(
  options: RepoAutomationCommandRegistrationOptions,
): ReadonlyArray<vscode.Disposable> {
  return [
    ...registerRepoAutomationAdminCommands(options),
    ...registerRepoAutomationFeatureWorkflowCommands(options),
  ];
}
