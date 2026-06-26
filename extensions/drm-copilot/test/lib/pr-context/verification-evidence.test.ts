import { describe, expect, it } from "@jest/globals";

import { type FileSystem } from "../../../src/lib/file-system";
import {
  discoverCanonicalEvidenceFiles,
  parseVerificationEvidenceFile,
  parseVerificationEvidenceMarkdown,
} from "../../../src/lib/pr-context/verification-evidence";

/**
 * Tests for the verification-evidence port. An in-memory `FileSystem` seeds
 * files and directories and implements a `**`-aware glob so discovery is
 * exercised without touching disk.
 */

/**
 * Compile a glob with `**` and `*` support into an anchored RegExp matching a
 * relative POSIX path (sufficient for the canonical evidence patterns).
 */
function compileGlob(pattern: string): RegExp {
  let regex = "";
  let index = 0;
  while (index < pattern.length) {
    const char = pattern[index]!;
    if (char === "*" && pattern[index + 1] === "*") {
      if (pattern[index + 2] === "/") {
        regex += "(?:.*/)?";
        index += 3;
      } else {
        regex += ".*";
        index += 2;
      }
      continue;
    }
    if (char === "*") {
      regex += "[^/]*";
      index += 1;
      continue;
    }
    regex += char.replace(/[.+?^${}()|[\]\\]/g, "\\$&");
    index += 1;
  }
  return new RegExp(`^${regex}$`);
}

/** In-memory `FileSystem` with seeded files and directories. */
class SeededFileSystem implements FileSystem {
  readonly files = new Map<string, string>();
  readonly dirs = new Set<string>();

  glob(root: string, pattern: string): string[] {
    const matcher = compileGlob(pattern);
    const prefix = `${root}/`;
    const matches: string[] = [];
    // Test each seeded file's path relative to root against the pattern.
    for (const path of this.files.keys()) {
      if (path.startsWith(prefix)) {
        const relative = path.slice(prefix.length);
        if (matcher.test(relative)) {
          matches.push(path);
        }
      }
    }
    return matches;
  }

  isFile(path: string): boolean {
    return this.files.has(path);
  }

  exists(path: string): boolean {
    return this.files.has(path) || this.dirs.has(path);
  }

  isDirectory(path: string): boolean {
    return this.dirs.has(path);
  }

  listDirectory(): string[] {
    return [];
  }

  readTextFile(path: string): string {
    const content = this.files.get(path);
    if (content === undefined) {
      throw new Error(`ENOENT: ${path}`);
    }
    return content;
  }

  writeTextFile(path: string, content: string): void {
    this.files.set(path, content);
  }

  ensureDir(path: string): void {
    this.dirs.add(path);
  }
}

const ROOT = "/repo";
const FEATURE = "my-feature";
const FEATURE_ROOT = `${ROOT}/docs/features/active/${FEATURE}`;

describe("parseVerificationEvidenceMarkdown", () => {
  it("returns pass when all fields are present and exit code is 0", () => {
    const md = "Timestamp: 2026-01-01T00-00\nCommand: npm test\nEXIT_CODE: 0";
    const record = parseVerificationEvidenceMarkdown({
      feature: FEATURE,
      sourceFile: "evidence/qa-gates/a.md",
      markdown: md,
    });
    expect(record.normalizedResult).toBe("pass");
    expect(record.exitCode).toBe(0);
    expect(record.command).toBe("npm test");
    expect(record.timestamp).toBe("2026-01-01T00-00");
  });

  it("returns fail when exit code is non-zero", () => {
    const md = "Timestamp: t\nCommand: c\nEXIT_CODE: 1";
    const record = parseVerificationEvidenceMarkdown({
      feature: FEATURE,
      sourceFile: "s.md",
      markdown: md,
    });
    expect(record.normalizedResult).toBe("fail");
    expect(record.exitCode).toBe(1);
  });

  it("returns unparseable when a required field is missing", () => {
    const md = "Timestamp: t\nEXIT_CODE: 0";
    const record = parseVerificationEvidenceMarkdown({
      feature: FEATURE,
      sourceFile: "s.md",
      markdown: md,
    });
    expect(record.normalizedResult).toBe("unparseable");
    expect(record.command).toBeNull();
  });

  it("returns unparseable when EXIT_CODE is not an integer", () => {
    const md = "Timestamp: t\nCommand: c\nEXIT_CODE: ok";
    const record = parseVerificationEvidenceMarkdown({
      feature: FEATURE,
      sourceFile: "s.md",
      markdown: md,
    });
    expect(record.normalizedResult).toBe("unparseable");
    expect(record.exitCode).toBeNull();
  });

  it("keeps the first occurrence for a duplicated required key", () => {
    const md = "Timestamp: first\nTimestamp: second\nCommand: c\nEXIT_CODE: 0";
    const record = parseVerificationEvidenceMarkdown({
      feature: FEATURE,
      sourceFile: "s.md",
      markdown: md,
    });
    expect(record.timestamp).toBe("first");
  });
});

describe("discoverCanonicalEvidenceFiles", () => {
  it("returns an empty list when the feature root is absent", () => {
    const fs = new SeededFileSystem();
    expect(discoverCanonicalEvidenceFiles(fs, ROOT, FEATURE)).toEqual([]);
  });

  it("globs the three canonical roots and returns sorted relative paths", () => {
    // Arrange: seed files across the qa-gates, regression-testing, and other roots.
    const fs = new SeededFileSystem();
    fs.dirs.add(FEATURE_ROOT);
    fs.files.set(`${FEATURE_ROOT}/evidence/qa-gates/b.md`, "x");
    fs.files.set(`${FEATURE_ROOT}/evidence/qa-gates/a.md`, "x");
    fs.files.set(`${FEATURE_ROOT}/evidence/regression-testing/r.md`, "x");
    fs.files.set(`${FEATURE_ROOT}/evidence/other/o.md`, "x");
    fs.files.set(`${FEATURE_ROOT}/evidence/qa-gates/skip.txt`, "x");

    // Act
    const found = discoverCanonicalEvidenceFiles(fs, ROOT, FEATURE);

    // Assert: only .md files, deduplicated, repo-relative, code-point sorted.
    expect(found).toEqual([
      "docs/features/active/my-feature/evidence/other/o.md",
      "docs/features/active/my-feature/evidence/qa-gates/a.md",
      "docs/features/active/my-feature/evidence/qa-gates/b.md",
      "docs/features/active/my-feature/evidence/regression-testing/r.md",
    ]);
  });
});

describe("parseVerificationEvidenceFile", () => {
  it("reads the file through the filesystem and parses it", () => {
    const fs = new SeededFileSystem();
    fs.files.set(
      `${ROOT}/evidence/qa-gates/a.md`,
      "Timestamp: t\nCommand: c\nEXIT_CODE: 0",
    );
    const record = parseVerificationEvidenceFile({
      fs,
      root: ROOT,
      feature: FEATURE,
      relativePath: "evidence/qa-gates/a.md",
    });
    expect(record.normalizedResult).toBe("pass");
    expect(record.sourceFile).toBe("evidence/qa-gates/a.md");
  });

  it("propagates a read failure as a thrown error", () => {
    const fs = new SeededFileSystem();
    expect(() =>
      parseVerificationEvidenceFile({
        fs,
        root: ROOT,
        feature: FEATURE,
        relativePath: "evidence/qa-gates/missing.md",
      }),
    ).toThrow("ENOENT");
  });
});
