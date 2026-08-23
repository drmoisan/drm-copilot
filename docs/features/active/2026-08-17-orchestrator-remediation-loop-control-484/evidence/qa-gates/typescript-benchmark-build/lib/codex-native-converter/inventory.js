"use strict";
/**
 * Discover and normalize source artifacts for the Codex-native converter.
 *
 * Purpose:
 *     Provide deterministic source-file enumeration for supported ecosystems
 *     while preventing caller-selected paths from escaping the declared source
 *     root. Ported from `inventory.py`; filesystem access flows through the
 *     injected {@link FileSystem} rather than `node:fs`.
 *
 * Flow:
 *     Supported top-level source surfaces are selected by ecosystem, candidate
 *     files are enumerated beneath those surfaces, and the result is sorted by
 *     normalized relative path.
 *
 * Invariants:
 *     All returned paths are source-root-relative POSIX strings using a stable
 *     ordering independent of host traversal order.
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.normalizeSelectedPaths = normalizeSelectedPaths;
exports.discoverSourceArtifacts = discoverSourceArtifacts;
const file_system_1 = require("../file-system");
const models_1 = require("./models");
/**
 * Supported discovery roots per ecosystem.
 *
 * Mirrors the Python `_SUPPORTED_ROOTS` mapping. Each entry is a source-root
 * relative POSIX path that may be a file or a directory.
 */
const SUPPORTED_ROOTS = {
    [models_1.SourceEcosystem.GITHUB_COPILOT]: [
        ".github/copilot-instructions.md",
        ".github/instructions",
        ".github/skills",
        ".github/agents",
        ".github/prompts",
    ],
    [models_1.SourceEcosystem.CLAUDE]: [
        "CLAUDE.md",
        ".claude/skills",
        ".claude/agents",
        ".claude/hooks",
        ".claude/settings.json",
        ".claude/rules",
    ],
};
/**
 * Join two POSIX path fragments, collapsing redundant separators.
 *
 * @param root Base POSIX path.
 * @param relative Path relative to the base.
 * @returns The combined POSIX path.
 */
function joinPosix(root, relative) {
    const normalizedRoot = root.replace(/\/+$/, "");
    const normalizedRelative = relative.replace(/^\/+/, "");
    if (normalizedRoot === "") {
        return normalizedRelative;
    }
    if (normalizedRelative === "") {
        return normalizedRoot;
    }
    return `${normalizedRoot}/${normalizedRelative}`;
}
/**
 * Resolve `.` and `..` segments in a POSIX path without touching the
 * filesystem, mirroring `Path.resolve` segment collapsing for already-absolute
 * inputs.
 *
 * @param value POSIX path that may contain `.`/`..` segments.
 * @returns The path with relative segments collapsed.
 */
function collapseSegments(value) {
    const isAbsolute = value.startsWith("/");
    const driveMatch = /^([A-Za-z]:)(.*)$/.exec(value);
    const drive = driveMatch ? (driveMatch[1] ?? "") : "";
    const body = driveMatch ? (driveMatch[2] ?? "") : value;
    const segments = body.split("/");
    const resolved = [];
    // Walk each segment, dropping "." and popping the stack for "..".
    for (const segment of segments) {
        if (segment === "" || segment === ".") {
            continue;
        }
        if (segment === "..") {
            if (resolved.length > 0) {
                resolved.pop();
            }
            continue;
        }
        resolved.push(segment);
    }
    const joined = resolved.join("/");
    if (drive) {
        return `${drive}/${joined}`;
    }
    return isAbsolute ? `/${joined}` : joined;
}
/**
 * Determine whether a candidate path is absolute (POSIX or Windows drive).
 *
 * @param value Candidate path.
 * @returns True when the path is absolute.
 */
function isAbsolutePath(value) {
    return value.startsWith("/") || /^[A-Za-z]:/.test(value);
}
/**
 * Normalize one candidate path relative to the declared source root.
 *
 * Mirrors `_normalize_relative_path`: an absolute candidate is collapsed
 * directly; a relative candidate is joined under the source root first. The
 * result must be contained within the source root or an error is raised with
 * the identical message.
 *
 * @param sourceRoot POSIX source root.
 * @param candidatePath Caller-provided source path to validate.
 * @returns The normalized source-root-relative POSIX path.
 * @throws Error When the candidate path escapes the declared source root.
 */
function normalizeRelativePath(sourceRoot, candidatePath) {
    const resolvedRoot = collapseSegments((0, file_system_1.toPosixPath)(sourceRoot));
    const candidate = (0, file_system_1.toPosixPath)(candidatePath);
    const resolvedCandidate = isAbsolutePath(candidate)
        ? collapseSegments(candidate)
        : collapseSegments(joinPosix(resolvedRoot, candidate));
    const rootPrefix = `${resolvedRoot.replace(/\/+$/, "")}/`;
    if (resolvedCandidate === resolvedRoot) {
        return "";
    }
    if (!resolvedCandidate.startsWith(rootPrefix)) {
        throw new Error(`Selected path escapes the declared source root: ${candidatePath}`);
    }
    return resolvedCandidate.slice(rootPrefix.length);
}
/**
 * Normalize selected source paths beneath the declared source root.
 *
 * Mirrors `normalize_selected_paths`: deduplicates, validates each path, and
 * returns the unique normalized relative paths sorted by POSIX text.
 *
 * @param sourceRoot POSIX source root that bounds valid source input.
 * @param selectedPaths Caller-selected paths beneath the root.
 * @returns Unique normalized relative paths sorted by POSIX text.
 * @throws Error When any selected path escapes the declared source root.
 */
function normalizeSelectedPaths(sourceRoot, selectedPaths) {
    const normalized = new Set();
    // Validate and collect every selected path; a Set deduplicates collisions.
    for (const candidatePath of selectedPaths) {
        normalized.add(normalizeRelativePath(sourceRoot, candidatePath));
    }
    return [...normalized].sort((left, right) => left < right ? -1 : left > right ? 1 : 0);
}
/**
 * Recursively collect file paths beneath one absolute directory.
 *
 * @param fileSystem Injected filesystem.
 * @param absoluteDir Absolute POSIX directory to walk.
 * @param out Accumulator receiving discovered absolute file paths.
 */
function collectFilesRecursive(fileSystem, absoluteDir, out) {
    // Walk immediate children; recurse into directories and record files.
    for (const childName of fileSystem.listDirectory(absoluteDir)) {
        const childPath = joinPosix(absoluteDir, childName);
        if (fileSystem.isDirectory(childPath)) {
            collectFilesRecursive(fileSystem, childPath, out);
        }
        else if (fileSystem.isFile(childPath)) {
            out.push(childPath);
        }
    }
}
/**
 * Yield supported artifacts for one source ecosystem.
 *
 * Mirrors `_iter_supported_artifacts`: enumerates existing supported files
 * beneath the configured ecosystem roots and returns unique source-root
 * relative paths sorted by POSIX text.
 *
 * @param fileSystem Injected filesystem.
 * @param sourceRoot POSIX source tree root.
 * @param sourceEcosystem Ecosystem defining supported surfaces.
 * @returns Unique supported relative file paths beneath the source root.
 */
function iterSupportedArtifacts(fileSystem, sourceRoot, sourceEcosystem) {
    const resolvedRoot = collapseSegments((0, file_system_1.toPosixPath)(sourceRoot));
    const rootPrefix = `${resolvedRoot.replace(/\/+$/, "")}/`;
    const discovered = new Set();
    // Enumerate only the supported ecosystem surfaces so classification starts
    // from the approved input set.
    for (const supportedRoot of SUPPORTED_ROOTS[sourceEcosystem]) {
        const absoluteSupportedRoot = collapseSegments(joinPosix(resolvedRoot, supportedRoot));
        if (!fileSystem.exists(absoluteSupportedRoot)) {
            continue;
        }
        if (fileSystem.isFile(absoluteSupportedRoot)) {
            discovered.add(absoluteSupportedRoot.slice(rootPrefix.length));
            continue;
        }
        const files = [];
        collectFilesRecursive(fileSystem, absoluteSupportedRoot, files);
        // Record each discovered file as a source-root-relative path.
        for (const filePath of files) {
            discovered.add(filePath.slice(rootPrefix.length));
        }
    }
    return [...discovered].sort((left, right) => left < right ? -1 : left > right ? 1 : 0);
}
/**
 * Discover source artifacts in deterministic normalized-relative-path order.
 *
 * Mirrors `discover_source_artifacts`: enumerates supported artifacts, then
 * filters to caller-selected files and the files contained beneath selected
 * directories when a selection is provided.
 *
 * @param fileSystem Injected filesystem.
 * @param sourceRoot POSIX root directory of the source ecosystem tree.
 * @param sourceEcosystem Declared source ecosystem.
 * @param selectedPaths Optional caller-selected subset of files or directories.
 * @returns Supported source artifact paths relative to the source root, sorted
 *   by POSIX text.
 * @throws Error When selected paths escape the source root.
 */
function discoverSourceArtifacts(fileSystem, sourceRoot, sourceEcosystem, selectedPaths) {
    const allArtifacts = iterSupportedArtifacts(fileSystem, sourceRoot, sourceEcosystem);
    if (selectedPaths === undefined) {
        return allArtifacts;
    }
    const normalizedSelected = normalizeSelectedPaths(sourceRoot, selectedPaths);
    if (normalizedSelected.length === 0) {
        return allArtifacts;
    }
    const selectedSet = new Set(normalizedSelected);
    const matched = [];
    // Include files selected directly and files contained beneath selected
    // directories so callers can target either shape deterministically.
    for (const artifactPath of allArtifacts) {
        if (selectedSet.has(artifactPath)) {
            matched.push(artifactPath);
            continue;
        }
        if (isUnderSelectedDirectory(artifactPath, selectedSet)) {
            matched.push(artifactPath);
        }
    }
    return matched.sort((left, right) => left < right ? -1 : left > right ? 1 : 0);
}
/**
 * Determine whether an artifact path lies beneath any selected directory,
 * mirroring the Python `any(parent in artifact_path.parents ...)` check.
 *
 * @param artifactPath Source-root-relative artifact path.
 * @param selectedSet Normalized selected relative paths.
 * @returns True when any selected path is an ancestor directory of the artifact.
 */
function isUnderSelectedDirectory(artifactPath, selectedSet) {
    const segments = artifactPath.split("/");
    // Build each strict ancestor prefix and test membership against the set.
    for (let index = 1; index < segments.length; index += 1) {
        const ancestor = segments.slice(0, index).join("/");
        if (selectedSet.has(ancestor)) {
            return true;
        }
    }
    return false;
}
