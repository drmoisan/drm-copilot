import * as fs from "node:fs";
import * as path from "node:path";
import { describe, expect, it } from "@jest/globals";

/** Absolute path to the pure `subagent-tree` module directory under test. */
const SUBAGENT_TREE_SRC_DIR = path.resolve(
  __dirname,
  "../../../src/lib/subagent-tree",
);

/** Recursively collect every `.ts` file under `dir`. */
function collectTypeScriptFiles(dir: string): string[] {
  const entries = fs.readdirSync(dir, { withFileTypes: true });
  return entries.flatMap((entry) => {
    const entryPath = path.join(dir, entry.name);
    if (entry.isDirectory()) {
      return collectTypeScriptFiles(entryPath);
    }
    return entry.isFile() && entry.name.endsWith(".ts") ? [entryPath] : [];
  });
}

describe("src/lib/subagent-tree pure-module boundary", () => {
  it("contains no `vscode` import statements in any source file", () => {
    // Arrange: scan every `.ts` file under the pure `subagent-tree` module.
    const files = collectTypeScriptFiles(SUBAGENT_TREE_SRC_DIR);
    expect(files.length).toBeGreaterThan(0);

    // Act: find any file whose text references a `vscode` import.
    const importPattern =
      /from\s+["']vscode["']|require\(\s*["']vscode["']\s*\)/;
    const offendingFiles = files.filter((file) => {
      const content = fs.readFileSync(file, "utf8");
      return importPattern.test(content);
    });

    // Assert: the pure module boundary is preserved.
    expect(offendingFiles).toEqual([]);
  });
});
