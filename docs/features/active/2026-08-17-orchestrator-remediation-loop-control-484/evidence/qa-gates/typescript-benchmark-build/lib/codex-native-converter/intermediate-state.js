"use strict";
/**
 * Write compiler-like intermediate state artifacts for the converter pipeline.
 *
 * Purpose:
 *     Expose the parsed and classified intermediate state as machine-readable
 *     JSON files in the artifact root. Ported from `intermediate_state.py`;
 *     writes flow through the injected {@link FileSystem}.
 *
 * Invariants:
 *     All JSON output uses sorted keys and 2-space indentation so successive
 *     calls with the same state produce byte-identical output, matching the
 *     Python `json.dumps(..., indent=2, sort_keys=True)` usage.
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.writeIntermediateStateArtifacts = writeIntermediateStateArtifacts;
const models_1 = require("./models");
/**
 * Recursively sort object keys so serialization matches Python `sort_keys=True`.
 *
 * @param value Value to normalize for deterministic serialization.
 * @returns A structurally equivalent value with all object keys sorted.
 */
function sortKeysDeep(value) {
    if (Array.isArray(value)) {
        return value.map((item) => sortKeysDeep(item));
    }
    if (value !== null && typeof value === "object") {
        const sorted = {};
        // Sort keys lexicographically to mirror Python json.dumps sort_keys.
        for (const key of Object.keys(value).sort((left, right) => (left < right ? -1 : left > right ? 1 : 0))) {
            sorted[key] = sortKeysDeep(value[key]);
        }
        return sorted;
    }
    return value;
}
/**
 * Serialize a JSON-safe payload with sorted keys and 2-space indentation.
 *
 * @param payload JSON-safe value to serialize.
 * @returns The deterministic JSON string (no trailing newline).
 */
function dumpsSorted(payload) {
    return JSON.stringify(sortKeysDeep(payload), null, 2);
}
/**
 * Join the artifact root and a child path segment using POSIX separators.
 *
 * @param root POSIX artifact root.
 * @param child Child path segment.
 * @returns The combined POSIX path.
 */
function joinPosix(root, child) {
    const normalizedRoot = root.replace(/\/+$/, "");
    return normalizedRoot === "" ? child : `${normalizedRoot}/${child}`;
}
/**
 * Write the four intermediate state JSON files under the artifact root.
 *
 * Mirrors `write_intermediate_state_artifacts`: creates
 * `<artifactRoot>/intermediate/` and writes `source-artifacts.json`,
 * `section-intents.json`, `planned-emissions.json`, and
 * `translation-traces.json` with sorted keys and 2-space indentation.
 *
 * @param fileSystem Injected filesystem.
 * @param state Populated intermediate state.
 * @param artifactRoot POSIX artifact root directory.
 * @returns The four written file paths in order: source-artifacts,
 *   section-intents, planned-emissions, translation-traces.
 */
function writeIntermediateStateArtifacts(fileSystem, state, artifactRoot) {
    const intermediateDir = joinPosix(artifactRoot, "intermediate");
    fileSystem.ensureDir(intermediateDir);
    const sourceArtifactsPath = joinPosix(intermediateDir, "source-artifacts.json");
    fileSystem.writeTextFile(sourceArtifactsPath, dumpsSorted(state.sourceArtifacts.map((artifact) => (0, models_1.sourceArtifactToJson)(artifact))));
    const sectionIntentsPath = joinPosix(intermediateDir, "section-intents.json");
    fileSystem.writeTextFile(sectionIntentsPath, dumpsSorted(state.sectionIntents.map((intent) => (0, models_1.sectionIntentToJson)(intent))));
    const plannedEmissionsPath = joinPosix(intermediateDir, "planned-emissions.json");
    fileSystem.writeTextFile(plannedEmissionsPath, dumpsSorted(state.plannedEmissions.map((emission) => (0, models_1.plannedEmissionToJson)(emission))));
    const translationTracesPath = joinPosix(intermediateDir, "translation-traces.json");
    fileSystem.writeTextFile(translationTracesPath, dumpsSorted(state.translationTraces.map((trace) => (0, models_1.translationTraceToJson)(trace))));
    return [
        sourceArtifactsPath,
        sectionIntentsPath,
        plannedEmissionsPath,
        translationTracesPath,
    ];
}
