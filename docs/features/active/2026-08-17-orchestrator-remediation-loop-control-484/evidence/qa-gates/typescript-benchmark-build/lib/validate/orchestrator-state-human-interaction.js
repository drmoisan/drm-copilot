"use strict";
/**
 * Human-interaction invariants for orchestrator-state checkpoints.
 *
 * Purpose:
 *     Port `scripts/dev_tools/_orchestrator_state_human_interaction.py`. Apply
 *     the optional `human_interaction` block invariants documented in
 *     `.claude/rules/orchestrator-state.md` without importing any schema file.
 *
 * Invariants / Constraints:
 *     - The three permitted `response` values are `scope_change`, `exception`,
 *       and `halt`.
 *     - An `exception` response requires a non-empty `runbook_path` string.
 *     - Error-message strings are identical to the Python source.
 *
 * Side Effects:
 *     None.
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.HUMAN_INTERACTION_EXCEPTION_RESPONSE = exports.HUMAN_INTERACTION_RESPONSE_ENUM = exports.HUMAN_INTERACTION_REQUIREMENTS_KEY = exports.HUMAN_INTERACTION_KEY = void 0;
exports.validateHumanInteraction = validateHumanInteraction;
/** Top-level checkpoint key for the optional human-interaction block. */
exports.HUMAN_INTERACTION_KEY = "human_interaction";
/** Key holding the requirements list inside the human-interaction block. */
exports.HUMAN_INTERACTION_REQUIREMENTS_KEY = "requirements";
/** The three permitted responses for an unautomatable requirement. */
exports.HUMAN_INTERACTION_RESPONSE_ENUM = new Set([
    "scope_change",
    "exception",
    "halt",
]);
/** The response value that requires a runbook path. */
exports.HUMAN_INTERACTION_EXCEPTION_RESPONSE = "exception";
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
 * Render a value the way Python's f-string `str()` would for error parity.
 *
 * Mirrors how the Python source interpolates the raw `response` value: `None`
 * for an absent value, `True`/`False` for booleans, and the literal text for
 * strings and numbers.
 *
 * @param value Raw value to render.
 * @returns The Python-equivalent string representation.
 */
function pythonRepr(value) {
    if (value === null || value === undefined) {
        return "None";
    }
    if (value === true) {
        return "True";
    }
    if (value === false) {
        return "False";
    }
    return String(value);
}
/**
 * Validate the optional `human_interaction` block invariants.
 *
 * Purpose:
 *     Mirror Python `_validate_human_interaction`. Callers invoke this only when
 *     the `human_interaction` key is present, so a non-object value is itself a
 *     malformed block.
 *
 * @param humanInteraction Raw value of the checkpoint's `human_interaction` key.
 * @returns One error string per violated invariant; empty when well-formed.
 */
function validateHumanInteraction(humanInteraction) {
    const errors = [];
    // A non-object human_interaction cannot carry a requirements list; the key
    // was present, so this is a malformed block rather than an absent one.
    if (!isObject(humanInteraction)) {
        errors.push("Checkpoint human_interaction must be an object when present.");
        return errors;
    }
    // Invariant 1: requirements must be present and a list.
    const requirements = humanInteraction[exports.HUMAN_INTERACTION_REQUIREMENTS_KEY];
    if (!Array.isArray(requirements)) {
        errors.push("Checkpoint human_interaction.requirements must be a list.");
        return errors;
    }
    // Validate each requirement independently so callers receive a complete error
    // list instead of stopping at the first malformed requirement.
    requirements.forEach((requirement, index) => {
        if (!isObject(requirement)) {
            errors.push(`Checkpoint human_interaction.requirements #${index} must be an object.`);
            return;
        }
        // Invariant 2: response must be within the permitted enum.
        const response = requirement["response"];
        if (typeof response !== "string" ||
            !exports.HUMAN_INTERACTION_RESPONSE_ENUM.has(response)) {
            errors.push(`Checkpoint human_interaction.requirements #${index} response ` +
                "must be one of scope_change, exception, halt; got: " +
                pythonRepr(response));
            return;
        }
        // Invariant 3: an exception response requires a non-empty runbook_path.
        if (response === exports.HUMAN_INTERACTION_EXCEPTION_RESPONSE) {
            const runbookPath = requirement["runbook_path"];
            if (typeof runbookPath !== "string" || runbookPath.trim() === "") {
                errors.push(`Checkpoint human_interaction.requirements #${index} ` +
                    "response is exception but runbook_path is missing or empty.");
            }
        }
    });
    return errors;
}
