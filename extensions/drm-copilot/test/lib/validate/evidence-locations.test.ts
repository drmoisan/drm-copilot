import { describe, expect, it } from "@jest/globals";

import type { FileSystem } from "../../../src/lib/file-system";
import {
  findForbiddenPaths,
  formatViolation,
} from "../../../src/lib/validate/evidence-locations";

const ROOT = "/repo";

/**
 * In-memory FileSystem fake modeling a virtual tree from a set of file paths.
 * `glob(root, "**")` returns every known file path joined to root; `isFile`
 * returns true only for those files. Other methods are unused by the scanner.
 */
class VirtualFileSystem implements FileSystem {
  private readonly files: Set<string>;
  private readonly root: string;

  constructor(filePaths: readonly string[], root: string) {
    this.root = root;
    this.files = new Set(filePaths);
  }

  glob(root: string, pattern: string): string[] {
    // The scanner uses the `**` pattern to enumerate all files under the root;
    // any other pattern would be a contract change, so guard it explicitly.
    if (pattern !== "**") {
      throw new Error(`unexpected glob pattern: ${pattern}`);
    }
    return [...this.files].map((relative) => `${root}/${relative}`);
  }

  isFile(path: string): boolean {
    const prefix = `${this.root}/`;
    const relative = path.startsWith(prefix) ? path.slice(prefix.length) : path;
    return this.files.has(relative);
  }

  readTextFile(): string {
    throw new Error("not used");
  }

  writeTextFile(): void {
    throw new Error("not used");
  }

  ensureDir(): void {
    throw new Error("not used");
  }
}

describe("findForbiddenPaths", () => {
  it("reports a file under each forbidden prefix with the canonical hint", () => {
    // Arrange: one offending file per forbidden prefix.
    const cases: ReadonlyArray<readonly [string, string]> = [
      ["artifacts/baselines/a.md", "<FEATURE>/evidence/baseline/"],
      ["artifacts/baseline/b.md", "<FEATURE>/evidence/baseline/"],
      ["artifacts/qa/c.md", "<FEATURE>/evidence/qa-gates/"],
      ["artifacts/qa-gates/d.md", "<FEATURE>/evidence/qa-gates/"],
      ["artifacts/coverage/e.md", "<FEATURE>/evidence/qa-gates/"],
      ["artifacts/evidence/f.md", "<FEATURE>/evidence/<kind>/"],
      ["artifacts/regression-testing/g.md", "<FEATURE>/evidence/qa-gates/"],
      ["artifacts/post-change/h.md", "<FEATURE>/evidence/qa-gates/"],
      [
        "artifacts/research/i.md",
        "docs/features/active/<feature>/research/ or docs/research/",
      ],
    ];

    for (const [relativePath, canonical] of cases) {
      const fs = new VirtualFileSystem([relativePath], ROOT);

      // Act
      const violations = findForbiddenPaths(fs, ROOT);

      // Assert
      expect(violations).toEqual([
        { path: `${ROOT}/${relativePath}`, canonical },
      ]);
    }
  });

  it("does not report a file under a canonical evidence path", () => {
    // Arrange
    const fs = new VirtualFileSystem(
      ["docs/features/active/x/evidence/baseline/note.md"],
      ROOT,
    );

    // Act
    const violations = findForbiddenPaths(fs, ROOT);

    // Assert
    expect(violations).toEqual([]);
  });

  it("returns an empty list for a clean tree", () => {
    // Arrange
    const fs = new VirtualFileSystem(["src/index.ts", "README.md"], ROOT);

    // Act
    const violations = findForbiddenPaths(fs, ROOT);

    // Assert
    expect(violations).toEqual([]);
  });

  it("reports only the first matching forbidden prefix per file", () => {
    // Arrange: a path under artifacts/baselines/ must match that prefix only.
    const fs = new VirtualFileSystem(["artifacts/baselines/x.md"], ROOT);

    // Act
    const violations = findForbiddenPaths(fs, ROOT);

    // Assert: exactly one violation entry per offending file.
    expect(violations).toHaveLength(1);
    expect(violations[0]?.canonical).toBe("<FEATURE>/evidence/baseline/");
  });

  it("skips glob entries that are not regular files", () => {
    // Arrange: glob yields a directory-like entry that isFile rejects.
    const fs: FileSystem = {
      glob: () => [`${ROOT}/artifacts/baselines`],
      isFile: () => false,
      readTextFile: () => {
        throw new Error("not used");
      },
      writeTextFile: () => {
        throw new Error("not used");
      },
      ensureDir: () => {
        throw new Error("not used");
      },
    };

    // Act
    const violations = findForbiddenPaths(fs, ROOT);

    // Assert: a non-file entry produces no violation.
    expect(violations).toEqual([]);
  });

  it("skips glob entries that are not under the root prefix", () => {
    // Arrange: glob yields a file outside the root; the relative guard skips it.
    const fs: FileSystem = {
      glob: () => ["/other/artifacts/baselines/x.md"],
      isFile: () => true,
      readTextFile: () => {
        throw new Error("not used");
      },
      writeTextFile: () => {
        throw new Error("not used");
      },
      ensureDir: () => {
        throw new Error("not used");
      },
    };

    // Act
    const violations = findForbiddenPaths(fs, ROOT);

    // Assert: an out-of-root file is not reported.
    expect(violations).toEqual([]);
  });
});

describe("formatViolation", () => {
  it("renders the VIOLATION line with an em dash", () => {
    // Arrange / Act
    const line = formatViolation(
      "/repo/artifacts/qa/x.md",
      "<FEATURE>/evidence/qa-gates/",
    );

    // Assert
    expect(line).toBe(
      "VIOLATION: /repo/artifacts/qa/x.md — use <FEATURE>/evidence/qa-gates/ instead",
    );
  });
});
