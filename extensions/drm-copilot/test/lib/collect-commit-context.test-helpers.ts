import { type CollectCommitContextOptions } from "../../src/lib/collect-commit-context";
import {
  type CommandResult,
  type CommandRunner,
  type CommandRunOptions,
} from "../../src/lib/subprocess-runner";
import { type FileSystem } from "../../src/lib/file-system";

/**
 * Recorded git invocation for assertions on argument lists and options.
 */
export interface RecordedCall {
  readonly args: readonly string[];
  readonly options?: CommandRunOptions;
}

/**
 * Build a {@link CommandRunner} fake whose output is routed by the git argument
 * list, mirroring the Python test's `mock_run_git`. The provided `route`
 * callback receives the git subcommand args (without the leading `"git"`) and
 * returns the stdout to capture; a non-zero `code` can be returned for
 * allowError scenarios. All calls are recorded for assertions.
 *
 * @param route Callback mapping subcommand args to `{ stdout, code? }`.
 * @returns The fake runner and the recorded-call list.
 */
export function createRunner(
  route: (args: readonly string[]) => { stdout: string; code?: number },
): { runner: CommandRunner; calls: RecordedCall[] } {
  const calls: RecordedCall[] = [];
  const runner: CommandRunner = {
    run(
      fullArgs: readonly string[],
      options?: CommandRunOptions,
    ): CommandResult {
      calls.push({ args: fullArgs, ...(options ? { options } : {}) });
      // Drop the leading "git" so routing matches on subcommand args, as the
      // Python mock inspects the subcommand list.
      const subArgs = fullArgs.slice(1);
      const routed = route(subArgs);
      const code = routed.code ?? 0;
      // Honour allowError: a mandatory call (allowError false) that returns a
      // non-zero code throws, mirroring SubprocessRunner's fail-fast contract.
      if (code !== 0 && !(options?.allowError ?? false)) {
        throw new Error(`git ${subArgs.join(" ")} failed (${code})`);
      }
      return { stdout: routed.stdout, stderr: "", code };
    },
  };
  return { runner, calls };
}

/**
 * In-memory {@link FileSystem} fake recording `ensureDir` calls and the content
 * written via `writeTextFile`. Unused read/glob methods throw to surface any
 * unexpected dependency.
 */
export class InMemoryFileSystem implements FileSystem {
  readonly written = new Map<string, string>();
  readonly ensuredDirs: string[] = [];

  glob(): string[] {
    throw new Error("not used");
  }

  isFile(): boolean {
    throw new Error("not used");
  }

  readTextFile(): string {
    throw new Error("not used");
  }

  writeTextFile(path: string, content: string): void {
    this.written.set(path, content);
  }

  ensureDir(path: string): void {
    this.ensuredDirs.push(path);
  }
}

/**
 * Default routing that returns a non-empty value for every git call, used by
 * tests that only assert structural output. Individual tests override.
 *
 * @returns A fixed `{ stdout: "mock" }` result.
 */
export function defaultRoute(): { stdout: string } {
  return { stdout: "mock" };
}

/**
 * The canonical output path used by collect-commit-context tests.
 */
export const OUTPUT_PATH = "/workspace/artifacts/commit_context.txt";

/**
 * Build {@link CollectCommitContextOptions} with sensible defaults, allowing
 * per-test overrides.
 *
 * @param runner Injected command runner.
 * @param fileSystem Injected filesystem.
 * @param overrides Optional field overrides.
 * @returns Fully-formed options for `collectCommitContext`.
 */
export function buildOptions(
  runner: CommandRunner,
  fileSystem: FileSystem,
  overrides?: Partial<CollectCommitContextOptions>,
): CollectCommitContextOptions {
  return {
    runner,
    fileSystem,
    cwd: "/workspace",
    outputPath: OUTPUT_PATH,
    ...overrides,
  };
}
