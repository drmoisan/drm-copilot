"use strict";
/**
 * Pure variable-resolution helpers for the atomic-plan prompt resolver.
 *
 * Purpose:
 *     Port the substitution logic of `resolve_file_prompt.py` (identical between
 *     the repo-root and bundled variants) into host-neutral, injectable
 *     TypeScript. These helpers carry the bulk of the resolver so the
 *     orchestrator (`file-prompt-core.ts`) stays small. All file existence
 *     checks flow through the injected {@link FileSystem}; there is no direct
 *     `node:fs` use here.
 *
 * Responsibilities:
 *     - Front-matter stripping.
 *     - Platform-agnostic path splitting and workspace-relative resolution.
 *     - Resolution of `${file}`, `${folderpath}`, `${name}`, `${spec}`,
 *       `${user-story}`, `${research}`, `${work-mode}`, `${fallback-reason}`.
 *     - Line-removal / heading-insertion / minor-audit override transforms.
 *     - Deterministic `${...}` substitution with an unresolved-placeholder
 *       safety check.
 *
 * Parity:
 *     Error messages, placeholder strings, and the minor-audit override block
 *     are byte-identical to the Python source.
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.replaceAllVariables = exports.removeUserStoryClauseWhenMissing = exports.removeLinesReferencingVariable = exports.insertAfterHeading = exports.extractTemplateVariables = exports.applyMinorAuditOverrides = void 0;
exports.stripFrontMatter = stripFrontMatter;
exports.splitPathPlatformAgnostic = splitPathPlatformAgnostic;
exports.tryRelativeToWorkspace = tryRelativeToWorkspace;
exports.resolveFolderpath = resolveFolderpath;
exports.resolveFeatureFoldername = resolveFeatureFoldername;
exports.resolveNameFromFeatureFoldername = resolveNameFromFeatureFoldername;
exports.resolveSpecPath = resolveSpecPath;
exports.resolveUserStoryValue = resolveUserStoryValue;
exports.resolveResearchValue = resolveResearchValue;
exports.resolveWorkModeFromIssue = resolveWorkModeFromIssue;
const file_system_1 = require("../file-system");
const prompt_mode_contract_1 = require("../prompt-mode-contract");
// Re-export the template-text transforms so consumers can import the full
// variable-resolution surface from this module. The transforms live in a
// sibling file to keep each module within the 500-line limit.
var file_prompt_transforms_1 = require("./file-prompt-transforms");
Object.defineProperty(exports, "applyMinorAuditOverrides", { enumerable: true, get: function () { return file_prompt_transforms_1.applyMinorAuditOverrides; } });
Object.defineProperty(exports, "extractTemplateVariables", { enumerable: true, get: function () { return file_prompt_transforms_1.extractTemplateVariables; } });
Object.defineProperty(exports, "insertAfterHeading", { enumerable: true, get: function () { return file_prompt_transforms_1.insertAfterHeading; } });
Object.defineProperty(exports, "removeLinesReferencingVariable", { enumerable: true, get: function () { return file_prompt_transforms_1.removeLinesReferencingVariable; } });
Object.defineProperty(exports, "removeUserStoryClauseWhenMissing", { enumerable: true, get: function () { return file_prompt_transforms_1.removeUserStoryClauseWhenMissing; } });
Object.defineProperty(exports, "replaceAllVariables", { enumerable: true, get: function () { return file_prompt_transforms_1.replaceAllVariables; } });
/**
 * Remove a leading YAML front-matter block when present.
 *
 * Mirrors Python `strip_front_matter`: when the first non-empty line (after
 * trimming) is exactly `---`, drop everything through the next `---` delimiter
 * and left-strip the remainder. Content without a leading front-matter block is
 * returned unchanged.
 *
 * @param content Raw template content.
 * @returns Content with any leading front-matter block removed.
 */
function stripFrontMatter(content) {
    const lines = content.split("\n");
    if (lines.length === 0 || (lines[0] ?? "").trim() !== "---") {
        return content;
    }
    // Scan for the closing `---` delimiter, then return the left-stripped tail.
    for (let index = 1; index < lines.length; index += 1) {
        if ((lines[index] ?? "").trim() === "---") {
            return lines
                .slice(index + 1)
                .join("\n")
                .replace(/^\s+/, "");
        }
    }
    return content;
}
/**
 * Split a path string on either separator, dropping empty segments.
 *
 * Mirrors Python `_split_path_platform_agnostic` (`re.split(r"[\\/]+", ...)`).
 *
 * @param pathStr Path string using either Windows or POSIX separators.
 * @returns Non-empty path components in order.
 */
function splitPathPlatformAgnostic(pathStr) {
    return pathStr.split(/[\\/]+/).filter((part) => part.length > 0);
}
/**
 * Return the workspace-relative path when the target sits under the workspace,
 * else the original path.
 *
 * Mirrors Python `_try_relative_to_workspace`
 * (`path.resolve().relative_to(workspace_root.resolve())`). Inputs are
 * normalized to forward slashes so the computation is deterministic and host
 * neutral; no disk access occurs. When `path` is not under `workspaceRoot`, the
 * original (POSIX-normalized) path is returned, matching the Python
 * `ValueError` fallback.
 *
 * @param path Target path (absolute or relative).
 * @param workspaceRoot Workspace root the target is resolved against.
 * @returns The workspace-relative POSIX path, or the original POSIX path.
 */
function tryRelativeToWorkspace(path, workspaceRoot) {
    const normalizedPath = (0, file_system_1.toPosixPath)(path).replace(/\/+$/, "");
    const normalizedRoot = (0, file_system_1.toPosixPath)(workspaceRoot).replace(/\/+$/, "");
    if (normalizedPath === normalizedRoot) {
        return "";
    }
    const rootPrefix = `${normalizedRoot}/`;
    if (normalizedPath.startsWith(rootPrefix)) {
        return normalizedPath.slice(rootPrefix.length);
    }
    // Target is outside the workspace; fall back to the original path verbatim.
    return normalizedPath;
}
/**
 * Resolve `${folderpath}` as the workspace-relative parent of the target.
 *
 * Mirrors Python `_resolve_folderpath`: `str(relative_target.parent)`. The
 * result is the parent directory of the workspace-relative target, or `.` when
 * the relative target has no parent (matching `Path.parent` of a bare name).
 *
 * @param targetPath Target file path.
 * @param workspaceRoot Workspace root used for relative resolution.
 * @returns Workspace-relative folder path of the target.
 */
function resolveFolderpath(targetPath, workspaceRoot) {
    const relative = tryRelativeToWorkspace(targetPath, workspaceRoot);
    const lastSlash = relative.lastIndexOf("/");
    if (lastSlash === -1) {
        // A bare filename has parent `.`, matching Python `Path("x").parent`.
        return ".";
    }
    return relative.slice(0, lastSlash);
}
/**
 * Resolve the logical feature folder name from `${folderpath}`.
 *
 * Mirrors Python `_resolve_feature_foldername`: a leaf folder starting with `v`
 * (when at least two components exist) is treated as a versioned plan folder and
 * the parent component is used; otherwise the leaf is used.
 *
 * @param folderpath Workspace-relative folder path.
 * @returns The feature folder name.
 * @throws Error When `folderpath` has no components (mirrors Python
 *   `ValueError("folderpath is empty")`).
 */
function resolveFeatureFoldername(folderpath) {
    const parts = splitPathPlatformAgnostic(folderpath);
    if (parts.length === 0) {
        throw new Error("folderpath is empty");
    }
    const leaf = parts[parts.length - 1] ?? "";
    // Versioned plan folders (e.g. `v2`) defer to their parent feature folder.
    if (leaf.startsWith("v") && parts.length >= 2) {
        return parts[parts.length - 2] ?? leaf;
    }
    return leaf;
}
/**
 * Extract `${name}` from a dated feature-folder name.
 *
 * Mirrors Python `_resolve_name_from_feature_foldername`: the convention is
 * `yyyy-MM-dd-${name}-${issue}` where `${name}` may contain hyphens. When the
 * name matches the date prefix and trailing numeric issue token, the middle
 * segment is returned; otherwise the whole folder name is returned.
 *
 * @param featureFoldername Feature folder name.
 * @returns The extracted name, or the original folder name.
 */
function resolveNameFromFeatureFoldername(featureFoldername) {
    const parts = featureFoldername.split("-");
    // Decision logic mirrors the Python guards: a 4-2-2 date prefix plus a
    // trailing all-digit issue token marks a dated feature folder.
    if (parts.length >= 5 &&
        (parts[0] ?? "").length === 4 &&
        (parts[1] ?? "").length === 2 &&
        (parts[2] ?? "").length === 2 &&
        isAllDigits(parts[0] ?? "") &&
        isAllDigits(parts[1] ?? "") &&
        isAllDigits(parts[2] ?? "") &&
        isAllDigits(parts[parts.length - 1] ?? "")) {
        const nameParts = parts.slice(3, parts.length - 1);
        if (nameParts.length > 0) {
            return nameParts.join("-");
        }
    }
    return featureFoldername;
}
/**
 * Test whether a string is non-empty and contains only ASCII digits.
 *
 * Mirrors Python `str.isdigit()` for the date/issue-token guards used by
 * {@link resolveNameFromFeatureFoldername}.
 *
 * @param value Candidate string.
 * @returns True when `value` is non-empty and all characters are `0`-`9`.
 */
function isAllDigits(value) {
    return value.length > 0 && /^[0-9]+$/.test(value);
}
/**
 * Resolve `${spec}` to `${folderpath}/spec.md`.
 *
 * Mirrors Python `_resolve_spec_path`. The path is joined with forward slashes
 * for deterministic, host-neutral output.
 *
 * @param folderpath Workspace-relative folder path.
 * @returns The spec path string.
 */
function resolveSpecPath(folderpath) {
    return joinFolder(folderpath, "spec.md");
}
/**
 * Resolve `${user-story}`, annotating it when the file is missing.
 *
 * Mirrors Python `_resolve_user_story_value`: returns the workspace-relative
 * `user-story.md` path when present (via {@link FileSystem.isFile}); otherwise
 * returns `<path> (missing)`.
 *
 * @param folderpath Workspace-relative folder path.
 * @param workspaceRoot Workspace root used for the existence check.
 * @param fs Injected filesystem for the existence check.
 * @returns The user-story path string, annotated when missing.
 */
function resolveUserStoryValue(folderpath, workspaceRoot, fs) {
    const relativeStory = joinFolder(folderpath, "user-story.md");
    const fullStory = joinFolder((0, file_system_1.toPosixPath)(workspaceRoot), relativeStory);
    if (fs.isFile(fullStory)) {
        return relativeStory;
    }
    return `${relativeStory} (missing)`;
}
/**
 * Resolve `${research}` when `research.md` exists, else null.
 *
 * Mirrors Python `_resolve_research_value`.
 *
 * @param folderpath Workspace-relative folder path.
 * @param workspaceRoot Workspace root used for the existence check.
 * @param fs Injected filesystem for the existence check.
 * @returns The research path string when present, otherwise null.
 */
function resolveResearchValue(folderpath, workspaceRoot, fs) {
    const relativeResearch = joinFolder(folderpath, "research.md");
    const fullResearch = joinFolder((0, file_system_1.toPosixPath)(workspaceRoot), relativeResearch);
    if (fs.isFile(fullResearch)) {
        return relativeResearch;
    }
    return null;
}
/**
 * Join a folder path and a leaf using forward slashes.
 *
 * Mirrors Python `Path(folderpath) / leaf` for the host-neutral string output
 * used by this resolver. A `.` folder yields just the leaf, matching
 * `Path(".") / "x" == Path("x")`.
 *
 * @param folder Folder path.
 * @param leaf Trailing path component.
 * @returns The joined POSIX path.
 */
function joinFolder(folder, leaf) {
    const normalizedFolder = (0, file_system_1.toPosixPath)(folder).replace(/\/+$/, "");
    if (normalizedFolder === "" || normalizedFolder === ".") {
        return leaf;
    }
    return `${normalizedFolder}/${leaf}`;
}
/**
 * Resolve `${work-mode}` and `${fallback-reason}` from `issue.md`.
 *
 * Mirrors Python `_resolve_work_mode_from_issue` (file-prompt variant): reads
 * `<folderpath>/issue.md` through the injected filesystem. When the file is
 * absent, `resolveSelectedWorkMode(null)` / `buildFallbackReason(null)` are
 * used; when the read fails, mode `full-feature` and the fixed reason
 * `issue.md unreadable; fail closed to full-feature` are used; otherwise the
 * file content drives both values.
 *
 * @param folderpath Workspace-relative feature folder path.
 * @param workspaceRoot Workspace root used for file resolution.
 * @param fs Injected filesystem for existence and read.
 * @returns The resolved work-mode and fallback reason.
 */
function resolveWorkModeFromIssue(folderpath, workspaceRoot, fs) {
    const issuePath = joinFolder(joinFolder((0, file_system_1.toPosixPath)(workspaceRoot), folderpath), "issue.md");
    if (!fs.isFile(issuePath)) {
        return {
            mode: (0, prompt_mode_contract_1.resolveSelectedWorkMode)(null),
            fallbackReason: (0, prompt_mode_contract_1.buildFallbackReason)(null),
        };
    }
    let issueContent;
    try {
        issueContent = fs.readTextFile(issuePath);
    }
    catch {
        // A present-but-unreadable issue file fails closed with a fixed reason,
        // matching the Python OSError branch.
        return {
            mode: (0, prompt_mode_contract_1.resolveSelectedWorkMode)(null),
            fallbackReason: "issue.md unreadable; fail closed to full-feature",
        };
    }
    return {
        mode: (0, prompt_mode_contract_1.resolveSelectedWorkMode)(issueContent),
        fallbackReason: (0, prompt_mode_contract_1.buildFallbackReason)(issueContent),
    };
}
