import { describe, expect, it } from "@jest/globals";

import {
  ARTIFACT_DIRECTORY,
  ManifestError,
  parsePacksArgument,
  pushDownCustomizations,
  ROOT_FOLDERS,
} from "../../../src/lib/push-down/claude-customizations";
import { buildInMemoryFileSystem, fixedClock } from "./push-down.test-helpers";

const CLOCK = fixedClock("2026-06-26T00:15:00.000Z");
const SRC = "/src";
const DEST = "/dest";
const BUNDLE = `${SRC}/extensions/drm-copilot/resources/claude-customizations`;
const MANIFEST_DIR = `${BUNDLE}/pack-manifests`;
const LEGACY_BASE = `${BUNDLE}/.claude-variants/csharp-legacy`;
const CSHARP_PATHS = [
  ".claude/rules/csharp.md",
  ".claude/agents/csharp-typed-engineer.md",
  ".claude/skills/csharp-qa-gate/SKILL.md",
  ".claude/skills/invoke-csharp-engineer/SKILL.md",
];

/**
 * Build a manifest JSON string for seeding.
 *
 * @param manifest Manifest fields to serialize.
 * @returns Serialized manifest JSON.
 */
function manifest(manifest: Record<string, unknown>): string {
  return JSON.stringify(manifest);
}

/**
 * Seed a representative `.claude` tree, legacy variant subtree, and manifests.
 *
 * @returns A seeded in-memory filesystem with `/dest` ensured.
 */
function seedFullTree(): ReturnType<typeof buildInMemoryFileSystem> {
  return buildInMemoryFileSystem(
    {
      [`${SRC}/.claude/settings.json`]: '{"core": true}\n',
      [`${SRC}/.claude/settings.local.json`]: '{"host": true}\n',
      [`${SRC}/.claude/agents/orchestrator.md`]: "# Orchestrator\n",
      [`${SRC}/.claude/rules/typescript.md`]: "# TS rules\n",
      [`${SRC}/.claude/rules/python.md`]: "# Python rules\n",
      [`${SRC}/.claude/rules/csharp.md`]: "# Modern C#\n",
      [`${SRC}/.claude/agents/csharp-typed-engineer.md`]: "# Modern engineer\n",
      [`${SRC}/.claude/skills/csharp-qa-gate/SKILL.md`]: "# Modern qa\n",
      [`${SRC}/.claude/skills/invoke-csharp-engineer/SKILL.md`]:
        "# Modern inv\n",
      [`${LEGACY_BASE}/rules/csharp.md`]: "# Legacy C#\n",
      [`${LEGACY_BASE}/agents/csharp-typed-engineer.md`]: "# Legacy engineer\n",
      [`${LEGACY_BASE}/skills/csharp-qa-gate/SKILL.md`]: "# Legacy qa\n",
      [`${LEGACY_BASE}/skills/invoke-csharp-engineer/SKILL.md`]:
        "# Legacy inv\n",
      [`${MANIFEST_DIR}/core.json`]: manifest({
        name: "core",
        label: "Core",
        paths: [".claude/settings.json", ".claude/agents/orchestrator.md"],
      }),
      [`${MANIFEST_DIR}/typescript.json`]: manifest({
        name: "typescript",
        label: "TypeScript",
        paths: [".claude/rules/typescript.md"],
      }),
      [`${MANIFEST_DIR}/python.json`]: manifest({
        name: "python",
        label: "Python",
        paths: [".claude/rules/python.md"],
      }),
      [`${MANIFEST_DIR}/csharp-modern.json`]: manifest({
        name: "csharp-modern",
        label: "C# Modern",
        paths: CSHARP_PATHS,
      }),
      [`${MANIFEST_DIR}/csharp-legacy.json`]: manifest({
        name: "csharp-legacy",
        label: "C# Legacy",
        paths: CSHARP_PATHS,
        source_prefix: ".claude-variants/csharp-legacy",
      }),
    },
    [DEST],
  );
}

describe("parsePacksArgument", () => {
  it("returns null when the value is null or undefined", () => {
    // Arrange / Act / Assert
    expect(parsePacksArgument(null)).toBeNull();
    expect(parsePacksArgument(undefined)).toBeNull();
  });

  it("returns null when the value contains only empty entries", () => {
    // Arrange / Act / Assert
    expect(parsePacksArgument(" , , ")).toBeNull();
  });

  it("trims entries and drops empties", () => {
    // Arrange / Act
    const result = parsePacksArgument("core, typescript ,, python,");

    // Assert
    expect([...(result ?? [])].sort()).toEqual([
      "core",
      "python",
      "typescript",
    ]);
  });
});

describe("pushDownCustomizations (claude)", () => {
  it("publishes the full tree with no manifest read when no packs are selected", () => {
    // Arrange: no manifests seeded; a manifest read would throw.
    const fs = buildInMemoryFileSystem(
      {
        [`${SRC}/.claude/rules/typescript.md`]: "# TS\n",
        [`${SRC}/.claude/settings.local.json`]: "{}",
      },
      [DEST],
    );

    // Act
    const summary = pushDownCustomizations({
      repoRoot: SRC,
      destinationRoot: DEST,
      fs,
      sourceRoot: SRC,
      artifactRoot: DEST,
      clock: CLOCK,
    });

    // Assert: everything except settings.local.json is published.
    const relativePaths = summary.files.map((f) => f.relativePath);
    expect(relativePaths).toContain(".claude/rules/typescript.md");
    expect(relativePaths).not.toContain(".claude/settings.local.json");
  });

  it("restricts published paths to the selection and always includes core", () => {
    // Arrange
    const fs = seedFullTree();

    // Act: select only typescript; core must still be published.
    const summary = pushDownCustomizations({
      repoRoot: SRC,
      destinationRoot: DEST,
      fs,
      sourceRoot: SRC,
      artifactRoot: DEST,
      packs: new Set(["typescript"]),
      bundleRoot: BUNDLE,
      clock: CLOCK,
    });

    // Assert
    const relativePaths = summary.files.map((f) => f.relativePath).sort();
    expect(relativePaths).toEqual(
      [
        ".claude/settings.json",
        ".claude/agents/orchestrator.md",
        ".claude/rules/typescript.md",
      ].sort(),
    );
  });

  it("routes legacy C# reads to the legacy source while writing canonical paths", () => {
    // Arrange
    const fs = seedFullTree();

    // Act
    pushDownCustomizations({
      repoRoot: SRC,
      destinationRoot: DEST,
      fs,
      sourceRoot: SRC,
      artifactRoot: DEST,
      packs: new Set(["csharp-legacy"]),
      csharpVariant: "legacy",
      bundleRoot: BUNDLE,
      clock: CLOCK,
    });

    // Assert: the canonical destination path receives legacy content.
    expect(fs.readTextFile(`${DEST}/.claude/rules/csharp.md`)).toBe(
      "# Legacy C#\n",
    );
  });

  it("raises the exclusion ManifestError when both C# packs are selected", () => {
    // Arrange
    const fs = seedFullTree();

    // Act / Assert
    expect(() =>
      pushDownCustomizations({
        repoRoot: SRC,
        destinationRoot: DEST,
        fs,
        sourceRoot: SRC,
        artifactRoot: DEST,
        packs: new Set(["csharp-modern", "csharp-legacy"]),
        bundleRoot: BUNDLE,
        clock: CLOCK,
      }),
    ).toThrow(ManifestError);
  });

  it("threads the skip memory mode through to ExcludingFileSystem", () => {
    // Arrange: a general agent memory that skip mode must exclude.
    const fs = buildInMemoryFileSystem(
      {
        [`${SRC}/.claude/agent-memory/o/g.md`]:
          "---\nmetadata:\n  scope: general\n---\nbody\n",
        [`${SRC}/.claude/rules/python.md`]: "# Python\n",
      },
      [DEST],
    );

    // Act
    const summary = pushDownCustomizations({
      repoRoot: SRC,
      destinationRoot: DEST,
      fs,
      sourceRoot: SRC,
      artifactRoot: DEST,
      memoryMode: "skip",
      clock: CLOCK,
    });

    // Assert: the memory is skipped; the rule survives.
    const relativePaths = summary.files.map((f) => f.relativePath);
    expect(relativePaths).toContain(".claude/rules/python.md");
    expect(relativePaths).not.toContain(".claude/agent-memory/o/g.md");
  });

  it("excludes settings.local.json from the published set", () => {
    // Arrange
    const fs = buildInMemoryFileSystem(
      {
        [`${SRC}/.claude/settings.local.json`]: "{}",
        [`${SRC}/.claude/rules/python.md`]: "# Python\n",
      },
      [DEST],
    );

    // Act
    const summary = pushDownCustomizations({
      repoRoot: SRC,
      destinationRoot: DEST,
      fs,
      sourceRoot: SRC,
      artifactRoot: DEST,
      clock: CLOCK,
    });

    // Assert
    expect(summary.files.map((f) => f.relativePath)).not.toContain(
      ".claude/settings.local.json",
    );
  });

  it("writes the summary artifact under the claude artifact directory", () => {
    // Arrange
    const fs = buildInMemoryFileSystem(
      { [`${SRC}/.claude/rules/python.md`]: "# Python\n" },
      [DEST],
    );

    // Act
    const summary = pushDownCustomizations({
      repoRoot: SRC,
      destinationRoot: DEST,
      fs,
      sourceRoot: SRC,
      artifactRoot: DEST,
      clock: CLOCK,
    });

    // Assert
    expect(summary.artifactPath).toBe(
      `${DEST}/artifacts/claude-customizations/push-down-20260626T001500Z.json`,
    );
    expect(ARTIFACT_DIRECTORY).toBe("artifacts/claude-customizations");
    expect(ROOT_FOLDERS).toEqual([".claude", "config"]);
  });
});
