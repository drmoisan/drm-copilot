"use strict";
/** Validate epic-planner checkpoints before prepared epic execution. */
Object.defineProperty(exports, "__esModule", { value: true });
exports.validateEpicPlannerStateText = validateEpicPlannerStateText;
const epic_orchestrator_state_resolution_1 = require("./epic-orchestrator-state-resolution");
const epic_orchestrator_state_launch_binding_1 = require("./epic-orchestrator-state-launch-binding");
const epic_wave_computation_1 = require("./epic-wave-computation");
const orchestrator_state_codex_model_routing_1 = require("./orchestrator-state-codex-model-routing");
const orchestrator_state_codex_topology_1 = require("./orchestrator-state-codex-topology");
const epic_planner_readiness_integrity_1 = require("./epic-planner-readiness-integrity");
const REQUIRED_KEYS = [
    "objective",
    "epic_feature_folder",
    "epic_manifest_path",
    "integration_branch",
    "max_parallel_features",
    "epic_worthiness",
    "features",
    "kickoff_prompt_path",
    "completed_steps",
    "next_step",
    "last_updated",
];
const REQUIRED_FEATURE_KEYS = [
    "issue_num",
    "feature_folder",
    "depends_on",
    "wave",
    "complexity_band",
    "preparation_status",
    "research_path",
    "plan_path",
    "preflight_status",
];
const COMPLEXITY_BANDS = new Set(["C1", "C2", "C3", "C4"]);
const COMPLEXITY_BAND_REPR = "('C1', 'C2', 'C3', 'C4')";
const READY_NEXT_STEP = "EPIC_EXECUTION_READY";
const NON_EPIC_NEXT_STEP = "NON_EPIC_RECOMMENDED";
/** Type guard for a plain object. */
function isObject(value) {
    return typeof value === "object" && value !== null && !Array.isArray(value);
}
function pythonRepr(value) {
    if (value === undefined || value === null) {
        return "None";
    }
    if (typeof value === "string") {
        return `'${value.replaceAll("\\", "\\\\").replaceAll("'", "\\'")}'`;
    }
    if (typeof value === "boolean") {
        return value ? "True" : "False";
    }
    if (Array.isArray(value)) {
        return `[${value.map(pythonRepr).join(", ")}]`;
    }
    return String(value);
}
function validateExpectedTopologyFields(value, prefix, expected) {
    const errors = (0, orchestrator_state_codex_topology_1.validateCodexTopologyReceipt)(value, prefix);
    if (!isObject(value)) {
        return errors;
    }
    for (const [key, expectedValue] of Object.entries(expected)) {
        if (value[key] !== expectedValue) {
            const expectedRepresentation = expectedValue === null ? "None" : `'${String(expectedValue)}'`;
            errors.push(`${prefix}.${key} must be ${expectedRepresentation}.`);
        }
    }
    return errors;
}
function validatePlannerTopologyReceipt(value) {
    return validateExpectedTopologyFields(value, "Epic planner topology_receipt", {
        execution_context: "standalone",
        root_persona: "epic-planner",
        route: "epic",
        topology: "epic_persona",
        logical_agent: "epic-planner",
    });
}
function validateChildTopologyReceipt(value, prefix) {
    return validateExpectedTopologyFields(value, prefix, {
        execution_context: "epic_preparation_child",
        root_persona: null,
        route: "large",
        topology: "orchestrator",
        logical_agent: "orchestrator",
    });
}
/** Validate the epic-worthiness verdict and rationale. */
function validateWorthiness(value) {
    if (!isObject(value)) {
        return {
            errors: ["Epic planner checkpoint epic_worthiness must be an object."],
            verdict: null,
        };
    }
    const errors = [];
    const verdict = value["verdict"];
    if (verdict !== "epic" && verdict !== "non_epic") {
        errors.push("Epic planner checkpoint epic_worthiness.verdict must be 'epic' or 'non_epic'.");
    }
    const rationale = value["rationale"];
    if (typeof rationale !== "string" || !rationale.trim()) {
        errors.push("Epic planner checkpoint epic_worthiness.rationale must be non-empty.");
    }
    return {
        errors,
        verdict: typeof verdict === "string" ? verdict : null,
    };
}
/** Validate baseline feature shape and return object entries. */
function extractFeatures(value) {
    if (!Array.isArray(value)) {
        return {
            errors: ["Epic planner checkpoint features must be a list."],
            features: [],
        };
    }
    const errors = [];
    const features = [];
    value.forEach((item, index) => {
        const prefix = `Epic planner checkpoint features[${index}]`;
        if (!isObject(item)) {
            errors.push(`${prefix} must be an object.`);
            return;
        }
        features.push(item);
        const missing = REQUIRED_FEATURE_KEYS.filter((key) => !(key in item));
        if (missing.length > 0) {
            errors.push(`${prefix} missing required keys: ${missing.join(", ")}.`);
            return;
        }
        if (!Array.isArray(item["depends_on"])) {
            errors.push(`${prefix}.depends_on must be a list.`);
        }
        const wave = item["wave"];
        if (typeof wave !== "number" || !Number.isInteger(wave) || wave < 0) {
            errors.push(`${prefix}.wave must be a non-negative integer.`);
        }
        const complexityBand = item["complexity_band"];
        if (typeof complexityBand !== "string" ||
            !COMPLEXITY_BANDS.has(complexityBand)) {
            errors.push(`${prefix}.complexity_band must be one of ${COMPLEXITY_BAND_REPR}.`);
        }
    });
    return { errors, features };
}
/** Require unique resolved dependencies and deterministic longest-path waves. */
function validateDependencyWaves(features) {
    const errors = [];
    const seenFolders = new Set();
    const seenIssues = new Set();
    features.forEach((feature, index) => {
        const prefix = `Epic planner checkpoint features[${index}]`;
        const folder = feature["feature_folder"];
        if (typeof folder === "string" && folder.length > 0) {
            if (seenFolders.has(folder)) {
                errors.push(`${prefix}.feature_folder must be unique: ${pythonRepr(folder)}.`);
            }
            seenFolders.add(folder);
        }
        const issueNum = feature["issue_num"];
        if (issueNum !== undefined && issueNum !== null) {
            if (seenIssues.has(issueNum)) {
                errors.push(`${prefix}.issue_num must be unique: ${pythonRepr(issueNum)}.`);
            }
            seenIssues.add(issueNum);
        }
    });
    const index = (0, epic_orchestrator_state_resolution_1.buildFeatureReferenceIndex)(features);
    const manifest = new Map();
    features.forEach((feature, featureIndex) => {
        const folder = feature["feature_folder"];
        const dependencies = feature["depends_on"];
        if (typeof folder !== "string" ||
            folder.length === 0 ||
            !Array.isArray(dependencies)) {
            return;
        }
        const resolvedEdges = [];
        for (const dependency of dependencies) {
            const resolved = (0, epic_orchestrator_state_resolution_1.resolveFeatureReference)(dependency, index);
            if (resolved === null) {
                errors.push(`Epic planner checkpoint features[${featureIndex}].depends_on ` +
                    `contains unresolved reference: ${pythonRepr(dependency)}.`);
            }
            else {
                resolvedEdges.push(resolved);
            }
        }
        manifest.set(folder, resolvedEdges);
    });
    let expectedWaves;
    try {
        expectedWaves = (0, epic_wave_computation_1.computeWaveNumbers)(manifest);
    }
    catch (error) {
        if (error instanceof epic_wave_computation_1.EpicWaveCycleError) {
            errors.push(error.message);
            return errors;
        }
        throw error;
    }
    features.forEach((feature, index) => {
        const folder = feature["feature_folder"];
        if (typeof folder !== "string" || !expectedWaves.has(folder)) {
            return;
        }
        const expected = expectedWaves.get(folder);
        if (feature["wave"] !== expected) {
            errors.push(`Epic planner checkpoint features[${index}].wave must be ${expected} ` +
                `from the dependency graph, found ${pythonRepr(feature["wave"])}.`);
        }
    });
    return errors;
}
/** Require every child to be fully prepared and preflight-cleared. */
function validateReadyFeatures(features) {
    const errors = [];
    if (features.length < 2) {
        errors.push("Execution-ready epic planning requires at least two features.");
    }
    features.forEach((feature, index) => {
        const prefix = `Epic planner checkpoint features[${index}]`;
        const issueNum = feature["issue_num"];
        if (typeof issueNum !== "number" ||
            !Number.isInteger(issueNum) ||
            issueNum <= 0) {
            errors.push(`${prefix}.issue_num must be a positive integer.`);
        }
        for (const key of [
            "feature_folder",
            "research_path",
            "plan_path",
        ]) {
            const value = feature[key];
            if (typeof value !== "string" || !value.trim()) {
                errors.push(`${prefix}.${key} must be a non-empty string.`);
            }
        }
        if (feature["preparation_status"] !== "prepared") {
            errors.push(`${prefix}.preparation_status must be 'prepared'.`);
        }
        if (feature["preflight_status"] !== "PREFLIGHT: ALL CLEAR") {
            errors.push(`${prefix}.preflight_status must be 'PREFLIGHT: ALL CLEAR'.`);
        }
        const receipt = feature["model_routing_receipt"];
        errors.push(...(0, orchestrator_state_codex_model_routing_1.validateCodexModelRoutingReceipt)(receipt, `${prefix}.model_routing_receipt`));
        if (isObject(receipt) && receipt["logical_agent"] !== "orchestrator") {
            errors.push(`${prefix}.model_routing_receipt.logical_agent must be 'orchestrator'.`);
        }
        if (isObject(receipt)) {
            if (receipt["complexity_band"] !== feature["complexity_band"]) {
                errors.push(`${prefix}.model_routing_receipt.complexity_band must match ` +
                    `feature complexity_band ${pythonRepr(feature["complexity_band"])}.`);
            }
            if (receipt["execution_context"] !== "epic_preparation_child") {
                errors.push(`${prefix}.model_routing_receipt.execution_context must be ` +
                    "'epic_preparation_child'.");
            }
        }
        errors.push(...validateChildTopologyReceipt(feature["topology_receipt"], `${prefix}.topology_receipt`));
    });
    return errors;
}
/**
 * Validate planner checkpoint structure and optional execution readiness.
 *
 * @param text Raw planner checkpoint JSON text.
 * @param options Optional execution-readiness gate.
 * @returns Validation errors, or an empty array for a valid checkpoint.
 */
function validateEpicPlannerStateText(text, options = {}) {
    let value;
    try {
        value = JSON.parse(text);
    }
    catch (error) {
        return [
            `Epic planner checkpoint is not valid JSON: ${error instanceof Error ? error.message : String(error)}`,
        ];
    }
    if (!isObject(value)) {
        return ["Epic planner checkpoint root must be a JSON object."];
    }
    const errors = REQUIRED_KEYS.filter((key) => !(key in value)).map((key) => `Epic planner checkpoint missing required key: ${key}`);
    const worthiness = validateWorthiness(value["epic_worthiness"]);
    errors.push(...worthiness.errors);
    const featureResult = extractFeatures(value["features"]);
    errors.push(...featureResult.errors);
    errors.push(...validateDependencyWaves(featureResult.features));
    const maxParallel = value["max_parallel_features"];
    if (typeof maxParallel !== "number" ||
        !Number.isInteger(maxParallel) ||
        maxParallel < 1 ||
        maxParallel > 8) {
        errors.push("Epic planner checkpoint max_parallel_features must be an integer " +
            "from 1 through 8.");
    }
    if (worthiness.verdict === "non_epic" &&
        value["next_step"] !== NON_EPIC_NEXT_STEP) {
        errors.push(`Non-epic planner checkpoint next_step must be '${NON_EPIC_NEXT_STEP}'.`);
    }
    if (options.requireReadyForExecution === true) {
        if (worthiness.verdict !== "epic") {
            errors.push("Execution readiness requires epic_worthiness.verdict 'epic'.");
        }
        if (value["next_step"] !== READY_NEXT_STEP) {
            errors.push(`Execution-ready planner checkpoint next_step must be '${READY_NEXT_STEP}'.`);
        }
        errors.push(...validateReadyFeatures(featureResult.features));
        errors.push(...(0, epic_orchestrator_state_launch_binding_1.validateEpicPlannerChildLaunchBindings)(featureResult.features));
        errors.push(...validatePlannerTopologyReceipt(value["topology_receipt"]));
        const expectedKickoff = `artifacts/orchestration/epic-kickoff-${String(value["epic_feature_folder"])}.md`;
        if (value["kickoff_prompt_path"] !== expectedKickoff) {
            errors.push("Execution-ready planner checkpoint kickoff_prompt_path must be " +
                `'${expectedKickoff}'.`);
        }
        if (options.readinessContext === undefined) {
            errors.push("Execution-ready planner validation requires repository context.");
        }
        else {
            errors.push(...(0, epic_planner_readiness_integrity_1.validateEpicReadinessIntegrity)(value, text, options.readinessContext));
        }
    }
    return errors;
}
