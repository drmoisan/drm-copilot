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
 * Carriage of the optional `mergeable_paths` key (issue #643).
 *
 * Purpose:
 *     Pin the presence case of the second optional carried key: verbatim
 *     carriage, its position between `mandate_reads` and `modules`, and omission
 *     when the source declares none. The absence case is in the core suite.
 *
 * Scope note:
 *     Every case is hermetic. The destination is an
 *     {@link InMemoryPushDownFileSystem} and the layout is an injected fake
 *     lister, so no temporary file is created and no real directory is read.
 */

const DEST = "/dest";
const TARGET = `${DEST}/config/blast-radius.json`;

/** The read-by-mandate exclusion set carried alongside the new key. */
const MANDATE_READS: ReadonlyArray<string> = [".claude/rules/**", "tiers.yml"];

/** The five-entry mechanically-mergeable path class. */
const MERGEABLE_PATHS: ReadonlyArray<string> = [
  "**/*.csproj",
  "**/packages.config",
  "**/app.config",
  "**/*.vbproj",
  "**/*.props",
];

/** Bundled source document declaring neither optional key. */
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

/** Bundled source document declaring both optional keys. */
const SOURCE_DOCUMENT_WITH_MERGEABLE_PATHS = `${JSON.stringify(
  {
    version: 1,
    shared_surfaces: [".claude/settings.json", "config/blast-radius.json"],
    shared_surface_globs: [],
    mandate_reads: MANDATE_READS,
    mergeable_paths: MERGEABLE_PATHS,
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
 * @param layout Map of absolute directory path to its shallow entries.
 * @returns A lister returning the mapped entries, empty when unmapped.
 */
function fakeLister(
  layout: Readonly<Record<string, ReadonlyArray<DirectoryEntry>>>,
): DirectoryLister {
  return (root) => layout[root] ?? [];
}

/**
 * Wrap an in-memory adapter in the derive decorator.
 * @param seeded The in-memory adapter to wrap.
 * @param lister Directory lister describing the destination layout.
 * @returns The decorated adapter.
 */
function decorate(
  seeded: InMemoryPushDownFileSystem,
  lister: DirectoryLister,
): BlastRadiusDeriveFileSystem {
  return new BlastRadiusDeriveFileSystem(seeded, DEST, lister);
}

describe("issue #643: mergeable_paths carriage", () => {
  it("carries mergeable_paths into the destination document verbatim", () => {
    // Arrange: a destination with no project structure, so the carried keys are
    // the whole point of the assertion.
    const seeded = buildInMemoryFileSystem({}, [DEST]);
    const decorated = decorate(seeded, fakeLister({}));

    // Act
    decorated.writeTextFile(TARGET, SOURCE_DOCUMENT_WITH_MERGEABLE_PATHS);
    const parsed: unknown = JSON.parse(seeded.readTextFile(TARGET));
    const document = parsed as Record<string, unknown>;

    // Assert: the array survives derivation element for element.
    expect(document["mergeable_paths"]).toEqual(MERGEABLE_PATHS);
  });

  it("emits mergeable_paths between mandate_reads and modules", () => {
    // Arrange
    const seeded = buildInMemoryFileSystem({}, [DEST]);
    const decorated = decorate(seeded, fakeLister({}));

    // Act
    decorated.writeTextFile(TARGET, SOURCE_DOCUMENT_WITH_MERGEABLE_PATHS);
    const parsed: unknown = JSON.parse(seeded.readTextFile(TARGET));

    // Assert: the serialized key order is the fixed contract order.
    expect(Object.keys(parsed as Record<string, unknown>)).toEqual([
      "version",
      "shared_surfaces",
      "shared_surface_globs",
      "mandate_reads",
      "mergeable_paths",
      "modules",
      "over_breadth_fraction",
    ]);
  });

  it("omits mergeable_paths when the source document declares none", () => {
    // Arrange: the pre-#643 bundled document shape.
    const seeded = buildInMemoryFileSystem({}, [DEST]);
    const decorated = decorate(seeded, fakeLister({}));

    // Act
    decorated.writeTextFile(TARGET, SOURCE_DOCUMENT);
    const parsed: unknown = JSON.parse(seeded.readTextFile(TARGET));

    // Assert: an absent optional key emits no property at all.
    expect(parsed as Record<string, unknown>).not.toHaveProperty(
      "mergeable_paths",
    );
  });
});
