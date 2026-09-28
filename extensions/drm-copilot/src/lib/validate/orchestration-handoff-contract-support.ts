export type HandoffProvider = "claude" | "codex";
export type SchedulerKind = "ordinary" | "parallel" | "epic";
export type HandoffFailureCode =
  | "HANDOFF_UNSUPPORTED_VERSION"
  | "HANDOFF_SOURCE_HASH_MISMATCH"
  | "HANDOFF_HISTORY_INVALID"
  | "HANDOFF_REPOSITORY_MISMATCH"
  | "HANDOFF_WORKSPACE_MISMATCH"
  | "HANDOFF_ISSUE_FEATURE_MISMATCH"
  | "HANDOFF_BRANCH_LINEAGE_MISMATCH"
  | "HANDOFF_PLAN_PATH_INVALID"
  | "HANDOFF_PLAN_HASH_MISMATCH"
  | "HANDOFF_SCHEDULER_BINDING_MISMATCH"
  | "HANDOFF_TRANSITION_NOT_ALLOWED"
  | "HANDOFF_CAPABILITY_UNAVAILABLE"
  | "HANDOFF_VALIDATOR_UNAVAILABLE"
  | "HANDOFF_TOPOLOGY_RESOLVER_UNAVAILABLE"
  | "HANDOFF_PROVIDER_ROUTING_UNAVAILABLE"
  | "HANDOFF_DIRTY_WORKTREE";

export interface ObjectiveIdentity {
  readonly objectiveId: string;
  readonly issueNumber: number;
  readonly featureFolder: string;
  readonly workMode: "minor-audit" | "full-feature" | "full-bug";
}

export interface WorkspaceBinding {
  readonly repositoryId: string;
  readonly workspaceRoot: string;
  readonly branch: string;
  readonly sourceHeadSha: string;
  readonly allowedHeadRelationship: "equal" | "equal_or_descendant";
}

export interface PlanIdentity {
  readonly path: string;
  readonly sha256: string;
  readonly contractVersion: string;
}

export interface ReceiptReference {
  readonly path: string;
  readonly sha256: string;
}

export interface ProviderProvenance {
  readonly provider: HandoffProvider;
  readonly checkpointPath: string;
  readonly checkpointSha256: string;
  readonly archivePath: string;
  readonly expressionSchemaId: string;
  readonly expressionSchemaVersion: string;
  readonly receiptReferences: readonly ReceiptReference[];
}

export interface LifecycleState {
  readonly logicalComplexity: "C1" | "C2" | "C3" | "C4";
  readonly routeIntent:
    "prepared_to_ordinary_execution" | "prepared_child_to_ordinary_execution";
  readonly completedPhases: readonly string[];
  readonly nextTransition: string;
  readonly replayPolicy: "forbid_completed_phases";
}

export interface CapabilityRequirements {
  readonly vocabularies: readonly string[];
  readonly required: readonly string[];
}

export interface OrdinarySchedulerContext {
  readonly kind: "ordinary";
}

export interface ChildSchedulerContext {
  readonly kind: "parallel" | "epic";
  readonly runId: string;
  readonly itemId: string;
  readonly kickoffOrManifestPath: string;
  readonly kickoffOrManifestSha256: string;
  readonly parentCheckpointPath: string;
  readonly parentCheckpointSha256: string;
  readonly cohortOrWave: string | number;
  readonly schedulerOwner: "parallel_orchestrator" | "epic_orchestrator";
  readonly childExecutionOwner: "ordinary_orchestrator";
  readonly returnContract: "portable_child_result-v1";
}

export type SchedulerContext = OrdinarySchedulerContext | ChildSchedulerContext;

export interface HistoryEntry {
  readonly sequence: number;
  readonly fromProvider: HandoffProvider;
  readonly toProvider: HandoffProvider;
  readonly sourceCheckpointSha256: string;
  readonly envelopeSha256: string;
  readonly requestedAt: string;
  readonly previousEntrySha256: string | null;
  readonly entrySha256: string;
  readonly status:
    "requested" | "validated" | "materialized" | "blocked" | "returned";
  readonly adapterId: string;
  readonly adapterVersion: string;
  readonly targetCheckpointSha256: string | null;
  readonly failureCode: string | null;
}

export interface HandoffEnvelope {
  readonly schemaUri: string;
  readonly schemaVersion: string;
  readonly kind: "portable_orchestration_handoff";
  readonly handoffId: string;
  readonly identity: ObjectiveIdentity;
  readonly binding: WorkspaceBinding;
  readonly source: ProviderProvenance;
  readonly destinationProvider: HandoffProvider;
  readonly destinationCheckpointPath: string;
  readonly plan: PlanIdentity;
  readonly lifecycle: LifecycleState;
  readonly capabilities: CapabilityRequirements;
  readonly schedulerContext: SchedulerContext;
  readonly handoffHistory: readonly HistoryEntry[];
}

export class HandoffContractError extends Error {
  constructor(
    readonly field: string,
    message: string,
    readonly code: HandoffFailureCode = "HANDOFF_UNSUPPORTED_VERSION",
  ) {
    super(`${field}: ${message}`);
    this.name = "HandoffContractError";
  }
}

export const SHA256 = /^[a-f0-9]{64}$/;
const GIT_SHA = /^[a-f0-9]{40}$/;
export const SEMVER = /^[0-9]+\.[0-9]+\.[0-9]+$/;
export const HANDOFF_ID = /^[A-Za-z0-9][A-Za-z0-9._:-]{2,127}$/;
const PLAN_CONTRACT = /^atomic-plan-v[0-9]+$/;
export const FAILURE_CODE = /^HANDOFF_[A-Z0-9_]+$/;
export const SCHEMA_URI =
  "https://drm-copilot.dev/schemas/orchestration-handoff/2.0.0/schema.json";
export const CHECKPOINT_PATH =
  "artifacts/orchestration/orchestrator-state.json";
export const PHASES = [
  "intake",
  "promotion",
  "research",
  "feature_documents",
  "atomic_planning",
  "preflight",
  "atomic_execution",
  "qa",
  "feature_review",
  "pr_creation",
  "ci_verification",
  "completion",
] as const;

export function fail(
  field: string,
  message = "is invalid",
  code?: HandoffFailureCode,
): never {
  throw new HandoffContractError(field, message, code);
}

export function record(
  value: unknown,
  field: string,
  required: readonly string[],
  optional: readonly string[] = [],
): Readonly<Record<string, unknown>> {
  if (typeof value !== "object" || value === null || Array.isArray(value)) {
    return fail(field, "must be an object");
  }
  const result = value as Readonly<Record<string, unknown>>;
  const allowed = new Set([...required, ...optional]);
  if (required.some((key) => !Object.hasOwn(result, key))) {
    return fail(field, "is missing a required property");
  }
  if (Object.keys(result).some((key) => !allowed.has(key))) {
    return fail(field, "contains an unknown property");
  }
  return result;
}

export function text(value: unknown, field: string): string {
  if (typeof value !== "string" || value.trim() === "") {
    return fail(field, "must be a non-empty string");
  }
  return value;
}

export function matchingText(
  value: unknown,
  field: string,
  pattern: RegExp,
): string {
  const result = text(value, field);
  return pattern.test(result) ? result : fail(field);
}

export function positiveInteger(value: unknown, field: string): number {
  return Number.isInteger(value) && Number(value) > 0
    ? Number(value)
    : fail(field, "must be a positive integer");
}

export function oneOf<T extends string>(
  value: unknown,
  field: string,
  allowed: readonly T[],
): T {
  return typeof value === "string" && allowed.includes(value as T)
    ? (value as T)
    : fail(field);
}

export function stringArray(value: unknown, field: string): readonly string[] {
  if (
    !Array.isArray(value) ||
    !value.every((item) => typeof item === "string")
  ) {
    return fail(field, "must be a string array");
  }
  if (
    value.some((item) => item.trim() === "") ||
    new Set(value).size !== value.length
  ) {
    return fail(field, "must contain unique non-empty strings");
  }
  return value;
}

function repositoryPath(value: unknown, field: string): string {
  const result = text(value, field);
  const parts = result.split("/");
  if (
    result.includes("\\") ||
    result.startsWith("/") ||
    /^[A-Za-z]:/.test(result) ||
    parts.some((part) => part === "" || part === "." || part === "..")
  ) {
    return fail(
      field,
      "must be normalized repository-relative POSIX syntax",
      "HANDOFF_PLAN_PATH_INVALID",
    );
  }
  return result;
}

export function parseIdentity(value: unknown): ObjectiveIdentity {
  const data = record(value, "identity", [
    "objective_id",
    "issue_number",
    "feature_folder",
    "work_mode",
  ]);
  return {
    objectiveId: text(data["objective_id"], "identity.objective_id"),
    issueNumber: positiveInteger(data["issue_number"], "identity.issue_number"),
    featureFolder: text(data["feature_folder"], "identity.feature_folder"),
    workMode: oneOf(data["work_mode"], "identity.work_mode", [
      "minor-audit",
      "full-feature",
      "full-bug",
    ]),
  };
}

export function parseBinding(value: unknown): WorkspaceBinding {
  const data = record(value, "binding", [
    "repository_id",
    "workspace_root",
    "branch",
    "source_head_sha",
    "allowed_head_relationship",
  ]);
  return {
    repositoryId: text(data["repository_id"], "binding.repository_id"),
    workspaceRoot: text(data["workspace_root"], "binding.workspace_root"),
    branch: text(data["branch"], "binding.branch"),
    sourceHeadSha: matchingText(
      data["source_head_sha"],
      "binding.source_head_sha",
      GIT_SHA,
    ),
    allowedHeadRelationship: oneOf(
      data["allowed_head_relationship"],
      "binding.allowed_head_relationship",
      ["equal", "equal_or_descendant"],
    ),
  };
}

export function parsePlan(value: unknown): PlanIdentity {
  const data = record(value, "plan", ["path", "sha256", "contract_version"]);
  return {
    path: repositoryPath(data["path"], "plan.path"),
    sha256: matchingText(data["sha256"], "plan.sha256", SHA256),
    contractVersion: matchingText(
      data["contract_version"],
      "plan.contract_version",
      PLAN_CONTRACT,
    ),
  };
}

export function parseCapabilities(value: unknown): CapabilityRequirements {
  const data = record(value, "capabilities", ["vocabularies", "required"]);
  const vocabularies = stringArray(
    data["vocabularies"],
    "capabilities.vocabularies",
  );
  const required = stringArray(data["required"], "capabilities.required");
  if (vocabularies.length === 0 || required.length === 0) {
    return fail("capabilities");
  }
  return { vocabularies, required };
}
