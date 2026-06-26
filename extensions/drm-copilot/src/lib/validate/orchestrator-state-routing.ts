import type { FileSystem } from "../file-system";
import { toPosixPath } from "../file-system";

/**
 * Routing and mandatory-handoff invariants for orchestrator checkpoints.
 *
 * Purpose:
 *     Port `scripts/dev_tools/_orchestrator_state_routing.py`. Validate that a
 *     completion checkpoint selects a known route, matches the routing matrix's
 *     required agents/skills/MCP tools, carries the corresponding receipts, and
 *     keeps the override/bypass lists empty with MCP-only lifecycle operations.
 *
 * Invariants / Constraints:
 *     - The routing matrix is injected (via `FileSystem`+root or an explicit
 *       `routingMatrix`) so the validator stays hermetic; no direct `node:fs`.
 *     - Error-message strings are identical to the Python source.
 *
 * Side Effects:
 *     None directly; the injected `FileSystem` performs reads when loading the
 *     matrix from disk.
 */

/** Relative path of the repository routing matrix consumed by production. */
export const ROUTING_MATRIX_RELATIVE_PATH = "config/orchestration-routing.json";

/**
 * Type guard for a plain object (non-null, non-array).
 *
 * @param value Candidate value.
 * @returns True when the value is a non-null, non-array object.
 */
function isObject(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

/**
 * Load the repository routing matrix from disk via the injected filesystem.
 *
 * @param fs Injected filesystem providing `readTextFile`.
 * @param root Repository root containing `config/orchestration-routing.json`.
 * @returns The parsed routing matrix as an opaque value.
 */
export function loadRoutingMatrix(fs: FileSystem, root: string): unknown {
  const path = `${toPosixPath(root).replace(/\/+$/, "")}/${ROUTING_MATRIX_RELATIVE_PATH}`;
  return JSON.parse(fs.readTextFile(path)) as unknown;
}

/**
 * Return a list of non-empty strings only when the value has that exact shape.
 *
 * Mirrors Python `_string_list`: every item must be a non-empty/whitespace
 * string, otherwise the whole value is rejected as `null`.
 *
 * @param value Candidate value.
 * @returns The string list, or null when the value is not a clean string list.
 */
export function stringList(value: unknown): string[] | null {
  if (!Array.isArray(value)) {
    return null;
  }
  // Reject the entire list if any element is not a non-empty string.
  if (!value.every((item) => typeof item === "string" && item.trim() !== "")) {
    return null;
  }
  return value as string[];
}

/**
 * Read a required string-list field from one route entry.
 *
 * @param route One route entry from the routing matrix.
 * @param key Field name to read.
 * @returns The string list, or an empty list when the field is malformed.
 */
export function routeList(
  route: Record<string, unknown>,
  key: string,
): string[] {
  const value = stringList(route[key]);
  return value === null ? [] : value;
}

/**
 * Validate a state list against the routing matrix list.
 *
 * Mirrors Python `_state_list`: returns null when the state value is not a clean
 * string list or does not equal the expected list; otherwise returns the value.
 *
 * @param state Checkpoint state object.
 * @param key Field name to read from state.
 * @param expected The expected list from the routing matrix.
 * @returns The matching list, or null when missing or mismatched.
 */
export function stateList(
  state: Record<string, unknown>,
  key: string,
  expected: string[],
): string[] | null {
  const value = stringList(state[key]);
  if (value === null) {
    return null;
  }
  // The state list must equal the routing-matrix list element-for-element.
  if (value.length !== expected.length) {
    return null;
  }
  if (!value.every((item, index) => item === expected[index])) {
    return null;
  }
  return value;
}

/**
 * Return legacy list delegation receipts as typed objects.
 *
 * @param receipts Raw delegation-receipts value from state.
 * @returns The receipt objects, dropping any non-object entries.
 */
export function listReceipts(receipts: unknown): Record<string, unknown>[] {
  if (!Array.isArray(receipts)) {
    return [];
  }
  return receipts.filter(isObject);
}

/**
 * Collect agent names from delegation receipts.
 *
 * @param state Checkpoint state object.
 * @returns The set of non-empty agent names present in delegation receipts.
 */
export function receiptAgents(state: Record<string, unknown>): Set<string> {
  const agents = new Set<string>();
  // Each delegation receipt may contribute one agent name when present.
  for (const receipt of listReceipts(state["delegation_receipts"])) {
    const agentName = receipt["agent_name"];
    if (typeof agentName === "string" && agentName.trim() !== "") {
      agents.add(agentName);
    }
  }
  return agents;
}

/**
 * Collect acknowledged skill names from skill receipts.
 *
 * @param state Checkpoint state object.
 * @returns The set of skill names with a required flag and non-empty evidence.
 */
export function receiptSkills(state: Record<string, unknown>): Set<string> {
  const skills = new Set<string>();
  const receipts = state["skill_receipts"];
  if (!Array.isArray(receipts)) {
    return skills;
  }
  // A skill counts only when it is named, marked required, and has evidence.
  for (const receipt of receipts) {
    if (!isObject(receipt)) {
      continue;
    }
    const skill = receipt["skill"];
    const required = receipt["required"];
    const evidence = receipt["evidence"];
    if (
      typeof skill === "string" &&
      skill.trim() !== "" &&
      required === true &&
      typeof evidence === "string" &&
      evidence.trim() !== ""
    ) {
      skills.add(skill);
    }
  }
  return skills;
}

/**
 * Collect successful MCP tool receipts from checkpoint state.
 *
 * @param state Checkpoint state object.
 * @returns The set of MCP tool names marked ok with non-empty evidence.
 */
export function mcpTools(state: Record<string, unknown>): Set<string> {
  const tools = new Set<string>();
  const receipts = state["mcp_call_receipts"];
  if (!Array.isArray(receipts)) {
    return tools;
  }
  // A tool counts only when it is named, marked ok, and has evidence.
  for (const receipt of receipts) {
    if (!isObject(receipt)) {
      continue;
    }
    const tool = receipt["tool"];
    const ok = receipt["ok"];
    const evidence = receipt["evidence"];
    if (
      typeof tool === "string" &&
      tool.trim() !== "" &&
      ok === true &&
      typeof evidence === "string" &&
      evidence.trim() !== ""
    ) {
      tools.add(tool);
    }
  }
  return tools;
}

/**
 * Require a checkpoint field to exist as an empty list.
 *
 * @param state Checkpoint state object.
 * @param key Field name that must be an empty list at completion.
 * @returns A single-error list when the field is malformed or non-empty.
 */
export function validateEmptyListField(
  state: Record<string, unknown>,
  key: string,
): string[] {
  const value = state[key];
  if (!Array.isArray(value)) {
    return [`Checkpoint ${key} must be an empty list at completion.`];
  }
  if (value.length > 0) {
    return [`Checkpoint ${key} must be empty at completion.`];
  }
  return [];
}

/**
 * Reject lifecycle-operation records that did not use the MCP surface.
 *
 * @param state Checkpoint state object.
 * @returns Validation errors for non-list or non-MCP lifecycle operations.
 */
export function validateLifecycleOperations(
  state: Record<string, unknown>,
): string[] {
  const operations = state["lifecycle_operations"];
  if (operations === undefined || operations === null) {
    return [];
  }
  if (!Array.isArray(operations)) {
    return ["Checkpoint lifecycle_operations must be a list when present."];
  }
  const errors: string[] = [];
  // Each operation must be an object recorded against the MCP surface.
  operations.forEach((operation, index) => {
    if (!isObject(operation)) {
      errors.push(
        `Checkpoint lifecycle_operations #${index} must be an object.`,
      );
      return;
    }
    if (operation["surface"] !== "mcp") {
      errors.push(
        `Checkpoint lifecycle_operations #${index} did not use MCP surface.`,
      );
    }
  });
  return errors;
}

/** Options for {@link validateRoutingContract}. */
export interface ValidateRoutingContractOptions {
  /** The routing matrix to validate against; injected for hermeticity. */
  readonly routingMatrix?: unknown;
}

/**
 * Validate mandatory route, handoff, skill, and MCP completion evidence.
 *
 * Purpose:
 *     Mirror Python `validate_routing_contract`. The caller supplies the routing
 *     matrix through `options.routingMatrix`; production wiring loads it via
 *     {@link loadRoutingMatrix} before calling.
 *
 * @param state Checkpoint state object.
 * @param options Routing-contract options carrying the routing matrix.
 * @returns Validation errors for routing, receipt, and completion violations.
 */
export function validateRoutingContract(
  state: Record<string, unknown>,
  options: ValidateRoutingContractOptions = {},
): string[] {
  const matrix = options.routingMatrix;
  if (!isObject(matrix)) {
    return ["Routing matrix missing routes object."];
  }
  const rawRoutes = matrix["routes"];
  if (!isObject(rawRoutes)) {
    return ["Routing matrix missing routes object."];
  }

  // Resolve the selected route id, falling back from route_id to path_selected.
  const routeIdValue =
    state["route_id"] !== undefined
      ? state["route_id"]
      : state["path_selected"];
  if (typeof routeIdValue !== "string" || routeIdValue.trim() === "") {
    return ["Checkpoint route_id or path_selected must select a route."];
  }
  const routeId = routeIdValue;
  const rawRoute = rawRoutes[routeId];
  if (!isObject(rawRoute)) {
    return [
      `Checkpoint selected route has no routing-matrix entry: ${routeId}.`,
    ];
  }

  const errors: string[] = [];
  const requiredAgents = routeList(rawRoute, "required_agents");
  const requiredSkills = routeList(rawRoute, "required_skills");
  const requiredMcpTools = routeList(rawRoute, "required_mcp_tools");

  if (stateList(state, "required_agents", requiredAgents) === null) {
    errors.push(
      `Checkpoint required_agents must match routing matrix for route ${routeId}.`,
    );
  }
  if (stateList(state, "required_skills", requiredSkills) === null) {
    errors.push(
      `Checkpoint required_skills must match routing matrix for route ${routeId}.`,
    );
  }
  if (stateList(state, "required_mcp_tools", requiredMcpTools) === null) {
    errors.push(
      `Checkpoint required_mcp_tools must match routing matrix for route ${routeId}.`,
    );
  }

  const actualAgents = receiptAgents(state);
  for (const agent of requiredAgents) {
    if (!actualAgents.has(agent)) {
      errors.push(`Checkpoint missing required agent receipt: ${agent}.`);
    }
  }

  const actualSkills = receiptSkills(state);
  for (const skill of requiredSkills) {
    if (!actualSkills.has(skill)) {
      errors.push(`Checkpoint missing required skill receipt: ${skill}.`);
    }
  }

  const actualTools = mcpTools(state);
  for (const tool of requiredMcpTools) {
    if (!actualTools.has(tool)) {
      errors.push(`Checkpoint missing successful MCP receipt: ${tool}.`);
    }
  }

  errors.push(...validateEmptyListField(state, "local_execution_overrides"));
  errors.push(...validateEmptyListField(state, "delegation_bypasses"));
  errors.push(...validateLifecycleOperations(state));
  return errors;
}
