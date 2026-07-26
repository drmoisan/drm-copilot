import { describe, expect, test } from "@jest/globals";
import { existsSync, readFileSync } from "node:fs";
import path from "node:path";

/**
 * Regression guard for issue #421.
 *
 * The root `test` and `test:integration` scripts were both defined as
 * `vscode-test` while no `.vscode-test.*` configuration file existed anywhere
 * in the repository, so both scripts exited inside `@vscode/test-cli`'s
 * `loadDefaultConfigFile` before any test runner started. These assertions
 * fail if a root script is ever re-pointed at the `vscode-test` runner, or if
 * one of the dead configuration files is reintroduced.
 *
 * Modeled on the prior-art guard at
 * `2f67b888:tests/unit/vscode-test-removal.test.ts`.
 *
 * The assertions read only versioned repository files. No temporary file,
 * mock, wall-clock read, or random value is involved, so the tests are
 * deterministic and order-independent.
 */

type PackageJson = {
  scripts?: Record<string, string>;
};

/** Repository root: two levels up from this file's `tests/unit` directory. */
const repositoryRoot = path.resolve(__dirname, "../..");

/**
 * Configuration file names `@vscode/test-cli` resolves, plus the TypeScript
 * project file the removed `compile:integration-tests` script looked for. All
 * must remain absent from the repository root.
 */
const deadConfigFileNames = [
  ".vscode-test.mjs",
  ".vscode-test.js",
  ".vscode-test.cjs",
  ".vscode-test.json",
  "tsconfig.vscode-test.json",
];

const readRootPackageJson = (): PackageJson => {
  const packageJsonPath = path.join(repositoryRoot, "package.json");
  const raw = readFileSync(packageJsonPath, "utf-8");
  return JSON.parse(raw) as PackageJson;
};

describe("vscode-test harness removal", () => {
  test("no root npm script invokes the vscode-test runner", () => {
    // Arrange
    const scripts = readRootPackageJson().scripts ?? {};

    // Act
    const offendingScriptNames = Object.entries(scripts)
      .filter(([, command]) => command.includes("vscode-test"))
      .map(([scriptName]) => scriptName);

    // Assert
    expect(offendingScriptNames).toEqual([]);
  });

  test("no dead vscode-test config file exists at the repository root", () => {
    // Arrange
    const candidates = deadConfigFileNames.map((fileName) => ({
      fileName,
      fullPath: path.join(repositoryRoot, fileName),
    }));

    // Act
    const presentFileNames = candidates
      .filter(({ fullPath }) => existsSync(fullPath))
      .map(({ fileName }) => fileName);

    // Assert
    expect(presentFileNames).toEqual([]);
  });
});
