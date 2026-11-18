/**
 * Unit tests for the push-down harness (issue #1029).
 *
 * Every test seeds fresh in-memory bundles through `seedThreeBundles`.
 */

import { parseDestinationManifest } from "../../../src/lib/push-down/push-down-destination-manifest";
import {
  pushDownHarness,
  type PushDownHarnessOptions,
  resolvePayloadVersion,
} from "../../../src/lib/push-down/push-down-harness";
import {
  buildInMemoryFileSystem,
  fixedClock,
  type InMemoryPushDownFileSystem,
} from "./push-down.test-helpers";
import {
  SEED_EXTENSION_ROOT,
  seedThreeBundles,
  snapshotTree,
} from "./push-down-pipeline.test-helpers";

const CLOCK = fixedClock("2026-11-18T09:00:00Z");

/** Harness options for one ecosystem selection. */
function run(
  fs: InMemoryPushDownFileSystem,
  ecosystems: PushDownHarnessOptions["ecosystems"],
  extra: Partial<PushDownHarnessOptions> = {},
) {
  return pushDownHarness({
    extensionRoot: SEED_EXTENSION_ROOT,
    destinationRoot: "/dest",
    fs,
    ecosystems,
    clock: CLOCK,
    listEntries: () => [],
    ...extra,
  });
}

/** Read the destination manifest written by an apply run. */
function manifest(fs: InMemoryPushDownFileSystem) {
  return parseDestinationManifest(
    fs.readTextFile("/dest/.push-down-manifest.json"),
  );
}

describe("pushDownHarness", () => {
  it("builds shared plus the selected ecosystem only", () => {
    const fs = seedThreeBundles();

    const result = run(fs, { codex: {} });

    expect(new Set(result.report.files.map((file) => file.layer))).toEqual(
      new Set(["shared", "codex"]),
    );
    expect(Object.keys(result.report.ecosystems)).toEqual(["codex"]);
    expect(
      result.report.files.find(
        (file) => file.path === ".agents/skills/shared-skill/SKILL.md",
      )?.layer,
    ).toBe("shared");
    expect(fs.listFiles("/dest/.claude")).toEqual([]);
    expect(fs.listFiles("/dest/.github")).toEqual([]);
  });

  it("publishes each layer's root-file pairs", () => {
    const claudeFs = seedThreeBundles();
    const copilotFs = seedThreeBundles();

    const claude = run(claudeFs, { claude: {} });
    const copilot = run(copilotFs, { copilot: {} });

    const rootFiles = (paths: ReadonlyArray<{ path: string; layer: string }>) =>
      paths
        .filter((file) => !file.path.includes("/"))
        .map((file) => [file.path, file.layer]);
    expect(rootFiles(claude.report.files)).toEqual([
      [".gitignore", "claude"],
      [".mcp.json", "claude"],
      ["AGENTS.md", "shared"],
    ]);
    expect(rootFiles(copilot.report.files)).toEqual([["AGENTS.md", "shared"]]);
    expect(
      copilot.report.files.find(
        (file) => file.path === ".github/copilot-instructions.md",
      )?.layer,
    ).toBe("copilot");
    expect(claudeFs.readTextFile("/dest/.mcp.json")).toBe(
      '{"mcpServers": {}}\n',
    );
    expect(copilotFs.readTextFile("/dest/AGENTS.md")).toBe("agents\n");
  });

  it("reuses the recorded packs when packs is omitted", () => {
    const fs = seedThreeBundles();
    run(fs, {
      codex: { packs: ["python"], csharpVariant: "legacy", memoryMode: "skip" },
    });

    const second = run(fs, { codex: {} });

    expect(second.report.ecosystems).toEqual({
      codex: {
        packs: ["core", "python"],
        csharp_variant: "legacy",
        memory_mode: "skip",
      },
    });
    expect(second.report.files.map((file) => file.action)).not.toContain(
      "orphaned",
    );
  });

  it("publishes the full tree with no recorded selection", () => {
    const fs = seedThreeBundles();

    const result = run(fs, { codex: {} });

    expect(result.report.ecosystems).toEqual({
      codex: {
        packs: ["core", "csharp", "powershell", "python", "typescript"],
        csharp_variant: "modern",
        memory_mode: "overwrite",
      },
    });
    expect(result.report.files.map((file) => file.path)).toContain(
      ".agents/skills/python-skill/SKILL.md",
    );
  });

  it("reuses a recorded full-tree selection as the full tree", () => {
    const fs = seedThreeBundles();
    run(fs, { copilot: {} });
    fs.seedFile(
      "/ext/resources/customizations/.github/agents/new.agent.md",
      "new\n",
    );

    const second = run(fs, { copilot: {} });

    expect(
      second.report.files.find(
        (file) => file.path === ".github/agents/new.agent.md",
      )?.action,
    ).toBe("create");
    expect(second.report.ecosystems).toEqual({
      copilot: {
        packs: ["core", "csharp", "powershell", "python", "typescript"],
      },
    });
  });

  it("records the selection with sorted packs including core", () => {
    const fs = seedThreeBundles();

    run(fs, { claude: { packs: ["python"] }, copilot: { packs: ["python"] } });

    expect(manifest(fs).selection).toEqual({
      claude: {
        packs: ["core", "python"],
        csharpVariant: "modern",
        memoryMode: "overwrite",
      },
      copilot: { packs: ["core", "python"] },
    });
    expect(manifest(fs).payloadVersion).toBe("9.8.7");
    expect(manifest(fs).files[".claude/agents/py.md"]?.pack).toBe("python");
    expect(manifest(fs).files["AGENTS.md"]?.layer).toBe("shared");
  });

  it("dry run and apply report identical files and counts", () => {
    const fs = seedThreeBundles();
    const before = snapshotTree(fs, "/dest");

    const dryRun = run(
      fs,
      { copilot: { packs: ["python"] } },
      { dryRun: true },
    );
    expect(snapshotTree(fs, "/dest")).toEqual(before);
    const apply = run(fs, { copilot: { packs: ["python"] } });

    expect(apply.report.files).toEqual(dryRun.report.files);
    expect(apply.report.counts).toEqual(dryRun.report.counts);
    expect(dryRun.summary.artifactPath).toBe("");
  });

  it("reports mode apply for an apply run", () => {
    const fs = seedThreeBundles();

    const dryRun = run(fs, { codex: {} }, { dryRun: true });
    const apply = run(fs, { codex: {} });

    expect(dryRun.report.mode).toBe("dry-run");
    expect(apply.report.mode).toBe("apply");
    expect(apply.summary.artifactPath).toBe(
      "/dest/artifacts/codex-and-agents-customizations/push-down-20261118T090000Z.json",
    );
  });

  it("classifies a CRLF source copy as unchanged on the second apply", () => {
    const fs = seedThreeBundles();
    run(fs, { copilot: {} });

    const second = run(fs, { copilot: {} });

    expect(
      second.report.files.find(
        (file) => file.path === ".github/copilot-instructions.md",
      )?.action,
    ).toBe("unchanged");
    expect(second.report.counts).toEqual({
      merge: 1,
      unchanged: second.report.files.length - 1,
    });
  });

  it("returns exclusions when the destination lists any", () => {
    const fs = seedThreeBundles();
    fs.seedFile("/dest/.push-down-exclusions", "AGENTS.md\n");

    const result = run(fs, { codex: {} });

    expect(result.exclusions?.skipped.map((skip) => skip.relativePath)).toEqual(
      ["AGENTS.md"],
    );
    expect(result.warnings[0]).toContain("AGENTS.md");
    const dryRun = run(fs, { codex: {} }, { dryRun: true });
    expect(dryRun.exclusions?.skipped).toHaveLength(1);
  });

  it("throws when no ecosystem is selected", () => {
    expect(() => run(seedThreeBundles(), {})).toThrow("at least one ecosystem");
  });
});

describe("resolvePayloadVersion", () => {
  it("reads payload_version from package.json", () => {
    expect(resolvePayloadVersion(seedThreeBundles(), SEED_EXTENSION_ROOT)).toBe(
      "9.8.7",
    );
  });

  it.each([
    ["absent", {}],
    ["unparseable", { "/ext/package.json": "{" }],
    ["without a version", { "/ext/package.json": '{"name":"x"}' }],
    ["a JSON null", { "/ext/package.json": "null" }],
  ])("falls back to 0.0.0 when package.json is %s", (_label, files) => {
    expect(resolvePayloadVersion(buildInMemoryFileSystem(files), "/ext")).toBe(
      "0.0.0",
    );
  });
});
