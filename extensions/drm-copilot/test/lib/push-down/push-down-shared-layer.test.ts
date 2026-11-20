/**
 * Tests for the shared push-down layer (issue #1029, D15 and D16).
 *
 * The in-memory cases build a fresh adapter per test. The real-tree cases read
 * tracked repository files only (`config/harness-parity-matrix.json` and the
 * Codex bundle) and write nothing.
 */

import * as nodePath from "node:path";

import { ManifestError } from "../../../src/lib/push-down/claude-pack-selection";
import { RealPushDownFileSystem } from "../../../src/lib/push-down/filesystem-adapter";
import { runPushDownPipeline } from "../../../src/lib/push-down/push-down-pipeline";
import {
  buildSharedLayer,
  SHARED_LAYER_ECOSYSTEM_EXCEPTIONS,
} from "../../../src/lib/push-down/push-down-shared-layer";
import { buildInMemoryFileSystem } from "./push-down.test-helpers";

const BUNDLE = "/ext/resources/codex-and-agents-customizations";
const REPO_ROOT = nodePath
  .resolve(__dirname, "../../../../..")
  .replace(/\\/g, "/");
const REAL_BUNDLE = `${REPO_ROOT}/extensions/drm-copilot/resources/codex-and-agents-customizations`;
const real = new RealPushDownFileSystem();

/** Code-point comparator for path lists. */
function byCodePoint(left: string, right: string): number {
  return left < right ? -1 : left > right ? 1 : 0;
}

/** Shared-skill names of the parity matrix (D15). */
function sharedSkillNames(): string[] {
  const matrix = JSON.parse(
    real.readTextFile(`${REPO_ROOT}/config/harness-parity-matrix.json`),
  ) as { features: Array<Record<string, unknown>> };
  return matrix.features
    .filter(
      (entry) =>
        entry["kind"] === "skill" &&
        entry["ecosystem"] === "codex" &&
        entry["disposition"] === "shared",
    )
    .map((entry) => String(entry["name"]));
}

/** Every bundle file of every shared skill, bundle-relative. */
function sharedSkillFiles(): string[] {
  return sharedSkillNames().flatMap((name) =>
    real
      .listFiles(`${REAL_BUNDLE}/.agents/skills/${name}`)
      .map((path) => path.slice(REAL_BUNDLE.length + 1)),
  );
}

/** Paths listed by one real Codex pack manifest. */
function manifestPaths(name: string): string[] {
  const manifest = JSON.parse(
    real.readTextFile(`${REAL_BUNDLE}/pack-manifests/${name}.json`),
  ) as { paths: string[] };
  return manifest.paths;
}

/** Seed a minimal Codex bundle with a shared manifest. */
function seededBundle(sharedPaths: ReadonlyArray<string>) {
  return buildInMemoryFileSystem(
    {
      [`${BUNDLE}/.agents/skills/shared-skill/SKILL.md`]: "shared\n",
      [`${BUNDLE}/.agents/skills/codex-only/SKILL.md`]: "codex\n",
      [`${BUNDLE}/AGENTS.md`]: "agents\n",
      [`${BUNDLE}/pack-manifests/shared.json`]: JSON.stringify({
        name: "shared",
        label: "Shared layer",
        paths: sharedPaths,
      }),
      "/ext/resources/config/orchestration-routing.json": '{"routes":[]}\n',
    },
    ["/dest"],
  );
}

describe("buildSharedLayer", () => {
  it("enumerates exactly the shared manifest paths", () => {
    const fs = seededBundle([
      ".agents/skills/shared-skill/SKILL.md",
      "AGENTS.md",
      "config/orchestration-routing.json",
    ]);

    const result = runPushDownPipeline({
      repoRoot: BUNDLE,
      destinationRoot: "/dest",
      fs,
      buildLayers: () => [
        buildSharedLayer({
          bundleRoot: BUNDLE,
          resourcesRoot: "/ext/resources",
          destinationRoot: "/dest",
          fs,
          artifactDirectory: "artifacts/codex-and-agents-customizations",
        }),
      ],
      dryRun: true,
    });

    expect(
      result.report.files.map((file) => [
        file.path,
        file.layer,
        file.pack,
        file.action,
      ]),
    ).toEqual([
      [".agents/skills/shared-skill/SKILL.md", "shared", "core", "create"],
      ["AGENTS.md", "shared", "core", "create"],
      ["config/orchestration-routing.json", "shared", "core", "merge"],
    ]);
    expect(result.report.ecosystems).toEqual({});
  });

  it("rejects a shared manifest that lists an ecosystem-layer exception", () => {
    const exception = SHARED_LAYER_ECOSYSTEM_EXCEPTIONS[0]?.path ?? "";
    const fs = seededBundle(["AGENTS.md", exception]);

    expect(() =>
      buildSharedLayer({
        bundleRoot: BUNDLE,
        resourcesRoot: "/ext/resources",
        destinationRoot: "/dest",
        fs,
        artifactDirectory: "artifacts/x",
      }),
    ).toThrow(ManifestError);
  });
});

describe("shared layer against the real tree", () => {
  it("shared.json paths equal the D15 shared set", () => {
    const exceptions = new Set(
      SHARED_LAYER_ECOSYSTEM_EXCEPTIONS.map((entry) => entry.path),
    );
    const expected = [
      ...sharedSkillFiles().filter((path) => !exceptions.has(path)),
      "AGENTS.md",
      "config/orchestration-routing.json",
      "config/orchestration-handoff-registry.json",
      "config/orchestration-handoff.schema.json",
    ].sort(byCodePoint);

    expect(expected.length).toBeGreaterThan(100);
    expect([...manifestPaths("shared")].sort(byCodePoint)).toEqual(expected);
  });

  it("keeps each ecosystem-layer exception in Codex core.json with a reason", () => {
    const sharedFolders = sharedSkillNames().map(
      (name) => `.agents/skills/${name}/`,
    );
    const core = new Set(manifestPaths("core"));

    expect(SHARED_LAYER_ECOSYSTEM_EXCEPTIONS).toHaveLength(3);
    for (const exception of SHARED_LAYER_ECOSYSTEM_EXCEPTIONS) {
      expect(
        sharedFolders.some((folder) => exception.path.startsWith(folder)),
      ).toBe(true);
      expect(real.isFile(`${REAL_BUNDLE}/${exception.path}`)).toBe(true);
      expect(core.has(exception.path)).toBe(true);
      expect(exception.layer).toBe("codex");
      expect(exception.reason.trim()).not.toBe("");
    }
    expect(Object.isFrozen(SHARED_LAYER_ECOSYSTEM_EXCEPTIONS)).toBe(true);
  });

  it("finds no .py or .ts file in a shared skill folder", () => {
    const codeFiles = sharedSkillFiles().filter((path) =>
      /\.(py|ts)$/.test(path),
    );

    expect(sharedSkillFiles().length).toBeGreaterThan(100);
    expect(codeFiles).toEqual([]);
  });
});
