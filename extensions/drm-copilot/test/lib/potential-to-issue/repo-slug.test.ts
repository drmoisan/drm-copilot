import { describe, expect, it } from "@jest/globals";

import {
  type CommandResult,
  type CommandRunOptions,
  type CommandRunner,
} from "../../../src/lib/subprocess-runner";
import { resolveRepoSlug } from "../../../src/lib/potential-to-issue/repo-slug";

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
