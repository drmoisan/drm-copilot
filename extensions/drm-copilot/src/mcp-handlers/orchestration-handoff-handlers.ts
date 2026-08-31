import * as path from "node:path";

import type { RepoAutomationService } from "../repo-automation-service-contract";
import type {
  PortableHandoffAuthorityResult,
  PortableHandoffReferenceRequest,
  TransitionPreparedOrchestrationRequest,
  TransitionPreparedOrchestrationResult,
} from "../mcp-repo-automation-tool-definitions-handoff";

export type PortableHandoffToolName =
  | "resolve_orchestration_topology"
  | "resolve_provider_routing"
  | "transition_prepared_orchestration";

export interface PortableHandoffMcpToolResult extends Readonly<
  Record<string, unknown>
> {
  readonly ok: true;
  readonly tool: PortableHandoffToolName;
  readonly workspace_root: string;
  readonly summary: string;
}

function requireInputRecord(
  rawInput: unknown,
): Readonly<Record<string, unknown>> {
  if (
    typeof rawInput !== "object" ||
    rawInput === null ||
    Array.isArray(rawInput)
  ) {
    throw new Error("Portable handoff input must be an object.");
  }
  return rawInput as Readonly<Record<string, unknown>>;
}

function requireString(
  input: Readonly<Record<string, unknown>>,
  key: string,
): string {
  const value = input[key];
  if (typeof value !== "string" || value.trim() === "") {
    throw new Error(`${key} must be a non-empty string.`);
  }
  return value;
}

function requireRepositoryPath(
  input: Readonly<Record<string, unknown>>,
  key: string,
): string {
  const value = requireString(input, key);
  if (
    value.includes("\\") ||
    value.startsWith("/") ||
    value.split("/").some((part) => ["", ".", ".."].includes(part))
  ) {
    throw new Error(`${key} must be repository-relative POSIX syntax.`);
  }
  return value;
}

function requireSha256(
  input: Readonly<Record<string, unknown>>,
  key: string,
): string {
  const value = requireString(input, key);
  if (!/^[a-f0-9]{64}$/.test(value)) {
    throw new Error(`${key} must be a lowercase SHA-256 digest.`);
  }
  return value;
}

function resolveReferenceInput(
  rawInput: unknown,
): PortableHandoffReferenceRequest {
  const input = requireInputRecord(rawInput);
  const workspaceRoot = requireString(input, "workspace_root");
  if (!path.isAbsolute(workspaceRoot)) {
    throw new Error("workspace_root must be an absolute path.");
  }
  const destinationProvider = requireString(input, "destination_provider");
  if (destinationProvider !== "claude" && destinationProvider !== "codex") {
    throw new Error("destination_provider must be 'claude' or 'codex'.");
  }
  return {
    workspaceRoot,
    handoffEnvelopePath: requireRepositoryPath(input, "handoff_envelope_path"),
    expectedHandoffEnvelopeSha256: requireSha256(
      input,
      "expected_handoff_envelope_sha256",
    ),
    destinationProvider,
  };
}

function resolveTransitionInput(
  rawInput: unknown,
): TransitionPreparedOrchestrationRequest {
  const input = requireInputRecord(rawInput);
  const reference = resolveReferenceInput(input);
  const mode = requireString(input, "mode");
  if (mode !== "dry_run" && mode !== "materialize") {
    throw new Error("mode must be 'dry_run' or 'materialize'.");
  }
  return {
    ...reference,
    sourceCheckpointPath: requireRepositoryPath(
      input,
      "source_checkpoint_path",
    ),
    expectedSourceCheckpointSha256: requireSha256(
      input,
      "expected_source_checkpoint_sha256",
    ),
    mode,
  };
}

function unavailableAuthorityResult(
  request: PortableHandoffReferenceRequest,
  primaryFailureCode:
    | "HANDOFF_TOPOLOGY_RESOLVER_UNAVAILABLE"
    | "HANDOFF_PROVIDER_ROUTING_UNAVAILABLE",
): PortableHandoffAuthorityResult {
  return {
    status: "blocked",
    handoffId: null,
    handoffEnvelopeSha256: request.expectedHandoffEnvelopeSha256,
    primaryFailureCode,
    affectedPaths: [],
    unsupportedCapabilities: [],
    resolution: null,
  };
}

function unavailableTransitionResult(
  request: TransitionPreparedOrchestrationRequest,
): TransitionPreparedOrchestrationResult {
  return {
    status: "blocked",
    handoffId: null,
    sourceCheckpointSha256: request.expectedSourceCheckpointSha256,
    handoffEnvelopeSha256: request.expectedHandoffEnvelopeSha256,
    handoffHistorySha256: null,
    requestedTransition: "prepared_to_atomic_execution",
    destinationCheckpointPath: null,
    destinationCheckpointSha256: null,
    primaryFailureCode: "HANDOFF_VALIDATOR_UNAVAILABLE",
    affectedPaths: [],
    unsupportedCapabilities: [],
  };
}

function toAuthorityMcpResult(
  tool: Exclude<PortableHandoffToolName, "transition_prepared_orchestration">,
  workspaceRoot: string,
  result: PortableHandoffAuthorityResult,
): PortableHandoffMcpToolResult {
  return {
    ok: true,
    tool,
    workspace_root: workspaceRoot,
    summary: `Portable handoff authority returned ${result.status}.`,
    status: result.status,
    handoff_id: result.handoffId,
    handoff_envelope_sha256: result.handoffEnvelopeSha256,
    primary_failure_code: result.primaryFailureCode,
    affected_paths: result.affectedPaths,
    unsupported_capabilities: result.unsupportedCapabilities,
    resolution: result.resolution,
  };
}

function toTransitionMcpResult(
  workspaceRoot: string,
  result: TransitionPreparedOrchestrationResult,
): PortableHandoffMcpToolResult {
  return {
    ok: true,
    tool: "transition_prepared_orchestration",
    workspace_root: workspaceRoot,
    summary: `Portable handoff transition returned ${result.status}.`,
    status: result.status,
    handoff_id: result.handoffId,
    source_checkpoint_sha256: result.sourceCheckpointSha256,
    handoff_envelope_sha256: result.handoffEnvelopeSha256,
    handoff_history_sha256: result.handoffHistorySha256,
    requested_transition: result.requestedTransition,
    destination_checkpoint_path: result.destinationCheckpointPath,
    destination_checkpoint_sha256: result.destinationCheckpointSha256,
    primary_failure_code: result.primaryFailureCode,
    affected_paths: result.affectedPaths,
    unsupported_capabilities: result.unsupportedCapabilities,
  };
}

/** Parse and dispatch one portable handoff MCP operation. */
export async function handlePortableHandoffTool(
  tool: PortableHandoffToolName,
  rawInput: unknown,
  service: RepoAutomationService,
): Promise<PortableHandoffMcpToolResult> {
  if (tool === "transition_prepared_orchestration") {
    const input = resolveTransitionInput(rawInput);
    const transition = service.transitionPreparedOrchestration;
    const result =
      transition === undefined
        ? unavailableTransitionResult(input)
        : await transition.call(service, input);
    return toTransitionMcpResult(input.workspaceRoot, result);
  }

  const input = resolveReferenceInput(rawInput);
  const resolver =
    tool === "resolve_orchestration_topology"
      ? service.resolveOrchestrationTopology
      : service.resolveProviderRouting;
  const unavailableCode =
    tool === "resolve_orchestration_topology"
      ? "HANDOFF_TOPOLOGY_RESOLVER_UNAVAILABLE"
      : "HANDOFF_PROVIDER_ROUTING_UNAVAILABLE";
  const result =
    resolver === undefined
      ? unavailableAuthorityResult(input, unavailableCode)
      : await resolver.call(service, input);
  return toAuthorityMcpResult(tool, input.workspaceRoot, result);
}
