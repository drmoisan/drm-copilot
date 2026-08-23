"use strict";
/** Deterministic Codex topology receipt validation and delegation gates. */
Object.defineProperty(exports, "__esModule", { value: true });
exports.CODEX_TOPOLOGY_RECEIPTS_KEY = void 0;
exports.validateCodexTopologyReceipt = validateCodexTopologyReceipt;
exports.validateCodexTopologyReceipts = validateCodexTopologyReceipts;
exports.validateCodexTopologyGate = validateCodexTopologyGate;
exports.validateCodexTopologyState = validateCodexTopologyState;
const codex_topology_resolver_1 = require("./codex-topology-resolver");
exports.CODEX_TOPOLOGY_RECEIPTS_KEY = "codex_topology_receipts";
const CODEX_TOPOLOGY_GATE_ERROR = "ORCH_ROUTING_GATE_CODEX_TOPOLOGY";
const DEPLOYMENT_PROFILE_SUFFIX = /-c(?:1|2|3(?:-elevated)?|4)$/u;
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
function receiptInputsAreValid(receipt) {
    const languages = receipt["languages"];
    return (Array.isArray(languages) &&
        !languages.some((language) => typeof language !== "string" || language.trim().length === 0) &&
        typeof receipt["production_file_count"] === "number" &&
        Number.isInteger(receipt["production_file_count"]) &&
        typeof receipt["test_file_count"] === "number" &&
        Number.isInteger(receipt["test_file_count"]) &&
        typeof receipt["cross_cutting"] === "boolean" &&
        typeof receipt["execution_context"] === "string" &&
        (receipt["root_persona"] === null ||
            FORCED_ROOT_PERSONAS.has(receipt["root_persona"])));
}
function appendReceiptInputErrors(receipt, prefix, errors) {
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
}
function hasRequiredKeys(receipt) {
    for (const key of REQUIRED_KEYS) {
        if (!(key in receipt)) {
            return false;
        }
    }
    return true;
}
function languagesEqual(left, right) {
    return (left.length === right.length &&
        left.every((language, index) => language === right[index]));
}
function entryMatches(entry, receipt, languages) {
    return (languagesEqual(entry.languages, languages) &&
        entry.productionFileCount === receipt["production_file_count"] &&
        entry.testFileCount === receipt["test_file_count"] &&
        entry.executionContext === receipt["execution_context"] &&
        entry.crossCutting === receipt["cross_cutting"] &&
        entry.rootPersona === receipt["root_persona"]);
}
function findResolution(entries, receipt, languages) {
    const lastIndex = entries.length - 1;
    const lastEntry = entries[lastIndex];
    if (lastEntry !== undefined && entryMatches(lastEntry, receipt, languages)) {
        return lastEntry.resolution;
    }
    for (let index = 0; index < lastIndex; index += 1) {
        const entry = entries[index];
        if (entry !== undefined && entryMatches(entry, receipt, languages)) {
            return entry.resolution;
        }
    }
    return undefined;
}
function receiptPrefix(index, fixedPrefix) {
    return fixedPrefix ?? `Checkpoint ${exports.CODEX_TOPOLOGY_RECEIPTS_KEY}[${index}]`;
}
function validateReceipt(value, index, errors, successfulResolutions, fixedPrefix) {
    if (!isObject(value)) {
        errors.push(`${receiptPrefix(index, fixedPrefix)} must be an object.`);
        return;
    }
    if (!hasRequiredKeys(value)) {
        const missing = REQUIRED_KEYS.filter((key) => !(key in value));
        errors.push(`${receiptPrefix(index, fixedPrefix)} missing required keys: ` +
            `${missing.join(", ")}.`);
        return;
    }
    const phase = value["phase"];
    if (typeof phase !== "string" || phase.trim().length === 0) {
        errors.push(`${receiptPrefix(index, fixedPrefix)}.phase must be a non-empty string.`);
    }
    if (!receiptInputsAreValid(value)) {
        appendReceiptInputErrors(value, receiptPrefix(index, fixedPrefix), errors);
        return;
    }
    const languages = value["languages"];
    let expected = findResolution(successfulResolutions, value, languages);
    if (expected === undefined) {
        try {
            expected = (0, codex_topology_resolver_1.resolveCodexTopology)(value["languages"], value["production_file_count"], value["test_file_count"], value["execution_context"], {
                crossCutting: value["cross_cutting"],
                rootPersona: value["root_persona"],
            });
            successfulResolutions.push({
                languages: [...languages],
                productionFileCount: value["production_file_count"],
                testFileCount: value["test_file_count"],
                executionContext: value["execution_context"],
                crossCutting: value["cross_cutting"],
                rootPersona: value["root_persona"],
                resolution: expected,
            });
        }
        catch (error) {
            const message = error instanceof Error ? error.message : String(error);
            errors.push(`${receiptPrefix(index, fixedPrefix)} has invalid routing inputs: ${message}`);
            return;
        }
    }
    for (const key of RESOLVED_KEYS) {
        if (!valuesEqual(value[key], expected[key])) {
            errors.push(`${receiptPrefix(index, fixedPrefix)}.${key} must be ` +
                `${pythonRepr(expected[key])}, ` +
                `found ${pythonRepr(value[key])}.`);
        }
    }
}
/** Validate one receipt with a caller-selected diagnostic prefix. */
function validateCodexTopologyReceipt(value, prefix = `Checkpoint ${exports.CODEX_TOPOLOGY_RECEIPTS_KEY}[0]`) {
    const errors = [];
    validateReceipt(value, 0, errors, [], prefix);
    return errors;
}
/** Validate every present topology receipt against the canonical resolver. */
function validateCodexTopologyReceipts(value) {
    if (!Array.isArray(value)) {
        return [
            `Checkpoint ${exports.CODEX_TOPOLOGY_RECEIPTS_KEY} must be a list when present.`,
        ];
    }
    const errors = [];
    const successfulResolutions = [];
    value.forEach((item, index) => {
        validateReceipt(item, index, errors, successfulResolutions);
    });
    return errors;
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
            result.add(agentName.replace(DEPLOYMENT_PROFILE_SUFFIX, ""));
        }
    }
    return result;
}
function validReceipts(value) {
    return value.filter((item) => isObject(item) && validateCodexTopologyReceipts([item]).length === 0);
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
        const allowedNames = new Set([receipt.logical_agent]);
        if (!delegated.has(receipt.logical_agent)) {
            errors.push("Checkpoint delegation_receipts is missing the exact resolved " +
                `topology agent for ${receipt.logical_agent}: ` +
                `${[...allowedNames].sort().join(", ")}.`);
        }
    }
    return errors;
}
/** Apply either selected-gate or always-on present-receipt validation once. */
function validateCodexTopologyState(state, requireGate = false, options = {}) {
    if (requireGate) {
        return validateCodexTopologyGate(state, options).map((error) => `${CODEX_TOPOLOGY_GATE_ERROR}: ${error}`);
    }
    if (exports.CODEX_TOPOLOGY_RECEIPTS_KEY in state) {
        return validateCodexTopologyReceipts(state[exports.CODEX_TOPOLOGY_RECEIPTS_KEY]);
    }
    return [];
}
