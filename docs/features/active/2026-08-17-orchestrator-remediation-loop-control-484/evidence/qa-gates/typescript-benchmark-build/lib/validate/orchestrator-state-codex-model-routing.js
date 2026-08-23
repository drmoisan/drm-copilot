"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.ModelUnavailableError = exports.PARALLEL_ROOT_CONTEXT_PERSONAS = exports.LOGICAL_AGENT_ALIASES = exports.BAND_ORDER = exports.CODEX_MODEL_ROUTING_RECEIPTS_KEY = void 0;
exports.resolveCodexDeployment = resolveCodexDeployment;
exports.validateCodexModelRoutingReceipt = validateCodexModelRoutingReceipt;
exports.validateCodexModelRoutingReceipts = validateCodexModelRoutingReceipts;
exports.validateCodexModelRoutingGate = validateCodexModelRoutingGate;
exports.validateCodexModelRoutingState = validateCodexModelRoutingState;
exports.CODEX_MODEL_ROUTING_RECEIPTS_KEY = "codex_model_routing_receipts";
const CODEX_MODEL_ROUTING_GATE_ERROR = "ORCH_ROUTING_GATE_CODEX_MODEL";
exports.BAND_ORDER = ["C1", "C2", "C3", "C4"];
function deploymentProfile(suffix, model, modelReasoningEffort) {
    return { suffix, model, model_reasoning_effort: modelReasoningEffort };
}
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
    C1: deploymentProfile("c1", "gpt-5.6-luna", "low"),
    C2: deploymentProfile("c2", "gpt-5.6-terra", "medium"),
    C3: deploymentProfile("c3", "gpt-5.6-terra", "high"),
    C4: deploymentProfile("c4", "gpt-5.6-sol", "max"),
};
const C3_ELEVATED_PROFILE = deploymentProfile("c3-elevated", "gpt-5.6-sol", "high");
const FORCED_PERSONA_PROFILE = deploymentProfile("", "gpt-5.6-sol", "ultra");
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
function receiptPrefix(index, fixedPrefix) {
    return (fixedPrefix ?? `Checkpoint ${exports.CODEX_MODEL_ROUTING_RECEIPTS_KEY}[${index}]`);
}
function validateReceiptSequence(values, fixedPrefix) {
    const errors = [];
    const successfulResolutions = [];
    let previousCeiling;
    for (let index = 0; index < values.length; index += 1) {
        const value = values[index];
        if (!isObject(value)) {
            errors.push(`${receiptPrefix(index, fixedPrefix)} must be an object.`);
            continue;
        }
        let hasMissingKey = false;
        for (const key of REQUIRED_KEYS) {
            if (!(key in value)) {
                hasMissingKey = true;
                break;
            }
        }
        if (hasMissingKey) {
            const missing = REQUIRED_KEYS.filter((key) => !(key in value));
            errors.push(`${receiptPrefix(index, fixedPrefix)} missing required keys: ` +
                `${missing.join(", ")}.`);
            continue;
        }
        const phase = value["phase"];
        if (typeof phase !== "string" || phase.trim() === "") {
            errors.push(`${receiptPrefix(index, fixedPrefix)}.phase must be a non-empty string.`);
        }
        const logicalAgent = pythonStr(value["logical_agent"]);
        const complexityBand = pythonStr(value["complexity_band"]);
        const executionContext = pythonStr(value["execution_context"]);
        const orchestrationComplexityCeiling = pythonStr(value["orchestration_complexity_ceiling"]);
        let expected;
        for (let offset = 0; offset < successfulResolutions.length; offset += 1) {
            const entry = successfulResolutions[offset === 0 ? successfulResolutions.length - 1 : offset - 1];
            if (entry !== undefined &&
                entry.logicalAgent === logicalAgent &&
                entry.complexityBand === complexityBand &&
                entry.executionContext === executionContext &&
                entry.orchestrationComplexityCeiling === orchestrationComplexityCeiling) {
                expected = entry.resolution;
                break;
            }
        }
        if (expected === undefined) {
            try {
                expected = resolveCodexDeployment(logicalAgent, complexityBand, executionContext, orchestrationComplexityCeiling);
                successfulResolutions.push({
                    logicalAgent,
                    complexityBand,
                    executionContext,
                    orchestrationComplexityCeiling,
                    resolution: expected,
                });
            }
            catch (error) {
                const message = error instanceof Error ? error.message : String(error);
                errors.push(`${receiptPrefix(index, fixedPrefix)} has invalid routing inputs: ${message}`);
                continue;
            }
        }
        const currentCeiling = expected.orchestration_complexity_ceiling;
        const transition = value["ceiling_transition"];
        if (previousCeiling === undefined) {
            if (transition !== undefined && transition !== null) {
                errors.push(`${receiptPrefix(index, fixedPrefix)}.ceiling_transition must be ` +
                    "absent unless the ceiling rises.");
            }
        }
        else if (exports.BAND_ORDER.indexOf(currentCeiling) < exports.BAND_ORDER.indexOf(previousCeiling)) {
            errors.push(`${receiptPrefix(index, fixedPrefix)}.orchestration_complexity_ceiling ` +
                `must be monotonic; found ${currentCeiling} after ${previousCeiling}.`);
        }
        else if (currentCeiling === previousCeiling) {
            if (transition !== undefined && transition !== null) {
                errors.push(`${receiptPrefix(index, fixedPrefix)}.ceiling_transition must be ` +
                    "absent unless the ceiling rises.");
            }
        }
        else if (!isObject(transition)) {
            errors.push(`${receiptPrefix(index, fixedPrefix)}.ceiling_transition must record ` +
                "a ceiling increase.");
        }
        else {
            if (transition["from"] !== previousCeiling ||
                transition["to"] !== currentCeiling) {
                errors.push(`${receiptPrefix(index, fixedPrefix)}.ceiling_transition must ` +
                    `record ${previousCeiling} to ${currentCeiling}.`);
            }
            const affected = transition["affected_delegation_ids"];
            if (!Array.isArray(affected) ||
                affected.length === 0 ||
                affected.some((item) => typeof item !== "string" || item.trim() === "") ||
                new Set(affected).size !== affected.length) {
                errors.push(`${receiptPrefix(index, fixedPrefix)}.ceiling_transition.` +
                    "affected_delegation_ids must be a non-empty unique string list.");
            }
        }
        for (const key of RESOLVED_KEYS) {
            if (value[key] !== expected[key]) {
                errors.push(`${receiptPrefix(index, fixedPrefix)}.${key} must be ` +
                    `${pythonRepr(expected[key])}, found ${pythonRepr(value[key])}.`);
            }
        }
        previousCeiling = currentCeiling;
    }
    return errors;
}
function validateCodexModelRoutingReceipt(value, prefix = `Checkpoint ${exports.CODEX_MODEL_ROUTING_RECEIPTS_KEY}[0]`) {
    return validateReceiptSequence([value], prefix);
}
function validateCodexModelRoutingReceipts(value) {
    if (!Array.isArray(value)) {
        return [
            `Checkpoint ${exports.CODEX_MODEL_ROUTING_RECEIPTS_KEY} must be a list when present.`,
        ];
    }
    return validateReceiptSequence(value);
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
    if (requireGate) {
        return validateCodexModelRoutingGate(state).map((error) => `${CODEX_MODEL_ROUTING_GATE_ERROR}: ${error}`);
    }
    if (exports.CODEX_MODEL_ROUTING_RECEIPTS_KEY in state) {
        return validateCodexModelRoutingReceipts(state[exports.CODEX_MODEL_ROUTING_RECEIPTS_KEY]);
    }
    return [];
}
