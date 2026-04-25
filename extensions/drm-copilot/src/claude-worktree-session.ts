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
 * Inputs required to build the PowerShell command line that the integrated
 * terminal sends through `Terminal.sendText`.
 */
export interface WorktreeSessionCommandInput {
  readonly repoRoot: string;
  readonly worktreePath: string;
  readonly branchName: string;
  readonly objective: string | undefined;
}

/**
 * Formats a Date as the `yyyyMMddHHmmss` timestamp used by the worktree
 * session naming convention.
 *
 * @param date The instant to format. The local-time fields are used so the
 *             output matches the PowerShell `Get-WorktreeTimestamp` helper,
 *             which calls `[datetime]::Now`.
 * @returns A 14-character string composed of zero-padded calendar fields.
 */
export function formatWorktreeTimestamp(date: Date): string {
  const year = date.getFullYear().toString().padStart(4, "0");
  const month = (date.getMonth() + 1).toString().padStart(2, "0");
  const day = date.getDate().toString().padStart(2, "0");
  const hour = date.getHours().toString().padStart(2, "0");
  const minute = date.getMinutes().toString().padStart(2, "0");
  const second = date.getSeconds().toString().padStart(2, "0");
  return `${year}${month}${day}${hour}${minute}${second}`;
}

/**
 * Builds the absolute worktree directory path used for a session.
 *
 * @param workspaceParent Parent directory containing the new worktree.
 * @param timestamp A `yyyyMMddHHmmss` timestamp produced by
 *                  {@link formatWorktreeTimestamp}.
 * @param shortName Kebab-case short identifier supplied by the user.
 * @returns The full forward-slash path to the worktree directory. The path
 *          uses forward slashes so it matches the PowerShell helper output
 *          and remains valid in `Set-Location`.
 */
export function buildWorktreePath(
  workspaceParent: string,
  timestamp: string,
  shortName: string,
): string {
  const normalizedParent = workspaceParent
    .replace(/\\/g, "/")
    .replace(/\/+$/, "");
  return `${normalizedParent}/drm-copilot-wt-${timestamp}-${shortName}`;
}

/**
 * Builds the default branch name for a worktree session.
 *
 * @param timestamp A `yyyyMMddHHmmss` timestamp.
 * @param shortName Kebab-case short identifier supplied by the user.
 * @returns The conventional `feature/<timestamp>-<shortName>` branch name.
 */
export function buildBranchName(timestamp: string, shortName: string): string {
  return `feature/${timestamp}-${shortName}`;
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
 * Builds the PowerShell command line that creates the worktree, navigates
 * into it, and starts an interactive Claude CLI session.
 *
 * @param input The repository root, resolved worktree path, branch name, and
 *              optional objective text.
 * @returns A single-line PowerShell command suitable for `Terminal.sendText`.
 *          The command uses `git -C <repoRoot>` so it works regardless of
 *          the terminal's current working directory, and short-circuits the
 *          Claude launch when `git worktree add` exits non-zero so the user
 *          sees the failure rather than an unrelated downstream error.
 */
export function buildWorktreeSessionCommand(
  input: WorktreeSessionCommandInput,
): string {
  const quotedRepoRoot = quoteForPwsh(input.repoRoot);
  const quotedPath = quoteForPwsh(input.worktreePath);
  const quotedBranch = quoteForPwsh(input.branchName);

  const trimmedObjective = input.objective?.trim() ?? "";
  const objectiveSuffix =
    trimmedObjective.length > 0 ? ` ${quoteForPwsh(trimmedObjective)}` : "";

  return (
    `git -C ${quotedRepoRoot} worktree add ${quotedPath} -b ${quotedBranch};` +
    ` if ($LASTEXITCODE -eq 0) {` +
    ` Set-Location ${quotedPath};` +
    ` claude --dangerously-skip-permissions${objectiveSuffix}` +
    ` }`
  );
}
