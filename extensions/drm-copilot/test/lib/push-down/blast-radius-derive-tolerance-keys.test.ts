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
 *     Pin that the push-down derivation carries the `conflict_tolerance`,
 *     `write_intent_extraction`, and `path_roots` keys of the bundled source
 *     document into the destination document verbatim, and omits each entirely
 *     when the source document does not declare it. The keys describe the
 *     scheduling and extraction runtime rather than a repository layout, so the
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

/** A self-hosted-style `path_roots` value, so carriage is observable. */
const PATH_ROOTS: ReadonlyArray<string> = [".claude", "config", "scripts"];

/**
 * Serialize a bundled source document, declaring only the given policy keys.
 *
 * @param policyKeys The optional scheduling-policy keys to declare, in
 *   emission order. A key absent from this object is left out of the source
 *   document entirely.
 * @returns The serialized source document with a trailing newline.
 */
function sourceDocument(policyKeys: Record<string, unknown>): string {
  const document: Record<string, unknown> = {
    version: 1,
    shared_surfaces: [".claude/settings.json", "config/blast-radius.json"],
    shared_surface_globs: [],
    mergeable_paths: ["**/*.csproj"],
    ...policyKeys,
  };
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
    const source = sourceDocument({ conflict_tolerance: CONFLICT_TOLERANCE });

    // Act
    const document = deriveDocument(source);

    // Assert: the nested object survives derivation member for member.
    expect(document["conflict_tolerance"]).toEqual(CONFLICT_TOLERANCE);
  });

  it("omits conflict_tolerance when the source document declares none", () => {
    // Arrange: the pre-#722 bundled document shape.
    const source = sourceDocument({});

    // Act
    const document = deriveDocument(source);

    // Assert: an absent optional key emits no property at all.
    expect(document).not.toHaveProperty("conflict_tolerance");
  });
});

describe("issue #722: write_intent_extraction carriage", () => {
  it("carries write_intent_extraction into the destination document verbatim", () => {
    // Arrange: the flag is declared false so a defaulting implementation that
    // emitted true would be observable.
    const source = sourceDocument({ write_intent_extraction: false });

    // Act
    const document = deriveDocument(source);

    // Assert: the boolean survives derivation unchanged.
    expect(document["write_intent_extraction"]).toBe(false);
  });

  it("omits write_intent_extraction when the source document declares none", () => {
    // Arrange: a source document without the flag.
    const source = sourceDocument({ conflict_tolerance: CONFLICT_TOLERANCE });

    // Act
    const document = deriveDocument(source);

    // Assert: an absent optional key emits no property at all.
    expect(document).not.toHaveProperty("write_intent_extraction");
  });
});

describe("issue #722: path_roots carriage", () => {
  it("carries path_roots into the destination document verbatim", () => {
    // Arrange: a non-empty list, so element-for-element carriage is observable.
    const source = sourceDocument({ path_roots: PATH_ROOTS });

    // Act
    const document = deriveDocument(source);

    // Assert: the array survives derivation element for element.
    expect(document["path_roots"]).toEqual(PATH_ROOTS);
  });

  it("omits path_roots when the source document declares none", () => {
    // Arrange: a source document without the key.
    const source = sourceDocument({ write_intent_extraction: true });

    // Act
    const document = deriveDocument(source);

    // Assert: an absent optional key emits no property at all.
    expect(document).not.toHaveProperty("path_roots");
  });
});
