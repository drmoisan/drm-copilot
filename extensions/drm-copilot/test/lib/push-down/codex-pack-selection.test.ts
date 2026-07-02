import { describe, expect, it } from "@jest/globals";

import {
  CSHARP_CANONICAL_PATHS,
  assertSingleCsharpToolchain,
  computePublishedPaths,
  loadPackManifests,
  ManifestError,
  resolveVariantSourcePath,
  type PackManifest,
} from "../../../src/lib/push-down/codex-pack-selection";
import { buildInMemoryFileSystem } from "./push-down.test-helpers";

const MANIFEST_DIR = "/bundle/pack-manifests";

function manifestJson(manifest: Record<string, unknown>): string {
  return JSON.stringify(manifest);
}

describe("Codex loadPackManifests", () => {
  it("loads selected manifests and always includes core", () => {
    const fs = buildInMemoryFileSystem({
      [`${MANIFEST_DIR}/core.json`]: manifestJson({
        name: "core",
        paths: [".codex/config.toml"],
      }),
      [`${MANIFEST_DIR}/typescript.json`]: manifestJson({
        name: "typescript",
        label: "TypeScript",
        paths: [".agents/skills/typescript/SKILL.md"],
      }),
    });

    const manifests = loadPackManifests(
      MANIFEST_DIR,
      new Set(["typescript"]),
      fs,
    );

    expect([...manifests.keys()].sort()).toEqual(["core", "typescript"]);
  });

  it("rejects missing, malformed, and unknown manifests", () => {
    const missingFs = buildInMemoryFileSystem({
      [`${MANIFEST_DIR}/core.json`]: manifestJson({
        name: "core",
        paths: [".codex/config.toml"],
      }),
    });
    expect(() =>
      loadPackManifests(MANIFEST_DIR, new Set(["python"]), missingFs),
    ).toThrow(ManifestError);

    const malformedFs = buildInMemoryFileSystem({
      [`${MANIFEST_DIR}/core.json`]: "{not json",
    });
    expect(() =>
      loadPackManifests(MANIFEST_DIR, new Set(["core"]), malformedFs),
    ).toThrow("not valid JSON");

    expect(() =>
      loadPackManifests(MANIFEST_DIR, new Set(["ruby"]), malformedFs),
    ).toThrow("Unknown Codex pack");
  });
});

describe("Codex computePublishedPaths", () => {
  const manifests = new Map<string, PackManifest>([
    [
      "core",
      {
        name: "core",
        label: "Core",
        paths: [".codex/config.toml"],
        sourcePrefix: null,
      },
    ],
    [
      "typescript",
      {
        name: "typescript",
        label: "TypeScript",
        paths: [".agents/skills/typescript/SKILL.md"],
        sourcePrefix: null,
      },
    ],
  ]);

  it("returns null for empty selection and includes core for explicit selection", () => {
    expect(computePublishedPaths(null, manifests)).toBeNull();
    expect(computePublishedPaths(new Set(), manifests)).toBeNull();
    expect([
      ...(computePublishedPaths(new Set(["typescript"]), manifests) ?? []),
    ]).toEqual([".agents/skills/typescript/SKILL.md", ".codex/config.toml"]);
  });
});

describe("Codex C# variant routing", () => {
  it("declares canonical destinations and routes legacy agents/codex sources", () => {
    expect(CSHARP_CANONICAL_PATHS).toEqual([
      ".agents/skills/csharp/SKILL.md",
      ".agents/skills/csharp-qa-gate/SKILL.md",
      ".agents/skills/invoke-csharp-engineer/SKILL.md",
      ".codex/agents/csharp-typed-engineer.toml",
    ]);
    expect(
      resolveVariantSourcePath(".agents/skills/csharp/SKILL.md", "legacy"),
    ).toBe(".agents-variants/csharp-legacy/skills/csharp/SKILL.md");
    expect(
      resolveVariantSourcePath(
        ".codex/agents/csharp-typed-engineer.toml",
        "legacy",
      ),
    ).toBe(".codex-variants/csharp-legacy/agents/csharp-typed-engineer.toml");
    expect(
      resolveVariantSourcePath(".agents/skills/csharp/SKILL.md", "modern"),
    ).toBe(".agents/skills/csharp/SKILL.md");
  });

  it("rejects selecting both C# variants", () => {
    expect(() =>
      assertSingleCsharpToolchain(
        new Set(CSHARP_CANONICAL_PATHS),
        new Set(["csharp-modern", "csharp-legacy"]),
      ),
    ).toThrow(ManifestError);
  });
});
