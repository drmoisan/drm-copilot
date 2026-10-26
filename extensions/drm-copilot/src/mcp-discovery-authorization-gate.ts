/**
 * Admit controlled discovery tool calls of a discovery role by consuming the
 * one-use native authorization the host's PreToolUse adapter issued.
 *
 * The native adapter digests the raw tool input exactly as the agent sent it,
 * so only this MCP layer, which still holds that raw input, can locate and
 * consume the matching grant. The gate derives the controlled operation from
 * the tool and its input with the adapter's rules, refuses a caller-supplied
 * `authorization_ref`, asks the service to consume the grant bound to the
 * trusted identity and the request's `invocation_ref`, and forwards the
 * consumed record's reference into the handler input. A root process (no
 * discovery role) bypasses the gate and reads no authorization record.
 */

import {
  CONTROLLED_TOOLS,
  type ControlledTool,
  type DiscoveryAuthorizationCode,
  DiscoveryAuthorizationError,
  TOOL_OPERATIONS,
} from "./discovery-authorization-record";
import { isDiscoveryRole } from "./mcp-tool-inputs-discovery-authority";
import type { RepoAutomationService } from "./repo-automation-service-contract";

/** `artifact_type` values of validate_discovery_artifacts and their operations. */
export const VALIDATE_ARTIFACT_OPERATIONS: Readonly<Record<string, string>> = {
  profile: "validate-profile",
  "domain-profile": "validate-profile",
  "feature-contract": "validate-feature-contract",
  "coverage-ledger": "validate-coverage-ledger",
  "runtime-scenario": "validate-runtime-scenario",
  "runtime-characterization-scenario": "validate-runtime-scenario",
  "parity-matrix": "validate-parity-matrix",
  "unspecified-behavior": "validate-unspecified-behavior",
  "product-decision": "validate-product-decision",
  "evidence-reference": "validate-evidence-reference",
  decisions: "validate-decisions",
  all: "validate-all",
};
const SCENARIO_KINDS: ReadonlyArray<string> = [
  "runtime-scenario",
  "runtime-characterization-scenario",
];
const REPORT_TYPES: ReadonlyArray<string> = [
  "coverage",
  "parity",
  "completion",
];

export function isControlledTool(name: string): name is ControlledTool {
  return CONTROLLED_TOOLS.includes(name);
}

/**
 * Build a gate refusal whose message starts with its code, so the MCP failure
 * summary (which carries the message only) names the refusal class.
 */
function refuse(
  code: DiscoveryAuthorizationCode,
  message: string,
): DiscoveryAuthorizationError {
  return new DiscoveryAuthorizationError(code, `${code}: ${message}`);
}

/**
 * Derive the controlled operation of one tool call with the native adapter's
 * rules, or null when it cannot be derived (which the caller refuses).
 *
 * Single-operation tools map directly. `create_discovery_artifact` selects by
 * `artifact_kind`, `run_discovery_report` by `report_type`, and
 * `validate_discovery_artifacts` by `artifact_type` (`validate-all` when absent).
 */
export function deriveControlledOperation(
  tool: string,
  inputs: Readonly<Record<string, unknown>>,
): string | null {
  if (!isControlledTool(tool)) {
    return null;
  }
  const operations = TOOL_OPERATIONS[tool];
  if (operations.length === 1) {
    return operations[0] ?? null;
  }
  // Multi-operation tools select by one input field; an unknown value is refused.
  switch (tool) {
    case "create_discovery_artifact": {
      const kind = inputs["artifact_kind"];
      if (kind === "feature-contract") {
        return "new-contract";
      }
      return typeof kind === "string" && SCENARIO_KINDS.includes(kind)
        ? "new-scenario"
        : null;
    }
    case "run_discovery_report": {
      const report = inputs["report_type"];
      return typeof report === "string" && REPORT_TYPES.includes(report)
        ? `${report}-report`
        : null;
    }
    case "validate_discovery_artifacts": {
      const type = inputs["artifact_type"];
      if (type === undefined || type === null) {
        return "validate-all";
      }
      return typeof type === "string"
        ? (VALIDATE_ARTIFACT_OPERATIONS[type] ?? null)
        : null;
    }
    default:
      return null;
  }
}

/**
 * Admit one controlled tool call and return the input the handler resolves.
 *
 * For a root process the raw input is returned unchanged and no store is read.
 * For a discovery role the call must carry `invocation_ref` and `workspace_root`
 * and must not carry `authorization_ref`; the service consumes the grant bound
 * to the trusted identity, the derived operation and the raw input digest, and
 * the returned input carries the consumed `authorization_ref`.
 *
 * @throws DiscoveryAuthorizationError on every refusal; a refusal leaves the
 *   grant untouched and the handler is never invoked.
 */
export function admitControlledToolCall(
  tool: ControlledTool,
  rawInput: unknown,
  service: RepoAutomationService,
): unknown {
  const role = service.discoveryRole?.() ?? null;
  if (!isDiscoveryRole(role)) {
    return rawInput;
  }
  if (
    rawInput === null ||
    typeof rawInput !== "object" ||
    Array.isArray(rawInput)
  ) {
    throw refuse(
      "AUTHORIZATION_REQUEST_INVALID",
      `Controlled tool ${tool} requires an object input.`,
    );
  }
  const inputs = rawInput as Readonly<Record<string, unknown>>;
  if (Object.prototype.hasOwnProperty.call(inputs, "authorization_ref")) {
    throw refuse(
      "AUTHORIZATION_REQUEST_INVALID",
      "authorization_ref is supplied by the host gate, never by the caller.",
    );
  }
  const invocationRef = inputs["invocation_ref"];
  if (typeof invocationRef !== "string" || invocationRef.length === 0) {
    throw refuse(
      "AUTHORIZATION_REQUEST_INVALID",
      `${tool} requires invocation_ref for discovery role ${role}.`,
    );
  }
  const workspaceRoot = inputs["workspace_root"];
  if (typeof workspaceRoot !== "string" || workspaceRoot.trim().length === 0) {
    throw refuse(
      "AUTHORIZATION_REQUEST_INVALID",
      `${tool} requires workspace_root for discovery role ${role}.`,
    );
  }
  const operation = deriveControlledOperation(tool, inputs);
  if (operation === null) {
    throw refuse(
      "AUTHORIZATION_OPERATION_UNKNOWN",
      `The operation of ${tool} could not be derived from its input.`,
    );
  }
  if (service.consumeDiscoveryToolAuthorization === undefined) {
    throw refuse(
      "AUTHORIZATION_MISSING",
      "This service cannot consume native tool authorizations.",
    );
  }
  let authorizationRef: string;
  try {
    authorizationRef = service.consumeDiscoveryToolAuthorization({
      workspaceRoot,
      tool,
      operation,
      inputs,
      invocationRef,
    });
  } catch (error) {
    // The consumer's refusal keeps its code; the MCP summary must name it too.
    if (
      error instanceof DiscoveryAuthorizationError &&
      !error.message.startsWith(error.code)
    ) {
      throw refuse(error.code, error.message);
    }
    throw error;
  }
  return { ...inputs, authorization_ref: authorizationRef };
}
