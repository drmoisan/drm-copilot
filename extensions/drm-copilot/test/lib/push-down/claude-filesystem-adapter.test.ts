import { describe, expect, it } from "@jest/globals";

import {
  ExcludingFileSystem,
  isGeneralMemoryFile,
  readMemoryScope,
} from "../../../src/lib/push-down/claude-filesystem-adapter";
import { buildInMemoryFileSystem } from "./push-down.test-helpers";

describe("readMemoryScope", () => {
  it("returns general for an exact metadata.scope: general value", () => {
    // Arrange
    const content =
      "---\nname: x\nmetadata:\n  type: feedback\n  scope: general\n---\nbody\n";

    // Act / Assert
    expect(readMemoryScope(content)).toBe("general");
  });

  it("returns general for a double-quoted general value", () => {
    // Arrange
    const content = '---\nname: x\nmetadata:\n  scope: "general"\n---\nbody\n';

    // Act / Assert
    expect(readMemoryScope(content)).toBe("general");
  });

  it("returns general for a single-quoted general value", () => {
    // Arrange: exercise the single-quote stripping branch.
    const content = "---\nname: x\nmetadata:\n  scope: 'general'\n---\nbody\n";

    // Act / Assert
    expect(readMemoryScope(content)).toBe("general");
  });

  it("returns general when an inline comment follows the value", () => {
    // Arrange
    const content =
      "---\nname: x\nmetadata:\n  scope: general # distribute\n---\nbody\n";

    // Act / Assert
    expect(readMemoryScope(content)).toBe("general");
  });

  it("returns repo for an exact repo value", () => {
    // Arrange
    const content =
      "---\nname: x\nmetadata:\n  type: project\n  scope: repo\n---\nbody\n";

    // Act / Assert
    expect(readMemoryScope(content)).toBe("repo");
  });

  it("defaults to repo when the scope leaf is absent", () => {
    // Arrange
    const content = "---\nname: x\nmetadata:\n  type: feedback\n---\nbody\n";

    // Act / Assert
    expect(readMemoryScope(content)).toBe("repo");
  });

  it("defaults to repo when the metadata block is absent", () => {
    // Arrange
    const content = "---\nname: x\ntype: feedback\n---\nbody\n";

    // Act / Assert
    expect(readMemoryScope(content)).toBe("repo");
  });

  it("defaults to repo when frontmatter is missing", () => {
    // Arrange
    const content = "# A plain markdown file\n\nNo frontmatter here.\n";

    // Act / Assert
    expect(readMemoryScope(content)).toBe("repo");
  });

  it("defaults to repo when frontmatter has no closing delimiter", () => {
    // Arrange
    const content =
      "---\nname: x\nmetadata:\n  scope: general\nbody without close\n";

    // Act / Assert
    expect(readMemoryScope(content)).toBe("repo");
  });

  it("defaults to repo for any non-general scope value", () => {
    // Arrange
    const content = "---\nname: x\nmetadata:\n  scope: worldwide\n---\nbody\n";

    // Act / Assert
    expect(readMemoryScope(content)).toBe("repo");
  });

  it("ignores a top-level scope outside the metadata block (fail-safe repo)", () => {
    // Arrange: scope is at column zero, not inside metadata.
    const content =
      "---\nname: x\nscope: general\nmetadata:\n  type: feedback\n---\nbody\n";

    // Act / Assert
    expect(readMemoryScope(content)).toBe("repo");
  });
});

describe("isGeneralMemoryFile", () => {
  it("returns true for a general-scoped agent-memory file", () => {
    // Arrange
    const content = "---\nmetadata:\n  scope: general\n---\nbody\n";

    // Act / Assert
    expect(
      isGeneralMemoryFile(".claude/agent-memory/orchestrator/m.md", content),
    ).toBe(true);
  });

  it("returns false for a repo-scoped agent-memory file", () => {
    // Arrange
    const content = "---\nmetadata:\n  scope: repo\n---\nbody\n";

    // Act / Assert
    expect(
      isGeneralMemoryFile(".claude/agent-memory/orchestrator/m.md", content),
    ).toBe(false);
  });

  it("returns true for a file outside the agent-memory subtree regardless of scope", () => {
    // Arrange
    const content = "---\nmetadata:\n  scope: repo\n---\nbody\n";

    // Act / Assert
    expect(isGeneralMemoryFile(".claude/rules/python.md", content)).toBe(true);
  });
});

describe("ExcludingFileSystem", () => {
  it("excludes a hard-excluded settings.local.json from enumeration", () => {
    // Arrange
    const inner = buildInMemoryFileSystem({
      "/repo/.claude/settings.local.json": "{}",
      "/repo/.claude/rules/general.md": "rule",
    });
    const sut = new ExcludingFileSystem(
      inner,
      "/repo",
      [".claude/settings.local.json"],
      { sourceRoot: "/repo" },
    );

    // Act
    const listed = sut.listFiles("/repo/.claude");

    // Assert
    expect(listed).toEqual(["/repo/.claude/rules/general.md"]);
  });

  it("restricts enumeration to the active published set", () => {
    // Arrange
    const inner = buildInMemoryFileSystem({
      "/repo/.claude/rules/general.md": "core rule",
      "/repo/.claude/rules/python.md": "python rule",
    });
    const sut = new ExcludingFileSystem(inner, "/repo", [], {
      sourceRoot: "/repo",
      publishedPaths: new Set([".claude/rules/general.md"]),
    });

    // Act
    const listed = sut.listFiles("/repo/.claude");

    // Assert: only the published path survives the pack filter.
    expect(listed).toEqual(["/repo/.claude/rules/general.md"]);
  });

  it("excludes a non-general agent memory via the scope filter", () => {
    // Arrange
    const inner = buildInMemoryFileSystem({
      "/repo/.claude/agent-memory/o/m.md":
        "---\nmetadata:\n  scope: repo\n---\nbody\n",
      "/repo/.claude/agent-memory/o/g.md":
        "---\nmetadata:\n  scope: general\n---\nbody\n",
    });
    const sut = new ExcludingFileSystem(inner, "/repo", [], {
      sourceRoot: "/repo",
    });

    // Act
    const listed = sut.listFiles("/repo/.claude");

    // Assert: only the general-scoped memory passes the scope filter.
    expect(listed).toEqual(["/repo/.claude/agent-memory/o/g.md"]);
  });

  it("memory mode skip excludes the entire agent-memory subtree", () => {
    // Arrange
    const inner = buildInMemoryFileSystem({
      "/repo/.claude/agent-memory/o/g.md":
        "---\nmetadata:\n  scope: general\n---\nbody\n",
      "/repo/.claude/rules/general.md": "rule",
    });
    const sut = new ExcludingFileSystem(inner, "/repo", [], {
      sourceRoot: "/repo",
      memoryMode: "skip",
    });

    // Act
    const listed = sut.listFiles("/repo/.claude");

    // Assert: the rule survives; all agent memories are dropped.
    expect(listed).toEqual(["/repo/.claude/rules/general.md"]);
  });

  it("memory mode merge excludes only memories already present at destination", () => {
    // Arrange: g1 exists at destination, g2 does not.
    const inner = buildInMemoryFileSystem({
      "/repo/.claude/agent-memory/o/g1.md":
        "---\nmetadata:\n  scope: general\n---\nbody\n",
      "/repo/.claude/agent-memory/o/g2.md":
        "---\nmetadata:\n  scope: general\n---\nbody\n",
      "/dest/.claude/agent-memory/o/g1.md": "existing destination memory",
    });
    const sut = new ExcludingFileSystem(inner, "/repo", [], {
      sourceRoot: "/repo",
      destinationRoot: "/dest",
      memoryMode: "merge",
    });

    // Act
    const listed = sut.listFiles("/repo/.claude");

    // Assert: g1 (present at dest) excluded; g2 (new) included.
    expect(listed).toEqual(["/repo/.claude/agent-memory/o/g2.md"]);
  });

  it("memory mode overwrite includes every general agent memory", () => {
    // Arrange
    const inner = buildInMemoryFileSystem({
      "/repo/.claude/agent-memory/o/g1.md":
        "---\nmetadata:\n  scope: general\n---\nbody\n",
      "/dest/.claude/agent-memory/o/g1.md": "existing",
    });
    const sut = new ExcludingFileSystem(inner, "/repo", [], {
      sourceRoot: "/repo",
      destinationRoot: "/dest",
      memoryMode: "overwrite",
    });

    // Act
    const listed = sut.listFiles("/repo/.claude");

    // Assert
    expect(listed).toEqual(["/repo/.claude/agent-memory/o/g1.md"]);
  });

  it("redirects legacy C# canonical reads to the legacy variant source", () => {
    // Arrange: canonical destination path read should come from the legacy tree.
    const inner = buildInMemoryFileSystem({
      "/bundle/.claude-variants/csharp-legacy/rules/csharp.md": "legacy body",
      "/bundle/.claude/rules/csharp.md": "modern body",
    });
    const sut = new ExcludingFileSystem(inner, "/bundle", [], {
      sourceRoot: "/bundle",
      variantRoot: "/bundle",
      csharpVariant: "legacy",
    });

    // Act
    const text = sut.readTextFile("/bundle/.claude/rules/csharp.md");

    // Assert: the read is served from the legacy variant subtree.
    expect(text).toBe("legacy body");
  });

  it("passes a modern C# read through to the canonical source", () => {
    // Arrange
    const inner = buildInMemoryFileSystem({
      "/bundle/.claude/rules/csharp.md": "modern body",
    });
    const sut = new ExcludingFileSystem(inner, "/bundle", [], {
      sourceRoot: "/bundle",
      variantRoot: "/bundle",
      csharpVariant: "modern",
    });

    // Act / Assert
    expect(sut.readTextFile("/bundle/.claude/rules/csharp.md")).toBe(
      "modern body",
    );
  });

  it("delegates isDir, isFile, writeTextFile, and ensureDir to the inner adapter", () => {
    // Arrange
    const inner = buildInMemoryFileSystem({}, ["/repo/.claude"]);
    const sut = new ExcludingFileSystem(inner, "/repo", [], {
      sourceRoot: "/repo",
    });

    // Act
    sut.ensureDir("/repo/out");
    sut.writeTextFile("/repo/out/a.md", "x");

    // Assert
    expect(sut.isDir("/repo/.claude")).toBe(true);
    expect(sut.isFile("/repo/out/a.md")).toBe(true);
    expect(inner.readTextFile("/repo/out/a.md")).toBe("x");
  });
});
