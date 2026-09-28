import type { HandoffFailureCode } from "./lib/validate/orchestration-handoff-contract";
import type { ToolDefinition } from "./mcp-repo-automation-tool-definitions";
import { workspaceRootProperty } from "./mcp-push-down-schema-properties";

export type PortableHandoffProvider = "claude" | "codex";
export type PortableHandoffMode = "dry_run" | "materialize";
export type PortableHandoffStatus = "validated" | "materialized" | "blocked";
export type PortableHandoffHeadRelationship = "equal" | "equal_or_descendant";
export type PortableHandoffWorkMode =
  "minor-audit" | "full-feature" | "full-bug";

/**
 * Caller-supplied expected context that binds a portable handoff to a specific
 * checkout. Every value is independent of the envelope under validation: the
 * caller states what the destination checkout must be, and the authority proves
 * the envelope against those values rather than against the envelope itself.
 */
export interface PortableHandoffExpectedContext {
  readonly expectedRepositoryId: string;
  readonly expectedWorkspaceRoot: string;
  readonly expectedBranch: string;
  readonly expectedSourceHeadSha: string;
  readonly allowedHeadRelationship: PortableHandoffHeadRelationship;
  readonly expectedIssueNumber: number;
  readonly expectedFeatureFolder: string;
  readonly expectedWorkMode: PortableHandoffWorkMode;
  readonly expectedPlanPath: string;
  readonly expectedPlanSha256: string;
}

export interface PortableHandoffReferenceRequest extends PortableHandoffExpectedContext {
  readonly workspaceRoot: string;
  readonly handoffEnvelopePath: string;
  readonly expectedHandoffEnvelopeSha256: string;
  readonly destinationProvider: PortableHandoffProvider;
}

export type ResolveOrchestrationTopologyRequest =
  PortableHandoffReferenceRequest;
export type ResolveProviderRoutingRequest = PortableHandoffReferenceRequest;

export interface TransitionPreparedOrchestrationRequest extends PortableHandoffReferenceRequest {
  readonly sourceCheckpointPath: string;
  readonly expectedSourceCheckpointSha256: string;
  readonly mode: PortableHandoffMode;
}

export interface PortableHandoffAuthorityResult {
  readonly status: "validated" | "blocked";
  readonly handoffId: string | null;
  readonly handoffEnvelopeSha256: string;
  readonly primaryFailureCode: HandoffFailureCode | null;
  readonly affectedPaths: readonly string[];
  readonly unsupportedCapabilities: readonly string[];
  readonly resolution: Readonly<Record<string, unknown>> | null;
}

export interface TransitionPreparedOrchestrationResult {
  readonly status: PortableHandoffStatus;
  readonly handoffId: string | null;
  readonly sourceCheckpointSha256: string;
  readonly handoffEnvelopeSha256: string;
  readonly handoffHistorySha256: string | null;
  readonly requestedTransition: string | null;
  readonly destinationCheckpointPath: string | null;
  readonly destinationCheckpointSha256: string | null;
  readonly primaryFailureCode: HandoffFailureCode | null;
  readonly affectedPaths: readonly string[];
  readonly unsupportedCapabilities: readonly string[];
}

const repositoryRelativePathProperty = {
  type: "string",
  pattern: "^(?!/)(?![A-Za-z]:)(?!.*(?:^|/)\\.\\.(?:/|$))(?!.*\\\\).+$",
  description: "Normalized repository-relative POSIX path.",
} as const;

const sha256Property = {
  type: "string",
  pattern: "^[a-f0-9]{64}$",
  description: "Expected lowercase raw-byte SHA-256 digest.",
} as const;

const destinationProviderProperty = {
  type: "string",
  enum: ["claude", "codex"],
  description: "Destination provider that will consume the portable handoff.",
} as const;

const gitShaProperty = {
  type: "string",
  pattern: "^[a-f0-9]{40}$",
  description: "Expected lowercase 40-character Git commit SHA.",
} as const;

const nonEmptyStringProperty = {
  type: "string",
  minLength: 1,
  description: "Required non-empty caller-supplied expected value.",
} as const;

const absolutePathProperty = {
  type: "string",
  pattern: "^(?:[A-Za-z]:[\\/]|/).+$",
  description: "Required absolute path the caller independently expects.",
} as const;

const independentContextProperties = {
  expected_repository_id: nonEmptyStringProperty,
  expected_workspace_root: absolutePathProperty,
  expected_branch: nonEmptyStringProperty,
  expected_source_head_sha: gitShaProperty,
  allowed_head_relationship: {
    type: "string",
    enum: ["equal", "equal_or_descendant"],
    description:
      "Allowed relationship between observed HEAD and expected HEAD.",
  },
  expected_issue_number: {
    type: "integer",
    minimum: 1,
    description: "Issue number the caller independently expects.",
  },
  expected_feature_folder: repositoryRelativePathProperty,
  expected_work_mode: {
    type: "string",
    enum: ["minor-audit", "full-feature", "full-bug"],
    description: "Work mode the caller independently expects.",
  },
  expected_plan_path: repositoryRelativePathProperty,
  expected_plan_sha256: sha256Property,
} as const;

const independentContextRequired = [
  "expected_repository_id",
  "expected_workspace_root",
  "expected_branch",
  "expected_source_head_sha",
  "allowed_head_relationship",
  "expected_issue_number",
  "expected_feature_folder",
  "expected_work_mode",
  "expected_plan_path",
  "expected_plan_sha256",
] as const;

const handoffReferenceProperties = {
  workspace_root: workspaceRootProperty,
  handoff_envelope_path: repositoryRelativePathProperty,
  expected_handoff_envelope_sha256: sha256Property,
  destination_provider: destinationProviderProperty,
  ...independentContextProperties,
} as const;

const handoffReferenceRequired = [
  "workspace_root",
  "handoff_envelope_path",
  "expected_handoff_envelope_sha256",
  "destination_provider",
  ...independentContextRequired,
] as const;

export const HANDOFF_TOOL_DEFINITIONS: ReadonlyArray<ToolDefinition> = [
  {
    name: "resolve_orchestration_topology",
    description:
      "Resolve destination execution topology for a workspace-explicit portable handoff without mutation.",
    inputSchema: {
      type: "object",
      properties: handoffReferenceProperties,
      required: [...handoffReferenceRequired],
      additionalProperties: false,
    },
  },
  {
    name: "resolve_provider_routing",
    description:
      "Resolve destination provider routing for a workspace-explicit portable handoff without mutation.",
    inputSchema: {
      type: "object",
      properties: handoffReferenceProperties,
      required: [...handoffReferenceRequired],
      additionalProperties: false,
    },
  },
  {
    name: "transition_prepared_orchestration",
    description:
      "Validate or atomically materialize a destination checkpoint from a portable prepared-orchestration handoff.",
    inputSchema: {
      type: "object",
      properties: {
        workspace_root: workspaceRootProperty,
        handoff_envelope_path: repositoryRelativePathProperty,
        expected_handoff_envelope_sha256: sha256Property,
        destination_provider: destinationProviderProperty,
        source_checkpoint_path: repositoryRelativePathProperty,
        expected_source_checkpoint_sha256: sha256Property,
        ...independentContextProperties,
        mode: {
          type: "string",
          enum: ["dry_run", "materialize"],
          description:
            "Non-mutating validation or controlled materialization mode.",
        },
      },
      required: [
        "workspace_root",
        "source_checkpoint_path",
        "expected_source_checkpoint_sha256",
        "handoff_envelope_path",
        "expected_handoff_envelope_sha256",
        "destination_provider",
        ...independentContextRequired,
        "mode",
      ],
      additionalProperties: false,
    },
  },
];
