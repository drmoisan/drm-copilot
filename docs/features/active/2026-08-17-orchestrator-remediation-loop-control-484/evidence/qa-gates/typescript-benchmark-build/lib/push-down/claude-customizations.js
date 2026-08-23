"use strict";
/**
 * Claude customization push-down publisher.
 *
 * Purpose:
 *     Port `push_down_claude_customizations.py`. Provides the dedicated entry
 *     point for publishing the bundled `.claude` tree, composing the filtering
 *     {@link ExcludingFileSystem} over the injected adapter and delegating the
 *     copy to the shared engine. Settings-local configuration is excluded;
 *     agent-memory files are filtered by scope and memory mode; pack selection
 *     restricts the published set; the C# variant routes canonical reads.
 *
 * Side effects:
 *     Reads source files and writes destination files plus the summary artifact
 *     through the adapter (via the engine).
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.BlastRadiusGuardError = exports.BlastRadiusDeriveFileSystem = exports.BlastRadiusDeriveError = exports.RoutingMergeFileSystem = exports.RoutingMergeError = exports.ManifestError = exports.MEMORY_MODE_CHOICES = exports.CSHARP_VARIANT_CHOICES = exports.PACK_MANIFEST_SUBDIR = exports.BUNDLE_ROOT_RELATIVE_DIR = exports.EXCLUDED_RELATIVE_PATHS = exports.ROUTING_MERGE_RELATIVE_PATH = exports.ROOT_FOLDERS = exports.ARTIFACT_DIRECTORY = void 0;
exports.passthroughRewrite = passthroughRewrite;
exports.parsePacksArgument = parsePacksArgument;
exports.resolvePublishedPaths = resolvePublishedPaths;
exports.pushDownCustomizations = pushDownCustomizations;
const copilot_customizations_engine_1 = require("./copilot-customizations-engine");
const claude_filesystem_adapter_1 = require("./claude-filesystem-adapter");
const claude_routing_merge_1 = require("./claude-routing-merge");
const claude_blast_radius_derive_1 = require("./claude-blast-radius-derive");
const claude_pack_selection_1 = require("./claude-pack-selection");
/** Artifact directory for the Claude push-down summary. */
exports.ARTIFACT_DIRECTORY = "artifacts/claude-customizations";
/**
 * Inlined Claude scoped root folders (enumeration-order contract).
 *
 * `config` is published alongside `.claude` because the destination-runtime
 * parallel surface reads `config/orchestration-routing.json` and
 * `config/blast-radius.json`, and a workspace that received only `.claude`
 * cannot resolve either. Enumeration order is the summary-artifact contract, so
 * `config` is appended after `.claude` rather than inserted before it.
 */
exports.ROOT_FOLDERS = [".claude", "config"];
/**
 * Destination-relative path whose write is merged rather than overwritten.
 *
 * A destination workspace may already carry its own routing document with
 * locally added routes. Overwriting it would silently discard them, so this one
 * path is merged by {@link RoutingMergeFileSystem}.
 *
 * Two destination-relative paths receive special handling. This one is merged;
 * `config/blast-radius.json` is intercepted by
 * {@link BlastRadiusDeriveFileSystem}, which replaces the bundled bytes with a
 * module map derived from the destination's own layout (the bundled map
 * describes drm-copilot and names none of an unrelated destination's modules).
 * Every other published file is a plain overwrite.
 */
exports.ROUTING_MERGE_RELATIVE_PATH = "config/orchestration-routing.json";
/** Repo-relative host-specific paths excluded from push-down. */
exports.EXCLUDED_RELATIVE_PATHS = [
    ".claude/settings.local.json",
];
/** Repo-relative location of the bundle root that holds manifests/variants. */
exports.BUNDLE_ROOT_RELATIVE_DIR = "extensions/drm-copilot/resources/claude-customizations";
/** Subdirectory under the bundle root containing pack-manifest JSON files. */
exports.PACK_MANIFEST_SUBDIR = "pack-manifests";
/** Valid CLI choices for the C# variant argument. */
exports.CSHARP_VARIANT_CHOICES = [
    "modern",
    "legacy",
];
/** Valid CLI choices for the memory-mode argument. */
exports.MEMORY_MODE_CHOICES = [
    "overwrite",
    "merge",
    "skip",
];
var claude_pack_selection_2 = require("./claude-pack-selection");
Object.defineProperty(exports, "ManifestError", { enumerable: true, get: function () { return claude_pack_selection_2.ManifestError; } });
var claude_routing_merge_2 = require("./claude-routing-merge");
Object.defineProperty(exports, "RoutingMergeError", { enumerable: true, get: function () { return claude_routing_merge_2.RoutingMergeError; } });
Object.defineProperty(exports, "RoutingMergeFileSystem", { enumerable: true, get: function () { return claude_routing_merge_2.RoutingMergeFileSystem; } });
var claude_blast_radius_derive_2 = require("./claude-blast-radius-derive");
Object.defineProperty(exports, "BlastRadiusDeriveError", { enumerable: true, get: function () { return claude_blast_radius_derive_2.BlastRadiusDeriveError; } });
Object.defineProperty(exports, "BlastRadiusDeriveFileSystem", { enumerable: true, get: function () { return claude_blast_radius_derive_2.BlastRadiusDeriveFileSystem; } });
Object.defineProperty(exports, "BlastRadiusGuardError", { enumerable: true, get: function () { return claude_blast_radius_derive_2.BlastRadiusGuardError; } });
/**
 * Passthrough rewrite for `.claude` content (no command rewrites).
 *
 * @param text Source text.
 * @returns A tuple `[text, 0, 0, []]`.
 */
function passthroughRewrite(text) {
    return [text, 0, 0, []];
}
/**
 * Join two POSIX path fragments with a single forward slash.
 *
 * @param root Base POSIX path.
 * @param relative Relative POSIX path fragment.
 * @returns The combined POSIX path.
 */
function joinPosix(root, relative) {
    const normalizedRoot = root.replace(/\\/g, "/").replace(/\/+$/, "");
    const normalizedRelative = relative.replace(/\\/g, "/").replace(/^\/+/, "");
    return normalizedRoot === ""
        ? normalizedRelative
        : `${normalizedRoot}/${normalizedRelative}`;
}
/**
 * Parse a comma-separated `--packs` value into a normalized pack-name set.
 *
 * @param packsValue The raw comma-separated value, or null/undefined when the
 *   flag was omitted.
 * @returns The set of non-empty, trimmed pack names, or null when the value was
 *   omitted or contained only empty entries (the publish-everything default).
 */
function parsePacksArgument(packsValue) {
    if (packsValue === null || packsValue === undefined) {
        return null;
    }
    // Trim whitespace and drop empty entries so trailing commas do not produce
    // empty pack names.
    const names = new Set();
    for (const entry of packsValue.split(",")) {
        const trimmed = entry.trim();
        if (trimmed !== "") {
            names.add(trimmed);
        }
    }
    return names.size === 0 ? null : names;
}
/**
 * Compute the published `.claude`-relative path set for a pack selection.
 *
 * Returns null when no pack selection was supplied (publish everything, no
 * manifest read). Otherwise loads manifests, computes the union (always
 * including core), and asserts C# mutual exclusion.
 *
 * @param packs Selected pack names, or null/empty for the default.
 * @param bundleRoot Bundle root containing the `pack-manifests` subdirectory.
 * @param fs Adapter used to read the manifest files.
 * @returns The union path set, or null for the publish-everything default.
 * @throws ManifestError When a manifest is missing/malformed or both C# variants
 *   are selected.
 */
function resolvePublishedPaths(packs, bundleRoot, fs) {
    // No explicit selection means publish everything without a manifest read.
    if (packs === null || packs.size === 0) {
        return null;
    }
    const manifestDir = joinPosix(bundleRoot, exports.PACK_MANIFEST_SUBDIR);
    const manifests = (0, claude_pack_selection_1.loadPackManifests)(manifestDir, packs, fs);
    const published = (0, claude_pack_selection_1.computePublishedPaths)(packs, manifests);
    // computePublishedPaths returns null only for an empty selection, already
    // excluded above; treat a null here as an empty set so the C# exclusion check
    // still runs on a concrete value.
    const effectivePublished = published ?? new Set();
    (0, claude_pack_selection_1.assertSingleCsharpToolchain)(effectivePublished, packs);
    return effectivePublished;
}
/**
 * Copy the `.claude` tree into the destination workspace.
 *
 * Composes {@link ExcludingFileSystem} over the injected adapter and delegates
 * to the shared engine with the Claude root folders, artifact directory, and the
 * passthrough rewrite.
 *
 * @param options Entry options (roots, filesystem, pack/variant/memory inputs).
 * @returns The completed run summary including the written artifact path.
 * @throws ManifestError When a selected manifest is missing/malformed or both C#
 *   variants are selected.
 * @throws Error When destination validation fails.
 */
function pushDownCustomizations(options) {
    const { repoRoot, destinationRoot, fs, sourceRoot, artifactRoot, packs, csharpVariant, memoryMode, bundleRoot, clock, listEntries, } = options;
    const effectiveSource = sourceRoot ?? repoRoot;
    // Resolve the bundle root that holds manifests and the variant subtree. The
    // repository layout nests the bundle under the source root; an explicit
    // bundleRoot (the bundled template) overrides this.
    const effectiveBundle = bundleRoot ?? joinPosix(effectiveSource, exports.BUNDLE_ROOT_RELATIVE_DIR);
    // Resolve the published-path set only when a pack selection is supplied so the
    // no-argument path performs no manifest I/O.
    const publishedPaths = resolvePublishedPaths(packs ?? null, effectiveBundle, fs);
    // Merge, rather than overwrite, the one destination path that a workspace may
    // legitimately have extended locally. The decorator sits closest to the real
    // adapter so the filtering wrapper above it is unaffected.
    const mergingFs = new claude_routing_merge_1.RoutingMergeFileSystem(fs, destinationRoot, exports.ROUTING_MERGE_RELATIVE_PATH);
    // Derive, rather than copy, the blast-radius module map. The two decorators
    // intercept disjoint paths, so their relative order is immaterial; this one is
    // layered above the merging decorator purely to keep both adjacent and close
    // to the real adapter, below the filtering wrapper.
    const derivingFs = listEntries === undefined
        ? new claude_blast_radius_derive_1.BlastRadiusDeriveFileSystem(mergingFs, destinationRoot)
        : new claude_blast_radius_derive_1.BlastRadiusDeriveFileSystem(mergingFs, destinationRoot, listEntries);
    // Wrap the adapter so enumeration omits excluded paths and honors selections.
    const excludingFs = new claude_filesystem_adapter_1.ExcludingFileSystem(derivingFs, repoRoot, exports.EXCLUDED_RELATIVE_PATHS, {
        sourceRoot: effectiveSource,
        destinationRoot,
        publishedPaths,
        csharpVariant: csharpVariant ?? "modern",
        memoryMode: memoryMode ?? "overwrite",
        variantRoot: effectiveBundle,
    });
    return (0, copilot_customizations_engine_1.pushDownCustomizations)({
        repoRoot,
        destinationRoot,
        fs: excludingFs,
        ...(sourceRoot === undefined ? {} : { sourceRoot }),
        ...(artifactRoot === undefined ? {} : { artifactRoot }),
        rootFolders: exports.ROOT_FOLDERS,
        artifactDirectory: exports.ARTIFACT_DIRECTORY,
        rewriteReferences: passthroughRewrite,
        ...(clock === undefined ? {} : { clock }),
    });
}
