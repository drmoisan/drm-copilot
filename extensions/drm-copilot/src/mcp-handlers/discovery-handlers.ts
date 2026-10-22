import {
  resolveCreateDiscoveryArtifactToolInput,
  resolveLinkDiscoveryEvidenceToolInput,
  resolveRunDiscoveryDotnetAnalyzerToolInput,
  resolveRunDiscoveryInitToolInput,
  resolveRunDiscoveryReportToolInput,
  resolveRunDiscoveryRepoInventoryToolInput,
  resolveRunDiscoveryScenarioGenerationToolInput,
  resolveRunDiscoveryVstoAnalyzerToolInput,
  resolveUpdateDiscoveryArtifactToolInput,
  resolveValidateDiscoveryArtifactsToolInput,
} from "../mcp-tool-inputs-discovery";
import {
  isDiscoveryRole,
  resolveConfigureDiscoveryWorkspaceToolInput,
  resolveFinalizeDiscoveryAgentToolInput,
  resolveImportDiscoveryInventoryToolInput,
  resolveMigrateDiscoveryArtifactsToolInput,
  resolvePrepareDiscoveryAgentToolInput,
  resolveReadDiscoverySourceToolInput,
  resolveRunDiscoveryDoctorToolInput,
  resolveTransferDiscoverySnapshotToolInput,
} from "../mcp-tool-inputs-discovery-authority";
import type {
  RepoAutomationExecutionResult,
  RepoAutomationService,
} from "../repo-automation-service";

type Handler = (
  rawInput: unknown,
  service: RepoAutomationService,
) => Promise<RepoAutomationExecutionResult>;

/** Build a handler that resolves raw arguments and delegates to one service method. */
function handler<TInput>(
  resolve: (rawInput: unknown) => TInput,
  invoke: (
    service: RepoAutomationService,
    input: TInput,
  ) => Promise<RepoAutomationExecutionResult>,
): Handler {
  return async (rawInput, service) => invoke(service, resolve(rawInput));
}

export const handleValidateDiscoveryArtifacts = handler(
  resolveValidateDiscoveryArtifactsToolInput,
  (service, input) => service.validateDiscoveryArtifacts(input),
);
export const handleRunDiscoveryInit = handler(
  resolveRunDiscoveryInitToolInput,
  (service, input) => service.runDiscoveryInit(input),
);
export const handleRunDiscoveryRepoInventory = handler(
  resolveRunDiscoveryRepoInventoryToolInput,
  (service, input) => service.runDiscoveryRepoInventory(input),
);
export const handleRunDiscoveryDotnetAnalyzer = handler(
  resolveRunDiscoveryDotnetAnalyzerToolInput,
  (service, input) => service.runDiscoveryDotnetAnalyzer(input),
);
export const handleRunDiscoveryVstoAnalyzer = handler(
  resolveRunDiscoveryVstoAnalyzerToolInput,
  (service, input) => service.runDiscoveryVstoAnalyzer(input),
);
export const handleRunDiscoveryScenarioGeneration = handler(
  resolveRunDiscoveryScenarioGenerationToolInput,
  (service, input) => service.runDiscoveryScenarioGeneration(input),
);
export const handleRunDiscoveryReport = handler(
  resolveRunDiscoveryReportToolInput,
  (service, input) => service.runDiscoveryReport(input),
);
export const handleConfigureDiscoveryWorkspace = handler(
  resolveConfigureDiscoveryWorkspaceToolInput,
  (service, input) => service.configureDiscoveryWorkspace(input),
);
export const handleCreateDiscoveryArtifact = handler(
  resolveCreateDiscoveryArtifactToolInput,
  (service, input) => service.createDiscoveryArtifact(input),
);

/** Decision approval is a root action; a discovery role may only replace. */
export const handleUpdateDiscoveryArtifact: Handler = async (
  rawInput,
  service,
) => {
  const input = resolveUpdateDiscoveryArtifactToolInput(rawInput);
  const role = service.discoveryRole?.() ?? null;
  if (input.updateAction === "approve-decision" && isDiscoveryRole(role)) {
    throw new Error(
      `DISCOVERY_ROLE_DENIED: approve-decision is a root-only update and is not available to the ${role} role.`,
    );
  }
  return service.updateDiscoveryArtifact(input);
};

export const handleLinkDiscoveryEvidence = handler(
  resolveLinkDiscoveryEvidenceToolInput,
  (service, input) => service.linkDiscoveryEvidence(input),
);
export const handleTransferDiscoverySnapshot = handler(
  resolveTransferDiscoverySnapshotToolInput,
  (service, input) => service.transferDiscoverySnapshot(input),
);
export const handleImportDiscoveryInventory = handler(
  resolveImportDiscoveryInventoryToolInput,
  (service, input) => service.importDiscoveryInventory(input),
);
export const handleMigrateDiscoveryArtifacts = handler(
  resolveMigrateDiscoveryArtifactsToolInput,
  (service, input) => service.migrateDiscoveryArtifacts(input),
);
export const handleRunDiscoveryDoctor = handler(
  resolveRunDiscoveryDoctorToolInput,
  (service, input) => service.runDiscoveryDoctor(input),
);
export const handleReadDiscoverySource = handler(
  resolveReadDiscoverySourceToolInput,
  (service, input) => service.readDiscoverySource(input),
);
export const handlePrepareDiscoveryAgent = handler(
  resolvePrepareDiscoveryAgentToolInput,
  (service, input) => service.prepareDiscoveryAgent(input),
);
export const handleFinalizeDiscoveryAgent = handler(
  resolveFinalizeDiscoveryAgentToolInput,
  (service, input) => service.finalizeDiscoveryAgent(input),
);
