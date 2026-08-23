"use strict";
/**
 * Codex/agents customization push-down publisher.
 *
 * Purpose:
 *     Port `push_down_codex_and_agents_customizations.py`. Provides a dedicated
 *     entry point for publishing the bundled `.codex` and `.agents` trees plus
 *     the shared routing config while reusing the copilot push-down engine.
 *
 * Side effects:
 *     Delegates all filesystem I/O to the injected {@link PushDownFileSystem}
 *     via the shared engine.
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.ROUTING_CONFIG_RELATIVE_PATH = exports.GENERIC_RESOURCE_BUNDLE_NAME = exports.PACK_MANIFEST_SUBDIR = exports.ROOT_FOLDERS = exports.ARTIFACT_DIRECTORY = void 0;
exports.passthroughRewrite = passthroughRewrite;
exports.pushDownCustomizations = pushDownCustomizations;
const copilot_customizations_engine_1 = require("./copilot-customizations-engine");
const codex_pack_selection_1 = require("./codex-pack-selection");
const codex_portable_assets_1 = require("./codex-portable-assets");
const claude_routing_merge_1 = require("./claude-routing-merge");
/** Artifact directory for the Codex/agents push-down summary. */
exports.ARTIFACT_DIRECTORY = "artifacts/codex-and-agents-customizations";
/** Inlined Codex/agents scoped root folders (enumeration-order contract). */
exports.ROOT_FOLDERS = [".codex", ".agents"];
exports.PACK_MANIFEST_SUBDIR = "pack-manifests";
exports.GENERIC_RESOURCE_BUNDLE_NAME = "claude-customizations";
exports.ROUTING_CONFIG_RELATIVE_PATH = "config/orchestration-routing.json";
const PUBLISHED_ROOT_FOLDERS = [
    ...exports.ROOT_FOLDERS,
    ".claude",
    "config",
];
/**
 * Passthrough rewrite for payloads that do not need command rewrites.
 *
 * Mirrors the Python `_passthrough_rewrite`: returns the text unchanged with
 * zero rewrite/placeholder counts and no unmatched references.
 *
 * @param text Source text.
 * @returns A tuple `[text, 0, 0, []]`.
 */
function passthroughRewrite(text) {
    return [text, 0, 0, []];
}
function normalizePosix(value) {
    return value.replace(/\\/g, "/").replace(/\/+$/, "");
}
function joinPosix(root, relative) {
    const normalizedRoot = normalizePosix(root);
    const normalizedRelative = relative.replace(/\\/g, "/").replace(/^\/+/, "");
    return normalizedRoot === ""
        ? normalizedRelative
        : `${normalizedRoot}/${normalizedRelative}`;
}
function parentPosix(path) {
    const normalized = normalizePosix(path);
    const separatorIndex = normalized.lastIndexOf("/");
    if (separatorIndex < 0) {
        return "";
    }
    return separatorIndex === 0 ? "/" : normalized.slice(0, separatorIndex);
}
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
class CodexFilteringFileSystem {
    inner;
    sourceRoot;
    bundleRoot;
    publishedPaths;
    csharpVariant;
    constructor(inner, options) {
        this.inner = inner;
        this.sourceRoot = normalizePosix(options.sourceRoot);
        this.bundleRoot = normalizePosix(options.bundleRoot);
        this.publishedPaths = options.publishedPaths;
        this.csharpVariant = options.csharpVariant;
    }
    sourceRelative(path) {
        return relativeToPosix(path, this.sourceRoot);
    }
    isPackIncluded(path) {
        if (this.publishedPaths === null) {
            return true;
        }
        const relative = this.sourceRelative(path);
        return relative === null || this.publishedPaths.has(relative);
    }
    resolveReadSource(path) {
        if (this.csharpVariant !== "legacy") {
            return path;
        }
        const relative = this.sourceRelative(path);
        if (relative === null) {
            return path;
        }
        const routed = (0, codex_pack_selection_1.resolveVariantSourcePath)(relative, "legacy");
        return routed === relative ? path : joinPosix(this.bundleRoot, routed);
    }
    listFiles(root) {
        return this.inner
            .listFiles(root)
            .filter((path) => this.isPackIncluded(path));
    }
    isDir(path) {
        return this.inner.isDir(path);
    }
    isFile(path) {
        return this.inner.isFile(path);
    }
    readTextFile(path) {
        return this.inner.readTextFile(this.resolveReadSource(path));
    }
    writeTextFile(path, content) {
        this.inner.writeTextFile(path, content);
    }
    ensureDir(path) {
        this.inner.ensureDir(path);
    }
}
class RoutingConfigFileSystem {
    inner;
    virtualPath;
    virtualRoot;
    resourcePath;
    constructor(inner, options) {
        this.inner = inner;
        this.virtualPath = joinPosix(options.sourceRoot, exports.ROUTING_CONFIG_RELATIVE_PATH);
        this.virtualRoot = joinPosix(options.sourceRoot, "config");
        this.resourcePath = joinPosix(parentPosix(options.bundleRoot), exports.ROUTING_CONFIG_RELATIVE_PATH);
    }
    listFiles(root) {
        if (normalizePosix(root) === this.virtualRoot) {
            return this.inner.isFile(this.resourcePath) ? [this.virtualPath] : [];
        }
        return this.inner.listFiles(root);
    }
    isDir(path) {
        return this.inner.isDir(path);
    }
    isFile(path) {
        return normalizePosix(path) === this.virtualPath
            ? this.inner.isFile(this.resourcePath)
            : this.inner.isFile(path);
    }
    readTextFile(path) {
        return this.inner.readTextFile(normalizePosix(path) === this.virtualPath ? this.resourcePath : path);
    }
    writeTextFile(path, content) {
        this.inner.writeTextFile(path, content);
    }
    ensureDir(path) {
        this.inner.ensureDir(path);
    }
}
function resolvePublishedPaths(packs, csharpVariant, bundleRoot, fs) {
    const manifestPacks = (0, codex_pack_selection_1.resolveManifestPackNames)(packs ?? null, csharpVariant);
    if (manifestPacks === null || manifestPacks.size === 0) {
        return null;
    }
    const manifests = (0, codex_pack_selection_1.loadPackManifests)(joinPosix(bundleRoot, exports.PACK_MANIFEST_SUBDIR), manifestPacks, fs);
    const published = (0, codex_pack_selection_1.computePublishedPaths)(manifestPacks, manifests) ?? new Set();
    (0, codex_pack_selection_1.assertSingleCsharpToolchain)(published, manifestPacks);
    return published;
}
/**
 * Copy Codex trees and the shared routing config into the destination workspace.
 *
 * Delegates to the shared engine with the Codex/agents root folders, artifact
 * directory, and the passthrough rewrite (no command-reference rewriting).
 *
 * @param options Entry options (roots, filesystem, optional clock).
 * @returns The completed run summary including the written artifact path.
 * @throws Error When destination validation fails.
 */
function pushDownCustomizations(options) {
    const sourceRoot = options.sourceRoot ?? options.repoRoot;
    const bundleRoot = options.bundleRoot ?? sourceRoot;
    const csharpVariant = options.csharpVariant ?? "modern";
    const publishedPaths = resolvePublishedPaths(options.packs, csharpVariant, bundleRoot, options.fs);
    const filteringFs = new CodexFilteringFileSystem(options.fs, {
        sourceRoot,
        bundleRoot,
        publishedPaths,
        csharpVariant,
    });
    const routingFs = new RoutingConfigFileSystem(filteringFs, {
        sourceRoot,
        bundleRoot,
    });
    const publishingFs = new codex_portable_assets_1.PortableAssetFileSystem(routingFs, {
        sourceRoot,
        resourceRoot: joinPosix(parentPosix(bundleRoot), exports.GENERIC_RESOURCE_BUNDLE_NAME),
        publishedPaths,
    });
    publishingFs.validateDestinationCollisions(options.destinationRoot);
    const mergeFs = new claude_routing_merge_1.AdditiveRoutingMergeFileSystem(publishingFs, options.destinationRoot, exports.ROUTING_CONFIG_RELATIVE_PATH);
    void options.memoryMode;
    return (0, copilot_customizations_engine_1.pushDownCustomizations)({
        repoRoot: options.repoRoot,
        destinationRoot: options.destinationRoot,
        fs: mergeFs,
        sourceRoot,
        ...(options.artifactRoot === undefined
            ? {}
            : { artifactRoot: options.artifactRoot }),
        rootFolders: PUBLISHED_ROOT_FOLDERS,
        artifactDirectory: exports.ARTIFACT_DIRECTORY,
        rewriteReferences: passthroughRewrite,
        ...(options.clock === undefined ? {} : { clock: options.clock }),
    });
}
