/**
 * Test helpers for the unified push-down pipeline (issue #1029).
 *
 * Every helper builds fresh in-memory state; no helper touches the disk or
 * keeps module-level mutable state.
 */

import { type PushDownFileSystem } from "../../../src/lib/push-down/filesystem-adapter";
import { passthroughRewrite } from "../../../src/lib/push-down/codex-agents-customizations";
import {
  type LayerName,
  type PushDownLayer,
} from "../../../src/lib/push-down/push-down-layer";
import { WriteIfChangedFileSystem } from "../../../src/lib/push-down/push-down-write-if-changed";
import {
  buildInMemoryFileSystem,
  type InMemoryPushDownFileSystem,
} from "./push-down.test-helpers";

/**
 * Decorator that merges one destination path as a union of unique lines, so
 * tests can observe a merged write without the routing or blast-radius rules.
 */
export class LineUnionFileSystem implements PushDownFileSystem {
  /**
   * @param inner Adapter performing the I/O.
   * @param targetPath Absolute destination path merged instead of copied.
   */
  constructor(
    private readonly inner: PushDownFileSystem,
    private readonly targetPath: string,
  ) {}

  listFiles(root: string): string[] {
    return this.inner.listFiles(root);
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

  ensureDir(path: string): void {
    this.inner.ensureDir(path);
  }

  writeTextFile(path: string, content: string): void {
    if (path !== this.targetPath || !this.inner.isFile(path)) {
      this.inner.writeTextFile(path, content);
      return;
    }
    const lines = this.inner.readTextFile(path).split("\n").filter(Boolean);
    for (const line of content.split("\n").filter(Boolean)) {
      if (!lines.includes(line)) {
        lines.push(line);
      }
    }
    this.inner.writeTextFile(path, `${lines.join("\n")}\n`);
  }
}

/**
 * Build an in-memory layer over a base adapter.
 *
 * @param base Raw in-memory destination and source adapter.
 * @param name Layer name.
 * @param overrides Fields to replace.
 * @returns The layer.
 */
export function makeTestLayer(
  base: PushDownFileSystem,
  name: LayerName,
  overrides: Partial<PushDownLayer> = {},
): PushDownLayer {
  return {
    name,
    sourceRoot: `/src/${name}`,
    resourcesRoot: "/res",
    rootFolders: [".x"],
    rootFiles: [],
    fs: new WriteIfChangedFileSystem(base),
    rewrite: passthroughRewrite,
    mergedPaths: [],
    mergedDeliveries: [],
    ownerPack: () => "core",
    selection: name === "shared" ? undefined : { packs: ["core"] },
    artifactDirectory: `artifacts/${name}-customizations`,
    ...overrides,
  };
}

/** Extension root used by the in-memory three-bundle seeds. */
export const SEED_EXTENSION_ROOT = "/ext";

/** Codex bundle root of the seeds. */
export const SEED_CODEX_BUNDLE = `${SEED_EXTENSION_ROOT}/resources/codex-and-agents-customizations`;

/** Paths of the seeded shared layer. */
export const SEED_SHARED_PATHS: ReadonlyArray<string> = [
  ".agents/skills/shared-skill/SKILL.md",
  "AGENTS.md",
  "config/orchestration-routing.json",
];

/**
 * Seed the shared-layer manifest `shared.json` into a Codex bundle.
 *
 * @param fs In-memory adapter to seed.
 * @param paths Shared paths to list; defaults to {@link SEED_SHARED_PATHS}.
 * @param bundleRoot Codex bundle root; defaults to {@link SEED_CODEX_BUNDLE}.
 */
export function seedSharedLayerManifest(
  fs: InMemoryPushDownFileSystem,
  paths: ReadonlyArray<string> = SEED_SHARED_PATHS,
  bundleRoot: string = SEED_CODEX_BUNDLE,
): void {
  fs.seedFile(
    `${bundleRoot}/pack-manifests/shared.json`,
    JSON.stringify({ name: "shared", label: "Shared layer", paths }),
  );
}

/** Render one pack manifest. */
function packManifest(name: string, paths: ReadonlyArray<string>): string {
  return JSON.stringify({ name, label: name, paths });
}

/**
 * Build an in-memory adapter seeded with minimal Claude, Codex, and Copilot
 * bundles, the shared manifest, `package.json`, and an empty `/dest`.
 *
 * The Copilot instructions file is seeded with CRLF line endings built in
 * code, so the CRLF path is exercised without a committed CRLF fixture.
 *
 * @returns The seeded adapter.
 */
export function seedThreeBundles(): InMemoryPushDownFileSystem {
  const ext = SEED_EXTENSION_ROOT;
  const res = `${ext}/resources`;
  const fs = buildInMemoryFileSystem(
    {
      [`${ext}/package.json`]: JSON.stringify({ version: "9.8.7" }),
      // Codex bundle and the shared layer.
      [`${SEED_CODEX_BUNDLE}/AGENTS.md`]: "agents\n",
      [`${SEED_CODEX_BUNDLE}/.agents/skills/shared-skill/SKILL.md`]: "shared\n",
      [`${SEED_CODEX_BUNDLE}/.agents/skills/codex-only/SKILL.md`]:
        "codex skill\n",
      [`${SEED_CODEX_BUNDLE}/.agents/skills/python-skill/SKILL.md`]:
        "py skill\n",
      [`${SEED_CODEX_BUNDLE}/.codex/agents/a.toml`]: "a = 1\n",
      [`${SEED_CODEX_BUNDLE}/pack-manifests/core.json`]: packManifest("core", [
        ".agents/skills/codex-only/SKILL.md",
        ".codex/agents/a.toml",
      ]),
      [`${SEED_CODEX_BUNDLE}/pack-manifests/python.json`]: packManifest(
        "python",
        [".agents/skills/python-skill/SKILL.md"],
      ),
      [`${res}/config/orchestration-routing.json`]: '{"routes": []}\n',
      // Claude bundle and its root file.
      [`${res}/claude-customizations/.claude/agents/a.md`]: "claude agent\n",
      [`${res}/claude-customizations/.claude/agents/py.md`]: "claude python\n",
      [`${res}/claude-customizations/pack-manifests/core.json`]: packManifest(
        "core",
        [".claude/agents/a.md"],
      ),
      [`${res}/claude-customizations/pack-manifests/python.json`]: packManifest(
        "python",
        [".claude/agents/py.md"],
      ),
      [`${res}/claude-dir-customizations/.mcp.json`]: '{"mcpServers": {}}\n',
      // Copilot bundle and its root file.
      [`${res}/customizations/.github/agents/a.agent.md`]: "copilot agent\n",
      [`${res}/customizations/.github/agents/python-x.agent.md`]:
        "copilot python\n",
      [`${res}/customizations/.github/copilot-instructions.md`]: [
        "instructions",
        "",
      ].join("\r\n"),
      [`${res}/customizations/pack-manifests/core.json`]: packManifest("core", [
        ".github/agents/a.agent.md",
        ".github/copilot-instructions.md",
      ]),
      [`${res}/customizations/pack-manifests/python.json`]: packManifest(
        "python",
        [".github/agents/python-x.agent.md"],
      ),
    },
    ["/dest"],
  );
  seedSharedLayerManifest(fs);
  return fs;
}

/**
 * Snapshot every file under a root as a path-to-text record.
 *
 * @param fs Adapter to read.
 * @param root Root to snapshot.
 * @returns The snapshot.
 */
export function snapshotTree(
  fs: PushDownFileSystem,
  root: string,
): Record<string, string> {
  const snapshot: Record<string, string> = {};
  for (const path of fs.listFiles(root)) {
    snapshot[path] = fs.readTextFile(path);
  }
  return snapshot;
}
