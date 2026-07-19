import * as vscode from "vscode";

import { getWorkspaceRoot } from "./command-runtime";
import {
  promptForChoice,
  resolveWorkflowInvocation,
} from "./extension-command-helpers";
import type { RepoAutomationCommandRegistrationOptions } from "./repo-automation-command-registration-types";
import {
  DISCOVERY_ARTIFACT_TYPES,
  DISCOVERY_REPORT_TYPES,
  resolveRunDiscoveryDotnetAnalyzerToolInput,
  resolveRunDiscoveryInitToolInput,
  resolveRunDiscoveryReportToolInput,
  resolveRunDiscoveryRepoInventoryToolInput,
  resolveRunDiscoveryScenarioGenerationToolInput,
  resolveRunDiscoveryVstoAnalyzerToolInput,
  resolveValidateDiscoveryArtifactsToolInput,
} from "./mcp-tool-inputs-discovery";

/**
 * Prompts for a required non-empty text value.
 *
 * @returns The trimmed value, or `undefined` when cancelled or left blank.
 */
async function promptForText(
  title: string,
  prompt: string,
): Promise<string | undefined> {
  const value = await vscode.window.showInputBox({
    title,
    prompt,
    ignoreFocusOut: true,
  });
  if (value === undefined) {
    return undefined;
  }
  const trimmed = value.trim();
  return trimmed.length === 0 ? undefined : trimmed;
}

/** Whether a direct (non-interactive) invocation was supplied. */
function isDirectInvocation(rawArgs: readonly unknown[]): boolean {
  return rawArgs.length > 0;
}

function registerValidateDiscoveryArtifactsCommand(
  options: RepoAutomationCommandRegistrationOptions,
): vscode.Disposable {
  const commandId = "drmCopilotExtension.validateDiscoveryArtifacts";
  return vscode.commands.registerCommand(
    commandId,
    async (...rawArgs: unknown[]) => {
      const workspaceRoot = getWorkspaceRoot();
      const invocation = resolveWorkflowInvocation(
        options.output,
        commandId,
        () =>
          isDirectInvocation(rawArgs)
            ? {
                mode: "direct",
                input: resolveValidateDiscoveryArtifactsToolInput(
                  rawArgs[0],
                  workspaceRoot,
                ),
              }
            : { mode: "interactive" },
      );
      if (invocation.mode === "direct") {
        await options.service.validateDiscoveryArtifacts({
          ...invocation.input,
          invocationId: commandId,
        });
        return;
      }

      const artifactType = await promptForChoice(
        "drm-copilot: Validate Discovery Artifacts",
        "Choose the artifact type.",
        DISCOVERY_ARTIFACT_TYPES,
      );
      if (!artifactType) {
        return;
      }
      const artifactPath = await promptForText(
        "drm-copilot: Validate Discovery Artifacts",
        "Enter the artifact path.",
      );
      if (!artifactPath) {
        return;
      }
      await options.service.validateDiscoveryArtifacts({
        workspaceRoot,
        invocationId: commandId,
        artifactType,
        artifactPath,
      });
    },
  );
}

function registerRunDiscoveryInitCommand(
  options: RepoAutomationCommandRegistrationOptions,
): vscode.Disposable {
  const commandId = "drmCopilotExtension.runDiscoveryInit";
  return vscode.commands.registerCommand(
    commandId,
    async (...rawArgs: unknown[]) => {
      const workspaceRoot = getWorkspaceRoot();
      const invocation = resolveWorkflowInvocation(
        options.output,
        commandId,
        () =>
          isDirectInvocation(rawArgs)
            ? {
                mode: "direct",
                input: resolveRunDiscoveryInitToolInput(
                  rawArgs[0],
                  workspaceRoot,
                ),
              }
            : { mode: "interactive" },
      );
      if (invocation.mode === "direct") {
        await options.service.runDiscoveryInit({
          ...invocation.input,
          invocationId: commandId,
        });
        return;
      }

      const targetDir = await promptForText(
        "drm-copilot: Run Discovery Init",
        "Enter the target directory to scaffold.",
      );
      if (!targetDir) {
        return;
      }
      await options.service.runDiscoveryInit({
        workspaceRoot,
        invocationId: commandId,
        targetDir,
      });
    },
  );
}

function registerAnalyzerCommand(
  options: RepoAutomationCommandRegistrationOptions,
  commandId: string,
  resolveInput: (
    rawInput: unknown,
    fallbackWorkspaceRoot?: string,
  ) => Parameters<typeof options.service.runDiscoveryRepoInventory>[0],
  invoke: (
    input: Parameters<typeof options.service.runDiscoveryRepoInventory>[0],
  ) => Promise<unknown>,
): vscode.Disposable {
  return vscode.commands.registerCommand(
    commandId,
    async (...rawArgs: unknown[]) => {
      const workspaceRoot = getWorkspaceRoot();
      const invocation = resolveWorkflowInvocation(
        options.output,
        commandId,
        () =>
          isDirectInvocation(rawArgs)
            ? { mode: "direct", input: resolveInput(rawArgs[0], workspaceRoot) }
            : { mode: "interactive" },
      );
      if (invocation.mode === "direct") {
        await invoke({ ...invocation.input, invocationId: commandId });
        return;
      }
      // No tool-specific fields are required; run against the resolved workspace.
      await invoke({ workspaceRoot, invocationId: commandId });
    },
  );
}

function registerRunDiscoveryScenarioGenerationCommand(
  options: RepoAutomationCommandRegistrationOptions,
): vscode.Disposable {
  const commandId = "drmCopilotExtension.runDiscoveryScenarioGeneration";
  return vscode.commands.registerCommand(
    commandId,
    async (...rawArgs: unknown[]) => {
      const workspaceRoot = getWorkspaceRoot();
      const invocation = resolveWorkflowInvocation(
        options.output,
        commandId,
        () =>
          isDirectInvocation(rawArgs)
            ? {
                mode: "direct",
                input: resolveRunDiscoveryScenarioGenerationToolInput(
                  rawArgs[0],
                  workspaceRoot,
                ),
              }
            : { mode: "interactive" },
      );
      if (invocation.mode === "direct") {
        await options.service.runDiscoveryScenarioGeneration({
          ...invocation.input,
          invocationId: commandId,
        });
        return;
      }

      const featureContract = await promptForText(
        "drm-copilot: Run Discovery Scenario Generation",
        "Enter the feature-contract path.",
      );
      if (!featureContract) {
        return;
      }
      const parityMatrix = await promptForText(
        "drm-copilot: Run Discovery Scenario Generation",
        "Enter the parity-matrix path.",
      );
      if (!parityMatrix) {
        return;
      }
      const runtimeCharacterization = await promptForText(
        "drm-copilot: Run Discovery Scenario Generation",
        "Enter the runtime-characterization path.",
      );
      if (!runtimeCharacterization) {
        return;
      }
      await options.service.runDiscoveryScenarioGeneration({
        workspaceRoot,
        invocationId: commandId,
        featureContract,
        parityMatrix,
        runtimeCharacterization,
      });
    },
  );
}

async function promptReportInteractive(
  options: RepoAutomationCommandRegistrationOptions,
  commandId: string,
  workspaceRoot: string,
): Promise<void> {
  const reportType = await promptForChoice(
    "drm-copilot: Run Discovery Report",
    "Choose the report type.",
    DISCOVERY_REPORT_TYPES,
  );
  if (!reportType) {
    return;
  }
  if (reportType === "completion") {
    const coverageInput = await promptForText(
      "drm-copilot: Run Discovery Report",
      "Enter the coverage-ledger input path.",
    );
    if (!coverageInput) {
      return;
    }
    const parityInput = await promptForText(
      "drm-copilot: Run Discovery Report",
      "Enter the parity-matrix input path.",
    );
    if (!parityInput) {
      return;
    }
    await options.service.runDiscoveryReport({
      workspaceRoot,
      invocationId: commandId,
      reportType,
      coverageInput,
      parityInput,
    });
    return;
  }
  const inputPath = await promptForText(
    "drm-copilot: Run Discovery Report",
    "Enter the report input path.",
  );
  if (!inputPath) {
    return;
  }
  await options.service.runDiscoveryReport({
    workspaceRoot,
    invocationId: commandId,
    reportType,
    inputPath,
  });
}

function registerRunDiscoveryReportCommand(
  options: RepoAutomationCommandRegistrationOptions,
): vscode.Disposable {
  const commandId = "drmCopilotExtension.runDiscoveryReport";
  return vscode.commands.registerCommand(
    commandId,
    async (...rawArgs: unknown[]) => {
      const workspaceRoot = getWorkspaceRoot();
      const invocation = resolveWorkflowInvocation(
        options.output,
        commandId,
        () =>
          isDirectInvocation(rawArgs)
            ? {
                mode: "direct",
                input: resolveRunDiscoveryReportToolInput(
                  rawArgs[0],
                  workspaceRoot,
                ),
              }
            : { mode: "interactive" },
      );
      if (invocation.mode === "direct") {
        await options.service.runDiscoveryReport({
          ...invocation.input,
          invocationId: commandId,
        });
        return;
      }
      await promptReportInteractive(options, commandId, workspaceRoot);
    },
  );
}

/**
 * Registers the seven discovery VS Code commands, each a front-end over the
 * shared {@link RepoAutomationCommandRegistrationOptions.service} method with
 * direct-argument and interactive-prompt invocation paths.
 *
 * @param options The shared registration context (context, output, service).
 * @returns The registered command disposables.
 */
export function registerDiscoveryCommands(
  options: RepoAutomationCommandRegistrationOptions,
): ReadonlyArray<vscode.Disposable> {
  return [
    registerValidateDiscoveryArtifactsCommand(options),
    registerRunDiscoveryInitCommand(options),
    registerAnalyzerCommand(
      options,
      "drmCopilotExtension.runDiscoveryRepoInventory",
      resolveRunDiscoveryRepoInventoryToolInput,
      (input) => options.service.runDiscoveryRepoInventory(input),
    ),
    registerAnalyzerCommand(
      options,
      "drmCopilotExtension.runDiscoveryDotnetAnalyzer",
      resolveRunDiscoveryDotnetAnalyzerToolInput,
      (input) => options.service.runDiscoveryDotnetAnalyzer(input),
    ),
    registerAnalyzerCommand(
      options,
      "drmCopilotExtension.runDiscoveryVstoAnalyzer",
      resolveRunDiscoveryVstoAnalyzerToolInput,
      (input) => options.service.runDiscoveryVstoAnalyzer(input),
    ),
    registerRunDiscoveryScenarioGenerationCommand(options),
    registerRunDiscoveryReportCommand(options),
  ];
}
