/**
 * Codex/agents customization push-down publisher.
 *
 * Purpose:
 *     Port `push_down_codex_and_agents_customizations.py`. Provides a dedicated
 *     entry point for publishing the bundled `.codex` and `.agents` trees plus
 *     the shared routing config while reusing the copilot push-down engine.
 *
 * Side effects:
 *     Delegates all filesystem I/O to the injected {@link PushDownFileSystem}
 *     via the shared engine.
 */

import { type PushDownFileSystem } from "./filesystem-adapter";
import {
  type Clock,
  type PushDownSummary,
} from "./copilot-customizations-engine";
import {
  type CSharpVariant,
  type MemoryMode,
  resolveVariantSourcePath,
} from "./codex-pack-selection";
import { RoutingMergeFileSystem } from "./claude-routing-merge";
import { LAYER_ROOT_FILES, type PushDownLayer } from "./push-down-layer";
import { resolveLayerPublishedPaths } from "./push-down-pack-resolver";
import { runPushDownPipeline } from "./push-down-pipeline";
import { applyPushDownPlan, UNKNOWN_PAYLOAD_VERSION } from "./push-down-apply";
import { WriteIfChangedFileSystem } from "./push-down-write-if-changed";

/** Artifact directory for the Codex/agents push-down summary. */
export const ARTIFACT_DIRECTORY = "artifacts/codex-and-agents-customizations";

/** Inlined Codex/agents scoped root folders (enumeration-order contract). */
export const ROOT_FOLDERS: ReadonlyArray<string> = [".codex", ".agents"];
export const PACK_MANIFEST_SUBDIR = "pack-manifests";
export const ROUTING_CONFIG_RELATIVE_PATH = "config/orchestration-routing.json";

/**
 * Shared resources published at a destination-relative path.
 *
 * Each pair is `[destination-relative path, resource-relative path]`, where the
 * resource path is resolved against the parent of the Codex bundle root (the
 * extension `resources` directory). The codex-routing modules are stored once
 * under `resources/lib/codex-routing` and published under `.codex/lib`, so the
 * two paths of a pair may differ. Mirrors the Python `VIRTUAL_RESOURCE_PAIRS`.
 */
export const VIRTUAL_RESOURCE_PAIRS: ReadonlyArray<readonly [string, string]> =
  [
    [ROUTING_CONFIG_RELATIVE_PATH, ROUTING_CONFIG_RELATIVE_PATH],
    [
      "config/orchestration-handoff-registry.json",
      "config/orchestration-handoff-registry.json",
    ],
    [
      "config/orchestration-handoff.schema.json",
      "config/orchestration-handoff.schema.json",
    ],
    [
      ".codex/lib/codex-routing/CodexTopology.psm1",
      "lib/codex-routing/CodexTopology.psm1",
    ],
    [
      ".codex/lib/codex-routing/CodexDeployment.psm1",
      "lib/codex-routing/CodexDeployment.psm1",
    ],
    [
      ".codex/lib/codex-routing/CodexDiscoveryRouting.psm1",
      "lib/codex-routing/CodexDiscoveryRouting.psm1",
    ],
  ];

/**
 * Shared helper directories published at a destination-relative directory.
 *
 * Each pair is `[destination-relative directory, resource-relative directory]`.
 * Every file stored under the resource directory publishes under the
 * destination directory with the same name, so a helper library added by a
 * later task needs no per-file entry. Mirrors the Python
 * `VIRTUAL_RESOURCE_DIRECTORIES`.
 */
export const VIRTUAL_RESOURCE_DIRECTORIES: ReadonlyArray<
  readonly [string, string]
> = [
  [".codex/lib/discovery-validation", "lib/discovery-validation"],
  [".codex/lib/epic-wave", "lib/epic-wave"],
  [".codex/lib/development-docs", "lib/development-docs"],
];

/**
 * Destination roots answered from {@link VIRTUAL_RESOURCE_PAIRS} and
 * {@link VIRTUAL_RESOURCE_DIRECTORIES} only.
 */
export const VIRTUAL_ROOT_FOLDERS: ReadonlyArray<string> = [
  "config",
  ".codex/lib/codex-routing",
  ...VIRTUAL_RESOURCE_DIRECTORIES.map(([destination]) => destination),
];

const PUBLISHED_ROOT_FOLDERS: ReadonlyArray<string> = [
  ...ROOT_FOLDERS,
  ...VIRTUAL_ROOT_FOLDERS,
];

/**
 * Passthrough rewrite for payloads that do not need command rewrites.
 *
 * Mirrors the Python `_passthrough_rewrite`: returns the text unchanged with
 * zero rewrite/placeholder counts and no unmatched references.
 *
 * @param text Source text.
 * @returns A tuple `[text, 0, 0, []]`.
 */
export function passthroughRewrite(
  text: string,
): [string, number, number, string[]] {
  return [text, 0, 0, []];
}

/** Options for the Codex/agents {@link pushDownCustomizations} entry point. */
export interface CodexAgentsPushDownOptions {
  readonly repoRoot: string;
  readonly destinationRoot: string;
  readonly fs: PushDownFileSystem;
  readonly sourceRoot?: string;
  readonly artifactRoot?: string;
  readonly clock?: Clock;
  readonly packs?: ReadonlySet<string> | null;
  readonly csharpVariant?: CSharpVariant;
  readonly memoryMode?: MemoryMode;
  readonly bundleRoot?: string;
  /** Overwrite `unmanaged-conflict` files (O-4 opt-in, issue #1029). */
  readonly overwriteUnmanaged?: boolean;
}

function normalizePosix(value: string): string {
  return value.replace(/\\/g, "/").replace(/\/+$/, "");
}

function joinPosix(root: string, relative: string): string {
  const normalizedRoot = normalizePosix(root);
  const normalizedRelative = relative.replace(/\\/g, "/").replace(/^\/+/, "");
  return normalizedRoot === ""
    ? normalizedRelative
    : `${normalizedRoot}/${normalizedRelative}`;
}

function parentPosix(path: string): string {
  const normalized = normalizePosix(path);
  const separatorIndex = normalized.lastIndexOf("/");
  if (separatorIndex < 0) {
    return "";
  }
  return separatorIndex === 0 ? "/" : normalized.slice(0, separatorIndex);
}

function relativeToPosix(path: string, root: string): string | null {
  const normalizedPath = normalizePosix(path);
  const normalizedRoot = normalizePosix(root);
  if (normalizedPath === normalizedRoot) {
    return "";
  }
  const prefix = `${normalizedRoot}/`;
  return normalizedPath.startsWith(prefix)
    ? normalizedPath.slice(prefix.length)
    : null;
}

class CodexFilteringFileSystem implements PushDownFileSystem {
  private readonly sourceRoot: string;
  private readonly bundleRoot: string;
  private readonly publishedPaths: ReadonlySet<string> | null;
  private readonly csharpVariant: CSharpVariant;

  constructor(
    private readonly inner: PushDownFileSystem,
    options: {
      readonly sourceRoot: string;
      readonly bundleRoot: string;
      readonly publishedPaths: ReadonlySet<string> | null;
      readonly csharpVariant: CSharpVariant;
    },
  ) {
    this.sourceRoot = normalizePosix(options.sourceRoot);
    this.bundleRoot = normalizePosix(options.bundleRoot);
    this.publishedPaths = options.publishedPaths;
    this.csharpVariant = options.csharpVariant;
  }

  private sourceRelative(path: string): string | null {
    return relativeToPosix(path, this.sourceRoot);
  }

  private isPackIncluded(path: string): boolean {
    if (this.publishedPaths === null) {
      return true;
    }
    const relative = this.sourceRelative(path);
    return relative === null || this.publishedPaths.has(relative);
  }

  private resolveReadSource(path: string): string {
    if (this.csharpVariant !== "legacy") {
      return path;
    }
    const relative = this.sourceRelative(path);
    if (relative === null) {
      return path;
    }
    const routed = resolveVariantSourcePath(relative, "legacy");
    return routed === relative ? path : joinPosix(this.bundleRoot, routed);
  }

  listFiles(root: string): string[] {
    return this.inner
      .listFiles(root)
      .filter((path) => this.isPackIncluded(path));
  }

  isDir(path: string): boolean {
    return this.inner.isDir(path);
  }

  isFile(path: string): boolean {
    return this.inner.isFile(path);
  }

  readTextFile(path: string): string {
    return this.inner.readTextFile(this.resolveReadSource(path));
  }

  writeTextFile(path: string, content: string): void {
    this.inner.writeTextFile(path, content);
  }

  ensureDir(path: string): void {
    this.inner.ensureDir(path);
  }
}

/**
 * Exposes shared bundle resources at their destination-relative paths.
 *
 * A virtual root is listed from the pair map only, so a physical file beside a
 * mapped path (for example `config/unrelated.json`) is never published, and
 * only pairs whose resource file exists are listed. `isFile` and
 * `readTextFile` are redirected for mapped paths; every other call delegates.
 */
export class RoutingConfigFileSystem implements PushDownFileSystem {
  private readonly virtualPaths: ReadonlyMap<string, string>;
  private readonly virtualRoots: ReadonlySet<string>;

  constructor(
    private readonly inner: PushDownFileSystem,
    options: { readonly sourceRoot: string; readonly bundleRoot: string },
  ) {
    const resourceRoot = parentPosix(options.bundleRoot);
    const virtualPaths = new Map(
      VIRTUAL_RESOURCE_PAIRS.map(
        ([destination, resource]) =>
          [
            joinPosix(options.sourceRoot, destination),
            joinPosix(resourceRoot, resource),
          ] as const,
      ),
    );
    // A mapped helper directory contributes one pair per stored resource file
    // so the whole library publishes under its destination directory.
    for (const [destinationDir, resourceDir] of VIRTUAL_RESOURCE_DIRECTORIES) {
      const resourceDirectory = joinPosix(resourceRoot, resourceDir);
      for (const resourcePath of inner.listFiles(resourceDirectory)) {
        const relative = relativeToPosix(resourcePath, resourceDirectory);
        if (relative !== null && relative !== "") {
          virtualPaths.set(
            joinPosix(joinPosix(options.sourceRoot, destinationDir), relative),
            resourcePath,
          );
        }
      }
    }
    this.virtualPaths = virtualPaths;
    this.virtualRoots = new Set(
      VIRTUAL_ROOT_FOLDERS.map((root) => joinPosix(options.sourceRoot, root)),
    );
  }

  private resolve(path: string): string {
    return this.virtualPaths.get(normalizePosix(path)) ?? path;
  }

  listFiles(root: string): string[] {
    const normalizedRoot = normalizePosix(root);
    if (!this.virtualRoots.has(normalizedRoot)) {
      return this.inner.listFiles(root);
    }
    // The engine orders each root itself, so map order is sufficient here.
    const listed: string[] = [];
    for (const [virtualPath, resourcePath] of this.virtualPaths) {
      if (
        parentPosix(virtualPath) === normalizedRoot &&
        this.inner.isFile(resourcePath)
      ) {
        listed.push(virtualPath);
      }
    }
    return listed;
  }

  isDir(path: string): boolean {
    return this.inner.isDir(path);
  }

  isFile(path: string): boolean {
    return this.inner.isFile(this.resolve(path));
  }

  readTextFile(path: string): string {
    return this.inner.readTextFile(this.resolve(path));
  }

  writeTextFile(path: string, content: string): void {
    this.inner.writeTextFile(path, content);
  }

  ensureDir(path: string): void {
    this.inner.ensureDir(path);
  }
}

/**
 * Build the Codex layer: the filtering and virtual-resource composition over
 * the routing merge and the write-if-changed base (issue #1029).
 *
 * @param options Entry options (roots, filesystem, pack/variant/memory inputs).
 * @returns The Codex layer for the push-down pipeline.
 * @throws ManifestError When a selected manifest is missing or malformed or a
 *   pack name is unknown.
 */
export function buildCodexLayer(
  options: CodexAgentsPushDownOptions,
): PushDownLayer {
  const sourceRoot = options.sourceRoot ?? options.repoRoot;
  const bundleRoot = options.bundleRoot ?? sourceRoot;
  const csharpVariant = options.csharpVariant ?? "modern";
  const resolved = resolveLayerPublishedPaths({
    ecosystem: "codex",
    packs:
      options.packs === undefined || options.packs === null
        ? null
        : [...options.packs],
    csharpVariant,
    memoryMode: options.memoryMode ?? "overwrite",
    bundleRoot,
    fs: options.fs,
  });
  // The routing document is merged like the Claude push-down merges it (D2).
  const merging = new RoutingMergeFileSystem(
    new WriteIfChangedFileSystem(options.fs),
    options.destinationRoot,
    ROUTING_CONFIG_RELATIVE_PATH,
  );
  const filteringFs = new CodexFilteringFileSystem(merging, {
    sourceRoot,
    bundleRoot,
    publishedPaths: resolved.publishedPaths,
    csharpVariant,
  });
  return {
    name: "codex",
    sourceRoot,
    resourcesRoot: parentPosix(bundleRoot),
    rootFolders: PUBLISHED_ROOT_FOLDERS,
    rootFiles: LAYER_ROOT_FILES.codex,
    fs: new RoutingConfigFileSystem(filteringFs, { sourceRoot, bundleRoot }),
    rewrite: passthroughRewrite,
    mergedPaths: [ROUTING_CONFIG_RELATIVE_PATH],
    mergedDeliveries: [],
    ownerPack: resolved.ownerPack,
    selection: resolved.selection,
    artifactDirectory: ARTIFACT_DIRECTORY,
  };
}

/**
 * Copy Codex trees and the shared routing config into the destination workspace.
 *
 * A single-layer adapter over the push-down pipeline (no shared layer).
 *
 * @param options Entry options (roots, filesystem, optional clock).
 * @returns The completed run summary including the written artifact path.
 * @throws Error When destination validation fails.
 */
export function pushDownCustomizations(
  options: CodexAgentsPushDownOptions,
): PushDownSummary {
  const planned = runPushDownPipeline({
    repoRoot: options.repoRoot,
    destinationRoot: options.destinationRoot,
    fs: options.fs,
    buildLayers: () => [buildCodexLayer(options)],
    overwriteUnmanaged: options.overwriteUnmanaged === true,
    ...(options.clock === undefined ? {} : { clock: options.clock }),
  });
  return applyPushDownPlan(planned, {
    payloadVersion: UNKNOWN_PAYLOAD_VERSION,
    artifactRoot: options.artifactRoot ?? options.repoRoot,
    artifactDirectory: ARTIFACT_DIRECTORY,
    ...(options.clock === undefined ? {} : { clock: options.clock }),
  }).summary;
}
