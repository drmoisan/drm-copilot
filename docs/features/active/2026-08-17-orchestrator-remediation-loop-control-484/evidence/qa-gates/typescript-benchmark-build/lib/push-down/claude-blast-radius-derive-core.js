"use strict";
/**
 * Pure derivation core for the destination blast-radius module map.
 *
 * Purpose:
 *     Turn a deterministic, already-collected list of destination directory
 *     observations plus the bundled source document into the serialized
 *     `config/blast-radius.json` a destination workspace should receive. The
 *     bundled map describes drm-copilot's own layout, so publishing it verbatim
 *     gives an unrelated destination a module map that names none of its
 *     modules. Deriving the map from the destination's own layout is what makes
 *     the published document meaningful there.
 *
 * Responsibilities:
 *     Own steps 2 through 8 of the derivation algorithm: classify project
 *     directories, prune ancestors, name and glob them, apply the top-level
 *     fallback and the no-signal floor, assemble and serialize the document, and
 *     guard against re-emitting the location-bucket defect this item fixes.
 *     Collecting the observations (step 1, the destination scan) belongs to
 *     `claude-blast-radius-derive.ts`, which performs the I/O.
 *
 * Invariants / Constraints:
 *     - This module performs no I/O: no `fs`, no `child_process`, no network,
 *       and no clock or randomness access. Every function is pure and mutates no
 *       input.
 *     - Identical observations and identical source text produce a
 *       byte-identical output string.
 *     - The root directory is categorically excluded from classification. A
 *       root-level manifest would otherwise yield the universal glob `**`, which
 *       is the defect class being fixed.
 *     - The guard is unconditional: no emitted glob may be `**`, `docs/**`, or
 *       `tests/**`, so the derivation can never recreate a location bucket.
 *
 * Side effects:
 *     None.
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.BlastRadiusGuardError = exports.BlastRadiusDeriveError = exports.FORBIDDEN_GLOBS = exports.PAYLOAD_MODULES = exports.SCAN_DEPTH_LIMIT = exports.EXCLUDED_DIR_NAMES = exports.MANIFEST_SUFFIXES = exports.MANIFEST_FILENAMES = exports.BLAST_RADIUS_RELATIVE_PATH = void 0;
exports.isExcludedDirectoryName = isExcludedDirectoryName;
exports.isManifestFileName = isManifestFileName;
exports.deriveDestinationModuleMap = deriveDestinationModuleMap;
/** Destination-relative path of the document this core derives. */
exports.BLAST_RADIUS_RELATIVE_PATH = "config/blast-radius.json";
/** Exact file names whose presence marks a directory as a project directory. */
exports.MANIFEST_FILENAMES = new Set([
    "build.gradle",
    "build.gradle.kts",
    "Cargo.toml",
    "go.mod",
    "package.json",
    "pom.xml",
    "pyproject.toml",
    "setup.py",
]);
/** File-name suffixes whose presence marks a directory as a project directory. */
exports.MANIFEST_SUFFIXES = [
    ".csproj",
    ".fsproj",
    ".vbproj",
    ".sln",
    ".slnx",
];
/**
 * Directory names the destination scan never descends into.
 *
 * These are build output, dependency caches, and location buckets. A location
 * bucket admitted as a module would attach to nearly every work item and
 * re-create the contention defect this item fixes, so `doc`, `docs`, `test`, and
 * `tests` are pruned here rather than filtered later. Names beginning with `.`
 * are excluded as well; that rule is a predicate rather than a member of this
 * set, so it lives in {@link isExcludedDirectoryName}.
 */
exports.EXCLUDED_DIR_NAMES = new Set([
    "__pycache__",
    "artifacts",
    "bin",
    "build",
    "coverage",
    "dist",
    "doc",
    "docs",
    "node_modules",
    "obj",
    "out",
    "target",
    "test",
    "tests",
    "venv",
]);
/**
 * Maximum scan depth: the destination top level plus two nested levels.
 *
 * The bound exists so the scan never performs an unpruned recursive walk of a
 * destination workspace, which would traverse dependency and history trees.
 */
exports.SCAN_DEPTH_LIMIT = 3;
/**
 * Modules the push-down itself creates in the destination.
 *
 * The push-down publishes a `.claude` tree and a `config` tree, so those two
 * modules are always correct for a destination that received the push
 * regardless of what the scan observed. They win on a name collision with a
 * derived module because they describe the payload, not a guess.
 */
exports.PAYLOAD_MODULES = {
    "claude-runtime": [".claude/**"],
    config: ["config/**"],
};
/** Globs the derivation may never emit, in the order the guard reports them. */
exports.FORBIDDEN_GLOBS = [
    "**",
    "docs/**",
    "tests/**",
];
/**
 * Top-level keys carried verbatim from the bundled source document.
 *
 * The assembly literal indexes this array positionally, so a new key is
 * APPENDED rather than inserted: inserting mid-array would shift every existing
 * index. `mandate_reads` (issue #489) is optional in the source document, and
 * `JSON.stringify` drops an `undefined`-valued property, so an absent source key
 * emits no property without a conditional spread.
 */
const CARRIED_KEYS = [
    "version",
    "shared_surfaces",
    "shared_surface_globs",
    "over_breadth_fraction",
    "mandate_reads",
];
/**
 * Error raised when the bundled source document cannot be parsed.
 *
 * Purpose:
 *     Distinguish an unparseable bundled document from any other failure so the
 *     run summary can name the offending path and the publisher can leave the
 *     destination bytes untouched. Follows the `RoutingMergeError` precedent in
 *     `claude-routing-merge.ts`.
 */
class BlastRadiusDeriveError extends Error {
    /** Destination-relative path of the document that failed to parse. */
    path;
    /**
     * @param path Path named in the message.
     * @param detail Parser detail appended to the message.
     */
    constructor(path, detail) {
        super(`Bundled blast-radius document is not valid JSON and was not written: ` +
            `${path} (${detail})`);
        this.name = "BlastRadiusDeriveError";
        this.path = path;
    }
}
exports.BlastRadiusDeriveError = BlastRadiusDeriveError;
/**
 * Error raised when the derivation would emit a forbidden glob.
 *
 * Purpose:
 *     Make the in-code assertion that the derivation can never recreate the
 *     universal-glob or location-bucket defect observable and testable. The
 *     guard throws before any output is produced, so no destination write can
 *     follow a trip.
 */
class BlastRadiusGuardError extends Error {
    /** The forbidden glob that tripped the guard. */
    glob;
    /** Name of the module that would have carried the forbidden glob. */
    moduleName;
    /**
     * @param moduleName Module the forbidden glob was assigned to.
     * @param glob The forbidden glob.
     */
    constructor(moduleName, glob) {
        super(`Derived blast-radius module ${moduleName} would emit the forbidden ` +
            `glob ${glob}; the derivation was aborted before writing.`);
        this.name = "BlastRadiusGuardError";
        this.glob = glob;
        this.moduleName = moduleName;
    }
}
exports.BlastRadiusGuardError = BlastRadiusGuardError;
/**
 * Compare two strings ordinally.
 *
 * Ordinal comparison is used rather than locale collation so the emitted order
 * is identical on every host, which is what makes the output byte-stable.
 *
 * @param left First string.
 * @param right Second string.
 * @returns Negative, zero, or positive per the standard comparator contract.
 */
function compareOrdinal(left, right) {
    return left < right ? -1 : left > right ? 1 : 0;
}
/**
 * Report whether a directory name is excluded from the destination scan.
 *
 * @param name A single directory name, not a path.
 * @returns True when the name is a pruned bucket or begins with a dot.
 */
function isExcludedDirectoryName(name) {
    return name.startsWith(".") || exports.EXCLUDED_DIR_NAMES.has(name);
}
/**
 * Report whether a file name marks its directory as a project directory.
 *
 * @param fileName A single file name, not a path.
 * @returns True when the name is an exact manifest name or carries a manifest
 *   suffix.
 */
function isManifestFileName(fileName) {
    if (exports.MANIFEST_FILENAMES.has(fileName)) {
        return true;
    }
    // Suffix matching covers the .NET project and solution families, whose file
    // names vary with the project name and so cannot be listed exactly.
    return exports.MANIFEST_SUFFIXES.some((suffix) => fileName.endsWith(suffix));
}
/**
 * Select the observations that are project directories (algorithm step 2).
 *
 * @param observations Every visited directory, including the root.
 * @returns Destination-relative paths of the project directories, ordinally
 *   sorted.
 */
function classifyProjectDirectories(observations) {
    const projectPaths = [];
    // The root is skipped categorically: a root-level manifest would name the
    // whole destination and yield the universal glob `**`, the defect being fixed.
    for (const observation of observations) {
        if (observation.relativePath === "") {
            continue;
        }
        if (observation.fileNames.some(isManifestFileName)) {
            projectPaths.push(observation.relativePath);
        }
    }
    return projectPaths.sort(compareOrdinal);
}
/**
 * Drop every path that is a proper ancestor of another path (step 3).
 *
 * Leaf granularity maximizes concurrency. An umbrella module covering sibling
 * projects would make every sibling contend with every other, which is the same
 * coupling the removed `docs` bucket produced.
 *
 * @param paths Candidate project-directory paths.
 * @returns The subset that has no descendant in the input, order preserved.
 */
function pruneAncestors(paths) {
    // A path is an ancestor of another exactly when that other path starts with
    // it followed by a separator; the separator anchor keeps a sibling whose name
    // merely shares a character prefix from being treated as a descendant.
    return paths.filter((candidate) => !paths.some((other) => other !== candidate && other.startsWith(`${candidate}/`)));
}
/**
 * Select the non-excluded top-level directories (algorithm step 5 fallback).
 *
 * @param observations Every visited directory, including the root.
 * @returns Top-level directory names, ordinally sorted. Excluded names are
 *   absent because the scanner never observes them.
 */
function topLevelDirectories(observations) {
    const names = [];
    // A top-level directory is an observation one segment deep; the root itself
    // has an empty relative path and is skipped.
    for (const observation of observations) {
        const relativePath = observation.relativePath;
        if (relativePath !== "" && !relativePath.includes("/")) {
            names.push(relativePath);
        }
    }
    return names.sort(compareOrdinal);
}
/**
 * Build the module map from derived paths and the payload modules (step 7).
 *
 * @param derivedPaths Destination-relative paths that became modules.
 * @returns The module map, module names ordinally sorted, payload modules
 *   winning on a name collision.
 */
function assembleModules(derivedPaths) {
    const combined = new Map();
    // Derived modules are inserted first so a payload module of the same name
    // overwrites them; the payload describes what was actually published, while a
    // derived entry of the same name is an inference about the destination.
    for (const path of derivedPaths) {
        combined.set(path, [`${path}/**`]);
    }
    for (const [name, globs] of Object.entries(exports.PAYLOAD_MODULES)) {
        combined.set(name, [...globs]);
    }
    const modules = {};
    // Insertion order determines the serialized key order, so the names are
    // sorted before insertion rather than after.
    for (const name of [...combined.keys()].sort(compareOrdinal)) {
        const globs = combined.get(name);
        if (globs !== undefined) {
            modules[name] = globs;
        }
    }
    return modules;
}
/**
 * Reject a module map that carries a forbidden glob (algorithm step 8).
 *
 * @param modules The assembled module map.
 * @throws BlastRadiusGuardError When any glob is `**`, `docs/**`, or `tests/**`.
 */
function assertNoForbiddenGlob(modules) {
    // Checking the assembled map rather than each derivation step means the guard
    // covers the payload modules and any future contributor to the map as well.
    for (const [name, globs] of Object.entries(modules)) {
        for (const glob of globs) {
            if (exports.FORBIDDEN_GLOBS.includes(glob)) {
                throw new BlastRadiusGuardError(name, glob);
            }
        }
    }
}
/**
 * Parse the bundled source document into a JSON object.
 *
 * @param text Raw bundled document text.
 * @returns The parsed object.
 * @throws BlastRadiusDeriveError When the text is unparseable or not an object.
 */
function parseSourceDocument(text) {
    let parsed;
    try {
        parsed = JSON.parse(text);
    }
    catch (error) {
        const detail = error instanceof Error ? error.message : String(error);
        throw new BlastRadiusDeriveError(exports.BLAST_RADIUS_RELATIVE_PATH, detail);
    }
    if (parsed === null || typeof parsed !== "object" || Array.isArray(parsed)) {
        throw new BlastRadiusDeriveError(exports.BLAST_RADIUS_RELATIVE_PATH, "document root is not a JSON object");
    }
    return parsed;
}
/**
 * Derive the destination blast-radius document from a destination scan.
 *
 * Executes algorithm steps 2 through 8: classify project directories, prune
 * ancestors, name and glob them, fall back to the top-level directories when no
 * project directory was found, floor to the payload modules when the fallback is
 * empty too, assemble the document, guard it, and serialize.
 *
 * @param observations Deterministic list of visited destination directories,
 *   including the destination root. Supplying an empty list is valid and yields
 *   the no-signal floor.
 * @param sourceDocumentText Text of the bundled `config/blast-radius.json`.
 * @returns The serialized destination document: 2-space indented with a
 *   trailing newline, keys in the order `version`, `shared_surfaces`,
 *   `shared_surface_globs`, `mandate_reads`, `modules`,
 *   `over_breadth_fraction`. `mandate_reads` is omitted entirely when the
 *   bundled source document does not declare it.
 * @throws BlastRadiusDeriveError When the bundled document is not parseable.
 * @throws BlastRadiusGuardError When an emitted glob is forbidden. The guard
 *   runs before the return, so a trip produces no output at all.
 */
function deriveDestinationModuleMap(observations, sourceDocumentText) {
    const source = parseSourceDocument(sourceDocumentText);
    // Project directories are the primary signal. When the destination declares
    // none, its top-level directories are the next-best structural signal, and
    // when it has neither the payload modules alone are the computed outcome for
    // a structureless destination.
    const projectPaths = pruneAncestors(classifyProjectDirectories(observations));
    const derivedPaths = projectPaths.length > 0 ? projectPaths : topLevelDirectories(observations);
    const modules = assembleModules(derivedPaths);
    assertNoForbiddenGlob(modules);
    // The literal's property order is the serialized key order, so the fixed
    // emission order is expressed here rather than by a separate sort.
    const document = {
        version: source[CARRIED_KEYS[0]],
        shared_surfaces: source[CARRIED_KEYS[1]],
        shared_surface_globs: source[CARRIED_KEYS[2]],
        mandate_reads: source[CARRIED_KEYS[4]],
        modules,
        over_breadth_fraction: source[CARRIED_KEYS[3]],
    };
    return `${JSON.stringify(document, null, 2)}\n`;
}
