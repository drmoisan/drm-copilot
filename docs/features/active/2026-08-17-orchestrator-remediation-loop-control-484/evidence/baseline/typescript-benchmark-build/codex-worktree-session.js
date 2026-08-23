"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.buildCodexTrustCommand = buildCodexTrustCommand;
exports.buildCodexWorktreeSessionCommands = buildCodexWorktreeSessionCommands;
const claude_worktree_session_1 = require("./claude-worktree-session");
/**
 * Builds a PowerShell command that adds the resolved worktree path to the
 * user-level Codex trust configuration before project-local `.codex` settings
 * are loaded by the Codex CLI.
 *
 * @param worktreePath The worktree path created by the preceding git command.
 * @returns A single PowerShell command string suitable for Terminal.sendText.
 */
function buildCodexTrustCommand(worktreePath) {
    const quotedPath = (0, claude_worktree_session_1.quoteForPwsh)(worktreePath);
    return [
        "$codexConfig = Join-Path $HOME '.codex/config.toml'",
        "New-Item -ItemType Directory -Force -Path (Split-Path -Parent $codexConfig) | Out-Null",
        `if (-not (Test-Path -LiteralPath ${quotedPath})) { throw "Codex trust target does not exist: ${worktreePath.replace(/"/g, '`"')}" }`,
        `$trustedPath = (Resolve-Path -LiteralPath ${quotedPath}).Path`,
        '$escapedPath = $trustedPath -replace "\'", "\'\'"',
        "$header = \"[projects.'$escapedPath']\"",
        `$trustedLine = 'trust_level = "trusted"'`,
        "if (-not (Test-Path -LiteralPath $codexConfig)) { Set-Content -LiteralPath $codexConfig -Value '' }",
        "$content = Get-Content -Raw -LiteralPath $codexConfig",
        "$sectionPattern = '(?s)' + [regex]::Escape($header) + '(?<body>.*?)(?:\\r?\\n\\[|$)'",
        "$sectionMatch = [regex]::Match($content, $sectionPattern)",
        'if (-not $sectionMatch.Success) { Add-Content -LiteralPath $codexConfig -Value "`r`n$header`r`n$trustedLine" } elseif ($sectionMatch.Groups[\'body\'].Value -notmatch \'trust_level\\s*=\\s*\\"trusted\\"\') { throw "Codex project trust entry exists but is not trusted: $trustedPath" }',
    ].join("; ");
}
/**
 * Builds the ordered terminal commands that create the worktree, mark it as a
 * trusted Codex project, run optional setup, and start Codex.
 *
 * @param input The repository root, destination worktree path, branch name,
 *              poetry flag, optional objective, and optional post script path.
 * @returns The commands to send as separate terminal lines.
 */
function buildCodexWorktreeSessionCommands(input) {
    const quotedRepoRoot = (0, claude_worktree_session_1.quoteForPwsh)(input.repoRoot);
    const quotedPath = (0, claude_worktree_session_1.quoteForPwsh)(input.worktreePath);
    const quotedBranch = (0, claude_worktree_session_1.quoteForPwsh)(input.branchName);
    // Derive the grouping directory from the pre-built nested worktree path using
    // the shared helper so the Codex guard matches the worktree path exactly.
    const groupDirectory = (0, claude_worktree_session_1.deriveWorktreeGroupDirectory)(input.worktreePath);
    const ensureParentDirectory = `New-Item -ItemType Directory -Force -Path ${(0, claude_worktree_session_1.quoteForPwsh)(groupDirectory)} | Out-Null`;
    const trimmedObjective = input.objective?.trim() ?? "";
    const objectiveSuffix = trimmedObjective.length > 0 ? ` ${(0, claude_worktree_session_1.quoteForPwsh)(trimmedObjective)}` : "";
    const codexCommand = `& ${(0, claude_worktree_session_1.quoteForPwsh)(input.codexExecutablePath)}${objectiveSuffix}`;
    const poetryInstall = input.usePoetry
        ? "poetry install --with dev"
        : undefined;
    const activate = input.usePoetry
        ? "& './.venv/Scripts/Activate.ps1'"
        : undefined;
    const trimmedPostCodexPath = input.postCodexScriptPath?.trim() ?? "";
    const postCodex = trimmedPostCodexPath.length > 0
        ? `if (Test-Path -LiteralPath ${(0, claude_worktree_session_1.quoteForPwsh)(trimmedPostCodexPath)}) { & ${(0, claude_worktree_session_1.quoteForPwsh)(trimmedPostCodexPath)} -SourceRoot ${quotedRepoRoot} -WorktreeRoot ${quotedPath} }`
        : undefined;
    return {
        ensureParentDirectory,
        git: `git -C ${quotedRepoRoot} worktree add ${quotedPath} -b ${quotedBranch}`,
        setLocation: `Set-Location ${quotedPath}`,
        trustCodexProject: buildCodexTrustCommand(input.worktreePath),
        poetryInstall,
        activate,
        postCodex,
        codex: codexCommand,
    };
}
