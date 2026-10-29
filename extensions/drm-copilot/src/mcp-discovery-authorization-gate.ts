/**
 * Admit controlled discovery tool calls by consuming the one-use record the
 * host's PreToolUse adapter issued for exactly this call.
 *
 * The native adapter digests the raw tool input exactly as the agent sent it,
 * so only this MCP layer, which still holds that raw input, can locate and
 * consume the matching record. The gate derives the controlled operation from
 * the tool and its input with the adapter's rules and refuses caller-supplied
 * `authorization_ref` or `root_grant_ref`. A call carrying `invocation_ref` is
 * a specialist call: the service consumes the tool authorization bound to that
 * invocation and the consumed reference travels in the handler input. A call
 * without `invocation_ref` is a root call: the service consumes the root grant
 * for the tool, operation and digest and forwards its reference. Neither path
 * falls back to an unverified principal; without a record the call is refused
 * before the handler runs.
 */

import {
  CONTROLLED_TOOLS,
  type ControlledTool,
  type DiscoveryAuthorizationCode,
  DiscoveryAuthorizationError,
  TOOL_OPERATIONS,
} from "./discovery-authorization-record";
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
/** Record references only the host gate and this layer may set. */
const GATE_SUPPLIED_KEYS: ReadonlyArray<string> = [
  "authorization_ref",
  "root_grant_ref",
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

/** Re-raise a consumer refusal so the MCP summary names its code. */
function withCode(error: unknown): unknown {
  if (
    error instanceof DiscoveryAuthorizationError &&
    !error.message.startsWith(error.code)
  ) {
    return refuse(error.code, error.message);
  }
  return error;
}

/**
 * Admit one controlled tool call and return the input the handler resolves.
 *
 * The call must carry `workspace_root` and must not carry `authorization_ref`
 * or `root_grant_ref`. With `invocation_ref` the service consumes the tool
 * authorization bound to that invocation and the returned input carries the
 * consumed `authorization_ref`; without it the service consumes the root grant
 * for the derived operation and raw input digest and the returned input carries
 * `root_grant_ref`.
 *
 * @throws DiscoveryAuthorizationError on every refusal; a refusal leaves every
 *   record untouched and the handler is never invoked.
 */
export function admitControlledToolCall(
  tool: ControlledTool,
  rawInput: unknown,
  service: RepoAutomationService,
): unknown {
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
  const supplied = GATE_SUPPLIED_KEYS.filter((key) =>
    Object.prototype.hasOwnProperty.call(inputs, key),
  );
  if (supplied.length > 0) {
    throw refuse(
      "AUTHORIZATION_REQUEST_INVALID",
      `${supplied.join(", ")} is supplied by the host gate, never by the caller.`,
    );
  }
  const workspaceRoot = inputs["workspace_root"];
  if (typeof workspaceRoot !== "string" || workspaceRoot.trim().length === 0) {
    throw refuse(
      "AUTHORIZATION_REQUEST_INVALID",
      `${tool} requires workspace_root.`,
    );
  }
  const operation = deriveControlledOperation(tool, inputs);
  if (operation === null) {
    throw refuse(
      "AUTHORIZATION_OPERATION_UNKNOWN",
      `The operation of ${tool} could not be derived from its input.`,
    );
  }
  const invocationRef = inputs["invocation_ref"];
  // Routing: a present invocation_ref names a specialist's started invocation;
  // its absence makes this a root call that needs the root grant of the hook.
  if (invocationRef !== undefined) {
    if (typeof invocationRef !== "string" || invocationRef.length === 0) {
      throw refuse(
        "AUTHORIZATION_REQUEST_INVALID",
        `${tool} invocation_ref must be a non-empty string.`,
      );
    }
    if (service.consumeDiscoveryToolAuthorization === undefined) {
      throw refuse(
        "AUTHORIZATION_MISSING",
        "This service cannot consume native tool authorizations.",
      );
    }
    try {
      const authorizationRef = service.consumeDiscoveryToolAuthorization({
        workspaceRoot,
        tool,
        operation,
        inputs,
        invocationRef,
      });
      return { ...inputs, authorization_ref: authorizationRef };
    } catch (error) {
      throw withCode(error);
    }
  }
  if (service.consumeDiscoveryRootGrant === undefined) {
    throw refuse(
      "DISCOVERY_HOST_BINDING_REQUIRED",
      "This service cannot consume native root grants.",
    );
  }
  try {
    const rootGrantRef = service.consumeDiscoveryRootGrant({
      workspaceRoot,
      tool,
      operation,
      inputs,
    });
    return { ...inputs, root_grant_ref: rootGrantRef };
  } catch (error) {
    throw withCode(error);
  }
}
