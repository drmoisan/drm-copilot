"use strict";
/**
 * Destination-aware blast-radius derivation decorator for the Claude push-down.
 *
 * Purpose:
 *     Special-case the single destination-relative path
 *     `config/blast-radius.json` so publishing it into an unrelated workspace
 *     writes a module map derived from that workspace's own layout rather than
 *     the bundled map, which describes drm-copilot's layout and names none of
 *     the destination's modules. Every other path passes straight through to the
 *     wrapped adapter.
 *
 * Why a decorator rather than engine logic:
 *     The substitution is Claude-specific and path-specific, exactly like the
 *     routing merge it is modeled on ({@link RoutingMergeFileSystem} in
 *     `claude-routing-merge.ts`). Putting it in the shared
 *     `copilot-customizations-engine` would apply it to the Copilot and Codex
 *     entry points, which publish no `config/` tree, and putting it in
 *     `rewriteReferences` would be wrong because that hook sees only source text
 *     and never the destination's layout.
 *
 * Responsibilities:
 *     Own algorithm step 1 only: collect a deterministic observation list by a
 *     depth-limited breadth-first scan of the destination root. Steps 2 through
 *     8 belong to the pure core `claude-blast-radius-derive-core.ts`, which this
 *     module calls and never duplicates.
 *
 * Tolerance rule (pinned):
 *     A `listEntries` failure at any level, including on the destination root
 *     itself, contributes no entries and does not fail the derivation. This
 *     mirrors `RealPushDownFileSystem.listFiles` (`filesystem-adapter.ts`) and
 *     is required rather than merely convenient: existing push-down tests
 *     publish to in-memory destinations such as `/dest` that the real-filesystem
 *     default lister cannot see, so a root-level `readdirSync` failure must
 *     degrade to zero observations, which the core's no-signal floor then
 *     handles.
 *
 * Side effects:
 *     Reads destination directory listings and delegates all writes to the
 *     wrapped adapter.
 */
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
exports.BlastRadiusDeriveFileSystem = exports.realDirectoryLister = exports.BlastRadiusGuardError = exports.BlastRadiusDeriveError = exports.BLAST_RADIUS_RELATIVE_PATH = void 0;
exports.collectDestinationObservations = collectDestinationObservations;
const fs = __importStar(require("node:fs"));
const claude_blast_radius_derive_core_1 = require("./claude-blast-radius-derive-core");
var claude_blast_radius_derive_core_2 = require("./claude-blast-radius-derive-core");
Object.defineProperty(exports, "BLAST_RADIUS_RELATIVE_PATH", { enumerable: true, get: function () { return claude_blast_radius_derive_core_2.BLAST_RADIUS_RELATIVE_PATH; } });
Object.defineProperty(exports, "BlastRadiusDeriveError", { enumerable: true, get: function () { return claude_blast_radius_derive_core_2.BlastRadiusDeriveError; } });
Object.defineProperty(exports, "BlastRadiusGuardError", { enumerable: true, get: function () { return claude_blast_radius_derive_core_2.BlastRadiusGuardError; } });
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
 * Real-filesystem directory lister used when no seam is injected.
 *
 * @param root Absolute directory to list.
 * @returns Entries directly inside `root`, ordinally sorted by name; an empty
 *   array when the directory cannot be read.
 */
const realDirectoryLister = (root) => {
    let entries;
    try {
        entries = fs.readdirSync(root, { withFileTypes: true });
    }
    catch {
        // A directory that cannot be read contributes no entries; see the tolerance
        // rule in this module's header comment.
        return [];
    }
    return entries
        .map((entry) => ({ name: entry.name, isDir: entry.isDirectory() }))
        .sort((left, right) => left.name < right.name ? -1 : left.name > right.name ? 1 : 0);
};
exports.realDirectoryLister = realDirectoryLister;
/**
 * Call a lister without letting its failure abort the derivation.
 *
 * @param lister The injected or default lister.
 * @param path Absolute directory to list.
 * @returns The entries, or an empty array when the lister threw.
 */
function listTolerantly(lister, path) {
    try {
        return lister(path);
    }
    catch {
        // Matches the real lister's own tolerance so an injected seam and the
        // default behave identically on an unreadable directory.
        return [];
    }
}
/**
 * Collect the destination observation list (algorithm step 1).
 *
 * Breadth-first from the destination root to {@link SCAN_DEPTH_LIMIT}, visiting
 * subdirectories in ordinal name order and pruning excluded and dot-prefixed
 * names. Breadth-first order with an ordinally sorted queue makes the resulting
 * list a pure function of the visible layout, which is what makes the derived
 * document byte-stable across pushes.
 *
 * @param destinationRoot Absolute destination workspace root (POSIX path).
 * @param lister Shallow directory lister.
 * @returns One observation per visited directory, the root first.
 */
function collectDestinationObservations(destinationRoot, lister) {
    const root = normalizePosix(destinationRoot);
    const observations = [];
    // The queue holds directories still to visit with their depth. Depth 1 is the
    // root, so the bound admits the root plus two nested levels.
    let queue = [
        { path: root, relativePath: "" },
    ];
    for (let depth = 1; depth <= claude_blast_radius_derive_core_1.SCAN_DEPTH_LIMIT && queue.length > 0; depth++) {
        const nextQueue = [];
        // Visit every directory at the current depth before descending, recording
        // its shallow file names and enqueuing the subdirectories worth visiting.
        for (const current of queue) {
            const entries = listTolerantly(lister, current.path);
            const fileNames = [];
            for (const entry of entries) {
                if (!entry.isDir) {
                    fileNames.push(entry.name);
                    continue;
                }
                if ((0, claude_blast_radius_derive_core_1.isExcludedDirectoryName)(entry.name)) {
                    continue;
                }
                nextQueue.push({
                    path: `${current.path}/${entry.name}`,
                    relativePath: current.relativePath === ""
                        ? entry.name
                        : `${current.relativePath}/${entry.name}`,
                });
            }
            observations.push({
                relativePath: current.relativePath,
                fileNames,
            });
        }
        queue = nextQueue;
    }
    return observations;
}
/**
 * Wrap a {@link PushDownFileSystem} so one path is derived instead of copied.
 *
 * Every method other than `writeTextFile` delegates unchanged. `writeTextFile`
 * substitutes a derived document only when the target resolves to
 * `config/blast-radius.json` relative to the destination root; the bundled
 * content the engine supplies becomes the derivation's base document rather than
 * the bytes written.
 *
 * The wrapped {@link PushDownFileSystem} contract is not widened: this class
 * implements exactly its six members.
 */
class BlastRadiusDeriveFileSystem {
    inner;
    destinationRoot;
    deriveRelativePath;
    lister;
    /**
     * @param inner The wrapped adapter performing real I/O.
     * @param destinationRoot Destination workspace root (POSIX path).
     * @param lister Shallow directory lister; defaults to the real filesystem.
     * @param deriveRelativePath Destination-relative path to derive; defaults to
     *   `config/blast-radius.json`.
     */
    constructor(inner, destinationRoot, lister = exports.realDirectoryLister, deriveRelativePath = claude_blast_radius_derive_core_1.BLAST_RADIUS_RELATIVE_PATH) {
        this.inner = inner;
        this.destinationRoot = normalizePosix(destinationRoot);
        this.lister = lister;
        this.deriveRelativePath = deriveRelativePath;
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
     * Write a file, deriving the one configured blast-radius path.
     *
     * @param path Absolute destination POSIX path.
     * @param content Bundled source content the engine wants to publish, used as
     *   the derivation's base document rather than written verbatim.
     * @throws BlastRadiusDeriveError When the bundled document is not parseable.
     * @throws BlastRadiusGuardError When a forbidden glob would be emitted. Both
     *   errors are raised before the inner write, so the destination bytes are
     *   left untouched.
     */
    writeTextFile(path, content) {
        if (!this.isDeriveTarget(path)) {
            this.inner.writeTextFile(path, content);
            return;
        }
        const observations = collectDestinationObservations(this.destinationRoot, this.lister);
        const derived = (0, claude_blast_radius_derive_core_1.deriveDestinationModuleMap)(observations, content);
        this.inner.writeTextFile(path, derived);
    }
    /**
     * Return whether a destination path is the configured derivation target.
     *
     * @param path Absolute destination POSIX path.
     * @returns True when the path resolves to the derive-target relative path.
     */
    isDeriveTarget(path) {
        return (relativeToPosix(path, this.destinationRoot) === this.deriveRelativePath);
    }
}
exports.BlastRadiusDeriveFileSystem = BlastRadiusDeriveFileSystem;
