/**
 * Contract test: no module under `src/lib/development-docs/` imports or
 * requires `vscode` (issue #1035, spec S-7), so MCP tools and the Python and
 * PowerShell twins can share the same rules without the extension host.
 *
 * Side effects:
 *     Read-only access to committed source files; no temporary file.
 */
import * as fs from "node:fs";
import * as path from "node:path";

/** Repository root, five levels above this file's folder. */
const REPO_ROOT = path.join(__dirname, "..", "..", "..", "..", "..");

/** Repository-relative forward-slash folder under test. */
const FOLDER = "extensions/drm-copilot/src/lib/development-docs";

const VSCODE_REFERENCE =
  /(?:\bfrom\s+["']vscode["']|\brequire\(\s*["']vscode["']\s*\)|\bimport\(\s*["']vscode["']\s*\)|^\s*import\s+["']vscode["'])/m;

/** Return the repository-relative forward-slash paths of the folder's `.ts` files. */
function listModules(): string[] {
  const absolute = path.join(REPO_ROOT, ...FOLDER.split("/"));
  return fs
    .readdirSync(absolute)
    .filter((name) => name.endsWith(".ts"))
    .sort()
    .map((name) => `${FOLDER}/${name}`);
}

describe("development-docs modules are host-neutral", () => {
  const modules = listModules();

  it("finds the development-docs modules", () => {
    expect(modules).toEqual(
      expect.arrayContaining([
        `${FOLDER}/root.ts`,
        `${FOLDER}/feature-folder-name.ts`,
      ]),
    );
  });

  it.each(modules)("%s does not import vscode", (relative) => {
    // Arrange
    const text = fs.readFileSync(
      path.join(REPO_ROOT, ...relative.split("/")),
      "utf8",
    );
    // Act
    const match = VSCODE_REFERENCE.exec(text);
    // Assert
    expect(match).toBeNull();
  });

  it.each([
    ['import * as vscode from "vscode";'],
    ["const v = require('vscode');"],
    ['const v = await import("vscode");'],
    ['import "vscode";'],
  ])("the detector recognizes %s", (sample) => {
    expect(VSCODE_REFERENCE.test(sample)).toBe(true);
  });
});
