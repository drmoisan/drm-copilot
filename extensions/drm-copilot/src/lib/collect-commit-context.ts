import * as nodePath from "node:path";

import { type CommandRunner } from "./subprocess-runner";
import { type FileSystem } from "./file-system";

/**
 * Options for {@link collectCommitContext}.
 *
 * Mirrors the dependency seams of the Python `collect_commit_context.py`
 * script while keeping the function host-neutral and hermetically testable:
 * - `runner`: injected {@link CommandRunner} used for every `git` invocation,
 *   replacing the Python `subprocess.run` + `shutil.which("git")` pair.
 * - `fileSystem`: injected {@link FileSystem} used to create the parent
 *   directory and write the output file, replacing Python `Path.mkdir` and
 *   `Path.write_text`.
 * - `cwd`: working directory for git commands, replacing the spawn `cwd`.
 * - `outputPath`: absolute path of the file to write, replacing the Python
 *   `--output` argument.
 * - `log`: optional sink that receives the `Commit context written to: <path>`
 *   message, replacing the Python `print(...)`. The function does not write to
 *   stdout directly.
 */
export interface CollectCommitContextOptions {
  runner: CommandRunner;
  fileSystem: FileSystem;
  cwd: string;
  outputPath: string;
  log?: (message: string) => void;
}

/**
 * Run a git command and return its stripped stdout.
 *
 * Ports the Python `run_git` helper. The injected {@link CommandRunner} is
 * invoked with `args[0] === "git"` so Node resolves the executable from PATH;
 * the Python `shutil.which("git")` existence pre-check is replaced by the
 * runner's spawn-failure handling (a failed spawn yields a non-zero/`null`
 * status which the runner maps to a thrown error when `allowError` is false).
 *
 * @param runner Injected command runner.
 * @param cwd Working directory for the git process.
 * @param args Git subcommand and arguments (e.g. `["status", "-sb"]`).
 * @param allowError When true, a non-zero exit returns the captured stdout
 *   instead of raising, matching Python `allow_error=True`. When false, a
 *   non-zero exit propagates the runner's thrown error (Python `check=True`).
 * @returns The command stdout with leading and trailing whitespace removed,
 *   matching Python `str.strip()`.
 */
function runGit(
  runner: CommandRunner,
  cwd: string,
  args: readonly string[],
  allowError: boolean,
): string {
  const result = runner.run(["git", ...args], { cwd, allowError });
  // Apply a full strip (leading + trailing) to match Python `.strip()`. When
  // `allowError` is true and the command failed, the runner still returns the
  // captured stdout, so returning the trimmed value matches the Python
  // allow_error branch (which returns the stripped captured stdout).
  return result.stdout.trim();
}

/**
 * Collect Git commit context and write it to the output file.
 *
 * Purpose:
 *     Port of `resources/templates/collect_commit_context.py`. Gathers
 *     repository state (remotes, branch, upstream, status, staged/unstaged
 *     diffs, untracked files, diff stat, changed Python files, last commit)
 *     into a single text file suitable for commit-message generation, then
 *     appends an editable change-intent block.
 *
 * Responsibilities:
 *     - Invoke the exact git commands of the Python source, in source order,
 *       with the same `allowError` semantics per call.
 *     - Build the section list with byte-identical headers, spacers, and
 *       placeholder strings.
 *     - Ensure the parent directory exists and write the newline-joined body.
 *     - Emit the `Commit context written to: <path>` message via `log`.
 *
 * Side effects:
 *     Runs git child processes through the injected runner and writes one file
 *     through the injected filesystem.
 *
 * @param options See {@link CollectCommitContextOptions}.
 * @returns Nothing; the result is the written file and the optional log call.
 */
export function collectCommitContext(
  options: CollectCommitContextOptions,
): void {
  const { runner, fileSystem, cwd, outputPath, log } = options;
  const sections: string[] = [];

  sections.push(
    "Please generate a commit message based on the following content:",
  );
  sections.push("\n");

  // Repository remotes (mandatory; matches Python check=True).
  sections.push("===== Repository remotes =====");
  sections.push("");
  const remotes = runGit(runner, cwd, ["remote", "-v"], false);
  sections.push(remotes);
  sections.push("");

  // Current branch (mandatory).
  sections.push("===== Current branch =====");
  sections.push("");
  const branch = runGit(
    runner,
    cwd,
    ["rev-parse", "--abbrev-ref", "HEAD"],
    false,
  );
  sections.push(branch);
  sections.push("");

  // Upstream (optional; a repository may have no upstream configured).
  sections.push("===== Upstream =====");
  sections.push("");
  const upstream = runGit(
    runner,
    cwd,
    ["rev-parse", "--abbrev-ref", "--symbolic-full-name", "@{u}"],
    true,
  );
  // Branch on presence of an upstream so missing upstream renders the literal
  // placeholder rather than an empty line.
  sections.push(upstream ? upstream : "(no upstream)");
  sections.push("");

  // Status (short) (mandatory).
  sections.push("===== Status (short) =====");
  sections.push("");
  const status = runGit(runner, cwd, ["status", "-sb"], false);
  sections.push(status);
  sections.push("");

  // Staged files (name-status) (optional).
  sections.push("===== Staged files (name-status) =====");
  sections.push("");
  const staged = runGit(
    runner,
    cwd,
    ["diff", "--cached", "--name-status"],
    true,
  );
  sections.push(staged ? staged : "(no staged changes)");
  sections.push("");

  // Staged diff (optional).
  sections.push("===== Staged diff =====");
  sections.push("");
  const stagedDiff = runGit(runner, cwd, ["diff", "--cached"], true);
  sections.push(stagedDiff ? stagedDiff : "(no staged changes)");
  sections.push("");

  // Unstaged files (name-status) (optional).
  sections.push("===== Unstaged files (name-status) =====");
  sections.push("");
  const unstaged = runGit(runner, cwd, ["diff", "--name-status"], true);
  sections.push(unstaged ? unstaged : "(no unstaged changes)");
  sections.push("");

  // Unstaged diff (optional).
  sections.push("===== Unstaged diff =====");
  sections.push("");
  const unstagedDiff = runGit(runner, cwd, ["diff"], true);
  sections.push(unstagedDiff ? unstagedDiff : "(no unstaged changes)");
  sections.push("");

  // Untracked files (optional).
  sections.push("===== Untracked files =====");
  sections.push("");
  const untracked = runGit(
    runner,
    cwd,
    ["ls-files", "--others", "--exclude-standard"],
    true,
  );
  sections.push(untracked ? untracked : "(no untracked files)");
  sections.push("");

  // Diff stat (staged + unstaged) (optional).
  sections.push("===== Diff stat (staged + unstaged) =====");
  sections.push("");
  const diffStat = runGit(runner, cwd, ["diff", "HEAD", "--stat"], true);
  sections.push(diffStat ? diffStat : "(no changes)");
  sections.push("");

  // Changed Python files (optional).
  sections.push("===== Changed Python files =====");
  sections.push("");
  const allChanged = runGit(runner, cwd, ["diff", "HEAD", "--name-only"], true);
  // Keep only paths ending in `.py`, splitting on the literal "\n" exactly as
  // the Python source does (not OS newline). An empty result yields no files.
  const pyFiles = allChanged
    ? allChanged.split("\n").filter((file) => file.endsWith(".py"))
    : [];
  sections.push(
    pyFiles.length > 0 ? pyFiles.join("\n") : "(no Python files changed)",
  );
  sections.push("");

  // Last commit (header only) (optional).
  sections.push("===== Last commit (header only) =====");
  sections.push("");
  const lastCommit = runGit(
    runner,
    cwd,
    ["log", "-1", "--format=%H%n%aN <%aE>%n%aD%n%cN <%cE>%n%cD%n%s%n%b"],
    true,
  );
  // Decide between formatting the captured commit header and rendering the
  // no-commits placeholder. The ordering and field positions mirror the
  // Python source exactly.
  if (lastCommit) {
    const lines = lastCommit.split("\n");
    sections.push(`commit ${lines[0]}`);
    if (lines.length > 1) {
      sections.push(`Author:     ${lines[1]}`);
    }
    if (lines.length > 2) {
      sections.push(`AuthorDate: ${lines[2]}`);
    }
    if (lines.length > 3) {
      sections.push(`Commit:     ${lines[3]}`);
    }
    if (lines.length > 4) {
      sections.push(`CommitDate: ${lines[4]}`);
    }
    if (lines.length > 5) {
      sections.push("");
      sections.push(`    ${lines[5]}`);
      // Indent each remaining non-blank body line, matching Python lines[6:].
      for (const line of lines.slice(6)) {
        if (line.trim()) {
          sections.push(`    ${line}`);
        }
      }
    }
  } else {
    sections.push("(no previous commits)");
  }
  sections.push("");

  // Change intent (editable section).
  sections.push("===== Change intent (edit below) =====");
  sections.push("- What/why summary:");
  sections.push("- Breaking changes:");
  sections.push("- Affected modules:");
  sections.push("- Issue/PR refs:");
  sections.push("");

  // Ensure the parent directory exists, then write the newline-joined body,
  // matching Python `output_path.parent.mkdir(parents=True, exist_ok=True)`
  // followed by `output_path.write_text("\n".join(sections))`.
  fileSystem.ensureDir(nodePath.dirname(outputPath));
  fileSystem.writeTextFile(outputPath, sections.join("\n"));
  log?.(`Commit context written to: ${outputPath}`);
}
