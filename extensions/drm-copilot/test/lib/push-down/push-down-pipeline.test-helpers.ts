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
