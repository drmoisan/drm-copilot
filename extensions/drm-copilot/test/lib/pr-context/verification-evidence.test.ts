import { describe, expect, it } from "@jest/globals";

import { type FileSystem } from "../../../src/lib/file-system";
import {
  discoverCanonicalEvidenceFiles,
  normalizeResult,
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

  // Eleven-shape fixture table transcribed from `spec.md` "Unit tests (pytest)",
  // in the same order and with the same shape identifiers as the Python
  // transcription in `tests/scripts/dev_tools/pr_context/test_verification_evidence.py`
  // so the two tables are diffable by eye (AC8). Shapes 01-05 and 07-11 each
  // carry exactly ONE `EXIT_CODE:` line.
  //
  // shape-06 is the DUPLICATED-`EXIT_CODE` case and carries TWO `EXIT_CODE:`
  // lines by definition. Its expected record is RUNTIME-SPECIFIC: the guard
  // `!parsed.has(key)` makes TypeScript FIRST-wins, so this case asserts the
  // FIRST value (`1`), deliberately differing from the Python case, which
  // asserts the second (`0`). shape-06 is EXCLUDED from the AC8 cross-runtime
  // agreement assertion; the exclusion is attributable to the deferred
  // duplicate-`EXIT_CODE` defect, not to this change.
  const shapeCases: readonly {
    readonly shapeId: string;
    readonly markdown: string;
    readonly expectedResult: "pass" | "fail" | "unparseable";
    readonly expectedExit: number | null;
    readonly expectedExpectation: number;
  }[] = [
    {
      shapeId: "shape-01",
      markdown: "Timestamp: t\nCommand: c\nEXIT_CODE: 0",
      expectedResult: "pass",
      expectedExit: 0,
      expectedExpectation: 0,
    },
    {
      shapeId: "shape-02",
      markdown: "Timestamp: t\nCommand: c\nEXIT_CODE: 1",
      expectedResult: "fail",
      expectedExit: 1,
      expectedExpectation: 0,
    },
    {
      shapeId: "shape-03",
      markdown: "Timestamp: t\nCommand: c\nEXIT_CODE: ok",
      expectedResult: "unparseable",
      expectedExit: null,
      expectedExpectation: 0,
    },
    {
      shapeId: "shape-04",
      markdown: "Timestamp: t\nEXIT_CODE: 0",
      expectedResult: "unparseable",
      expectedExit: null,
      expectedExpectation: 0,
    },
    {
      shapeId: "shape-05",
      markdown: "Timestamp: t\nCommand:\nEXIT_CODE: 0",
      expectedResult: "unparseable",
      expectedExit: null,
      expectedExpectation: 0,
    },
    {
      shapeId: "shape-06",
      markdown: "Timestamp: t\nCommand: c\nEXIT_CODE: 1\nEXIT_CODE: 0",
      expectedResult: "fail",
      expectedExit: 1,
      expectedExpectation: 0,
    },
    {
      shapeId: "shape-07",
      markdown:
        "Timestamp: t\nCommand: c\nEXIT_CODE: 0\nOutput Summary: all gates green",
      expectedResult: "pass",
      expectedExit: 0,
      expectedExpectation: 0,
    },
    {
      shapeId: "shape-08",
      markdown: "Timestamp: t\nCommand: c\nEXIT_CODE: 2",
      expectedResult: "fail",
      expectedExit: 2,
      expectedExpectation: 0,
    },
    {
      shapeId: "shape-09",
      markdown: "Timestamp: t\nCommand: c\nEXIT_CODE: 1\nExpectedExitCode: 1",
      expectedResult: "pass",
      expectedExit: 1,
      expectedExpectation: 1,
    },
    {
      shapeId: "shape-10",
      markdown: "Timestamp: t\nCommand: c\nEXIT_CODE: 2\nExpectedExitCode: 1",
      expectedResult: "fail",
      expectedExit: 2,
      expectedExpectation: 1,
    },
    {
      shapeId: "shape-11",
      markdown:
        "Timestamp: t\nCommand: c\nEXIT_CODE: 1\nExpectedExitCode: banana",
      expectedResult: "unparseable",
      expectedExit: null,
      expectedExpectation: 0,
    },
  ];

  it.each(shapeCases)(
    "parses $shapeId to its specified record",
    ({ markdown, expectedResult, expectedExit, expectedExpectation }) => {
      const record = parseVerificationEvidenceMarkdown({
        feature: FEATURE,
        sourceFile: "evidence/qa-gates/shape.md",
        markdown,
      });
      expect(record.normalizedResult).toBe(expectedResult);
      expect(record.exitCode).toBe(expectedExit);
      expect(record.expectedExitCode).toBe(expectedExpectation);
    },
  );

  it("defaults the expectation to zero and matches pre-change records", () => {
    // Shapes 1-8 carry no expectation key, so each must reproduce the
    // pre-change record: expectation zero and the pre-change expression.
    for (const shape of shapeCases.slice(0, 8)) {
      const record = parseVerificationEvidenceMarkdown({
        feature: FEATURE,
        sourceFile: "evidence/qa-gates/shape.md",
        markdown: shape.markdown,
      });
      expect(record.expectedExitCode).toBe(0);
      if (record.exitCode === null) {
        expect(record.normalizedResult).toBe("unparseable");
      } else {
        expect(record.normalizedResult).toBe(
          record.exitCode === 0 ? "pass" : "fail",
        );
      }
    }
  });

  it("normalizeResult with a zero expectation matches the pre-change expression", () => {
    const observedValues = [
      -8, -7, -6, -5, -4, -3, -2, -1, 0, 1, 2, 3, 4, 5, 6, 7, 8, -2147483648,
      -1000000, 1000000, 2147483647,
    ];
    for (const observed of observedValues) {
      expect(normalizeResult(observed, 0)).toBe(
        observed === 0 ? "pass" : "fail",
      );
    }
  });

  it("normalizes to pass when the observed code equals a non-zero expectation", () => {
    for (const value of [1, 137, -3]) {
      const md = `Timestamp: 2026-08-20T09-53\nCommand: git grep -n forbidden-token\nEXIT_CODE: ${String(value)}\nExpectedExitCode: ${String(value)}`;
      const record = parseVerificationEvidenceMarkdown({
        feature: FEATURE,
        sourceFile: "evidence/qa-gates/absence-gate.md",
        markdown: md,
      });
      expect(record.normalizedResult).toBe("pass");
      expect(record.exitCode).toBe(value);
      expect(record.expectedExitCode).toBe(value);
    }
  });

  it("normalizes to fail when the observed code differs from a non-zero expectation", () => {
    for (const observed of [2, 0]) {
      const md = `Timestamp: t\nCommand: c\nEXIT_CODE: ${String(observed)}\nExpectedExitCode: 1`;
      const record = parseVerificationEvidenceMarkdown({
        feature: FEATURE,
        sourceFile: "s.md",
        markdown: md,
      });
      expect(record.normalizedResult).toBe("fail");
      expect(record.exitCode).toBe(observed);
      expect(record.expectedExitCode).toBe(1);
    }
  });

  it("reports unparseable for a non-integer expectation", () => {
    for (const row of ["ExpectedExitCode: banana", "ExpectedExitCode:"]) {
      const md = `Timestamp: t\nCommand: c\nEXIT_CODE: 1\n${row}`;
      const record = parseVerificationEvidenceMarkdown({
        feature: FEATURE,
        sourceFile: "s.md",
        markdown: md,
      });
      expect(record.normalizedResult).toBe("unparseable");
      expect(record.exitCode).toBeNull();
      expect(record.expectedExitCode).toBe(0);
    }
  });

  it("takes the first occurrence of a duplicated expectation key", () => {
    const md =
      "Timestamp: t\nCommand: c\nEXIT_CODE: 7\nExpectedExitCode: 7\nExpectedExitCode: 9";
    const record = parseVerificationEvidenceMarkdown({
      feature: FEATURE,
      sourceFile: "s.md",
      markdown: md,
    });
    expect(record.expectedExitCode).toBe(7);
    expect(record.normalizedResult).toBe("pass");
  });

  it("reports unparseable for EXIT_CODE SKIPPED", () => {
    for (const md of [
      "Timestamp: t\nCommand: c\nEXIT_CODE: SKIPPED",
      "Timestamp: t\nCommand: c\nEXIT_CODE: SKIPPED\nExpectedExitCode: 1",
    ]) {
      const record = parseVerificationEvidenceMarkdown({
        feature: FEATURE,
        sourceFile: "s.md",
        markdown: md,
      });
      expect(record.normalizedResult).toBe("unparseable");
      expect(record.exitCode).toBeNull();
      expect(record.expectedExitCode).toBe(0);
    }
  });

  it("ignores rows outside the accept-list", () => {
    const withExtraRows =
      "Timestamp: t\nCommand: c\nEXIT_CODE: 1\nOutput Summary: one gate, zero matches\nexpectedexitcode: 1";
    const withoutExtraRows = "Timestamp: t\nCommand: c\nEXIT_CODE: 1";
    const record = parseVerificationEvidenceMarkdown({
      feature: FEATURE,
      sourceFile: "s.md",
      markdown: withExtraRows,
    });
    const reference = parseVerificationEvidenceMarkdown({
      feature: FEATURE,
      sourceFile: "s.md",
      markdown: withoutExtraRows,
    });
    expect(record).toEqual(reference);
    expect(record.normalizedResult).toBe("fail");
    expect(record.expectedExitCode).toBe(0);
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
