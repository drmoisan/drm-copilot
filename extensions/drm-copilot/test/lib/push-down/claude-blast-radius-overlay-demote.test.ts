import { describe, expect, it } from "@jest/globals";

import {
  BlastRadiusOverlayError,
  BlastRadiusOverlayFileSystem,
  composeBlastRadiusOverlay,
} from "../../../src/lib/push-down/claude-blast-radius-overlay";
import {
  SHARED_SURFACES_DEMOTE_KEY,
  applySharedSurfaceDemotion,
} from "../../../src/lib/push-down/claude-blast-radius-overlay-demote";
import { BlastRadiusGuardError } from "../../../src/lib/push-down/claude-blast-radius-derive-core";
import {
  DEST,
  SRC_APP_LAYOUT,
  layoutLister,
  publish,
  seedTree,
} from "./config-carriage.test-helpers";
import { buildInMemoryFileSystem } from "./push-down.test-helpers";

/**
 * Shared-surface demotion through the TypeScript blast-radius overlay
 * (issue #1006).
 *
 * Purpose:
 *     Mirror `test_push_down_claude_blast_radius_overlay_demote.py`. The
 *     overlay directive `shared_surfaces_demote` moves named entries from
 *     `shared_surfaces` to `conflict_tolerance.append_only_paths` after every
 *     other key is composed, is consumed rather than emitted, and fails closed
 *     before any write with the same detail text as the Python composer.
 *
 * Side effects:
 *     None; every filesystem is in memory.
 */

type JsonObject = Record<string, unknown>;

const OVERLAY_REL = "config/blast-radius.local.json";
const TARGET = `${DEST}/config/blast-radius.json`;
const OVERLAY = `${DEST}/${OVERLAY_REL}`;
const PRIOR = "prior bytes\n";
const TIER_MAP = "quality-tiers.yml";
const MESSAGE_PREFIX =
  `Blast-radius overlay ${OVERLAY_REL} was not applied; ` +
  "config/blast-radius.json was not written: ";

/** Serialize a document the way the push-down writes it. */
function doc(value: JsonObject): string {
  return `${JSON.stringify(value, null, 2)}\n`;
}

/** A base with the tier map shared between two other surfaces. */
const BASE: JsonObject = {
  version: 1,
  shared_surfaces: ["a.json", TIER_MAP, "b.json"],
  conflict_tolerance: {
    tolerance_percent: 100,
    append_only_paths: ["**/CHANGELOG.md"],
  },
  modules: { config: ["config/**"] },
};
const DEMOTE_TIER_MAP: JsonObject = {
  [SHARED_SURFACES_DEMOTE_KEY]: [TIER_MAP],
};

/** Compose two documents and parse the result. */
function compose(base: JsonObject, overlay: JsonObject): JsonObject {
  return JSON.parse(
    composeBlastRadiusOverlay(doc(base), doc(overlay), OVERLAY_REL),
  ) as JsonObject;
}

/** Return the `conflict_tolerance` block of a parsed document. */
function tolerance(document: JsonObject): JsonObject {
  return document["conflict_tolerance"] as JsonObject;
}

/** Compose an overlay that must fail and return the error message. */
function rejection(overlay: JsonObject, base: JsonObject = BASE): string {
  let caught: unknown = null;
  try {
    composeBlastRadiusOverlay(doc(base), doc(overlay), OVERLAY_REL);
  } catch (thrown) {
    caught = thrown;
  }
  expect(caught).toBeInstanceOf(BlastRadiusOverlayError);
  return (caught as Error).message;
}

describe("issue #1006 shared-surface demotion semantics", () => {
  it("moves the entry and keeps the remaining order", () => {
    const composed = compose(BASE, DEMOTE_TIER_MAP);

    expect(composed["shared_surfaces"]).toEqual(["a.json", "b.json"]);
    expect(tolerance(composed)["append_only_paths"]).toEqual([
      "**/CHANGELOG.md",
      TIER_MAP,
    ]);
  });

  it("consumes the directive key", () => {
    const composed = compose(BASE, DEMOTE_TIER_MAP);

    expect(Object.keys(composed)).toEqual(Object.keys(BASE));
  });

  it("runs after every other key", () => {
    const composed = compose(BASE, {
      shared_surfaces: ["c.json"],
      conflict_tolerance: { append_only_paths: ["docs/log.md"] },
      [SHARED_SURFACES_DEMOTE_KEY]: ["c.json", TIER_MAP],
    });

    expect(composed["shared_surfaces"]).toEqual(["a.json", "b.json"]);
    expect(tolerance(composed)["append_only_paths"]).toEqual([
      "**/CHANGELOG.md",
      "docs/log.md",
      "c.json",
      TIER_MAP,
    ]);
  });

  it("treats an already append-only entry as a no-op", () => {
    const base = compose(BASE, DEMOTE_TIER_MAP);

    expect(
      composeBlastRadiusOverlay(doc(base), doc(DEMOTE_TIER_MAP), OVERLAY_REL),
    ).toBe(doc(base));
  });

  it("yields identical output when a composed result is composed again", () => {
    const once = composeBlastRadiusOverlay(
      doc(BASE),
      doc(DEMOTE_TIER_MAP),
      OVERLAY_REL,
    );

    expect(
      composeBlastRadiusOverlay(once, doc(DEMOTE_TIER_MAP), OVERLAY_REL),
    ).toBe(once);
  });

  it("leaves a document without shared_surfaces without that key", () => {
    const result = applySharedSurfaceDemotion(
      { conflict_tolerance: { append_only_paths: [TIER_MAP] } },
      [TIER_MAP],
    );

    expect(result).toEqual({
      ok: true,
      document: { conflict_tolerance: { append_only_paths: [TIER_MAP] } },
    });
  });

  it("does not mutate the composed input", () => {
    const composed: JsonObject = JSON.parse(doc(BASE)) as JsonObject;
    const before = doc(composed);

    applySharedSurfaceDemotion(composed, [TIER_MAP]);

    expect(doc(composed)).toBe(before);
  });
});

describe("issue #1006 shared-surface demotion fails closed", () => {
  it.each([
    ["a non-list value", TIER_MAP],
    ["a non-string member", [TIER_MAP, 3]],
  ])("rejects %s", (_label, value) => {
    expect(rejection({ [SHARED_SURFACES_DEMOTE_KEY]: value })).toBe(
      `${MESSAGE_PREFIX}key "shared_surfaces_demote" must be a list of strings`,
    );
  });

  it.each([
    ["no conflict_tolerance", {}],
    [
      "no append_only_paths",
      { conflict_tolerance: { tolerance_percent: 100 } },
    ],
  ])("rejects a composed document with %s", (_label, extra) => {
    const base: JsonObject = {
      version: 1,
      shared_surfaces: [TIER_MAP],
      ...extra,
    };

    expect(rejection(DEMOTE_TIER_MAP, base)).toBe(
      `${MESSAGE_PREFIX}key "shared_surfaces_demote" requires ` +
        "conflict_tolerance.append_only_paths in the composed document",
    );
  });

  it("rejects an unknown entry", () => {
    expect(
      rejection({ [SHARED_SURFACES_DEMOTE_KEY]: ["no-such-surface.json"] }),
    ).toBe(
      `${MESSAGE_PREFIX}key "shared_surfaces_demote" names ` +
        '"no-such-surface.json", which is neither a shared surface nor an ' +
        "append-only path",
    );
  });

  it("keeps the prior destination bytes on rejection", () => {
    const inner = buildInMemoryFileSystem(
      {
        [TARGET]: PRIOR,
        [OVERLAY]: doc({ [SHARED_SURFACES_DEMOTE_KEY]: ["missing.json"] }),
      },
      [DEST],
    );
    const fs = new BlastRadiusOverlayFileSystem(inner, DEST);

    expect(() => {
      fs.writeTextFile(TARGET, doc(BASE));
    }).toThrow(BlastRadiusOverlayError);
    expect(inner.readTextFile(TARGET)).toBe(PRIOR);
    expect(inner.writtenPaths).not.toContain(TARGET);
  });

  it("still applies the forbidden-glob guard with the directive present", () => {
    expect(() =>
      composeBlastRadiusOverlay(
        doc(BASE),
        doc({ modules: { everything: ["**"] }, ...DEMOTE_TIER_MAP }),
        OVERLAY_REL,
      ),
    ).toThrow(BlastRadiusGuardError);
  });
});

describe("issue #1006 AC-04 destination push-down", () => {
  it("demotes quality-tiers.yml with tolerance 5000 on push (issue #1006 AC-04)", () => {
    // Arrange: the seeded source carries SOURCE_BLAST_RADIUS, which is pinned
    // equal to the committed bundled truth table.
    const seeded = seedTree({
      [OVERLAY]: doc({
        [SHARED_SURFACES_DEMOTE_KEY]: [TIER_MAP],
        conflict_tolerance: { tolerance_percent: 5000 },
      }),
    });

    // Act
    publish(seeded, null, layoutLister(SRC_APP_LAYOUT));
    const composed = JSON.parse(seeded.readTextFile(TARGET)) as JsonObject;

    // Assert
    expect(tolerance(composed)["append_only_paths"]).toContain(TIER_MAP);
    expect(composed["shared_surfaces"]).not.toContain(TIER_MAP);
    expect(tolerance(composed)["tolerance_percent"]).toBe(5000);
    expect(composed).not.toHaveProperty(SHARED_SURFACES_DEMOTE_KEY);
  });
});
