"use strict";
/**
 * Additive, key-gated resolution helpers for the epic-orchestrator validator port.
 *
 * Purpose:
 *     TypeScript port of `scripts/dev_tools/_epic_orchestrator_state_resolution.py`.
 *     Holds the issue_num-keyed dependency resolution and the presence-gated
 *     intent-block validation consumed by `epic-orchestrator-state-core.ts`.
 *     Extracting these keeps the core validator within the repository 500-line
 *     file-size limit.
 *
 * Invariants / Constraints:
 *     - Every helper is additive and key-gated: on the legacy folder-basename-keyed,
 *       intent-free checkpoint shape the results are byte-identical to the
 *       pre-change validator.
 *     - Error-message strings are identical to the Python source.
 *     - Pure; no filesystem or network I/O and no input mutation.
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.buildFeatureReferenceIndex = buildFeatureReferenceIndex;
exports.resolveFeatureReference = resolveFeatureReference;
exports.detectDependencyCycle = detectDependencyCycle;
exports.validateIntentBlock = validateIntentBlock;
// Lifecycle path prefixes a feature_folder hint may carry. Stripping the prefix
// yields the stable basename used as the canonical resolution key, which lets a
// dependency expressed with either lifecycle location resolve to the same feature.
const LIFECYCLE_PREFIXES = [
    "docs/features/active/",
    "docs/features/completed/",
    "active/",
    "completed/",
];
const VALID_EPIC_TYPES = new Set(["business", "enabler"]);
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
 * Format a value the way Python `repr` does, for byte-identical error strings.
 *
 * Mirrors the Python `{value!r}` conversion for the value types that appear in
 * intent errors: `null`/`undefined` render as `None`, booleans as `True`/`False`,
 * strings in single quotes (with backslash/quote escaping), and everything else
 * via its string form.
 *
 * @param value Value to format.
 * @returns The Python-repr-equivalent string.
 */
function pythonRepr(value) {
    if (value === null || value === undefined) {
        return "None";
    }
    if (typeof value === "boolean") {
        return value ? "True" : "False";
    }
    if (typeof value === "string") {
        return `'${value.replace(/\\/g, "\\\\").replace(/'/g, "\\'")}'`;
    }
    return String(value);
}
/**
 * Return the stable basename of a feature_folder hint.
 *
 * Strips a leading active/ or completed/ lifecycle path prefix so a hint that
 * points into either lifecycle location resolves to the same basename. A value
 * with no known prefix is returned unchanged (the legacy bare-basename shape).
 *
 * @param value A feature_folder value or depends_on reference string.
 * @returns The basename with any lifecycle prefix removed.
 */
function normalizeFolderHint(value) {
    // Check each known lifecycle prefix in order; the first match is stripped.
    for (const prefix of LIFECYCLE_PREFIXES) {
        if (value.startsWith(prefix)) {
            return value.slice(prefix.length);
        }
    }
    return value;
}
/**
 * Build the union index used to resolve depends_on references.
 *
 * Produces two lookup maps over the defined features (one keyed by normalized
 * feature_folder basename, one keyed by `issue_num`), each mapping to the raw
 * feature_folder value. Building both is what makes the resolver a union index: a
 * reference resolves whether it is a folder-basename hint or an `issue_num`.
 *
 * @param features Object-shaped `features[]` entries.
 * @returns The `{ byFolderHint, byIssueNum }` union index.
 */
function buildFeatureReferenceIndex(features) {
    const byFolderHint = new Map();
    const byIssueNum = new Map();
    // Index every defined feature by both its normalized folder basename and its
    // issue_num so a dependency expressed either way resolves to the same feature.
    for (const feature of features) {
        const folder = feature["feature_folder"];
        if (typeof folder === "string" && folder) {
            byFolderHint.set(normalizeFolderHint(folder), folder);
            const issueNum = feature["issue_num"];
            if (issueNum !== undefined && issueNum !== null) {
                byIssueNum.set(issueNum, folder);
            }
        }
    }
    return { byFolderHint, byIssueNum };
}
/**
 * Resolve one depends_on reference to its canonical feature_folder.
 *
 * Detects whether the reference is an `issue_num` (non-string) or a
 * feature_folder basename (string, with an optional active/ or completed/ prefix)
 * and resolves it against the union index. Returns the raw feature_folder the
 * reference points to, or null when it resolves to no defined feature. On the
 * legacy shape a bare folder-basename string returns itself, keeping callers
 * byte-identical.
 *
 * @param dependency A single depends_on entry (issue_num or folder hint).
 * @param index The union index from {@link buildFeatureReferenceIndex}.
 * @returns The canonical feature_folder, or null when unresolved.
 */
function resolveFeatureReference(dependency, index) {
    // A non-string reference is an issue_num lookup; a string is a folder hint
    // resolved after stripping any lifecycle prefix.
    if (typeof dependency !== "string") {
        return index.byIssueNum.get(dependency) ?? null;
    }
    return index.byFolderHint.get(normalizeFolderHint(dependency)) ?? null;
}
/**
 * Detect a cycle in the depends_on dependency graph via DFS.
 *
 * Resolves every depends_on reference to its canonical feature_folder through the
 * union index so the graph is keyed uniformly whether dependencies are issue_num
 * references or folder-basename hints. On the legacy shape each folder string
 * resolves to itself, so the graph and any cycle it reveals are byte-identical.
 *
 * @param features Object-shaped `features[]` entries.
 * @returns An error string naming the cycle, or null when acyclic.
 */
function detectDependencyCycle(features) {
    const index = buildFeatureReferenceIndex(features);
    const graph = new Map();
    for (const feature of features) {
        const folder = feature["feature_folder"];
        if (typeof folder !== "string" || !folder) {
            continue;
        }
        const dependsOn = feature["depends_on"];
        if (!Array.isArray(dependsOn)) {
            graph.set(folder, []);
            continue;
        }
        // Keep only references that resolve to a defined feature; an unresolved
        // reference contributes no edge (as in the legacy code, where a non-graph-key
        // dependency was visited to a no-op).
        const resolvedEdges = [];
        for (const dependency of dependsOn) {
            const resolved = resolveFeatureReference(dependency, index);
            if (resolved !== null) {
                resolvedEdges.push(resolved);
            }
        }
        graph.set(folder, resolvedEdges);
    }
    const visiting = new Set();
    const visited = new Set();
    /**
     * Return a node on a cycle reachable from `node`, else null.
     *
     * @param node Current graph node.
     * @returns A node participating in a cycle, or null.
     */
    function visit(node) {
        if (visiting.has(node)) {
            return node;
        }
        if (visited.has(node) || !graph.has(node)) {
            return null;
        }
        visiting.add(node);
        // Depth-first traversal of this node's dependencies; a revisit of a node
        // still on the current path (in `visiting`) indicates a cycle.
        for (const dependency of graph.get(node) ?? []) {
            const cycleNode = visit(dependency);
            if (cycleNode !== null) {
                return cycleNode;
            }
        }
        visiting.delete(node);
        visited.add(node);
        return null;
    }
    // Start a DFS from every node so disconnected subgraphs are all covered.
    for (const start of graph.keys()) {
        const cycleNode = visit(start);
        if (cycleNode !== null) {
            return `Epic checkpoint depends_on graph contains a cycle involving feature_folder: ${cycleNode}`;
        }
    }
    return null;
}
/**
 * Validate the optional intent block, only when it is present.
 *
 * Presence-gated: when the checkpoint has no top-level `intent` key this returns
 * an empty array and the validator output is byte-identical to before. When
 * present, enforces: (1) intent is an object; (2) `epic_type` present and in
 * {business, enabler}; (3) `business_outcome_hypothesis` is a non-empty string;
 * (4) `leading_indicators` / `nfrs`, when present, are lists of strings. Error
 * strings are identical to the Python validator.
 *
 * @param state Parsed checkpoint JSON object.
 * @returns One error per violated intent invariant; empty when absent/valid.
 */
function validateIntentBlock(state) {
    // Key-gate: an absent intent block leaves output byte-identical to before.
    if (!("intent" in state)) {
        return [];
    }
    const intent = state["intent"];
    if (!isObject(intent)) {
        return ["Epic checkpoint intent must be an object."];
    }
    const errors = [];
    // epic_type is required-when-block-present and enum-constrained.
    const epicType = intent["epic_type"];
    if (typeof epicType !== "string" || !VALID_EPIC_TYPES.has(epicType)) {
        errors.push(`Epic checkpoint intent.epic_type must be 'business' or 'enabler', found: ${pythonRepr(epicType)}`);
    }
    // business_outcome_hypothesis is required-when-block-present and must carry
    // real content, not whitespace.
    const hypothesis = intent["business_outcome_hypothesis"];
    if (typeof hypothesis !== "string" || !hypothesis.trim()) {
        errors.push("Epic checkpoint intent.business_outcome_hypothesis must be a non-empty string.");
    }
    // leading_indicators and nfrs are optional even within the block, but when
    // present each must be a list whose every element is a string.
    for (const fieldName of ["leading_indicators", "nfrs"]) {
        if (!(fieldName in intent)) {
            continue;
        }
        const value = intent[fieldName];
        if (!Array.isArray(value) ||
            !value.every((item) => typeof item === "string")) {
            errors.push(`Epic checkpoint intent.${fieldName} must be a list of strings.`);
        }
    }
    return errors;
}
