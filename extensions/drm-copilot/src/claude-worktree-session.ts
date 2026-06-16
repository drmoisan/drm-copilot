/**
 * Pure helpers for assembling the Claude worktree session command that runs
 * in a VS Code integrated terminal.
 *
 * @remarks
 * This module must remain side-effect free and must not import vscode,
 * node:child_process, or node:fs. Keeping the helpers pure makes them
 * testable without a VS Code host process and preserves the separation
 * between command construction and the I/O boundary that opens a terminal.
 */

/**
 * Inputs required to build the PowerShell commands that the integrated
 * terminal sends through `Terminal.sendText`.
 */
export interface WorktreeSessionCommandInput {
  readonly repoRoot: string;
  readonly worktreePath: string;
  readonly branchName: string;
  readonly usePoetry: boolean;
  readonly objective: string | undefined;
  /**
   * Worktree-relative path to a PowerShell script to run immediately before
   * `claude`. When `undefined`, empty, or whitespace-only no pre-`claude`
   * command is emitted.
   */
  readonly preClaudeScriptPath: string | undefined;
}

/**
 * The ordered PowerShell commands that constitute a worktree session.
 *
 * @remarks
 * The handler must send these as separate `sendText` invocations so each
 * appears on its own PowerShell prompt and the user sees the output of
 * each step independently. The `poetryInstall` and `activate` commands are
 * present together when the workspace's `pyproject.toml` declares poetry,
 * and absent together when it does not (in which case there is no
 * environment to install or activate).
 */
export interface WorktreeSessionCommands {
  readonly git: string;
  readonly setLocation: string;
  readonly poetryInstall: string | undefined;
  readonly activate: string | undefined;
  /**
   * Guarded PowerShell command that runs the configured pre-`claude` script
   * only when it exists in the worktree. Present only when a non-empty script
   * path is supplied; `undefined` otherwise.
   */
  readonly preClaude: string | undefined;
  readonly claude: string;
}

/**
 * Formats a Date as the `yyyy-MM-dd-HH-mm` timestamp used by the worktree
 * session naming convention.
 *
 * @param date The instant to format. The local-time fields are used so the
 *             output matches the PowerShell `Get-WorktreeTimestamp` helper,
 *             which calls `[datetime]::Now`.
 * @returns A 16-character dash-separated string in `yyyy-MM-dd-HH-mm` format.
 */
export function formatWorktreeTimestamp(date: Date): string {
  const year = date.getFullYear().toString().padStart(4, "0");
  const month = (date.getMonth() + 1).toString().padStart(2, "0");
  const day = date.getDate().toString().padStart(2, "0");
  const hour = date.getHours().toString().padStart(2, "0");
  const minute = date.getMinutes().toString().padStart(2, "0");
  return `${year}-${month}-${day}-${hour}-${minute}`;
}

/**
 * Builds the absolute worktree directory path used for a session.
 *
 * @param workspaceParent Parent directory containing the new worktree.
 * @param timestamp A `yyyy-MM-dd-HH-mm` timestamp produced by
 *                  {@link formatWorktreeTimestamp}.
 * @param repoName Basename of the destination repository.
 * @returns The full forward-slash path to the worktree directory in
 *          `<parent>/<repoName>-wt-<timestamp>` format. The path uses forward
 *          slashes so it matches the PowerShell helper output and remains
 *          valid in `Set-Location`.
 */
export function buildWorktreePath(
  workspaceParent: string,
  timestamp: string,
  repoName: string,
): string {
  const normalizedParent = workspaceParent
    .replace(/\\/g, "/")
    .replace(/\/+$/, "");
  return `${normalizedParent}/${repoName}-wt-${timestamp}`;
}

/**
 * Builds the default branch name for a worktree session.
 *
 * @param timestamp A `yyyy-MM-dd-HH-mm` timestamp.
 * @param repoName Basename of the destination repository.
 * @returns A branch name in `<repoName>-wt-<timestamp>` format.
 */
export function buildBranchName(timestamp: string, repoName: string): string {
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
export function quoteForPwsh(value: string): string {
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
 * @returns The git/setLocation/poetryInstall/activate/claude commands as
 *          separate strings. Each is intended to be sent via its own
 *          `Terminal.sendText` call so it appears on its own PowerShell
 *          prompt. The poetryInstall and activate commands are both present
 *          when `usePoetry` is true and both undefined otherwise.
 */
export function buildWorktreeSessionCommands(
  input: WorktreeSessionCommandInput,
): WorktreeSessionCommands {
  const quotedRepoRoot = quoteForPwsh(input.repoRoot);
  const quotedPath = quoteForPwsh(input.worktreePath);
  const quotedBranch = quoteForPwsh(input.branchName);

  const trimmedObjective = input.objective?.trim() ?? "";
  const objectiveSuffix =
    trimmedObjective.length > 0 ? ` ${quoteForPwsh(trimmedObjective)}` : "";

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
  let preClaude: string | undefined;
  if (trimmedPreClaudePath.length > 0) {
    const quotedPreClaude = quoteForPwsh(trimmedPreClaudePath);
    preClaude = `if (Test-Path -LiteralPath ${quotedPreClaude}) { & ${quotedPreClaude} }`;
  } else {
    preClaude = undefined;
  }

  return {
    git: `git -C ${quotedRepoRoot} worktree add ${quotedPath} -b ${quotedBranch}`,
    setLocation: `Set-Location ${quotedPath}`,
    poetryInstall,
    activate,
    preClaude,
    claude: `claude --dangerously-skip-permissions${objectiveSuffix}`,
  };
}
