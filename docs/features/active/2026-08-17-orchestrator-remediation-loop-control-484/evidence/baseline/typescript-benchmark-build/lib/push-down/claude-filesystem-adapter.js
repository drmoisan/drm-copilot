"use strict";
/**
 * Filtering filesystem wrapper for the `.claude` customization push-down.
 *
 * Purpose:
 *     Port the `ExcludingFileSystem` of `push_down_claude_filesystem.py`. It
 *     presents a filtered, variant-aware view of the source `.claude` tree to
 *     the shared publisher engine so the engine's destination derivation stays
 *     correct while the published set, per-file source content, and agent-memory
 *     handling all honor the selected packs, C# variant, and memory mode.
 *
 * Responsibilities:
 *     - Exclude host-specific files (for example `settings.local.json`).
 *     - Apply the general-vs-repo agent-memory scope filter.
 *     - Restrict enumeration to the published-pack set when a selection is
 *       active.
 *     - Redirect legacy C# canonical reads to the bundle-only legacy source.
 *     - Apply the memory mode (overwrite / skip / merge).
 *
 * Path model:
 *     All paths are forward-slash POSIX strings. The Python resolved-vs-
 *     unresolved root distinction is replicated by normalizing POSIX strings, so
 *     comparisons stay hermetic and host-independent.
 *
 * Side effects:
 *     Delegates all I/O to the inner adapter.
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.ExcludingFileSystem = exports.readMemoryScope = exports.isGeneralMemoryFile = exports.REPO_MEMORY_SCOPE = exports.GENERAL_MEMORY_SCOPE = exports.AGENT_MEMORY_RELATIVE_ROOT = void 0;
const claude_memory_scope_1 = require("./claude-memory-scope");
const claude_pack_selection_1 = require("./claude-pack-selection");
var claude_memory_scope_2 = require("./claude-memory-scope");
Object.defineProperty(exports, "AGENT_MEMORY_RELATIVE_ROOT", { enumerable: true, get: function () { return claude_memory_scope_2.AGENT_MEMORY_RELATIVE_ROOT; } });
Object.defineProperty(exports, "GENERAL_MEMORY_SCOPE", { enumerable: true, get: function () { return claude_memory_scope_2.GENERAL_MEMORY_SCOPE; } });
Object.defineProperty(exports, "REPO_MEMORY_SCOPE", { enumerable: true, get: function () { return claude_memory_scope_2.REPO_MEMORY_SCOPE; } });
Object.defineProperty(exports, "isGeneralMemoryFile", { enumerable: true, get: function () { return claude_memory_scope_2.isGeneralMemoryFile; } });
Object.defineProperty(exports, "readMemoryScope", { enumerable: true, get: function () { return claude_memory_scope_2.readMemoryScope; } });
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
 * Join two POSIX path fragments with a single forward slash.
 *
 * @param root Base POSIX path.
 * @param relative Relative POSIX path.
 * @returns The combined POSIX path.
 */
function joinPosix(root, relative) {
    const normalizedRoot = normalizePosix(root);
    const normalizedRelative = relative.replace(/\\/g, "/").replace(/^\/+/, "");
    if (normalizedRoot === "") {
        return normalizedRelative;
    }
    if (normalizedRelative === "") {
        return normalizedRoot;
    }
    return `${normalizedRoot}/${normalizedRelative}`;
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
    if (normalizedPath.startsWith(prefix)) {
        return normalizedPath.slice(prefix.length);
    }
    return null;
}
/**
 * Wrap a {@link PushDownFileSystem} with scope, pack, variant, and memory
 * filters.
 *
 * Mirrors the Python `ExcludingFileSystem`. Enumeration drops hard-excluded
 * paths, agent-memory files outside the active scope, files outside the active
 * published set, and agent-memory files excluded by the memory mode. Reads of
 * canonical C# paths are redirected to the legacy source for the legacy
 * variant.
 */
class ExcludingFileSystem {
    inner;
    repoRoot;
    sourceRoot;
    variantRoot;
    destinationRoot;
    publishedPaths;
    csharpVariant;
    memoryMode;
    excluded;
    /**
     * @param inner The wrapped adapter performing real I/O.
     * @param repoRoot Repository root used to resolve excluded paths and the
     *   agent-memory scope prefix.
     * @param excluded Repo-relative POSIX paths to always exclude.
     * @param options Optional source/destination roots and selection inputs.
     */
    constructor(inner, repoRoot, excluded, options = {}) {
        this.inner = inner;
        this.repoRoot = normalizePosix(repoRoot);
        // Keep the source root for relative-path comparisons and redirected reads.
        this.sourceRoot = normalizePosix(options.sourceRoot ?? repoRoot);
        // The variant root holds the legacy subtree; legacy reads redirect beneath.
        this.variantRoot = normalizePosix(options.variantRoot ?? options.sourceRoot ?? repoRoot);
        this.destinationRoot =
            options.destinationRoot === undefined
                ? undefined
                : normalizePosix(options.destinationRoot);
        this.publishedPaths = options.publishedPaths ?? null;
        this.csharpVariant = options.csharpVariant ?? "modern";
        this.memoryMode = options.memoryMode ?? "overwrite";
        // Resolve excluded paths once for O(1) membership checks.
        this.excluded = new Set(excluded.map((p) => joinPosix(this.repoRoot, p)));
    }
    /**
     * Return the source-relative POSIX path, or null when outside the root.
     *
     * @param path An absolute candidate POSIX path from the inner adapter.
     * @returns The source-relative POSIX path, or `null`.
     */
    sourceRelativePosix(path) {
        return relativeToPosix(path, this.sourceRoot);
    }
    /**
     * Return whether a candidate path is in the active published set.
     *
     * @param path An absolute candidate POSIX path.
     * @returns True when no pack filter is active or the path is published.
     */
    isPackIncluded(path) {
        // A null published set means no selection: every enumerated file is in.
        if (this.publishedPaths === null) {
            return true;
        }
        const relative = this.sourceRelativePosix(path);
        if (relative === null) {
            return true;
        }
        return this.publishedPaths.has(relative);
    }
    /**
     * Return whether a candidate file passes the agent-memory scope filter.
     *
     * Reads file content only for agent-memory candidates.
     *
     * @param path An absolute candidate POSIX path.
     * @returns True when the file is outside the memory subtree or general-scoped.
     */
    isScopeIncluded(path) {
        const relativePath = relativeToPosix(path, this.repoRoot);
        if (relativePath === null) {
            // A path outside the repo root cannot be an agent memory; include it.
            return true;
        }
        // Skip the content read entirely for files outside the memory subtree.
        if (!(0, claude_memory_scope_1.isUnderAgentMemory)(relativePath)) {
            return true;
        }
        const content = this.readText(path);
        return (0, claude_memory_scope_1.isGeneralMemoryFile)(relativePath, content);
    }
    /**
     * Return whether a candidate file passes the memory-mode filter.
     *
     * @param path An absolute candidate POSIX path.
     * @returns True when the file should be published under the active mode.
     */
    isMemoryModeIncluded(path) {
        const relative = this.sourceRelativePosix(path);
        if (relative === null) {
            return true;
        }
        // Only agent-memory files are affected by the memory mode.
        if (!(0, claude_memory_scope_1.isUnderAgentMemory)(relative)) {
            return true;
        }
        // Route by mode: skip drops all memories; merge keeps only those absent at
        // the destination; overwrite (default) keeps everything.
        if (this.memoryMode === "skip") {
            return false;
        }
        if (this.memoryMode === "merge") {
            if (this.destinationRoot === undefined) {
                return true;
            }
            const destinationPath = joinPosix(this.destinationRoot, relative);
            return !this.inner.isFile(destinationPath);
        }
        return true;
    }
    /**
     * Return the actual source path to read for a requested path.
     *
     * Redirects canonical C# reads to the bundle-only legacy source when the
     * legacy variant is active; otherwise passes the path through unchanged.
     *
     * @param path The absolute POSIX path the engine asked to read.
     * @returns The redirected legacy source path, or the original path.
     */
    resolveReadSource(path) {
        if (this.csharpVariant !== "legacy") {
            return path;
        }
        const relative = this.sourceRelativePosix(path);
        if (relative === null || !claude_pack_selection_1.CSHARP_CANONICAL_PATHS.includes(relative)) {
            return path;
        }
        const redirectedRelative = (0, claude_pack_selection_1.resolveVariantSourcePath)(relative, "legacy");
        // Join under the variant (bundle) root so the read lives in the same key
        // space the engine enumerated from.
        return joinPosix(this.variantRoot, redirectedRelative);
    }
    listFiles(root) {
        // Apply the four enumeration filters in sequence: hard exclusions, pack
        // selection, agent-memory scope, then memory mode.
        return this.inner
            .listFiles(root)
            .filter((p) => !this.excluded.has(normalizePosix(p)) &&
            this.isPackIncluded(p) &&
            this.isScopeIncluded(p) &&
            this.isMemoryModeIncluded(p));
    }
    isDir(path) {
        return this.inner.isDir(path);
    }
    isFile(path) {
        return this.inner.isFile(path);
    }
    readText(path) {
        return this.inner.readTextFile(this.resolveReadSource(path));
    }
    readTextFile(path) {
        return this.readText(path);
    }
    writeTextFile(path, content) {
        this.inner.writeTextFile(path, content);
    }
    ensureDir(path) {
        this.inner.ensureDir(path);
    }
}
exports.ExcludingFileSystem = ExcludingFileSystem;
