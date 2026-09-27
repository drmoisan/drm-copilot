import { describe, expect, it } from "@jest/globals";

import { TreeFileSystem } from "./tree-file-system";
import {
  type CommandResult,
  type CommandRunner,
  type CommandRunOptions,
} from "../../../src/lib/subprocess-runner";
import { collectPrContext } from "../../../src/lib/pr-context/collector-core";

/**
 * Test for `collectPrContext` when the `whichGh` option is omitted entirely.
 *
 * Purpose:
 *     Confirm that `GhClient`'s own default resolver (`() => undefined`) runs
 *     when the caller supplies no `whichGh` property at all, so `collectPrContext`
 *     reports gh unavailable without ever invoking the `gh` executable. Every
 *     other test in `collector-core.test.ts` supplies an explicit `whichGh` key,
 *     leaving this branch of the ternary at
 *     `...(whichGh === undefined ? {} : { whichGh })` untested.
 */

const ROOT = "/repo";

/**
 * Fake `CommandRunner` that records every invoked argv and always returns a
 * successful, empty result regardless of the command. No real process is
 * spawned.
 */
class RecordingRunner implements CommandRunner {
  readonly calls: (readonly string[])[] = [];

  /**
   * @param args Argument vector.
   * @param _options Ignored run options.
   * @returns A fixed, always-successful empty result.
   */
  run(args: readonly string[], _options?: CommandRunOptions): CommandResult {
    void _options;
    this.calls.push(args);
    return { stdout: "", stderr: "", code: 0 };
  }
}

describe("collectPrContext (whichGh option omitted)", () => {
  it("falls back to the default whichGh resolver and reports gh unavailable", () => {
    // Arrange: a minimal repo fixture (only a `.git` marker) and a runner that
    // always succeeds, so `GitClient.resolveRoot()` never shells out.
    const fs = new TreeFileSystem();
    fs.addFile(`${ROOT}/.git`, "");
    const runner = new RecordingRunner();

    // Act: call collectPrContext with no `whichGh` property present anywhere in
    // the options object, exercising GhClient's own default resolver.
    const result = collectPrContext({
      base: "main",
      head: "feature/x",
      repoRoot: ROOT,
      includeUntracked: false,
      fs,
      runner,
    });

    // Assert: the default resolver ran (returning undefined), so gh is reported
    // unavailable with the "not installed" message, and no "gh" command ever
    // reached the runner.
    expect(result.ghAvailable).toBe(false);
    expect(result.ghStatusOverride).toContain(
      "GitHub CLI (gh) is not installed.",
    );
    expect(runner.calls.some((argv) => argv[0] === "gh")).toBe(false);
  });
});
