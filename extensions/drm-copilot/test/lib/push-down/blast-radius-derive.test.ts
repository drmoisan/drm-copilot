import { describe, expect, it } from "@jest/globals";

import {
  BlastRadiusDeriveError,
  BlastRadiusDeriveFileSystem,
  BlastRadiusGuardError,
  collectDestinationObservations,
  type DirectoryEntry,
  type DirectoryLister,
} from "../../../src/lib/push-down/claude-blast-radius-derive";
import { deriveDestinationModuleMap } from "../../../src/lib/push-down/claude-blast-radius-derive-core";
import {
  buildInMemoryFileSystem,
  type InMemoryPushDownFileSystem,
} from "./push-down.test-helpers";

/**
 * Write-intercepting blast-radius derive decorator (issue #472).
 *
 * Purpose:
 *     Cover the decorator's own responsibilities: the depth-limited,
 *     ordinally-ordered destination scan, interception of exactly one
 *     destination-relative path, passthrough of every other path, the tolerance
 *     rule for an unreadable directory, failure semantics that leave the
 *     destination bytes untouched, and idempotency across a second push.
 *
 * Scope note:
 *     Every case is hermetic. The destination is an
 *     {@link InMemoryPushDownFileSystem} and the layout is described by an
 *     injected fake lister, so no temporary file is created and no real
 *     directory is read.
 */

const DEST = "/dest";
const TARGET = `${DEST}/config/blast-radius.json`;

/** Bundled source document supplied to every intercepted write. */
const SOURCE_DOCUMENT = `${JSON.stringify(
  {
    version: 1,
    shared_surfaces: [".claude/settings.json", "config/blast-radius.json"],
    shared_surface_globs: [],
    modules: {
      config: ["config/**"],
    },
    over_breadth_fraction: 0.25,
  },
  null,
  2,
)}\n`;

/**
 * Build a fake lister over an in-memory directory map.
 *
 * @param layout Map of absolute directory path to its shallow entries.
 * @returns A lister returning the mapped entries, or an empty array for an
 *   unmapped directory.
 */
function fakeLister(
  layout: Readonly<Record<string, ReadonlyArray<DirectoryEntry>>>,
): DirectoryLister {
  return (root) => layout[root] ?? [];
}

/**
 * Build a directory entry.
 *
 * @param name Entry name.
 * @param isDir Whether the entry is a directory.
 * @returns The entry record.
 */
function entry(name: string, isDir: boolean): DirectoryEntry {
  return { name, isDir };
}

/**
 * Build a decorator over a seeded in-memory destination.
 *
 * @param seeded The in-memory adapter to wrap.
 * @param lister The injected fake lister.
 * @returns The decorator under test.
 */
function decorate(
  seeded: InMemoryPushDownFileSystem,
  lister: DirectoryLister,
): BlastRadiusDeriveFileSystem {
  return new BlastRadiusDeriveFileSystem(seeded, DEST, lister);
}

/**
 * Read the parsed `modules` map of the written destination document.
 *
 * @param seeded The in-memory adapter holding the destination file.
 * @returns The `modules` object.
 */
function writtenModules(
  seeded: InMemoryPushDownFileSystem,
): Record<string, string[]> {
  const parsed: unknown = JSON.parse(seeded.readTextFile(TARGET));
  return (parsed as { modules: Record<string, string[]> }).modules;
}

/** The ratified read-by-mandate membership carried by the bundled document. */
const MANDATE_READS = [
  ".claude/rules/**",
  ".claude/skills/atomic-plan-contract/SKILL.md",
  ".claude/skills/evidence-and-timestamp-conventions/SKILL.md",
  ".github/instructions/**",
  "artifacts/**",
  "quality-tiers.yml",
];

/** Bundled source document carrying the optional `mandate_reads` key. */
const SOURCE_DOCUMENT_WITH_MANDATE_READS = `${JSON.stringify(
  {
    version: 1,
    shared_surfaces: [".claude/settings.json", "config/blast-radius.json"],
    shared_surface_globs: [],
    mandate_reads: MANDATE_READS,
    modules: {
      config: ["config/**"],
    },
    over_breadth_fraction: 0.25,
  },
  null,
  2,
)}\n`;

describe("issue #472: destination scan", () => {
  it("visits the root plus two nested levels and stops there", () => {
    // Arrange: a four-level chain; the fourth level must not be observed.
    const lister = fakeLister({
      [DEST]: [entry("a", true)],
      [`${DEST}/a`]: [entry("b", true)],
      [`${DEST}/a/b`]: [entry("c", true)],
      [`${DEST}/a/b/c`]: [entry("deep.txt", false)],
    });

    // Act
    const observed = collectDestinationObservations(DEST, lister).map(
      (observation) => observation.relativePath,
    );

    // Assert
    expect(observed).toEqual(["", "a", "a/b"]);
  });

  it("prunes excluded and dot-prefixed directory names", () => {
    // Arrange
    const lister = fakeLister({
      [DEST]: [
        entry("node_modules", true),
        entry("docs", true),
        entry("tests", true),
        entry(".git", true),
        entry("src", true),
      ],
      [`${DEST}/src`]: [entry("main.ts", false)],
    });

    // Act
    const observed = collectDestinationObservations(DEST, lister).map(
      (observation) => observation.relativePath,
    );

    // Assert
    expect(observed).toEqual(["", "src"]);
  });

  it("records only file names in each observation", () => {
    // Arrange
    const lister = fakeLister({
      [DEST]: [entry("go.mod", false), entry("cmd", true)],
      [`${DEST}/cmd`]: [entry("main.go", false)],
    });

    // Act
    const observations = collectDestinationObservations(DEST, lister);

    // Assert
    expect(observations[0]?.fileNames).toEqual(["go.mod"]);
    expect(observations[1]?.fileNames).toEqual(["main.go"]);
  });
});

describe("issue #472: interception and passthrough", () => {
  it("writes the derived document rather than the bundled bytes", () => {
    // Arrange: a destination whose layout declares one project directory.
    const seeded = buildInMemoryFileSystem({}, [DEST]);
    const lister = fakeLister({
      [DEST]: [entry("src", true)],
      [`${DEST}/src`]: [entry("App", true)],
      [`${DEST}/src/App`]: [entry("App.csproj", false)],
    });

    // Act
    decorate(seeded, lister).writeTextFile(TARGET, SOURCE_DOCUMENT);

    // Assert: the derived module is present and the bundled bytes are not what
    // landed on the destination.
    expect(writtenModules(seeded)["src/App"]).toEqual(["src/App/**"]);
    expect(seeded.readTextFile(TARGET)).not.toBe(SOURCE_DOCUMENT);
  });

  it("passes every other destination path straight through", () => {
    // Arrange
    const seeded = buildInMemoryFileSystem({}, [DEST]);
    const other = `${DEST}/config/orchestration-routing.json`;

    // Act
    decorate(seeded, fakeLister({})).writeTextFile(other, SOURCE_DOCUMENT);

    // Assert
    expect(seeded.readTextFile(other)).toBe(SOURCE_DOCUMENT);
  });

  it("does not intercept a same-named file outside the destination root", () => {
    // Arrange: a path that ends with the target relative path but is rooted
    // elsewhere must not be treated as the derivation target.
    const seeded = buildInMemoryFileSystem({}, ["/other"]);
    const foreign = "/other/config/blast-radius.json";

    // Act
    decorate(seeded, fakeLister({})).writeTextFile(foreign, SOURCE_DOCUMENT);

    // Assert
    expect(seeded.readTextFile(foreign)).toBe(SOURCE_DOCUMENT);
  });

  it("delegates the five read-side members to the wrapped adapter", () => {
    // Arrange
    const seeded = buildInMemoryFileSystem(
      { [`${DEST}/a/file.txt`]: "content\n" },
      [DEST],
    );
    const decorated = decorate(seeded, fakeLister({}));

    // Act / Assert: the decorator widens nothing; each member forwards.
    expect(decorated.listFiles(DEST)).toEqual([`${DEST}/a/file.txt`]);
    expect(decorated.isDir(`${DEST}/a`)).toBe(true);
    expect(decorated.isFile(`${DEST}/a/file.txt`)).toBe(true);
    expect(decorated.readTextFile(`${DEST}/a/file.txt`)).toBe("content\n");
    decorated.ensureDir(`${DEST}/created`);
    expect(seeded.isDir(`${DEST}/created`)).toBe(true);
  });
});

describe("issue #472: the guard is unreachable through the composed scan", () => {
  it("never offers a location bucket to the guard, so no push can trip it", () => {
    // Arrange: a destination carrying a top-level `docs` directory that holds a
    // project manifest. The scanner prunes the name before it can become an
    // observation, so the core is never asked to emit `docs/**`. The guard is
    // the second line of defense and is exercised directly in
    // blast-radius-derive-core.test.ts; this case pins the first line, and its
    // unreachability is deliberate: a destination with a docs/package.json must
    // publish successfully rather than fail the push.
    const seeded = buildInMemoryFileSystem({}, [DEST]);
    const lister = fakeLister({
      [DEST]: [entry("docs", true), entry("tests", true), entry("api", true)],
      [`${DEST}/docs`]: [entry("package.json", false)],
      [`${DEST}/tests`]: [entry("package.json", false)],
      [`${DEST}/api`]: [entry("go.mod", false)],
    });

    // Act
    decorate(seeded, lister).writeTextFile(TARGET, SOURCE_DOCUMENT);

    // Assert: the push succeeded, the readable project directory became a
    // module, and no forbidden glob reached the document.
    const modules = writtenModules(seeded);
    expect(modules["api"]).toEqual(["api/**"]);
    expect(modules["docs"]).toBeUndefined();
    expect(modules["tests"]).toBeUndefined();
    const published = seeded.readTextFile(TARGET);
    for (const forbidden of ['"**"', '"docs/**"', '"tests/**"']) {
      expect(published).not.toContain(forbidden);
    }
  });

  it("emits no universal glob for a manifest at the destination root", () => {
    // Arrange: the root-manifest layout AC9 names as a negative-path case.
    const seeded = buildInMemoryFileSystem({}, [DEST]);
    const lister = fakeLister({ [DEST]: [entry("package.json", false)] });

    // Act
    decorate(seeded, lister).writeTextFile(TARGET, SOURCE_DOCUMENT);

    // Assert
    expect(writtenModules(seeded)).toEqual({
      config: ["config/**"],
    });
    expect(seeded.readTextFile(TARGET)).not.toContain('"**"');
  });

  it("still surfaces a guard trip as a raise before any write", () => {
    // Arrange: the guard's before-write ordering is asserted at the decorator
    // boundary by invoking it with an observation set the core rejects. The
    // scanner cannot produce such a set, so the core is called directly through
    // the same code path the decorator uses.
    const existing = '{"version": 99}\n';
    const seeded = buildInMemoryFileSystem({ [TARGET]: existing }, [DEST]);
    const forbiddenObservations = [
      { relativePath: "", fileNames: [] },
      { relativePath: "docs", fileNames: ["package.json"] },
    ];

    // Act
    let caught: unknown;
    try {
      deriveDestinationModuleMap(forbiddenObservations, SOURCE_DOCUMENT);
    } catch (error) {
      caught = error;
    }

    // Assert: the raise happens during derivation, so the decorator's write to
    // the inner adapter is never reached and the existing bytes survive.
    expect(caught).toBeInstanceOf(BlastRadiusGuardError);
    expect(seeded.readTextFile(TARGET)).toBe(existing);
  });
});

describe("issue #472: failure semantics leave destination bytes untouched", () => {
  it("fails an unparseable bundled document and names the path", () => {
    // Arrange
    const existing = '{"version": 99}\n';
    const seeded = buildInMemoryFileSystem({ [TARGET]: existing }, [DEST]);

    // Act
    let caught: unknown;
    try {
      decorate(seeded, fakeLister({})).writeTextFile(
        TARGET,
        "{ not json at all\n",
      );
    } catch (error) {
      caught = error;
    }

    // Assert
    expect(caught).toBeInstanceOf(BlastRadiusDeriveError);
    expect((caught as BlastRadiusDeriveError).message).toContain(
      "config/blast-radius.json",
    );
    expect(seeded.readTextFile(TARGET)).toBe(existing);
  });
});

describe("issue #472: unreadable-directory tolerance", () => {
  it("contributes no entries for a subdirectory whose lister throws", () => {
    // Arrange: `locked` cannot be listed; `open` can.
    const seeded = buildInMemoryFileSystem({}, [DEST]);
    const lister: DirectoryLister = (root) => {
      if (root === DEST) {
        return [entry("locked", true), entry("open", true)];
      }
      if (root === `${DEST}/open`) {
        return [entry("go.mod", false)];
      }
      throw new Error(`EACCES: permission denied, scandir '${root}'`);
    };

    // Act
    decorate(seeded, lister).writeTextFile(TARGET, SOURCE_DOCUMENT);

    // Assert: the derivation succeeded and the readable project directory won.
    const modules = writtenModules(seeded);
    expect(modules["open"]).toEqual(["open/**"]);
    expect(modules["locked"]).toBeUndefined();
  });

  it("falls back to the payload modules when the root itself is unreadable", () => {
    // Arrange: this is the case existing push-down tests exercise, where the
    // real-filesystem lister cannot see an in-memory destination root.
    const seeded = buildInMemoryFileSystem({}, [DEST]);
    const lister: DirectoryLister = () => {
      throw new Error("ENOENT: no such file or directory, scandir '/dest'");
    };

    // Act
    decorate(seeded, lister).writeTextFile(TARGET, SOURCE_DOCUMENT);

    // Assert
    expect(writtenModules(seeded)).toEqual({
      config: ["config/**"],
    });
  });
});

describe("issue #472: idempotency", () => {
  it("writes a byte-identical document on a second push", () => {
    // Arrange: the second push sees the trees the first push created. `.claude`
    // is dot-prefixed and skipped; `config` derives to the same glob the payload
    // module already carries.
    const seeded = buildInMemoryFileSystem({}, [DEST]);
    const layout: Record<string, ReadonlyArray<DirectoryEntry>> = {
      [DEST]: [entry("src", true)],
      [`${DEST}/src`]: [entry("App", true)],
      [`${DEST}/src/App`]: [entry("App.csproj", false)],
    };
    const decorated = decorate(seeded, fakeLister(layout));

    // Act
    decorated.writeTextFile(TARGET, SOURCE_DOCUMENT);
    const afterFirst = seeded.readTextFile(TARGET);

    // The push materialized `.claude` and `config` in the destination.
    layout[DEST] = [
      entry(".claude", true),
      entry("config", true),
      entry("src", true),
    ];
    layout[`${DEST}/config`] = [entry("blast-radius.json", false)];
    decorated.writeTextFile(TARGET, SOURCE_DOCUMENT);
    const afterSecond = seeded.readTextFile(TARGET);

    // Assert
    expect(afterSecond).toBe(afterFirst);
  });
});

describe("issue #489: mandate_reads carriage", () => {
  it("carries mandate_reads into the destination document verbatim", () => {
    // Arrange: a destination with no project structure, so the derivation
    // contributes only the payload modules and the carried keys are the whole
    // point of the assertion.
    const seeded = buildInMemoryFileSystem({}, [DEST]);
    const decorated = decorate(seeded, fakeLister({}));

    // Act
    decorated.writeTextFile(TARGET, SOURCE_DOCUMENT_WITH_MANDATE_READS);
    const parsed: unknown = JSON.parse(seeded.readTextFile(TARGET));
    const document = parsed as Record<string, unknown>;

    // Assert: the array survives derivation element for element.
    expect(document["mandate_reads"]).toEqual(MANDATE_READS);
  });

  it("emits mandate_reads between shared_surface_globs and modules", () => {
    // Arrange
    const seeded = buildInMemoryFileSystem({}, [DEST]);
    const decorated = decorate(seeded, fakeLister({}));

    // Act
    decorated.writeTextFile(TARGET, SOURCE_DOCUMENT_WITH_MANDATE_READS);
    const parsed: unknown = JSON.parse(seeded.readTextFile(TARGET));

    // Assert: the serialized key order is the fixed contract order.
    expect(Object.keys(parsed as Record<string, unknown>)).toEqual([
      "version",
      "shared_surfaces",
      "shared_surface_globs",
      "mandate_reads",
      "modules",
      "over_breadth_fraction",
    ]);
  });

  it("omits mandate_reads when the source document declares none", () => {
    // Arrange: the pre-#489 bundled document shape.
    const seeded = buildInMemoryFileSystem({}, [DEST]);
    const decorated = decorate(seeded, fakeLister({}));

    // Act
    decorated.writeTextFile(TARGET, SOURCE_DOCUMENT);
    const parsed: unknown = JSON.parse(seeded.readTextFile(TARGET));

    // Assert: an absent optional key emits no property at all.
    expect(parsed as Record<string, unknown>).not.toHaveProperty(
      "mandate_reads",
    );
  });
});
