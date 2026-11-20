/**
 * Unit tests for push-down pack resolution and the layer helpers (issue #1029).
 *
 * Manifests are seeded into a fresh in-memory filesystem per test.
 */

import { ManifestError } from "../../../src/lib/push-down/claude-pack-selection";
import {
  ECOSYSTEM_NAMES,
  isEcosystemName,
  LAYER_ROOT_FILES,
} from "../../../src/lib/push-down/push-down-layer";
import {
  buildPackOwnerLookup,
  loadSharedLayerPaths,
  PublishedPathFilterFileSystem,
  resolveLayerPublishedPaths,
} from "../../../src/lib/push-down/push-down-pack-resolver";
import { buildInMemoryFileSystem } from "./push-down.test-helpers";

/** Render one pack manifest. */
function manifest(name: string, paths: ReadonlyArray<string>): string {
  return JSON.stringify({ name, label: name, paths });
}

/** Seed a bundle with the named manifests under `/bundle/pack-manifests`. */
function bundle(manifests: Readonly<Record<string, ReadonlyArray<string>>>) {
  const files: Record<string, string> = {};
  for (const [name, paths] of Object.entries(manifests)) {
    files[`/bundle/pack-manifests/${name}.json`] = manifest(name, paths);
  }
  return buildInMemoryFileSystem(files);
}

describe("resolveLayerPublishedPaths", () => {
  it("unions core and the selected Claude packs and records the selection", () => {
    const fs = bundle({
      core: [".claude/a.md"],
      python: [".claude/py.md", ".claude/a.md"],
    });
    const resolved = resolveLayerPublishedPaths({
      ecosystem: "claude",
      packs: ["python"],
      csharpVariant: "modern",
      memoryMode: "merge",
      bundleRoot: "/bundle",
      fs,
    });
    expect([...(resolved.publishedPaths ?? [])].sort()).toEqual([
      ".claude/a.md",
      ".claude/py.md",
    ]);
    expect(resolved.ownerPack(".claude/a.md")).toBe("core");
    expect(resolved.ownerPack(".claude/py.md")).toBe("python");
    expect(resolved.selection).toEqual({
      packs: ["core", "python"],
      csharpVariant: "modern",
      memoryMode: "merge",
    });
  });

  it("fails when both C# variants are selected", () => {
    const fs = bundle({
      core: ["a"],
      "csharp-modern": ["c"],
      "csharp-legacy": ["c"],
    });
    expect(() =>
      resolveLayerPublishedPaths({
        ecosystem: "claude",
        packs: ["csharp-modern", "csharp-legacy"],
        csharpVariant: "modern",
        memoryMode: "overwrite",
        bundleRoot: "/bundle",
        fs,
      }),
    ).toThrow("C# mutual exclusion violated");
  });

  it("routes the public Codex csharp pack to the selected variant", () => {
    const fs = bundle({
      core: [".codex/a.toml"],
      "csharp-legacy": [".codex/c.toml"],
    });
    const resolved = resolveLayerPublishedPaths({
      ecosystem: "codex",
      packs: ["csharp"],
      csharpVariant: "legacy",
      memoryMode: "overwrite",
      bundleRoot: "/bundle",
      fs,
    });
    expect(resolved.publishedPaths?.has(".codex/c.toml")).toBe(true);
    expect(resolved.ownerPack(".codex/c.toml")).toBe("csharp-legacy");
    expect(resolved.selection.packs).toEqual(["core", "csharp"]);
    expect(resolved.selection.csharpVariant).toBe("legacy");
  });

  it("resolves a Copilot selection without variant fields", () => {
    const fs = bundle({ core: [".github/a.md"], python: [".github/p.md"] });
    const resolved = resolveLayerPublishedPaths({
      ecosystem: "copilot",
      packs: ["python", "core"],
      csharpVariant: "modern",
      memoryMode: "overwrite",
      bundleRoot: "/bundle",
      fs,
    });
    expect(resolved.selection).toEqual({ packs: ["core", "python"] });
    expect(resolved.publishedPaths?.size).toBe(2);
  });

  it("fails on an unknown Copilot pack", () => {
    const fs = bundle({ core: ["a"] });
    expect(() =>
      resolveLayerPublishedPaths({
        ecosystem: "copilot",
        packs: ["rust", "go"],
        csharpVariant: "modern",
        memoryMode: "overwrite",
        bundleRoot: "/bundle",
        fs,
      }),
    ).toThrow("Unknown Copilot pack name(s): go, rust");
  });

  it.each([
    [
      "claude",
      "legacy",
      ["core", "csharp-legacy", "powershell", "python", "typescript"],
    ],
    [
      "codex",
      "modern",
      ["core", "csharp", "powershell", "python", "typescript"],
    ],
    [
      "copilot",
      "modern",
      ["core", "csharp", "powershell", "python", "typescript"],
    ],
  ] as const)(
    "publishes the full %s tree and records every accepted pack when packs is omitted",
    (ecosystem, csharpVariant, packs) => {
      const resolved = resolveLayerPublishedPaths({
        ecosystem,
        packs: null,
        csharpVariant,
        memoryMode: "skip",
        bundleRoot: "/bundle",
        fs: buildInMemoryFileSystem(),
      });
      expect(resolved.publishedPaths).toBeNull();
      expect(resolved.selection.packs).toEqual(packs);
      expect(resolved.ownerPack("anything")).toBe("core");
    },
  );

  it("treats an empty selection as the full tree", () => {
    const resolved = resolveLayerPublishedPaths({
      ecosystem: "codex",
      packs: [],
      csharpVariant: "modern",
      memoryMode: "overwrite",
      bundleRoot: "/bundle",
      fs: buildInMemoryFileSystem(),
    });
    expect(resolved.publishedPaths).toBeNull();
    expect(resolved.selection.memoryMode).toBe("overwrite");
  });
});

describe("loadSharedLayerPaths", () => {
  it("loads the shared path set", () => {
    const fs = buildInMemoryFileSystem({
      "/m/shared.json": manifest("shared", ["AGENTS.md", "config/x.json"]),
    });
    expect([...loadSharedLayerPaths("/m", fs)]).toEqual([
      "AGENTS.md",
      "config/x.json",
    ]);
  });

  it("fails when the shared manifest is missing", () => {
    expect(() => loadSharedLayerPaths("/m", buildInMemoryFileSystem())).toThrow(
      ManifestError,
    );
  });

  it.each([
    ["invalid JSON", "{", "not valid JSON"],
    ["a non-object", "[]", "must be a JSON object"],
    ["a wrong name", manifest("core", []), "'name' must be 'shared'"],
    [
      "non-string paths",
      JSON.stringify({ name: "shared", paths: [1] }),
      "'paths'",
    ],
  ])("fails on %s", (_label, text, message) => {
    const fs = buildInMemoryFileSystem({ "/m/shared.json": text });
    expect(() => loadSharedLayerPaths("/m", fs)).toThrow(message);
  });
});

describe("buildPackOwnerLookup", () => {
  it("lets core claim first and other packs claim in name order", () => {
    const lookup = buildPackOwnerLookup(
      new Map([
        ["typescript", { name: "typescript", paths: ["t", "shared"] }],
        ["python", { name: "python", paths: ["p", "shared"] }],
        ["core", { name: "core", paths: ["c", "p"] }],
      ]),
    );
    expect(lookup("c")).toBe("core");
    expect(lookup("p")).toBe("core");
    expect(lookup("shared")).toBe("python");
    expect(lookup("t")).toBe("typescript");
    expect(lookup("unlisted")).toBe("core");
  });
});

describe("PublishedPathFilterFileSystem", () => {
  const inner = buildInMemoryFileSystem({
    "/src/.agents/a.md": "a",
    "/src/.agents/b.md": "b",
    "/elsewhere/c.md": "c",
  });

  it("keeps only published paths under the source root", () => {
    const fs = new PublishedPathFilterFileSystem(
      inner,
      "/src/",
      new Set([".agents/a.md"]),
    );
    expect(fs.listFiles("/src/.agents")).toEqual(["/src/.agents/a.md"]);
    expect(fs.listFiles("/elsewhere")).toEqual(["/elsewhere/c.md"]);
  });

  it("keeps every path when the published set is null and delegates I/O", () => {
    const target = buildInMemoryFileSystem({ "/src/x.md": "x" });
    const fs = new PublishedPathFilterFileSystem(target, "/src", null);
    fs.writeTextFile("/dest/y.md", "y");
    fs.ensureDir("/dest/z");
    expect(fs.listFiles("/src")).toEqual(["/src/x.md"]);
    expect(fs.isDir("/src")).toBe(true);
    expect(fs.isFile("/src/x.md")).toBe(true);
    expect(fs.readTextFile("/dest/y.md")).toBe("y");
    expect(target.ensuredDirs).toEqual(["/dest/z"]);
  });
});

describe("push-down layer helpers", () => {
  it("recognizes ecosystem names", () => {
    expect(isEcosystemName("codex")).toBe(true);
    expect(isEcosystemName("shared")).toBe(false);
    expect(ECOSYSTEM_NAMES).toEqual(["claude", "codex", "copilot"]);
  });

  it("declares the O-10 root files per layer", () => {
    expect(LAYER_ROOT_FILES.shared).toEqual([
      ["AGENTS.md", "codex-and-agents-customizations/AGENTS.md"],
    ]);
    expect(LAYER_ROOT_FILES.claude).toEqual([
      [".mcp.json", "claude-dir-customizations/.mcp.json"],
    ]);
    expect(LAYER_ROOT_FILES.codex).toEqual([]);
    expect(
      LAYER_ROOT_FILES.copilot.map(([destination]) => destination),
    ).toEqual([".github/copilot-instructions.md"]);
  });
});
