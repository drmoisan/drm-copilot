import { describe, expect, it } from "@jest/globals";

import type { FileSystem } from "../../src/lib/file-system";
import {
  EXCLUDE_GLOBS,
  GOVERNED_GLOBS,
  iterGovernedFiles,
} from "../../src/lib/json-config";

/**
 * Compile a glob into an anchored RegExp using the same token semantics as the
 * production RealFileSystem.glob (`**`, `*`, `?`). Defined locally so the fake
 * filesystem validates iterGovernedFiles logic with matching glob semantics.
 */
function compileGlob(pattern: string): RegExp {
  let regex = "";
  let index = 0;
  while (index < pattern.length) {
    const char = pattern[index];
    if (char === "*") {
      if (pattern[index + 1] === "*") {
        if (pattern[index + 2] === "/") {
          regex += "(?:.*/)?";
          index += 3;
        } else {
          regex += ".*";
          index += 2;
        }
        continue;
      }
      regex += "[^/]*";
      index += 1;
      continue;
    }
    if (char === "?") {
      regex += "[^/]";
      index += 1;
      continue;
    }
    regex += (char ?? "").replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
    index += 1;
  }
  return new RegExp(`^${regex}$`);
}

/**
 * In-memory FileSystem fake modeling a virtual tree from a set of file paths.
 * Directories are derived from the file paths. glob matches both files and
 * directories (as the production walker does); isFile is true only for files.
 */
class VirtualFileSystem implements FileSystem {
  private readonly files: Set<string>;
  private readonly dirs: Set<string>;
  private readonly root: string;

  constructor(filePaths: readonly string[], root: string) {
    this.root = root;
    this.files = new Set(filePaths);
    this.dirs = new Set<string>();
    // Derive every ancestor directory of each file path.
    for (const file of filePaths) {
      const segments = file.split("/");
      for (let count = 1; count < segments.length; count += 1) {
        this.dirs.add(segments.slice(0, count).join("/"));
      }
    }
  }

  glob(root: string, pattern: string): string[] {
    const matcher = compileGlob(pattern);
    const matches: string[] = [];
    // Test every known directory and file (relative to root) against the glob.
    for (const candidate of [...this.dirs, ...this.files]) {
      if (matcher.test(candidate)) {
        matches.push(`${root}/${candidate}`);
      }
    }
    return matches;
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

const ROOT = "/repo";

describe("json-config constants", () => {
  it("GOVERNED_GLOBS is a non-empty array containing scripts glob", () => {
    // Arrange / Act / Assert
    expect(Array.isArray(GOVERNED_GLOBS)).toBe(true);
    expect(GOVERNED_GLOBS.length).toBeGreaterThan(0);
    expect(GOVERNED_GLOBS).toContain("scripts/**/*.json");
  });

  it("EXCLUDE_GLOBS is a non-empty array containing data exclude", () => {
    // Arrange / Act / Assert
    expect(Array.isArray(EXCLUDE_GLOBS)).toBe(true);
    expect(EXCLUDE_GLOBS.length).toBeGreaterThan(0);
    expect(EXCLUDE_GLOBS).toContain("data/**");
  });
});

describe("iterGovernedFiles", () => {
  it("yields nothing for an empty filesystem", () => {
    // Arrange
    const fs = new VirtualFileSystem([], ROOT);

    // Act
    const result = iterGovernedFiles(fs, ROOT);

    // Assert
    expect(result).toEqual([]);
  });

  it("excludes .vscode/*.json (JSONC, not governed)", () => {
    // Arrange
    const fs = new VirtualFileSystem([".vscode/tasks.json"], ROOT);

    // Act
    const result = iterGovernedFiles(fs, ROOT);

    // Assert
    expect(result).not.toContain(`${ROOT}/.vscode/tasks.json`);
  });

  it("excludes nested .vscode/**/*.json", () => {
    // Arrange
    const fs = new VirtualFileSystem([".vscode/subdir/config.json"], ROOT);

    // Act
    const result = iterGovernedFiles(fs, ROOT);

    // Assert
    expect(result).not.toContain(`${ROOT}/.vscode/subdir/config.json`);
  });

  it("excludes files under data/**", () => {
    // Arrange
    const fs = new VirtualFileSystem(["data/metadata.json"], ROOT);

    // Act
    const result = iterGovernedFiles(fs, ROOT);

    // Assert
    expect(result).not.toContain(`${ROOT}/data/metadata.json`);
  });

  it("excludes files under artifacts/**", () => {
    // Arrange
    const fs = new VirtualFileSystem(["artifacts/output.json"], ROOT);

    // Act
    const result = iterGovernedFiles(fs, ROOT);

    // Assert
    expect(result).not.toContain(`${ROOT}/artifacts/output.json`);
  });

  it("excludes when a parent directory is excluded", () => {
    // Arrange: htmlcov is excluded; a nested report is not governed/included.
    const fs = new VirtualFileSystem(["htmlcov/subdir/report.json"], ROOT);

    // Act
    const result = iterGovernedFiles(fs, ROOT);

    // Assert
    expect(result).not.toContain(`${ROOT}/htmlcov/subdir/report.json`);
  });

  it("excludes .devcontainer/*.json (JSONC, not governed)", () => {
    // Arrange
    const fs = new VirtualFileSystem([".devcontainer/devcontainer.json"], ROOT);

    // Act
    const result = iterGovernedFiles(fs, ROOT);

    // Assert
    expect(result).not.toContain(`${ROOT}/.devcontainer/devcontainer.json`);
  });

  it("finds files under scripts/**/*.json", () => {
    // Arrange
    const fs = new VirtualFileSystem(["scripts/subdir/config.json"], ROOT);

    // Act
    const result = iterGovernedFiles(fs, ROOT);

    // Assert
    expect(result).toContain(`${ROOT}/scripts/subdir/config.json`);
  });

  it("finds files under docs/**/*.json", () => {
    // Arrange
    const fs = new VirtualFileSystem(["docs/features/manifest.json"], ROOT);

    // Act
    const result = iterGovernedFiles(fs, ROOT);

    // Assert
    expect(result).toContain(`${ROOT}/docs/features/manifest.json`);
  });

  it("finds files under examples/**/*.json", () => {
    // Arrange
    const fs = new VirtualFileSystem(["examples/meta/sample.json"], ROOT);

    // Act
    const result = iterGovernedFiles(fs, ROOT);

    // Assert
    expect(result).toContain(`${ROOT}/examples/meta/sample.json`);
  });

  it("accepts a string root", () => {
    // Arrange
    const fs = new VirtualFileSystem(["scripts/config.json"], ROOT);

    // Act
    const result = iterGovernedFiles(fs, ROOT);

    // Assert
    expect(result).toContain(`${ROOT}/scripts/config.json`);
  });

  it("yields only included files when mixed with excluded", () => {
    // Arrange
    const fs = new VirtualFileSystem(
      ["scripts/config.json", "data/corpus.json"],
      ROOT,
    );

    // Act
    const result = iterGovernedFiles(fs, ROOT);

    // Assert
    expect(result).toContain(`${ROOT}/scripts/config.json`);
    expect(result).not.toContain(`${ROOT}/data/corpus.json`);
  });

  it("skips non-file glob matches (a directory named *.json)", () => {
    // Arrange: a directory named weird.json matches the glob but is not a file.
    const fs = new VirtualFileSystem(["scripts/weird.json/inner.txt"], ROOT);

    // Act
    const result = iterGovernedFiles(fs, ROOT);

    // Assert: the directory scripts/weird.json must not be returned.
    expect(result).not.toContain(`${ROOT}/scripts/weird.json`);
  });
});
