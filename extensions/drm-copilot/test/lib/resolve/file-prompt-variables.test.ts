import { describe, expect, it } from "@jest/globals";

import type { FileSystem } from "../../../src/lib/file-system";
import {
  applyMinorAuditOverrides,
  insertAfterHeading,
  removeLinesReferencingVariable,
  removeUserStoryClauseWhenMissing,
  replaceAllVariables,
  resolveFeatureFoldername,
  resolveFolderpath,
  resolveNameFromFeatureFoldername,
  resolveResearchValue,
  resolveSpecPath,
  resolveUserStoryValue,
  resolveWorkModeFromIssue,
  splitPathPlatformAgnostic,
  stripFrontMatter,
  tryRelativeToWorkspace,
} from "../../../src/lib/resolve/file-prompt-variables";

/**
 * In-memory {@link FileSystem} fake keyed on POSIX paths.
 *
 * `isFile` and `readTextFile` consult the seeded map; `glob`/`writeTextFile`/
 * `ensureDir` are recording stubs so the resolver helpers remain hermetic.
 */
function createFakeFileSystem(files: Readonly<Record<string, string>>): {
  fs: FileSystem;
  writes: Array<{ path: string; content: string }>;
  ensured: string[];
} {
  const store = new Map<string, string>(Object.entries(files));
  const writes: Array<{ path: string; content: string }> = [];
  const ensured: string[] = [];
  const fs: FileSystem = {
    glob: () => [],
    isFile: (path: string) => store.has(path),
    readTextFile: (path: string) => {
      const content = store.get(path);
      if (content === undefined) {
        throw new Error(`ENOENT: ${path}`);
      }
      return content;
    },
    writeTextFile: (path: string, content: string) => {
      writes.push({ path, content });
      store.set(path, content);
    },
    ensureDir: (path: string) => {
      ensured.push(path);
    },
  };
  return { fs, writes, ensured };
}

describe("file-prompt-variables stripFrontMatter", () => {
  it("removes a leading YAML front-matter block", () => {
    // Arrange
    const content = "---\ntitle: x\n---\n# Heading\nbody";

    // Act
    const result = stripFrontMatter(content);

    // Assert
    expect(result).toBe("# Heading\nbody");
  });

  it("passes through content without front matter unchanged", () => {
    // Arrange
    const content = "# Heading\nbody";

    // Act
    const result = stripFrontMatter(content);

    // Assert
    expect(result).toBe("# Heading\nbody");
  });
});

describe("file-prompt-variables path helpers", () => {
  it("splits a path on either separator dropping empties", () => {
    // Arrange / Act
    const parts = splitPathPlatformAgnostic("a\\b//c");

    // Assert
    expect(parts).toEqual(["a", "b", "c"]);
  });

  it("computes ${file} as a workspace-relative forward-slash path", () => {
    // Arrange
    const target = "C:/workspace/docs/features/active/feature-1/plan.md";

    // Act
    const relative = tryRelativeToWorkspace(target, "C:/workspace");

    // Assert
    expect(relative).toBe("docs/features/active/feature-1/plan.md");
  });

  it("falls back to the full target path when outside the workspace", () => {
    // Arrange
    const target = "D:/other/plan.md";

    // Act
    const relative = tryRelativeToWorkspace(target, "C:/workspace");

    // Assert
    expect(relative).toBe("D:/other/plan.md");
  });

  it("converts backslashes to forward slashes for the relative path", () => {
    // Arrange
    const target = "C:\\workspace\\docs\\plan.md";

    // Act
    const relative = tryRelativeToWorkspace(target, "C:\\workspace");

    // Assert
    expect(relative).toBe("docs/plan.md");
  });

  it("resolves folderpath as the workspace-relative parent", () => {
    // Arrange
    const target = "C:/workspace/docs/features/active/feature-1/plan.md";

    // Act
    const folderpath = resolveFolderpath(target, "C:/workspace");

    // Assert
    expect(folderpath).toBe("docs/features/active/feature-1");
  });
});

describe("file-prompt-variables feature foldername and name", () => {
  it("derives the feature foldername from a versioned v2 leaf parent", () => {
    // Arrange
    const folderpath = "docs/features/active/2026-01-02-port-cmd-240/v2";

    // Act
    const featureFoldername = resolveFeatureFoldername(folderpath);

    // Assert
    expect(featureFoldername).toBe("2026-01-02-port-cmd-240");
  });

  it("throws when folderpath is empty", () => {
    // Arrange / Act / Assert
    expect(() => resolveFeatureFoldername("")).toThrow("folderpath is empty");
  });

  it("extracts ${name} from a dated feature foldername", () => {
    // Arrange
    const featureFoldername = "2026-01-02-port-cmd-240";

    // Act
    const name = resolveNameFromFeatureFoldername(featureFoldername);

    // Assert
    expect(name).toBe("port-cmd");
  });

  it("returns the whole foldername when it does not match the dated pattern", () => {
    // Arrange
    const featureFoldername = "feature-123";

    // Act
    const name = resolveNameFromFeatureFoldername(featureFoldername);

    // Assert
    expect(name).toBe("feature-123");
  });
});

describe("file-prompt-variables spec/user-story/research resolution", () => {
  it("resolves ${spec} to <folderpath>/spec.md", () => {
    // Arrange / Act
    const spec = resolveSpecPath("docs/features/active/feature-1");

    // Assert
    expect(spec).toBe("docs/features/active/feature-1/spec.md");
  });

  it("resolves ${user-story} to the path when the file exists", () => {
    // Arrange
    const { fs } = createFakeFileSystem({
      "C:/workspace/docs/feature-1/user-story.md": "story",
    });

    // Act
    const value = resolveUserStoryValue("docs/feature-1", "C:/workspace", fs);

    // Assert
    expect(value).toBe("docs/feature-1/user-story.md");
  });

  it("annotates ${user-story} as missing when the file is absent", () => {
    // Arrange
    const { fs } = createFakeFileSystem({});

    // Act
    const value = resolveUserStoryValue("docs/feature-1", "C:/workspace", fs);

    // Assert
    expect(value).toBe("docs/feature-1/user-story.md (missing)");
  });

  it("resolves ${research} when research.md exists", () => {
    // Arrange
    const { fs } = createFakeFileSystem({
      "C:/workspace/docs/feature-1/research.md": "r",
    });

    // Act
    const value = resolveResearchValue("docs/feature-1", "C:/workspace", fs);

    // Assert
    expect(value).toBe("docs/feature-1/research.md");
  });

  it("returns null for ${research} when research.md is missing", () => {
    // Arrange
    const { fs } = createFakeFileSystem({});

    // Act
    const value = resolveResearchValue("docs/feature-1", "C:/workspace", fs);

    // Assert
    expect(value).toBeNull();
  });
});

describe("file-prompt-variables work-mode resolution from issue.md", () => {
  it("resolves minor-audit with a none reason when the marker is present", () => {
    // Arrange
    const { fs } = createFakeFileSystem({
      "C:/workspace/docs/feature-1/issue.md": "- Work Mode: minor-audit\n",
    });

    // Act
    const result = resolveWorkModeFromIssue(
      "docs/feature-1",
      "C:/workspace",
      fs,
    );

    // Assert
    expect(result).toEqual({ mode: "minor-audit", fallbackReason: "none" });
  });

  it("fails closed to full-feature when issue.md is missing", () => {
    // Arrange
    const { fs } = createFakeFileSystem({});

    // Act
    const result = resolveWorkModeFromIssue(
      "docs/feature-1",
      "C:/workspace",
      fs,
    );

    // Assert
    expect(result.mode).toBe("full-feature");
    expect(result.fallbackReason).toBe(
      "issue.md missing; fail closed to full-feature",
    );
  });

  it("fails closed to full-feature when the marker is malformed", () => {
    // Arrange
    const { fs } = createFakeFileSystem({
      "C:/workspace/docs/feature-1/issue.md": "- Work Mode: bogus\n",
    });

    // Act
    const result = resolveWorkModeFromIssue(
      "docs/feature-1",
      "C:/workspace",
      fs,
    );

    // Assert
    expect(result.mode).toBe("full-feature");
    expect(result.fallbackReason).toBe(
      "issue.md Work Mode marker malformed; fail closed to full-feature",
    );
  });

  it("normalizes legacy full to full-feature", () => {
    // Arrange
    const { fs } = createFakeFileSystem({
      "C:/workspace/docs/feature-1/issue.md": "- Work Mode: full\n",
    });

    // Act
    const result = resolveWorkModeFromIssue(
      "docs/feature-1",
      "C:/workspace",
      fs,
    );

    // Assert
    expect(result.mode).toBe("full-feature");
    expect(result.fallbackReason).toBe(
      "issue.md Work Mode marker uses legacy full; normalized to full-feature",
    );
  });
});

describe("file-prompt-variables transforms", () => {
  it("removes the user-story clause when missing", () => {
    // Arrange
    const template = "Read the `${spec}` and the `${user-story}` carefully.";

    // Act
    const result = removeUserStoryClauseWhenMissing(template);

    // Assert
    expect(result).toBe("Read the `${spec}` carefully.");
  });

  it("removes lines referencing a variable while preserving other line endings", () => {
    // Arrange
    const template = "keep line\nresearch: ${research}\nkeep tail\n";

    // Act
    const result = removeLinesReferencingVariable(template, "research");

    // Assert
    expect(result).toBe("keep line\nkeep tail\n");
  });

  it("injects the minor-audit override block after Core Requirements", () => {
    // Arrange
    const template =
      "## Core Requirements\n\n- Use `${spec}`\n- Read `${user-story}`\n- See `${research}`\n";

    // Act
    const result = applyMinorAuditOverrides(template);

    // Assert
    expect(result).toContain("### Minor-Audit Mode Overrides (Mandatory)");
    expect(result).toContain(
      "- Use `${folderpath}/issue.md` as the sole requirements source.",
    );
    expect(result).toContain("  - Phase 0 — Baseline Capture");
    expect(result).toContain(
      "  - Phase 1 — Handoff to small-path planning/development agent",
    );
    expect(result).toContain("  - Phase 2 — Final QC loop");
    // Spec/user-story/research requirement lines are removed.
    expect(result).not.toContain("- Use `${spec}`");
    expect(result).not.toContain("- Read `${user-story}`");
    expect(result).not.toContain("- See `${research}`");
  });

  it("raises on unresolved variables in replaceAllVariables", () => {
    // Arrange
    const template = "value is ${file} and ${missing}";

    // Act / Assert
    expect(() => replaceAllVariables(template, { file: "x" })).toThrow(
      "Unresolved template variables: missing",
    );
  });

  it("raises when a substitution value reintroduces a placeholder", () => {
    // Arrange: substituting ${a} with a value containing ${b} leaves a
    // placeholder, tripping the post-substitution safety check.
    const template = "${a}";

    // Act / Assert
    expect(() => replaceAllVariables(template, { a: "${b}" })).toThrow(
      "Template resolution failed: unresolved placeholders remain",
    );
  });

  it("returns an empty string when removing lines from empty content", () => {
    // Arrange / Act
    const result = removeLinesReferencingVariable("", "research");

    // Assert
    expect(result).toBe("");
  });

  it("inserts a block lacking a trailing newline after the heading", () => {
    // Arrange
    const template = "## Section\nbody\n";

    // Act
    const result = insertAfterHeading(template, "## Section", "INSERTED");

    // Assert
    expect(result).toBe("## Section\nINSERTED\nbody\n");
  });

  it("returns the original template when the heading is not found", () => {
    // Arrange
    const template = "## Other\nbody\n";

    // Act
    const result = insertAfterHeading(template, "## Section", "INSERTED\n");

    // Assert
    expect(result).toBe(template);
  });
});
