import { describe, expect, it } from "@jest/globals";

import { TreeFileSystem } from "./tree-file-system";
import {
  completedPlanTasks,
  extractIssueReferences,
  latestGlobPath,
  parseReadinessValue,
  parseSection,
  relativeToPosix,
  resolveFeatureDir,
  resolveReadinessSignal,
} from "../../../src/lib/pr-context/feature-docs-parsers";
import { gatherFeatureExcerpts } from "../../../src/lib/pr-context/feature-docs";

/**
 * Tests for the collector feature-docs port. A tree-backed in-memory
 * `FileSystem` seeds `docs/features/active/<feature>/` trees so discovery,
 * excerpt assembly, primary-issue precedence, readiness selection, and the
 * `context_files` ordering are exercised without touching disk.
 */

const ROOT = "/repo";

describe("parseSection", () => {
  it("extracts content under a heading", () => {
    const md = "## Introduction\nHello\n## Details\nMore info\n## End\nFinal";
    expect(parseSection(md, "Details")).toBe("More info");
  });

  it("returns empty when the heading is absent", () => {
    expect(parseSection("## Introduction\nContent", "Missing")).toBe("");
  });

  it("captures the final heading body", () => {
    expect(parseSection("## First\nOne\n## Last\nTwo", "Last")).toBe("Two");
  });

  it("returns empty for an empty section", () => {
    expect(parseSection("## Empty\n## Next\nContent", "Empty")).toBe("");
  });

  it("escapes special characters in the heading", () => {
    expect(
      parseSection("## Details (v2.0)\nContent here", "Details (v2.0)"),
    ).toBe("Content here");
  });
});

describe("completedPlanTasks", () => {
  it("collects lowercase [x] tasks", () => {
    expect(
      completedPlanTasks("- [x] Task 1\n- [ ] Task 2\n- [x] Task 3"),
    ).toEqual(["Task 1", "Task 3"]);
  });

  it("collects uppercase [X] tasks", () => {
    expect(completedPlanTasks("- [X] Done\n- [ ] Todo")).toEqual(["Done"]);
  });

  it("honors the limit", () => {
    expect(completedPlanTasks("- [x] A\n- [x] B\n- [x] C", 2)).toEqual([
      "A",
      "B",
    ]);
  });

  it("handles asterisk bullets", () => {
    expect(completedPlanTasks("* [x] Task A\n* [ ] Task B")).toEqual([
      "Task A",
    ]);
  });

  it("returns empty when nothing is completed", () => {
    expect(completedPlanTasks("- [ ] Todo 1\n- [ ] Todo 2")).toEqual([]);
  });
});

describe("extractIssueReferences", () => {
  it("extracts GitHub references", () => {
    expect(extractIssueReferences("Relates to #123 and #456")).toEqual([
      "#123",
      "#456",
    ]);
  });

  it("ignores JIRA-style references", () => {
    expect(extractIssueReferences("See ABC-123 and XYZ-456")).toEqual([]);
  });

  it("deduplicates while preserving order", () => {
    expect(extractIssueReferences("#10 again #10 and #10")).toEqual(["#10"]);
  });

  it("returns empty for empty or non-matching text", () => {
    expect(extractIssueReferences("")).toEqual([]);
    expect(extractIssueReferences("Just plain text")).toEqual([]);
  });
});

describe("resolveFeatureDir", () => {
  const base = `${ROOT}/active`;

  it("returns the direct match when present", () => {
    const fs = new TreeFileSystem();
    fs.addDir(`${base}/my-feature`);
    expect(resolveFeatureDir(fs, base, "my-feature")).toBe(
      `${base}/my-feature`,
    );
  });

  it("prefers a strong delimiter match over a weak substring", () => {
    const fs = new TreeFileSystem();
    fs.addDir(`${base}/weak-myfeature-match`);
    fs.addDir(`${base}/strong-my-feature-match`);
    expect(resolveFeatureDir(fs, base, "my-feature")).toBe(
      `${base}/strong-my-feature-match`,
    );
  });

  it("falls back to a weak substring match", () => {
    const fs = new TreeFileSystem();
    fs.addDir(`${base}/somemyfeaturedir`);
    expect(resolveFeatureDir(fs, base, "myfeature")).toBe(
      `${base}/somemyfeaturedir`,
    );
  });

  it("skips files during iteration", () => {
    const fs = new TreeFileSystem();
    fs.addFile(`${base}/my-feature.txt`, "not a dir");
    fs.addDir(`${base}/my-feature-dir`);
    expect(resolveFeatureDir(fs, base, "my-feature")).toBe(
      `${base}/my-feature-dir`,
    );
  });

  it("returns the first sorted strong match", () => {
    const fs = new TreeFileSystem();
    fs.addDir(`${base}/z-my-feature`);
    fs.addDir(`${base}/a-my-feature`);
    fs.addDir(`${base}/m-my-feature`);
    expect(resolveFeatureDir(fs, base, "my-feature")).toBe(
      `${base}/a-my-feature`,
    );
  });

  it("returns null when no match is found", () => {
    const fs = new TreeFileSystem();
    fs.addDir(`${base}/other-feature`);
    expect(resolveFeatureDir(fs, base, "nonexistent")).toBeNull();
  });
});

describe("gatherFeatureExcerpts", () => {
  it("assembles excerpts for a direct match", () => {
    const fs = new TreeFileSystem();
    const dir = `${ROOT}/docs/features/active/test-feature`;
    fs.addDir(dir);
    fs.addDir(`${ROOT}/docs/features/potential/promoted`);
    fs.addFile(
      `${dir}/user-story.md`,
      "## Problem / Why\nAs a user I need this feature...",
    );
    fs.addFile(
      `${dir}/spec.md`,
      "## Overview\nFeature spec.\n## Details\nMore info.",
    );
    fs.addFile(`${dir}/plan.md`, "## Tasks\n- [x] Task 1\n- [ ] Task 2");

    const excerpts = gatherFeatureExcerpts(fs, ROOT, [
      "docs/features/active/test-feature/user-story.md",
    ]);

    expect(excerpts).toHaveLength(1);
    expect(excerpts[0]!.feature).toBe("test-feature");
    expect(excerpts[0]!.excerpt).toContain("As a user I need this feature...");
    expect(excerpts[0]!.excerpt).toContain("Feature spec.");
    expect(excerpts[0]!.excerpt).toContain("Task 1");
  });

  it("resolves a fuzzy feature directory", () => {
    const fs = new TreeFileSystem();
    const dir = `${ROOT}/docs/features/active/my-test-feature-impl`;
    fs.addDir(dir);
    fs.addDir(`${ROOT}/docs/features/potential/promoted`);
    fs.addFile(`${dir}/spec.md`, "## Spec\nData");

    const excerpts = gatherFeatureExcerpts(fs, ROOT, [
      "docs/features/active/my-test-feature-impl/spec.md",
    ]);
    expect(excerpts).toHaveLength(1);
  });

  it("returns no excerpts when the feature directory is absent", () => {
    const fs = new TreeFileSystem();
    fs.addDir(`${ROOT}/docs/features/active`);
    fs.addDir(`${ROOT}/docs/features/potential/promoted`);
    const excerpts = gatherFeatureExcerpts(fs, ROOT, [
      "docs/features/active/nonexistent/user-story.md",
    ]);
    expect(excerpts).toHaveLength(0);
  });

  it("falls back to a promoted feature directory", () => {
    const fs = new TreeFileSystem();
    fs.addDir(`${ROOT}/docs/features/active`);
    const promoted = `${ROOT}/docs/features/potential/promoted/test-feature`;
    fs.addDir(promoted);
    fs.addFile(
      `${promoted}/user-story.md`,
      "## Problem / Why\nPromoted story content",
    );

    const excerpts = gatherFeatureExcerpts(fs, ROOT, [
      "docs/features/active/test-feature/plan.md",
    ]);
    expect(excerpts).toHaveLength(1);
    expect(excerpts[0]!.excerpt).toContain("Promoted story content");
  });

  it("extracts issue references from the combined doc text", () => {
    const fs = new TreeFileSystem();
    const dir = `${ROOT}/docs/features/active/test`;
    fs.addDir(dir);
    fs.addDir(`${ROOT}/docs/features/potential/promoted`);
    fs.addFile(`${dir}/user-story.md`, "Relates to #123 and ABC-456");

    const excerpts = gatherFeatureExcerpts(fs, ROOT, [
      "docs/features/active/test/user-story.md",
    ]);
    expect(excerpts[0]!.issueRefs).toContain("#123");
    expect(excerpts[0]!.issueRefs).not.toContain("ABC-456");
  });

  it("surfaces multiple features sorted by name", () => {
    const fs = new TreeFileSystem();
    for (const name of ["feature-a", "feature-b"]) {
      const dir = `${ROOT}/docs/features/active/${name}`;
      fs.addDir(dir);
      fs.addFile(`${dir}/user-story.md`, `Story for ${name}`);
    }
    fs.addDir(`${ROOT}/docs/features/potential/promoted`);

    const excerpts = gatherFeatureExcerpts(fs, ROOT, [
      "docs/features/active/feature-a/user-story.md",
      "docs/features/active/feature-b/spec.md",
    ]);
    expect(excerpts.map((e) => e.feature)).toEqual(["feature-a", "feature-b"]);
  });

  it("prefers Issue metadata and the newest PASS readiness", () => {
    const fs = new TreeFileSystem();
    const dir = `${ROOT}/docs/features/active/2026-02-22-pr-context-gap-46`;
    fs.addDir(dir);
    fs.addDir(`${ROOT}/docs/features/potential/promoted`);
    fs.addFile(
      `${dir}/spec.md`,
      "- Issue: #46\n## Context\nNarrative #40 #42 should not become primary.\n",
    );
    fs.addFile(
      `${dir}/user-story.md`,
      "## Story Statement\n- Keep metadata.\n",
    );
    fs.addFile(`${dir}/plan.md`, "## Tasks\n- [x] done\n");
    fs.addFile(
      `${dir}/feature-audit.2026-02-22T20-00.md`,
      "Readiness: NEEDS REVISION\n",
    );
    fs.addFile(`${dir}/feature-audit.2026-02-22T21-00.md`, "Readiness: PASS\n");

    const excerpts = gatherFeatureExcerpts(fs, ROOT, [
      "docs/features/active/2026-02-22-pr-context-gap-46/spec.md",
    ]);
    expect(excerpts).toHaveLength(1);
    expect(excerpts[0]!.primaryIssueRef).toBe("#46");
    expect(excerpts[0]!.readinessSignal).toBe("PASS");
  });

  it("recognizes issue.md metadata, a timestamped plan, and a bold readiness marker", () => {
    const fs = new TreeFileSystem();
    const feature = "2026-03-03-extension-name-71";
    const dir = `${ROOT}/docs/features/active/${feature}`;
    fs.addDir(dir);
    fs.addDir(`${ROOT}/docs/features/potential/promoted`);
    fs.addFile(
      `${dir}/issue.md`,
      "# extension-name (Issue #71)\n\n- Issue: #71\n- Work Mode: minor-audit\n",
    );
    fs.addFile(
      `${dir}/plan.2026-03-03T12-35.md`,
      "## Tasks\n- [x] Completed work\n",
    );
    fs.addFile(
      `${dir}/feature-audit.2026-03-03T19-24.md`,
      "## Summary\n\n**Overall feature readiness:** **PASS**\n",
    );

    const excerpts = gatherFeatureExcerpts(fs, ROOT, [
      `docs/features/active/${feature}/issue.md`,
    ]);
    expect(excerpts).toHaveLength(1);
    expect(excerpts[0]!.primaryIssueRef).toBe("#71");
    expect(excerpts[0]!.readinessSignal).toBe("PASS");
    expect(excerpts[0]!.contextFiles).toContain(
      `docs/features/active/${feature}/issue.md`,
    );
    expect(excerpts[0]!.contextFiles).toContain(
      `docs/features/active/${feature}/plan.2026-03-03T12-35.md`,
    );
    expect(excerpts[0]!.contextFiles).toContain(
      `docs/features/active/${feature}/feature-audit.2026-03-03T19-24.md`,
    );
  });
});

describe("relativeToPosix", () => {
  it("returns the path relative to a POSIX root", () => {
    // Arrange / Act
    const result = relativeToPosix("/repo", "/repo/docs/a.md");

    // Assert
    expect(result).toBe("docs/a.md");
  });

  it("normalizes a Windows-style root and path", () => {
    // Arrange / Act
    const result = relativeToPosix("C:\\repo\\", "C:\\repo\\docs\\a.md");

    // Assert
    expect(result).toBe("docs/a.md");
  });

  it("strips a trailing slash from the root", () => {
    // Arrange / Act
    const result = relativeToPosix("/repo/", "/repo/x.md");

    // Assert
    expect(result).toBe("x.md");
  });

  it("returns the leading-slash-stripped path for a path outside the root", () => {
    // Arrange / Act
    const result = relativeToPosix("/repo", "/other/x.md");

    // Assert: Python `relative_to` would raise; this port strips the slash.
    expect(result).toBe("other/x.md");
  });

  it("does not treat a sibling directory sharing the root prefix as inside the root", () => {
    // Arrange / Act
    const result = relativeToPosix("/repo", "/repository/x.md");

    // Assert
    expect(result).toBe("repository/x.md");
  });
});

describe("gatherFeatureExcerpts development-docs root", () => {
  it("reads a .dev active feature when .dev is configured and present", () => {
    // Arrange
    const fs = new TreeFileSystem();
    fs.addFile(
      `${ROOT}/config/orchestration-routing.json`,
      '{"development_docs_root": ".dev"}',
    );
    const dir = `${ROOT}/.dev/active/1016-foo`;
    fs.addDir(`${ROOT}/.dev`);
    fs.addDir(dir);
    fs.addDir(`${ROOT}/.dev/potential/promoted`);
    fs.addFile(`${dir}/spec.md`, "## Overview\nDev spec.");

    // Act
    const excerpts = gatherFeatureExcerpts(fs, ROOT, [
      ".dev/active/1016-foo/spec.md",
    ]);

    // Assert
    expect(excerpts).toHaveLength(1);
    expect(excerpts[0]!.feature).toBe("1016-foo");
    expect(excerpts[0]!.excerpt).toContain("Dev spec.");
  });

  it("recognizes a .dev active path under the default root", () => {
    // Arrange: the matcher accepts both roots; the reader uses docs/features.
    const fs = new TreeFileSystem();
    const dir = `${ROOT}/docs/features/active/1016-foo`;
    fs.addDir(dir);
    fs.addDir(`${ROOT}/docs/features/potential/promoted`);
    fs.addFile(`${dir}/spec.md`, "## Overview\nDefault spec.");

    // Act
    const excerpts = gatherFeatureExcerpts(fs, ROOT, [
      ".dev/active/1016-foo/spec.md",
    ]);

    // Assert
    expect(excerpts.map((excerpt) => excerpt.feature)).toEqual(["1016-foo"]);
  });

  it("reads a folder path with no trailing segment and skips an empty segment", () => {
    // Arrange: one changed path names the folder itself; the other has an empty segment.
    const fs = new TreeFileSystem();
    const dir = `${ROOT}/docs/features/active/1016-foo`;
    fs.addDir(dir);
    fs.addDir(`${ROOT}/docs/features/potential/promoted`);
    fs.addFile(`${dir}/spec.md`, "## Overview\nFolder spec.");

    // Act
    const excerpts = gatherFeatureExcerpts(fs, ROOT, [
      "docs/features/active/1016-foo",
      ".dev/active//spec.md",
    ]);

    // Assert
    expect(excerpts.map((excerpt) => excerpt.feature)).toEqual(["1016-foo"]);
  });
});

describe("feature-docs-parsers glob under the .dev root", () => {
  it("latestGlobPath finds the newest plan file under a .dev feature folder", () => {
    // Arrange: the in-memory glob is the production compileGlob matcher.
    const fs = new TreeFileSystem();
    const dir = `${ROOT}/.dev/active/1016-foo`;
    fs.addFile(`${dir}/plan.2026-11-01T10-00.md`, "# Plan A");
    fs.addFile(`${dir}/plan.2026-11-02T10-00.md`, "# Plan B");

    // Act
    const latest = latestGlobPath(fs, dir, "plan.*.md");

    // Assert
    expect(latest).toBe(`${dir}/plan.2026-11-02T10-00.md`);
  });

  it("resolveReadinessSignal reads a feature audit under a .dev feature folder", () => {
    // Arrange
    const fs = new TreeFileSystem();
    const dir = `${ROOT}/.dev/active/1016-foo`;
    fs.addFile(`${dir}/feature-audit.2026-11-02T10-00.md`, "Readiness: PASS\n");

    // Act
    const [readiness, source] = resolveReadinessSignal(fs, dir);

    // Assert
    expect(readiness).toBe("PASS");
    expect(source).toBe(`${dir}/feature-audit.2026-11-02T10-00.md`);
  });
});

describe("parseReadinessValue", () => {
  it("returns null when the text has no readiness marker", () => {
    expect(parseReadinessValue("## Summary\nNo marker here.\n")).toBeNull();
  });

  it("returns null for a readiness value outside the accepted set", () => {
    expect(parseReadinessValue("Readiness: MAYBE\n")).toBeNull();
  });
});
