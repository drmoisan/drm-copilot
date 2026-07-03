import { quoteForPwsh } from "./claude-worktree-session";

/**
 * Inputs required to build the PowerShell commands that start a Codex worktree
 * session in a VS Code integrated terminal.
 */
export interface CodexWorktreeSessionCommandInput {
  readonly repoRoot: string;
  readonly worktreePath: string;
  readonly branchName: string;
  readonly usePoetry: boolean;
  readonly objective: string | undefined;
  readonly codexExecutablePath: string;
  /**
   * Source-root-resolved PowerShell script path to run after Codex trust has been
   * written and before the Codex CLI starts. Empty values emit no post command.
   */
  readonly postCodexScriptPath: string | undefined;
}

/**
 * Ordered PowerShell commands that constitute a Codex worktree session.
 */
export interface CodexWorktreeSessionCommands {
  readonly git: string;
  readonly setLocation: string;
  readonly trustCodexProject: string;
  readonly poetryInstall: string | undefined;
  readonly activate: string | undefined;
  readonly postCodex: string | undefined;
  readonly codex: string;
}

/**
 * Builds a PowerShell command that adds the resolved worktree path to the
 * user-level Codex trust configuration before project-local `.codex` settings
 * are loaded by the Codex CLI.
 *
 * @param worktreePath The worktree path created by the preceding git command.
 * @returns A single PowerShell command string suitable for Terminal.sendText.
 */
export function buildCodexTrustCommand(worktreePath: string): string {
  const quotedPath = quoteForPwsh(worktreePath);
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
export function buildCodexWorktreeSessionCommands(
  input: CodexWorktreeSessionCommandInput,
): CodexWorktreeSessionCommands {
  const quotedRepoRoot = quoteForPwsh(input.repoRoot);
  const quotedPath = quoteForPwsh(input.worktreePath);
  const quotedBranch = quoteForPwsh(input.branchName);

  const trimmedObjective = input.objective?.trim() ?? "";
  const objectiveSuffix =
    trimmedObjective.length > 0 ? ` ${quoteForPwsh(trimmedObjective)}` : "";
  const codexCommand = `& ${quoteForPwsh(input.codexExecutablePath)}${objectiveSuffix}`;

  const poetryInstall = input.usePoetry
    ? "poetry install --with dev"
    : undefined;
  const activate = input.usePoetry
    ? "& './.venv/Scripts/Activate.ps1'"
    : undefined;

  const trimmedPostCodexPath = input.postCodexScriptPath?.trim() ?? "";
  const postCodex =
    trimmedPostCodexPath.length > 0
      ? `if (Test-Path -LiteralPath ${quoteForPwsh(trimmedPostCodexPath)}) { & ${quoteForPwsh(trimmedPostCodexPath)} -SourceRoot ${quotedRepoRoot} -WorktreeRoot ${quotedPath} }`
      : undefined;

  return {
    git: `git -C ${quotedRepoRoot} worktree add ${quotedPath} -b ${quotedBranch}`,
    setLocation: `Set-Location ${quotedPath}`,
    trustCodexProject: buildCodexTrustCommand(input.worktreePath),
    poetryInstall,
    activate,
    postCodex,
    codex: codexCommand,
  };
}
