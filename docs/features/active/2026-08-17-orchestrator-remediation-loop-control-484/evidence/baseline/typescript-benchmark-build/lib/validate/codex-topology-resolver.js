"use strict";
/** Resolve Codex implementation topology from deterministic scope inputs. */
Object.defineProperty(exports, "__esModule", { value: true });
exports.LANGUAGE_BUDGETS = exports.ESCALATION_PRECEDENCE = exports.ORCHESTRATOR_LOGICAL_AGENT = exports.PARALLEL_ROOT_CONTEXT_PERSONAS = exports.FORCED_ROOT_PERSONAS = exports.EPIC_CHILD_CONTEXTS = exports.VALID_EXECUTION_CONTEXTS = void 0;
exports.resolveCodexTopology = resolveCodexTopology;
exports.VALID_EXECUTION_CONTEXTS = new Set([
    "standalone",
    "epic_preparation_child",
    "epic_execution_child",
    "parallel_planning",
    "parallel_execution",
]);
exports.EPIC_CHILD_CONTEXTS = new Set([
    "epic_preparation_child",
    "epic_execution_child",
]);
exports.FORCED_ROOT_PERSONAS = new Set([
    "epic-planner",
    "epic-orchestrator",
    "parallel-planner",
    "parallel-orchestrator",
]);
exports.PARALLEL_ROOT_CONTEXT_PERSONAS = {
    parallel_planning: "parallel-planner",
    parallel_execution: "parallel-orchestrator",
};
exports.ORCHESTRATOR_LOGICAL_AGENT = "orchestrator";
exports.ESCALATION_PRECEDENCE = [
    "epic_child_context",
    "invalid_estimate",
    "cross_language",
    "unsupported_language",
    "cross_cutting",
    "direct_mode_disabled",
    "production_budget_exceeded",
];
exports.LANGUAGE_BUDGETS = {
    python: {
        direct_mode_enabled: true,
        max_production_files: 3,
        max_test_files: 3,
        logical_agent: "python-typed-engineer",
    },
    powershell: {
        direct_mode_enabled: true,
        max_production_files: 2,
        max_test_files: 3,
        logical_agent: "powershell-typed-engineer",
    },
    csharp: {
        direct_mode_enabled: true,
        max_production_files: 3,
        max_test_files: 3,
        logical_agent: "csharp-typed-engineer",
    },
    typescript: {
        direct_mode_enabled: false,
        max_production_files: 0,
        max_test_files: 0,
        logical_agent: "typescript-engineer",
    },
};
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
    return String(value);
}
function validateContext(value) {
    if (typeof value !== "string" || !exports.VALID_EXECUTION_CONTEXTS.has(value)) {
        throw new Error("execution_context must be one of " +
            "('epic_execution_child', 'epic_preparation_child', 'standalone'), " +
            `found ${pythonRepr(value)}.`);
    }
    return value;
}
function normalizeLanguages(value) {
    if (!Array.isArray(value) ||
        value.some((language) => typeof language !== "string" || language.trim() === "")) {
        throw new Error("languages must contain non-empty strings.");
    }
    const normalized = new Set(value.map((language) => language.trim().toLowerCase()));
    return [...normalized].sort();
}
function requireInteger(value, fieldName) {
    if (typeof value !== "number" || !Number.isInteger(value)) {
        throw new Error(`${fieldName} must be an integer.`);
    }
    return value;
}
function requireBoolean(value) {
    if (typeof value !== "boolean") {
        throw new Error("cross_cutting must be a boolean.");
    }
    return value;
}
function orchestratorReceipt(context, languages, productionFileCount, testFileCount, crossCutting, reason, budget) {
    return {
        execution_context: context,
        languages,
        production_file_count: productionFileCount,
        test_file_count: testFileCount,
        cross_cutting: crossCutting,
        root_persona: null,
        route: "large",
        topology: "orchestrator",
        logical_agent: exports.ORCHESTRATOR_LOGICAL_AGENT,
        routing_reason: reason,
        max_production_files: budget?.max_production_files ?? null,
        max_test_files: budget?.max_test_files ?? null,
    };
}
/** Resolve the initial implementation topology independently from model choice. */
function resolveCodexTopology(languagesValue, productionFileCountValue, testFileCountValue, executionContextValue, options = {}) {
    const context = validateContext(executionContextValue);
    const languages = normalizeLanguages(languagesValue);
    const productionFileCount = requireInteger(productionFileCountValue, "production_file_count");
    const testFileCount = requireInteger(testFileCountValue, "test_file_count");
    const crossCutting = requireBoolean(options.crossCutting === undefined ? false : options.crossCutting);
    const rootPersona = options.rootPersona ?? null;
    const parallelPersona = exports.PARALLEL_ROOT_CONTEXT_PERSONAS[context];
    if (parallelPersona !== undefined) {
        if (rootPersona !== parallelPersona) {
            throw new Error(`Parallel context ${pythonRepr(context)} requires its forced root ` +
                `persona ${pythonRepr(parallelPersona)}.`);
        }
        return {
            execution_context: context,
            languages,
            production_file_count: productionFileCount,
            test_file_count: testFileCount,
            cross_cutting: crossCutting,
            root_persona: parallelPersona,
            route: "parallel",
            topology: "parallel_persona",
            logical_agent: parallelPersona,
            routing_reason: "forced_root_persona",
            max_production_files: null,
            max_test_files: null,
        };
    }
    if (rootPersona !== null) {
        if (typeof rootPersona !== "string" ||
            !exports.FORCED_ROOT_PERSONAS.has(rootPersona)) {
            throw new Error(`Unsupported Codex root persona: ${pythonRepr(rootPersona)}.`);
        }
        const parallelContext = Object.entries(exports.PARALLEL_ROOT_CONTEXT_PERSONAS).find(([, persona]) => persona === rootPersona)?.[0];
        if (parallelContext !== undefined) {
            throw new Error(`Parallel persona ${pythonRepr(rootPersona)} requires ` +
                `${pythonRepr(parallelContext)} context.`);
        }
        if (context !== "standalone") {
            throw new Error("A forced root persona requires standalone context.");
        }
        const persona = rootPersona;
        return {
            execution_context: context,
            languages,
            production_file_count: productionFileCount,
            test_file_count: testFileCount,
            cross_cutting: crossCutting,
            root_persona: persona,
            route: "epic",
            topology: "epic_persona",
            logical_agent: persona,
            routing_reason: "forced_root_persona",
            max_production_files: null,
            max_test_files: null,
        };
    }
    const escalate = (reason, budget) => orchestratorReceipt(context, languages, productionFileCount, testFileCount, crossCutting, reason, budget);
    if (exports.EPIC_CHILD_CONTEXTS.has(context)) {
        return escalate("epic_child_context");
    }
    if (productionFileCount <= 0 || testFileCount < 0) {
        return escalate("invalid_estimate");
    }
    if (languages.length > 1) {
        return escalate("cross_language");
    }
    if (languages.length !== 1) {
        return escalate("unsupported_language");
    }
    const budget = exports.LANGUAGE_BUDGETS[languages[0] ?? ""];
    if (budget === undefined) {
        return escalate("unsupported_language");
    }
    if (crossCutting) {
        return escalate("cross_cutting", budget);
    }
    if (!budget.direct_mode_enabled) {
        return escalate("direct_mode_disabled", budget);
    }
    if (productionFileCount > budget.max_production_files) {
        return escalate("production_budget_exceeded", budget);
    }
    return {
        execution_context: context,
        languages,
        production_file_count: productionFileCount,
        test_file_count: testFileCount,
        cross_cutting: crossCutting,
        root_persona: null,
        route: "small",
        topology: "typed_engineer",
        logical_agent: budget.logical_agent,
        routing_reason: "within_language_budget",
        max_production_files: budget.max_production_files,
        max_test_files: budget.max_test_files,
    };
}
