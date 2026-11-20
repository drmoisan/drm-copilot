import { describe, expect, it } from "@jest/globals";

import {
  createMigrationGit,
  MIGRATION_GIT_MAX_BUFFER,
} from "../../../src/lib/development-docs-migration/migration-git";
import { FakeCommandRunner } from "./migration-test-fakes";

describe("createMigrationGit", () => {
  it("lists tracked files with -z, the pathspecs, the cwd and the buffer limit", () => {
    // Arrange
    const runner = new FakeCommandRunner(() => ({
      stdout: "docs/features/a.md\0docs/features/my file.md\0",
      stderr: "",
      code: 0,
    }));
    const git = createMigrationGit(runner, "/work");

    // Act
    const files = git.listTrackedFiles(["docs", "README.md"]);

    // Assert: NUL splitting keeps the path that contains a space intact.
    expect(files).toEqual(["docs/features/a.md", "docs/features/my file.md"]);
    expect(runner.calls).toEqual([
      {
        args: ["git", "ls-files", "-z", "--", "docs", "README.md"],
        options: { cwd: "/work", maxBuffer: MIGRATION_GIT_MAX_BUFFER },
      },
    ]);
  });

  it("lists untracked files with --others and the buffer limit", () => {
    // Arrange
    const runner = new FakeCommandRunner(() => ({
      stdout: "docs/features/active/x/scratch.log\0",
      stderr: "",
      code: 0,
    }));
    const git = createMigrationGit(runner, "/work");

    // Act
    const files = git.listUntrackedFiles(["docs/features"]);

    // Assert
    expect(files).toEqual(["docs/features/active/x/scratch.log"]);
    expect(runner.calls[0]).toEqual({
      args: ["git", "ls-files", "-z", "--others", "--", "docs/features"],
      options: { cwd: "/work", maxBuffer: MIGRATION_GIT_MAX_BUFFER },
    });
  });

  it("reports uncommitted tracked changes from porcelain output", () => {
    // Arrange
    const dirty = new FakeCommandRunner(() => ({
      stdout: " M README.md\0",
      stderr: "",
      code: 0,
    }));
    const clean = new FakeCommandRunner();

    // Act
    const dirtyResult = createMigrationGit(
      dirty,
      "/w",
    ).hasUncommittedTrackedChanges();
    const cleanResult = createMigrationGit(
      clean,
      "/w",
    ).hasUncommittedTrackedChanges();

    // Assert
    expect(dirtyResult).toBe(true);
    expect(cleanResult).toBe(false);
    expect(dirty.calls[0]?.args).toEqual([
      "git",
      "status",
      "--porcelain",
      "-z",
      "--untracked-files=no",
    ]);
    expect(dirty.calls[0]?.options?.cwd).toBe("/w");
  });

  it("moves with git mv and the -- separator", () => {
    // Arrange
    const runner = new FakeCommandRunner();
    const git = createMigrationGit(runner, "/w");

    // Act
    git.move("docs/features/active", ".dev/active");

    // Assert
    expect(runner.calls[0]).toEqual({
      args: ["git", "mv", "--", "docs/features/active", ".dev/active"],
      options: { cwd: "/w", allowError: true },
    });
  });

  it("raises when git mv exits non-zero", () => {
    // Arrange
    const runner = new FakeCommandRunner(() => ({
      stdout: "",
      stderr: "fatal: destination exists",
      code: 128,
    }));
    const git = createMigrationGit(runner, "/w");

    // Act / Assert
    expect(() => git.move("a", "b")).toThrow(
      "git mv a b failed (128): fatal: destination exists",
    );
  });

  it("reports a work tree only for a zero exit that prints true", () => {
    // Arrange
    const inside = new FakeCommandRunner(() => ({
      stdout: "true",
      stderr: "",
      code: 0,
    }));
    const outside = new FakeCommandRunner(() => ({
      stdout: "",
      stderr: "fatal: not a git repository",
      code: 128,
    }));

    // Act
    const insideResult = createMigrationGit(inside, "/w").isInsideWorkTree();
    const outsideResult = createMigrationGit(outside, "/w").isInsideWorkTree();

    // Assert
    expect(insideResult).toBe(true);
    expect(outsideResult).toBe(false);
    expect(inside.calls[0]).toEqual({
      args: ["git", "rev-parse", "--is-inside-work-tree"],
      options: { cwd: "/w", allowError: true },
    });
  });
});
