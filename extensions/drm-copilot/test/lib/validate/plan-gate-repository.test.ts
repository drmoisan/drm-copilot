import { describe, expect, it } from "@jest/globals";

import type {
  CommandResult,
  CommandRunner,
} from "../../../src/lib/subprocess-runner";
import { CommandRunnerPlanGateRepository } from "../../../src/lib/validate/plan-gate-discrimination";

/**
 * In-memory command runner recording every argv it is handed.
 *
 * Lets the adapter test assert the exact `git` argv lists without spawning a
 * subprocess or touching the filesystem.
 */
class RecordingRunner implements CommandRunner {
  public readonly calls: string[][] = [];

  public constructor(
    private readonly outputs: Readonly<Record<string, string>> = {},
  ) {}

  public run(args: readonly string[]): CommandResult {
    const recorded = [...args];
    this.calls.push(recorded);
    const key = recorded[1] ?? "";
    return { stdout: this.outputs[key] ?? "", stderr: "", code: 0 };
  }
}

describe("CommandRunnerPlanGateRepository", () => {
  it("records the git argv issued by the adapter", () => {
    // Arrange
    const runner = new RecordingRunner({
      grep: "scripts/dev_tools/foo.py",
      "ls-files": "scripts/dev_tools/foo.py",
      show: "committed text",
    });
    const adapter = new CommandRunnerPlanGateRepository("/workspace", runner);

    // Act
    const matches = adapter.filesContaining("pinned items occupy");
    const trackedFile = adapter.isTrackedFile("scripts/dev_tools/foo.py");
    const trackedDirectory = adapter.isTrackedDirectory("scripts/dev_tools");
    const committed = adapter.readTrackedText("scripts/dev_tools/foo.py");

    // Assert: the same four argv arrays the Python adapter issues, in order.
    expect(runner.calls).toEqual([
      ["git", "grep", "-F", "-l", "--", "pinned items occupy"],
      ["git", "ls-files", "--", "scripts/dev_tools/foo.py"],
      ["git", "ls-files", "--", "scripts/dev_tools"],
      ["git", "show", "HEAD:scripts/dev_tools/foo.py"],
    ]);
    expect(runner.calls).toHaveLength(4);
    expect(matches).toEqual(["scripts/dev_tools/foo.py"]);
    expect(trackedFile).toBe(true);
    expect(trackedDirectory).toBe(true);
    expect(committed).toBe("committed text");
  });

  it("answers every query negatively when git returns no output", () => {
    // Arrange
    const runner = new RecordingRunner();
    const adapter = new CommandRunnerPlanGateRepository(".", runner);

    // Act / Assert
    expect(adapter.filesContaining("absent literal")).toEqual([]);
    expect(adapter.isTrackedFile("scripts/dev_tools/foo.py")).toBe(false);
    expect(adapter.isTrackedDirectory("scripts/dev_tools/")).toBe(false);
    expect(adapter.readTrackedText("scripts/dev_tools/foo.py")).toBe("");
  });

  it("normalizes backslash paths before querying git", () => {
    // Arrange
    const runner = new RecordingRunner({ "ls-files": "src/lib/foo.ts" });
    const adapter = new CommandRunnerPlanGateRepository("/workspace", runner);

    // Act
    const tracked = adapter.isTrackedFile("src\\lib\\foo.ts");

    // Assert
    expect(tracked).toBe(true);
    expect(runner.calls[0]).toEqual([
      "git",
      "ls-files",
      "--",
      "src/lib/foo.ts",
    ]);
  });

  it("treats a non-zero git exit as a negative answer", () => {
    // Arrange
    const failing: CommandRunner = {
      run: () => ({ stdout: "noise", stderr: "fatal", code: 128 }),
    };
    const adapter = new CommandRunnerPlanGateRepository("/workspace", failing);

    // Act / Assert
    expect(adapter.filesContaining("literal")).toEqual([]);
    expect(adapter.isTrackedFile("src/lib/foo.ts")).toBe(false);
    expect(adapter.isTrackedDirectory("src/lib")).toBe(false);
    expect(adapter.readTrackedText("src/lib/foo.ts")).toBe("");
  });

  it("reports a path that lists only descendants as a tracked directory", () => {
    // Arrange
    const runner = new RecordingRunner({
      "ls-files": "src/lib/foo.ts\nsrc/lib/bar.ts",
    });
    const adapter = new CommandRunnerPlanGateRepository("/workspace", runner);

    // Act / Assert
    expect(adapter.isTrackedDirectory("src/lib")).toBe(true);
    expect(adapter.isTrackedFile("src/lib")).toBe(false);
  });
});
