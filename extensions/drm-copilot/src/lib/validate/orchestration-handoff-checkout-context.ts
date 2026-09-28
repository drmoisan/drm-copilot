import type { CommandRunner, CommandRunOptions } from "../subprocess-runner";
import type { PortableHandoffHeadRelationship } from "../../mcp-repo-automation-tool-definitions-handoff";

/**
 * Read-only observation of the destination checkout, taken from the local Git
 * repository itself rather than from the handoff envelope under validation.
 *
 * The `unavailable` variant is explicit rather than implied by a missing field
 * so that a caller cannot mistake an unobservable checkout for a matching one.
 */
export type CheckoutObservation =
  | {
      readonly status: "observed";
      readonly repositoryId: string;
      readonly workspaceRoot: string;
      readonly branch: string;
      readonly headSha: string;
    }
  | {
      readonly status: "unavailable";
      readonly reason: string;
    };

/** Independent values a head-relationship decision is allowed to consider. */
export interface HeadRelationshipQuery {
  readonly workspaceRoot: string;
  readonly expectedSourceHeadSha: string;
  readonly observedHeadSha: string;
  readonly allowedHeadRelationship: PortableHandoffHeadRelationship;
}

/**
 * Injectable boundary over the local checkout. Implementations must observe the
 * checkout and decide head relationships without consulting the network and
 * without mutating the repository.
 */
export interface HandoffCheckoutContext {
  readonly observe: (workspaceRoot: string) => CheckoutObservation;
  readonly isHeadRelationshipSatisfied: (
    query: HeadRelationshipQuery,
  ) => boolean;
}

/** Every observation runs with error capture so a failure never throws. */
const READ_ONLY_OPTIONS: CommandRunOptions = { allowError: true };

const GIT_SHA_PATTERN = /^[0-9a-f]{40}$/;
const SCHEME_PATTERN = /^[A-Za-z][A-Za-z0-9+.-]*:\/\//;
const SCP_PATTERN = /^(?:[^/@]+@)?([^/:]+):(.+)$/;

/**
 * Reduce a Git remote URL to the scheme-independent `host/owner/name` identity
 * used by the portable handoff contract.
 *
 * @param remoteUrl Raw `git remote get-url origin` output.
 * @returns The canonical repository id, or `null` when the remote is unusable.
 */
export function normalizeRepositoryId(remoteUrl: string): string | null {
  const trimmed = remoteUrl.trim();
  if (trimmed === "") {
    return null;
  }
  let remainder: string;
  if (SCHEME_PATTERN.test(trimmed)) {
    remainder = trimmed.replace(SCHEME_PATTERN, "");
  } else {
    const scpMatch = SCP_PATTERN.exec(trimmed);
    if (scpMatch === null) {
      return null;
    }
    remainder = `${scpMatch[1]}/${scpMatch[2]}`;
  }
  const withoutUserInfo = remainder.replace(/^[^/]*@/, "");
  const withoutGitSuffix = withoutUserInfo
    .replace(/\/+$/, "")
    .replace(/\.git$/i, "")
    .replace(/\/+$/, "");
  const segments = withoutGitSuffix.split("/").filter((part) => part !== "");
  return segments.length < 3 ? null : segments.join("/");
}

/**
 * Canonicalize a Git toplevel path to trailing-slash-free POSIX form.
 *
 * @param toplevel Raw `git rev-parse --show-toplevel` output.
 * @returns The canonical workspace root, or `null` when the output is empty.
 */
function canonicalizeWorkspaceRoot(toplevel: string): string | null {
  const canonical = toplevel
    .trim()
    .replace(/\\/g, "/")
    .replace(/(.)\/+$/, "$1");
  return canonical === "" ? null : canonical;
}

/**
 * Run one read-only Git query and return its trimmed stdout.
 *
 * @param runner Injected command runner.
 * @param workspaceRoot Workspace the query is scoped to with `-C`.
 * @param args Git subcommand arguments.
 * @returns Trimmed stdout, or `null` when Git reported a non-zero exit.
 */
function readGitFact(
  runner: CommandRunner,
  workspaceRoot: string,
  args: readonly string[],
): string | null {
  const result = runner.run(
    ["git", "-C", workspaceRoot, ...args],
    READ_ONLY_OPTIONS,
  );
  return result.code === 0 ? result.stdout.trim() : null;
}

function unavailable(reason: string): CheckoutObservation {
  return { status: "unavailable", reason };
}

/**
 * Create the production checkout observation boundary.
 *
 * Purpose:
 *     Observe the destination checkout's canonical workspace, repository
 *     identity, current branch, and current HEAD, and decide whether the
 *     observed HEAD satisfies the caller's allowed relationship.
 *
 * Responsibilities:
 *     - Issue only local, read-only Git queries, never a shell and never a
 *       network-capable subcommand.
 *     - Stop at the first fact that cannot be observed and report it.
 *     - Validate `equal` by exact SHA equality without invoking Git.
 *     - Validate `equal_or_descendant` only through
 *       `git merge-base --is-ancestor <expected-source-head> HEAD`.
 *
 * @param runner Injected command runner used for every Git query.
 * @returns A read-only {@link HandoffCheckoutContext}.
 */
export function createGitCheckoutContext(
  runner: CommandRunner,
): HandoffCheckoutContext {
  const observe = (workspaceRoot: string): CheckoutObservation => {
    const toplevel = readGitFact(runner, workspaceRoot, [
      "rev-parse",
      "--show-toplevel",
    ]);
    const canonicalWorkspaceRoot =
      toplevel === null ? null : canonicalizeWorkspaceRoot(toplevel);
    if (canonicalWorkspaceRoot === null) {
      return unavailable(
        "git rev-parse --show-toplevel did not yield a canonical workspace root.",
      );
    }
    const remoteUrl = readGitFact(runner, workspaceRoot, [
      "remote",
      "get-url",
      "origin",
    ]);
    const repositoryId =
      remoteUrl === null ? null : normalizeRepositoryId(remoteUrl);
    if (repositoryId === null) {
      return unavailable(
        "git remote get-url origin did not yield a canonical repository id.",
      );
    }
    const branch = readGitFact(runner, workspaceRoot, [
      "branch",
      "--show-current",
    ]);
    if (branch === null || branch === "") {
      return unavailable(
        "git branch --show-current did not yield a current branch.",
      );
    }
    const headSha = readGitFact(runner, workspaceRoot, ["rev-parse", "HEAD"]);
    if (headSha === null || !GIT_SHA_PATTERN.test(headSha)) {
      return unavailable(
        "git rev-parse HEAD did not yield an observed head sha.",
      );
    }
    return {
      status: "observed",
      repositoryId,
      workspaceRoot: canonicalWorkspaceRoot,
      branch,
      headSha,
    };
  };

  const isHeadRelationshipSatisfied = (
    query: HeadRelationshipQuery,
  ): boolean => {
    if (query.allowedHeadRelationship === "equal") {
      return query.observedHeadSha === query.expectedSourceHeadSha;
    }
    const result = runner.run(
      [
        "git",
        "-C",
        query.workspaceRoot,
        "merge-base",
        "--is-ancestor",
        query.expectedSourceHeadSha,
        "HEAD",
      ],
      READ_ONLY_OPTIONS,
    );
    return result.code === 0;
  };

  return { observe, isHeadRelationshipSatisfied };
}
