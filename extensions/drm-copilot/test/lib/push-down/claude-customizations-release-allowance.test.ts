import { describe, expect, it } from "@jest/globals";

import {
  EXCLUDED_RELATIVE_PATHS,
  pushDownCustomizations,
} from "../../../src/lib/push-down/claude-customizations";
import { buildInMemoryFileSystem, fixedClock } from "./push-down.test-helpers";

/**
 * Issue #1201: the destination-owned release-commit allowance file is never
 * created, overwritten, or deleted by a Claude push-down refresh.
 */

const CLOCK = fixedClock("2026-11-17T20:00:00.000Z");
const SRC = "/src";
const DEST = "/dest";
const BUNDLE = `${SRC}/extensions/drm-copilot/resources/claude-customizations`;
const ALLOWANCE = ".claude/release-commit-allowance.json";
const SOURCE_TEXT =
  '{"schema_version": 1, "allowances": [{"id": "source", "branch_patterns": ["release/v*"], "allowed_paths": ["package.json"]}]}\n';
const DESTINATION_TEXT =
  '{"schema_version": 1, "allowances": [{"id": "destination", "branch_patterns": ["release/*"], "allowed_paths": ["CHANGELOG.md"]}]}\n';

/**
 * Seed a source tree holding an allowance file and a destination holding a
 * different allowance file.
 *
 * @returns A seeded in-memory filesystem.
 */
function seedTree(): ReturnType<typeof buildInMemoryFileSystem> {
  return buildInMemoryFileSystem(
    {
      [`${SRC}/.claude/settings.json`]: '{"core": true}\n',
      [`${SRC}/.claude/rules/python.md`]: "# Python\n",
      [`${SRC}/${ALLOWANCE}`]: SOURCE_TEXT,
      [`${DEST}/${ALLOWANCE}`]: DESTINATION_TEXT,
      [`${BUNDLE}/pack-manifests/core.json`]: JSON.stringify({
        name: "core",
        label: "Core",
        paths: [".claude/settings.json", ALLOWANCE],
      }),
    },
    [DEST],
  );
}

describe("release-commit allowance push-down exclusion (issue #1201)", () => {
  it("lists the allowance file in EXCLUDED_RELATIVE_PATHS (AC-25)", () => {
    // Arrange / Act / Assert
    expect(EXCLUDED_RELATIVE_PATHS).toContain(ALLOWANCE);
  });

  it("leaves the destination allowance file unchanged when no packs are selected (AC-26)", () => {
    // Arrange
    const fs = seedTree();

    // Act
    const summary = pushDownCustomizations({
      repoRoot: SRC,
      destinationRoot: DEST,
      fs,
      sourceRoot: SRC,
      artifactRoot: DEST,
      clock: CLOCK,
    });

    // Assert
    const relativePaths = summary.files.map((f) => f.relativePath);
    expect(relativePaths).toContain(".claude/rules/python.md");
    expect(relativePaths).not.toContain(ALLOWANCE);
    expect(fs.readTextFile(`${DEST}/${ALLOWANCE}`)).toBe(DESTINATION_TEXT);
  });

  it("leaves the destination allowance file unchanged when the core pack is selected (AC-26)", () => {
    // Arrange
    const fs = seedTree();

    // Act
    const summary = pushDownCustomizations({
      repoRoot: SRC,
      destinationRoot: DEST,
      fs,
      sourceRoot: SRC,
      artifactRoot: DEST,
      packs: new Set(["core"]),
      bundleRoot: BUNDLE,
      clock: CLOCK,
    });

    // Assert
    const relativePaths = summary.files.map((f) => f.relativePath);
    expect(relativePaths).toContain(".claude/settings.json");
    expect(relativePaths).not.toContain(ALLOWANCE);
    expect(fs.readTextFile(`${DEST}/${ALLOWANCE}`)).toBe(DESTINATION_TEXT);
  });
});
