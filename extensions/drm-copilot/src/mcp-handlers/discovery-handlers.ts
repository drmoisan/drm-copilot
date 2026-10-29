import type { ControlledTool } from "../discovery-authorization-record";
import { admitControlledToolCall } from "../mcp-discovery-authorization-gate";
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
  resolveConfigureDiscoveryWorkspaceToolInput,
  resolveDiscoveryCapabilitySentinelToolInput,
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

/**
 * Build a handler for a controlled tool: the one-use record the host gate
 * issued for this call (a tool authorization for a call carrying
 * `invocation_ref`, a root grant otherwise) is consumed before the input is
 * resolved, and the consumed reference travels in the resolved input.
 */
function controlled<TInput>(
  tool: ControlledTool,
  resolve: (rawInput: unknown) => TInput,
  invoke: (
    service: RepoAutomationService,
    input: TInput,
  ) => Promise<RepoAutomationExecutionResult>,
): Handler {
  return async (rawInput, service) =>
    invoke(service, resolve(admitControlledToolCall(tool, rawInput, service)));
}

export const handleValidateDiscoveryArtifacts = controlled(
  "validate_discovery_artifacts",
  resolveValidateDiscoveryArtifactsToolInput,
  (service, input) => service.validateDiscoveryArtifacts(input),
);
export const handleRunDiscoveryInit = handler(
  resolveRunDiscoveryInitToolInput,
  (service, input) => service.runDiscoveryInit(input),
);
export const handleRunDiscoveryRepoInventory = controlled(
  "run_discovery_repo_inventory",
  resolveRunDiscoveryRepoInventoryToolInput,
  (service, input) => service.runDiscoveryRepoInventory(input),
);
export const handleRunDiscoveryDotnetAnalyzer = controlled(
  "run_discovery_dotnet_analyzer",
  resolveRunDiscoveryDotnetAnalyzerToolInput,
  (service, input) => service.runDiscoveryDotnetAnalyzer(input),
);
export const handleRunDiscoveryVstoAnalyzer = controlled(
  "run_discovery_vsto_analyzer",
  resolveRunDiscoveryVstoAnalyzerToolInput,
  (service, input) => service.runDiscoveryVstoAnalyzer(input),
);
export const handleRunDiscoveryScenarioGeneration = controlled(
  "run_discovery_scenario_generation",
  resolveRunDiscoveryScenarioGenerationToolInput,
  (service, input) => service.runDiscoveryScenarioGeneration(input),
);
export const handleRunDiscoveryReport = controlled(
  "run_discovery_report",
  resolveRunDiscoveryReportToolInput,
  (service, input) => service.runDiscoveryReport(input),
);
export const handleConfigureDiscoveryWorkspace = handler(
  resolveConfigureDiscoveryWorkspaceToolInput,
  (service, input) => service.configureDiscoveryWorkspace(input),
);
export const handleCreateDiscoveryArtifact = controlled(
  "create_discovery_artifact",
  resolveCreateDiscoveryArtifactToolInput,
  (service, input) => service.createDiscoveryArtifact(input),
);

/**
 * Decision approval is a root action; a call bound to a protected invocation
 * (a specialist's call) may only replace. The check precedes the authorization
 * gate so a forbidden approval is named as such and consumes no record.
 */
export const handleUpdateDiscoveryArtifact: Handler = async (
  rawInput,
  service,
) => {
  const input = resolveUpdateDiscoveryArtifactToolInput(rawInput);
  if (
    input.updateAction === "approve-decision" &&
    input.invocationRef !== undefined
  ) {
    throw new Error(
      `DISCOVERY_ROOT_ONLY: approve-decision is a root-only update and is not available to a call bound to invocation ${input.invocationRef}.`,
    );
  }
  const admitted = admitControlledToolCall(
    "update_discovery_artifact",
    rawInput,
    service,
  );
  return service.updateDiscoveryArtifact(
    resolveUpdateDiscoveryArtifactToolInput(admitted),
  );
};

export const handleLinkDiscoveryEvidence = controlled(
  "link_discovery_evidence",
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
export const handleReadDiscoverySource = controlled(
  "read_discovery_source",
  resolveReadDiscoverySourceToolInput,
  (service, input) => service.readDiscoverySource(input),
);
export const handlePrepareDiscoveryAgent = handler(
  resolvePrepareDiscoveryAgentToolInput,
  (service, input) => service.prepareDiscoveryAgent(input),
);
export const handleFinalizeDiscoveryAgent = controlled(
  "finalize_discovery_agent",
  resolveFinalizeDiscoveryAgentToolInput,
  (service, input) => service.finalizeDiscoveryAgent(input),
);

/**
 * The sentinel tool consumes the one-use sentinel grant the host gate recorded
 * for this call and reports what the host observed; it is never gated by an
 * authorization or a root grant, because the observation is its evidence.
 */
export const handleDiscoveryCapabilitySentinel: Handler = async (
  rawInput,
  service,
) => {
  if (service.discoveryCapabilitySentinel === undefined) {
    throw new Error(
      "DISCOVERY_SENTINEL_UNAVAILABLE: this service cannot consume sentinel observations.",
    );
  }
  return service.discoveryCapabilitySentinel(
    resolveDiscoveryCapabilitySentinelToolInput(rawInput),
  );
};
