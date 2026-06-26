/**
 * Unit tests for `src/lib/new-active-feature-folder/flow.ts` `createActiveFolder`.
 *
 * Mirrors the scenarios in `tests/scripts/dev_tools/test_new_active_feature_folder*.py`
 * and the templates test. Hermetic: a `Map`-backed `FolderFileSystem` fake
 * (pre-seeded with template trees and optional potential files), a fake
 * `issueFetcher`, a fake `codeLauncher`, a fixed `nowProvider`, and an `emit`
 * capture array. No real gh/git/filesystem/temp files/code. AAA.
 */

import { describe, expect, it } from "@jest/globals";

import { createActiveFolder } from "../../../src/lib/new-active-feature-folder/flow";
import {
  type IssueMeta,
  PLAN_TIMESTAMP_TEMPLATE_NAME,
} from "../../../src/lib/new-active-feature-folder/models";
import { FakeFolderFileSystem } from "./fakes";

const WORKSPACE = "/ws";
const TEMPLATE_ROOT = "/ws/templates";
const FIXED_INSTANT = new Date("2024-02-03T09:05:00Z");
const FIXED_STAMP = "2024-02-03T04-05";

/**
 * Seed a feature template tree (user-story/spec/plan templates) under a type.
 *
 * @param fs Filesystem fake.
 * @param featureType Template type directory.
 */
function seedFeatureTemplate(
  fs: FakeFolderFileSystem,
  featureType: string,
): void {
  const dir = `${TEMPLATE_ROOT}/${featureType}`;
  fs.seed(`${dir}/user-story.md`, "# <feature-name>\n");
  fs.seed(`${dir}/spec.md`, "# <feature-name>\n\n## Test Strategy\n\n");
  fs.seed(
    `${dir}/${PLAN_TIMESTAMP_TEMPLATE_NAME}`,
    "# <feature-name>\n- Last Updated: <yyyy-MM-ddTHH-mm>\n",
  );
}

describe("createActiveFolder validation", () => {
  it("throws for an invalid type", () => {
    // Arrange / Act / Assert
    expect(() =>
      createActiveFolder({
        featureName: "notes",
        featureType: "maintenance",
        templateRoot: TEMPLATE_ROOT,
        fs: new FakeFolderFileSystem(),
        workspace: WORKSPACE,
      }),
    ).toThrow("Type must be one of: feature, refactor, epic, bug");
  });

  it("throws when no feature name and no active file are provided", () => {
    // Arrange / Act / Assert
    expect(() =>
      createActiveFolder({
        featureName: null,
        templateRoot: TEMPLATE_ROOT,
        fs: new FakeFolderFileSystem(),
        workspace: WORKSPACE,
      }),
    ).toThrow(
      "feature_name must be provided when --active-file-for-feature-name is not used",
    );
  });

  it("throws the auto-resolve error for an active file outside promoted", () => {
    // Arrange
    const fs = new FakeFolderFileSystem();

    // Act / Assert
    expect(() =>
      createActiveFolder({
        featureName: null,
        activeFileForFeatureName: "docs/features/potential/notes.md",
        templateRoot: TEMPLATE_ROOT,
        fs,
        workspace: WORKSPACE,
      }),
    ).toThrow(
      "Select a promoted issue markdown file under docs/features/potential/promoted or supply --feature-name directly.",
    );
  });

  it("resolves the feature name from a valid promoted active file", () => {
    // Arrange
    const fs = new FakeFolderFileSystem();
    seedFeatureTemplate(fs, "feature");
    const promoted = `${WORKSPACE}/docs/features/potential/promoted/notes-feature.md`;
    fs.seed(promoted, "# notes-feature\n");
    const emitted: string[] = [];

    // Act
    createActiveFolder({
      featureName: null,
      activeFileForFeatureName:
        "docs/features/potential/promoted/notes-feature.md",
      templateRoot: TEMPLATE_ROOT,
      fs,
      workspace: WORKSPACE,
      nowProvider: () => FIXED_INSTANT,
      codeLauncher: () => true,
      emit: (line) => emitted.push(line),
    });

    // Assert
    expect(emitted).toContain("Feature name source: active-file");
  });

  it("throws when the template dir is missing", () => {
    // Arrange
    const fs = new FakeFolderFileSystem();

    // Act / Assert
    expect(() =>
      createActiveFolder({
        featureName: "notes",
        templateRoot: TEMPLATE_ROOT,
        fs,
        workspace: WORKSPACE,
      }),
    ).toThrow(`Template folder not found: ${TEMPLATE_ROOT}/feature`);
  });

  it("throws when the target exists without force and proceeds with force", () => {
    // Arrange
    const fs = new FakeFolderFileSystem();
    seedFeatureTemplate(fs, "feature");
    const target = `${WORKSPACE}/docs/features/active/notes`;
    fs.seed(`${target}/existing.md`, "x");

    // Act / Assert: without force it throws.
    expect(() =>
      createActiveFolder({
        featureName: "notes",
        templateRoot: TEMPLATE_ROOT,
        fs,
        workspace: WORKSPACE,
        nowProvider: () => FIXED_INSTANT,
        codeLauncher: () => true,
      }),
    ).toThrow(`Target exists: ${target}. Re-run with --force to overwrite.`);

    // Act: with force it proceeds.
    const result = createActiveFolder({
      featureName: "notes",
      force: true,
      templateRoot: TEMPLATE_ROOT,
      fs,
      workspace: WORKSPACE,
      nowProvider: () => FIXED_INSTANT,
      codeLauncher: () => true,
    });

    // Assert
    expect(result.target).toBe(target);
  });
});

describe("createActiveFolder feature creation (no potential file)", () => {
  it("copies the tree, materializes the timestamped plan, updates docs, returns the target", () => {
    // Arrange
    const fs = new FakeFolderFileSystem();
    seedFeatureTemplate(fs, "feature");
    const emitted: string[] = [];
    const launched: Array<readonly string[]> = [];

    // Act
    const result = createActiveFolder({
      featureName: "notes-feature",
      featureType: "feature",
      templateRoot: TEMPLATE_ROOT,
      fs,
      workspace: WORKSPACE,
      nowProvider: () => FIXED_INSTANT,
      codeLauncher: (files) => {
        launched.push(files);
        return true;
      },
      emit: (line) => emitted.push(line),
    });

    // Assert
    const target = `${WORKSPACE}/docs/features/active/notes-feature`;
    expect(result).toEqual({ target, potentialIssuePath: null });
    expect(fs.files.has(`${target}/plan.${FIXED_STAMP}.md`)).toBe(true);
    expect(fs.files.has(`${target}/${PLAN_TIMESTAMP_TEMPLATE_NAME}`)).toBe(
      false,
    );
    expect(emitted).toContain(`Created/updated: ${target}`);
    expect(emitted).toContain("Selected mode: full-feature");
    expect(launched[0]).toContain(`${target}/user-story.md`);
  });
});

describe("createActiveFolder full mode with a potential file", () => {
  it("moves the potential file to issue.md, marks the work mode, and emits seeding lines", () => {
    // Arrange
    const fs = new FakeFolderFileSystem();
    seedFeatureTemplate(fs, "feature");
    const potential = `${WORKSPACE}/docs/features/potential/notes-feature.md`;
    fs.seed(
      potential,
      "# notes-feature\n\n## Problem / Why\nthe why\n\n## Proposed Behavior\nthe how\n",
    );
    const emitted: string[] = [];

    // Act
    const result = createActiveFolder({
      featureName: "notes-feature",
      featureType: "feature",
      workMode: "full-feature",
      templateRoot: TEMPLATE_ROOT,
      fs,
      workspace: WORKSPACE,
      nowProvider: () => FIXED_INSTANT,
      codeLauncher: () => true,
      emit: (line) => emitted.push(line),
    });

    // Assert
    const target = `${WORKSPACE}/docs/features/active/notes-feature`;
    const issuePath = `${target}/issue.md`;
    expect(result.potentialIssuePath).toBe(issuePath);
    expect(fs.files.has(potential)).toBe(false);
    expect(fs.files.get(issuePath)).toContain("- Work Mode: full-feature");
    expect(emitted).toContain(`Moved potential file to ${issuePath}`);
    expect(emitted).toContain("Seeded docs from potential: notes-feature.md");
  });
});

describe("createActiveFolder minor-audit mode", () => {
  it("with a potential file moves it to issue.md with the minor-audit marker and opens only issue.md", () => {
    // Arrange
    const fs = new FakeFolderFileSystem();
    seedFeatureTemplate(fs, "feature");
    const potential = `${WORKSPACE}/docs/features/potential/notes-feature.md`;
    fs.seed(potential, "# notes-feature\n\n## Problem / Why\nthe why\n");
    const launched: Array<readonly string[]> = [];

    // Act
    const result = createActiveFolder({
      featureName: "notes-feature",
      featureType: "feature",
      workMode: "minor-audit",
      templateRoot: TEMPLATE_ROOT,
      fs,
      workspace: WORKSPACE,
      nowProvider: () => FIXED_INSTANT,
      codeLauncher: (files) => {
        launched.push(files);
        return true;
      },
    });

    // Assert
    const issuePath = `${WORKSPACE}/docs/features/active/notes-feature/issue.md`;
    expect(result.potentialIssuePath).toBe(issuePath);
    expect(fs.files.get(issuePath)).toContain("- Work Mode: minor-audit");
    // issue.md is opened (filesToOpen=[issue.md]; potentialIssuePath also appended).
    expect(launched[0]).toEqual([issuePath, issuePath]);
  });

  it("without a potential file writes the verbatim minor-audit issue.md body", () => {
    // Arrange
    const fs = new FakeFolderFileSystem();
    seedFeatureTemplate(fs, "feature");

    // Act
    const result = createActiveFolder({
      featureName: "notes-feature",
      featureType: "feature",
      workMode: "minor-audit",
      templateRoot: TEMPLATE_ROOT,
      fs,
      workspace: WORKSPACE,
      nowProvider: () => FIXED_INSTANT,
      codeLauncher: () => true,
    });

    // Assert
    const issuePath = `${WORKSPACE}/docs/features/active/notes-feature/issue.md`;
    expect(result.potentialIssuePath).toBeNull();
    const body = fs.files.get(issuePath) ?? "";
    expect(body).toContain("# notes-feature");
    expect(body).toContain("- Work Mode: minor-audit");
    expect(body).toContain(
      "## Problem / Why\n(not provided in potential file)",
    );
    expect(body).toContain(
      "## Verification Steps\n(not provided in potential file)",
    );
    expect(body).toContain(
      "## Evidence Checklist\n- [ ] baseline\n- [ ] targeted verification\n- [ ] end-state",
    );
  });
});

describe("createActiveFolder issue-number handling", () => {
  it("normalizes 'auto' to none and falls back to the potential file Issue line", () => {
    // Arrange
    const fs = new FakeFolderFileSystem();
    seedFeatureTemplate(fs, "feature");
    const potential = `${WORKSPACE}/docs/features/potential/notes-feature.md`;
    fs.seed(potential, "# notes-feature\n- Issue: #240\n");

    // Act
    const result = createActiveFolder({
      featureName: "notes-feature",
      featureType: "feature",
      issueNumber: "auto",
      workMode: "full-feature",
      templateRoot: TEMPLATE_ROOT,
      fs,
      workspace: WORKSPACE,
      nowProvider: () => FIXED_INSTANT,
      codeLauncher: () => true,
      issueFetcher: () => null,
    });

    // Assert: the slug from the potential stem gains the parsed issue suffix.
    expect(result.target).toBe(
      `${WORKSPACE}/docs/features/active/notes-feature-240`,
    );
  });

  it("uses issueFetcher metadata for the issue and owner fields", () => {
    // Arrange
    const fs = new FakeFolderFileSystem();
    seedFeatureTemplate(fs, "feature");
    const meta: IssueMeta = {
      number: "555",
      author: "octocat",
      updatedDate: "2026-03-14",
    };

    // Act
    const result = createActiveFolder({
      featureName: "notes-feature",
      featureType: "feature",
      issueNumber: "555",
      workMode: "full-feature",
      templateRoot: TEMPLATE_ROOT,
      fs,
      workspace: WORKSPACE,
      nowProvider: () => FIXED_INSTANT,
      codeLauncher: () => true,
      issueFetcher: () => meta,
    });

    // Assert: the materialized plan header carries the fetched issue/owner.
    const planPath = `${result.target}/plan.${FIXED_STAMP}.md`;
    const plan = fs.files.get(planPath) ?? "";
    expect(plan).toContain("- Issue: #555");
  });

  it("uses TBD/name defaults when the fetcher returns null", () => {
    // Arrange
    const fs = new FakeFolderFileSystem();
    seedFeatureTemplate(fs, "feature");
    fs.seed(
      `${TEMPLATE_ROOT}/feature/${PLAN_TIMESTAMP_TEMPLATE_NAME}`,
      "# <feature-name>\n- Issue: #<id>\n- Owner: name\n",
    );

    // Act
    const result = createActiveFolder({
      featureName: "notes-feature",
      featureType: "feature",
      workMode: "full-feature",
      templateRoot: TEMPLATE_ROOT,
      fs,
      workspace: WORKSPACE,
      nowProvider: () => FIXED_INSTANT,
      codeLauncher: () => true,
      issueFetcher: () => null,
    });

    // Assert: no issue number, so issueField is TBD.
    const plan = fs.files.get(`${result.target}/plan.${FIXED_STAMP}.md`) ?? "";
    expect(plan).toContain("- Issue: TBD");
  });
});

describe("createActiveFolder bug template preservation", () => {
  it("copies spec.md and the timestamped plan and stops before legacy plan.md", () => {
    // Arrange: a bug template with spec.md, the timestamped plan, AND plan.md.
    const fs = new FakeFolderFileSystem();
    const dir = `${TEMPLATE_ROOT}/bug`;
    fs.seed(`${dir}/spec.md`, "# <feature-name>\n\n## Test Strategy\n\n");
    fs.seed(
      `${dir}/${PLAN_TIMESTAMP_TEMPLATE_NAME}`,
      "# <feature-name>\n- Last Updated: <yyyy-MM-ddTHH-mm>\n",
    );
    fs.seed(`${dir}/plan.md`, "# legacy\n");

    // Act
    const result = createActiveFolder({
      featureName: "notes-bug",
      featureType: "bug",
      workMode: "full-bug",
      templateRoot: TEMPLATE_ROOT,
      fs,
      workspace: WORKSPACE,
      nowProvider: () => FIXED_INSTANT,
      codeLauncher: () => true,
    });

    // Assert: legacy plan.md was not copied; the timestamped plan was stamped.
    const target = result.target;
    expect(fs.files.has(`${target}/plan.md`)).toBe(false);
    expect(fs.files.has(`${target}/plan.${FIXED_STAMP}.md`)).toBe(true);
  });
});

describe("createActiveFolder launcher fallback", () => {
  it("emits the manual-open warning lines when the launcher returns false", () => {
    // Arrange
    const fs = new FakeFolderFileSystem();
    seedFeatureTemplate(fs, "feature");
    const emitted: string[] = [];

    // Act
    createActiveFolder({
      featureName: "notes-feature",
      featureType: "feature",
      templateRoot: TEMPLATE_ROOT,
      fs,
      workspace: WORKSPACE,
      nowProvider: () => FIXED_INSTANT,
      codeLauncher: () => false,
      emit: (line) => emitted.push(line),
    });

    // Assert
    expect(emitted).toContain(
      "VS Code 'code' command not found. Files to edit:",
    );
    const target = `${WORKSPACE}/docs/features/active/notes-feature`;
    expect(emitted).toContain(`  ${target}/user-story.md`);
  });
});
