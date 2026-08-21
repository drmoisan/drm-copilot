/**
 * Unit tests for the promoted-record disposition rule in
 * `src/lib/new-active-feature-folder/flow.ts` `createActiveFolder`.
 *
 * A potential file resolved from `docs/features/potential/promoted/` is COPIED
 * into the active folder as `issue.md` so the promoted record is retained; a
 * source resolved from anywhere else is still MOVED. Covers both placement
 * sites (the minor-audit branch and the full branch) and the containment
 * boundary.
 *
 * Sibling of `flow.test.ts` because that file is at the 500-line limit in
 * `.claude/rules/general-code-change.md`. Hermetic: a `Map`-backed
 * `FolderFileSystem` fake, a fixed `nowProvider`, a fake `codeLauncher`, and an
 * `emit` capture array. No real gh/git/filesystem/temp files. AAA.
 */

import { describe, expect, it } from "@jest/globals";

import { createActiveFolder } from "../../../src/lib/new-active-feature-folder/flow";
import { PLAN_TIMESTAMP_TEMPLATE_NAME } from "../../../src/lib/new-active-feature-folder/models";
import { FakeFolderFileSystem } from "./fakes";

const WORKSPACE = "/ws";
const TEMPLATE_ROOT = "/ws/templates";
const FIXED_INSTANT = new Date("2024-02-03T09:05:00Z");
const PROMOTED_ROOT = `${WORKSPACE}/docs/features/potential/promoted`;
const POTENTIAL_BODY =
  "# notes-feature\n\n## Problem / Why\nthe why\n\n## Proposed Behavior\nthe how\n";

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

/**
 * Seed the selective bug template set (spec.md plus the timestamped plan).
 *
 * @param fs Filesystem fake.
 */
function seedBugTemplate(fs: FakeFolderFileSystem): void {
  const dir = `${TEMPLATE_ROOT}/bug`;
  fs.seed(`${dir}/spec.md`, "# <feature-name>\n\n## Test Strategy\n\n");
  fs.seed(
    `${dir}/${PLAN_TIMESTAMP_TEMPLATE_NAME}`,
    "# <feature-name>\n- Last Updated: <yyyy-MM-ddTHH-mm>\n",
  );
}

describe("createActiveFolder promoted-record disposition", () => {
  it("retains the promoted potential file and writes issue.md in full mode", () => {
    // Arrange: the only matching potential file lives under promoted/.
    const fs = new FakeFolderFileSystem();
    seedBugTemplate(fs);
    const promoted = `${PROMOTED_ROOT}/notes-feature.md`;
    fs.seed(promoted, POTENTIAL_BODY);
    const emitted: string[] = [];

    // Act
    const result = createActiveFolder({
      featureName: "notes-feature",
      featureType: "bug",
      workMode: "full-bug",
      templateRoot: TEMPLATE_ROOT,
      fs,
      workspace: WORKSPACE,
      nowProvider: () => FIXED_INSTANT,
      codeLauncher: () => true,
      emit: (line) => emitted.push(line),
    });

    // Assert: issue.md was written with the marker.
    const issuePath = `${result.target}/issue.md`;
    expect(result.potentialIssuePath).toBe(issuePath);
    expect(fs.files.has(issuePath)).toBe(true);
    expect(fs.files.get(issuePath)).toContain("- Work Mode: full-bug");

    // Assert: the promoted record survives with unchanged content.
    expect(fs.files.has(promoted)).toBe(true);
    expect(fs.files.get(promoted)).toBe(POTENTIAL_BODY);

    // Assert: the copy branch reports a copy, not a move.
    expect(emitted).toContain(`Copied potential file to ${issuePath}`);
  });

  it("retains the promoted potential file in minor-audit mode", () => {
    // Arrange: the only matching potential file lives under promoted/.
    const fs = new FakeFolderFileSystem();
    seedFeatureTemplate(fs, "feature");
    const promoted = `${PROMOTED_ROOT}/notes-feature.md`;
    fs.seed(promoted, POTENTIAL_BODY);
    const emitted: string[] = [];

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
      emit: (line) => emitted.push(line),
    });

    // Assert: issue.md was written with the minor-audit marker.
    const issuePath = `${result.target}/issue.md`;
    expect(result.potentialIssuePath).toBe(issuePath);
    expect(fs.files.get(issuePath)).toContain("- Work Mode: minor-audit");

    // Assert: the promoted record survives with unchanged content.
    expect(fs.files.has(promoted)).toBe(true);
    expect(fs.files.get(promoted)).toBe(POTENTIAL_BODY);

    // Assert: the second placement site also reports a copy.
    expect(emitted).toContain(`Copied potential file to ${issuePath}`);
  });

  it("takes the move branch for a sibling path that is only a string prefix of the promoted root", () => {
    // Arrange: a FILE directly under potential/ whose basename begins with
    // "promoted", so its path is a string prefix of the promoted root but is
    // not contained in it.
    const fs = new FakeFolderFileSystem();
    seedBugTemplate(fs);
    const sibling = `${WORKSPACE}/docs/features/potential/promoted-notes-feature.md`;
    expect(sibling.startsWith(PROMOTED_ROOT)).toBe(true);
    expect(sibling.startsWith(`${PROMOTED_ROOT}/`)).toBe(false);
    fs.seed(sibling, POTENTIAL_BODY);
    const emitted: string[] = [];

    // Act
    const result = createActiveFolder({
      featureName: "notes-feature",
      featureType: "bug",
      workMode: "full-bug",
      templateRoot: TEMPLATE_ROOT,
      fs,
      workspace: WORKSPACE,
      nowProvider: () => FIXED_INSTANT,
      codeLauncher: () => true,
      emit: (line) => emitted.push(line),
    });

    // Assert: the source was removed and the move wording was emitted, proving
    // the containment predicate requires a `<root>/` boundary.
    const issuePath = `${result.target}/issue.md`;
    expect(fs.files.has(sibling)).toBe(false);
    expect(fs.files.has(issuePath)).toBe(true);
    expect(emitted).toContain(`Moved potential file to ${issuePath}`);
  });
});
