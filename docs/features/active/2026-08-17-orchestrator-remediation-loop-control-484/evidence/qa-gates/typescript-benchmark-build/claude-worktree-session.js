"use strict";
/**
 * Pure helpers for assembling the Claude worktree session command that runs
 * in a VS Code integrated terminal.
 *
 * @remarks
 * This module must remain side-effect free and must not import vscode,
 * node:child_process, or node:fs. Keeping the helpers pure makes them
 * testable without a VS Code host process and preserves the separation
 * between command construction and the I/O boundary that opens a terminal.
 *
 * Under the nested worktree scheme a worktree is created at
 * `<parent>/<repoName>-wt/<yyyy-MM-ddTHH-mm>`: a single `<repoName>-wt`
 * grouping directory holds every timestamped worktree for the repo. The
 * `ensureParentDirectory` command creates that grouping directory idempotently
 * before `git worktree add` runs. The branch name remains flat
 * (`<repoName>-wt-<timestamp>`); only the on-disk path is nested.
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.formatWorktreeTimestamp = formatWorktreeTimestamp;
exports.buildWorktreeGroupDirectory = buildWorktreeGroupDirectory;
exports.deriveWorktreeGroupDirectory = deriveWorktreeGroupDirectory;
exports.buildWorktreePath = buildWorktreePath;
exports.buildBranchName = buildBranchName;
exports.quoteForPwsh = quoteForPwsh;
exports.buildWorktreeSessionCommands = buildWorktreeSessionCommands;
/**
 * Formats a Date as the `yyyy-MM-ddTHH-mm` timestamp used by the worktree
 * session naming convention.
 *
 * @param date The instant to format. The local-time fields are used so the
 *             output matches the PowerShell `Get-WorktreeTimestamp` helper,
 *             which calls `[datetime]::Now`.
 * @returns A 16-character string in `yyyy-MM-ddTHH-mm` format (literal `T`
 *          between the date and 24-hour time components).
 */
function formatWorktreeTimestamp(date) {
    const year = date.getFullYear().toString().padStart(4, "0");
    const month = (date.getMonth() + 1).toString().padStart(2, "0");
    const day = date.getDate().toString().padStart(2, "0");
    const hour = date.getHours().toString().padStart(2, "0");
    const minute = date.getMinutes().toString().padStart(2, "0");
    return `${year}-${month}-${day}T${hour}-${minute}`;
}
/**
 * Builds the per-repository grouping directory that holds every timestamped
 * worktree for a repo under the nested scheme.
 *
 * @param workspaceParent Parent directory containing the grouping directory.
 * @param repoName Basename of the destination repository.
 * @returns The forward-slash grouping-directory path in
 *          `<parent>/<repoName>-wt` format. This is the single shared helper
 *          used by {@link buildWorktreePath} so the worktree path and the
 *          parent-directory guard cannot drift.
 */
function buildWorktreeGroupDirectory(workspaceParent, repoName) {
    const normalizedParent = workspaceParent
        .replace(/\\/g, "/")
        .replace(/\/+$/, "");
    return `${normalizedParent}/${repoName}-wt`;
}
/**
 * Derives the grouping directory (the parent) of an already-built nested
 * worktree path by stripping its timestamp leaf segment.
 *
 * @param worktreePath A nested worktree path produced by
 *                     {@link buildWorktreePath}
 *                     (`<parent>/<repoName>-wt/<timestamp>`).
 * @returns The forward-slash grouping directory `<parent>/<repoName>-wt`. The
 *          derivation reads the path directly, so the emitted parent-directory
 *          guard is always the leading segment of the worktree path and cannot
 *          drift from it.
 */
function deriveWorktreeGroupDirectory(worktreePath) {
    const normalized = worktreePath.replace(/\\/g, "/").replace(/\/+$/, "");
    const lastSlash = normalized.lastIndexOf("/");
    return lastSlash > 0 ? normalized.slice(0, lastSlash) : normalized;
}
/**
 * Builds the absolute worktree directory path used for a session.
 *
 * @param workspaceParent Parent directory containing the new worktree.
 * @param timestamp A `yyyy-MM-ddTHH-mm` timestamp produced by
 *                  {@link formatWorktreeTimestamp}.
 * @param repoName Basename of the destination repository.
 * @returns The full forward-slash path to the worktree directory in
 *          `<parent>/<repoName>-wt/<timestamp>` (nested) format. The path uses
 *          forward slashes so it matches the PowerShell helper output and
 *          remains valid in `Set-Location`. The grouping directory is derived
 *          from {@link buildWorktreeGroupDirectory}.
 */
function buildWorktreePath(workspaceParent, timestamp, repoName) {
    return `${buildWorktreeGroupDirectory(workspaceParent, repoName)}/${timestamp}`;
}
/**
 * Builds the default branch name for a worktree session.
 *
 * @param timestamp A `yyyy-MM-ddTHH-mm` timestamp.
 * @param repoName Basename of the destination repository.
 * @returns A flat branch name in `<repoName>-wt-<timestamp>` format. The branch
 *          is never nested with a slash even though the on-disk worktree path
 *          is nested.
 */
function buildBranchName(timestamp, repoName) {
    return `${repoName}-wt-${timestamp}`;
}
/**
 * Wraps a value in PowerShell single quotes, doubling embedded single quotes
 * to preserve them as literal characters.
 *
 * @param value Arbitrary text that must be embedded inside a PowerShell
 *              single-quoted literal.
 * @returns A PowerShell single-quoted literal that evaluates back to the
 *          original `value`. Empty strings produce `''`.
 *
 * @remarks
 * Single-quoted literals are used because PowerShell does not perform
 * variable expansion or escape processing inside them, except that two
 * single quotes within a literal represent one literal single quote. Doubling
 * the embedded apostrophes is therefore the only escape required.
 */
function quoteForPwsh(value) {
    const escaped = value.replace(/'/g, "''");
    return `'${escaped}'`;
}
/**
 * Builds the ordered PowerShell commands that the integrated terminal sends
 * to create the worktree, navigate into it, install dependencies via poetry
 * (when the workspace uses poetry), activate the resulting in-project venv,
 * and start an interactive Claude CLI session.
 *
 * @param input The repository root, resolved worktree path, branch name,
 *              poetry flag, and optional objective.
 * @returns The ensureParentDirectory/git/setLocation/poetryInstall/activate/
 *          claude commands as separate strings. Each is intended to be sent via
 *          its own
 *          `Terminal.sendText` call so it appears on its own PowerShell
 *          prompt. The poetryInstall and activate commands are both present
 *          when `usePoetry` is true and both undefined otherwise.
 */
function buildWorktreeSessionCommands(input) {
    const quotedRepoRoot = quoteForPwsh(input.repoRoot);
    const quotedPath = quoteForPwsh(input.worktreePath);
    const quotedBranch = quoteForPwsh(input.branchName);
    // Derive the grouping directory directly from the nested worktree path so the
    // guard can never target a different directory than the one the worktree is
    // created under. `-Force` makes creation idempotent and creates any missing
    // leading directories.
    const groupDirectory = deriveWorktreeGroupDirectory(input.worktreePath);
    const ensureParentDirectory = `New-Item -ItemType Directory -Force -Path ${quoteForPwsh(groupDirectory)} | Out-Null`;
    const trimmedObjective = input.objective?.trim() ?? "";
    const objectiveSuffix = trimmedObjective.length > 0 ? ` ${quoteForPwsh(trimmedObjective)}` : "";
    // The poetry-managed venv is created in the worktree under .venv after
    // `poetry install`. We Set-Location into the worktree before this step so
    // the relative './.venv/Scripts/Activate.ps1' resolves correctly.
    const poetryInstall = input.usePoetry
        ? "poetry install --with dev"
        : undefined;
    const activate = input.usePoetry
        ? "& './.venv/Scripts/Activate.ps1'"
        : undefined;
    // Guard the pre-`claude` script behind a runtime Test-Path so a missing
    // script at the configured path does not cause an error. The path is
    // embedded with the single-quote escaping helper so spaces and apostrophes
    // are preserved literally. An undefined/empty/whitespace path yields no
    // command.
    const trimmedPreClaudePath = input.preClaudeScriptPath?.trim() ?? "";
    let preClaude;
    if (trimmedPreClaudePath.length > 0) {
        const quotedPreClaude = quoteForPwsh(trimmedPreClaudePath);
        preClaude = `if (Test-Path -LiteralPath ${quotedPreClaude}) { & ${quotedPreClaude} }`;
    }
    else {
        preClaude = undefined;
    }
    return {
        ensureParentDirectory,
        git: `git -C ${quotedRepoRoot} worktree add ${quotedPath} -b ${quotedBranch}`,
        setLocation: `Set-Location ${quotedPath}`,
        poetryInstall,
        activate,
        preClaude,
        claude: `claude --dangerously-skip-permissions${objectiveSuffix}`,
    };
}
