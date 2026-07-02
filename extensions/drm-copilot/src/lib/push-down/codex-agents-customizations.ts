/**
 * Codex/agents customization push-down publisher.
 *
 * Purpose:
 *     Port `push_down_codex_and_agents_customizations.py`. Provides a dedicated
 *     entry point for publishing the bundled `.codex` and `.agents` trees while
 *     reusing the shared copilot push-down engine.
 *
 * Side effects:
 *     Delegates all filesystem I/O to the injected {@link PushDownFileSystem}
 *     via the shared engine.
 */

import { type PushDownFileSystem } from "./filesystem-adapter";
import {
  type Clock,
  pushDownCustomizations as enginePushDown,
  type PushDownSummary,
} from "./copilot-customizations-engine";
import {
  assertSingleCsharpToolchain,
  type CSharpVariant,
  computePublishedPaths,
  loadPackManifests,
  type MemoryMode,
  type PackManifest,
  resolveManifestPackNames,
  resolveVariantSourcePath,
} from "./codex-pack-selection";

/** Artifact directory for the Codex/agents push-down summary. */
export const ARTIFACT_DIRECTORY = "artifacts/codex-and-agents-customizations";

/** Inlined Codex/agents scoped root folders (enumeration-order contract). */
export const ROOT_FOLDERS: ReadonlyArray<string> = [".codex", ".agents"];
export const PACK_MANIFEST_SUBDIR = "pack-manifests";

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

function resolvePublishedPaths(
  packs: ReadonlySet<string> | null | undefined,
  csharpVariant: CSharpVariant,
  bundleRoot: string,
  fs: PushDownFileSystem,
): ReadonlySet<string> | null {
  const manifestPacks = resolveManifestPackNames(packs ?? null, csharpVariant);
  if (manifestPacks === null || manifestPacks.size === 0) {
    return null;
  }
  const manifests: Map<string, PackManifest> = loadPackManifests(
    joinPosix(bundleRoot, PACK_MANIFEST_SUBDIR),
    manifestPacks,
    fs,
  );
  const published =
    computePublishedPaths(manifestPacks, manifests) ?? new Set<string>();
  assertSingleCsharpToolchain(published, manifestPacks);
  return published;
}

/**
 * Copy the bundled `.codex` and `.agents` trees into the destination workspace.
 *
 * Delegates to the shared engine with the Codex/agents root folders, artifact
 * directory, and the passthrough rewrite (no command-reference rewriting).
 *
 * @param options Entry options (roots, filesystem, optional clock).
 * @returns The completed run summary including the written artifact path.
 * @throws Error When destination validation fails.
 */
export function pushDownCustomizations(
  options: CodexAgentsPushDownOptions,
): PushDownSummary {
  const sourceRoot = options.sourceRoot ?? options.repoRoot;
  const bundleRoot = options.bundleRoot ?? sourceRoot;
  const csharpVariant = options.csharpVariant ?? "modern";
  const publishedPaths = resolvePublishedPaths(
    options.packs,
    csharpVariant,
    bundleRoot,
    options.fs,
  );
  const filteringFs = new CodexFilteringFileSystem(options.fs, {
    sourceRoot,
    bundleRoot,
    publishedPaths,
    csharpVariant,
  });
  void options.memoryMode;
  return enginePushDown({
    repoRoot: options.repoRoot,
    destinationRoot: options.destinationRoot,
    fs: filteringFs,
    sourceRoot,
    ...(options.artifactRoot === undefined
      ? {}
      : { artifactRoot: options.artifactRoot }),
    rootFolders: ROOT_FOLDERS,
    artifactDirectory: ARTIFACT_DIRECTORY,
    rewriteReferences: passthroughRewrite,
    ...(options.clock === undefined ? {} : { clock: options.clock }),
  });
}
