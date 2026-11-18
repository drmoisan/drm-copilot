/**
 * Claude customization push-down publisher.
 *
 * Purpose:
 *     Port `push_down_claude_customizations.py`. Provides the dedicated entry
 *     point for publishing the bundled `.claude` tree, composing the filtering
 *     {@link ExcludingFileSystem} over the injected adapter and delegating the
 *     copy to the shared engine. Settings-local configuration is excluded;
 *     agent-memory files are filtered by scope and memory mode; pack selection
 *     restricts the published set; the C# variant routes canonical reads.
 *
 * Side effects:
 *     Reads source files and writes destination files plus the summary artifact
 *     through the adapter (via the engine).
 */

import { type PushDownFileSystem } from "./filesystem-adapter";
import {
  type Clock,
  type PushDownSummary,
} from "./copilot-customizations-engine";
import { RoutingMergeFileSystem } from "./claude-routing-merge";
import {
  BLAST_RADIUS_RELATIVE_PATH,
  BlastRadiusDeriveFileSystem,
  type DirectoryLister,
} from "./claude-blast-radius-derive";
import { BlastRadiusOverlayFileSystem } from "./claude-blast-radius-overlay";
import {
  assertSingleCsharpToolchain,
  computePublishedPaths,
  type CSharpVariant,
  loadPackManifests,
  type MemoryMode,
  type PackManifest,
} from "./claude-pack-selection";
import {
  assertManifestPathIsRootLevel,
  EXCLUSION_MANIFEST_RELATIVE_PATH,
} from "./claude-exclusion-manifest";
import { type ExclusionReport } from "./claude-exclusion-filter";
import { composeClaudeLayer } from "./claude-layer";
import { type PushDownLayer } from "./push-down-layer";
import { runPushDownPipeline } from "./push-down-pipeline";
import { applyPushDownPlan, UNKNOWN_PAYLOAD_VERSION } from "./push-down-apply";

/** Artifact directory for the Claude push-down summary. */
export const ARTIFACT_DIRECTORY = "artifacts/claude-customizations";

/**
 * Inlined Claude scoped root folders (enumeration-order contract).
 *
 * `config` is published alongside `.claude` because the destination-runtime
 * parallel surface reads `config/orchestration-routing.json` and
 * `config/blast-radius.json`, and a workspace that received only `.claude`
 * cannot resolve either. Enumeration order is the summary-artifact contract, so
 * `config` is appended after `.claude` rather than inserted before it.
 */
export const ROOT_FOLDERS: ReadonlyArray<string> = [".claude", "config"];

// The manifest must sit outside every published root so it is never enumerated.
assertManifestPathIsRootLevel(EXCLUSION_MANIFEST_RELATIVE_PATH, ROOT_FOLDERS);

/**
 * Destination-relative path of the routing document merged on every push.
 *
 * Destination-side writes are shaped by the {@link DESTINATION_WRITE_DECORATORS}
 * registry, and {@link MERGED_RELATIVE_PATHS} lists the two paths it handles.
 * `config/orchestration-routing.json` (this path) is merged by
 * {@link RoutingMergeFileSystem} so locally added routes survive a push.
 * `config/blast-radius.json` is derived by {@link BlastRadiusDeriveFileSystem}
 * from the destination's own layout and then composed by
 * {@link BlastRadiusOverlayFileSystem} with the destination-owned overlay
 * `config/blast-radius.local.json` (issue #508). The overlay is only read: it is
 * excluded from publication and never written. Every other published file is a
 * plain overwrite.
 */
export const ROUTING_MERGE_RELATIVE_PATH = "config/orchestration-routing.json";

/** Repo-relative host-specific paths excluded from push-down. */
export const EXCLUDED_RELATIVE_PATHS: ReadonlyArray<string> = [
  ".claude/settings.local.json",
  "config/blast-radius.local.json",
  ".claude/release-commit-allowance.json",
];

/** One destination-side write decorator registered for a relative path. */
export interface DestinationWriteDecorator {
  /** Destination-relative path whose write the decorator shapes. */
  readonly relativePath: string;

  /**
   * Wrap an adapter with this decorator.
   *
   * @param inner Adapter the decorator delegates to.
   * @param destinationRoot Destination workspace root.
   * @param options Optional destination-layout lister for the derivation.
   * @returns The decorated adapter.
   */
  wrap(
    inner: PushDownFileSystem,
    destinationRoot: string,
    options: { readonly listEntries?: DirectoryLister },
  ): PushDownFileSystem;
}

/**
 * Destination-side write decorators, innermost first (issue #508).
 *
 * The chain is built by folding this array over the real adapter, so the last
 * entry is outermost: the derivation runs first, the overlay composes onto the
 * derived document, and the routing merge sits closest to the adapter.
 */
export const DESTINATION_WRITE_DECORATORS: ReadonlyArray<DestinationWriteDecorator> =
  [
    {
      relativePath: ROUTING_MERGE_RELATIVE_PATH,
      wrap: (inner, destinationRoot) =>
        new RoutingMergeFileSystem(
          inner,
          destinationRoot,
          ROUTING_MERGE_RELATIVE_PATH,
        ),
    },
    {
      relativePath: BLAST_RADIUS_RELATIVE_PATH,
      wrap: (inner, destinationRoot) =>
        new BlastRadiusOverlayFileSystem(inner, destinationRoot),
    },
    {
      relativePath: BLAST_RADIUS_RELATIVE_PATH,
      wrap: (inner, destinationRoot, { listEntries }) =>
        listEntries === undefined
          ? new BlastRadiusDeriveFileSystem(inner, destinationRoot)
          : new BlastRadiusDeriveFileSystem(
              inner,
              destinationRoot,
              listEntries,
            ),
    },
  ];

/** Destination-relative paths shaped by the decorator registry. */
export const MERGED_RELATIVE_PATHS: ReadonlyArray<string> = [
  "config/orchestration-routing.json",
  "config/blast-radius.json",
];

/** Repo-relative location of the bundle root that holds manifests/variants. */
export const BUNDLE_ROOT_RELATIVE_DIR =
  "extensions/drm-copilot/resources/claude-customizations";

/** Subdirectory under the bundle root containing pack-manifest JSON files. */
export const PACK_MANIFEST_SUBDIR = "pack-manifests";

/** Valid CLI choices for the C# variant argument. */
export const CSHARP_VARIANT_CHOICES: ReadonlyArray<string> = [
  "modern",
  "legacy",
];

/** Valid CLI choices for the memory-mode argument. */
export const MEMORY_MODE_CHOICES: ReadonlyArray<string> = [
  "overwrite",
  "merge",
  "skip",
];

export { ManifestError } from "./claude-pack-selection";
export {
  RoutingMergeError,
  RoutingMergeFileSystem,
} from "./claude-routing-merge";
export {
  BlastRadiusDeriveError,
  BlastRadiusDeriveFileSystem,
  BlastRadiusGuardError,
  type DirectoryLister,
} from "./claude-blast-radius-derive";
export {
  BLAST_RADIUS_OVERLAY_RELATIVE_PATH,
  BlastRadiusOverlayError,
  BlastRadiusOverlayFileSystem,
  composeBlastRadiusOverlay,
} from "./claude-blast-radius-overlay";
export { type PushDownSummary, type CSharpVariant, type MemoryMode };
export {
  EXCLUSION_MANIFEST_RELATIVE_PATH,
  ExclusionManifestError,
  type SkippedPath,
} from "./claude-exclusion-manifest";
export {
  ExclusionViolationError,
  type ExclusionReport,
} from "./claude-exclusion-filter";

/** Engine summary plus the exclusion report, present only with a manifest. */
export interface ClaudePushDownSummary extends PushDownSummary {
  readonly exclusions?: ExclusionReport;
}

/**
 * Passthrough rewrite for `.claude` content (no command rewrites).
 *
 * @param text Source text.
 * @returns A tuple `[text, 0, 0, []]`.
 */
export function passthroughRewrite(
  text: string,
): [string, number, number, string[]] {
  return [text, 0, 0, []];
}

/**
 * Join two POSIX path fragments with a single forward slash.
 *
 * @param root Base POSIX path.
 * @param relative Relative POSIX path fragment.
 * @returns The combined POSIX path.
 */
function joinPosix(root: string, relative: string): string {
  const normalizedRoot = root.replace(/\\/g, "/").replace(/\/+$/, "");
  const normalizedRelative = relative.replace(/\\/g, "/").replace(/^\/+/, "");
  return normalizedRoot === ""
    ? normalizedRelative
    : `${normalizedRoot}/${normalizedRelative}`;
}

/**
 * Parse a comma-separated `--packs` value into a normalized pack-name set.
 *
 * @param packsValue The raw comma-separated value, or null/undefined when the
 *   flag was omitted.
 * @returns The set of non-empty, trimmed pack names, or null when the value was
 *   omitted or contained only empty entries (the publish-everything default).
 */
export function parsePacksArgument(
  packsValue: string | null | undefined,
): ReadonlySet<string> | null {
  if (packsValue === null || packsValue === undefined) {
    return null;
  }
  // Trim whitespace and drop empty entries so trailing commas do not produce
  // empty pack names.
  const names = new Set<string>();
  for (const entry of packsValue.split(",")) {
    const trimmed = entry.trim();
    if (trimmed !== "") {
      names.add(trimmed);
    }
  }
  return names.size === 0 ? null : names;
}

/**
 * Compute the published `.claude`-relative path set for a pack selection.
 *
 * Returns null when no pack selection was supplied (publish everything, no
 * manifest read). Otherwise loads manifests, computes the union (always
 * including core), and asserts C# mutual exclusion.
 *
 * @param packs Selected pack names, or null/empty for the default.
 * @param bundleRoot Bundle root containing the `pack-manifests` subdirectory.
 * @param fs Adapter used to read the manifest files.
 * @returns The union path set, or null for the publish-everything default.
 * @throws ManifestError When a manifest is missing/malformed or both C# variants
 *   are selected.
 */
export function resolvePublishedPaths(
  packs: ReadonlySet<string> | null,
  bundleRoot: string,
  fs: PushDownFileSystem,
): ReadonlySet<string> | null {
  // No explicit selection means publish everything without a manifest read.
  if (packs === null || packs.size === 0) {
    return null;
  }

  const manifestDir = joinPosix(bundleRoot, PACK_MANIFEST_SUBDIR);
  const manifests: Map<string, PackManifest> = loadPackManifests(
    manifestDir,
    packs,
    fs,
  );
  const published = computePublishedPaths(packs, manifests);
  // computePublishedPaths returns null only for an empty selection, already
  // excluded above; treat a null here as an empty set so the C# exclusion check
  // still runs on a concrete value.
  const effectivePublished: ReadonlySet<string> =
    published ?? new Set<string>();
  assertSingleCsharpToolchain(effectivePublished, packs);
  return effectivePublished;
}

/** Options for the Claude {@link pushDownCustomizations} entry point. */
export interface ClaudePushDownOptions {
  readonly repoRoot: string;
  readonly destinationRoot: string;
  readonly fs: PushDownFileSystem;
  readonly sourceRoot?: string;
  readonly artifactRoot?: string;
  readonly packs?: ReadonlySet<string> | null;
  readonly csharpVariant?: CSharpVariant;
  readonly memoryMode?: MemoryMode;
  readonly bundleRoot?: string;
  readonly clock?: Clock;

  /**
   * Shallow directory lister used to scan the destination layout.
   *
   * Optional and non-breaking: when omitted the real-filesystem lister is used.
   * A test publishing to an in-memory destination injects a fake here, because
   * the real lister cannot see an in-memory tree.
   */
  readonly listEntries?: DirectoryLister;

  /** Overwrite `unmanaged-conflict` files (O-4 opt-in, issue #1029). */
  readonly overwriteUnmanaged?: boolean;
}

/**
 * Return the parent directory of a POSIX path.
 *
 * @param path POSIX path.
 * @returns The parent path, or `""` for a bare name.
 */
function parentPosix(path: string): string {
  const normalized = path.replace(/\\/g, "/").replace(/\/+$/, "");
  return normalized.slice(0, Math.max(normalized.lastIndexOf("/"), 0));
}

/**
 * Build the Claude layer from the pinned declarations of this module (D10).
 *
 * @param options Entry options (roots, filesystem, pack/variant/memory inputs).
 * @returns The Claude layer for the push-down pipeline.
 * @throws ManifestError When a selected manifest is missing/malformed or both C#
 *   variants are selected.
 */
export function buildClaudeLayer(
  options: ClaudePushDownOptions,
): PushDownLayer {
  const effectiveSource = options.sourceRoot ?? options.repoRoot;
  // The repository layout nests the bundle under the source root; an explicit
  // bundleRoot (the bundled template) overrides this.
  const effectiveBundle =
    options.bundleRoot ?? joinPosix(effectiveSource, BUNDLE_ROOT_RELATIVE_DIR);
  const packs = options.packs ?? null;
  return composeClaudeLayer(
    {
      rootFolders: ROOT_FOLDERS,
      excludedRelativePaths: EXCLUDED_RELATIVE_PATHS,
      mergedRelativePaths: MERGED_RELATIVE_PATHS,
      destinationWriteDecorators: DESTINATION_WRITE_DECORATORS,
      artifactDirectory: ARTIFACT_DIRECTORY,
    },
    {
      repoRoot: options.repoRoot,
      sourceRoot: effectiveSource,
      bundleRoot: effectiveBundle,
      resourcesRoot: parentPosix(effectiveBundle),
      destinationRoot: options.destinationRoot,
      fs: options.fs,
      packs: packs === null ? null : [...packs],
      csharpVariant: options.csharpVariant ?? "modern",
      memoryMode: options.memoryMode ?? "overwrite",
      ...(options.listEntries === undefined
        ? {}
        : { listEntries: options.listEntries }),
    },
  );
}

/**
 * Copy the `.claude` tree into the destination workspace.
 *
 * A single-layer adapter over the push-down pipeline (no shared layer): the
 * Claude layer is planned, then applied, so the destination manifest, the
 * no-overwrite rule, exclusions, merged paths, and the `.gitignore` delivery
 * all follow the pipeline.
 *
 * @param options Entry options (roots, filesystem, pack/variant/memory inputs).
 * @returns The completed run summary including the written artifact path.
 * @throws ManifestError When a selected manifest is missing/malformed or both C#
 *   variants are selected.
 * @throws ExclusionManifestError When the destination manifest is malformed.
 * @throws Error When destination validation fails.
 */
export function pushDownCustomizations(
  options: ClaudePushDownOptions,
): ClaudePushDownSummary {
  const planned = runPushDownPipeline({
    repoRoot: options.repoRoot,
    destinationRoot: options.destinationRoot,
    fs: options.fs,
    buildLayers: () => [buildClaudeLayer(options)],
    overwriteUnmanaged: options.overwriteUnmanaged === true,
    ...(options.clock === undefined ? {} : { clock: options.clock }),
  });
  const applied = applyPushDownPlan(planned, {
    payloadVersion: UNKNOWN_PAYLOAD_VERSION,
    artifactRoot: options.artifactRoot ?? options.repoRoot,
    artifactDirectory: ARTIFACT_DIRECTORY,
    ...(options.clock === undefined ? {} : { clock: options.clock }),
  });
  return applied.exclusions === undefined
    ? applied.summary
    : { ...applied.summary, exclusions: applied.exclusions };
}
