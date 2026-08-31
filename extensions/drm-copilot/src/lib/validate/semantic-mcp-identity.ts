export const REGISTERED_HANDOFF_OPERATIONS = [
  "validate_orchestration_artifacts",
  "resolve_orchestration_topology",
  "resolve_provider_routing",
  "transition_prepared_orchestration",
] as const;

export type RegisteredHandoffOperation =
  (typeof REGISTERED_HANDOFF_OPERATIONS)[number];

export interface SemanticMcpIdentity {
  readonly semanticId: `drm-copilot.${RegisteredHandoffOperation}`;
  readonly server: "drm-copilot";
  readonly operation: RegisteredHandoffOperation;
  readonly transportId: string;
}

const MCP_TRANSPORT_ID = /^mcp__([a-z0-9_-]+)__([a-z0-9_]+)$/;
const SERVER_ALIASES = new Set(["drm-copilot", "drm_copilot"]);

function isRegisteredOperation(
  value: string,
): value is RegisteredHandoffOperation {
  return REGISTERED_HANDOFF_OPERATIONS.some((operation) => operation === value);
}

export function parseSemanticMcpIdentity(
  transportId: string,
): SemanticMcpIdentity | null {
  const match = MCP_TRANSPORT_ID.exec(transportId);
  const server = match?.[1];
  const operation = match?.[2];
  if (
    server === undefined ||
    operation === undefined ||
    !SERVER_ALIASES.has(server) ||
    !isRegisteredOperation(operation)
  ) {
    return null;
  }
  return {
    semanticId: `drm-copilot.${operation}`,
    server: "drm-copilot",
    operation,
    transportId,
  };
}

export function isExactSemanticMcpOperation(
  transportId: string,
  expectedOperation: RegisteredHandoffOperation,
): boolean {
  return parseSemanticMcpIdentity(transportId)?.operation === expectedOperation;
}
