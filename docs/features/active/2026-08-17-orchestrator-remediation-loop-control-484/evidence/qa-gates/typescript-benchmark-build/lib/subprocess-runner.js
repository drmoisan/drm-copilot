"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.SubprocessRunner = void 0;
const node_child_process_1 = require("node:child_process");
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
function stripTrailingNewlines(value) {
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
class SubprocessRunner {
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
    run(args, options) {
        const executable = args[0];
        if (executable === undefined) {
            throw new Error("SubprocessRunner.run requires at least one argument");
        }
        const allowError = options?.allowError ?? false;
        const spawnOptions = options?.cwd === undefined
            ? { shell: false }
            : { cwd: options.cwd, shell: false };
        const completed = (0, node_child_process_1.spawnSync)(executable, args.slice(1), spawnOptions);
        // Decode captured buffers as UTF-8. Node replaces undecodable byte
        // sequences with U+FFFD, matching Python encoding="utf-8", errors="replace".
        const rawStdout = completed.stdout instanceof Buffer
            ? completed.stdout.toString("utf8")
            : "";
        const rawStderr = completed.stderr instanceof Buffer
            ? completed.stderr.toString("utf8")
            : "";
        const stdout = stripTrailingNewlines(rawStdout);
        const stderr = stripTrailingNewlines(rawStderr);
        // A null status indicates the process did not exit normally (signal or
        // spawn failure). Treat it as a non-zero failure rather than success.
        const code = completed.status === null ? 1 : completed.status;
        const result = { stdout, stderr, code };
        // Fail-fast on non-zero exit unless the caller opted into tolerating errors.
        if (!allowError && result.code !== 0) {
            const joined = (stdout + "\n" + stderr).trim();
            throw new Error(`${args.join(" ")} failed (${result.code}): ${joined}`);
        }
        return result;
    }
}
exports.SubprocessRunner = SubprocessRunner;
