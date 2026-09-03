import { describe, expect, it, jest } from "@jest/globals";
import * as path from "node:path";

import {
  createHandoffPathBoundary,
  type HandoffPathFileSystemBoundary,
} from "../../../src/lib/validate/orchestration-handoff-path-boundary";

function normalized(targetPath: string): string {
  return path.resolve(targetPath).replaceAll("\\", "/").replace(/\/+$/, "");
}

function missingPath(): NodeJS.ErrnoException {
  return Object.assign(new Error("Path does not exist."), { code: "ENOENT" });
}

function fakeFileSystem(options: {
  readonly realpaths: Readonly<Record<string, string>>;
  readonly directories: readonly string[];
}): HandoffPathFileSystemBoundary {
  const realpaths = new Map(
    Object.entries(options.realpaths).map(([key, value]) => [
      normalized(key),
      normalized(value),
    ]),
  );
  const directories = new Set(options.directories.map(normalized));
  return {
    realpath: jest.fn((targetPath: string) => {
      const resolved = realpaths.get(normalized(targetPath));
      if (resolved === undefined) throw missingPath();
      return resolved;
    }),
    stat: jest.fn((targetPath: string) => ({
      isDirectory: () => directories.has(normalized(targetPath)),
    })),
  };
}

describe("orchestration handoff canonical path boundary", () => {
  const workspaceAlias = path.resolve("virtual-workspace-alias");
  const workspaceRoot = path.resolve("virtual-workspace-canonical");

  it("resolves an absolute directory workspace to its canonical root", () => {
    // Arrange
    const fileSystem = fakeFileSystem({
      realpaths: { [workspaceAlias]: workspaceRoot },
      directories: [workspaceRoot],
    });

    // Act / Assert
    expect(
      createHandoffPathBoundary(fileSystem).resolveWorkspaceRoot(
        workspaceAlias,
      ),
    ).toBe(normalized(workspaceRoot));
  });

  it("rejects missing, relative, and non-directory workspace roots", () => {
    // Arrange
    const fileSystem = fakeFileSystem({
      realpaths: {
        [workspaceAlias]: workspaceRoot,
      },
      directories: [],
    });
    const boundary = createHandoffPathBoundary(fileSystem);

    // Act / Assert
    expect(boundary.resolveWorkspaceRoot("relative/workspace")).toBeNull();
    expect(boundary.resolveWorkspaceRoot(workspaceAlias)).toBeNull();
    expect(
      boundary.resolveWorkspaceRoot(path.resolve("missing-workspace")),
    ).toBeNull();
  });

  it("resolves ordinary in-root existing and creatable paths", () => {
    // Arrange
    const existingPath = path.join(workspaceRoot, "docs", "plan.md");
    const artifactsPath = path.join(workspaceRoot, "artifacts");
    const fileSystem = fakeFileSystem({
      realpaths: {
        [existingPath]: existingPath,
        [artifactsPath]: artifactsPath,
      },
      directories: [artifactsPath],
    });
    const boundary = createHandoffPathBoundary(fileSystem);

    // Act / Assert
    expect(boundary.resolveExistingTarget(workspaceRoot, "docs/plan.md")).toBe(
      normalized(existingPath),
    );
    expect(
      boundary.resolveCreatableTarget(
        workspaceRoot,
        "artifacts/orchestration/checkpoint.json",
      ),
    ).toBe(
      normalized(
        path.join(
          workspaceRoot,
          "artifacts",
          "orchestration",
          "checkpoint.json",
        ),
      ),
    );
  });

  it("walks missing ancestors to the nearest canonical directory", () => {
    // Arrange
    const fileSystem = fakeFileSystem({
      realpaths: { [workspaceRoot]: workspaceRoot },
      directories: [workspaceRoot],
    });

    // Act
    const resolved = createHandoffPathBoundary(
      fileSystem,
    ).resolveCreatableTarget(workspaceRoot, "missing/parents/checkpoint.json");

    // Assert
    expect(resolved).toBe(
      normalized(
        path.join(workspaceRoot, "missing", "parents", "checkpoint.json"),
      ),
    );
  });

  it("rejects root-prefix collisions after canonical resolution", () => {
    // Arrange
    const candidate = path.join(workspaceRoot, "links", "plan.md");
    const prefixCollision = `${workspaceRoot}-other`;
    const fileSystem = fakeFileSystem({
      realpaths: {
        [candidate]: path.join(prefixCollision, "plan.md"),
      },
      directories: [],
    });

    // Act / Assert
    expect(
      createHandoffPathBoundary(fileSystem).resolveExistingTarget(
        workspaceRoot,
        "links/plan.md",
      ),
    ).toBeNull();
  });

  it("rejects non-normal separators and applies configured case semantics", () => {
    // Arrange
    const candidate = path.join(workspaceRoot, "docs", "plan.md");
    const differentlyCasedTarget = normalized(candidate).toUpperCase();
    const fileSystem = fakeFileSystem({
      realpaths: { [candidate]: differentlyCasedTarget },
      directories: [],
    });

    // Act / Assert
    expect(
      createHandoffPathBoundary(fileSystem, false).resolveExistingTarget(
        workspaceRoot,
        "docs/plan.md",
      ),
    ).toBe(differentlyCasedTarget);
    expect(
      createHandoffPathBoundary(fileSystem, true).resolveExistingTarget(
        workspaceRoot,
        "docs/plan.md",
      ),
    ).toBeNull();
    expect(
      createHandoffPathBoundary(fileSystem, false).resolveExistingTarget(
        workspaceRoot,
        "docs\\plan.md",
      ),
    ).toBeNull();
  });

  it("accepts an in-root link only after resolving its canonical target", () => {
    // Arrange
    const linkPath = path.join(workspaceRoot, "links", "plan.md");
    const targetPath = path.join(workspaceRoot, "docs", "plan.md");
    const fileSystem = fakeFileSystem({
      realpaths: { [linkPath]: targetPath },
      directories: [],
    });

    // Act / Assert
    expect(
      createHandoffPathBoundary(fileSystem).resolveExistingTarget(
        workspaceRoot,
        "links/plan.md",
      ),
    ).toBe(normalized(targetPath));
  });

  it("rejects existing and creatable reparse targets outside the root", () => {
    // Arrange
    const outsideRoot = path.resolve("outside-workspace");
    const existingLink = path.join(workspaceRoot, "links", "plan.md");
    const directoryLink = path.join(workspaceRoot, "linked-directory");
    const fileSystem = fakeFileSystem({
      realpaths: {
        [existingLink]: path.join(outsideRoot, "plan.md"),
        [directoryLink]: outsideRoot,
      },
      directories: [outsideRoot],
    });
    const boundary = createHandoffPathBoundary(fileSystem);

    // Act / Assert
    expect(
      boundary.resolveExistingTarget(workspaceRoot, "links/plan.md"),
    ).toBeNull();
    expect(
      boundary.resolveCreatableTarget(
        workspaceRoot,
        "linked-directory/checkpoint.json",
      ),
    ).toBeNull();
  });
});
