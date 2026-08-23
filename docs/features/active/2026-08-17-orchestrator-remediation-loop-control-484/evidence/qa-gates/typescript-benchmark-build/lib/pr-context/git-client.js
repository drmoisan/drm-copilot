"use strict";
/**
 * Typed git wrapper for PR context collection.
 *
 * Purpose:
 *     Port of `dev_tools/pr_context/git.py` `GitClient`. Provide a thin, typed
 *     surface over the `git` executable using an injected {@link CommandRunner}
 *     (from `subprocess-runner.ts`) so tests can script exact argv/result pairs
 *     without spawning a real process.
 *
 * Responsibilities:
 *     - Prefix every invocation with `"git"` and run it through the injected
 *       runner with the configured `cwd`.
 *     - Replicate each Python `GitClient` method's argv composition and
 *       `allowError` semantics exactly.
 *     - Resolve the repository root, preferring a `.git` entry in `cwd` (probed
 *       through the injected {@link FileSystem}) and otherwise falling back to
 *       `git rev-parse --show-toplevel`.
 *
 * Invariants:
 *     - The injected runner already strips trailing newlines and raises the
 *       parity failure message on non-zero exit when `allowError` is false; this
 *       class never re-implements that behavior.
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.GitClient = void 0;
/**
 * Thin wrapper around git for typed access, mirroring the Python `GitClient`.
 *
 * Usage:
 *     Construct with an injected runner, the working directory, and a
 *     filesystem used only for the `.git` existence probe in
 *     {@link resolveRoot}. Each method returns trimmed stdout (the runner strips
 *     trailing newlines) or the raw {@link CommandResult} for {@link run}.
 */
class GitClient {
    runner;
    cwdValue;
    fileSystem;
    /**
     * @param runner Command runner used for every git invocation.
     * @param cwd Working directory git runs in.
     * @param fileSystem Filesystem used only for the `.git` existence probe.
     */
    constructor(runner, cwd, fileSystem) {
        this.runner = runner;
        this.cwdValue = cwd;
        this.fileSystem = fileSystem;
    }
    /** Current working directory for git operations. */
    get cwd() {
        return this.cwdValue;
    }
    /**
     * Run a git subcommand, prefixing `"git"` and passing the configured `cwd`.
     *
     * @param args Git subcommand and arguments (without the leading `"git"`).
     * @param options Optional `allowError` flag.
     * @returns The captured command result.
     * @throws Error When the process exits non-zero and `allowError` is false
     *   (raised by the injected runner with the parity message).
     */
    run(args, options) {
        return this.runner.run(["git", ...args], {
            cwd: this.cwdValue,
            allowError: options?.allowError ?? false,
        });
    }
    /**
     * Resolve the repository root.
     *
     * Mirrors Python `resolve_root`: when a `.git` entry exists directly under
     * `cwd`, return `cwd`; otherwise return the path reported by
     * `git rev-parse --show-toplevel`.
     *
     * @returns The resolved repository root path.
     */
    resolveRoot() {
        const candidate = joinPath(this.cwdValue, ".git");
        if (this.fileSystem.exists(candidate)) {
            return this.cwdValue;
        }
        return this.run(["rev-parse", "--show-toplevel"]).stdout;
    }
    /**
     * @param ref Ref to verify and resolve.
     * @returns The resolved object name from `rev-parse --verify`.
     */
    revParse(ref) {
        return this.run(["rev-parse", "--verify", ref]).stdout;
    }
    /** @returns The output of `git remote -v`. */
    remoteVerbose() {
        return this.run(["remote", "-v"]).stdout;
    }
    /** @returns The current branch name from `rev-parse --abbrev-ref HEAD`. */
    branchName() {
        return this.run(["rev-parse", "--abbrev-ref", "HEAD"]).stdout;
    }
    /**
     * @returns The upstream tracking ref, or empty string when none is configured
     *   (the call tolerates a non-zero exit).
     */
    upstream() {
        return this.run(["rev-parse", "--abbrev-ref", "--symbolic-full-name", "@{u}"], { allowError: true }).stdout;
    }
    /** @returns The short status output from `git status -sb`. */
    statusShort() {
        return this.run(["status", "-sb"]).stdout;
    }
    /** @returns Untracked files from `git ls-files --others --exclude-standard`. */
    untracked() {
        return this.run(["ls-files", "--others", "--exclude-standard"]).stdout;
    }
    /**
     * Run `git diff --name-status`, optionally staged.
     *
     * Mirrors Python `diff_name_status`: when `staged` is true, `--cached` is
     * inserted at index 1 (between `diff` and `--name-status`).
     *
     * @param options `staged` selects the index (cached) diff.
     * @returns The name-status diff text (tolerates a non-zero exit).
     */
    diffNameStatus(options) {
        const args = ["diff", "--name-status"];
        if (options.staged) {
            args.splice(1, 0, "--cached");
        }
        return this.run(args, { allowError: true }).stdout;
    }
    /**
     * Run `git diff`, optionally staged.
     *
     * Mirrors Python `diff_patch`: when `staged` is true, `--cached` is appended.
     *
     * @param options `staged` selects the index (cached) diff.
     * @returns The patch text (tolerates a non-zero exit).
     */
    diffPatch(options) {
        const args = ["diff"];
        if (options.staged) {
            args.push("--cached");
        }
        return this.run(args, { allowError: true }).stdout;
    }
    /**
     * @param base Base ref or sha.
     * @param head Head ref or sha.
     * @returns The merge-base object name from `git merge-base <base> <head>`.
     */
    mergeBase(base, head) {
        return this.run(["merge-base", base, head]).stdout;
    }
    /**
     * Run `git log --date=short <fmt> <revRange>`.
     *
     * @param fmt The pretty/format argument (for example `--pretty=%s`).
     * @param revRange The revision range argument.
     * @returns The log output (tolerates a non-zero exit).
     */
    log(fmt, revRange) {
        return this.run(["log", "--date=short", fmt, revRange], {
            allowError: true,
        }).stdout;
    }
    /**
     * Run `git diff <args...>`.
     *
     * @param args Diff arguments appended after `diff`.
     * @returns The diff output (tolerates a non-zero exit).
     */
    diffRange(args) {
        return this.run(["diff", ...args], { allowError: true }).stdout;
    }
}
exports.GitClient = GitClient;
/**
 * Join a directory and a child segment using a forward slash.
 *
 * The pr-context port uses POSIX-style paths throughout; this keeps the `.git`
 * probe path consistent with the rest of the module.
 *
 * @param dir Base directory.
 * @param child Child segment to append.
 * @returns The combined path with a single separator.
 */
function joinPath(dir, child) {
    const normalized = dir.replace(/[/\\]+$/u, "");
    return `${normalized}/${child}`;
}
