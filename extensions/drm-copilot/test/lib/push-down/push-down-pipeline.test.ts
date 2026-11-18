/**
 * Unit tests for the planning half of the push-down pipeline (issue #1029).
 *
 * Layers are in-memory; each test builds a fresh adapter.
 */

import { resolveLayerPublishedPaths } from "../../../src/lib/push-down/push-down-pack-resolver";
import {
  type PushDownPipelineOptions,
  runPushDownPipeline,
} from "../../../src/lib/push-down/push-down-pipeline";
import { hashPayloadText } from "../../../src/lib/push-down/push-down-destination-manifest";
import { PublishedPathFilterFileSystem } from "../../../src/lib/push-down/push-down-pack-resolver";
import { WriteIfChangedFileSystem } from "../../../src/lib/push-down/push-down-write-if-changed";
import {
  buildInMemoryFileSystem,
  fixedClock,
  type InMemoryPushDownFileSystem,
} from "./push-down.test-helpers";
import { makeTestLayer, snapshotTree } from "./push-down-pipeline.test-helpers";

const CLOCK = fixedClock("2026-11-18T08:00:00Z");

/** Render a destination manifest with the given files. */
function destinationManifest(
  files: Record<string, { layer: string; pack: string; sha256: string }>,
  selection: Record<string, { packs: string[] }> = {},
): string {
  return JSON.stringify({
    schema_version: "1.0.0",
    payload_version: "1.0.0",
    selection,
    files,
  });
}

/** Base adapter with a shared and a codex source tree and an empty destination. */
function seededFs(
  extra: Record<string, string> = {},
): InMemoryPushDownFileSystem {
  return buildInMemoryFileSystem(
    {
      "/src/shared/.x/a.md": "shared a\n",
      "/src/codex/.x/b.md": "codex b\n",
      ...extra,
    },
    ["/dest"],
  );
}

/** Pipeline options over a shared and a codex test layer. */
function options(
  fs: InMemoryPushDownFileSystem,
  overrides: Partial<PushDownPipelineOptions> = {},
): PushDownPipelineOptions {
  return {
    repoRoot: "/src",
    destinationRoot: "/dest",
    fs,
    buildLayers: () => [
      makeTestLayer(fs, "shared"),
      makeTestLayer(fs, "codex"),
    ],
    clock: CLOCK,
    ...overrides,
  };
}

describe("runPushDownPipeline", () => {
  it("computes the full plan before the first write", () => {
    const fs = seededFs();

    const result = runPushDownPipeline(options(fs));

    expect(fs.writtenPaths).toEqual([]);
    expect(fs.ensuredDirs).toEqual([]);
    expect(result.report.mode).toBe("apply");
    expect(
      result.report.files.map((file) => [file.path, file.layer, file.action]),
    ).toEqual([
      [".x/a.md", "shared", "create"],
      [".x/b.md", "codex", "create"],
    ]);
    expect(result.plan.entries).toHaveLength(2);
    expect(result.summary.createdCount).toBe(2);
    expect(result.summary.artifactPath).toBe("");
    expect(result.warnings).toEqual([]);
  });

  it("dry run leaves the destination byte-identical", () => {
    const fs = seededFs({ "/dest/.x/b.md": "local\n" });
    const before = snapshotTree(fs, "/dest");

    const result = runPushDownPipeline(options(fs, { dryRun: true }));

    expect(snapshotTree(fs, "/dest")).toEqual(before);
    expect(fs.writtenPaths).toEqual([]);
    expect(result.report.mode).toBe("dry-run");
    expect(result.report.counts).toEqual({
      create: 1,
      "unmanaged-conflict": 1,
    });
    expect(result.summary.overwrittenCount).toBe(1);
  });

  describe("fails before any write on <case>", () => {
    const packLayers =
      (fs: InMemoryPushDownFileSystem, packs: string[]) => () => {
        resolveLayerPublishedPaths({
          ecosystem: "claude",
          packs,
          csharpVariant: "modern",
          memoryMode: "overwrite",
          bundleRoot: "/bundle",
          fs,
        });
        return [makeTestLayer(fs, "claude")];
      };
    const cases: ReadonlyArray<
      readonly [
        string,
        (fs: InMemoryPushDownFileSystem) => Partial<PushDownPipelineOptions>,
        Record<string, string>,
        string,
      ]
    > = [
      [
        "a missing destination",
        () => ({ destinationRoot: "/missing" }),
        {},
        "does not exist",
      ],
      [
        "a destination equal to the source",
        () => ({ destinationRoot: "/src" }),
        {},
        "must not be",
      ],
      [
        "a malformed exclusion manifest",
        () => ({}),
        { "/dest/.push-down-exclusions": "!negated\n" },
        "Malformed push-down exclusion manifest",
      ],
      [
        "an invalid-JSON destination manifest",
        () => ({}),
        { "/dest/.push-down-manifest.json": "{" },
        "not valid JSON",
      ],
      [
        "an unknown-major destination manifest",
        () => ({}),
        { "/dest/.push-down-manifest.json": '{"schema_version":"2.0.0"}' },
        "unknown major",
      ],
      [
        "a destination manifest missing a required field",
        () => ({}),
        { "/dest/.push-down-manifest.json": '{"schema_version":"1.0.0"}' },
        "payload_version",
      ],
      [
        "a missing pack manifest",
        (fs) => ({ buildLayers: packLayers(fs, ["python"]) }),
        {},
        "missing",
      ],
      [
        "a malformed pack manifest",
        (fs) => ({ buildLayers: packLayers(fs, ["python"]) }),
        {
          "/bundle/pack-manifests/core.json": "[]",
          "/bundle/pack-manifests/python.json": "[]",
        },
        "JSON object",
      ],
      [
        "both C# variants selected",
        (fs) => ({
          buildLayers: packLayers(fs, ["csharp-modern", "csharp-legacy"]),
        }),
        {
          "/bundle/pack-manifests/core.json":
            '{"name":"core","label":"c","paths":[]}',
          "/bundle/pack-manifests/csharp-modern.json":
            '{"name":"m","label":"m","paths":[]}',
          "/bundle/pack-manifests/csharp-legacy.json":
            '{"name":"l","label":"l","paths":[]}',
        },
        "mutual exclusion",
      ],
    ];

    it.each(cases)(
      "fails before any write on %s",
      (_label, override, seed, message) => {
        const fs = seededFs(seed);
        const before = snapshotTree(fs, "/dest");

        expect(() => runPushDownPipeline(options(fs, override(fs)))).toThrow(
          message,
        );
        expect(fs.writtenPaths).toEqual([]);
        expect(fs.ensuredDirs).toEqual([]);
        expect(snapshotTree(fs, "/dest")).toEqual(before);
      },
    );
  });

  it("reports excluded paths for every layer", () => {
    const fs = seededFs({
      "/src/codex/.x/c.md": "c\n",
      "/res/root.md": "root\n",
      "/dest/.push-down-exclusions": ".x/a.md\n.x/b.md\nROOT.md\n.y\n",
    });
    const layers = () => [
      makeTestLayer(fs, "shared", { rootFiles: [["ROOT.md", "root.md"]] }),
      makeTestLayer(fs, "codex", {
        mergedDeliveries: [
          { relativePath: ".y", merge: (text) => `${text}y\n` },
        ],
      }),
    ];

    const result = runPushDownPipeline(options(fs, { buildLayers: layers }));

    const excluded = result.report.files.filter(
      (file) => file.action === "excluded",
    );
    expect(excluded.map((file) => [file.path, file.layer])).toEqual([
      [".x/a.md", "shared"],
      [".x/b.md", "codex"],
      [".y", "codex"],
      ["ROOT.md", "shared"],
    ]);
    expect(
      result.exclusions?.skipped.map((skip) => skip.relativePath).sort(),
    ).toEqual([".x/a.md", ".x/b.md", ".y", "ROOT.md"]);
    expect(
      result.warnings.every((line) => line.startsWith("push-down exclusion")),
    ).toBe(true);
    expect(
      result.report.files.find((file) => file.path === ".x/c.md")?.action,
    ).toBe("create");
  });

  it("classifies merged paths and merged deliveries as merge", () => {
    const fs = seededFs({ "/src/codex/.x/m.json": "m\n" });
    const layers = () => [
      makeTestLayer(fs, "codex", {
        mergedPaths: [".x/m.json"],
        mergedDeliveries: [
          { relativePath: ".gitignore", merge: (text) => `${text}x\n` },
        ],
      }),
    ];

    const result = runPushDownPipeline(options(fs, { buildLayers: layers }));

    expect(result.report.counts).toEqual({ create: 1, merge: 2 });
    expect(result.summary.files.map((file) => file.relativePath)).toEqual([
      ".x/b.md",
      ".x/m.json",
    ]);
  });

  it("reports orphaned entries without deleting", () => {
    const fs = seededFs({
      "/dest/.x/gone.md": "gone\n",
      "/dest/.push-down-manifest.json": destinationManifest({
        ".x/gone.md": {
          layer: "codex",
          pack: "python",
          sha256: hashPayloadText("gone\n"),
        },
        ".z/claude.md": {
          layer: "claude",
          pack: "core",
          sha256: hashPayloadText("c"),
        },
      }),
    });

    const result = runPushDownPipeline(options(fs));

    expect(
      result.report.files.find((file) => file.path === ".x/gone.md"),
    ).toEqual({
      path: ".x/gone.md",
      layer: "codex",
      pack: "python",
      action: "orphaned",
      reason: "manifest entry without a payload counterpart; not deleted",
    });
    expect(
      result.report.files.some((file) => file.path === ".z/claude.md"),
    ).toBe(false);
    expect(fs.isFile("/dest/.x/gone.md")).toBe(true);
  });

  it("reports entries of a deselected pack as orphaned", () => {
    const fs = seededFs({
      "/src/codex/.x/py.md": "py\n",
      "/dest/.push-down-manifest.json": destinationManifest({
        ".x/py.md": {
          layer: "codex",
          pack: "python",
          sha256: hashPayloadText("py\n"),
        },
      }),
    });
    const layers = () => [
      makeTestLayer(fs, "codex", {
        fs: new PublishedPathFilterFileSystem(
          new WriteIfChangedFileSystem(fs),
          "/src/codex",
          new Set([".x/b.md"]),
        ),
      }),
    ];

    const result = runPushDownPipeline(options(fs, { buildLayers: layers }));

    expect(result.report.files.map((file) => [file.path, file.action])).toEqual(
      [
        [".x/b.md", "create"],
        [".x/py.md", "orphaned"],
      ],
    );
  });

  it("reports every planned, merged, excluded and orphaned path once", () => {
    const fs = seededFs({
      "/src/codex/.x/a.md": "duplicate claim\n",
      "/src/codex/.x/m.json": "m\n",
      "/src/codex/.x/skip.md": "s\n",
      "/dest/.push-down-exclusions": ".x/skip.md\n",
      "/dest/.push-down-manifest.json": destinationManifest({
        ".x/old.md": {
          layer: "shared",
          pack: "core",
          sha256: hashPayloadText("o"),
        },
      }),
    });
    const layers = () => [
      makeTestLayer(fs, "shared"),
      makeTestLayer(fs, "codex", { mergedPaths: [".x/m.json"] }),
    ];

    const result = runPushDownPipeline(options(fs, { buildLayers: layers }));

    const paths = result.report.files.map((file) => file.path);
    expect(new Set(paths).size).toBe(paths.length);
    expect(paths).toEqual([
      ".x/a.md",
      ".x/b.md",
      ".x/m.json",
      ".x/old.md",
      ".x/skip.md",
    ]);
    expect(result.report.counts).toEqual({
      create: 2,
      merge: 1,
      orphaned: 1,
      excluded: 1,
    });
  });

  it("skips a root-file pair whose source is absent", () => {
    const fs = seededFs({ "/res/present.md": "p\n" });
    const layers = () => [
      makeTestLayer(fs, "copilot", {
        rootFiles: [
          ["ABSENT.md", "absent.md"],
          ["PRESENT.md", "present.md"],
        ],
      }),
    ];

    const result = runPushDownPipeline(options(fs, { buildLayers: layers }));

    expect(result.report.files.map((file) => file.path)).toEqual([
      "PRESENT.md",
    ]);
  });

  it("lets the first layer that offers a path claim it", () => {
    const fs = seededFs({ "/src/codex/.x/a.md": "codex copy\n" });

    const result = runPushDownPipeline(options(fs));

    const entry = result.report.files.find((file) => file.path === ".x/a.md");
    expect(entry?.layer).toBe("shared");
    expect(
      result.plan.entries.filter(
        (planned) => planned.relativePath === ".x/a.md",
      ),
    ).toHaveLength(1);
  });

  it("accumulates rewrite counters and first-seen unmatched references", () => {
    const fs = seededFs({ "/src/codex/.x/c.md": "c\n" });
    const rewrite = (text: string): [string, number, number, string[]] => [
      text.toUpperCase(),
      1,
      2,
      ["ref-1", text.trim()],
    ];
    const layers = () => [makeTestLayer(fs, "codex", { rewrite })];

    const result = runPushDownPipeline(options(fs, { buildLayers: layers }));

    expect(result.summary.rewrittenReferenceCount).toBe(2);
    expect(result.summary.placeholderRewriteCount).toBe(4);
    expect(result.summary.unmatchedReferences).toEqual([
      "ref-1",
      "codex b",
      "c",
    ]);
    expect(result.report.ecosystems).toEqual({ codex: { packs: ["core"] } });
  });

  it("reports the recorded ecosystem selection with variant fields", () => {
    const fs = seededFs();
    const layers = () => [
      makeTestLayer(fs, "claude", {
        selection: {
          packs: ["core", "python"],
          csharpVariant: "legacy",
          memoryMode: "skip",
        },
      }),
    ];

    const result = runPushDownPipeline({
      repoRoot: "/src",
      destinationRoot: "/dest",
      fs,
      buildLayers: layers,
    });

    expect(result.report.ecosystems).toEqual({
      claude: {
        packs: ["core", "python"],
        csharp_variant: "legacy",
        memory_mode: "skip",
      },
    });
    expect(result.summary.startedAt).toBeInstanceOf(Date);
  });
});
