/**
 * Type-only mirror of the v2 discovery service request and result envelopes.
 *
 * These declarations follow `schemas/discovery/v2/service-request.schema.json`
 * and `service-result.schema.json`. They carry no executable behavior; the
 * runtime checks live in `discovery-result.ts` and `discovery-runtime.ts`.
 * A valid envelope describes an operation outcome only and never grants
 * workspace, configuration, approval or native authority.
 */

export type DiscoveryOperation =
  | "init"
  | "configure"
  | "profile"
  | "inventory"
  | "new-contract"
  | "new-scenario"
  | "update-artifact"
  | "link-evidence"
  | "validate-profile"
  | "validate-feature-contract"
  | "validate-coverage-ledger"
  | "validate-runtime-scenario"
  | "validate-parity-matrix"
  | "validate-unspecified-behavior"
  | "validate-product-decision"
  | "validate-evidence-reference"
  | "validate-decisions"
  | "validate-all"
  | "coverage-report"
  | "parity-report"
  | "completion-report"
  | "generate-acceptance"
  | "snapshot-export"
  | "snapshot-import"
  | "import-inventory"
  | "migrate"
  | "doctor"
  | "read-source"
  | "prepare-agent"
  | "finalize-agent";

export type DiscoveryMode =
  | "structural"
  | "agent-output"
  | "discovery-complete"
  | "parity-complete"
  | "planning";

export type DiscoveryOutputFormat = "json" | "markdown" | "both";

export type DiscoveryPrincipal = "local-user" | "host";

export type DiscoveryExitCode = 0 | 1 | 2 | 3;

export type DiscoveryFindingSeverity = "error" | "warning" | "info";

export type DiscoveryArtifactStatus =
  "planned" | "created" | "updated" | "skipped" | "conflict";

/** Closed request data; the service enforces operation-specific combinations. */
export type DiscoveryRequestInputs = Readonly<
  Record<string, string | number | boolean | null | ReadonlyArray<string>>
>;

/** The complete v2 service-request document written to the gateway stdin. */
export interface DiscoveryServiceRequest {
  readonly $schema: "urn:drm-copilot:discovery:2.0.0:service-request";
  readonly schema_version: "2.0.0";
  readonly artifact_kind: "service-request";
  readonly id: string;
  readonly request_id: string;
  readonly operation: DiscoveryOperation;
  readonly mode: DiscoveryMode;
  readonly workspace_root: string;
  readonly profile_path: string | null;
  readonly dry_run: boolean;
  readonly write: boolean;
  readonly format: DiscoveryOutputFormat;
  readonly inputs: DiscoveryRequestInputs;
  readonly invocation_ref: string | null;
  readonly authorization_ref: string | null;
}

export interface DiscoveryFinding {
  readonly code: string;
  readonly severity: DiscoveryFindingSeverity;
  readonly artifact_path: string | null;
  readonly pointer: string;
  readonly related_ids: ReadonlyArray<string>;
  readonly related_paths: ReadonlyArray<string>;
  readonly message: string;
  readonly next_action: string;
}

export interface DiscoveryArtifact {
  readonly path: string;
  readonly kind: string;
  readonly status: DiscoveryArtifactStatus;
  readonly sha256: string;
  readonly content?: string;
}

export interface DiscoverySummaryCount {
  readonly name: string;
  readonly value: number;
}

export interface DiscoverySummary {
  readonly message: string;
  readonly counts: ReadonlyArray<DiscoverySummaryCount>;
  readonly validation_result: string | null;
  readonly receipt_ref: string | null;
  readonly invocation_ref: string | null;
  readonly deployment?: Record<string, unknown> | null;
  readonly source_reads?: ReadonlyArray<Record<string, unknown>>;
}

export interface DiscoveryInputManifestEntry {
  readonly path: string;
  readonly sha256: string;
  readonly size: number;
  readonly category: string;
}

export interface DiscoveryInputManifest {
  readonly entries: ReadonlyArray<DiscoveryInputManifestEntry>;
  readonly missing_paths: ReadonlyArray<string>;
  readonly source_repositories: ReadonlyArray<Record<string, unknown>>;
  readonly target_repositories: ReadonlyArray<Record<string, unknown>>;
  readonly sha256: string;
}

export interface DiscoveryRuntimeIdentity {
  readonly package_version: string;
  readonly schema_version: string;
  readonly build_sha256: string;
  readonly policy_version: number;
  readonly policy_sha256: string;
}

/** The validated v2 service-result wire envelope read from the gateway stdout. */
export interface DiscoveryServiceResult {
  readonly result_version: "2.0.0";
  readonly operation: DiscoveryOperation | null;
  readonly mode: DiscoveryMode | null;
  readonly ok: boolean;
  readonly exit_code: DiscoveryExitCode;
  readonly findings: ReadonlyArray<DiscoveryFinding>;
  readonly artifacts: ReadonlyArray<DiscoveryArtifact>;
  readonly summary: DiscoverySummary;
  readonly input_manifest: DiscoveryInputManifest | null;
  readonly runtime: DiscoveryRuntimeIdentity | null;
}
