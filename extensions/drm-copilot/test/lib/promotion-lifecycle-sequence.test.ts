/**
 * Sequenced lifecycle regression for the promotion pipeline.
 *
 * `potential_to_issue` moves a potential entry into
 * `docs/features/potential/promoted/`; `new_active_feature_folder` then seeds
 * the active folder from it. Running the two in sequence against one shared
 * in-memory filesystem must leave the promoted record in place, because that
 * record is the durable history of the promotion.
 *
 * Hermetic: one `Map`-backed filesystem implementing both
 * `PotentialFileSystem` and `FolderFileSystem`, an injected `GhClient` fake,
 * and a fixed `nowProvider`. No temporary files, no `gh` invocation, and no
 * dependency on the real `docs/features/` tree. AAA.
 */

import { describe, expect, it } from "@jest/globals";

import { createActiveFolder } from "../../src/lib/new-active-feature-folder/flow";
import {
  type FolderFileSystem,
  PLAN_TIMESTAMP_TEMPLATE_NAME,
} from "../../src/lib/new-active-feature-folder/models";
import {
  type PotentialFileSystem,
  promotePotential,
} from "../../src/lib/potential-to-issue/promotion";
import { FakeGhClient } from "./potential-to-issue/promotion-test-support";

const WORKSPACE = "/workspace";
const TEMPLATE_ROOT = "/workspace/templates";
const FIXED_INSTANT = new Date("2024-02-03T09:05:00Z");
const FEATURE_NAME = "notes-feature";
const POTENTIAL_PATH = `${WORKSPACE}/docs/features/potential/${FEATURE_NAME}.md`;
const PROMOTED_PATH = `${WORKSPACE}/docs/features/potential/promoted/${FEATURE_NAME}.md`;

/**
 * Shared in-memory filesystem satisfying both cluster seams.
 *
 * Implements the union of {@link PotentialFileSystem} (used by
 * `promotePotential`) and {@link FolderFileSystem} (used by
 * `createActiveFolder`) so a single instance carries state across the two
 * calls, which is what makes the sequence observable.
 */
class SharedLifecycleFileSystem
  implements PotentialFileSystem, FolderFileSystem
{
  /** File contents keyed by forward-slash path. */
  readonly files = new Map<string, string>();
  /** Directories recorded via {@link ensureDir}. */
  readonly createdDirs: string[] = [];
  /** Recorded move operations as `[src, dest]` pairs. */
  readonly moves: Array<[string, string]> = [];

  /**
   * @param path Forward-slash file path.
   * @param content File content.
   */
  seed(path: string, content: string): void {
    this.files.set(path, content);
  }

  /**
   * @param pathStr Raw path string.
   * @returns The path unchanged; test paths are already absolute POSIX.
   */
  resolvePath(pathStr: string): string {
    return pathStr;
  }

  /**
   * @param path Path to test.
   * @returns True for a seeded file, a created directory, or an implicit
   *   ancestor directory of a seeded file.
   */
  exists(path: string): boolean {
    if (this.files.has(path) || this.createdDirs.includes(path)) {
      return true;
    }
    for (const filePath of this.files.keys()) {
      if (filePath.startsWith(`${path}/`)) {
        return true;
      }
    }
    return false;
  }

  /**
   * @param path File to read.
   * @returns The file content.
   * @throws Error When the path is absent.
   */
  readText(path: string): string {
    const content = this.files.get(path);
    if (content === undefined) {
      throw new Error(`File not found: ${path}`);
    }
    return content;
  }

  /**
   * @param path File to write.
   * @param content Text content.
   */
  writeText(path: string, content: string): void {
    this.files.set(path, content);
  }

  /**
   * @param path File to write.
   * @param lines Lines joined with a newline.
   */
  writeLines(path: string, lines: readonly string[]): void {
    this.files.set(path, lines.join("\n"));
  }

  /**
   * @param path Directory to record as created.
   */
  ensureDir(path: string): void {
    if (!this.createdDirs.includes(path)) {
      this.createdDirs.push(path);
    }
  }

  /**
   * @param src Source file path.
   * @param dest Destination file path.
   */
  copyFile(src: string, dest: string): void {
    this.files.set(dest, this.files.get(src) ?? "");
  }

  /**
   * @param src Source directory root.
   * @param dest Destination directory root.
   */
  copyTree(src: string, dest: string): void {
    for (const [filePath, content] of this.files) {
      if (filePath.startsWith(`${src}/`)) {
        this.files.set(`${dest}/${filePath.slice(src.length + 1)}`, content);
      }
    }
  }

  /**
   * @param path Directory to list.
   * @returns Forward-slash file paths directly under `path`.
   */
  listFiles(path: string): string[] {
    const result: string[] = [];
    for (const filePath of this.files.keys()) {
      if (filePath.startsWith(`${path}/`)) {
        const relative = filePath.slice(path.length + 1);
        if (!relative.includes("/")) {
          result.push(filePath);
        }
      }
    }
    return result;
  }

  /**
   * @param src Source path.
   * @param dest Destination path.
   * @throws Error When the source is absent.
   */
  move(src: string, dest: string): void {
    const content = this.files.get(src);
    if (content === undefined) {
      throw new Error(`File not found: ${src}`);
    }
    this.files.delete(src);
    this.files.set(dest, content);
    this.moves.push([src, dest]);
  }
}

/**
 * Build minimal full-feature potential content with all required sections.
 *
 * @returns Markdown accepted by the promotion workflow.
 */
function buildPotentialContent(): string {
  return [
    `# ${FEATURE_NAME}`,
    "## Problem / Why",
    "why",
    "## Proposed Behavior",
    "behave",
    "## Acceptance Criteria (early draft)",
    "criteria",
    "## Constraints & Risks",
    "risk",
    "## Test Conditions to Consider",
    "tests",
  ].join("\n");
}

/**
 * Seed the feature template tree used by `createActiveFolder`.
 *
 * @param fs Shared filesystem.
 */
function seedFeatureTemplate(fs: SharedLifecycleFileSystem): void {
  const dir = `${TEMPLATE_ROOT}/feature`;
  fs.seed(`${dir}/user-story.md`, "# <feature-name>\n");
  fs.seed(`${dir}/spec.md`, "# <feature-name>\n\n## Test Strategy\n\n");
  fs.seed(
    `${dir}/${PLAN_TIMESTAMP_TEMPLATE_NAME}`,
    "# <feature-name>\n- Last Updated: <yyyy-MM-ddTHH-mm>\n",
  );
}

describe("promotion lifecycle sequence", () => {
  it("retains the promoted record across potential_to_issue then new_active_feature_folder", () => {
    // Arrange: one shared filesystem carrying the potential entry and the
    // feature templates.
    const fs = new SharedLifecycleFileSystem();
    seedFeatureTemplate(fs);
    fs.seed(POTENTIAL_PATH, buildPotentialContent());

    // Act 1: promote the potential entry into promoted/.
    const outcome = promotePotential({
      potentialPath: POTENTIAL_PATH,
      promotionType: "feature",
      workMode: "full-feature",
      workspace: WORKSPACE,
      fs,
      gh: new FakeGhClient({ output: [], exitCode: 0 }),
    });

    // Assert the intermediate state so a later failure is unambiguous.
    expect(outcome.exitCode).toBe(0);
    expect(outcome.destination).toBe(PROMOTED_PATH);
    expect(fs.files.has(POTENTIAL_PATH)).toBe(false);
    expect(fs.files.has(PROMOTED_PATH)).toBe(true);
    const promotedContentAfterPromotion = fs.readText(PROMOTED_PATH);

    // Act 2: seed the active folder from the promoted record.
    const result = createActiveFolder({
      featureName: FEATURE_NAME,
      featureType: "feature",
      workMode: "full-feature",
      templateRoot: TEMPLATE_ROOT,
      fs,
      workspace: WORKSPACE,
      nowProvider: () => FIXED_INSTANT,
      codeLauncher: () => true,
    });

    // Assert: the active folder's issue.md carries the work-mode marker.
    const issuePath = `${result.target}/issue.md`;
    expect(result.potentialIssuePath).toBe(issuePath);
    expect(fs.files.get(issuePath)).toContain("- Work Mode: full-feature");

    // Assert: the promoted record survives, byte-identical.
    expect(fs.files.has(PROMOTED_PATH)).toBe(true);
    expect(fs.readText(PROMOTED_PATH)).toBe(promotedContentAfterPromotion);
  });
});
