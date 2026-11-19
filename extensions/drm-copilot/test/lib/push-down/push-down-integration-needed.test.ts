/**
 * Tests of the integration-needed writer (issue #1051, S1, S7, S10 to S14).
 *
 * Every test seeds fresh in-memory bundles through `seedThreeBundles` plus the
 * CI bundle, read once, read-only, from the tracked `resources/ci-workflows/`
 * folder. No test writes to disk.
 */

import { readFileSync } from "node:fs";
import { join } from "node:path";

import { type PushDownFileSystem } from "../../../src/lib/push-down/filesystem-adapter";
import { assertDestinationManifestOutsideLayers } from "../../../src/lib/push-down/push-down-ecosystem-registry";
import {
  hashPayloadText,
  parseDestinationManifest,
} from "../../../src/lib/push-down/push-down-destination-manifest";
import {
  pushDownHarness,
  type PushDownHarnessOptions,
} from "../../../src/lib/push-down/push-down-harness";
import {
  collectReportItems,
  PostRunOverlayFileSystem,
} from "../../../src/lib/push-down/push-down-integration-needed";
import { evaluateDestinationConflicts } from "../../../src/lib/push-down-integration/integration-detect";
import { type InMemoryPushDownFileSystem } from "./push-down.test-helpers";
import {
  SEED_EXTENSION_ROOT,
  seedThreeBundles,
  snapshotTree,
} from "./push-down-pipeline.test-helpers";

const RESOURCES = join(__dirname, "..", "..", "..", "resources");
const CI_FILES = [
  "ci-workflows/caller/drm-copilot-ci.template.yml",
  "ci-workflows/caller/jobs/python.yml",
  "ci-workflows/caller/jobs/powershell.yml",
  "ci-workflows/caller/jobs/typescript.yml",
  "ci-workflows/caller/jobs/dotnet.yml",
  "ci-workflows/ci-required-checks.json",
  "ci-workflows/Set-CiRequiredChecks.ps1",
  "ci-workflows/workflows/harness-python.yml",
  "ci-workflows/workflows/harness-powershell.yml",
  "ci-workflows/workflows/harness-typescript.yml",
  "ci-workflows/workflows/harness-dotnet.yml",
] as const;
const CI_TEXT: ReadonlyMap<string, string> = new Map(
  CI_FILES.map((path) => [
    path,
    readFileSync(join(RESOURCES, ...path.split("/")), "utf8"),
  ]),
);
const FILE = ".push-down-integration-needed.json";
const TARGET = `/dest/${FILE}`;
const PYTHON = { copilot: { packs: ["python"] } } as const;

/** Adapter that lists entries in reverse order and delegates everything. */
class ReverseListingFileSystem implements PushDownFileSystem {
  constructor(private readonly inner: InMemoryPushDownFileSystem) {}
  listFiles(root: string): string[] {
    return [...this.inner.listFiles(root)].reverse();
  }
  isDir(path: string): boolean {
    return this.inner.isDir(path);
  }
  isFile(path: string): boolean {
    return this.inner.isFile(path);
  }
  readTextFile(path: string): string {
    return this.inner.readTextFile(path);
  }
  writeTextFile(path: string, content: string): void {
    this.inner.writeTextFile(path, content);
  }
  ensureDir(path: string): void {
    this.inner.ensureDir(path);
  }
}

/** Seed the three bundles plus the CI bundle. */
function seed(): InMemoryPushDownFileSystem {
  const fs = seedThreeBundles();
  for (const [path, text] of CI_TEXT) {
    fs.seedFile(`${SEED_EXTENSION_ROOT}/resources/${path}`, text);
  }
  return fs;
}

/** Run the harness against `/dest`. */
function run(
  fs: PushDownFileSystem,
  ecosystems: PushDownHarnessOptions["ecosystems"],
  extra: Partial<PushDownHarnessOptions> = {},
) {
  return pushDownHarness({
    extensionRoot: SEED_EXTENSION_ROOT,
    destinationRoot: "/dest",
    fs,
    ecosystems,
    listEntries: () => [],
    ...extra,
  });
}

/** Item ids of a run's report. */
function ids(result: ReturnType<typeof run>): string[] {
  return (result.report.integration_needed?.items ?? []).map((item) => item.id);
}

/** Count the writes of the integration-needed file. */
function fileWrites(fs: InMemoryPushDownFileSystem): number {
  return fs.writtenPaths.filter((path) => path === TARGET).length;
}

/** A destination whose ci.yml is named CI, run in reference mode. */
function collisionDestination(): InMemoryPushDownFileSystem {
  const fs = seed();
  fs.seedFile("/dest/.github/workflows/ci.yml", "name: CI\non: push\n");
  return fs;
}

const BUILD_NODE_18 = [
  "name: Build",
  "on: push",
  "jobs:",
  "  b:",
  "    steps:",
  "      - with:",
  "          python-version: '3.9'",
  "          node-version: '18'",
  "",
].join("\n");

/**
 * A collision destination with a node-version 18 workflow and a recorded
 * Codex selection holding the typescript pack, so the harness reference
 * `node-version` applies (the seeded bundles have no typescript pack).
 */
function versionDestination(): InMemoryPushDownFileSystem {
  const fs = collisionDestination();
  fs.seedFile("/dest/.github/workflows/build.yml", BUILD_NODE_18);
  fs.seedFile(
    "/dest/.push-down-manifest.json",
    `${JSON.stringify({
      schema_version: "1.0.0",
      payload_version: "9.8.7",
      selection: { codex: { packs: ["core", "typescript"] } },
      files: {},
    })}\n`,
  );
  return fs;
}

describe("integration-needed writer", () => {
  it("S1 positive: a destination holding the file plans no action for its path", () => {
    const fs = seed();
    fs.seedFile(TARGET, "{}\n");

    const result = run(fs, PYTHON);

    expect(result.report.files.map((file) => file.path)).not.toContain(FILE);
  });

  it.each([
    [
      "a root folder",
      { name: "x", rootFolders: [".push-down-integration"], rootFiles: [] },
    ],
    [
      "a root file",
      {
        name: "x",
        rootFolders: [".x"],
        rootFiles: [[FILE, "x.json"] as const],
      },
    ],
  ])(
    "S1 negative: the root-level guard rejects %s that captures the file path",
    (_label, declaration) => {
      expect(() =>
        assertDestinationManifestOutsideLayers([declaration]),
      ).toThrow(/push-down-integration|reserved root-level path/);
    },
  );

  it("S7 positive: identical content renders identical bytes, whatever the listing order", () => {
    const forward = collisionDestination();
    const reverse = collisionDestination();

    run(forward, PYTHON, { ciWorkflows: "reference" });
    run(new ReverseListingFileSystem(reverse), PYTHON, {
      ciWorkflows: "reference",
    });
    const first = forward.readTextFile(TARGET);
    run(forward, PYTHON);

    expect(reverse.readTextFile(TARGET)).toBe(first);
    expect(forward.readTextFile(TARGET)).toBe(first);
  });

  it("S7 negative: an item stays while its condition holds and leaves once it does not", () => {
    const fs = collisionDestination();
    run(fs, PYTHON, { ciWorkflows: "reference" });

    // Resolution keep-both-workflows: rename the existing workflow only.
    fs.seedFile(
      "/dest/.github/workflows/ci.yml",
      "name: Legacy CI\non: push\n",
    );
    const second = run(fs, PYTHON);

    expect(ids(second)).toEqual([
      "existing-ci-workflow:.github/workflows/ci.yml",
    ]);
    expect(fs.readTextFile(TARGET)).not.toContain("workflow-name-collision");
    expect(fs.readTextFile(TARGET)).toContain("existing-ci-workflow");
  });

  it("S10 positive: raises every push-down kind from its source", () => {
    const fs = versionDestination();
    fs.seedFile("/dest/.github/agents/a.agent.md", "theirs\n");

    const result = run(fs, PYTHON, { ciWorkflows: "reference" });

    expect(ids(result)).toEqual([
      "existing-ci-workflow:.github/workflows/ci.yml",
      "missing-required-check:.github/workflows/drm-copilot-ci.yml#CI Required Gate",
      "unmanaged-conflict:.github/agents/a.agent.md",
      "version-matrix-difference:.github/workflows/build.yml#b.node-version",
      "workflow-name-collision:.github/workflows/ci.yml",
    ]);
  });

  it("S10 positive: maps conflict, unmanaged-conflict and deleted-locally actions with is_hook", () => {
    const base = { layer: "claude", pack: "core", reason: "r" };
    const items = collectReportItems({
      mode: "apply",
      ecosystems: {},
      counts: {},
      files: [
        { ...base, path: ".claude/hooks/h.ps1", action: "conflict" },
        { ...base, path: ".github/hooks/g.json", action: "conflict" },
        { ...base, path: "AGENTS.md", action: "conflict" },
        { ...base, path: "a.md", action: "unmanaged-conflict" },
        { ...base, path: "b.md", action: "deleted-locally" },
        { ...base, path: "c.md", action: "update" },
      ],
    });

    expect(items.map((item) => [item.kind, item.path, item.detail])).toEqual([
      ["destination-edited-file", ".claude/hooks/h.ps1", { is_hook: true }],
      ["destination-edited-file", ".github/hooks/g.json", { is_hook: true }],
      ["destination-edited-file", "AGENTS.md", { is_hook: false }],
      ["unmanaged-conflict", "a.md", {}],
      ["deleted-locally", "b.md", {}],
    ]);
  });

  it("S10 positive: raises destination-edited-file from a real run", () => {
    const fs = seed();
    run(fs, { codex: {} });
    fs.seedFile("/dest/AGENTS.md", "local edit\n");

    const second = run(fs, { codex: {} });

    expect(ids(second)).toEqual(["destination-edited-file:AGENTS.md"]);
    expect(second.report.integration_needed?.items[0]?.detail).toEqual({
      is_hook: false,
    });
  });

  it("S10 negative: a clean destination raises no item and writes no file", () => {
    const fs = seed();

    const result = run(fs, PYTHON, { ciWorkflows: "reference" });

    expect(result.report.integration_needed).toBeUndefined();
    expect(fs.isFile(TARGET)).toBe(false);
  });

  it("S11 positive: a dry run returns the items of the following apply run", () => {
    const dry = run(versionDestination(), PYTHON, {
      ciWorkflows: "reference",
      dryRun: true,
    });
    const applied = run(versionDestination(), PYTHON, {
      ciWorkflows: "reference",
    });

    expect(dry.report.integration_needed?.items).toEqual(
      applied.report.integration_needed?.items,
    );
    expect(ids(dry)).toContain(
      "version-matrix-difference:.github/workflows/build.yml#b.node-version",
    );
  });

  it("S11 negative: the pre-run destination without the overlay yields different items", () => {
    const fs = versionDestination();
    const before = snapshotTree(fs, "/dest");

    const dry = run(fs, PYTHON, { ciWorkflows: "reference", dryRun: true });
    const raw = evaluateDestinationConflicts({
      fs,
      destinationRoot: "/dest",
      extensionRoot: SEED_EXTENSION_ROOT,
      source: "push-down",
    });

    expect(snapshotTree(fs, "/dest")).toEqual(before);
    expect(raw.map((item) => item.id)).not.toEqual(ids(dry));
  });

  it("S11 positive: the overlay lists planned files and refuses writes", () => {
    const overlay = new PostRunOverlayFileSystem(
      seed(),
      new Map([["/dest/new/a.txt", "a\n"]]),
    );

    expect(overlay.listFiles("/dest")).toEqual(["/dest/new/a.txt"]);
    expect(overlay.isDir("/dest/new")).toBe(true);
    expect(overlay.isFile("/dest/new/a.txt")).toBe(true);
    expect(overlay.readTextFile("/dest/new/a.txt")).toBe("a\n");
    expect(() => overlay.writeTextFile("/dest/x")).toThrow(/read-only/);
    expect(() => overlay.ensureDir("/dest/x")).toThrow(/read-only/);
  });

  it("S12 positive: an apply run writes the file once; an identical second run does not rewrite it", () => {
    const fs = collisionDestination();

    run(fs, PYTHON, { ciWorkflows: "reference" });
    run(fs, PYTHON);

    expect(fileWrites(fs)).toBe(1);
    expect(JSON.parse(fs.readTextFile(TARGET))).toMatchObject({
      schema_version: "1.0.0",
      payload_version: "9.8.7",
    });
  });

  it("S12 positive: an empty item list rewrites an existing file with items []", () => {
    const fs = seed();
    run(fs, { codex: {} });
    fs.seedFile("/dest/AGENTS.md", "local edit\n");
    run(fs, { codex: {} });
    expect(fs.readTextFile(TARGET)).toContain("destination-edited-file");

    fs.seedFile("/dest/AGENTS.md", "agents\n");
    const third = run(fs, { codex: {} });

    expect(JSON.parse(fs.readTextFile(TARGET))).toMatchObject({ items: [] });
    expect(third.report.integration_needed).toEqual({
      path: FILE,
      items: [],
      written: true,
    });
  });

  it("S12 negative: a dry run, and an apply run with no item and no file, write nothing", () => {
    const dryFs = collisionDestination();
    const cleanFs = seed();

    run(dryFs, PYTHON, { ciWorkflows: "reference", dryRun: true });
    run(cleanFs, PYTHON);

    expect(fileWrites(dryFs)).toBe(0);
    expect(dryFs.isFile(TARGET)).toBe(false);
    expect(fileWrites(cleanFs)).toBe(0);
  });

  it("S13 positive: the file is never a manifest entry", () => {
    const fs = collisionDestination();

    run(fs, PYTHON, { ciWorkflows: "reference" });
    run(fs, PYTHON);

    const manifest = parseDestinationManifest(
      fs.readTextFile("/dest/.push-down-manifest.json"),
    );
    expect(fs.isFile(TARGET)).toBe(true);
    expect(Object.keys(manifest.files)).not.toContain(FILE);
  });

  it("S13 negative: a manifest entry would carry the file hash, and none does", () => {
    const fs = collisionDestination();
    run(fs, PYTHON, { ciWorkflows: "reference" });

    const manifest = parseDestinationManifest(
      fs.readTextFile("/dest/.push-down-manifest.json"),
    );
    const hash = hashPayloadText(fs.readTextFile(TARGET));

    expect(
      Object.values(manifest.files).map((entry) => entry.sha256),
    ).not.toContain(hash);
  });

  it("S14 positive: both modes return path, items and written in push_down_report", () => {
    const dry = run(collisionDestination(), PYTHON, {
      ciWorkflows: "reference",
      dryRun: true,
    });
    const applied = run(collisionDestination(), PYTHON, {
      ciWorkflows: "reference",
    });

    expect(dry.report.integration_needed).toMatchObject({
      path: FILE,
      written: false,
    });
    expect(applied.report.integration_needed).toMatchObject({
      path: FILE,
      written: true,
    });
    expect(applied.report.integration_needed?.items.length).toBeGreaterThan(0);
    expect(applied.report.mode).toBe("apply");
  });

  it("S14 negative: a run with no item and no file returns a report without the key", () => {
    const result = run(seed(), PYTHON);

    expect(Object.keys(result.report).sort()).toEqual([
      "counts",
      "ecosystems",
      "files",
      "mode",
    ]);
  });
});
