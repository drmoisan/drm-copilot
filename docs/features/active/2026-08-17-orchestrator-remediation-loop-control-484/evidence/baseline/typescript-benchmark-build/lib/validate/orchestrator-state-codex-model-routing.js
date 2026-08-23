"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.ModelUnavailableError = exports.PARALLEL_ROOT_CONTEXT_PERSONAS = exports.LOGICAL_AGENT_ALIASES = exports.BAND_ORDER = exports.CODEX_MODEL_ROUTING_RECEIPTS_KEY = void 0;
exports.resolveCodexDeployment = resolveCodexDeployment;
exports.validateCodexModelRoutingReceipt = validateCodexModelRoutingReceipt;
exports.validateCodexModelRoutingReceipts = validateCodexModelRoutingReceipts;
exports.validateCodexModelRoutingGate = validateCodexModelRoutingGate;
exports.validateCodexModelRoutingState = validateCodexModelRoutingState;
exports.CODEX_MODEL_ROUTING_RECEIPTS_KEY = "codex_model_routing_receipts";
exports.BAND_ORDER = ["C1", "C2", "C3", "C4"];
const VALID_EXECUTION_CONTEXTS = new Set([
    "standalone",
    "epic_preparation_child",
    "epic_execution_child",
    "parallel_planning",
    "parallel_execution",
]);
const EPIC_EXECUTION_CONTEXTS = new Set([
    "epic_preparation_child",
    "epic_execution_child",
]);
const GENERATED_AGENT_FAMILIES = new Set([
    "orchestrator",
    "atomic-planner",
    "atomic-executor",
    "feature-reviewer",
    "task-researcher",
    "prd-feature",
    "pr-author",
    "python-typed-engineer",
    "powershell-typed-engineer",
    "csharp-typed-engineer",
    "typescript-engineer",
    "commit-steward",
]);
exports.LOGICAL_AGENT_ALIASES = {
    "feature-review": "feature-reviewer",
};
const BASE_PROFILES = {
    C1: {
        suffix: "c1",
        model: "gpt-5.6-luna",
        model_reasoning_effort: "low",
    },
    C2: {
        suffix: "c2",
        model: "gpt-5.6-terra",
        model_reasoning_effort: "medium",
    },
    C3: {
        suffix: "c3",
        model: "gpt-5.6-terra",
        model_reasoning_effort: "high",
    },
    C4: {
        suffix: "c4",
        model: "gpt-5.6-sol",
        model_reasoning_effort: "max",
    },
};
const C3_ELEVATED_PROFILE = {
    suffix: "c3-elevated",
    model: "gpt-5.6-sol",
    model_reasoning_effort: "high",
};
const FORCED_PERSONA_PROFILE = {
    suffix: "",
    model: "gpt-5.6-sol",
    model_reasoning_effort: "ultra",
};
const FORCED_PERSONA_PROFILES = {
    "epic-planner": FORCED_PERSONA_PROFILE,
    "epic-orchestrator": FORCED_PERSONA_PROFILE,
    "parallel-planner": FORCED_PERSONA_PROFILE,
    "parallel-orchestrator": FORCED_PERSONA_PROFILE,
};
exports.PARALLEL_ROOT_CONTEXT_PERSONAS = {
    parallel_planning: "parallel-planner",
    parallel_execution: "parallel-orchestrator",
};
const ROUTING_KEYS = [
    "complexity_band",
    "execution_context",
    "orchestration_complexity_ceiling",
    "c3_overlay_applied",
    "c3_overlay_reason",
    "model",
    "model_reasoning_effort",
];
const REQUIRED_KEYS = [
    "logical_agent",
    "deployment_agent",
    "phase",
    ...ROUTING_KEYS,
];
const RESOLVED_KEYS = [
    "logical_agent",
    "deployment_agent",
    ...ROUTING_KEYS,
];
class ModelUnavailableError extends Error {
    constructor(message) {
        super(message);
        this.name = "ModelUnavailableError";
    }
}
exports.ModelUnavailableError = ModelUnavailableError;
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
    if (typeof value === "number") {
        return String(value);
    }
    if (Array.isArray(value)) {
        return `[${value.map(pythonRepr).join(", ")}]`;
    }
    if (isObject(value)) {
        return `{${Object.entries(value)
            .map(([key, item]) => `${pythonRepr(key)}: ${pythonRepr(item)}`)
            .join(", ")}}`;
    }
    return String(value);
}
function pythonStr(value) {
    return typeof value === "string" ? value : pythonRepr(value);
}
function validateBand(value, fieldName) {
    if (!exports.BAND_ORDER.includes(value)) {
        throw new Error(`${fieldName} must be one of ('C1', 'C2', 'C3', 'C4'), ` +
            `found ${pythonRepr(value)}.`);
    }
    return value;
}
function validateContext(value) {
    if (!VALID_EXECUTION_CONTEXTS.has(value)) {
        throw new Error("execution_context must be one of " +
            "('epic_execution_child', 'epic_preparation_child', 'standalone'), " +
            `found ${pythonRepr(value)}.`);
    }
    return value;
}
function selectC3OverlayReason(executionContext, orchestrationComplexityCeiling) {
    const epicContext = EPIC_EXECUTION_CONTEXTS.has(executionContext);
    const c4Ceiling = orchestrationComplexityCeiling === "C4";
    if (epicContext && c4Ceiling) {
        return "epic_context_and_c4_ceiling";
    }
    return epicContext
        ? "epic_context"
        : c4Ceiling
            ? "c4_orchestration_ceiling"
            : null;
}
function resolveCodexDeployment(logicalAgent, complexityBand, executionContext, orchestrationComplexityCeiling, availableModels) {
    const band = validateBand(complexityBand, "complexity_band");
    const ceiling = validateBand(orchestrationComplexityCeiling, "orchestration_complexity_ceiling");
    const context = validateContext(executionContext);
    if (exports.BAND_ORDER.indexOf(band) > exports.BAND_ORDER.indexOf(ceiling)) {
        throw new Error("orchestration_complexity_ceiling must be greater than or equal to " +
            `complexity_band, found ${ceiling} below ${band}.`);
    }
    const parallelPersona = exports.PARALLEL_ROOT_CONTEXT_PERSONAS[context];
    if (parallelPersona !== undefined && logicalAgent !== parallelPersona) {
        throw new Error(`Parallel context ${pythonRepr(context)} requires its forced root ` +
            `persona ${pythonRepr(parallelPersona)}.`);
    }
    const parallelContext = Object.entries(exports.PARALLEL_ROOT_CONTEXT_PERSONAS).find(([, persona]) => persona === logicalAgent)?.[0];
    if (parallelContext !== undefined && context !== parallelContext) {
        throw new Error(`Parallel persona ${pythonRepr(logicalAgent)} requires ` +
            `${pythonRepr(parallelContext)} context.`);
    }
    const forcedProfile = FORCED_PERSONA_PROFILES[logicalAgent];
    let profile;
    let deploymentAgent;
    let overlayReason;
    if (forcedProfile !== undefined) {
        profile = forcedProfile;
        deploymentAgent = logicalAgent;
        overlayReason = null;
    }
    else {
        const deploymentFamily = exports.LOGICAL_AGENT_ALIASES[logicalAgent] ?? logicalAgent;
        if (!GENERATED_AGENT_FAMILIES.has(deploymentFamily)) {
            throw new Error(`Unsupported Codex logical agent: ${pythonRepr(logicalAgent)}.`);
        }
        overlayReason =
            band === "C3" ? selectC3OverlayReason(context, ceiling) : null;
        profile =
            overlayReason === null ? BASE_PROFILES[band] : C3_ELEVATED_PROFILE;
        deploymentAgent = `${deploymentFamily}-${profile.suffix}`;
    }
    if (availableModels !== undefined && !availableModels.has(profile.model)) {
        throw new ModelUnavailableError("model_unavailable: required Codex model " +
            `${pythonRepr(profile.model)} is unavailable; silent fallback is prohibited.`);
    }
    return {
        logical_agent: logicalAgent,
        deployment_agent: deploymentAgent,
        complexity_band: band,
        execution_context: context,
        orchestration_complexity_ceiling: ceiling,
        c3_overlay_applied: overlayReason !== null,
        c3_overlay_reason: overlayReason,
        model: profile.model,
        model_reasoning_effort: profile.model_reasoning_effort,
    };
}
function validateReceipt(value, prefix, previousCeiling) {
    if (!isObject(value)) {
        return { errors: [`${prefix} must be an object.`] };
    }
    const missing = REQUIRED_KEYS.filter((key) => !(key in value));
    if (missing.length > 0) {
        return {
            errors: [`${prefix} missing required keys: ${missing.join(", ")}.`],
        };
    }
    const errors = [];
    const phase = value["phase"];
    if (typeof phase !== "string" || phase.trim() === "") {
        errors.push(`${prefix}.phase must be a non-empty string.`);
    }
    let expected;
    try {
        expected = resolveCodexDeployment(pythonStr(value["logical_agent"]), pythonStr(value["complexity_band"]), pythonStr(value["execution_context"]), pythonStr(value["orchestration_complexity_ceiling"]));
    }
    catch (error) {
        const message = error instanceof Error ? error.message : String(error);
        errors.push(`${prefix} has invalid routing inputs: ${message}`);
        return { errors };
    }
    const currentCeiling = expected.orchestration_complexity_ceiling;
    if (previousCeiling !== undefined &&
        exports.BAND_ORDER.indexOf(currentCeiling) < exports.BAND_ORDER.indexOf(previousCeiling)) {
        errors.push(`${prefix}.orchestration_complexity_ceiling must be monotonic; ` +
            `found ${currentCeiling} after ${previousCeiling}.`);
    }
    else if (previousCeiling !== undefined) {
        const transition = value["ceiling_transition"];
        if (currentCeiling === previousCeiling) {
            if (transition !== undefined && transition !== null) {
                errors.push(`${prefix}.ceiling_transition must be absent unless the ceiling rises.`);
            }
        }
        else if (!isObject(transition)) {
            errors.push(`${prefix}.ceiling_transition must record a ceiling increase.`);
        }
        else {
            if (transition["from"] !== previousCeiling ||
                transition["to"] !== currentCeiling) {
                errors.push(`${prefix}.ceiling_transition must record ${previousCeiling} to ${currentCeiling}.`);
            }
            const affected = transition["affected_delegation_ids"];
            if (!Array.isArray(affected) ||
                affected.length === 0 ||
                affected.some((item) => typeof item !== "string" || item.trim() === "") ||
                new Set(affected).size !== affected.length) {
                errors.push(`${prefix}.ceiling_transition.affected_delegation_ids must be a ` +
                    "non-empty unique string list.");
            }
        }
    }
    else if (value["ceiling_transition"] !== undefined &&
        value["ceiling_transition"] !== null) {
        errors.push(`${prefix}.ceiling_transition must be absent unless the ceiling rises.`);
    }
    for (const key of RESOLVED_KEYS) {
        if (value[key] !== expected[key]) {
            errors.push(`${prefix}.${key} must be ${pythonRepr(expected[key])}, ` +
                `found ${pythonRepr(value[key])}.`);
        }
    }
    return { errors, resolvedCeiling: currentCeiling };
}
function validateCodexModelRoutingReceipt(value, prefix = `Checkpoint ${exports.CODEX_MODEL_ROUTING_RECEIPTS_KEY}[0]`) {
    return validateReceipt(value, prefix).errors;
}
function validateCodexModelRoutingReceipts(value) {
    if (!Array.isArray(value)) {
        return [
            `Checkpoint ${exports.CODEX_MODEL_ROUTING_RECEIPTS_KEY} must be a list when present.`,
        ];
    }
    const errors = [];
    let previousCeiling;
    value.forEach((item, index) => {
        const result = validateReceipt(item, `Checkpoint ${exports.CODEX_MODEL_ROUTING_RECEIPTS_KEY}[${index}]`, previousCeiling);
        errors.push(...result.errors);
        previousCeiling = result.resolvedCeiling ?? previousCeiling;
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
        if (typeof agentName === "string" && agentName.trim() !== "") {
            result.add(agentName);
        }
    }
    return result;
}
function validateCodexModelRoutingGate(state) {
    const delegated = delegatedAgentNames(state);
    if (delegated.size === 0) {
        return [];
    }
    const value = state[exports.CODEX_MODEL_ROUTING_RECEIPTS_KEY];
    const errors = validateCodexModelRoutingReceipts(value);
    if (!Array.isArray(value)) {
        return errors;
    }
    const logicalAgents = new Set();
    const deploymentAgents = new Set();
    for (const item of value) {
        if (!isObject(item)) {
            continue;
        }
        const logical = item["logical_agent"];
        const deployment = item["deployment_agent"];
        if (typeof logical === "string") {
            logicalAgents.add(logical);
        }
        if (typeof deployment === "string") {
            deploymentAgents.add(deployment);
        }
    }
    for (const agent of [...delegated].sort()) {
        if (!logicalAgents.has(agent) && !deploymentAgents.has(agent)) {
            errors.push(`Checkpoint ${exports.CODEX_MODEL_ROUTING_RECEIPTS_KEY} is missing a ` +
                `receipt for delegated agent: ${agent}.`);
        }
    }
    return errors;
}
function validateCodexModelRoutingState(state, requireGate = false) {
    const errors = [];
    if (exports.CODEX_MODEL_ROUTING_RECEIPTS_KEY in state) {
        errors.push(...validateCodexModelRoutingReceipts(state[exports.CODEX_MODEL_ROUTING_RECEIPTS_KEY]));
    }
    if (requireGate) {
        errors.push(...validateCodexModelRoutingGate(state));
    }
    return errors;
}
