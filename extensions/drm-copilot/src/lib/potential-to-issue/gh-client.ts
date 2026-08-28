/**
 * `gh` CLI client seam for the potential-to-issue promotion workflow.
 *
 * Purpose:
 *     In-process TypeScript port of the `gh` client in the bundled
 *     `resources/scripts/dev_tools/potential_to_issue.py`
 *     (`GhResult`, `GhClient`, `RealGhClient`). The workflow module uses this
 *     seam for all GitHub interactions (auth check, issue create, label create,
 *     issue view) so tests can inject a deterministic fake.
 *
 * Parity:
 *     Argument vectors for `auth status`, `issue create`, `label create`, and
 *     `issue view`, the `--json` field list, the label color/description, and
 *     the missing-`gh` error message match the Python source, with one
 *     deliberate TypeScript-only divergence: when the optional `repo` option is
 *     supplied, `issue create`, `label create`, and `issue view` carry an
 *     explicit `--repo <owner/name>` selector immediately after their subcommand
 *     words. The divergence exists because the Python command-line surface
 *     exposes no workspace parameter, so it can only ever target the process
 *     working directory, whereas this port is invoked with a caller-supplied
 *     workspace root that may name a different checkout. When `repo` is omitted
 *     the three vectors are unchanged. Every invocation runs with
 *     `allowError: true` (Python uses `check=False` and inspects the return
 *     code), and `GhResult.output` is the combined stdout+stderr split into
 *     lines.
 *
 * Design choice (parity-note option b):
 *     The F1 `CommandRunner.run` signature does not accept stdin. Rather than
 *     widen the shared interface, this module defines a narrow
 *     {@link GhCommandRunner} seam that adds an optional `input?: string` for
 *     the `issue create --body-file -` stdin body. The production default
 *     ({@link SpawnSyncGhCommandRunner}) wraps `node:child_process.spawnSync`
 *     directly so stdin can be supplied; the shared F1 interface is unchanged.
 */

import { execSync, spawnSync } from "node:child_process";

/** Label color applied when creating the promotion label (byte-identical). */
export const FEATURE_LABEL_COLOR = "0e8a16";

/** Label description applied when creating the promotion label. */
export const FEATURE_LABEL_DESCRIPTION = "Feature work";

/** Missing-`gh` error message (byte-identical to the Python source). */
export const GH_NOT_FOUND_MESSAGE =
  "gh CLI not found on PATH. Install gh and authenticate first.";

/**
 * Structured outcome of a `gh` invocation.
 *
 * Mirrors the Python `GhResult` dataclass: `output` is the combined stdout and
 * stderr split into lines; `exitCode` is the integer process exit code.
 */
export interface GhResult {
  output: string[];
  exitCode: number;
}

/**
 * Result of a low-level `gh` process invocation through {@link GhCommandRunner}.
 *
 * Decoded stdout/stderr text and the integer exit code, before line-splitting.
 */
export interface GhCommandResult {
  stdout: string;
  stderr: string;
  code: number;
}

/**
 * Narrow command-runner seam for `gh` invocations.
 *
 * Purpose:
 *     Adds an optional stdin `input` parameter that the shared F1
 *     `CommandRunner` does not expose, so the `issue create --body-file -` body
 *     can be supplied on stdin without widening the shared interface.
 *
 * Implementations always capture stdout/stderr and the exit code and never
 * throw on a non-zero exit (the workflow inspects the code itself).
 */
export interface GhCommandRunner {
  /**
   * Run `gh` with the given arguments and optional stdin body.
   *
   * @param ghPath Resolved `gh` executable path.
   * @param args Argument vector passed verbatim (no shell interpolation).
   * @param input Optional UTF-8 stdin body (used by `issue create`).
   * @returns Captured stdout, stderr, and exit code.
   */
  run(ghPath: string, args: readonly string[], input?: string): GhCommandResult;
}

/**
 * Contract for the `gh` operations used by the promotion workflow.
 *
 * Mirrors the Python `GhClient` Protocol. Tests inject a deterministic fake;
 * production wiring injects {@link RealGhClient}.
 */
export interface GhClient {
  /** Return true when `gh auth status` exits zero. */
  isAuthenticated(): boolean;

  /**
   * Create a GitHub issue, supplying the body on stdin.
   *
   * @param title Issue title.
   * @param body Issue body, passed on stdin via `--body-file -`.
   * @param promotionType Promotion label to attach.
   * @returns The combined-output/exit-code result.
   */
  issueCreate(title: string, body: string, promotionType: string): GhResult;

  /**
   * Create the promotion label with the canonical color and description.
   *
   * @param label Label name to create.
   * @returns The combined-output/exit-code result.
   */
  ensureLabel(label: string): GhResult;

  /**
   * View an issue's JSON metadata.
   *
   * @param issueNumber Issue number to view.
   * @returns The combined-output/exit-code result.
   */
  issueView(issueNumber: string): GhResult;
}

/**
 * Production {@link GhCommandRunner} backed by `node:child_process.spawnSync`.
 *
 * Purpose:
 *     Invoke `gh` without a shell, capturing UTF-8 stdout/stderr and the exit
 *     code, and supplying an optional stdin body. Mirrors the Python
 *     `subprocess.run(..., input=body, text=True, encoding="utf-8",
 *     capture_output=True, check=False)` call.
 *
 * Side effects:
 *     Spawns a child process.
 */
export class SpawnSyncGhCommandRunner implements GhCommandRunner {
  /**
   * Run `gh` with the given arguments and optional stdin body.
   *
   * @param ghPath Resolved `gh` executable path.
   * @param args Argument vector passed verbatim.
   * @param input Optional UTF-8 stdin body.
   * @returns Captured stdout, stderr, and exit code (status null treated as 1).
   */
  run(
    ghPath: string,
    args: readonly string[],
    input?: string,
  ): GhCommandResult {
    const completed = spawnSync(ghPath, [...args], {
      shell: false,
      encoding: "utf8",
      ...(input === undefined ? {} : { input }),
    });

    const stdout = typeof completed.stdout === "string" ? completed.stdout : "";
    const stderr = typeof completed.stderr === "string" ? completed.stderr : "";
    // A null status (signal/spawn failure) is treated as a non-zero failure.
    const code = completed.status === null ? 1 : completed.status;
    return { stdout, stderr, code };
  }
}

/**
 * Resolve the `gh` executable path, mirroring Python `shutil.which("gh")`.
 *
 * Uses the platform `where`/`which` lookup. Returns the first resolved path, or
 * null when `gh` is not found. This is the injectable production default so
 * tests never touch the real PATH.
 *
 * @returns The resolved `gh` path, or null when absent.
 */
export function defaultGhPathLookup(): string | null {
  // Use the platform locator (`where` on Windows, `which` elsewhere) to mirror
  // shutil.which; a non-zero exit or empty output means gh is absent.
  const locator = process.platform === "win32" ? "where" : "which";
  try {
    const output = execSync(`${locator} gh`, { encoding: "utf8" });
    const first = output.split(/\r?\n/).find((line) => line.trim().length > 0);
    return first ? first.trim() : null;
  } catch {
    return null;
  }
}

/**
 * Split combined stdout+stderr into lines, mirroring Python `str.splitlines()`.
 *
 * Python's `splitlines()` splits on `\n`, `\r\n`, and `\r` and does not produce
 * a trailing empty element for a terminal newline.
 *
 * @param combined Concatenated stdout+stderr text.
 * @returns The text split into lines with no trailing empty element.
 */
function splitCombinedOutput(combined: string): string[] {
  if (combined === "") {
    return [];
  }
  // Split on all line-ending forms; drop a single trailing empty element that a
  // terminal newline would otherwise produce (matches Python splitlines).
  const lines = combined.split(/\r\n|\r|\n/);
  if (lines.length > 0 && lines[lines.length - 1] === "") {
    lines.pop();
  }
  return lines;
}

/**
 * Production {@link GhClient} backed by the `gh` CLI.
 *
 * Purpose:
 *     Run the auth/create/label/view `gh` invocations the promotion workflow
 *     needs, capturing combined output and the exit code, and never throwing on
 *     a non-zero exit (the workflow inspects the code itself).
 *
 * Responsibilities:
 *     - Resolve the `gh` executable via an injectable lookup; fail fast with the
 *       byte-identical missing-`gh` message when absent.
 *     - Build the exact argument vectors the Python source uses.
 *     - Convert combined stdout+stderr into split lines for {@link GhResult}.
 *
 * Side effects:
 *     Spawns `gh` child processes through the injected {@link GhCommandRunner}.
 *
 * Invariants:
 *     The resolved `gh` path is non-null after construction.
 */
export class RealGhClient implements GhClient {
  private readonly ghPath: string;
  private readonly runner: GhCommandRunner;
  private readonly repo: string | undefined;

  /**
   * Construct a client, resolving and validating the `gh` executable.
   *
   * @param options Optional injected `runner` (defaults to
   *   {@link SpawnSyncGhCommandRunner}), `ghPathLookup` (defaults to
   *   {@link defaultGhPathLookup}) so tests never touch the real PATH, and
   *   `repo` — an explicit `owner/name` target repository. When `repo` is
   *   supplied, every repository-scoped invocation names it explicitly so the
   *   process working directory cannot influence repository selection; when it
   *   is omitted the argument vectors are unchanged.
   * @throws Error With {@link GH_NOT_FOUND_MESSAGE} when `gh` cannot be resolved.
   */
  constructor(options?: {
    readonly runner?: GhCommandRunner;
    readonly ghPathLookup?: () => string | null;
    readonly repo?: string;
  }) {
    const lookup = options?.ghPathLookup ?? defaultGhPathLookup;
    const resolved = lookup();
    // Fail fast when gh is absent, mirroring the Python FileNotFoundError.
    if (!resolved) {
      throw new Error(GH_NOT_FOUND_MESSAGE);
    }
    this.ghPath = resolved;
    this.runner = options?.runner ?? new SpawnSyncGhCommandRunner();
    this.repo = options?.repo;
  }

  /**
   * Repository selector fragment spliced after the subcommand words.
   *
   * @returns `["--repo", "<owner/name>"]` when bound, otherwise an empty vector
   *   so an unbound client keeps its pre-change argument vectors exactly.
   */
  private repoSelector(): readonly string[] {
    return this.repo === undefined ? [] : ["--repo", this.repo];
  }

  /**
   * Run a `gh` invocation and build a {@link GhResult} from combined output.
   *
   * @param args Argument vector (without the `gh` executable).
   * @param input Optional stdin body.
   * @returns The combined-output/exit-code result.
   */
  private runGh(args: readonly string[], input?: string): GhResult {
    const result = this.runner.run(this.ghPath, args, input);
    const combined = (result.stdout || "") + (result.stderr || "");
    return { output: splitCombinedOutput(combined), exitCode: result.code };
  }

  /**
   * @returns True when `gh auth status` exits zero.
   */
  isAuthenticated(): boolean {
    const result = this.runner.run(this.ghPath, ["auth", "status"]);
    return result.code === 0;
  }

  /**
   * Create a GitHub issue with the body supplied on stdin.
   *
   * @param title Issue title.
   * @param body Issue body (passed on stdin via `--body-file -`).
   * @param promotionType Promotion label to attach.
   * @returns The combined-output/exit-code result.
   */
  issueCreate(title: string, body: string, promotionType: string): GhResult {
    const args = [
      "issue",
      "create",
      ...this.repoSelector(),
      "--title",
      title,
      "--body-file",
      "-",
      "--label",
      promotionType,
    ];
    return this.runGh(args, body);
  }

  /**
   * Create the promotion label with the canonical color and description.
   *
   * @param label Label name to create.
   * @returns The combined-output/exit-code result.
   */
  ensureLabel(label: string): GhResult {
    const args = [
      "label",
      "create",
      ...this.repoSelector(),
      label,
      "--color",
      FEATURE_LABEL_COLOR,
      "--description",
      FEATURE_LABEL_DESCRIPTION,
    ];
    return this.runGh(args);
  }

  /**
   * View an issue's JSON metadata with the canonical field list.
   *
   * @param issueNumber Issue number to view.
   * @returns The combined-output/exit-code result.
   */
  issueView(issueNumber: string): GhResult {
    const args = [
      "issue",
      "view",
      ...this.repoSelector(),
      issueNumber,
      "--json",
      "number,title,url,author,updatedAt",
    ];
    return this.runGh(args);
  }
}
