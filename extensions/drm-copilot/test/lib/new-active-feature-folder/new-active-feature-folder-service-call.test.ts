/**
 * Unit tests for the `newActiveFeatureFolder` service-call helper.
 *
 * Hermetic: a `Map`-backed `FolderFileSystem` fake pre-seeded with a template
 * tree and a fake `CommandRunner`. No real subprocess or `code`. AAA; one
 * behavior per test.
 */

import { describe, expect, it } from "@jest/globals";

import { newActiveFeatureFolderServiceCall } from "../../../src/lib/new-active-feature-folder/new-active-feature-folder-service-call";
import { PLAN_TIMESTAMP_TEMPLATE_NAME } from "../../../src/lib/new-active-feature-folder/models";
import { FakeCommandRunner, FakeFolderFileSystem } from "./fakes";

const WORKSPACE = "/ws";
const TEMPLATE_ROOT = "/ws/templates";

/**
 * Filesystem fake that reports one designated path as absent.
 *
 * Used to drive the receipt post-condition: the workflow still writes normally,
 * but the reported path fails its existence check.
 */
class BlockedPathFolderFileSystem extends FakeFolderFileSystem {
  /**
   * @param blockedPath Path whose existence check always reports false.
   */
  constructor(private readonly blockedPath: string) {
    super();
  }

  /**
   * @param path Path to test.
   * @returns False for the blocked path; otherwise the inherited answer.
   */
  override exists(path: string): boolean {
    return path === this.blockedPath ? false : super.exists(path);
  }
}

/**
 * Seed a feature template tree under the template root.
 *
 * @param fs Filesystem fake.
 */
function seedFeatureTemplate(fs: FakeFolderFileSystem): void {
  const dir = `${TEMPLATE_ROOT}/feature`;
  fs.seed(`${dir}/user-story.md`, "# <feature-name>\n");
  fs.seed(`${dir}/spec.md`, "# <feature-name>\n");
  fs.seed(
    `${dir}/${PLAN_TIMESTAMP_TEMPLATE_NAME}`,
    "# <feature-name>\n- Last Updated: <yyyy-MM-ddTHH-mm>\n",
  );
}

describe("newActiveFeatureFolderServiceCall", () => {
  it("returns the preserved tool, workspaceRoot, summary, and destinationPath", () => {
    // Arrange
    const fs = new FakeFolderFileSystem();
    seedFeatureTemplate(fs);
    const runner = new FakeCommandRunner();

    // Act
    const result = newActiveFeatureFolderServiceCall({
      fileSystem: fs,
      runner,
      workspaceRoot: WORKSPACE,
      featureName: "notes-feature",
      type: "feature",
      workMode: "full-feature",
      templateRoot: TEMPLATE_ROOT,
    });

    // Assert
    expect(result.tool).toBe("new_active_feature_folder");
    expect(result.workspaceRoot).toBe(WORKSPACE);
    expect(result.summary).toBe(
      "Created a new active feature feature folder for 'notes-feature'.",
    );
    expect(result.destinationPath).toBe(
      "/ws/docs/features/active/notes-feature",
    );
    expect(result.artifacts).toBeUndefined();
  });

  it("forwards emitted workflow lines to the injected log", () => {
    // Arrange
    const fs = new FakeFolderFileSystem();
    seedFeatureTemplate(fs);
    const runner = new FakeCommandRunner();
    const logged: string[] = [];

    // Act
    newActiveFeatureFolderServiceCall({
      fileSystem: fs,
      runner,
      workspaceRoot: WORKSPACE,
      featureName: "notes-feature",
      type: "feature",
      workMode: "full-feature",
      templateRoot: TEMPLATE_ROOT,
      log: (message) => logged.push(message),
    });

    // Assert
    expect(logged).toContain(
      "Created/updated: /ws/docs/features/active/notes-feature",
    );
  });

  it("enriches artifacts with the moved issue.md when a potential file is seeded", () => {
    // Arrange
    const fs = new FakeFolderFileSystem();
    seedFeatureTemplate(fs);
    fs.seed(
      `${WORKSPACE}/docs/features/potential/notes-feature.md`,
      "# notes-feature\n",
    );
    const runner = new FakeCommandRunner();

    // Act
    const result = newActiveFeatureFolderServiceCall({
      fileSystem: fs,
      runner,
      workspaceRoot: WORKSPACE,
      featureName: "notes-feature",
      type: "feature",
      workMode: "full-feature",
      templateRoot: TEMPLATE_ROOT,
    });

    // Assert
    expect(result.artifacts).toEqual([
      "/ws/docs/features/active/notes-feature/issue.md",
    ]);
  });

  it("surfaces a thrown workflow error preserving the message", () => {
    // Arrange: an invalid type makes the workflow throw.
    const fs = new FakeFolderFileSystem();
    const runner = new FakeCommandRunner();

    // Act / Assert
    expect(() =>
      newActiveFeatureFolderServiceCall({
        fileSystem: fs,
        runner,
        workspaceRoot: WORKSPACE,
        featureName: "notes-feature",
        type: "maintenance" as never,
        workMode: "full-feature",
        templateRoot: TEMPLATE_ROOT,
      }),
    ).toThrow("Type must be one of: feature, refactor, epic, bug");
  });

  it("forwards templateRoot so the bundled templates resolve (--template-root parity)", () => {
    // Arrange: the template tree lives ONLY under the bundled template root.
    const fs = new FakeFolderFileSystem();
    seedFeatureTemplate(fs);
    const runner = new FakeCommandRunner();

    // Act: a missing templateRoot would throw "Template folder not found".
    const result = newActiveFeatureFolderServiceCall({
      fileSystem: fs,
      runner,
      workspaceRoot: WORKSPACE,
      featureName: "notes-feature",
      type: "feature",
      issueNumber: "240",
      workMode: "full-feature",
      templateRoot: TEMPLATE_ROOT,
    });

    // Assert: success implies templateRoot was forwarded to createActiveFolder.
    expect(result.destinationPath).toBe(
      "/ws/docs/features/active/notes-feature-240",
    );
  });

  it("uses a no-op launcher so no code subprocess runs and warning lines are emitted", () => {
    // Arrange
    const fs = new FakeFolderFileSystem();
    seedFeatureTemplate(fs);
    const runner = new FakeCommandRunner();
    const logged: string[] = [];

    // Act
    newActiveFeatureFolderServiceCall({
      fileSystem: fs,
      runner,
      workspaceRoot: WORKSPACE,
      featureName: "notes-feature",
      type: "feature",
      workMode: "full-feature",
      templateRoot: TEMPLATE_ROOT,
      log: (message) => logged.push(message),
    });

    // Assert: the no-op launcher returns false, so the manual-open lines emit;
    // the runner was never used to spawn `code` (no gh fetch either).
    expect(logged).toContain(
      "VS Code 'code' command not found. Files to edit:",
    );
    expect(runner.calls).toHaveLength(0);
  });
});

describe("newActiveFeatureFolderServiceCall receipt post-condition", () => {
  const TARGET = "/ws/docs/features/active/notes-feature";

  it("throws when the reported destination path is absent", () => {
    // Arrange: the target directory reports as absent after the workflow ran.
    const build = (): BlockedPathFolderFileSystem => {
      const fs = new BlockedPathFolderFileSystem(TARGET);
      seedFeatureTemplate(fs);
      return fs;
    };
    const runner = new FakeCommandRunner();

    // Act / Assert
    expect(() =>
      newActiveFeatureFolderServiceCall({
        fileSystem: build(),
        runner,
        workspaceRoot: WORKSPACE,
        featureName: "notes-feature",
        type: "feature",
        workMode: "full-feature",
        templateRoot: TEMPLATE_ROOT,
      }),
    ).toThrow(`new_active_feature_folder`);
    expect(() =>
      newActiveFeatureFolderServiceCall({
        fileSystem: build(),
        runner,
        workspaceRoot: WORKSPACE,
        featureName: "notes-feature",
        type: "feature",
        workMode: "full-feature",
        templateRoot: TEMPLATE_ROOT,
      }),
    ).toThrow(TARGET);
  });

  it("throws when the reported artifact path is absent", () => {
    // Arrange: the seeded issue.md reports as absent after the workflow ran.
    const issuePath = `${TARGET}/issue.md`;
    const build = (): BlockedPathFolderFileSystem => {
      const fs = new BlockedPathFolderFileSystem(issuePath);
      seedFeatureTemplate(fs);
      fs.seed(
        `${WORKSPACE}/docs/features/potential/notes-feature.md`,
        "# notes-feature\n",
      );
      return fs;
    };
    const runner = new FakeCommandRunner();

    // Act / Assert
    expect(() =>
      newActiveFeatureFolderServiceCall({
        fileSystem: build(),
        runner,
        workspaceRoot: WORKSPACE,
        featureName: "notes-feature",
        type: "feature",
        workMode: "full-feature",
        templateRoot: TEMPLATE_ROOT,
      }),
    ).toThrow(`new_active_feature_folder`);
    expect(() =>
      newActiveFeatureFolderServiceCall({
        fileSystem: build(),
        runner,
        workspaceRoot: WORKSPACE,
        featureName: "notes-feature",
        type: "feature",
        workMode: "full-feature",
        templateRoot: TEMPLATE_ROOT,
      }),
    ).toThrow(issuePath);
  });

  it("returns the enriched record when every reported path exists", () => {
    // Arrange: nothing is blocked, so both reported paths exist.
    const fs = new FakeFolderFileSystem();
    seedFeatureTemplate(fs);
    fs.seed(
      `${WORKSPACE}/docs/features/potential/notes-feature.md`,
      "# notes-feature\n",
    );
    const runner = new FakeCommandRunner();

    // Act
    const result = newActiveFeatureFolderServiceCall({
      fileSystem: fs,
      runner,
      workspaceRoot: WORKSPACE,
      featureName: "notes-feature",
      type: "feature",
      workMode: "full-feature",
      templateRoot: TEMPLATE_ROOT,
    });

    // Assert
    expect(result.destinationPath).toBe(TARGET);
    expect(result.artifacts).toEqual([`${TARGET}/issue.md`]);
  });
});
