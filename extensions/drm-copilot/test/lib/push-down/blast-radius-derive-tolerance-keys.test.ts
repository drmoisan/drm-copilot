import { describe, expect, it } from "@jest/globals";

import {
  BlastRadiusDeriveFileSystem,
  type DirectoryEntry,
  type DirectoryLister,
} from "../../../src/lib/push-down/claude-blast-radius-derive";
import {
  buildInMemoryFileSystem,
  type InMemoryPushDownFileSystem,
} from "./push-down.test-helpers";

/**
 * Carriage of the optional scheduling-policy keys (issue #722).
 *
 * Purpose:
 *     Pin that the push-down derivation carries the `conflict_tolerance` key of
 *     the bundled source document into the destination document verbatim, and
 *     omits it entirely when the source document does not declare it. The key
 *     describes the scheduling runtime rather than a repository layout, so the
 *     destination receives the source value unchanged.
 *
 * Scope note:
 *     Every case is hermetic. The destination is an
 *     {@link InMemoryPushDownFileSystem} and the layout is an injected fake
 *     lister, so no temporary file is created and no real directory is read.
 */

const DEST = "/dest";
const TARGET = `${DEST}/config/blast-radius.json`;

/** The committed integration-cost scheduling policy (block B2 of the plan). */
const CONFLICT_TOLERANCE = {
  tolerance_percent: 100,
  weights: { same_file: 8, possible_overlap: 2, append_only: 1, module: 2 },
  band_durations: { C1: 1, C2: 2, C3: 4, C4: 8 },
  default_band: "C1",
  append_only_paths: [
    "**/CHANGELOG.md",
    "extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json",
  ],
};

/**
 * Serialize a bundled source document, optionally declaring the policy key.
 *
 * @param conflictTolerance The `conflict_tolerance` value to declare, or
 *   `undefined` to leave the key out of the source document.
 * @returns The serialized source document with a trailing newline.
 */
function sourceDocument(conflictTolerance: unknown): string {
  const document: Record<string, unknown> = {
    version: 1,
    shared_surfaces: [".claude/settings.json", "config/blast-radius.json"],
    shared_surface_globs: [],
    mergeable_paths: ["**/*.csproj"],
  };
  if (conflictTolerance !== undefined) {
    document["conflict_tolerance"] = conflictTolerance;
  }
  document["modules"] = { config: ["config/**"] };
  document["over_breadth_fraction"] = 0.25;
  return `${JSON.stringify(document, null, 2)}\n`;
}

/**
 * Build a fake lister over an in-memory directory map.
 * @param layout Map of absolute directory path to its shallow entries.
 * @returns A lister returning the mapped entries, empty when unmapped.
 */
function fakeLister(
  layout: Readonly<Record<string, ReadonlyArray<DirectoryEntry>>>,
): DirectoryLister {
  return (root) => layout[root] ?? [];
}

/**
 * Derive the destination document from a source document.
 * @param source The serialized bundled source document.
 * @returns The parsed destination document.
 */
function deriveDocument(source: string): Record<string, unknown> {
  const seeded: InMemoryPushDownFileSystem = buildInMemoryFileSystem({}, [
    DEST,
  ]);
  const decorated = new BlastRadiusDeriveFileSystem(
    seeded,
    DEST,
    fakeLister({}),
  );
  decorated.writeTextFile(TARGET, source);
  const parsed: unknown = JSON.parse(seeded.readTextFile(TARGET));
  return parsed as Record<string, unknown>;
}

describe("issue #722: conflict_tolerance carriage", () => {
  it("carries conflict_tolerance into the destination document verbatim", () => {
    // Arrange: a destination with no project structure, so the carried key is
    // the whole point of the assertion.
    const source = sourceDocument(CONFLICT_TOLERANCE);

    // Act
    const document = deriveDocument(source);

    // Assert: the nested object survives derivation member for member.
    expect(document["conflict_tolerance"]).toEqual(CONFLICT_TOLERANCE);
  });

  it("omits conflict_tolerance when the source document declares none", () => {
    // Arrange: the pre-#722 bundled document shape.
    const source = sourceDocument(undefined);

    // Act
    const document = deriveDocument(source);

    // Assert: an absent optional key emits no property at all.
    expect(document).not.toHaveProperty("conflict_tolerance");
  });
});
