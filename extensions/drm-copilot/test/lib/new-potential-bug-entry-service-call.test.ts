import { describe, expect, it } from "@jest/globals";

import { type FileSystem } from "../../src/lib/file-system";
import {
  type CommandResult,
  type CommandRunner,
} from "../../src/lib/subprocess-runner";
import { newPotentialBugEntryServiceCall } from "../../src/lib/new-potential-bug-entry-service-call";

/**
 * Tests for the in-process `newPotentialBugEntryServiceCall` helper (F6). The
 * helper hard-codes a no-op editor launcher, so these tests confirm the
 * preserved return contract and that no editor subprocess is requested. All
 * external interactions are injected; no real subprocess, filesystem, or temp
 * file is used.
 */

/** Map-backed in-memory {@link FileSystem} fake; throws on absent reads. */
class InMemoryFileSystem implements FileSystem {
  readonly files = new Map<string, string>();
  readonly ensuredDirs: string[] = [];

  glob(): string[] {
    return [];
  }

  isFile(path: string): boolean {
    return this.files.has(path);
  }

  readTextFile(path: string): string {
    const content = this.files.get(path);
    if (content === undefined) {
      throw new Error(`File not found: ${path}`);
    }
    return content;
  }

  writeTextFile(path: string, content: string): void {
    this.files.set(path, content);
  }

  ensureDir(path: string): void {
    this.ensuredDirs.push(path);
  }
}

/**
 * Command runner stub that records invocations and returns a successful git
 * config result, so author resolution is deterministic.
 */
function makeRunner(recordedArgs: string[][]): CommandRunner {
  return {
    run(args: readonly string[]): CommandResult {
      recordedArgs.push([...args]);
      // Return a configured author for `git config user.name`.
      return { stdout: "Jane Doe", stderr: "", code: 0 };
    },
  };
}

const TEMPLATE_ROOT = "/ext/resources/feature-templates";
const TEMPLATE = "<bug-name> on YYYY-MM-DD by - Author: name";

describe("newPotentialBugEntryServiceCall", () => {
  it("returns the preserved tool, workspaceRoot, and exact summary", () => {
    // Arrange
    const fs = new InMemoryFileSystem();
    fs.files.set(`${TEMPLATE_ROOT}/bug/potential_bug.md`, TEMPLATE);
    const runner = makeRunner([]);

    // Act
    const result = newPotentialBugEntryServiceCall({
      fileSystem: fs,
      runner,
      workspaceRoot: "/workspace",
      shortName: "api-timeout",
      templateRoot: TEMPLATE_ROOT,
    });

    // Assert
    expect(result.tool).toBe("new_potential_bug_entry");
    expect(result.workspaceRoot).toBe("/workspace");
    expect(result.summary).toBe(
      "Created a new potential bug entry for 'api-timeout'.",
    );
  });

  it("returns artifacts containing the normalized created path", () => {
    // Arrange
    const fs = new InMemoryFileSystem();
    fs.files.set(`${TEMPLATE_ROOT}/bug/potential_bug.md`, TEMPLATE);
    const runner = makeRunner([]);

    // Act
    const result = newPotentialBugEntryServiceCall({
      fileSystem: fs,
      runner,
      workspaceRoot: "/workspace",
      shortName: "api-timeout",
      templateRoot: TEMPLATE_ROOT,
    });

    // Assert: a single artifact whose normalized path is the created file.
    expect(result.artifacts).toHaveLength(1);
    expect(result.artifacts?.[0]).toMatch(
      /\/workspace\/docs\/features\/potential\/\d{4}-\d{2}-\d{2}-api-timeout\.md$/,
    );
  });

  it("uses a no-op launcher so the manual-open warning lines are emitted (no subprocess launch)", () => {
    // Arrange: capture log output and any runner invocations.
    const fs = new InMemoryFileSystem();
    fs.files.set(`${TEMPLATE_ROOT}/bug/potential_bug.md`, TEMPLATE);
    const recordedArgs: string[][] = [];
    const runner = makeRunner(recordedArgs);
    const logged: string[] = [];

    // Act
    newPotentialBugEntryServiceCall({
      fileSystem: fs,
      runner,
      workspaceRoot: "/workspace",
      shortName: "api-timeout",
      templateRoot: TEMPLATE_ROOT,
      log: (message) => logged.push(message),
    });

    // Assert: the no-op launcher path emits the two warning lines, proving the
    // editor launch was skipped.
    expect(logged[0]).toBe(
      "WARNING: VS Code 'code' command not found. Open file manually:",
    );
    expect(logged[1]).toMatch(/^ {2}\/workspace\/docs\/features\/potential\//);
    // The only runner invocation is the git author lookup; no `code` launch.
    for (const args of recordedArgs) {
      expect(args[0]).not.toMatch(/code/);
    }
    expect(recordedArgs.some((args) => args[0] === "git")).toBe(true);
  });

  it("propagates the validation error for an invalid short name", () => {
    // Arrange
    const fs = new InMemoryFileSystem();
    const runner = makeRunner([]);

    // Act / Assert
    expect(() =>
      newPotentialBugEntryServiceCall({
        fileSystem: fs,
        runner,
        workspaceRoot: "/workspace",
        shortName: "Invalid Name",
        templateRoot: TEMPLATE_ROOT,
      }),
    ).toThrow(
      "Aborted: 'Invalid Name' is invalid. Use kebab-case letters/numbers only (e.g., api-timeout).",
    );
  });
});
