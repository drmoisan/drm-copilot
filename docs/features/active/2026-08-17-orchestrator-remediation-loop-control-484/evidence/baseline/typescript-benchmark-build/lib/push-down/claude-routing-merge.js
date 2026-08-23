"use strict";
/**
 * Destination-aware routing-merge decorator for the Claude push-down.
 *
 * Purpose:
 *     Special-case the single destination-relative path
 *     `config/orchestration-routing.json` so publishing it into a workspace that
 *     already carries its own routing document adds the source's routes without
 *     discarding the destination's. Every other path passes straight through to
 *     the wrapped adapter.
 *
 * Why a decorator rather than engine logic:
 *     The merge is Claude-specific and path-specific. Putting it in the shared
 *     `copilot-customizations-engine` would apply it to the Copilot and Codex
 *     entry points, which publish no `config/` tree and must stay unchanged, and
 *     putting it in `rewriteReferences` would be wrong because that hook sees
 *     only the source text and never the destination's current content.
 *
 * Merge rule (pinned for idempotency):
 *     - Destination file absent: write the source text unchanged.
 *     - Destination present: start from the destination document; preserve
 *       destination key order for keys the destination already has; the source
 *       `parallel` route overwrites or is inserted; source routes the
 *       destination lacks and source top-level non-`routes` blocks the
 *       destination lacks are appended in source order.
 *     - Serialization is 2-space indentation with a trailing newline, so pushing
 *       twice is byte-stable.
 *     - An unparseable destination document fails that one file with an explicit
 *       error and its bytes are never written.
 *
 * Side effects:
 *     Reads the destination file and delegates all I/O to the wrapped adapter.
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.AdditiveRoutingMergeFileSystem = exports.RoutingMergeFileSystem = exports.RoutingMergeConflictError = exports.RoutingMergeError = void 0;
exports.mergeAdditiveRoutingDocuments = mergeAdditiveRoutingDocuments;
exports.mergeRoutingDocuments = mergeRoutingDocuments;
/** Top-level key holding the route table. */
const ROUTES_KEY = "routes";
/** Route name whose source definition always wins over the destination's. */
const AUTHORITATIVE_ROUTE = "parallel";
/**
 * Error raised when a destination routing document cannot be parsed.
 *
 * Purpose:
 *     Distinguish an unparseable destination file from any other write failure
 *     so the run summary can name the offending path and the publisher can
 *     leave its bytes untouched.
 */
class RoutingMergeError extends Error {
    /** Destination path whose current content could not be parsed. */
    path;
    /**
     * @param path Destination path that failed to parse.
     * @param detail Parser detail appended to the message.
     */
    constructor(path, detail) {
        super(`Destination routing document is not valid JSON and was not written: ` +
            `${path} (${detail})`);
        this.name = "RoutingMergeError";
        this.path = path;
    }
}
exports.RoutingMergeError = RoutingMergeError;
/** Stable reason emitted for substantive destination-owned collisions. */
const ROUTING_MERGE_CONFLICT_REASON = "ROUTING_MERGE_SUBSTANTIVE_COLLISION";
/** Error raised when an additive merge would replace destination-owned data. */
class RoutingMergeConflictError extends Error {
    /** Stable machine-readable reason code. */
    reasonCode = ROUTING_MERGE_CONFLICT_REASON;
    /** Destination path whose values conflict. */
    path;
    /** Conflicting keys in deterministic ascending order. */
    conflicts;
    constructor(path, conflicts) {
        const orderedConflicts = [...conflicts].sort();
        super(`${ROUTING_MERGE_CONFLICT_REASON}: ${path}: ${orderedConflicts.join(", ")}`);
        this.name = "RoutingMergeConflictError";
        this.path = path;
        this.conflicts = orderedConflicts;
    }
}
exports.RoutingMergeConflictError = RoutingMergeConflictError;
/**
 * Normalize a path to forward-slash separators with no trailing slash.
 *
 * @param value Path that may use OS-specific separators.
 * @returns Forward-slash POSIX path without a trailing separator.
 */
function normalizePosix(value) {
    return value.replace(/\\/g, "/").replace(/\/+$/, "");
}
/**
 * Return the POSIX path relative to a root, or null when not under the root.
 *
 * @param path Candidate child POSIX path.
 * @param root Candidate parent POSIX path.
 * @returns The relative POSIX path, or `null` when not under the root.
 */
function relativeToPosix(path, root) {
    const normalizedPath = normalizePosix(path);
    const normalizedRoot = normalizePosix(root);
    if (normalizedPath === normalizedRoot) {
        return "";
    }
    const prefix = `${normalizedRoot}/`;
    return normalizedPath.startsWith(prefix)
        ? normalizedPath.slice(prefix.length)
        : null;
}
/**
 * Parse text into a JSON object, or throw a {@link RoutingMergeError}.
 *
 * @param text Raw document text.
 * @param path Path reported in the error message.
 * @returns The parsed object.
 * @throws RoutingMergeError When the text is not parseable or not an object.
 */
function parseRoutingObject(text, path) {
    let parsed;
    try {
        parsed = JSON.parse(text);
    }
    catch (error) {
        const detail = error instanceof Error ? error.message : String(error);
        throw new RoutingMergeError(path, detail);
    }
    if (parsed === null || typeof parsed !== "object" || Array.isArray(parsed)) {
        throw new RoutingMergeError(path, "document root is not a JSON object");
    }
    return parsed;
}
/**
 * Return a value as a JSON object when it is one, otherwise null.
 *
 * @param value Candidate value read from a parsed document.
 * @returns The value narrowed to an object, or `null`.
 */
function asObject(value) {
    if (value === undefined || value === null || typeof value !== "object") {
        return null;
    }
    return Array.isArray(value) ? null : value;
}
/** Compare JSON values structurally without relying on object key order. */
function jsonValuesEqual(left, right) {
    if (left === right) {
        return true;
    }
    if (Array.isArray(left) || Array.isArray(right)) {
        return (Array.isArray(left) &&
            Array.isArray(right) &&
            left.length === right.length &&
            left.every((value, index) => jsonValuesEqual(value, right[index])));
    }
    const leftObject = asObject(left);
    const rightObject = asObject(right);
    if (leftObject === null || rightObject === null) {
        return false;
    }
    const leftKeys = Object.keys(leftObject).sort();
    const rightKeys = Object.keys(rightObject).sort();
    return (leftKeys.length === rightKeys.length &&
        leftKeys.every((key, index) => key === rightKeys[index] &&
            jsonValuesEqual(leftObject[key], rightObject[key])));
}
/** Read a key known to originate from `Object.keys` or `Object.entries`. */
function requiredJsonValue(object, key) {
    const value = object[key];
    if (value === undefined) {
        throw new Error(`Parsed routing document is missing key: ${key}`);
    }
    return value;
}
/** Return substantive shared-key conflicts in deterministic order. */
function findAdditiveConflicts(destination, source) {
    const conflicts = [];
    for (const key of Object.keys(destination)) {
        if (key !== ROUTES_KEY &&
            key in source &&
            !jsonValuesEqual(destination[key], source[key])) {
            conflicts.push(key);
        }
    }
    if (ROUTES_KEY in destination && ROUTES_KEY in source) {
        const destinationRoutes = asObject(destination[ROUTES_KEY]);
        const sourceRoutes = asObject(source[ROUTES_KEY]);
        if (destinationRoutes === null || sourceRoutes === null) {
            if (!jsonValuesEqual(destination[ROUTES_KEY], source[ROUTES_KEY])) {
                conflicts.push(ROUTES_KEY);
            }
        }
        else {
            for (const routeName of Object.keys(destinationRoutes)) {
                if (routeName in sourceRoutes &&
                    !jsonValuesEqual(destinationRoutes[routeName], sourceRoutes[routeName])) {
                    conflicts.push(`${ROUTES_KEY}.${routeName}`);
                }
            }
        }
    }
    return conflicts.sort();
}
/**
 * Add missing source entries without replacing destination-owned routing data.
 *
 * Existing equal entries retain the destination's exact bytes when no
 * additions are required. New route and top-level keys are appended in
 * ascending order.
 */
function mergeAdditiveRoutingDocuments(destinationText, sourceText, path) {
    const destination = parseRoutingObject(destinationText, path);
    const source = parseRoutingObject(sourceText, path);
    const conflicts = findAdditiveConflicts(destination, source);
    if (conflicts.length > 0) {
        throw new RoutingMergeConflictError(path, conflicts);
    }
    const merged = { ...destination };
    let changed = false;
    const destinationRoutes = asObject(destination[ROUTES_KEY]);
    const sourceRoutes = asObject(source[ROUTES_KEY]);
    if (sourceRoutes !== null) {
        if (destinationRoutes === null && !(ROUTES_KEY in destination)) {
            merged[ROUTES_KEY] = Object.fromEntries(Object.keys(sourceRoutes)
                .sort()
                .map((name) => [name, requiredJsonValue(sourceRoutes, name)]));
            changed = true;
        }
        else if (destinationRoutes !== null) {
            const missingRoutes = Object.keys(sourceRoutes)
                .filter((name) => !(name in destinationRoutes))
                .sort();
            if (missingRoutes.length > 0) {
                const mergedRoutes = { ...destinationRoutes };
                for (const name of missingRoutes) {
                    mergedRoutes[name] = requiredJsonValue(sourceRoutes, name);
                }
                merged[ROUTES_KEY] = mergedRoutes;
                changed = true;
            }
        }
    }
    for (const key of Object.keys(source)
        .filter((name) => name !== ROUTES_KEY && !(name in destination))
        .sort()) {
        merged[key] = requiredJsonValue(source, key);
        changed = true;
    }
    return changed ? `${JSON.stringify(merged, null, 2)}\n` : destinationText;
}
/**
 * Merge the source route table into the destination route table.
 *
 * Destination key order is preserved for routes the destination already
 * defines. The source `parallel` route overwrites the destination's; every
 * other destination route is kept verbatim. Source routes the destination lacks
 * are appended in source order.
 *
 * @param destinationRoutes The destination's `routes` block, or null when absent.
 * @param sourceRoutes The source's `routes` block, or null when absent.
 * @returns The merged route table.
 */
function mergeRoutes(destinationRoutes, sourceRoutes) {
    const merged = {};
    // Walk the destination first so its key order survives the merge; only the
    // authoritative route is replaced in place.
    if (destinationRoutes !== null) {
        for (const [name, definition] of Object.entries(destinationRoutes)) {
            const sourceDefinition = sourceRoutes?.[name];
            merged[name] =
                name === AUTHORITATIVE_ROUTE && sourceDefinition !== undefined
                    ? sourceDefinition
                    : definition;
        }
    }
    // Append the routes the destination does not define, in source order, so a
    // workspace that predates a route (for example `preparation`) receives it.
    if (sourceRoutes !== null) {
        for (const [name, definition] of Object.entries(sourceRoutes)) {
            if (!(name in merged)) {
                merged[name] = definition;
            }
        }
    }
    return merged;
}
/**
 * Merge a source routing document into a destination routing document.
 *
 * @param destinationText Current destination document text.
 * @param sourceText Source document text being published.
 * @param path Destination path reported in a parse error.
 * @returns The merged document text, 2-space indented with a trailing newline.
 * @throws RoutingMergeError When either document is not a JSON object.
 */
function mergeRoutingDocuments(destinationText, sourceText, path) {
    const destination = parseRoutingObject(destinationText, path);
    const source = parseRoutingObject(sourceText, path);
    const merged = {};
    // Preserve the destination's top-level key order for every key it already
    // carries, replacing only the route table.
    for (const [key, value] of Object.entries(destination)) {
        merged[key] =
            key === ROUTES_KEY
                ? mergeRoutes(asObject(value), asObject(source[ROUTES_KEY]))
                : value;
    }
    // Append the top-level blocks the destination lacks, in source order. The
    // route table is appended here when the destination had none at all.
    for (const [key, value] of Object.entries(source)) {
        if (key in merged) {
            continue;
        }
        merged[key] =
            key === ROUTES_KEY ? mergeRoutes(null, asObject(value)) : value;
    }
    return `${JSON.stringify(merged, null, 2)}\n`;
}
/**
 * Wrap a {@link PushDownFileSystem} so one path is merged instead of overwritten.
 *
 * Every method other than `writeTextFile` delegates unchanged. `writeTextFile`
 * merges only when the target resolves to the configured destination-relative
 * path and the destination file already exists.
 */
class RoutingMergeFileSystem {
    inner;
    destinationRoot;
    mergeRelativePath;
    /**
     * @param inner The wrapped adapter performing real I/O.
     * @param destinationRoot Destination workspace root (POSIX path).
     * @param mergeRelativePath Destination-relative path to merge.
     */
    constructor(inner, destinationRoot, mergeRelativePath) {
        this.inner = inner;
        this.destinationRoot = normalizePosix(destinationRoot);
        this.mergeRelativePath = mergeRelativePath;
    }
    /** @inheritdoc */
    listFiles(root) {
        return this.inner.listFiles(root);
    }
    /** @inheritdoc */
    isDir(path) {
        return this.inner.isDir(path);
    }
    /** @inheritdoc */
    isFile(path) {
        return this.inner.isFile(path);
    }
    /** @inheritdoc */
    readTextFile(path) {
        return this.inner.readTextFile(path);
    }
    /** @inheritdoc */
    ensureDir(path) {
        this.inner.ensureDir(path);
    }
    /**
     * Write a file, merging the one configured routing path when it exists.
     *
     * @param path Absolute destination POSIX path.
     * @param content Source content the engine wants to publish.
     * @throws RoutingMergeError When the destination routing document is not
     *   parseable; the destination bytes are left untouched.
     */
    writeTextFile(path, content) {
        if (!this.isMergeTarget(path)) {
            this.inner.writeTextFile(path, content);
            return;
        }
        // An absent destination file has nothing to preserve, so the source text is
        // written unchanged and the second push then merges against it.
        if (!this.inner.isFile(path)) {
            this.inner.writeTextFile(path, content);
            return;
        }
        const merged = this.mergeDocuments(this.inner.readTextFile(path), content, path);
        this.inner.writeTextFile(path, merged);
    }
    /** Merge source content into an existing destination routing document. */
    mergeDocuments(destinationText, sourceText, path) {
        return mergeRoutingDocuments(destinationText, sourceText, path);
    }
    /**
     * Return whether a destination path is the configured merge target.
     *
     * @param path Absolute destination POSIX path.
     * @returns True when the path resolves to the merge-target relative path.
     */
    isMergeTarget(path) {
        return (relativeToPosix(path, this.destinationRoot) === this.mergeRelativePath);
    }
}
exports.RoutingMergeFileSystem = RoutingMergeFileSystem;
/** Routing filesystem decorator that rejects destination-owned collisions. */
class AdditiveRoutingMergeFileSystem extends RoutingMergeFileSystem {
    /** @inheritdoc */
    mergeDocuments(destinationText, sourceText, path) {
        return mergeAdditiveRoutingDocuments(destinationText, sourceText, path);
    }
}
exports.AdditiveRoutingMergeFileSystem = AdditiveRoutingMergeFileSystem;
