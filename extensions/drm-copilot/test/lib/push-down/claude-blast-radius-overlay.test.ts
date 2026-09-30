import { describe, expect, it } from "@jest/globals";

import {
  BlastRadiusGuardError,
  FORBIDDEN_GLOBS,
} from "../../../src/lib/push-down/claude-blast-radius-derive-core";
import {
  BLAST_RADIUS_OVERLAY_RELATIVE_PATH,
  BlastRadiusOverlayError,
  BlastRadiusOverlayFileSystem,
  composeBlastRadiusOverlay,
} from "../../../src/lib/push-down/claude-blast-radius-overlay";
import { buildInMemoryFileSystem } from "./push-down.test-helpers";
import {
  layoutLister,
  OVERLAY_TEXT,
  publish,
  seedTree,
  SOURCE_BLAST_RADIUS,
  SRC,
} from "./config-carriage.test-helpers";

/**
 * Destination blast-radius overlay (issue #508).
 *
 * Purpose:
 *     Cover the composition of the destination-owned overlay
 *     `config/blast-radius.local.json` onto the regenerated
 *     `config/blast-radius.json`, and the carriage rules that keep the overlay
 *     destination-owned: it is never published from the source and never
 *     written by a push.
 *
 * Scope note:
 *     Every case uses the hermetic in-memory adapter; no temporary files.
 */

type JsonRecord = Record<string, unknown>;

const OVERLAY_REL = BLAST_RADIUS_OVERLAY_RELATIVE_PATH;
const ROOT = "/dest";
const TARGET = `${ROOT}/config/blast-radius.json`;
const OVERLAY = `${ROOT}/config/blast-radius.local.json`;
const PRIOR = "prior bytes\n";
const STRING_LIST_KEYS = [
  "shared_surfaces",
  "shared_surface_globs",
  "mandate_reads",
  "mergeable_paths",
  "path_roots",
] as const;

/** Serialize a document the way the push-down writes it. */
function doc(value: JsonRecord): string {
  return `${JSON.stringify(value, null, 2)}\n`;
}

/** Compose two documents and parse the result. */
function compose(base: JsonRecord, overlay: JsonRecord): JsonRecord {
  const text = composeBlastRadiusOverlay(doc(base), doc(overlay), OVERLAY_REL);
  return JSON.parse(text) as JsonRecord;
}

/** Build a decorator over an in-memory destination seeded with files. */
function decorate(seed: Record<string, string>): {
  inner: ReturnType<typeof buildInMemoryFileSystem>;
  fs: BlastRadiusOverlayFileSystem;
} {
  const inner = buildInMemoryFileSystem(seed, [ROOT]);
  return { inner, fs: new BlastRadiusOverlayFileSystem(inner, ROOT) };
}

/** Run a decorated target write that must fail and keep the prior bytes. */
function expectRejectedWrite(overlayText: string, error: unknown): string {
  const { inner, fs } = decorate({ [TARGET]: PRIOR, [OVERLAY]: overlayText });
  let caught: unknown;
  try {
    fs.writeTextFile(TARGET, doc({ version: 1, modules: {} }));
  } catch (thrown) {
    caught = thrown;
  }
  expect(caught).toBeInstanceOf(error);
  expect(inner.readTextFile(TARGET)).toBe(PRIOR);
  expect(inner.writtenPaths).not.toContain(TARGET);
  return caught instanceof Error ? caught.message : "";
}

describe("issue #508 AC01 overlay absent", () => {
  it("returns the base text unchanged when the overlay is null", () => {
    expect(
      composeBlastRadiusOverlay(SOURCE_BLAST_RADIUS, null, OVERLAY_REL),
    ).toBe(SOURCE_BLAST_RADIUS);
  });

  it("writes the base bytes unchanged when the destination has no overlay", () => {
    // Arrange: non-canonical bytes prove no parse or re-serialization happens.
    const { inner, fs } = decorate({});
    const base = '{ "version": 1,   "modules": {} }\n';

    // Act
    fs.writeTextFile(TARGET, base);

    // Assert
    expect(inner.readTextFile(TARGET)).toBe(base);
  });
});

describe("issue #508 AC02 additive keys", () => {
  it.each(STRING_LIST_KEYS)(
    "unions %s with base order first and duplicates removed",
    (key) => {
      const composed = compose(
        { version: 1, [key]: ["a", "b"] },
        { [key]: ["c", "a", "c", "d"] },
      );
      expect(composed[key]).toEqual(["a", "b", "c", "d"]);
    },
  );

  it.each(STRING_LIST_KEYS)(
    "appends a deduplicated %s the base lacks",
    (key) => {
      const composed = compose({ version: 1 }, { [key]: ["x", "y", "x"] });
      expect(composed[key]).toEqual(["x", "y"]);
      expect(Object.keys(composed)).toEqual(["version", key]);
    },
  );
});

describe("issue #508 AC03 modules", () => {
  const base = { version: 1, modules: { b: ["b/**"], c: ["c/**"] } };

  it("adds an overlay module the base lacks", () => {
    const composed = compose(base, { modules: { a: ["a/**"] } });
    expect(composed["modules"]).toEqual({
      a: ["a/**"],
      b: ["b/**"],
      c: ["c/**"],
    });
  });

  it.each([
    ["different globs", ["c/src/**", "c/lib/**"]],
    ["the same globs", ["c/**"]],
  ])("replaces a same-name module with %s", (_label, globs) => {
    const composed = compose(base, { modules: { c: globs } });
    expect((composed["modules"] as JsonRecord)["c"]).toEqual(globs);
  });

  it("emits module names in ordinal order", () => {
    const composed = compose(
      { version: 1, modules: { alpha: ["alpha/**"] } },
      { modules: { Zeta: ["z/**"], Beta: ["b/**"] } },
    );
    expect(Object.keys(composed["modules"] as JsonRecord)).toEqual([
      "Beta",
      "Zeta",
      "alpha",
    ]);
  });
});

describe("issue #508 AC04 nested and scalar keys", () => {
  it("merges conflict_tolerance recursively", () => {
    const composed = compose(
      {
        version: 1,
        conflict_tolerance: {
          tolerance_percent: 100,
          weights: { same_file: 8, module: 2 },
          band_durations: { C1: 1 },
          default_band: "C1",
          append_only_paths: ["a.md"],
        },
      },
      {
        conflict_tolerance: {
          weights: { module: 3, extra: 1 },
          band_durations: { C2: 2 },
          default_band: "C2",
          append_only_paths: ["b.md", "a.md"],
        },
      },
    );
    expect(composed["conflict_tolerance"]).toEqual({
      tolerance_percent: 100,
      weights: { same_file: 8, module: 3, extra: 1 },
      band_durations: { C1: 1, C2: 2 },
      default_band: "C2",
      append_only_paths: ["a.md", "b.md"],
    });
  });

  it("lets the overlay win for over_breadth_fraction and write_intent_extraction", () => {
    const composed = compose(
      {
        version: 1,
        over_breadth_fraction: 0.25,
        write_intent_extraction: true,
      },
      { over_breadth_fraction: 0.5, write_intent_extraction: false },
    );
    expect(composed["over_breadth_fraction"]).toBe(0.5);
    expect(composed["write_intent_extraction"]).toBe(false);
  });

  it("appends an overlay-only key after every base key", () => {
    const composed = compose(
      { version: 1, modules: {} },
      { custom_key: { k: "v" } },
    );
    expect(Object.keys(composed)).toEqual(["version", "modules", "custom_key"]);
    expect(composed["custom_key"]).toEqual({ k: "v" });
  });
});

describe("issue #508 AC05 forbidden-glob guard", () => {
  it.each(FORBIDDEN_GLOBS)(
    "rejects an overlay module carrying %s and keeps the prior bytes",
    (glob) => {
      const overlayText = doc({ modules: { bad: [glob] } });
      expect(() =>
        composeBlastRadiusOverlay(
          doc({ version: 1 }),
          overlayText,
          OVERLAY_REL,
        ),
      ).toThrow(BlastRadiusGuardError);
      expectRejectedWrite(overlayText, BlastRadiusGuardError);
    },
  );
});

describe("issue #508 AC06 version", () => {
  it("rejects a mismatched version and keeps the prior bytes", () => {
    const message = expectRejectedWrite(
      doc({ version: 2 }),
      BlastRadiusOverlayError,
    );
    expect(message).toContain('"version"');
  });

  it.each([
    ["equal", { version: 1 }],
    ["absent", {}],
  ])(
    "composes an %s overlay version to the base version",
    (_label, overlay) => {
      expect(compose({ version: 1, modules: {} }, overlay)["version"]).toBe(1);
    },
  );
});

describe("issue #508 AC07 malformed overlay", () => {
  it.each([
    ["unparseable text", "{ not json\n", null],
    ["an array root", "[]\n", null],
    ["a scalar root", "7\n", null],
    [
      "a non-list string-list value",
      '{"shared_surfaces": "x"}\n',
      "shared_surfaces",
    ],
    ["a non-string list member", '{"mandate_reads": [1]}\n', "mandate_reads"],
    ["a non-object modules value", '{"modules": ["a/**"]}\n', "modules"],
    ["a non-list module value", '{"modules": {"a": "a/**"}}\n', "modules"],
    [
      "a non-string nested list member",
      '{"conflict_tolerance": {"append_only_paths": [2]}}\n',
      "conflict_tolerance.append_only_paths",
    ],
  ])("rejects %s and keeps the prior bytes", (_label, text, key) => {
    const { inner, fs } = decorate({ [TARGET]: PRIOR, [OVERLAY]: text });
    const base = doc({
      version: 1,
      conflict_tolerance: { append_only_paths: ["a.md"] },
    });
    let caught: unknown;
    try {
      fs.writeTextFile(TARGET, base);
    } catch (thrown) {
      caught = thrown;
    }
    expect(caught).toBeInstanceOf(BlastRadiusOverlayError);
    const message = caught instanceof Error ? caught.message : "";
    expect(message).toContain("config/blast-radius.local.json");
    if (key !== null) {
      expect(message).toContain(`"${key}"`);
    }
    expect(inner.readTextFile(TARGET)).toBe(PRIOR);
    expect(inner.writtenPaths).not.toContain(TARGET);
  });

  it("rejects an unparseable base document naming the main file", () => {
    let caught: unknown;
    try {
      composeBlastRadiusOverlay("{ bad", "{}\n", OVERLAY_REL);
    } catch (thrown) {
      caught = thrown;
    }
    expect(caught).toBeInstanceOf(BlastRadiusOverlayError);
    expect((caught as BlastRadiusOverlayError).path).toBe(
      "config/blast-radius.json",
    );
  });
});

const PROPERTY_BASES: ReadonlyArray<string> = [
  SOURCE_BLAST_RADIUS,
  doc({ version: 1, shared_surfaces: [], mandate_reads: [], modules: {} }),
  doc({
    version: 1,
    shared_surfaces: ["x.json"],
    modules: { a: ["a/**"], b: ["b/**"] },
  }),
];

const PROPERTY_OVERLAYS: ReadonlyArray<JsonRecord> = [
  {},
  { shared_surfaces: ["s1.json"], mandate_reads: ["m1/**"] },
  { modules: { added: ["added/**"] } },
  { modules: { a: ["a2/**"] } },
  {
    conflict_tolerance: { append_only_paths: ["x.md"], weights: { module: 5 } },
  },
  { over_breadth_fraction: 0.5 },
  { custom_key: { k: "v" } },
  { version: 1 },
];

const PROPERTY_PAIRS: ReadonlyArray<[string, JsonRecord]> =
  PROPERTY_BASES.flatMap((base) =>
    PROPERTY_OVERLAYS.map((overlay): [string, JsonRecord] => [base, overlay]),
  );

/** Compose one property pair and return the text. */
function composePair(base: string, overlay: JsonRecord): string {
  return composeBlastRadiusOverlay(base, doc(overlay), OVERLAY_REL);
}

describe("issue #508 AC18 properties", () => {
  it("enumerates all 24 base and overlay pairs", () => {
    expect(PROPERTY_PAIRS).toHaveLength(24);
  });

  it("identity: an empty overlay yields the base text", () => {
    for (const base of PROPERTY_BASES) {
      expect(composePair(base, {})).toBe(base);
    }
  });

  it("idempotence: composing twice equals composing once", () => {
    for (const [base, overlay] of PROPERTY_PAIRS) {
      const once = composePair(base, overlay);
      expect(composePair(once, overlay)).toBe(once);
    }
  });

  it("superset: every base list entry survives", () => {
    for (const [base, overlay] of PROPERTY_PAIRS) {
      const before = JSON.parse(base) as JsonRecord;
      const after = JSON.parse(composePair(base, overlay)) as JsonRecord;
      for (const key of STRING_LIST_KEYS) {
        const entries = (before[key] ?? []) as unknown[];
        expect(after[key] ?? []).toEqual(expect.arrayContaining(entries));
      }
    }
  });

  it("overlay inclusion: every overlay list entry and module appears", () => {
    for (const [base, overlay] of PROPERTY_PAIRS) {
      const after = JSON.parse(composePair(base, overlay)) as JsonRecord;
      for (const key of STRING_LIST_KEYS) {
        const entries = (overlay[key] ?? []) as unknown[];
        expect(after[key] ?? []).toEqual(expect.arrayContaining(entries));
      }
      const modules = (overlay["modules"] ?? {}) as JsonRecord;
      for (const [name, globs] of Object.entries(modules)) {
        expect((after["modules"] as JsonRecord)[name]).toEqual(globs);
      }
    }
  });

  it("determinism: two calls return equal text", () => {
    for (const [base, overlay] of PROPERTY_PAIRS) {
      expect(composePair(base, overlay)).toBe(composePair(base, overlay));
    }
  });

  it("version preservation: the base version is emitted", () => {
    for (const [base, overlay] of PROPERTY_PAIRS) {
      const before = JSON.parse(base) as JsonRecord;
      const after = JSON.parse(composePair(base, overlay)) as JsonRecord;
      expect(after["version"]).toBe(before["version"]);
    }
  });
});

describe("issue #508 AC11 overlay never shipped", () => {
  it("does not publish a source-side overlay file", () => {
    // Arrange: a source workspace that carries its own overlay file.
    const seeded = seedTree({
      [`${SRC}/config/blast-radius.local.json`]: OVERLAY_TEXT,
    });

    // Act
    publish(seeded, null, layoutLister({}));

    // Assert
    expect(seeded.isFile("/dest/config/blast-radius.local.json")).toBe(false);
  });
});

describe("issue #508 AC12 overlay never written", () => {
  it.each([
    ["a sibling path", `${ROOT}/config/other.json`],
    ["a path outside the destination", "/elsewhere/config/blast-radius.json"],
  ])("delegates a write to %s unchanged", (_label, path) => {
    const { inner, fs } = decorate({ [OVERLAY]: OVERLAY_TEXT });

    fs.writeTextFile(path, "untouched\n");

    expect(inner.readTextFile(path)).toBe("untouched\n");
  });

  it("composes the target write and never writes the overlay", () => {
    const { inner, fs } = decorate({ [OVERLAY]: OVERLAY_TEXT });

    fs.writeTextFile(TARGET, SOURCE_BLAST_RADIUS);

    expect(inner.readTextFile(TARGET)).toContain('"Directory.Build.props"');
    expect(inner.readTextFile(TARGET)).toContain('"destination-app"');
    expect(inner.writtenPaths).toEqual([TARGET]);
    expect(inner.writtenPaths).not.toContain(OVERLAY);
    expect(inner.readTextFile(OVERLAY)).toBe(OVERLAY_TEXT);
  });

  it("delegates reads, listings, and directory calls to the inner adapter", () => {
    const { inner, fs } = decorate({ [OVERLAY]: OVERLAY_TEXT });

    fs.ensureDir(`${ROOT}/made`);

    expect(fs.isFile(OVERLAY)).toBe(true);
    expect(fs.isDir(`${ROOT}/config`)).toBe(true);
    expect(fs.readTextFile(OVERLAY)).toBe(OVERLAY_TEXT);
    expect(fs.listFiles(ROOT)).toEqual([OVERLAY]);
    expect(inner.ensuredDirs).toEqual([`${ROOT}/made`]);
  });
});
