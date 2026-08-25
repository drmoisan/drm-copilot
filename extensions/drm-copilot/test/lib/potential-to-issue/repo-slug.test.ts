import { describe, expect, it } from "@jest/globals";

import {
  type CommandResult,
  type CommandRunOptions,
  type CommandRunner,
} from "../../../src/lib/subprocess-runner";
import {
  REPO_SLUG_UNRESOLVED_PREFIX,
  resolveRepoSlug,
} from "../../../src/lib/potential-to-issue/repo-slug";

/**
 * Tests for the target-repository slug resolver used by the potential-to-issue
 * promotion path. Every external interaction is injected: a recording
 * {@link CommandRunner} stub supplies the seeded payload and captures the run
 * options, and the `gh` path lookup is injected, so no real `gh` is located or
 * executed and no child process is spawned.
 */

/** Recorded invocation captured by the recording runner. */
interface RecordedRun {
  readonly args: string[];
  readonly options: CommandRunOptions | undefined;
}

/**
 * Recording {@link CommandRunner} stub that captures each invocation.
 *
 * @param recorded Sink that receives one entry per invocation.
 * @param result Seeded result returned for every invocation.
 * @returns A runner that records and returns the seeded result.
 */
function makeRecordingRunner(
  recorded: RecordedRun[],
  result: CommandResult = { stdout: "", stderr: "", code: 0 },
): CommandRunner {
  return {
    run(args: readonly string[], options?: CommandRunOptions): CommandResult {
      recorded.push({ args: [...args], options });
      return result;
    },
  };
}

/** Injected `gh` path, so the real PATH is never consulted. */
const GH_PATH = "/usr/bin/gh";

/** Workspace root supplied to the resolver under test. */
const WORKSPACE_ROOT = "/other-checkout";

/** Slug carried by the seeded repository-view payload. */
const SLUG = "drmoisan/drm-copilot";

describe("resolveRepoSlug — success", () => {
  it("returns the nameWithOwner slug and runs with cwd set to the workspace root", () => {
    // Arrange: the seeded payload carries the owner/name field, and the runner
    // records the argument vector and the run options it was handed.
    const recorded: RecordedRun[] = [];
    const runner = makeRecordingRunner(recorded, {
      stdout: `{"nameWithOwner":"${SLUG}"}`,
      stderr: "",
      code: 0,
    });

    // Act
    const slug = resolveRepoSlug({
      runner,
      workspaceRoot: WORKSPACE_ROOT,
      ghPathLookup: () => GH_PATH,
    });

    // Assert: the parsed slug is returned, and the resolution ran against the
    // supplied workspace root rather than the process working directory.
    expect(slug).toBe(SLUG);
    expect(recorded).toHaveLength(1);
    expect(recorded[0]?.args).toEqual([
      GH_PATH,
      "repo",
      "view",
      "--json",
      "nameWithOwner",
    ]);
    expect(recorded[0]?.options?.cwd).toBe(WORKSPACE_ROOT);
  });
});

/**
 * Invoke the resolver against a seeded command result.
 *
 * @param result Result the injected runner returns for the resolution call.
 * @returns The resolver invocation, deferred so it can be asserted to throw.
 */
function callWithResult(result: CommandResult): () => string {
  const runner = makeRecordingRunner([], result);
  return () =>
    resolveRepoSlug({
      runner,
      workspaceRoot: WORKSPACE_ROOT,
      ghPathLookup: () => GH_PATH,
    });
}

describe("resolveRepoSlug — unresolvable conditions fail closed", () => {
  it("throws when the checkout has no origin remote", () => {
    // Arrange: the CLI reports the absent remote on stderr and exits non-zero.
    const call = callWithResult({
      stdout: "",
      stderr: "no git remotes found",
      code: 1,
    });

    // Act + Assert: the failure is classified as unresolvable and the CLI's own
    // diagnostic is carried through.
    expect(call).toThrow(REPO_SLUG_UNRESOLVED_PREFIX);
    expect(call).toThrow("no git remotes found");
  });

  it("throws when the resolution command exits non-zero", () => {
    // Arrange: a non-zero exit carrying no stderr detail.
    const call = callWithResult({ stdout: "", stderr: "", code: 4 });

    // Act + Assert: the exit code alone is sufficient to fail closed.
    expect(call).toThrow(REPO_SLUG_UNRESOLVED_PREFIX);
    expect(call).toThrow("exited 4");
  });

  it("throws when the command produces empty output", () => {
    // Arrange: a zero exit with no payload on stdout.
    const call = callWithResult({ stdout: "", stderr: "", code: 0 });

    // Act + Assert
    expect(call).toThrow(REPO_SLUG_UNRESOLVED_PREFIX);
    expect(call).toThrow("empty output");
  });

  it("throws when the output is not valid JSON", () => {
    // Arrange: stdout that JSON.parse rejects.
    const call = callWithResult({
      stdout: "not json at all",
      stderr: "",
      code: 0,
    });

    // Act + Assert
    expect(call).toThrow(REPO_SLUG_UNRESOLVED_PREFIX);
    expect(call).toThrow("unparseable output");
  });

  it("throws when the payload is parseable but is not an object", () => {
    // Arrange: `null` parses successfully yet carries no fields.
    const call = callWithResult({ stdout: "null", stderr: "", code: 0 });

    // Act + Assert
    expect(call).toThrow(REPO_SLUG_UNRESOLVED_PREFIX);
    expect(call).toThrow("is not an object");
  });

  it("throws when the owner and name field is missing", () => {
    // Arrange: an object payload carrying a different field.
    const call = callWithResult({
      stdout: '{"name":"drm-copilot"}',
      stderr: "",
      code: 0,
    });

    // Act + Assert
    expect(call).toThrow(REPO_SLUG_UNRESOLVED_PREFIX);
    expect(call).toThrow("no nameWithOwner field");
  });

  it("throws when the owner and name field is not a string", () => {
    // Arrange: the expected field is present but carries a numeric value.
    const call = callWithResult({
      stdout: '{"nameWithOwner":42}',
      stderr: "",
      code: 0,
    });

    // Act + Assert
    expect(call).toThrow(REPO_SLUG_UNRESOLVED_PREFIX);
    expect(call).toThrow("is not a string");
  });

  it("names the workspace root in the thrown message", () => {
    // Arrange: a workspace root distinct from the one used by the other tests,
    // so the assertion cannot pass on an incidental substring.
    const distinctRoot = "/checkout-that-cannot-be-resolved";
    const runner = makeRecordingRunner([], {
      stdout: "",
      stderr: "",
      code: 1,
    });
    const call = (): string =>
      resolveRepoSlug({
        runner,
        workspaceRoot: distinctRoot,
        ghPathLookup: () => GH_PATH,
      });

    // Act + Assert: the message carries the shared prefix and names the exact
    // workspace root that could not be resolved.
    expect(call).toThrow(REPO_SLUG_UNRESOLVED_PREFIX);
    expect(call).toThrow(distinctRoot);
  });
});
