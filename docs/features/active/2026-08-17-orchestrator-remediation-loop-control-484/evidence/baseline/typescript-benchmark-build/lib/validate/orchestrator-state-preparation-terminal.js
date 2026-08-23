"use strict";
/** Validate the exact terminal checkpoint contract for epic preparation. */
Object.defineProperty(exports, "__esModule", { value: true });
exports.OUT_OF_SCOPE_STEP_KEYS = exports.EXPECTED_NEXT_STEP = void 0;
exports.validatePreparationTerminalContract = validatePreparationTerminalContract;
/** Next lifecycle step required after preparation reaches preflight clearance. */
exports.EXPECTED_NEXT_STEP = "S5_atomic_execution";
/** Execution-through-CI statuses that remain out of scope during preparation. */
exports.OUT_OF_SCOPE_STEP_KEYS = [
    "step5_status",
    "step6_status",
    "step7_status",
    "step8_status",
    "step9_status",
    "step10_status",
];
/**
 * Format a JSON-compatible value like Python repr for parity error messages.
 *
 * @param value Checkpoint value included in a terminal-contract error.
 * @returns A Python-style representation of the value.
 */
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
    if (typeof value === "object") {
        const entries = Object.entries(value).map(([key, item]) => `${pythonRepr(key)}: ${pythonRepr(item)}`);
        return `{${entries.join(", ")}}`;
    }
    return String(value);
}
/**
 * Require planning-only terminal values when the selected route is preparation.
 *
 * @param state Checkpoint state object.
 * @returns Terminal-contract errors, or an empty list for other routes.
 */
function validatePreparationTerminalContract(state) {
    const routeId = state["route_id"] !== undefined
        ? state["route_id"]
        : state["path_selected"];
    if (routeId !== "preparation") {
        return [];
    }
    const errors = [];
    if (state["next_step"] !== exports.EXPECTED_NEXT_STEP) {
        errors.push("Preparation checkpoint next_step must be " +
            `${pythonRepr(exports.EXPECTED_NEXT_STEP)}, found ${pythonRepr(state["next_step"])}.`);
    }
    for (const key of exports.OUT_OF_SCOPE_STEP_KEYS) {
        if (state[key] !== "not-applicable") {
            errors.push(`Preparation checkpoint ${key} must be 'not-applicable', ` +
                `found ${pythonRepr(state[key])}.`);
        }
    }
    return errors;
}
