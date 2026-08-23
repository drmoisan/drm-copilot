"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.PortableAssetFileSystem = exports.PORTABLE_ASSET_RELATIVE_PATHS = void 0;
/** Exact cross-runtime assets permitted in a Codex publication. */
exports.PORTABLE_ASSET_RELATIVE_PATHS = [
    ".claude/lib/bash/compute-cohorts.sh",
    ".claude/lib/bash/compute-concurrency-batches.sh",
    ".claude/lib/bash/parallel-cohorts.sh",
    ".claude/lib/bash/parallel-common.sh",
    ".claude/lib/bash/parallel-items-validate.sh",
    ".claude/lib/bash/parallel-manifest-validate.sh",
    ".claude/lib/bash/parallel-yaml-emit.sh",
    ".claude/lib/bash/parallel-yaml-scan.sh",
    ".claude/lib/bash/validate-parallel-manifest.sh",
    ".claude/lib/blast-radius/BlastRadius.psm1",
    ".claude/lib/blast-radius/BlastRadiusConfig.psm1",
    ".claude/lib/blast-radius/BlastRadiusExtraction.psm1",
    ".claude/lib/blast-radius/BlastRadiusGlob.psm1",
    ".claude/lib/blast-radius/BlastRadiusValidation.psm1",
    "config/blast-radius.json",
];
const PORTABLE_ASSET_PATH_SET = new Set(exports.PORTABLE_ASSET_RELATIVE_PATHS);
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
 * Expose only selected approved portable assets from a generic resource bundle.
 */
class PortableAssetFileSystem {
    inner;
    sourceRoot;
    resourceRoot;
    publishedPaths;
    constructor(inner, options) {
        this.inner = inner;
        this.sourceRoot = normalizePosix(options.sourceRoot);
        this.resourceRoot = normalizePosix(options.resourceRoot);
        this.publishedPaths = options.publishedPaths;
    }
    sourceRelative(path) {
        return relativeToPosix(path, this.sourceRoot);
    }
    isSelected(relativePath) {
        return (PORTABLE_ASSET_PATH_SET.has(relativePath) &&
            (this.publishedPaths === null || this.publishedPaths.has(relativePath)));
    }
    resourcePath(path) {
        const relativePath = this.sourceRelative(path);
        if (relativePath === null || !this.isSelected(relativePath)) {
            return null;
        }
        const canonicalPath = joinPosix(this.sourceRoot, relativePath);
        if (relativePath !== "config/blast-radius.json" &&
            this.inner.isFile(canonicalPath)) {
            return canonicalPath;
        }
        const genericPath = joinPosix(this.resourceRoot, relativePath);
        return this.inner.isFile(genericPath) ? genericPath : null;
    }
    selectedVirtualPaths() {
        return exports.PORTABLE_ASSET_RELATIVE_PATHS.filter((relativePath) => {
            const virtualPath = joinPosix(this.sourceRoot, relativePath);
            return (this.isSelected(relativePath) && this.resourcePath(virtualPath) !== null);
        }).map((relativePath) => joinPosix(this.sourceRoot, relativePath));
    }
    /** Reject unequal portable destinations before any publisher write. */
    validateDestinationCollisions(destinationRoot) {
        const collisions = [];
        for (const virtualPath of this.selectedVirtualPaths()) {
            const relativePath = this.sourceRelative(virtualPath);
            if (relativePath === null) {
                continue;
            }
            const destinationPath = joinPosix(destinationRoot, relativePath);
            const resourcePath = this.resourcePath(virtualPath);
            if (resourcePath === null) {
                continue;
            }
            if (this.inner.isFile(destinationPath) &&
                this.inner.readTextFile(destinationPath) !==
                    this.inner.readTextFile(resourcePath)) {
                collisions.push(relativePath);
            }
        }
        if (collisions.length > 0) {
            throw new Error(`Portable asset collision(s) detected: ${collisions.join(", ")}`);
        }
    }
    listFiles(root) {
        const normalizedRoot = normalizePosix(root);
        const claudeRoot = joinPosix(this.sourceRoot, ".claude");
        const configRoot = joinPosix(this.sourceRoot, "config");
        const selectedPaths = this.selectedVirtualPaths();
        if (normalizedRoot === claudeRoot) {
            return selectedPaths.filter((path) => relativeToPosix(path, claudeRoot) !== null);
        }
        const delegated = this.inner.listFiles(root);
        if (normalizedRoot !== configRoot) {
            return delegated;
        }
        const blastRadiusPath = joinPosix(this.sourceRoot, "config/blast-radius.json");
        const combined = new Set(delegated.filter((path) => normalizePosix(path) !== blastRadiusPath));
        for (const path of selectedPaths) {
            if (relativeToPosix(path, configRoot) !== null) {
                combined.add(path);
            }
        }
        return [...combined].sort();
    }
    isDir(path) {
        return this.inner.isDir(path);
    }
    isFile(path) {
        const relativePath = this.sourceRelative(path);
        if (relativePath !== null && PORTABLE_ASSET_PATH_SET.has(relativePath)) {
            const resourcePath = this.resourcePath(path);
            return resourcePath !== null && this.inner.isFile(resourcePath);
        }
        return this.inner.isFile(path);
    }
    readTextFile(path) {
        return this.inner.readTextFile(this.resourcePath(path) ?? path);
    }
    writeTextFile(path, content) {
        this.inner.writeTextFile(path, content);
    }
    ensureDir(path) {
        this.inner.ensureDir(path);
    }
}
exports.PortableAssetFileSystem = PortableAssetFileSystem;
