/**
 * Unit tests for the apply half of the push-down pipeline (issue #1029).
 *
 * Each test drives `runPushDownPipeline` then `applyPushDownPlan` over
 * in-memory layers built on a fresh adapter.
 */

import { applyPushDownPlan } from "../../../src/lib/push-down/push-down-apply";
import {
  type DestinationManifest,
  hashPayloadText,
  parseDestinationManifest,
} from "../../../src/lib/push-down/push-down-destination-manifest";
import { type PushDownLayer } from "../../../src/lib/push-down/push-down-layer";
import { runPushDownPipeline } from "../../../src/lib/push-down/push-down-pipeline";
import { WriteIfChangedFileSystem } from "../../../src/lib/push-down/push-down-write-if-changed";
import {
  buildInMemoryFileSystem,
  fixedClock,
  type InMemoryPushDownFileSystem,
} from "./push-down.test-helpers";
import {
  LineUnionFileSystem,
  makeTestLayer,
} from "./push-down-pipeline.test-helpers";

const CLOCK = fixedClock("2026-11-18T08:00:00Z");
const MANIFEST_PATH = "/dest/.push-down-manifest.json";

/** Render a previous destination manifest. */
function previous(
  files: Record<string, { layer: string; pack: string; sha256: string }>,
  selection: Record<string, { packs: string[] }> = {},
): string {
  return JSON.stringify({
    schema_version: "1.0.0",
    payload_version: "0.9.0",
    selection,
    files,
  });
}

/** Plan and apply one run; return the parsed next manifest. */
function run(
  fs: InMemoryPushDownFileSystem,
  layers: (base: InMemoryPushDownFileSystem) => PushDownLayer[],
  overwriteUnmanaged = false,
) {
  const planned = runPushDownPipeline({
    repoRoot: "/src",
    destinationRoot: "/dest",
    fs,
    buildLayers: () => layers(fs),
    overwriteUnmanaged,
    clock: CLOCK,
  });
  const applied = applyPushDownPlan(planned, {
    payloadVersion: "1.2.3",
    artifactRoot: "/dest",
    clock: CLOCK,
  });
  const manifest: DestinationManifest = parseDestinationManifest(
    fs.readTextFile(MANIFEST_PATH),
  );
  return { planned, applied, manifest };
}

/** A codex layer over `/src/codex/.x`. */
const codexOnly = (base: InMemoryPushDownFileSystem) => [
  makeTestLayer(base, "codex"),
];

/** Seed one file per decision-table row plus a previous manifest. */
function decisionTableFs(): InMemoryPushDownFileSystem {
  const h = hashPayloadText;
  return buildInMemoryFileSystem({
    "/src/codex/.x/create.md": "new\n",
    "/src/codex/.x/update.md": "v2\n",
    "/dest/.x/update.md": "v1\n",
    "/src/codex/.x/unchanged.md": "same\n",
    "/dest/.x/unchanged.md": "same\r\n",
    "/src/codex/.x/conflict.md": "v2\n",
    "/dest/.x/conflict.md": "local\n",
    "/src/codex/.x/converged.md": "v2\n",
    "/dest/.x/converged.md": "v2\n",
    "/src/codex/.x/adopt.md": "same\n",
    "/dest/.x/adopt.md": "same\n",
    "/src/codex/.x/unmanaged.md": "payload\n",
    "/dest/.x/unmanaged.md": "theirs\n",
    "/src/codex/.x/deleted.md": "v1\n",
    [MANIFEST_PATH]: previous({
      ".x/update.md": { layer: "codex", pack: "core", sha256: h("v1\n") },
      ".x/unchanged.md": { layer: "codex", pack: "core", sha256: h("same\n") },
      ".x/conflict.md": { layer: "codex", pack: "python", sha256: h("v1\n") },
      ".x/converged.md": { layer: "codex", pack: "core", sha256: h("v1\n") },
      ".x/deleted.md": { layer: "codex", pack: "python", sha256: h("v1\n") },
      ".x/orphan.md": { layer: "codex", pack: "typescript", sha256: h("o\n") },
    }),
  });
}

/** Payload paths the in-memory adapter recorded as written. */
function payloadWrites(fs: InMemoryPushDownFileSystem): string[] {
  return fs.writtenPaths.filter((path) => path.startsWith("/dest/.x/"));
}

describe("applyPushDownPlan", () => {
  it("writes only create, update and opted-in unmanaged-conflict", () => {
    const fs = decisionTableFs();

    const { applied } = run(fs, codexOnly);

    expect(payloadWrites(fs)).toEqual([
      "/dest/.x/create.md",
      "/dest/.x/update.md",
    ]);
    expect(fs.readTextFile("/dest/.x/conflict.md")).toBe("local\n");
    expect(fs.readTextFile("/dest/.x/unmanaged.md")).toBe("theirs\n");
    expect(fs.isFile("/dest/.x/deleted.md")).toBe(false);
    expect(applied.report.mode).toBe("apply");

    const opted = decisionTableFs();
    run(opted, codexOnly, true);
    expect(payloadWrites(opted)).toEqual([
      "/dest/.x/create.md",
      "/dest/.x/unmanaged.md",
      "/dest/.x/update.md",
    ]);
    expect(opted.readTextFile("/dest/.x/unmanaged.md")).toBe("payload\n");
  });

  it("writes the manifest only when its text changes", () => {
    const fs = buildInMemoryFileSystem({ "/src/codex/.x/a.md": "a\n" }, [
      "/dest",
    ]);

    run(fs, codexOnly);
    const firstWrites = fs.writtenPaths.filter(
      (path) => path === MANIFEST_PATH,
    );
    run(fs, codexOnly);

    expect(firstWrites).toEqual([MANIFEST_PATH]);
    expect(fs.writtenPaths.filter((path) => path === MANIFEST_PATH)).toEqual([
      MANIFEST_PATH,
    ]);
    expect(fs.readTextFile(MANIFEST_PATH).endsWith("\n")).toBe(true);
  });

  it("keeps selection entries of unselected ecosystems", () => {
    const fs = buildInMemoryFileSystem({
      "/src/codex/.x/a.md": "a\n",
      [MANIFEST_PATH]: previous({}, { claude: { packs: ["core", "python"] } }),
    });

    const { manifest } = run(fs, codexOnly);

    expect(manifest.selection).toEqual({
      claude: { packs: ["core", "python"] },
      codex: { packs: ["core"] },
    });
    expect(manifest.payloadVersion).toBe("1.2.3");
  });

  it("leaves file entries of an unselected ecosystem unreported and unchanged", () => {
    const entry = {
      layer: "claude",
      pack: "core",
      sha256: hashPayloadText("c\n"),
    };
    const fs = buildInMemoryFileSystem({
      "/src/codex/.x/a.md": "a\n",
      "/dest/.claude/c.md": "edited\n",
      [MANIFEST_PATH]: previous({ ".claude/c.md": entry }),
    });

    const { applied, manifest } = run(fs, codexOnly);

    expect(applied.report.files.map((file) => file.path)).toEqual([".x/a.md"]);
    expect(manifest.files[".claude/c.md"]).toEqual(entry);
    expect(fs.readTextFile("/dest/.claude/c.md")).toBe("edited\n");
  });

  it("keeps the previous entry for deleted-locally and orphaned", () => {
    const fs = decisionTableFs();
    const before = parseDestinationManifest(fs.readTextFile(MANIFEST_PATH));

    const { manifest, applied } = run(fs, codexOnly);

    expect(manifest.files[".x/deleted.md"]).toEqual(
      before.files[".x/deleted.md"],
    );
    expect(manifest.files[".x/orphan.md"]).toEqual(
      before.files[".x/orphan.md"],
    );
    expect(manifest.files[".x/conflict.md"]).toEqual(
      before.files[".x/conflict.md"],
    );
    expect(manifest.files[".x/update.md"]?.sha256).toBe(
      hashPayloadText("v2\n"),
    );
    expect(manifest.files[".x/converged.md"]?.sha256).toBe(
      hashPayloadText("v2\n"),
    );
    expect(manifest.files[".x/adopt.md"]?.sha256).toBe(
      hashPayloadText("same\n"),
    );
    expect(applied.report.counts).toEqual({
      adopt: 1,
      conflict: 1,
      converged: 1,
      create: 1,
      "deleted-locally": 1,
      orphaned: 1,
      unchanged: 1,
      "unmanaged-conflict": 1,
      update: 1,
    });
    expect(applied.warnings).toHaveLength(3);
  });

  it("records no entry for unmanaged-conflict unless overwriteUnmanaged is true", () => {
    const declined = run(decisionTableFs(), codexOnly).manifest;
    const opted = run(decisionTableFs(), codexOnly, true).manifest;

    expect(declined.files[".x/unmanaged.md"]).toBeUndefined();
    expect(opted.files[".x/unmanaged.md"]?.sha256).toBe(
      hashPayloadText("payload\n"),
    );
  });

  it("records no files entry for merge and excluded paths", () => {
    const fs = buildInMemoryFileSystem({
      "/src/codex/.x/m.json": "m\n",
      "/src/codex/.x/skip.md": "s\n",
      "/dest/.push-down-exclusions": ".x/skip.md\n",
    });
    const layers = (base: InMemoryPushDownFileSystem) => [
      makeTestLayer(base, "codex", {
        mergedPaths: [".x/m.json"],
        mergedDeliveries: [
          { relativePath: ".gitignore", merge: (text) => `${text}g\n` },
        ],
      }),
    ];

    const { manifest, applied } = run(fs, layers);

    expect(manifest.files).toEqual({});
    expect(fs.readTextFile("/dest/.gitignore")).toBe("g\n");
    expect(fs.isFile("/dest/.x/skip.md")).toBe(false);
    const artifact = JSON.parse(
      fs.readTextFile(applied.summary.artifactPath),
    ) as {
      exclusions: { skipped_count: number };
    };
    expect(artifact.exclusions.skipped_count).toBe(1);
  });

  it("writes a merged path only when the merged text differs", () => {
    const fs = buildInMemoryFileSystem({
      "/src/codex/.x/m.txt": "a\nb\n",
      "/dest/.x/m.txt": "local\n",
      "/dest/.gitignore": "keep\n",
    });
    const layers = (base: InMemoryPushDownFileSystem) => [
      makeTestLayer(base, "codex", {
        fs: new LineUnionFileSystem(
          new WriteIfChangedFileSystem(base),
          "/dest/.x/m.txt",
        ),
        mergedPaths: [".x/m.txt"],
        mergedDeliveries: [
          { relativePath: ".gitignore", merge: (text) => text },
        ],
      }),
    ];

    run(fs, layers);
    expect(fs.readTextFile("/dest/.x/m.txt")).toBe("local\na\nb\n");
    expect(
      fs.writtenPaths.filter((path) => path === "/dest/.x/m.txt"),
    ).toHaveLength(1);

    run(fs, layers);
    expect(
      fs.writtenPaths.filter((path) => path === "/dest/.x/m.txt"),
    ).toHaveLength(1);
    expect(fs.writtenPaths).not.toContain("/dest/.gitignore");
  });

  it("adds action next to destination_status in the summary artifact", () => {
    const fs = decisionTableFs();

    const { applied } = run(fs, codexOnly);

    expect(applied.summary.artifactPath).toBe(
      "/dest/artifacts/codex-customizations/push-down-20261118T080000Z.json",
    );
    const artifact = JSON.parse(
      fs.readTextFile(applied.summary.artifactPath),
    ) as {
      files: Array<{
        relative_path: string;
        destination_status: string;
        action: string;
      }>;
    };
    const byPath = new Map(
      artifact.files.map((file) => [file.relative_path, file]),
    );
    expect(byPath.get(".x/create.md")).toMatchObject({
      destination_status: "created",
      action: "create",
    });
    expect(byPath.get(".x/conflict.md")).toMatchObject({
      destination_status: "overwritten",
      action: "conflict",
    });
    expect(
      applied.summary.files.every((file) => file.action !== undefined),
    ).toBe(true);
  });

  it("uses the summary repo root and a default directory when no layer remains", () => {
    const fs = buildInMemoryFileSystem({}, ["/dest", "/src"]);
    const planned = runPushDownPipeline({
      repoRoot: "/src",
      destinationRoot: "/dest",
      fs,
      buildLayers: () => [],
      clock: CLOCK,
    });

    const applied = applyPushDownPlan(planned, { payloadVersion: "1.0.0" });

    expect(applied.summary.artifactPath).toBe(
      "/src/artifacts/push-down/push-down-20261118T080000Z.json",
    );
    expect(applied.summary.finishedAt).toBeInstanceOf(Date);
  });
});
