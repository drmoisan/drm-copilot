import { describe, expect, test } from "@jest/globals";
import { existsSync, readFileSync } from "node:fs";
import path from "node:path";

type PackageJson = {
  scripts?: Record<string, string>;
};

const repoRoot = path.resolve(__dirname, "../..");

const loadPackageJson = (): PackageJson => {
  const packageJsonPath = path.join(repoRoot, "package.json");
  const raw = readFileSync(packageJsonPath, "utf-8");
  return JSON.parse(raw) as PackageJson;
};

describe("VS Code test harness removal", () => {
  test("scripts avoid vscode-test electron harness", () => {
    // Arrange
    const packageJson = loadPackageJson();
    const scriptValues = Object.values(packageJson.scripts ?? {});

    // Act
    const hasVscodeTestElectron = scriptValues.some((value) =>
      value.includes("@vscode/test-electron"),
    );
    const hasVscodeTestRunner = scriptValues.some((value) =>
      value.includes("vscode-test"),
    );

    // Assert
    expect(hasVscodeTestElectron).toBe(false);
    expect(hasVscodeTestRunner).toBe(false);
  });

  test("vscode-test mjs removed", () => {
    // Arrange
    const vscodeTestPath = path.join(repoRoot, ".vscode-test.mjs");

    // Act
    const exists = existsSync(vscodeTestPath);

    // Assert
    expect(exists).toBe(false);
  });

  test("vscode-test tsconfig removed", () => {
    // Arrange
    const tsconfigPath = path.join(repoRoot, "tsconfig.vscode-test.json");

    // Act
    const exists = existsSync(tsconfigPath);

    // Assert
    expect(exists).toBe(false);
  });
});
