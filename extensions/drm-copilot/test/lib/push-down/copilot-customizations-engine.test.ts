import { describe, expect, it } from "@jest/globals";

import {
  COPILOT_ROOT_FOLDERS,
  enumerateSourceFiles,
  pushDownCustomizations,
} from "../../../src/lib/push-down/copilot-customizations-engine";
import { buildInMemoryFileSystem, fixedClock } from "./push-down.test-helpers";

const CLOCK = fixedClock("2026-06-26T00:15:00.000Z");
const ARTIFACT_PATH =
  "/dest/artifacts/copilot-customizations/push-down-20260626T001500Z.json";

describe("pushDownCustomizations (engine)", () => {
  it("throws when the destination directory does not exist", () => {
    // Arrange: destination root not seeded as a directory.
    const fs = buildInMemoryFileSystem({}, ["/src"]);

    // Act / Assert
    expect(() =>
      pushDownCustomizations({
        repoRoot: "/src",
        destinationRoot: "/dest",
        fs,
        sourceRoot: "/src",
        artifactRoot: "/dest",
        clock: CLOCK,
      }),
    ).toThrow(
      "Invalid destination: destination directory does not exist: /dest",
    );
  });

  it("throws when the destination equals the source repository root", () => {
    // Arrange
    const fs = buildInMemoryFileSystem({}, ["/src"]);

    // Act / Assert
    expect(() =>
      pushDownCustomizations({
        repoRoot: "/src",
        destinationRoot: "/src",
        fs,
        sourceRoot: "/src",
        artifactRoot: "/src",
        clock: CLOCK,
      }),
    ).toThrow(
      "Invalid destination: destination must not be the source repository root: /src",
    );
  });

  it("classifies created vs overwritten and enumerates in root then path order", () => {
    // Arrange: seed files across roots out of order; one destination preexists.
    const fs = buildInMemoryFileSystem(
      {
        "/src/.github/prompts/b.prompt.md": "no references here",
        "/src/.github/prompts/a.prompt.md": "also plain",
        "/src/.github/agents/agent.md": "agent body",
        "/src/.github/skills/s/SKILL.md": "skill body",
        "/dest/.github/agents/agent.md": "old destination content",
      },
      ["/dest"],
    );

    // Act
    const summary = pushDownCustomizations({
      repoRoot: "/src",
      destinationRoot: "/dest",
      fs,
      sourceRoot: "/src",
      artifactRoot: "/dest",
      clock: CLOCK,
    });

    // Assert: agents root first (overwritten), then prompts sorted a,b, then skills.
    expect(summary.files.map((f) => f.relativePath)).toEqual([
      ".github/agents/agent.md",
      ".github/prompts/a.prompt.md",
      ".github/prompts/b.prompt.md",
      ".github/skills/s/SKILL.md",
    ]);
    expect(summary.files[0]!.destinationStatus).toBe("overwritten");
    expect(summary.files[1]!.destinationStatus).toBe("created");
    expect(summary.createdCount).toBe(3);
    expect(summary.overwrittenCount).toBe(1);
  });

  it("accumulates rewrite counters and first-seen unmatched references", () => {
    // Arrange: one known reference and two distinct unknown references.
    const fs = buildInMemoryFileSystem(
      {
        "/src/.github/prompts/a.prompt.md":
          "Run scripts.dev_tools.potential_to_issue here.",
        "/src/.github/skills/s/SKILL.md":
          "Use scripts.dev_tools.unknown_x then scripts.dev_tools.unknown_y.",
      },
      ["/dest"],
    );

    // Act
    const summary = pushDownCustomizations({
      repoRoot: "/src",
      destinationRoot: "/dest",
      fs,
      sourceRoot: "/src",
      artifactRoot: "/dest",
      clock: CLOCK,
    });

    // Assert
    expect(summary.rewrittenReferenceCount).toBe(1);
    expect(summary.placeholderRewriteCount).toBe(0);
    expect(summary.unmatchedReferences).toEqual([
      "scripts.dev_tools.unknown_x",
      "scripts.dev_tools.unknown_y",
    ]);
  });

  it("writes the summary artifact at the deterministic path and returns it", () => {
    // Arrange
    const fs = buildInMemoryFileSystem(
      { "/src/.github/agents/agent.md": "body" },
      ["/dest"],
    );

    // Act
    const summary = pushDownCustomizations({
      repoRoot: "/src",
      destinationRoot: "/dest",
      fs,
      sourceRoot: "/src",
      artifactRoot: "/dest",
      clock: CLOCK,
    });

    // Assert: deterministic artifact path, written through the filesystem.
    expect(summary.artifactPath).toBe(ARTIFACT_PATH);
    expect(fs.isFile(ARTIFACT_PATH)).toBe(true);
  });

  it("copies file content into the destination via the injected filesystem", () => {
    // Arrange
    const fs = buildInMemoryFileSystem(
      { "/src/.github/agents/agent.md": "verbatim body" },
      ["/dest"],
    );

    // Act
    pushDownCustomizations({
      repoRoot: "/src",
      destinationRoot: "/dest",
      fs,
      sourceRoot: "/src",
      artifactRoot: "/dest",
      clock: CLOCK,
    });

    // Assert
    expect(fs.readTextFile("/dest/.github/agents/agent.md")).toBe(
      "verbatim body",
    );
  });

  it("exposes the inlined copilot root-folder enumeration order", () => {
    // Arrange / Act / Assert
    expect(COPILOT_ROOT_FOLDERS).toEqual([
      ".github/agents",
      ".github/instructions",
      ".github/prompts",
      ".github/skills",
    ]);
  });

  it("defaults sourceRoot and artifactRoot to repoRoot when omitted", () => {
    // Arrange: omit sourceRoot and artifactRoot to exercise the repoRoot
    // fallback branches; use the default copilot roots.
    const fs = buildInMemoryFileSystem(
      { "/repo/.github/agents/a.md": "body" },
      ["/dest-omit"],
    );

    // Act
    const summary = pushDownCustomizations({
      repoRoot: "/repo",
      destinationRoot: "/dest-omit",
      fs,
      rootFolders: [".github/agents"],
      clock: CLOCK,
    });

    // Assert: artifact rooted at repoRoot (the default artifact root).
    expect(summary.artifactPath).toBe(
      "/repo/artifacts/copilot-customizations/push-down-20260626T001500Z.json",
    );
    expect(summary.files[0]!.relativePath).toBe(".github/agents/a.md");
  });
});

describe("enumerateSourceFiles", () => {
  it("returns an empty list when a root folder has no files", () => {
    // Arrange: a source root with no files under the requested scoped root.
    const fs = buildInMemoryFileSystem({}, ["/src"]);

    // Act
    const result = enumerateSourceFiles(fs, "/src", [".github/agents"]);

    // Assert
    expect(result).toEqual([]);
  });

  it("treats an empty-string scoped root as the source root itself", () => {
    // Arrange: an empty root folder makes the scoped root equal the source root,
    // exercising the empty-relative join branch and the equal-path relative
    // branch (the file directly under the source root sorts by its full path).
    const fs = buildInMemoryFileSystem({
      "/src/top.md": "top",
      "/src/sub/b.md": "b",
    });

    // Act
    const result = enumerateSourceFiles(fs, "/src", [""]);

    // Assert: both files enumerate, sorted by their source-relative path.
    expect(result).toEqual(["/src/sub/b.md", "/src/top.md"]);
  });

  it("sorts files within a scoped root by their root-relative path", () => {
    // Arrange: nested + top-level files under one scoped root.
    const fs = buildInMemoryFileSystem({
      "/src/.github/agents/z.md": "z",
      "/src/.github/agents/nested/a.md": "a",
    });

    // Act
    const result = enumerateSourceFiles(fs, "/src", [".github/agents"]);

    // Assert: sorted by root-relative POSIX path.
    expect(result).toEqual([
      "/src/.github/agents/nested/a.md",
      "/src/.github/agents/z.md",
    ]);
  });
});
