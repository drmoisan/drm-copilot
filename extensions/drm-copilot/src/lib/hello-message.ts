import * as nodePath from "node:path";

import { type FileSystem, toPosixPath } from "./file-system";

/**
 * Inputs for {@link writeHelloMessage}.
 *
 * Mirrors the dependency seams of the former `resources/templates/hello_python.py`
 * smoke-test script while keeping the function host-neutral and hermetically
 * testable:
 * - `fileSystem`: injected {@link FileSystem} used to create the parent
 *   directory and write the output file, replacing Python `Path.mkdir` and
 *   `Path.write_text`.
 * - `workspaceRoot`: absolute path of the workspace whose `artifacts/`
 *   directory receives the output file, replacing the Python process working
 *   directory (`Path("artifacts/hello_python.txt")` was relative to cwd).
 * - `log`: optional sink that receives the human-readable summary message,
 *   replacing the absence of stdout output in the Python source. The function
 *   does not write to stdout directly.
 */
export interface WriteHelloMessageInput {
  readonly fileSystem: FileSystem;
  readonly workspaceRoot: string;
  readonly log?: (message: string) => void;
}

/**
 * Structured result of {@link writeHelloMessage}.
 *
 * - `tool`: stable identifier preserved from the prior Python smoke test
 *   (`hello_python`) so existing observers and command wiring stay stable.
 * - `workspaceRoot`: the workspace root that was written under, echoed back for
 *   callers and tests.
 * - `summary`: the human-readable completion message also passed to `log`.
 * - `artifacts`: the POSIX-normalized relative paths of files written; here the
 *   single `artifacts/hello_python.txt` entry.
 */
export interface WriteHelloMessageResult {
  readonly tool: "hello_python";
  readonly workspaceRoot: string;
  readonly summary: string;
  readonly artifacts: ReadonlyArray<string>;
}

/** Relative POSIX path of the file the smoke test writes. */
const HELLO_OUTPUT_RELATIVE_PATH = "artifacts/hello_python.txt";

/**
 * Byte-identical content the former `hello_python.py` wrote, including the
 * trailing newline, preserved so the observable output contract is unchanged.
 */
const HELLO_OUTPUT_CONTENT = "hello_python:ok\n";

/**
 * Write the `hello_python` smoke-test artifact in-process.
 *
 * Purpose:
 *     In-process replacement for `resources/templates/hello_python.py`. Writes
 *     `artifacts/hello_python.txt` under the workspace root with the exact
 *     content `"hello_python:ok\n"`, removing the last Python-spawn code path
 *     while preserving the `drmCopilotExtension.helloPython` command surface and
 *     its observable output.
 *
 * Responsibilities:
 *     - Resolve `<workspaceRoot>/artifacts/hello_python.txt`.
 *     - Ensure the parent `artifacts/` directory exists, then write the file.
 *     - Return a structured result and emit the summary via `log`.
 *
 * Side effects:
 *     Creates one directory (idempotent) and writes one file through the
 *     injected {@link FileSystem}. Performs no subprocess execution and no
 *     direct stdout writes.
 *
 * @param input See {@link WriteHelloMessageInput}.
 * @returns The structured {@link WriteHelloMessageResult} describing the write.
 */
export function writeHelloMessage(
  input: WriteHelloMessageInput,
): WriteHelloMessageResult {
  const { fileSystem, workspaceRoot, log } = input;

  // Resolve the output path under the workspace root, then normalize to POSIX
  // separators so the path is OS-neutral for both the filesystem write and the
  // returned/observed value.
  const outputPath = toPosixPath(
    nodePath.join(workspaceRoot, HELLO_OUTPUT_RELATIVE_PATH),
  );

  // Ensure the parent `artifacts/` directory exists, then write the file with
  // the byte-identical content of the former Python source.
  fileSystem.ensureDir(nodePath.dirname(outputPath));
  fileSystem.writeTextFile(outputPath, HELLO_OUTPUT_CONTENT);

  const summary = "Wrote artifacts/hello_python.txt.";
  log?.(summary);

  return {
    tool: "hello_python",
    workspaceRoot,
    summary,
    artifacts: [HELLO_OUTPUT_RELATIVE_PATH],
  };
}
