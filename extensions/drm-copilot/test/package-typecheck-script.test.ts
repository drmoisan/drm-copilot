import { readFileSync } from "node:fs";
import * as path from "node:path";

import { describe, expect, it } from "@jest/globals";

/**
 * Regression guard for issue #647: the test tree compiled by
 * `tsconfig.jest.json` must be type-checked by the `typecheck` script, and the
 * extension-tests workflow must run that script before the Jest suite.
 *
 * The committed `package.json` and workflow file are read as static,
 * read-only inputs; no file is created.
 */

const PACKAGE_JSON_PATH = path.resolve(__dirname, "..", "package.json");
const WORKFLOW_PATH = path.resolve(
  __dirname,
  "..",
  "..",
  "..",
  ".github",
  "workflows",
  "_drm-copilot-extension-tests.yml",
);

/** Return true when `value` is a non-null, non-array object. */
function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

/**
 * Return the npm script named `name` from the extension `package.json`.
 *
 * @throws Error when the manifest, its `scripts` block, or the named script is
 *   missing or is not a string.
 */
function scriptAt(name: string): string {
  const manifest: unknown = JSON.parse(readFileSync(PACKAGE_JSON_PATH, "utf8"));
  if (!isRecord(manifest) || !isRecord(manifest["scripts"])) {
    throw new Error("extension package.json has no scripts object");
  }
  const script = manifest["scripts"][name];
  if (typeof script !== "string") {
    throw new Error(`extension package.json has no string script '${name}'`);
  }
  return script;
}

describe("extension type-check gate wiring", () => {
  it("typecheck script chains typecheck:test", () => {
    // Arrange
    const expected = "tsc -p ./ --noEmit && npm run typecheck:test";

    // Act
    const script = scriptAt("typecheck");

    // Assert
    expect(script).toBe(expected);
  });

  it("typecheck:test script checks tsconfig.jest.json", () => {
    // Arrange
    const expected = "tsc -p tsconfig.jest.json --noEmit";

    // Act
    const script = scriptAt("typecheck:test");

    // Assert
    expect(script).toBe(expected);
  });

  it("compile and build do not reference tsconfig.jest.json", () => {
    // Arrange
    const testConfig = "tsconfig.jest.json";

    // Act
    const compile = scriptAt("compile");
    const build = scriptAt("build");

    // Assert
    expect(compile).not.toContain(testConfig);
    expect(build).not.toContain(testConfig);
  });

  it("extension tests workflow runs the typecheck script before tests", () => {
    // Arrange
    const workflow = readFileSync(WORKFLOW_PATH, "utf8");

    // Act
    const installIndex = workflow.indexOf(
      "npm --prefix extensions/drm-copilot ci",
    );
    const typecheckIndex = workflow.indexOf(
      "npm --prefix extensions/drm-copilot run typecheck",
    );
    const testIndex = workflow.indexOf(
      "npm --prefix extensions/drm-copilot run test",
    );

    // Assert
    expect(workflow).toContain("Type-check extension source and test tree");
    expect(installIndex).toBeGreaterThanOrEqual(0);
    expect(typecheckIndex).toBeGreaterThanOrEqual(0);
    expect(testIndex).toBeGreaterThanOrEqual(0);
    expect(typecheckIndex).toBeGreaterThan(installIndex);
    expect(typecheckIndex).toBeLessThan(testIndex);
  });
});
