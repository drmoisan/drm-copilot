import { describe, expect, it } from "@jest/globals";

import { TreeFileSystem } from "./tree-file-system";
import {
  buildExcerptText,
  extractFeaturesFromPaths,
  extractPlanSections,
  extractSpecParts,
  extractStoryParts,
  gatherFeatureExcerpts,
  readTextFile,
  resolveFeatureDir,
} from "../../../src/lib/pr-context/render-feature-excerpts";

/**
 * Tests for the render-variant feature excerpt helpers
 * (`render_feature_excerpts.py`). A tree-backed in-memory `FileSystem` seeds
 * feature trees; the pure helpers are exercised directly.
 */

const ROOT = "/repo";

describe("resolveFeatureDir", () => {
  const base = `${ROOT}/features`;

  it("returns the exact match", () => {
    const fs = new TreeFileSystem();
    fs.addDir(`${base}/my-feature`);
    expect(resolveFeatureDir(fs, base, "my-feature")).toBe(
      `${base}/my-feature`,
    );
  });

  it("matches a strong delimiter pattern", () => {
    const fs = new TreeFileSystem();
    fs.addDir(`${base}/prefix-my-feature-suffix`);
    expect(resolveFeatureDir(fs, base, "my-feature")).toBe(
      `${base}/prefix-my-feature-suffix`,
    );
  });

  it("falls back to a weak substring match", () => {
    const fs = new TreeFileSystem();
    fs.addDir(`${base}/somemyfeaturename`);
    expect(resolveFeatureDir(fs, base, "myfeature")).toBe(
      `${base}/somemyfeaturename`,
    );
  });

  it("returns null when no match exists", () => {
    const fs = new TreeFileSystem();
    fs.addDir(base);
    expect(resolveFeatureDir(fs, base, "nonexistent")).toBeNull();
  });

  it("returns null when the base directory is missing", () => {
    const fs = new TreeFileSystem();
    expect(resolveFeatureDir(fs, `${ROOT}/missing`, "feature")).toBeNull();
  });

  it("ignores files during fuzzy search", () => {
    const fs = new TreeFileSystem();
    fs.addDir(base);
    fs.addFile(`${base}/myfeature-file`, "file not dir");
    expect(resolveFeatureDir(fs, base, "myfeature")).toBeNull();
  });
});

describe("readTextFile", () => {
  it("reads an existing file", () => {
    const fs = new TreeFileSystem();
    fs.addFile(`${ROOT}/test.txt`, "test content");
    expect(readTextFile(fs, `${ROOT}/test.txt`)).toBe("test content");
  });

  it("returns empty for a missing file", () => {
    const fs = new TreeFileSystem();
    expect(readTextFile(fs, `${ROOT}/missing.txt`)).toBe("");
  });
});

describe("extractFeaturesFromPaths", () => {
  it("extracts names from active paths", () => {
    const result = extractFeaturesFromPaths([
      "docs/features/active/feature-a/spec.md",
      "docs/features/active/feature-b/plan.md",
      "docs/features/active/feature-a/user-story.md",
    ]);
    expect(result).toEqual(new Set(["feature-a", "feature-b"]));
  });

  it("ignores non-active paths", () => {
    const result = extractFeaturesFromPaths([
      "docs/features/potential/feature-a/spec.md",
      "README.md",
      "src/module.py",
    ]);
    expect(result).toEqual(new Set());
  });

  it("requires the minimum path depth", () => {
    expect(extractFeaturesFromPaths(["docs/features/active"])).toEqual(
      new Set(),
    );
  });

  it("handles an empty list", () => {
    expect(extractFeaturesFromPaths([])).toEqual(new Set());
  });
});

describe("extractSpecParts", () => {
  it("extracts recognized headings only", () => {
    const result = extractSpecParts(
      "## Context\nCtx\n## Problem\nProb\n## Unknown\nIgnored",
    );
    expect(result).toHaveLength(2);
    expect(result.some((p) => p.includes("Context:"))).toBe(true);
    expect(result.some((p) => p.includes("Problem:"))).toBe(true);
    expect(result.some((p) => p.includes("Unknown:"))).toBe(false);
  });

  it("returns empty when no headings match", () => {
    expect(extractSpecParts("## Unknown\nContent")).toEqual([]);
  });

  it("handles empty input", () => {
    expect(extractSpecParts("")).toEqual([]);
  });
});

describe("extractPlanSections", () => {
  it("extracts completed tasks and the test plan", () => {
    const [planSection, verification] = extractPlanSections(
      "- [x] Task 1\n- [ ] Task 2\n- [x] Task 3\n## Test Plan\nDetails",
    );
    expect(planSection).toContain("Task 1");
    expect(planSection).toContain("Task 3");
    expect(planSection).not.toContain("Task 2");
    expect(verification).toContain("Details");
  });

  it("returns empty plan section when nothing is completed", () => {
    const [planSection] = extractPlanSections("- [ ] Task 1\n- [ ] Task 2");
    expect(planSection).toBe("");
  });

  it("returns empty verification when no test plan exists", () => {
    const [, verification] = extractPlanSections("- [x] Task 1");
    expect(verification).toBe("");
  });
});

describe("extractStoryParts", () => {
  it("extracts statement and problem sections", () => {
    const result = extractStoryParts(
      "## Story Statement\n- As user\n- I want\n## Problem / Why\nBecause",
      "",
    );
    expect(result).toHaveLength(2);
    expect(result[0]).toContain("Story Statement:");
    expect(result[1]).toContain("Problem / Why:");
  });

  it("falls back to the promoted Problem / Why", () => {
    const result = extractStoryParts("", "## Problem / Why\nPromoted problem");
    expect(result).toHaveLength(1);
    expect(result[0]).toContain("Promoted problem");
  });

  it("falls back to the promoted Summary", () => {
    const result = extractStoryParts("", "## Summary\nSummary content");
    expect(result).toHaveLength(1);
    expect(result[0]).toContain("Summary content");
  });

  it("returns empty when nothing is present", () => {
    expect(extractStoryParts("", "")).toEqual([]);
  });
});

describe("buildExcerptText", () => {
  it("includes every provided section", () => {
    const result = buildExcerptText(
      "feat",
      ["Story part"],
      ["Spec part"],
      "Plan part",
      "Verification part",
    );
    expect(result).toContain("Feature doc: feat");
    expect(result).toContain("Story part");
    expect(result).toContain("Spec part");
    expect(result).toContain("Plan part");
    expect(result).toContain("Verification part");
  });

  it("omits empty sections", () => {
    const result = buildExcerptText("feat", [], ["Spec"], "", "");
    expect(result).toContain("Spec");
    expect(result).not.toContain("Story");
    expect(result).not.toContain("Plan");
  });

  it("shows the placeholder when there is no content", () => {
    expect(buildExcerptText("feat", [], [], "", "")).toContain(
      "(no spec/plan/user-story excerpts found)",
    );
  });
});

describe("gatherFeatureExcerpts", () => {
  it("integrates all helpers for a full feature", () => {
    const fs = new TreeFileSystem();
    const dir = `${ROOT}/docs/features/active/test-feature`;
    fs.addDir(dir);
    fs.addFile(`${dir}/spec.md`, "## Context\nCtx\n## Problem\nProb");
    fs.addFile(`${dir}/plan.md`, "- [x] Done\n## Test Plan\nTested");
    fs.addFile(
      `${dir}/user-story.md`,
      "## Story Statement\n- As user\n## Problem / Why\nNeed",
    );

    const result = gatherFeatureExcerpts(fs, ROOT, [
      "docs/features/active/test-feature/spec.md",
    ]);
    expect(result).toHaveLength(1);
    expect(result[0]!.feature).toBe("test-feature");
    expect(result[0]!.excerpt).toContain("Context:");
    expect(result[0]!.excerpt).toContain("Done");
    // Render variant carries no readiness or primary-issue fields.
    expect(result[0]!.readinessSignal).toBeNull();
    expect(result[0]!.primaryIssueRef).toBeNull();
  });

  it("processes multiple features", () => {
    const fs = new TreeFileSystem();
    for (const name of ["feat-a", "feat-b"]) {
      const dir = `${ROOT}/docs/features/active/${name}`;
      fs.addDir(dir);
      fs.addFile(`${dir}/spec.md`, "## Overview\nContent");
    }
    const result = gatherFeatureExcerpts(fs, ROOT, [
      "docs/features/active/feat-a/spec.md",
      "docs/features/active/feat-b/plan.md",
    ]);
    expect(result.map((r) => r.feature)).toEqual(["feat-a", "feat-b"]);
  });

  it("skips features without a directory", () => {
    const fs = new TreeFileSystem();
    const result = gatherFeatureExcerpts(fs, ROOT, [
      "docs/features/active/nonexistent/spec.md",
    ]);
    expect(result).toEqual([]);
  });
});
