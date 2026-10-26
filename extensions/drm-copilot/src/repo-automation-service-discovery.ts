/**
 * Discovery operations of the shared repo-automation service.
 *
 * Every method composes one closed v2 `service-request` and hands it to the
 * fixed installed runtime through the operation adapters; no schema, coverage,
 * parity or approval semantics are computed here. Prepare and finalize add the
 * protected-store steps around the runtime call through an injected
 * {@link DiscoveryAuthorityProvider}. The extension and the standalone MCP
 * server both use this one implementation.
 */

import type { CommandOutput } from "./command-runtime";
import {
  createNodeDiscoveryAuthorityProvider,
  type DiscoveryAuthorityProvider,
} from "./discovery-authority-provider";
import type { DiscoveryRuntimeDependencies } from "./discovery-runtime";
import type { DiscoveryRequestInputs } from "./discovery-service-types";
import {
  runDiscoveryDotnetAnalyzer,
  runDiscoveryInit,
  runDiscoveryOperation,
  runDiscoveryRepoInventory,
  runDiscoveryReport,
  runDiscoveryScenarioGeneration,
  runDiscoveryVstoAnalyzer,
  runValidateDiscoveryArtifacts,
  type RunDiscoveryAnalyzerInput,
  type RunDiscoveryInitInput,
  type RunDiscoveryReportInput,
  type RunDiscoveryScenarioGenerationInput,
  type ValidateDiscoveryArtifactsInput,
} from "./repo-automation-execute-discovery";
import type { RepoAutomationExecutionResult } from "./repo-automation-service-contract";
import {
  finalizeDiscoveryAgentOperation,
  prepareDiscoveryAgentOperation,
  projectDoctorCapability,
} from "./repo-automation-service-discovery-agent";
import type {
  ConfigureDiscoveryWorkspaceInput,
  CreateDiscoveryArtifactInput,
  DiscoveryGrantedInput,
  FinalizeDiscoveryAgentInput,
  ImportDiscoveryInventoryInput,
  LinkDiscoveryEvidenceInput,
  MigrateDiscoveryArtifactsInput,
  PrepareDiscoveryAgentInput,
  ReadDiscoverySourceInput,
  RunDiscoveryDoctorInput,
  TransferDiscoverySnapshotInput,
  UpdateDiscoveryArtifactInput,
} from "./repo-automation-service-discovery-types";

export interface DiscoveryServiceDeps {
  /** Runtime launcher/interpreter seams; production uses the Node defaults. */
  readonly runtime?: DiscoveryRuntimeDependencies;
  /** Protected-store and trusted-context provider; production reads the host. */
  readonly authority?: DiscoveryAuthorityProvider;
}

type InputValue = string | number | boolean | null | ReadonlyArray<string>;

/** Drop undefined members so only supplied values become request inputs. */
function inputs(
  entries: ReadonlyArray<readonly [string, unknown]>,
): DiscoveryRequestInputs {
  const result: Record<string, InputValue> = {};
  // Only supplied values travel; the runtime applies its own defaults.
  for (const [key, value] of entries) {
    if (value !== undefined) {
      result[key] = value as InputValue;
    }
  }
  return result;
}

/** Grant references select the agent-output mode; root requests stay structural. */
function granted(input: DiscoveryGrantedInput) {
  return {
    mode:
      input.invocationRef === undefined
        ? ("structural" as const)
        : ("agent-output" as const),
    ...(input.invocationRef === undefined
      ? {}
      : { invocationRef: input.invocationRef }),
    ...(input.authorizationRef === undefined
      ? {}
      : { authorizationRef: input.authorizationRef }),
    write: input.write ?? false,
    dryRun: input.dryRun ?? false,
  };
}

/** Base class carrying the discovery half of the shared service contract. */
export class DiscoveryServiceBase {
  protected readonly discoveryOutput: CommandOutput;
  private readonly runtime: DiscoveryRuntimeDependencies;
  private authorityProvider: DiscoveryAuthorityProvider | undefined;

  constructor(output: CommandOutput, deps: DiscoveryServiceDeps = {}) {
    this.discoveryOutput = output;
    this.runtime = deps.runtime ?? {};
    this.authorityProvider = deps.authority;
  }

  /** Role context reported by the trusted provider, or null for a root principal. */
  discoveryRole(): string | null {
    return this.authorityProvider?.agent?.role ?? null;
  }

  private get authority(): DiscoveryAuthorityProvider {
    this.authorityProvider ??= createNodeDiscoveryAuthorityProvider();
    return this.authorityProvider;
  }

  async validateDiscoveryArtifacts(
    input: ValidateDiscoveryArtifactsInput,
  ): Promise<RepoAutomationExecutionResult> {
    return runValidateDiscoveryArtifacts(
      this.discoveryOutput,
      input,
      this.runtime,
    );
  }

  async runDiscoveryInit(
    input: RunDiscoveryInitInput,
  ): Promise<RepoAutomationExecutionResult> {
    return runDiscoveryInit(this.discoveryOutput, input, this.runtime);
  }

  async runDiscoveryRepoInventory(
    input: RunDiscoveryAnalyzerInput,
  ): Promise<RepoAutomationExecutionResult> {
    return runDiscoveryRepoInventory(this.discoveryOutput, input, this.runtime);
  }

  async runDiscoveryDotnetAnalyzer(
    input: RunDiscoveryAnalyzerInput,
  ): Promise<RepoAutomationExecutionResult> {
    return runDiscoveryDotnetAnalyzer(
      this.discoveryOutput,
      input,
      this.runtime,
    );
  }

  async runDiscoveryVstoAnalyzer(
    input: RunDiscoveryAnalyzerInput,
  ): Promise<RepoAutomationExecutionResult> {
    return runDiscoveryVstoAnalyzer(this.discoveryOutput, input, this.runtime);
  }

  async runDiscoveryScenarioGeneration(
    input: RunDiscoveryScenarioGenerationInput,
  ): Promise<RepoAutomationExecutionResult> {
    return runDiscoveryScenarioGeneration(
      this.discoveryOutput,
      input,
      this.runtime,
    );
  }

  async runDiscoveryReport(
    input: RunDiscoveryReportInput,
  ): Promise<RepoAutomationExecutionResult> {
    return runDiscoveryReport(this.discoveryOutput, input, this.runtime);
  }

  async configureDiscoveryWorkspace(
    input: ConfigureDiscoveryWorkspaceInput,
  ): Promise<RepoAutomationExecutionResult> {
    return runDiscoveryOperation(
      this.discoveryOutput,
      "configure_discovery_workspace",
      input,
      {
        operation: "configure",
        dryRun: input.dryRun ?? false,
        inputs: inputs([
          ["configuration_action", input.configurationAction],
          ["input_path", input.inputPath],
        ]),
      },
      this.runtime,
    );
  }

  async createDiscoveryArtifact(
    input: CreateDiscoveryArtifactInput,
  ): Promise<RepoAutomationExecutionResult> {
    // Feature contracts and runtime scenarios are distinct runtime operations.
    const contract = input.artifactKind === "feature-contract";
    return runDiscoveryOperation(
      this.discoveryOutput,
      "create_discovery_artifact",
      input,
      {
        operation: contract ? "new-contract" : "new-scenario",
        ...granted(input),
        inputs: inputs(
          contract
            ? [
                ["feature_id", input.featureId],
                ["name", input.name],
                ["capability_group", input.capabilityGroup],
                ["input_path", input.inputPath],
              ]
            : [
                ["scenario_id", input.scenarioId],
                ["feature_ids", input.featureIds],
                ["input_path", input.inputPath],
              ],
        ),
      },
      this.runtime,
    );
  }

  async updateDiscoveryArtifact(
    input: UpdateDiscoveryArtifactInput,
  ): Promise<RepoAutomationExecutionResult> {
    return runDiscoveryOperation(
      this.discoveryOutput,
      "update_discovery_artifact",
      input,
      {
        operation: "update-artifact",
        ...granted(input),
        inputs: inputs([
          ["artifact_kind", input.artifactKind],
          ["artifact_path", input.artifactPath],
          ["artifact_id", input.artifactId],
          ["input_path", input.inputPath],
          ["expected_sha256", input.expectedSha256],
          ["update_action", input.updateAction],
          ["approval_owner", input.approvalOwner],
          ["approval_evidence_refs", input.approvalEvidenceRefs],
        ]),
      },
      this.runtime,
    );
  }

  async linkDiscoveryEvidence(
    input: LinkDiscoveryEvidenceInput,
  ): Promise<RepoAutomationExecutionResult> {
    return runDiscoveryOperation(
      this.discoveryOutput,
      "link_discovery_evidence",
      input,
      {
        operation: "link-evidence",
        ...granted(input),
        inputs: inputs([
          ["artifact_kind", input.artifactKind],
          ["artifact_id", input.artifactId],
          ["evidence_path", input.evidencePath],
          ["expected_sha256", input.expectedSha256],
        ]),
      },
      this.runtime,
    );
  }

  async transferDiscoverySnapshot(
    input: TransferDiscoverySnapshotInput,
  ): Promise<RepoAutomationExecutionResult> {
    const exporting = input.direction === "export";
    return runDiscoveryOperation(
      this.discoveryOutput,
      "transfer_discovery_snapshot",
      input,
      {
        operation: exporting ? "snapshot-export" : "snapshot-import",
        write: input.write ?? false,
        dryRun: input.dryRun ?? false,
        inputs: inputs(
          exporting
            ? [
                ["selected_ids", input.selectedIds],
                ["paths", input.paths],
              ]
            : [["manifest_path", input.manifestPath]],
        ),
      },
      this.runtime,
    );
  }

  async importDiscoveryInventory(
    input: ImportDiscoveryInventoryInput,
  ): Promise<RepoAutomationExecutionResult> {
    return runDiscoveryOperation(
      this.discoveryOutput,
      "import_discovery_inventory",
      input,
      {
        operation: "import-inventory",
        write: input.write ?? false,
        dryRun: input.dryRun ?? false,
        inputs: inputs([["manifest_path", input.manifestPath]]),
      },
      this.runtime,
    );
  }

  async migrateDiscoveryArtifacts(
    input: MigrateDiscoveryArtifactsInput,
  ): Promise<RepoAutomationExecutionResult> {
    return runDiscoveryOperation(
      this.discoveryOutput,
      "migrate_discovery_artifacts",
      input,
      {
        operation: "migrate",
        write: input.write ?? false,
        dryRun: input.dryRun ?? false,
        inputs: inputs([
          ["from_version", 1],
          ["to_version", 2],
          ["destination", input.destination],
          ["input_path", input.inputPath],
          ["paths", input.paths],
          ["system_id", input.systemId],
          ["system_name", input.systemName],
          ["system_role", input.systemRole],
          ["repository_id", input.repositoryId],
          ["production_roots", input.productionRoots],
          ["test_roots", input.testRoots],
          ["draft", input.draft],
        ]),
      },
      this.runtime,
    );
  }

  async runDiscoveryDoctor(
    input: RunDiscoveryDoctorInput,
  ): Promise<RepoAutomationExecutionResult> {
    const result = await runDiscoveryOperation(
      this.discoveryOutput,
      "run_discovery_doctor",
      input,
      { operation: "doctor" },
      this.runtime,
    );
    // The same lazily created trusted provider that prepares agents describes
    // the host capability, so a production service with no injected provider
    // still projects the session's protected attestation (or the exact
    // deficiency) instead of leaving the runtime's generic warning in place.
    return projectDoctorCapability(this.authority, input.workspaceRoot, result);
  }

  async readDiscoverySource(
    input: ReadDiscoverySourceInput,
  ): Promise<RepoAutomationExecutionResult> {
    return runDiscoveryOperation(
      this.discoveryOutput,
      "read_discovery_source",
      input,
      {
        operation: "read-source",
        mode: input.mode ?? "structural",
        ...(input.invocationRef === undefined
          ? {}
          : { invocationRef: input.invocationRef }),
        ...(input.authorizationRef === undefined
          ? {}
          : { authorizationRef: input.authorizationRef }),
        inputs: inputs([
          ["read_operation", input.readOperation],
          ["paths", input.paths],
          ["query", input.query],
          ["regex", input.regex],
          ["max_bytes", input.maxBytes],
          ["line_start", input.lineStart],
          ["line_end", input.lineEnd],
        ]),
      },
      this.runtime,
    );
  }

  async prepareDiscoveryAgent(
    input: PrepareDiscoveryAgentInput,
  ): Promise<RepoAutomationExecutionResult> {
    return prepareDiscoveryAgentOperation(
      {
        output: this.discoveryOutput,
        runtime: this.runtime,
        authority: this.authority,
      },
      input,
    );
  }

  async finalizeDiscoveryAgent(
    input: FinalizeDiscoveryAgentInput,
  ): Promise<RepoAutomationExecutionResult> {
    return finalizeDiscoveryAgentOperation(
      {
        output: this.discoveryOutput,
        runtime: this.runtime,
        authority: this.authority,
      },
      input,
    );
  }
}
