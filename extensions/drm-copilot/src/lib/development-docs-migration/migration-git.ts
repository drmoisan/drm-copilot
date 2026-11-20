/**
 * Git seam for the development-docs migration (issue #1016, spec "TypeScript seam").
 *
 * Every git call goes through the injected {@link CommandRunner}, so tests use
 * a fake runner and never start a process. Listing calls use `-z` output and an
 * explicit `maxBuffer`, because the tracked-file listing of a large repository
 * exceeds the 1 MiB `spawnSync` default.
 */
import type { CommandRunner } from "../subprocess-runner";

/** Buffer limit for listing calls: 256 MiB. */
export const MIGRATION_GIT_MAX_BUFFER = 256 * 1024 * 1024;

/** Git operations the migration planner and applier need. */
export interface MigrationGit {
  /** `git ls-files -z -- <pathspecs>`: tracked files, repository-relative. */
  listTrackedFiles(pathspecs: ReadonlyArray<string>): ReadonlyArray<string>;
  /** `git ls-files -z --others -- <pathspecs>`: untracked and ignored files. */
  listUntrackedFiles(pathspecs: ReadonlyArray<string>): ReadonlyArray<string>;
  /** `git status --porcelain -z --untracked-files=no`: true when output is non-empty. */
  hasUncommittedTrackedChanges(): boolean;
  /** `git mv -- <from> <to>`; throws when git exits non-zero. */
  move(from: string, to: string): void;
  /** `git rev-parse --is-inside-work-tree`: false on a non-zero exit. */
  isInsideWorkTree(): boolean;
}

/**
 * Split NUL-terminated `-z` output into entries.
 *
 * @param output Raw stdout of a `-z` command.
 * @returns The non-empty entries in output order.
 */
function splitNul(output: string): ReadonlyArray<string> {
  return output.split("\0").filter((entry) => entry !== "");
}

/**
 * Create the production git seam over a command runner.
 *
 * @param runner Command runner; the real one spawns `git`.
 * @param cwd Working directory of every git call (the workspace root).
 * @returns A {@link MigrationGit} bound to `cwd`.
 */
export function createMigrationGit(
  runner: CommandRunner,
  cwd: string,
): MigrationGit {
  const list = (args: ReadonlyArray<string>): ReadonlyArray<string> =>
    splitNul(
      runner.run(["git", ...args], { cwd, maxBuffer: MIGRATION_GIT_MAX_BUFFER })
        .stdout,
    );
  return {
    listTrackedFiles: (pathspecs) =>
      list(["ls-files", "-z", "--", ...pathspecs]),
    listUntrackedFiles: (pathspecs) =>
      list(["ls-files", "-z", "--others", "--", ...pathspecs]),
    hasUncommittedTrackedChanges: () =>
      runner
        .run(["git", "status", "--porcelain", "-z", "--untracked-files=no"], {
          cwd,
          maxBuffer: MIGRATION_GIT_MAX_BUFFER,
        })
        .stdout.trim() !== "",
    move: (from, to) => {
      const result = runner.run(["git", "mv", "--", from, to], {
        cwd,
        allowError: true,
      });
      if (result.code !== 0) {
        throw new Error(
          `git mv ${from} ${to} failed (${String(result.code)}): ${(result.stdout + "\n" + result.stderr).trim()}`,
        );
      }
    },
    isInsideWorkTree: () => {
      const result = runner.run(["git", "rev-parse", "--is-inside-work-tree"], {
        cwd,
        allowError: true,
      });
      return result.code === 0 && result.stdout.trim() === "true";
    },
  };
}
