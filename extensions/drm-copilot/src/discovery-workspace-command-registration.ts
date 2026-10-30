import type * as vscode from "vscode";

import {
  promptForChoice,
  promptForList,
  promptForText,
  registerDiscoveryCommand,
} from "./discovery-command-registration";
import {
  DISCOVERY_ARTIFACT_TYPES,
  DISCOVERY_REPORT_TYPES,
  resolveRunDiscoveryDotnetAnalyzerToolInput,
  resolveRunDiscoveryInitToolInput,
  resolveRunDiscoveryReportToolInput,
  resolveRunDiscoveryRepoInventoryToolInput,
  resolveRunDiscoveryVstoAnalyzerToolInput,
  resolveValidateDiscoveryArtifactsToolInput,
  SYSTEM_ROLES,
} from "./mcp-tool-inputs-discovery";
import {
  CONFIGURATION_ACTIONS,
  resolveConfigureDiscoveryWorkspaceToolInput,
  resolveMigrateDiscoveryArtifactsToolInput,
  resolveRunDiscoveryDoctorToolInput,
  resolveTransferDiscoverySnapshotToolInput,
  TRANSFER_DIRECTIONS,
} from "./mcp-tool-inputs-discovery-authority";
import type { RepoAutomationCommandRegistrationOptions } from "./repo-automation-command-registration-types";
import type { RunDiscoveryAnalyzerInput } from "./repo-automation-execute-discovery";

/**
 * Workspace-level discovery commands: validate, initialize, inventory (three
 * analyzers), reports, doctor, configure, transfer and migrate. Each command
 * resolves direct arguments through the shared MCP resolver and prompts only
 * for the inputs its operation requires.
 */

const VALIDATE_TITLE = "drm-copilot: Validate Discovery Artifacts";
const INIT_TITLE = "drm-copilot: Run Discovery Init";
const REPORT_TITLE = "drm-copilot: Run Discovery Report";
const CONFIGURE_TITLE = "drm-copilot: Configure Discovery Workspace";
const TRANSFER_TITLE = "drm-copilot: Transfer Discovery Snapshot";
const MIGRATE_TITLE = "drm-copilot: Migrate Discovery Artifacts";

/** Collect the system identity shared by initialization and migration. */
async function promptForSystemIdentity(title: string): Promise<
  | {
      readonly systemId: string;
      readonly systemName: string;
      readonly systemRole: (typeof SYSTEM_ROLES)[number];
      readonly repositoryId: string;
    }
  | undefined
> {
  const systemId = await promptForText(title, "Enter the system identifier.");
  if (systemId === undefined) {
    return undefined;
  }
  const systemName = await promptForText(title, "Enter the system name.");
  if (systemName === undefined) {
    return undefined;
  }
  const systemRole = await promptForChoice(
    title,
    "Choose the system role.",
    SYSTEM_ROLES,
  );
  if (systemRole === undefined) {
    return undefined;
  }
  const repositoryId = await promptForText(
    title,
    "Enter the repository identifier.",
  );
  if (repositoryId === undefined) {
    return undefined;
  }
  return { systemId, systemName, systemRole, repositoryId };
}

function registerAnalyzer(
  options: RepoAutomationCommandRegistrationOptions,
  commandId: string,
  resolve: (
    rawInput: unknown,
    fallbackWorkspaceRoot?: string,
  ) => RunDiscoveryAnalyzerInput,
  invoke: (input: RunDiscoveryAnalyzerInput) => Promise<unknown>,
): vscode.Disposable {
  return registerDiscoveryCommand<RunDiscoveryAnalyzerInput>(options, {
    commandId,
    resolve,
    invoke,
    // Analyzers need no tool-specific input; they run against the workspace.
    interactive: (workspaceRoot) => Promise.resolve({ workspaceRoot }),
  });
}

/** Register the workspace-level discovery commands. */
export function registerDiscoveryWorkspaceCommands(
  options: RepoAutomationCommandRegistrationOptions,
): ReadonlyArray<vscode.Disposable> {
  const { service } = options;
  return [
    registerDiscoveryCommand(options, {
      commandId: "drmCopilotExtension.validateDiscoveryArtifacts",
      resolve: resolveValidateDiscoveryArtifactsToolInput,
      invoke: (input) => service.validateDiscoveryArtifacts(input),
      interactive: async (workspaceRoot) => {
        const artifactType = await promptForChoice(
          VALIDATE_TITLE,
          "Choose the artifact type.",
          DISCOVERY_ARTIFACT_TYPES,
        );
        if (artifactType === undefined) {
          return undefined;
        }
        // Whole-workspace validation takes the workspace itself as its path.
        const artifactPath = await promptForText(
          VALIDATE_TITLE,
          "Enter the artifact path.",
          artifactType === "all" ? "." : undefined,
        );
        if (artifactPath === undefined) {
          return undefined;
        }
        return { workspaceRoot, artifactType, artifactPath };
      },
    }),
    registerDiscoveryCommand(options, {
      commandId: "drmCopilotExtension.runDiscoveryInit",
      resolve: resolveRunDiscoveryInitToolInput,
      invoke: (input) => service.runDiscoveryInit(input),
      interactive: async (workspaceRoot) => {
        const identity = await promptForSystemIdentity(INIT_TITLE);
        return identity === undefined
          ? undefined
          : { workspaceRoot, ...identity };
      },
    }),
    registerAnalyzer(
      options,
      "drmCopilotExtension.runDiscoveryRepoInventory",
      resolveRunDiscoveryRepoInventoryToolInput,
      (input) => service.runDiscoveryRepoInventory(input),
    ),
    registerAnalyzer(
      options,
      "drmCopilotExtension.runDiscoveryDotnetAnalyzer",
      resolveRunDiscoveryDotnetAnalyzerToolInput,
      (input) => service.runDiscoveryDotnetAnalyzer(input),
    ),
    registerAnalyzer(
      options,
      "drmCopilotExtension.runDiscoveryVstoAnalyzer",
      resolveRunDiscoveryVstoAnalyzerToolInput,
      (input) => service.runDiscoveryVstoAnalyzer(input),
    ),
    registerDiscoveryCommand(options, {
      commandId: "drmCopilotExtension.runDiscoveryReport",
      resolve: resolveRunDiscoveryReportToolInput,
      invoke: (input) => service.runDiscoveryReport(input),
      interactive: async (workspaceRoot) => {
        const reportType = await promptForChoice(
          REPORT_TITLE,
          "Choose the report type.",
          DISCOVERY_REPORT_TYPES,
        );
        return reportType === undefined
          ? undefined
          : { workspaceRoot, reportType };
      },
    }),
    registerDiscoveryCommand(options, {
      commandId: "drmCopilotExtension.runDiscoveryDoctor",
      resolve: resolveRunDiscoveryDoctorToolInput,
      invoke: (input) => service.runDiscoveryDoctor(input),
      interactive: (workspaceRoot) => Promise.resolve({ workspaceRoot }),
    }),
    registerDiscoveryCommand(options, {
      commandId: "drmCopilotExtension.configureDiscoveryWorkspace",
      resolve: resolveConfigureDiscoveryWorkspaceToolInput,
      invoke: (input) => service.configureDiscoveryWorkspace(input),
      interactive: async (workspaceRoot) => {
        const configurationAction = await promptForChoice(
          CONFIGURE_TITLE,
          "Choose the configuration action.",
          CONFIGURATION_ACTIONS,
        );
        if (configurationAction === undefined) {
          return undefined;
        }
        // Deactivation names no profile; activation selects the profile to bind.
        if (configurationAction === "deactivate") {
          return { workspaceRoot, configurationAction };
        }
        const inputPath = await promptForText(
          CONFIGURE_TITLE,
          "Enter the workspace-relative profile path to activate.",
        );
        return inputPath === undefined
          ? undefined
          : { workspaceRoot, configurationAction, inputPath };
      },
    }),
    registerDiscoveryCommand(options, {
      commandId: "drmCopilotExtension.transferDiscoverySnapshot",
      resolve: resolveTransferDiscoverySnapshotToolInput,
      invoke: (input) => service.transferDiscoverySnapshot(input),
      interactive: async (workspaceRoot) => {
        const direction = await promptForChoice(
          TRANSFER_TITLE,
          "Choose the transfer direction.",
          TRANSFER_DIRECTIONS,
        );
        if (direction === undefined) {
          return undefined;
        }
        // Export selects identities; import names the manifest to read.
        if (direction === "export") {
          const selectedIds = await promptForList(
            TRANSFER_TITLE,
            "Enter the comma-separated identities to export.",
          );
          return selectedIds === undefined
            ? undefined
            : { workspaceRoot, direction, selectedIds };
        }
        const manifestPath = await promptForText(
          TRANSFER_TITLE,
          "Enter the workspace-relative snapshot manifest path.",
        );
        return manifestPath === undefined
          ? undefined
          : { workspaceRoot, direction, manifestPath };
      },
    }),
    registerDiscoveryCommand(options, {
      commandId: "drmCopilotExtension.migrateDiscoveryArtifacts",
      resolve: resolveMigrateDiscoveryArtifactsToolInput,
      invoke: (input) => service.migrateDiscoveryArtifacts(input),
      interactive: async (workspaceRoot) => {
        const destination = await promptForText(
          MIGRATE_TITLE,
          "Enter the workspace-relative destination root.",
        );
        if (destination === undefined) {
          return undefined;
        }
        const identity = await promptForSystemIdentity(MIGRATE_TITLE);
        if (identity === undefined) {
          return undefined;
        }
        const inputPath = await promptForText(
          MIGRATE_TITLE,
          "Enter the workspace-relative v1 source file.",
        );
        return inputPath === undefined
          ? undefined
          : { workspaceRoot, destination, ...identity, inputPath };
      },
    }),
  ];
}
