import { describe, expect, it } from "@jest/globals";

import {
  assertSingleCsharpToolchain,
  computePublishedPaths,
  loadPackManifests,
  ManifestError,
  resolveVariantSourcePath,
  type PackManifest,
} from "../../../src/lib/push-down/claude-pack-selection";
import { buildInMemoryFileSystem } from "./push-down.test-helpers";

const MANIFEST_DIR = "/bundle/pack-manifests";

/**
 * Build a manifest JSON string for seeding the in-memory filesystem.
 *
 * @param manifest Partial manifest fields to serialize.
 * @returns A JSON manifest string.
 */
function manifestJson(manifest: Record<string, unknown>): string {
  return JSON.stringify(manifest);
}

describe("loadPackManifests", () => {
  it("loads selected manifests and always includes core", () => {
    // Arrange
    const fs = buildInMemoryFileSystem({
      [`${MANIFEST_DIR}/core.json`]: manifestJson({
        name: "core",
        label: "Core",
        paths: [".claude/rules/general.md"],
      }),
      [`${MANIFEST_DIR}/python.json`]: manifestJson({
        name: "python",
        label: "Python",
        paths: [".claude/rules/python.md"],
      }),
    });

    // Act
    const manifests = loadPackManifests(MANIFEST_DIR, new Set(["python"]), fs);

    // Assert: core loaded even though only python was selected.
    expect([...manifests.keys()].sort()).toEqual(["core", "python"]);
    expect(manifests.get("python")?.paths).toEqual([".claude/rules/python.md"]);
  });

  it("rejects a missing manifest with the exact message", () => {
    // Arrange: only core present, python missing.
    const fs = buildInMemoryFileSystem({
      [`${MANIFEST_DIR}/core.json`]: manifestJson({
        name: "core",
        label: "Core",
        paths: [],
      }),
    });

    // Act / Assert
    expect(() =>
      loadPackManifests(MANIFEST_DIR, new Set(["python"]), fs),
    ).toThrow(
      `Pack manifest is missing for pack 'python': ${MANIFEST_DIR}/python.json`,
    );
  });

  it("rejects invalid JSON with the exact message", () => {
    // Arrange
    const fs = buildInMemoryFileSystem({
      [`${MANIFEST_DIR}/core.json`]: "{ not json",
    });

    // Act / Assert
    expect(() => loadPackManifests(MANIFEST_DIR, new Set(), fs)).toThrow(
      `Pack manifest is not valid JSON for pack 'core': ${MANIFEST_DIR}/core.json`,
    );
  });

  it("rejects a non-object manifest with the exact message", () => {
    // Arrange
    const fs = buildInMemoryFileSystem({
      [`${MANIFEST_DIR}/core.json`]: manifestJson([1, 2, 3]),
    });

    // Act / Assert
    expect(() => loadPackManifests(MANIFEST_DIR, new Set(), fs)).toThrow(
      `Pack manifest must be a JSON object for pack 'core': ${MANIFEST_DIR}/core.json`,
    );
  });

  it("rejects a manifest with an empty name", () => {
    // Arrange
    const fs = buildInMemoryFileSystem({
      [`${MANIFEST_DIR}/core.json`]: manifestJson({
        name: "",
        label: "Core",
        paths: [],
      }),
    });

    // Act / Assert
    expect(() => loadPackManifests(MANIFEST_DIR, new Set(), fs)).toThrow(
      `Pack manifest 'name' must be a non-empty string: ${MANIFEST_DIR}/core.json`,
    );
  });

  it("rejects a manifest with an empty label", () => {
    // Arrange
    const fs = buildInMemoryFileSystem({
      [`${MANIFEST_DIR}/core.json`]: manifestJson({
        name: "core",
        label: "",
        paths: [],
      }),
    });

    // Act / Assert
    expect(() => loadPackManifests(MANIFEST_DIR, new Set(), fs)).toThrow(
      `Pack manifest 'label' must be a non-empty string: ${MANIFEST_DIR}/core.json`,
    );
  });

  it("rejects a manifest whose paths is not a list", () => {
    // Arrange
    const fs = buildInMemoryFileSystem({
      [`${MANIFEST_DIR}/core.json`]: manifestJson({
        name: "core",
        label: "Core",
        paths: "not-a-list",
      }),
    });

    // Act / Assert
    expect(() => loadPackManifests(MANIFEST_DIR, new Set(), fs)).toThrow(
      `Pack manifest 'paths' must be a list of strings: ${MANIFEST_DIR}/core.json`,
    );
  });

  it("rejects a manifest with a non-string path entry", () => {
    // Arrange
    const fs = buildInMemoryFileSystem({
      [`${MANIFEST_DIR}/core.json`]: manifestJson({
        name: "core",
        label: "Core",
        paths: [".claude/rules/general.md", 42],
      }),
    });

    // Act / Assert
    expect(() => loadPackManifests(MANIFEST_DIR, new Set(), fs)).toThrow(
      `Pack manifest 'paths' must be a list of strings: ${MANIFEST_DIR}/core.json`,
    );
  });

  it("rejects a manifest whose source_prefix is not a string", () => {
    // Arrange
    const fs = buildInMemoryFileSystem({
      [`${MANIFEST_DIR}/core.json`]: manifestJson({
        name: "core",
        label: "Core",
        paths: [],
        source_prefix: 5,
      }),
    });

    // Act / Assert
    expect(() => loadPackManifests(MANIFEST_DIR, new Set(), fs)).toThrow(
      `Pack manifest 'source_prefix' must be a string when present: ${MANIFEST_DIR}/core.json`,
    );
  });
});

describe("computePublishedPaths", () => {
  const manifests = new Map<string, PackManifest>([
    [
      "core",
      {
        name: "core",
        label: "Core",
        paths: [".claude/rules/general.md"],
        sourcePrefix: null,
      },
    ],
    [
      "python",
      {
        name: "python",
        label: "Python",
        paths: [".claude/rules/python.md"],
        sourcePrefix: null,
      },
    ],
  ]);

  it("returns null for an empty selection (publish everything)", () => {
    // Arrange / Act / Assert
    expect(computePublishedPaths(null, manifests)).toBeNull();
    expect(computePublishedPaths(new Set(), manifests)).toBeNull();
  });

  it("unions selected pack paths and always includes core", () => {
    // Arrange / Act
    const published = computePublishedPaths(new Set(["python"]), manifests);

    // Assert
    expect([...(published ?? [])].sort()).toEqual([
      ".claude/rules/general.md",
      ".claude/rules/python.md",
    ]);
  });

  it("throws when a selected pack has no loaded manifest", () => {
    // Arrange / Act / Assert
    expect(() =>
      computePublishedPaths(new Set(["missing"]), manifests),
    ).toThrow("No loaded manifest for selected pack 'missing'.");
  });
});

describe("resolveVariantSourcePath", () => {
  it("routes a canonical C# path to the legacy source for the legacy variant", () => {
    // Arrange / Act / Assert
    expect(resolveVariantSourcePath(".claude/rules/csharp.md", "legacy")).toBe(
      ".claude-variants/csharp-legacy/rules/csharp.md",
    );
  });

  it("passes a canonical C# path through unchanged for the modern variant", () => {
    // Arrange / Act / Assert
    expect(resolveVariantSourcePath(".claude/rules/csharp.md", "modern")).toBe(
      ".claude/rules/csharp.md",
    );
  });

  it("passes a non-C# path through unchanged even for the legacy variant", () => {
    // Arrange / Act / Assert
    expect(resolveVariantSourcePath(".claude/rules/python.md", "legacy")).toBe(
      ".claude/rules/python.md",
    );
  });
});

describe("assertSingleCsharpToolchain", () => {
  it("rejects selecting both C# packs", () => {
    // Arrange / Act / Assert
    expect(() =>
      assertSingleCsharpToolchain(
        new Set([".claude/rules/csharp.md"]),
        new Set(["csharp-modern", "csharp-legacy"]),
      ),
    ).toThrow(ManifestError);
  });

  it("accepts selecting a single C# variant", () => {
    // Arrange / Act / Assert: no throw.
    expect(() =>
      assertSingleCsharpToolchain(
        new Set([".claude/rules/csharp.md"]),
        new Set(["csharp-legacy"]),
      ),
    ).not.toThrow();
  });
});
