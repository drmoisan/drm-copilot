/**
 * Tests for the pure push-down exclusion manifest module.
 *
 * Covers the root-level manifest path invariant, the manifest grammar and its
 * malformed-entry set, the exact/directory/glob matcher boundaries, first-match
 * planning, and five seeded property checks. Property cases iterate a fixed
 * seed list and include `seed` in every compared object, so a failing
 * `toEqual` prints the seed that reproduces it. No test touches the filesystem.
 */
import { ROOT_FOLDERS } from "../../../src/lib/push-down/claude-customizations";
import {
  assertManifestPathIsRootLevel,
  EXCLUSION_MANIFEST_RELATIVE_PATH,
  type ExclusionEntry,
  ExclusionManifestError,
  matchesExclusionEntry,
  normalizeExclusionEntry,
  parseExclusionManifest,
  planExclusions,
} from "../../../src/lib/push-down/claude-exclusion-manifest";
import { SeededRandom, SEEDS } from "./seeded-random.test-helpers";

const MANIFEST_PATH = EXCLUSION_MANIFEST_RELATIVE_PATH;

/**
 * Parse `text` as a one-line manifest and return its single entry.
 *
 * @param text Entry text without a terminator.
 * @returns The parsed entry.
 */
function singleEntry(text: string): ExclusionEntry {
  const [entry] = parseExclusionManifest(`${text}\n`, MANIFEST_PATH).entries;
  if (entry === undefined) {
    throw new Error(`expected one entry for ${text}`);
  }
  return entry;
}

/**
 * Capture the error a callback throws.
 *
 * @param action Callback expected to throw.
 * @returns The thrown value.
 */
function captureError(action: () => unknown): unknown {
  try {
    action();
  } catch (error: unknown) {
    return error;
  }
  throw new Error("expected the action to throw");
}

/**
 * Return the first entry of a manifest that matches a candidate.
 *
 * @param entries Manifest entries in order.
 * @param candidate Destination-relative candidate.
 * @returns The first matching entry, or `undefined`.
 */
function firstMatch(
  entries: ReadonlyArray<ExclusionEntry>,
  candidate: string,
): ExclusionEntry | undefined {
  return entries.find((entry) => matchesExclusionEntry(entry, candidate));
}

describe("claude-exclusion-manifest", () => {
  it("declares a root-level manifest path outside every ROOT_FOLDERS entry", () => {
    // Arrange / Act / Assert
    expect(EXCLUSION_MANIFEST_RELATIVE_PATH).toBe(".push-down-exclusions");
    expect(EXCLUSION_MANIFEST_RELATIVE_PATH.includes("/")).toBe(false);
    expect(
      ROOT_FOLDERS.filter((root) =>
        EXCLUSION_MANIFEST_RELATIVE_PATH.startsWith(root),
      ),
    ).toEqual([]);
    expect(() => {
      assertManifestPathIsRootLevel(
        EXCLUSION_MANIFEST_RELATIVE_PATH,
        ROOT_FOLDERS,
      );
    }).not.toThrow();
  });

  it("rejects a manifest path containing a slash or a root-folder prefix", () => {
    // Arrange
    const roots = [".claude", "config"];

    // Act / Assert
    expect(() => {
      assertManifestPathIsRootLevel("a/b", roots);
    }).toThrow("Exclusion manifest path must be root-level: a/b");
    expect(() => {
      assertManifestPathIsRootLevel(".claude-x", roots);
    }).toThrow("must not begin with published root .claude");
  });

  it("parses comments, blank lines, CRLF, and a leading BOM", () => {
    // Arrange
    const text =
      "\uFEFF# reason\r\n.claude/rules/a.md\r\n\r\n   \r\n  # note\r\nconfig/b\r\n";

    // Act
    const manifest = parseExclusionManifest(text, MANIFEST_PATH);

    // Assert
    expect(manifest.path).toBe(MANIFEST_PATH);
    expect(manifest.entries.map((e) => [e.normalized, e.line])).toEqual([
      [".claude/rules/a.md", 2],
      ["config/b", 6],
    ]);
  });

  it("normalizes backslashes, a leading dot-slash, repeated slashes, and whitespace", () => {
    // Arrange
    const text = "  .\\config\\\\rules//x.md  \n";

    // Act
    const manifest = parseExclusionManifest(text, MANIFEST_PATH);

    // Assert
    expect(manifest.entries).toEqual([
      {
        raw: "  .\\config\\\\rules//x.md  ",
        normalized: "config/rules/x.md",
        kind: "exact",
        line: 1,
      },
    ]);
  });

  it("classifies entry kinds", () => {
    // Arrange
    const text = ".claude/a.md\n.claude/memory/\n.claude/**\nconfig/?.json\n";

    // Act
    const manifest = parseExclusionManifest(text, MANIFEST_PATH);

    // Assert
    expect(manifest.entries.map((e) => e.kind)).toEqual([
      "exact",
      "directory",
      "glob",
      "glob",
    ]);
  });

  it.each([
    "./",
    "/abs",
    "X:/abs",
    "a/../b",
    "!neg",
    "a[b].md",
    "a].md",
    "dir/**/",
    "\uFFFDx",
  ])(
    "rejects each malformed entry with the manifest path and line (%j)",
    (text) => {
      // Arrange / Act
      const error = captureError(() =>
        parseExclusionManifest(`${text}\n`, MANIFEST_PATH),
      );

      // Assert
      expect(error).toBeInstanceOf(ExclusionManifestError);
      const manifestError = error as ExclusionManifestError;
      expect(manifestError.path).toBe(".push-down-exclusions");
      expect(manifestError.line).toBe(1);
      expect(manifestError.message).toContain(".push-down-exclusions");
      expect(manifestError.message).toContain("line 1");
    },
  );

  it("reports the offending line after comments", () => {
    // Arrange / Act
    const error = captureError(() =>
      parseExclusionManifest("# c\n\n.claude/ok.md\n!bad\n", MANIFEST_PATH),
    );

    // Assert
    expect(error).toBeInstanceOf(ExclusionManifestError);
    expect((error as ExclusionManifestError).line).toBe(4);
    expect((error as ExclusionManifestError).message).toContain("line 4");
  });

  it.each([
    [".claude/rules/x", ".claude/rules/xy.md", false],
    [".claude/rules/*", ".claude/rules/sub/x.md", false],
    [".claude/**", ".claude/a/b/c.md", true],
    ["config/?.json", "config/a.json", true],
  ])(
    "matches exact, directory, and glob boundaries (%s vs %s)",
    (entry, candidate, expected) => {
      // Arrange
      const parsed = singleEntry(entry);

      // Act / Assert
      expect(matchesExclusionEntry(parsed, candidate)).toBe(expected);
    },
  );

  it("applies first-match precedence", () => {
    // Arrange
    const manifest = parseExclusionManifest(
      ".claude/rules/quality-tiers.md\n.claude/rules/**\n",
      MANIFEST_PATH,
    );

    // Act
    const plan = planExclusions(
      [".claude/rules/quality-tiers.md", ".claude/rules/python.md"],
      manifest,
      () => false,
    );

    // Assert
    expect(plan.kept).toEqual([]);
    expect(plan.skipped.map((s) => [s.relativePath, s.entry, s.line])).toEqual([
      [".claude/rules/quality-tiers.md", ".claude/rules/quality-tiers.md", 1],
      [".claude/rules/python.md", ".claude/rules/**", 2],
    ]);
    expect(plan.unmatchedEntries).toEqual([]);
  });

  it("reports a shadowed entry as unmatched", () => {
    // Arrange
    const manifest = parseExclusionManifest(
      ".claude/rules/**\n.claude/rules/quality-tiers.md\n",
      MANIFEST_PATH,
    );

    // Act
    const plan = planExclusions(
      [".claude/rules/quality-tiers.md"],
      manifest,
      () => false,
    );

    // Assert
    expect(plan.skipped.map((s) => s.entry)).toEqual([".claude/rules/**"]);
    expect(plan.unmatchedEntries.map((e) => [e.normalized, e.line])).toEqual([
      [".claude/rules/quality-tiers.md", 2],
    ]);
  });

  it("uses the destination probe for status", () => {
    // Arrange
    const manifest = parseExclusionManifest("a.md\nb.md\n", MANIFEST_PATH);
    const probed: string[] = [];
    const probe = (relativePath: string): boolean => {
      probed.push(relativePath);
      return relativePath === "a.md";
    };

    // Act
    const plan = planExclusions(["a.md", "b.md", "c.md"], manifest, probe);

    // Assert
    expect(
      plan.skipped.map((s) => [s.relativePath, s.destinationStatus]),
    ).toEqual([
      ["a.md", "present"],
      ["b.md", "absent"],
    ]);
    expect(plan.kept).toEqual(["c.md"]);
    expect(probed).toEqual(["a.md", "b.md"]);
  });

  it("property: an exact entry matches only itself", () => {
    for (const seed of SEEDS) {
      // Arrange
      const random = new SeededRandom(seed);
      const target = random.relativePath(1 + random.nextInt(4));
      const entry = singleEntry(target);
      const candidates = [
        target,
        `${target}x`,
        `${target}/${random.pathSegment()}`,
      ];
      for (let index = 0; index < 20; index += 1) {
        candidates.push(random.relativePath(1 + random.nextInt(4)));
      }

      // Act
      const actual = candidates.map((candidate) => ({
        seed,
        candidate,
        matched: matchesExclusionEntry(entry, candidate),
      }));

      // Assert
      const expected = candidates.map((candidate) => ({
        seed,
        candidate,
        matched: candidate === target || candidate.startsWith(`${target}/`),
      }));
      expect(actual).toEqual(expected);
    }
  });

  it("property: a directory entry matches the same set with and without a trailing slash", () => {
    for (const seed of SEEDS) {
      // Arrange
      const random = new SeededRandom(seed);
      const base = random.relativePath(1 + random.nextInt(4));
      const withoutSlash = singleEntry(base);
      const withSlash = singleEntry(`${base}/`);
      const candidates = [
        base,
        `${base}/${random.relativePath(2)}`,
        `${base}z`,
      ];
      for (let index = 0; index < 20; index += 1) {
        candidates.push(random.relativePath(1 + random.nextInt(4)));
      }

      // Act
      const bare = candidates.map((candidate) => ({
        seed,
        candidate,
        matched: matchesExclusionEntry(withoutSlash, candidate),
      }));
      const slashed = candidates.map((candidate) => ({
        seed,
        candidate,
        matched: matchesExclusionEntry(withSlash, candidate),
      }));

      // Assert
      expect(slashed).toEqual(bare);
    }
  });

  it("property: a single star never crosses a separator", () => {
    for (const seed of SEEDS) {
      // Arrange
      const random = new SeededRandom(seed);
      const prefix = random.relativePath(1 + random.nextInt(4));
      const entry = singleEntry(`${prefix}/*`);
      const observed: Array<{
        seed: number;
        candidate: string;
        matched: boolean;
      }> = [];
      const expected: Array<{
        seed: number;
        candidate: string;
        matched: boolean;
      }> = [];

      // Act
      for (let index = 0; index < 10; index += 1) {
        const one = `${prefix}/${random.pathSegment()}`;
        const deeper = `${one}/${random.relativePath(1 + random.nextInt(4))}`;
        observed.push({
          seed,
          candidate: one,
          matched: matchesExclusionEntry(entry, one),
        });
        observed.push({
          seed,
          candidate: deeper,
          matched: matchesExclusionEntry(entry, deeper),
        });
        expected.push({ seed, candidate: one, matched: true });
        expected.push({ seed, candidate: deeper, matched: false });
      }

      // Assert
      expect(observed).toEqual(expected);
    }
  });

  it("property: normalization is idempotent", () => {
    for (const seed of SEEDS) {
      const random = new SeededRandom(seed);
      for (let index = 0; index < 20; index += 1) {
        // Arrange
        const segments = [0, 1, 2, 3].map(() => random.pathSegment());
        const separators = [0, 1, 2].map(() =>
          random.pick(["/", "\\", "//", "\\\\", "/\\"]),
        );
        const body = segments
          .slice(1)
          .reduce(
            (text, segment, position) =>
              `${text}${separators[position] ?? "/"}${segment}`,
            segments[0] ?? "",
          );
        const padding = " ".repeat(random.nextInt(4));
        const raw = `${padding}${random.pick(["", "./", ".\\"])}${body}${padding}`;

        // Act
        const once = normalizeExclusionEntry(raw);

        // Assert
        expect({
          seed,
          raw,
          twice: normalizeExclusionEntry(once),
          hasBackslash: once.includes("\\"),
          hasDoubleSlash: once.includes("//"),
        }).toEqual({
          seed,
          raw,
          twice: once,
          hasBackslash: false,
          hasDoubleSlash: false,
        });
      }
    }
  });

  it("property: planExclusions partitions the payload", () => {
    for (const seed of SEEDS) {
      // Arrange
      const random = new SeededRandom(seed);
      const payload = [
        ...new Set(
          Array.from(
            { length: 15 },
            () => `${random.relativePath(1 + random.nextInt(4))}.md`,
          ),
        ),
      ];
      const entryLines: string[] = [];
      const entryCount = 1 + random.nextInt(5);
      for (let index = 0; index < entryCount; index += 1) {
        const source = random.pick(payload).split("/");
        const head = source[0] ?? "";
        const form = random.nextInt(4);
        entryLines.push(
          form === 0
            ? source.join("/")
            : form === 1
              ? `${head}/`
              : form === 2
                ? `${head}/**`
                : `${random.relativePath(2)}/nomatch.md`,
        );
      }
      const manifest = parseExclusionManifest(
        `${entryLines.join("\n")}\n`,
        MANIFEST_PATH,
      );
      const present = new Set(payload.filter(() => random.nextInt(2) === 0));

      // Act
      const plan = planExclusions(payload, manifest, (p) => present.has(p));

      // Assert
      const skippedPaths = plan.skipped.map((s) => s.relativePath);
      const claimed = new Set(
        plan.skipped.map((s) => `${String(s.line)}:${s.entry}`),
      );
      const unmatched = plan.unmatchedEntries.map(
        (e) => `${String(e.line)}:${e.normalized}`,
      );
      expect({
        seed,
        partition: [...plan.kept, ...skippedPaths].sort(),
        keptOrder: plan.kept,
        keptMatches: plan.kept.filter(
          (p) => firstMatch(manifest.entries, p) !== undefined,
        ),
        skips: plan.skipped.map((s) => [s.entry, s.line, s.destinationStatus]),
        entryCover: [...claimed, ...unmatched].sort(),
        overlap: unmatched.filter((key) => claimed.has(key)),
      }).toEqual({
        seed,
        partition: [...payload].sort(),
        keptOrder: payload.filter((p) => plan.kept.includes(p)),
        keptMatches: [],
        skips: skippedPaths.map((p) => {
          const first = firstMatch(manifest.entries, p);
          return [
            first?.normalized,
            first?.line,
            present.has(p) ? "present" : "absent",
          ];
        }),
        entryCover: manifest.entries
          .map((e) => `${String(e.line)}:${e.normalized}`)
          .sort(),
        overlap: [],
      });
    }
  });
});
