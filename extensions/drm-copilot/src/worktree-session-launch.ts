/**
 * Pure helpers that compose a worktree session (Claude or Codex) into one
 * PowerShell script and deliver it at process start through
 * `-EncodedCommand`.
 *
 * @remarks
 * Delivering the whole session as a process argument removes every write to
 * the terminal input stream, so the session does not depend on when the shell
 * starts reading input or on how a Linux pty in cooked mode translates Enter.
 * The composed script is valid on pwsh 7 and Windows PowerShell 5.1: it uses
 * no `&&`/`||` pipeline-chain operators, no `$IsWindows`, and no block-wide
 * `$ErrorActionPreference`.
 *
 * This module must remain side-effect free and must not import vscode,
 * node:fs, or node:child_process. `Buffer` is a Node global.
 */

import type { WorktreeSessionCommands } from "./claude-worktree-session";
import type { CodexWorktreeSessionCommands } from "./codex-worktree-session";

/**
 * Maximum length, in characters, of the base64 `-EncodedCommand` argument.
 *
 * @remarks
 * Windows `CreateProcess` limits a command line to 32,767 characters and the
 * user-supplied objective is embedded in the script, so the encoded argument
 * is bounded below that limit with room for the executable path and switches.
 */
export const MAX_ENCODED_COMMAND_LENGTH = 30000;

/** Statement that fails the guarded setup block when `git worktree add` fails. */
const GIT_EXIT_CODE_GUARD =
  "if ($LASTEXITCODE -ne 0) { throw ('git worktree add failed with exit code ' + $LASTEXITCODE) }";

/** Statement that fails the guarded setup block when `poetry install` fails. */
const POETRY_EXIT_CODE_GUARD =
  "if ($LASTEXITCODE -ne 0) { throw ('poetry install failed with exit code ' + $LASTEXITCODE) }";

/** One setup step of a session script. */
interface SessionStep {
  /** Banner text printed before the step runs. */
  readonly label: string;
  /** Step command; an `undefined` step emits neither banner nor command. */
  readonly command: string | undefined;
  /** Optional statement emitted after the command to check a native exit code. */
  readonly exitCodeGuard?: string;
}

/** Inputs that describe one complete session script. */
interface SessionScriptDefinition {
  /** Session name used in the setup-failure message (`Claude` or `Codex`). */
  readonly sessionName: string;
  /** Ordered setup steps. */
  readonly steps: readonly SessionStep[];
  /** Banner text printed before the agent launch. */
  readonly launchLabel: string;
  /** Agent launch command, run only after setup succeeds. */
  readonly launchCommand: string;
}

/**
 * Builds a `Write-Host` banner statement for a step label.
 *
 * @param label Literal banner text; it contains no single quote.
 * @returns The banner statement.
 */
function banner(label: string): string {
  return `Write-Host '==> ${label}'`;
}

/**
 * Composes the fail-fast session script from its definition.
 *
 * @param definition Session name, ordered steps, and agent launch.
 * @returns The LF-joined script. Setup runs inside a `try` block that sets a
 *          success flag as its last statement; the catch block writes a red
 *          failure message; the agent launch runs only when the flag is set.
 */
function composeSessionScript(definition: SessionScriptDefinition): string {
  const lines: string[] = ["& {", "$setupSucceeded = $false", "try {"];
  for (const step of definition.steps) {
    if (step.command === undefined) {
      continue;
    }
    lines.push(banner(step.label), step.command);
    if (step.exitCodeGuard !== undefined) {
      lines.push(step.exitCodeGuard);
    }
  }
  lines.push(
    "$setupSucceeded = $true",
    `} catch { Write-Host "${definition.sessionName} session setup failed: $_" -ForegroundColor Red }`,
    "if ($setupSucceeded) {",
    banner(definition.launchLabel),
    definition.launchCommand,
    "}",
    "}",
  );
  return lines.join("\n");
}

/**
 * Encodes a PowerShell script for the `-EncodedCommand` switch.
 *
 * @param script PowerShell script text.
 * @returns The base64 encoding of the script's UTF-16LE bytes.
 */
export function encodePowerShellCommand(script: string): string {
  return Buffer.from(script, "utf16le").toString("base64");
}

/**
 * Builds the terminal `shellArgs` that run a script at process start and keep
 * the shell open at an interactive prompt afterwards.
 *
 * @param script PowerShell script text.
 * @returns `-NoLogo`, `-NoExit`, `-EncodedCommand`, and the encoded script, in
 *          that order.
 * @throws Error when the encoded script is longer than
 *         {@link MAX_ENCODED_COMMAND_LENGTH} characters; the message names the
 *         encoded length and the limit.
 */
export function buildEncodedShellArgs(script: string): string[] {
  const encoded = encodePowerShellCommand(script);
  if (encoded.length > MAX_ENCODED_COMMAND_LENGTH) {
    throw new Error(
      `The encoded session command is ${encoded.length.toString()} characters, which exceeds the ${MAX_ENCODED_COMMAND_LENGTH.toString()}-character limit. Shorten the objective and try again.`,
    );
  }
  return ["-NoLogo", "-NoExit", "-EncodedCommand", encoded];
}

/**
 * Composes the Claude worktree session script.
 *
 * @param commands Builder output from `buildWorktreeSessionCommands`.
 * @returns The session script with steps in the order ensureParentDirectory,
 *          git, setLocation, poetryInstall, activate, preClaude, then the
 *          `claude` launch. Undefined optional steps are omitted.
 */
export function buildClaudeSessionScript(
  commands: WorktreeSessionCommands,
): string {
  return composeSessionScript({
    sessionName: "Claude",
    steps: [
      {
        label: "Creating worktree group directory",
        command: commands.ensureParentDirectory,
      },
      {
        label: "Adding git worktree",
        command: commands.git,
        exitCodeGuard: GIT_EXIT_CODE_GUARD,
      },
      { label: "Entering worktree", command: commands.setLocation },
      {
        label: "Installing dependencies with poetry",
        command: commands.poetryInstall,
        exitCodeGuard: POETRY_EXIT_CODE_GUARD,
      },
      {
        label: "Activating virtual environment",
        command: commands.activate,
      },
      { label: "Running pre-claude script", command: commands.preClaude },
    ],
    launchLabel: "Starting claude",
    launchCommand: commands.claude,
  });
}

/**
 * Composes the Codex worktree session script.
 *
 * @param commands Builder output from `buildCodexWorktreeSessionCommands`.
 * @returns The session script with steps in the order ensureParentDirectory,
 *          git, setLocation, trustCodexProject, poetryInstall, activate,
 *          postCodex, then the `codex` launch. Undefined optional steps are
 *          omitted.
 */
export function buildCodexSessionScript(
  commands: CodexWorktreeSessionCommands,
): string {
  return composeSessionScript({
    sessionName: "Codex",
    steps: [
      {
        label: "Creating worktree group directory",
        command: commands.ensureParentDirectory,
      },
      {
        label: "Adding git worktree",
        command: commands.git,
        exitCodeGuard: GIT_EXIT_CODE_GUARD,
      },
      { label: "Entering worktree", command: commands.setLocation },
      {
        label: "Trusting worktree for Codex",
        command: commands.trustCodexProject,
      },
      {
        label: "Installing dependencies with poetry",
        command: commands.poetryInstall,
        exitCodeGuard: POETRY_EXIT_CODE_GUARD,
      },
      {
        label: "Activating virtual environment",
        command: commands.activate,
      },
      { label: "Running post-codex script", command: commands.postCodex },
    ],
    launchLabel: "Starting codex",
    launchCommand: commands.codex,
  });
}

/**
 * Builds the terminal `shellArgs` for a Claude worktree session.
 *
 * @param commands Builder output from `buildWorktreeSessionCommands`.
 * @returns The encoded `shellArgs` array.
 * @throws Error when the encoded script exceeds
 *         {@link MAX_ENCODED_COMMAND_LENGTH}.
 */
export function buildClaudeSessionShellArgs(
  commands: WorktreeSessionCommands,
): string[] {
  return buildEncodedShellArgs(buildClaudeSessionScript(commands));
}

/**
 * Builds the terminal `shellArgs` for a Codex worktree session.
 *
 * @param commands Builder output from `buildCodexWorktreeSessionCommands`.
 * @returns The encoded `shellArgs` array.
 * @throws Error when the encoded script exceeds
 *         {@link MAX_ENCODED_COMMAND_LENGTH}.
 */
export function buildCodexSessionShellArgs(
  commands: CodexWorktreeSessionCommands,
): string[] {
  return buildEncodedShellArgs(buildCodexSessionScript(commands));
}
