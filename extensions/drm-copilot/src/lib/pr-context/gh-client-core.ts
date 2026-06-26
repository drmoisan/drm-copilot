/**
 * GitHub CLI wrapper for PR context collection (core).
 *
 * Purpose:
 *     Port of the availability/classification/file-fetch portion of
 *     `dev_tools/pr_context/github.py` `GhClient`. The class wraps the `gh`
 *     executable through an injected {@link CommandRunner}, classifies issue/PR
 *     entities, fetches repo files (base64), and reports CI status.
 *
 * Responsibilities:
 *     - Hydrate availability on construction (`gh` resolution, `auth status`,
 *       repo resolution) and expose `available`, `ensureAvailable`,
 *       `statusMessage`.
 *     - Provide the shared `requestJson` helper with 404/Not-Found tolerance and
 *       invalid-JSON handling.
 *     - Implement `classifyEntity`, `fetchRepoFile`, and `ciStatus`.
 *     - Delegate the issue/PR detail methods to `gh-client-details.ts` so both
 *       files stay under 500 lines while presenting a single `GhClient` whose
 *       public surface matches the Python class.
 *
 * Invariants:
 *     - Every error message string is preserved verbatim from the Python source.
 *     - `gh` resolution flows through the injected `whichGh` resolver so PATH is
 *       not touched in tests.
 */

import { type FileSystem } from "../file-system";
import { type CommandRunner, type CommandResult } from "../subprocess-runner";
import { type IssueDetails, type PullRequestDetails } from "./models";
import {
  closingIssuesImpl,
  currentPrImpl,
  issueDetailsImpl,
  prDetailsImpl,
} from "./gh-client-details";

/** Resolver for the `gh` executable path; mirrors Python `shutil.which("gh")`. */
export type WhichGh = () => string | undefined;

/** Options accepted by {@link GhClient.requestJson}. */
export interface RequestJsonOptions {
  /** Diagnostic context string used in error messages. */
  readonly context: string;
  /** When true, a 404/Not Found response resolves to `null` instead of throwing. */
  readonly allowNotFound?: boolean;
}

/** Constructor options for {@link GhClient}. */
export interface GhClientOptions {
  /** Command runner used for every `gh` invocation. */
  readonly runner: CommandRunner;
  /** Working directory `gh` runs in. */
  readonly cwd: string;
  /** Filesystem used for local user-story resolution. */
  readonly fileSystem: FileSystem;
  /** Explicit `gh` path; when omitted, `whichGh` is consulted. */
  readonly ghPath?: string;
  /** Resolver for `gh` on PATH; defaults to a resolver returning `undefined`. */
  readonly whichGh?: WhichGh;
}

/**
 * GitHub CLI wrapper used for entity classification and content fetches.
 *
 * Usage:
 *     Construct with an injected runner/cwd/filesystem. Availability is computed
 *     eagerly in the constructor. The issue/PR detail methods delegate to the
 *     functions in `gh-client-details.ts`, which receive this instance through
 *     the {@link GhClientInternals} accessor surface.
 */
export class GhClient {
  private readonly runnerValue: CommandRunner;
  private readonly cwdValue: string;
  private readonly fileSystemValue: FileSystem;
  private readonly ghPath: string | undefined;
  private repoCache: string | null = null;
  private availabilityError: string | null = null;
  private availableValue = false;
  private statusMessageValue: string | null = null;

  constructor(options: GhClientOptions) {
    this.runnerValue = options.runner;
    this.cwdValue = options.cwd;
    this.fileSystemValue = options.fileSystem;
    const whichGh = options.whichGh ?? (() => undefined);
    // Prefer an explicit path; otherwise resolve via the injected resolver.
    this.ghPath = options.ghPath ?? whichGh() ?? undefined;
    this.hydrateAvailability();
  }

  /** @returns The injected command runner. */
  get runner(): CommandRunner {
    return this.runnerValue;
  }

  /** @returns The configured working directory. */
  get cwd(): string {
    return this.cwdValue;
  }

  /** @returns The injected filesystem. */
  get fileSystem(): FileSystem {
    return this.fileSystemValue;
  }

  /** @returns The resolved `gh` executable token, defaulting to `"gh"`. */
  get ghExecutable(): string {
    return this.ghPath ?? "gh";
  }

  /** @returns Whether the GitHub CLI is available and authenticated. */
  get available(): boolean {
    return this.availableValue;
  }

  /** @returns The status message when healthy, otherwise `null`. */
  get statusMessage(): string | null {
    return this.statusMessageValue;
  }

  /**
   * Raise when the GitHub CLI is unavailable.
   *
   * Mirrors Python `ensure_available`: the message is the recorded availability
   * error, or the literal `"GitHub CLI is unavailable."` fallback.
   *
   * @throws Error When `available` is false.
   */
  ensureAvailable(): void {
    if (!this.availableValue) {
      const message = this.availabilityError ?? "GitHub CLI is unavailable.";
      throw new Error(message);
    }
  }

  /**
   * Compute availability: `gh` presence, `auth status`, repo resolution.
   *
   * Mirrors Python `_hydrate_availability`, preserving every message verbatim.
   */
  private hydrateAvailability(): void {
    if (!this.ghPath) {
      this.availabilityError =
        "GitHub CLI (gh) is not installed. Install from https://cli.github.com/.";
      return;
    }

    const status = this.runnerValue.run([this.ghPath, "auth", "status"], {
      cwd: this.cwdValue,
      allowError: true,
    });
    if (status.code !== 0) {
      const stderr = status.stderr || status.stdout || "unknown error";
      this.availabilityError =
        "GitHub CLI is installed but not authenticated. Run 'gh auth login' " +
        "to authenticate.";
      // Append the captured detail when present, matching the Python suffix.
      if (stderr) {
        this.availabilityError += ` Details: ${stderr.trim()}`;
      }
      return;
    }

    const repo = this.repoName();
    if (!repo) {
      this.availabilityError =
        "GitHub CLI is authenticated but failed to resolve repository. " +
        "Ensure network access and repository permissions.";
      return;
    }

    this.availableValue = true;
    this.availabilityError = null;
    this.statusMessageValue = `GitHub CLI authenticated for ${repo}`;
  }

  /**
   * Resolve and cache the `owner/name` repository slug.
   *
   * Mirrors Python `_repo_name`: tolerant of non-zero exit, empty stdout,
   * invalid JSON, and non-dict / missing `nameWithOwner`.
   *
   * @returns The repository slug, or `null` when it cannot be resolved.
   */
  repoName(): string | null {
    if (this.repoCache) {
      return this.repoCache;
    }
    if (!this.ghPath) {
      return null;
    }

    const result = this.runnerValue.run(
      [this.ghPath, "repo", "view", "--json", "nameWithOwner"],
      { cwd: this.cwdValue, allowError: true },
    );
    if (result.code !== 0 || !result.stdout) {
      return null;
    }

    const payload = parseJsonOrNull(result.stdout);
    if (!isRecord(payload)) {
      return null;
    }

    const nameRaw = payload["nameWithOwner"];
    if (typeof nameRaw === "string") {
      this.repoCache = nameRaw;
      return nameRaw;
    }
    return null;
  }

  /**
   * Run `gh` returning parsed JSON, tolerating 404 when requested.
   *
   * Mirrors Python `_request_json`: a non-zero exit raises
   * `"<context> failed (<code>): <message>"` unless `allowNotFound` matches a
   * 404 / Not Found message (then `null`); invalid JSON raises
   * `"<context> returned invalid JSON"`.
   *
   * @param args Full `gh` argv (including the executable token).
   * @param options Context string and optional `allowNotFound`.
   * @returns The parsed JSON value, or `null` for a tolerated 404.
   * @throws Error On a non-404 failure or invalid JSON.
   */
  requestJson(args: readonly string[], options: RequestJsonOptions): unknown {
    const result = this.runnerValue.run(args, {
      cwd: this.cwdValue,
      allowError: true,
    });
    if (result.code !== 0) {
      const message = result.stderr || result.stdout || "unknown error";
      // A 404/Not Found is treated as "absent" only when the caller opts in.
      if (
        (options.allowNotFound ?? false) &&
        (message.includes("404") || message.includes("Not Found"))
      ) {
        return null;
      }
      throw new Error(
        `${options.context} failed (${result.code}): ${message.trim()}`,
      );
    }
    try {
      return JSON.parse(result.stdout) as unknown;
    } catch {
      throw new Error(`${options.context} returned invalid JSON`);
    }
  }

  /**
   * Classify a reference number as `"issue"`, `"pull"`, or `null`.
   *
   * Mirrors Python `classify_entity`: requires availability, resolves the repo,
   * queries `repos/{repo}/issues/{number}` tolerating 404, and returns `"pull"`
   * when the payload has a `pull_request` key, otherwise `"issue"`. Any thrown
   * runtime error resolves to `null`.
   *
   * @param numberRef The numeric reference (without a leading `#`).
   * @returns `"issue"`, `"pull"`, or `null`.
   */
  classifyEntity(numberRef: string): "issue" | "pull" | null {
    this.ensureAvailable();
    const repo = this.repoName();
    if (!repo) {
      return null;
    }

    const apiPath = `repos/${repo}/issues/${numberRef}`;
    let payload: unknown;
    try {
      payload = this.requestJson([this.ghExecutable, "api", apiPath], {
        context: "Classify entity",
        allowNotFound: true,
      });
    } catch {
      return null;
    }

    if (payload === null) {
      return null;
    }
    if (isRecord(payload) && "pull_request" in payload) {
      return "pull";
    }
    return "issue";
  }

  /**
   * Fetch and base64-decode a repository file's content.
   *
   * Mirrors Python `fetch_repo_file`: queries
   * `repos/{repo}/contents/{path}` (leading slash stripped), returns the decoded
   * UTF-8 content (invalid bytes replaced), or `null` for any tolerated failure
   * (unavailable repo, runtime error, non-dict payload, non-string content).
   *
   * @param path Repo-relative file path.
   * @returns The decoded file content, or `null`.
   */
  fetchRepoFile(path: string): string | null {
    this.ensureAvailable();
    const repo = this.repoName();
    if (!repo) {
      return null;
    }

    const apiPath = `repos/${repo}/contents/${path.replace(/^\/+/u, "")}`;
    let payload: unknown;
    try {
      payload = this.requestJson([this.ghExecutable, "api", apiPath], {
        context: "Fetch file",
      });
    } catch {
      return null;
    }

    if (!isRecord(payload)) {
      return null;
    }

    const contentRaw = payload["content"];
    if (typeof contentRaw !== "string") {
      return null;
    }

    // Node's Buffer base64 decode + utf8 emit U+FFFD for undecodable bytes,
    // matching Python `decode("utf-8", errors="replace")`.
    return Buffer.from(contentRaw, "base64").toString("utf8");
  }

  /**
   * Fetch the latest CI run status for a commit.
   *
   * Mirrors Python `ci_status`: returns `[null, []]` when the payload is not a
   * non-empty list or the first run is not an object; otherwise the status from
   * `status` then `conclusion`. The failing-jobs list is always empty (parity).
   *
   * @param headSha Commit sha to query.
   * @returns A tuple of `[status, failingJobs]`.
   */
  ciStatus(headSha: string): [string | null, string[]] {
    this.ensureAvailable();
    const args = [
      this.ghExecutable,
      "run",
      "list",
      "--commit",
      headSha,
      "--limit",
      "1",
      "--json",
      "conclusion,status,name,headSha",
    ];
    const payload = this.requestJson(args, { context: "Fetch CI status" });
    if (!Array.isArray(payload) || payload.length === 0) {
      return [null, []];
    }
    const first: unknown = payload[0];
    if (!isRecord(first)) {
      return [null, []];
    }
    const statusRaw = first["status"] || first["conclusion"];
    const status = typeof statusRaw === "string" ? statusRaw : null;
    return [status, []];
  }

  /**
   * @param numberRef Issue number (without a leading `#`).
   * @returns The fetched issue details (delegates to `gh-client-details`).
   */
  issueDetails(numberRef: string): IssueDetails {
    return issueDetailsImpl(this, numberRef);
  }

  /**
   * @param numberRef PR number (without a leading `#`).
   * @returns The fetched pull request details.
   */
  prDetails(numberRef: string): PullRequestDetails {
    return prDetailsImpl(this, numberRef);
  }

  /**
   * @param prNumber Optional PR number; when omitted, the current PR is used.
   * @returns Sorted, deduplicated `#N` closing-issue references.
   */
  closingIssues(prNumber?: string): string[] {
    return closingIssuesImpl(this, prNumber);
  }

  /** @returns The current branch's PR details, or `null` when unavailable. */
  currentPr(): PullRequestDetails | null {
    return currentPrImpl(this);
  }
}

/**
 * Run a `gh` command directly through the client's runner.
 *
 * Used by detail functions that need the raw {@link CommandResult} (for example
 * `currentPr`, which tolerates non-zero exits and parses JSON itself).
 *
 * @param client The owning client.
 * @param args Full `gh` argv (including the executable token).
 * @returns The captured command result.
 */
export function runGh(
  client: GhClient,
  args: readonly string[],
): CommandResult {
  return client.runner.run(args, { cwd: client.cwd, allowError: true });
}

/**
 * Parse a JSON string, returning `null` on failure.
 *
 * @param text JSON text.
 * @returns The parsed value, or `null` when parsing fails.
 */
export function parseJsonOrNull(text: string): unknown {
  try {
    return JSON.parse(text) as unknown;
  } catch {
    return null;
  }
}

/**
 * Narrow an unknown value to a string-keyed record.
 *
 * @param value Value to test.
 * @returns True when `value` is a non-null, non-array object.
 */
export function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}
