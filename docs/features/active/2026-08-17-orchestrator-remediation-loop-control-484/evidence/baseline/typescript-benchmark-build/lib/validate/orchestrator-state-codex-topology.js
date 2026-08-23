"use strict";
/** Deterministic Codex topology receipt validation and delegation gates. */
Object.defineProperty(exports, "__esModule", { value: true });
exports.CODEX_TOPOLOGY_RECEIPTS_KEY = void 0;
exports.validateCodexTopologyReceipt = validateCodexTopologyReceipt;
exports.validateCodexTopologyReceipts = validateCodexTopologyReceipts;
exports.validateCodexTopologyGate = validateCodexTopologyGate;
exports.validateCodexTopologyState = validateCodexTopologyState;
const codex_topology_resolver_1 = require("./codex-topology-resolver");
const orchestrator_state_codex_model_routing_1 = require("./orchestrator-state-codex-model-routing");
exports.CODEX_TOPOLOGY_RECEIPTS_KEY = "codex_topology_receipts";
const REQUIRED_KEYS = [
    "phase",
    "execution_context",
    "languages",
    "production_file_count",
    "test_file_count",
    "cross_cutting",
    "root_persona",
    "route",
    "topology",
    "logical_agent",
    "routing_reason",
    "max_production_files",
    "max_test_files",
];
const RESOLVED_KEYS = REQUIRED_KEYS.filter((key) => key !== "phase");
const FORCED_ROOT_PERSONAS = new Set([
    "epic-orchestrator",
    "epic-planner",
]);
function isObject(value) {
    return typeof value === "object" && value !== null && !Array.isArray(value);
}
function pythonRepr(value) {
    if (value === undefined || value === null) {
        return "None";
    }
    if (typeof value === "string") {
        const escaped = value
            .replaceAll("\\", "\\\\")
            .replaceAll("'", "\\'")
            .replaceAll("\n", "\\n")
            .replaceAll("\r", "\\r")
            .replaceAll("\t", "\\t");
        return `'${escaped}'`;
    }
    if (typeof value === "boolean") {
        return value ? "True" : "False";
    }
    if (Array.isArray(value)) {
        return `[${value.map(pythonRepr).join(", ")}]`;
    }
    if (isObject(value)) {
        const entries = Object.entries(value).map(([key, item]) => `${pythonRepr(key)}: ${pythonRepr(item)}`);
        return `{${entries.join(", ")}}`;
    }
    return String(value);
}
function valuesEqual(actual, expected) {
    if (Array.isArray(actual) && Array.isArray(expected)) {
        return (actual.length === expected.length &&
            actual.every((item, index) => item === expected[index]));
    }
    return actual === expected;
}
function validateReceiptInputs(receipt, prefix) {
    const errors = [];
    const languages = receipt["languages"];
    if (!Array.isArray(languages) ||
        languages.some((language) => typeof language !== "string" || language.trim().length === 0)) {
        errors.push(`${prefix}.languages must be a list of non-empty strings.`);
    }
    for (const key of ["production_file_count", "test_file_count"]) {
        const value = receipt[key];
        if (typeof value !== "number" || !Number.isInteger(value)) {
            errors.push(`${prefix}.${key} must be an integer.`);
        }
    }
    if (typeof receipt["cross_cutting"] !== "boolean") {
        errors.push(`${prefix}.cross_cutting must be a boolean.`);
    }
    if (typeof receipt["execution_context"] !== "string") {
        errors.push(`${prefix}.execution_context must be a string.`);
    }
    const rootPersona = receipt["root_persona"];
    if (rootPersona !== null && !FORCED_ROOT_PERSONAS.has(rootPersona)) {
        errors.push(`${prefix}.root_persona must be null or one of ` +
            "('epic-orchestrator', 'epic-planner').");
    }
    return errors;
}
function validateReceipt(value, prefix) {
    if (!isObject(value)) {
        return [`${prefix} must be an object.`];
    }
    const missing = REQUIRED_KEYS.filter((key) => !(key in value));
    if (missing.length > 0) {
        return [`${prefix} missing required keys: ${missing.join(", ")}.`];
    }
    const errors = [];
    const phase = value["phase"];
    if (typeof phase !== "string" || phase.trim().length === 0) {
        errors.push(`${prefix}.phase must be a non-empty string.`);
    }
    const inputErrors = validateReceiptInputs(value, prefix);
    errors.push(...inputErrors);
    if (inputErrors.length > 0) {
        return errors;
    }
    let expected;
    try {
        expected = (0, codex_topology_resolver_1.resolveCodexTopology)(value["languages"], value["production_file_count"], value["test_file_count"], value["execution_context"], {
            crossCutting: value["cross_cutting"],
            rootPersona: value["root_persona"],
        });
    }
    catch (error) {
        const message = error instanceof Error ? error.message : String(error);
        errors.push(`${prefix} has invalid routing inputs: ${message}`);
        return errors;
    }
    for (const key of RESOLVED_KEYS) {
        if (!valuesEqual(value[key], expected[key])) {
            errors.push(`${prefix}.${key} must be ${pythonRepr(expected[key])}, ` +
                `found ${pythonRepr(value[key])}.`);
        }
    }
    return errors;
}
/** Validate one receipt with a caller-selected diagnostic prefix. */
function validateCodexTopologyReceipt(value, prefix = `Checkpoint ${exports.CODEX_TOPOLOGY_RECEIPTS_KEY}[0]`) {
    return validateReceipt(value, prefix);
}
/** Validate every present topology receipt against the canonical resolver. */
function validateCodexTopologyReceipts(value) {
    if (!Array.isArray(value)) {
        return [
            `Checkpoint ${exports.CODEX_TOPOLOGY_RECEIPTS_KEY} must be a list when present.`,
        ];
    }
    return value.flatMap((item, index) => validateReceipt(item, `Checkpoint ${exports.CODEX_TOPOLOGY_RECEIPTS_KEY}[${index}]`));
}
function delegatedAgentNames(state) {
    const result = new Set();
    let receipts = state["delegation_receipts"];
    if (isObject(receipts)) {
        receipts = receipts["agents"];
    }
    if (!Array.isArray(receipts)) {
        return result;
    }
    for (const item of receipts) {
        if (!isObject(item)) {
            continue;
        }
        const agentName = item["agent_name"];
        if (typeof agentName === "string" && agentName.trim().length > 0) {
            result.add(agentName);
        }
    }
    return result;
}
function validReceipts(value) {
    return value.filter((item) => isObject(item) && validateCodexTopologyReceipts([item]).length === 0);
}
function modelDeployments(state, logicalAgent) {
    const result = new Set();
    const receipts = state[orchestrator_state_codex_model_routing_1.CODEX_MODEL_ROUTING_RECEIPTS_KEY];
    if (!Array.isArray(receipts)) {
        return result;
    }
    for (const item of receipts) {
        if (!isObject(item) ||
            (0, orchestrator_state_codex_model_routing_1.validateCodexModelRoutingReceipt)(item).length > 0 ||
            item["logical_agent"] !== logicalAgent) {
            continue;
        }
        const deployment = item["deployment_agent"];
        if (typeof deployment === "string") {
            result.add(deployment);
        }
    }
    return result;
}
/** Require exact topology evidence for root personas and initial delegates. */
function validateCodexTopologyGate(state, options = {}) {
    const delegated = delegatedAgentNames(state);
    const requiredRootPersona = options.requiredRootPersona;
    if (delegated.size === 0 && requiredRootPersona === undefined) {
        return [];
    }
    const value = state[exports.CODEX_TOPOLOGY_RECEIPTS_KEY];
    const errors = validateCodexTopologyReceipts(value);
    if (!Array.isArray(value)) {
        return errors;
    }
    const receipts = validReceipts(value);
    if (requiredRootPersona !== undefined &&
        !receipts.some((receipt) => receipt.root_persona === requiredRootPersona)) {
        errors.push(`Checkpoint ${exports.CODEX_TOPOLOGY_RECEIPTS_KEY} is missing the forced ` +
            `root persona receipt for ${requiredRootPersona}.`);
    }
    const childReceipts = receipts.filter((receipt) => receipt.root_persona === null);
    if (delegated.size > 0 && childReceipts.length === 0) {
        errors.push(`Checkpoint ${exports.CODEX_TOPOLOGY_RECEIPTS_KEY} is missing a child ` +
            "topology receipt for recorded delegations.");
    }
    for (const receipt of childReceipts) {
        const selectedRoute = state["path_selected"];
        if (receipt.execution_context === "standalone" &&
            (selectedRoute === "small" || selectedRoute === "large") &&
            receipt.route !== selectedRoute) {
            errors.push(`Checkpoint path_selected ${pythonRepr(selectedRoute)} does not match ` +
                `the resolved Codex topology route ${pythonRepr(receipt.route)}.`);
        }
        const allowedNames = modelDeployments(state, receipt.logical_agent);
        allowedNames.add(receipt.logical_agent);
        if ([...delegated].every((agent) => !allowedNames.has(agent))) {
            errors.push("Checkpoint delegation_receipts is missing the exact resolved " +
                `topology agent for ${receipt.logical_agent}: ` +
                `${[...allowedNames].sort().join(", ")}.`);
        }
    }
    return errors;
}
/** Apply always-on present-receipt validation and the optional topology gate. */
function validateCodexTopologyState(state, requireGate = false, options = {}) {
    const errors = [];
    if (exports.CODEX_TOPOLOGY_RECEIPTS_KEY in state) {
        errors.push(...validateCodexTopologyReceipts(state[exports.CODEX_TOPOLOGY_RECEIPTS_KEY]));
    }
    if (requireGate) {
        errors.push(...validateCodexTopologyGate(state, options));
    }
    return errors;
}
