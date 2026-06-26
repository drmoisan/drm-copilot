import { spawnSync } from "node:child_process";

/**
 * Structured outcome of a shell command.
 *
 * Mirrors the Python `CommandResult` dataclass in
 * `scripts/dev_tools/pr_context/models.py`:
 * - `stdout` and `stderr` are decoded UTF-8 text with a single trailing
 *   newline stripped (matching Python `rstrip("\n")`).
 * - `code` is the integer process exit code.
 */
export interface CommandResult {
  stdout: string;
  stderr: string;
  code: number;
}

/**
 * Optional invocation parameters for {@link CommandRunner.run}.
 *
 * - `cwd`: working directory for the spawned process.
 * - `allowError`: when `false` (default), a non-zero exit code raises an Error;
 *   when `true`, the captured result is returned regardless of exit status.
 */
export interface CommandRunOptions {
  cwd?: string;
  allowError?: boolean;
}

/**
 * Contract for running shell commands and returning structured results.
 *
 * Mirrors the Python `CommandRunner` Protocol in
 * `scripts/dev_tools/pr_context/git.py`. Implementations capture stdout,
 * stderr, and the exit code; whether a non-zero exit raises is governed by
 * {@link CommandRunOptions.allowError}.
 */
export interface CommandRunner {
  run(args: readonly string[], options?: CommandRunOptions): CommandResult;
}

/**
 * Removes a single trailing newline character from a decoded stream.
 *
 * Replicates Python `rstrip("\n")` as used by the source `SubprocessRunner`:
 * Python's `rstrip("\n")` removes all trailing `\n` characters, so this helper
 * strips every trailing newline rather than just one. This keeps parity with
 * the Python behavior where multiple trailing newlines collapse to none.
 *
 * @param value Decoded stream content.
 * @returns The content with all trailing `\n` characters removed.
 */
function stripTrailingNewlines(value: string): string {
  let end = value.length;
  // Walk backward over trailing newline characters to mirror rstrip("\n").
  while (end > 0 && value[end - 1] === "\n") {
    end -= 1;
  }
  return value.slice(0, end);
}

/**
 * Command runner that shells out using `node:child_process.spawnSync`.
 *
 * Purpose:
 *     Execute a command and capture stdout, stderr, and the exit code,
 *     replicating the behavior of the Python `SubprocessRunner` in
 *     `scripts/dev_tools/pr_context/git.py`.
 *
 * Responsibilities:
 *     - Spawn the process without a shell (`shell: false`), passing the
 *       argument list verbatim (no shell interpolation).
 *     - Decode stdout/stderr buffers as UTF-8 with replacement of undecodable
 *       bytes (Node's default `Buffer.toString("utf8")` emits U+FFFD for
 *       invalid sequences, matching Python `errors="replace"`).
 *     - Strip trailing newlines from both streams.
 *     - Raise on non-zero exit unless `allowError` is set.
 *
 * Side effects:
 *     Spawns a child process.
 *
 * Invariants:
 *     - A `null` status (process terminated by signal or failed to spawn) is
 *       treated as a non-zero failure, matching the contract that a missing
 *       exit code is not success.
 */
export class SubprocessRunner implements CommandRunner {
  /**
   * Execute a command and capture its output.
   *
   * @param args Command and arguments; `args[0]` is the executable.
   * @param options Optional `cwd` and `allowError` flag.
   * @returns Captured stdout, stderr, and integer exit code.
   * @throws Error When the process exits non-zero and `allowError` is false.
   *   The message format matches the Python source:
   *   `` `${args.join(" ")} failed (${code}): ${joined}` `` where `joined` is
   *   `(stdout + "\n" + stderr).trim()`.
   */
  run(args: readonly string[], options?: CommandRunOptions): CommandResult {
    const executable = args[0];
    if (executable === undefined) {
      throw new Error("SubprocessRunner.run requires at least one argument");
    }

    const allowError = options?.allowError ?? false;

    const spawnOptions: { cwd?: string; shell: false } =
      options?.cwd === undefined
        ? { shell: false }
        : { cwd: options.cwd, shell: false };

    const completed = spawnSync(executable, args.slice(1), spawnOptions);

    // Decode captured buffers as UTF-8. Node replaces undecodable byte
    // sequences with U+FFFD, matching Python encoding="utf-8", errors="replace".
    const rawStdout =
      completed.stdout instanceof Buffer
        ? completed.stdout.toString("utf8")
        : "";
    const rawStderr =
      completed.stderr instanceof Buffer
        ? completed.stderr.toString("utf8")
        : "";

    const stdout = stripTrailingNewlines(rawStdout);
    const stderr = stripTrailingNewlines(rawStderr);

    // A null status indicates the process did not exit normally (signal or
    // spawn failure). Treat it as a non-zero failure rather than success.
    const code = completed.status === null ? 1 : completed.status;

    const result: CommandResult = { stdout, stderr, code };

    // Fail-fast on non-zero exit unless the caller opted into tolerating errors.
    if (!allowError && result.code !== 0) {
      const joined = (stdout + "\n" + stderr).trim();
      throw new Error(`${args.join(" ")} failed (${result.code}): ${joined}`);
    }

    return result;
  }
}
