import * as vscode from "vscode";
import { getWorkspaceRoot } from "./command-runtime";
import {
  promptForChoice,
  promptForWorkspaceScanFolders,
  resolveWorkflowInvocation,
} from "./extension-command-helpers";
import type { RepoAutomationService } from "./repo-automation-service";
import { resolveRunPoshQCSuiteInvocation } from "./workflow-command-arguments";

interface PoshQcCommandRegistrationOptions {
  readonly output: vscode.OutputChannel;
  readonly service: RepoAutomationService;
}

interface PoshQcCommandDefinition {
  readonly commandId: string;
  readonly title: string;
  readonly runOperation: (input: {
    readonly workspaceRoot: string;
    readonly invocationId: string;
    readonly scanFolders?: ReadonlyArray<string>;
  }) => Promise<unknown>;
}

function registerPoshQcCommand(
  options: PoshQcCommandRegistrationOptions,
  definition: PoshQcCommandDefinition,
): vscode.Disposable {
  return vscode.commands.registerCommand(
    definition.commandId,
    async (...rawArgs: unknown[]) => {
      const invocation = resolveWorkflowInvocation(
        options.output,
        definition.commandId,
        () => resolveRunPoshQCSuiteInvocation(rawArgs),
      );
      const workspaceRoot = getWorkspaceRoot();
      if (invocation.mode === "direct") {
        await definition.runOperation({
          workspaceRoot,
          invocationId: definition.commandId,
          ...invocation.input,
        });
        return;
      }

      const scopeChoice = await promptForChoice(
        definition.title,
        "Choose the scan scope.",
        ["Scan entire workspace", "Select folders to scan"],
      );
      if (!scopeChoice) {
        return;
      }

      if (scopeChoice === "Select folders to scan") {
        const selectedFolders =
          await promptForWorkspaceScanFolders(workspaceRoot);
        if (!selectedFolders) {
          return;
        }

        await definition.runOperation({
          workspaceRoot,
          invocationId: definition.commandId,
          scanFolders: selectedFolders,
        });
        return;
      }

      await definition.runOperation({
        workspaceRoot,
        invocationId: definition.commandId,
      });
    },
  );
}

export function registerPoshQcCommands(
  options: PoshQcCommandRegistrationOptions,
): readonly [
  vscode.Disposable,
  vscode.Disposable,
  vscode.Disposable,
  vscode.Disposable,
] {
  return [
    registerPoshQcCommand(options, {
      commandId: "drmCopilotExtension.runPoshQCFormat",
      title: "drm-copilot: Run PoshQC Format",
      runOperation: (input) => options.service.runPoshQCFormat(input),
    }),
    registerPoshQcCommand(options, {
      commandId: "drmCopilotExtension.runPoshQCAnalyze",
      title: "drm-copilot: Run PoshQC Analyze",
      runOperation: (input) => options.service.runPoshQCAnalyze(input),
    }),
    registerPoshQcCommand(options, {
      commandId: "drmCopilotExtension.runPoshQCTest",
      title: "drm-copilot: Run PoshQC Test",
      runOperation: (input) => options.service.runPoshQCTest(input),
    }),
    registerPoshQcCommand(options, {
      commandId: "drmCopilotExtension.runPoshQCAnalyzeAutofix",
      title: "drm-copilot: Run PoshQC Analyze Autofix",
      runOperation: (input) => options.service.runPoshQCAnalyzeAutofix(input),
    }),
  ];
}
