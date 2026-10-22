/**
 * Input and result shapes for the discovery operations added to the shared
 * service contract (configure, create, update, link, transfer, import,
 * migrate, doctor, read, prepare and finalize).
 *
 * Every shape maps one-to-one onto a v2 `service-request` operation and its
 * closed input matrix; no shape carries a path to a receipt, an identity or a
 * success claim. This module is type-only.
 */

import type {
  DiscoveryMode,
  DiscoveryServiceResult,
} from "./discovery-service-types";
import type { DiscoveryWorkspaceInput } from "./repo-automation-execute-discovery";
import type { InvocationDeployment } from "./discovery-routing";

/** Mutation inputs may be issued under a protected invocation and grant. */
export interface DiscoveryGrantedInput extends DiscoveryWorkspaceInput {
  readonly invocationRef?: string;
  readonly authorizationRef?: string;
  readonly write?: boolean;
  readonly dryRun?: boolean;
}

export interface ConfigureDiscoveryWorkspaceInput extends DiscoveryWorkspaceInput {
  readonly configurationAction: "activate" | "deactivate";
  readonly inputPath?: string;
  readonly dryRun?: boolean;
}

export type CreateDiscoveryArtifactKind =
  "feature-contract" | "runtime-scenario";

export interface CreateDiscoveryArtifactInput extends DiscoveryGrantedInput {
  readonly artifactKind: CreateDiscoveryArtifactKind;
  readonly featureId?: string;
  readonly name?: string;
  readonly capabilityGroup?: string;
  readonly scenarioId?: string;
  readonly featureIds?: ReadonlyArray<string>;
  readonly inputPath?: string;
}

export interface UpdateDiscoveryArtifactInput extends DiscoveryGrantedInput {
  readonly artifactKind: string;
  readonly artifactPath: string;
  readonly inputPath: string;
  readonly expectedSha256: string | null;
  readonly updateAction: "replace" | "approve-decision";
  readonly artifactId?: string;
  readonly approvalOwner?: string;
  readonly approvalEvidenceRefs?: ReadonlyArray<string>;
}

export interface LinkDiscoveryEvidenceInput extends DiscoveryGrantedInput {
  readonly artifactKind: string;
  readonly artifactId: string;
  readonly evidencePath: string;
  readonly expectedSha256: string;
}

export interface TransferDiscoverySnapshotInput extends DiscoveryWorkspaceInput {
  readonly direction: "export" | "import";
  readonly selectedIds?: ReadonlyArray<string>;
  readonly paths?: ReadonlyArray<string>;
  readonly manifestPath?: string;
  readonly write?: boolean;
  readonly dryRun?: boolean;
}

export interface ImportDiscoveryInventoryInput extends DiscoveryWorkspaceInput {
  readonly manifestPath: string;
  readonly write?: boolean;
  readonly dryRun?: boolean;
}

export interface MigrateDiscoveryArtifactsInput extends DiscoveryWorkspaceInput {
  readonly destination: string;
  readonly systemId: string;
  readonly systemName: string;
  readonly systemRole: "legacy-source" | "modernization-target" | "combined";
  readonly repositoryId: string;
  readonly inputPath?: string;
  readonly paths?: ReadonlyArray<string>;
  readonly productionRoots?: ReadonlyArray<string>;
  readonly testRoots?: ReadonlyArray<string>;
  readonly draft?: boolean;
  readonly write?: boolean;
  readonly dryRun?: boolean;
}

export type RunDiscoveryDoctorInput = DiscoveryWorkspaceInput;

export interface ReadDiscoverySourceInput extends DiscoveryWorkspaceInput {
  readonly readOperation: "list" | "read" | "search";
  readonly paths: ReadonlyArray<string>;
  readonly query?: string;
  readonly regex?: boolean;
  readonly maxBytes?: number;
  readonly lineStart?: number;
  readonly lineEnd?: number;
  readonly invocationRef?: string;
  readonly authorizationRef?: string;
  readonly mode?: DiscoveryMode;
}

export interface PrepareDiscoveryAgentInput extends DiscoveryWorkspaceInput {
  readonly skillId: string;
  readonly selectedIds: ReadonlyArray<string>;
  readonly paths: ReadonlyArray<string>;
  readonly expectedOutputs: ReadonlyArray<Record<string, unknown>>;
  readonly executionContext: string;
  readonly complexity: string;
  readonly orchestrationComplexityCeiling?: string;
}

export interface FinalizeDiscoveryAgentInput extends DiscoveryWorkspaceInput {
  readonly invocationRef: string;
  readonly requestId: string;
}

/** Launchable deployment returned by prepare; never a grant by itself. */
export interface PreparedInvocationSummary {
  readonly invocation_id: string;
  readonly role: string;
  readonly skill_id: string;
  readonly deployment: InvocationDeployment;
  readonly mirror_path: string;
}

/** Receipt summary returned by finalize; the protected record is authoritative. */
export interface FinalizedReceiptSummary {
  readonly receipt_ref: string;
  readonly validation_result: "pass" | "fail";
  readonly output_valid: boolean;
  readonly planning_authorized: boolean;
}

export type { DiscoveryServiceResult };
