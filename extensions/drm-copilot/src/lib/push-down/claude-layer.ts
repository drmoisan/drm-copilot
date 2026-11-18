/**
 * Claude layer composition of the unified push-down pipeline (issue #1029).
 *
 * Purpose:
 *     Compose the Claude ecosystem layer from the pinned Claude declarations,
 *     which the caller passes in (D10): pack resolution, the destination-write
 *     decorator fold over the write-if-changed base, the filtering
 *     `ExcludingFileSystem`, the merged paths, the `.gitignore` merged delivery,
 *     the Claude root files, and the selection record.
 *
 * Invariants / Constraints:
 *     This module imports nothing from `claude-customizations.ts`, so the
 *     pinned declarations stay where the static parity tests read them.
 */

import { type PushDownFileSystem } from "./filesystem-adapter";
import { type DirectoryLister } from "./claude-blast-radius-derive";
import { ExcludingFileSystem } from "./claude-filesystem-adapter";
import {
  CLAUDE_GITIGNORE_RELATIVE_PATH,
  mergeClaudeGitignore,
} from "./claude-gitignore-merge";
import { type CSharpVariant, type MemoryMode } from "./claude-pack-selection";
import { LAYER_ROOT_FILES, type PushDownLayer } from "./push-down-layer";
import { resolveLayerPublishedPaths } from "./push-down-pack-resolver";
import { type RewriteFunction } from "./reference-rewrites";
import { WriteIfChangedFileSystem } from "./push-down-write-if-changed";

/** Structural form of one destination-side write decorator. */
export interface ClaudeLayerWriteDecorator {
  readonly relativePath: string;
  wrap(
    inner: PushDownFileSystem,
    destinationRoot: string,
    options: { readonly listEntries?: DirectoryLister },
  ): PushDownFileSystem;
}

/** The pinned Claude declarations the layer is composed from. */
export interface ClaudeLayerDeclarations {
  readonly rootFolders: ReadonlyArray<string>;
  readonly excludedRelativePaths: ReadonlyArray<string>;
  readonly mergedRelativePaths: ReadonlyArray<string>;
  readonly destinationWriteDecorators: ReadonlyArray<ClaudeLayerWriteDecorator>;
  readonly artifactDirectory: string;
  /** Text rewrite (the Claude passthrough). */
  readonly rewrite: RewriteFunction;
}

/** Run inputs of {@link composeClaudeLayer}. */
export interface ClaudeLayerOptions {
  /** Repository root used to resolve the excluded paths. */
  readonly repoRoot: string;
  /** Root the `.claude` and `config` roots are enumerated under. */
  readonly sourceRoot: string;
  /** Bundle root holding pack manifests and the legacy variant subtree. */
  readonly bundleRoot: string;
  /** Extension `resources` root for the Claude root files. */
  readonly resourcesRoot: string;
  readonly destinationRoot: string;
  /** Raw destination and source adapter. */
  readonly fs: PushDownFileSystem;
  /** Selected packs, or `null` for the full tree. */
  readonly packs: ReadonlyArray<string> | null;
  readonly csharpVariant: CSharpVariant;
  readonly memoryMode: MemoryMode;
  /** Destination directory lister for the blast-radius derivation. */
  readonly listEntries?: DirectoryLister;
}

/**
 * Compose the Claude layer.
 *
 * @param declarations Pinned Claude declarations.
 * @param options Roots, adapter, and selection inputs.
 * @returns The Claude layer.
 * @throws ManifestError When a selected manifest is missing or malformed or
 *   both C# variants are selected.
 */
export function composeClaudeLayer(
  declarations: ClaudeLayerDeclarations,
  options: ClaudeLayerOptions,
): PushDownLayer {
  const resolved = resolveLayerPublishedPaths({
    ecosystem: "claude",
    packs: options.packs,
    csharpVariant: options.csharpVariant,
    memoryMode: options.memoryMode,
    bundleRoot: options.bundleRoot,
    fs: options.fs,
  });
  const decoratorOptions =
    options.listEntries === undefined
      ? {}
      : { listEntries: options.listEntries };
  const decorated =
    declarations.destinationWriteDecorators.reduce<PushDownFileSystem>(
      (inner, decorator) =>
        decorator.wrap(inner, options.destinationRoot, decoratorOptions),
      new WriteIfChangedFileSystem(options.fs),
    );
  const excluding = new ExcludingFileSystem(
    decorated,
    options.repoRoot,
    declarations.excludedRelativePaths,
    {
      sourceRoot: options.sourceRoot,
      destinationRoot: options.destinationRoot,
      publishedPaths: resolved.publishedPaths,
      csharpVariant: options.csharpVariant,
      memoryMode: options.memoryMode,
      variantRoot: options.bundleRoot,
    },
  );
  return {
    name: "claude",
    sourceRoot: options.sourceRoot,
    resourcesRoot: options.resourcesRoot,
    rootFolders: declarations.rootFolders,
    rootFiles: LAYER_ROOT_FILES.claude,
    fs: excluding,
    rewrite: declarations.rewrite,
    mergedPaths: declarations.mergedRelativePaths,
    mergedDeliveries: [
      {
        relativePath: CLAUDE_GITIGNORE_RELATIVE_PATH,
        merge: mergeClaudeGitignore,
      },
    ],
    ownerPack: resolved.ownerPack,
    selection: resolved.selection,
    artifactDirectory: declarations.artifactDirectory,
  };
}
