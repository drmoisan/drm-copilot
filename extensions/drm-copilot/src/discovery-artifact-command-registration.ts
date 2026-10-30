import type * as vscode from "vscode";

import {
  promptForChoice,
  promptForList,
  promptForText,
  registerDiscoveryCommand,
} from "./discovery-command-registration";
import {
  ACCEPTANCE_KINDS,
  CREATE_ARTIFACT_KINDS,
  DISCOVERY_ARTIFACT_KINDS,
  resolveCreateDiscoveryArtifactToolInput,
  resolveLinkDiscoveryEvidenceToolInput,
  resolveRunDiscoveryScenarioGenerationToolInput,
} from "./mcp-tool-inputs-discovery";
import type { RepoAutomationCommandRegistrationOptions } from "./repo-automation-command-registration-types";

/**
 * Artifact-level discovery commands: create a draft, link evidence and
 * generate acceptance scenarios. Each command resolves direct arguments
 * through the shared MCP resolver and prompts only for the inputs its
 * operation requires; updates by compare-and-swap stay a service operation.
 */

const CREATE_TITLE = "drm-copilot: Create Discovery Artifact";
const LINK_TITLE = "drm-copilot: Link Discovery Evidence";
const GENERATE_TITLE = "drm-copilot: Run Discovery Scenario Generation";

/** Register the artifact-level discovery commands. */
export function registerDiscoveryArtifactCommands(
  options: RepoAutomationCommandRegistrationOptions,
): ReadonlyArray<vscode.Disposable> {
  const { service } = options;
  return [
    registerDiscoveryCommand(options, {
      commandId: "drmCopilotExtension.createDiscoveryArtifact",
      resolve: resolveCreateDiscoveryArtifactToolInput,
      invoke: (input) => service.createDiscoveryArtifact(input),
      interactive: async (workspaceRoot) => {
        const artifactKind = await promptForChoice(
          CREATE_TITLE,
          "Choose the draft kind.",
          CREATE_ARTIFACT_KINDS,
        );
        if (artifactKind === undefined) {
          return undefined;
        }
        // Each draft kind carries its own identity fields.
        if (artifactKind === "feature-contract") {
          const featureId = await promptForText(
            CREATE_TITLE,
            "Enter the feature identifier.",
          );
          if (featureId === undefined) {
            return undefined;
          }
          const name = await promptForText(
            CREATE_TITLE,
            "Enter the feature name.",
          );
          return name === undefined
            ? undefined
            : { workspaceRoot, artifactKind, featureId, name };
        }
        const scenarioId = await promptForText(
          CREATE_TITLE,
          "Enter the scenario identifier.",
        );
        if (scenarioId === undefined) {
          return undefined;
        }
        const featureIds = await promptForList(
          CREATE_TITLE,
          "Enter the comma-separated covered feature identifiers.",
        );
        return featureIds === undefined
          ? undefined
          : { workspaceRoot, artifactKind, scenarioId, featureIds };
      },
    }),
    registerDiscoveryCommand(options, {
      commandId: "drmCopilotExtension.linkDiscoveryEvidence",
      resolve: resolveLinkDiscoveryEvidenceToolInput,
      invoke: (input) => service.linkDiscoveryEvidence(input),
      interactive: async (workspaceRoot) => {
        const artifactKind = await promptForChoice(
          LINK_TITLE,
          "Choose the target artifact kind.",
          DISCOVERY_ARTIFACT_KINDS,
        );
        if (artifactKind === undefined) {
          return undefined;
        }
        const artifactId = await promptForText(
          LINK_TITLE,
          "Enter the target artifact identifier.",
        );
        if (artifactId === undefined) {
          return undefined;
        }
        const evidencePath = await promptForText(
          LINK_TITLE,
          "Enter the workspace-relative evidence path.",
        );
        if (evidencePath === undefined) {
          return undefined;
        }
        const expectedSha256 = await promptForText(
          LINK_TITLE,
          "Enter the current target artifact digest (SHA-256).",
        );
        return expectedSha256 === undefined
          ? undefined
          : {
              workspaceRoot,
              artifactKind,
              artifactId,
              evidencePath,
              expectedSha256,
            };
      },
    }),
    registerDiscoveryCommand(options, {
      commandId: "drmCopilotExtension.runDiscoveryScenarioGeneration",
      resolve: resolveRunDiscoveryScenarioGenerationToolInput,
      invoke: (input) => service.runDiscoveryScenarioGeneration(input),
      interactive: async (workspaceRoot) => {
        const acceptanceKind = await promptForChoice(
          GENERATE_TITLE,
          "Choose the acceptance specification kind.",
          ACCEPTANCE_KINDS,
        );
        return acceptanceKind === undefined
          ? undefined
          : { workspaceRoot, acceptanceKind };
      },
    }),
  ];
}
