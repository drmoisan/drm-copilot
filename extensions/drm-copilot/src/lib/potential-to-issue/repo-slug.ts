/**
 * Target-repository slug resolver for the potential-to-issue promotion path.
 *
 * Purpose:
 *     Resolve the `owner/name` slug of the checkout at a given workspace root,
 *     so every repository-scoped `gh` invocation on the promotion path can name
 *     its target explicitly instead of relying on the process working directory
 *     (spec R1).
 *
 * Mechanism (fixed, not a substitutable default):
 *     The slug is read from the GitHub CLI repository-view operation for the
 *     `nameWithOwner` field, executed through the injected
 *     {@link CommandRunner} with its working directory set to the supplied
 *     workspace root and with a non-zero exit tolerated (`allowError: true`) so
 *     the failure is classified here rather than raised as a runner error.
 *
 * Rejected mechanism:
 *     No leg of this resolver reads or parses a remote URL. Remote-URL parsing
 *     is rejected as the primary mechanism and as a fallback (spec R1, E4); this
 *     module therefore exposes no URL-parsing surface.
 *
 * Failure policy:
 *     Resolution fails closed (spec E1). Every unresolvable condition of spec E3
 *     — a checkout with no `origin` remote, a non-zero exit, empty output,
 *     unparseable output, a parseable non-object payload, and a missing or
 *     non-string owner/name field — throws an `Error` whose message begins with
 *     {@link REPO_SLUG_UNRESOLVED_PREFIX} and names the workspace root. There is
 *     no fallback to implicit CLI resolution, because such a fallback is the
 *     defect this module exists to close.
 *
 * Separation of concerns:
 *     This module performs no filesystem or network access of its own. Both the
 *     command runner and the `gh` path lookup are injected, so unit tests spawn
 *     no child process.
 */

import { type CommandResult, type CommandRunner } from "../subprocess-runner";

/**
 * Prefix carried by every error this module throws.
 *
 * Callers assert on this prefix rather than on the full message, so the
 * diagnostic detail appended after the workspace root can change without
 * breaking the fail-closed contract.
 */
export const REPO_SLUG_UNRESOLVED_PREFIX =
  "Unable to resolve the target repository from workspace root";

/** Argument words appended to the `gh` path to form the resolution vector. */
const REPO_VIEW_ARGS: readonly string[] = [
  "repo",
  "view",
  "--json",
  "nameWithOwner",
];

/** JSON field carrying the `owner/name` slug in the repository-view payload. */
const NAME_WITH_OWNER_FIELD = "nameWithOwner";

/**
 * Default `gh` path lookup: the bare program name, with no PATH probe.
 *
 * A probing default would spawn a real `where`/`which` child process in every
 * unit test that omits the lookup, which unit-test policy prohibits and which
 * makes the outcome machine-dependent. Returning the bare program name defers
 * resolution to the operating system at spawn time (the production runner
 * spawns with `shell: false`, and the platform loader searches PATH). An absent
 * `gh` therefore surfaces as a failed invocation, which the fail-closed branch
 * below converts into the unresolved-slug error.
 *
 * @returns The literal `gh` program name.
 */
function defaultGhProgramName(): string {
  return "gh";
}

/** Inputs for {@link resolveRepoSlug}. */
export interface ResolveRepoSlugInput {
  /** Injected command runner used to invoke the repository-view operation. */
  readonly runner: CommandRunner;

  /** Resolved workspace root whose checkout determines the target repository. */
  readonly workspaceRoot: string;

  /**
   * Optional `gh` executable lookup. Defaults to the bare program name, so no
   * PATH probe is performed; see {@link defaultGhProgramName}.
   */
  readonly ghPathLookup?: () => string;
}

/**
 * Build the fail-closed error for an unresolvable workspace root.
 *
 * @param workspaceRoot Workspace root that could not be resolved.
 * @param reason Short diagnostic describing which condition was hit.
 * @returns An `Error` whose message begins with the shared prefix and names the
 *   workspace root.
 */
function unresolved(workspaceRoot: string, reason: string): Error {
  return new Error(
    `${REPO_SLUG_UNRESOLVED_PREFIX} ${workspaceRoot}: ${reason}`,
  );
}

/**
 * Parse the repository-view payload and extract the `owner/name` slug.
 *
 * @param stdout Trimmed standard output of the repository-view invocation.
 * @param workspaceRoot Workspace root, used only to build the error message.
 * @returns The extracted slug.
 * @throws Error When the output is unparseable, is parseable but is not an
 *   object, or carries a missing or non-string owner/name field.
 */
function extractSlug(stdout: string, workspaceRoot: string): string {
  let payload: unknown;
  try {
    payload = JSON.parse(stdout);
  } catch (error) {
    // Re-thrown with context: the parse failure alone does not identify the
    // workspace root that produced it.
    throw unresolved(
      workspaceRoot,
      `the resolution command produced unparseable output (${String(error)})`,
    );
  }

  if (typeof payload !== "object" || payload === null) {
    throw unresolved(
      workspaceRoot,
      "the resolution output is parseable but is not an object",
    );
  }

  if (!(NAME_WITH_OWNER_FIELD in payload)) {
    throw unresolved(
      workspaceRoot,
      `the resolution output carries no ${NAME_WITH_OWNER_FIELD} field`,
    );
  }

  const slug: unknown = payload[NAME_WITH_OWNER_FIELD];
  if (typeof slug !== "string") {
    throw unresolved(
      workspaceRoot,
      `the ${NAME_WITH_OWNER_FIELD} field is not a string`,
    );
  }

  return slug;
}

/**
 * Resolve the `owner/name` slug of the checkout at a workspace root.
 *
 * @param input Injected runner, workspace root, and optional `gh` path lookup.
 * @returns The resolved `owner/name` slug.
 * @throws Error With a message beginning with
 *   {@link REPO_SLUG_UNRESOLVED_PREFIX} and naming the workspace root, for every
 *   unresolvable condition enumerated in spec E3.
 */
export function resolveRepoSlug(input: ResolveRepoSlugInput): string {
  const { runner, workspaceRoot } = input;
  const ghPath = (input.ghPathLookup ?? defaultGhProgramName)();

  // Tolerate a non-zero exit so the failure is classified below rather than
  // raised by the runner; run against the workspace root so the process working
  // directory is irrelevant to repository selection.
  const result: CommandResult = runner.run([ghPath, ...REPO_VIEW_ARGS], {
    cwd: workspaceRoot,
    allowError: true,
  });

  if (result.code !== 0) {
    // Covers both the no-`origin`-remote checkout and every other non-zero
    // exit; the CLI reports the distinction on stderr.
    const detail = result.stderr.trim();
    throw unresolved(
      workspaceRoot,
      `the resolution command exited ${String(result.code)}${detail === "" ? "" : `: ${detail}`}`,
    );
  }

  const stdout = result.stdout.trim();
  if (stdout === "") {
    throw unresolved(
      workspaceRoot,
      "the resolution command produced empty output",
    );
  }

  return extractSlug(stdout, workspaceRoot);
}
