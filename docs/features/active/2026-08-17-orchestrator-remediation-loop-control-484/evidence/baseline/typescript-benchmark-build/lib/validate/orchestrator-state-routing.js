"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.ROUTING_MATRIX_RELATIVE_PATH = void 0;
exports.routeRequiresPrGate = routeRequiresPrGate;
exports.routeRequiresCiGate = routeRequiresCiGate;
exports.validatePhaseCompleteness = validatePhaseCompleteness;
exports.loadRoutingMatrix = loadRoutingMatrix;
exports.stringList = stringList;
exports.routeList = routeList;
exports.stateList = stateList;
exports.listReceipts = listReceipts;
exports.receiptAgents = receiptAgents;
exports.receiptSkills = receiptSkills;
exports.mcpTools = mcpTools;
exports.validateEmptyListField = validateEmptyListField;
exports.validateLifecycleOperations = validateLifecycleOperations;
exports.validateRoutingContract = validateRoutingContract;
const file_system_1 = require("../file-system");
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
exports.ROUTING_MATRIX_RELATIVE_PATH = "config/orchestration-routing.json";
/** Mandatory canonical phases that selected routes must complete. */
const MANDATORY_ROUTE_PHASES = {
    small: ["S3_promotion", "S4_atomic_planning"],
    preparation: ["S3_promotion", "S4_atomic_planning"],
};
/**
 * Type guard for a plain object (non-null, non-array).
 *
 * @param value Candidate value.
 * @returns True when the value is a non-null, non-array object.
 */
function isObject(value) {
    return typeof value === "object" && value !== null && !Array.isArray(value);
}
/**
 * Resolve the selected route, preferring route_id over path_selected.
 *
 * @param state Checkpoint state object.
 * @returns The selected non-empty route id, or null when none is valid.
 */
function selectedRouteId(state) {
    const value = state["route_id"] !== undefined
        ? state["route_id"]
        : state["path_selected"];
    return typeof value === "string" && value.trim() !== "" ? value : null;
}
/**
 * Report whether the selected route explicitly requires a PR gate.
 *
 * A PR gate is required only when the selected route exists and its
 * `requires_pr_gate` value is the literal Boolean true.
 *
 * @param state Checkpoint state object.
 * @param options Routing matrix injection.
 * @returns True only for a route that explicitly opts into the PR gate.
 */
function routeRequiresPrGate(state, options = {}) {
    const routeId = selectedRouteId(state);
    const matrix = options.routingMatrix;
    if (routeId === null || !isObject(matrix) || !isObject(matrix["routes"])) {
        return false;
    }
    const route = matrix["routes"][routeId];
    return isObject(route) && route["requires_pr_gate"] === true;
}
/**
 * Report whether the selected route requires a CI gate.
 *
 * Only the literal Boolean false opts out. Missing or unknown routes,
 * malformed matrices, absent flags, and non-Boolean values fail closed.
 *
 * @param state Checkpoint state object.
 * @param options Routing matrix injection.
 * @returns False only for an explicit `requires_ci_gate: false` route.
 */
function routeRequiresCiGate(state, options = {}) {
    const routeId = selectedRouteId(state);
    const matrix = options.routingMatrix;
    if (routeId === null || !isObject(matrix) || !isObject(matrix["routes"])) {
        return true;
    }
    const route = matrix["routes"][routeId];
    return !isObject(route) || route["requires_ci_gate"] !== false;
}
/**
 * Validate mandatory canonical phases for the selected route.
 *
 * @param state Checkpoint state object.
 * @returns One error per mandatory phase absent from completed_steps.
 */
function validatePhaseCompleteness(state) {
    const routeId = selectedRouteId(state);
    if (routeId === null) {
        return [];
    }
    const mandatory = MANDATORY_ROUTE_PHASES[routeId];
    if (mandatory === undefined) {
        return [];
    }
    const completed = new Set(stringList(state["completed_steps"]) ?? []);
    return mandatory
        .filter((phase) => !completed.has(phase))
        .map((phase) => "Checkpoint completion validation failed: route " +
        `${routeId} is missing mandatory phase ${phase}.`);
}
/**
 * Load the repository routing matrix from disk via the injected filesystem.
 *
 * @param fs Injected filesystem providing `readTextFile`.
 * @param root Repository root containing `config/orchestration-routing.json`.
 * @returns The parsed routing matrix as an opaque value.
 */
function loadRoutingMatrix(fs, root) {
    const path = `${(0, file_system_1.toPosixPath)(root).replace(/\/+$/, "")}/${exports.ROUTING_MATRIX_RELATIVE_PATH}`;
    return JSON.parse(fs.readTextFile(path));
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
function stringList(value) {
    if (!Array.isArray(value)) {
        return null;
    }
    // Reject the entire list if any element is not a non-empty string.
    if (!value.every((item) => typeof item === "string" && item.trim() !== "")) {
        return null;
    }
    return value;
}
/**
 * Read a required string-list field from one route entry.
 *
 * @param route One route entry from the routing matrix.
 * @param key Field name to read.
 * @returns The string list, or an empty list when the field is malformed.
 */
function routeList(route, key) {
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
function stateList(state, key, expected) {
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
 * Return legacy or canonical object-form delegation receipts as typed objects.
 *
 * @param receipts Raw delegation-receipts value from state.
 * @returns The receipt objects, dropping any non-object entries.
 */
function listReceipts(receipts) {
    if (isObject(receipts)) {
        receipts = receipts["agents"];
    }
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
function receiptAgents(state) {
    const agents = new Set();
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
function receiptSkills(state) {
    const skills = new Set();
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
        if (typeof skill === "string" &&
            skill.trim() !== "" &&
            required === true &&
            typeof evidence === "string" &&
            evidence.trim() !== "") {
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
function mcpTools(state) {
    const tools = new Set();
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
        if (typeof tool === "string" &&
            tool.trim() !== "" &&
            ok === true &&
            typeof evidence === "string" &&
            evidence.trim() !== "") {
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
function validateEmptyListField(state, key) {
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
function validateLifecycleOperations(state) {
    const operations = state["lifecycle_operations"];
    if (operations === undefined || operations === null) {
        return [];
    }
    if (!Array.isArray(operations)) {
        return ["Checkpoint lifecycle_operations must be a list when present."];
    }
    const errors = [];
    // Each operation must be an object recorded against the MCP surface.
    operations.forEach((operation, index) => {
        if (!isObject(operation)) {
            errors.push(`Checkpoint lifecycle_operations #${index} must be an object.`);
            return;
        }
        if (operation["surface"] !== "mcp") {
            errors.push(`Checkpoint lifecycle_operations #${index} did not use MCP surface.`);
        }
    });
    return errors;
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
function validateRoutingContract(state, options = {}) {
    const matrix = options.routingMatrix;
    if (!isObject(matrix)) {
        return ["Routing matrix missing routes object."];
    }
    const rawRoutes = matrix["routes"];
    if (!isObject(rawRoutes)) {
        return ["Routing matrix missing routes object."];
    }
    // Resolve the selected route id, falling back from route_id to path_selected.
    const routeId = selectedRouteId(state);
    if (routeId === null) {
        return ["Checkpoint route_id or path_selected must select a route."];
    }
    const rawRoute = rawRoutes[routeId];
    if (!isObject(rawRoute)) {
        return [
            `Checkpoint selected route has no routing-matrix entry: ${routeId}.`,
        ];
    }
    const errors = [];
    const requiredAgents = routeList(rawRoute, "required_agents");
    const requiredSkills = routeList(rawRoute, "required_skills");
    const requiredMcpTools = routeList(rawRoute, "required_mcp_tools");
    if (stateList(state, "required_agents", requiredAgents) === null) {
        errors.push(`Checkpoint required_agents must match routing matrix for route ${routeId}.`);
    }
    if (stateList(state, "required_skills", requiredSkills) === null) {
        errors.push(`Checkpoint required_skills must match routing matrix for route ${routeId}.`);
    }
    if (stateList(state, "required_mcp_tools", requiredMcpTools) === null) {
        errors.push(`Checkpoint required_mcp_tools must match routing matrix for route ${routeId}.`);
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
