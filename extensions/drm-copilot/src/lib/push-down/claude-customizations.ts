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
  pushDownCustomizations as enginePushDown,
  type PushDownSummary,
} from "./copilot-customizations-engine";
import { ExcludingFileSystem } from "./claude-filesystem-adapter";
import {
  assertSingleCsharpToolchain,
  computePublishedPaths,
  type CSharpVariant,
  loadPackManifests,
  type MemoryMode,
  type PackManifest,
} from "./claude-pack-selection";

/** Artifact directory for the Claude push-down summary. */
export const ARTIFACT_DIRECTORY = "artifacts/claude-customizations";

/** Inlined Claude scoped root folders (enumeration-order contract). */
export const ROOT_FOLDERS: ReadonlyArray<string> = [".claude"];

/** Repo-relative host-specific paths excluded from push-down. */
export const EXCLUDED_RELATIVE_PATHS: ReadonlyArray<string> = [
  ".claude/settings.local.json",
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
export { type PushDownSummary, type CSharpVariant, type MemoryMode };

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
}

/**
 * Copy the `.claude` tree into the destination workspace.
 *
 * Composes {@link ExcludingFileSystem} over the injected adapter and delegates
 * to the shared engine with the Claude root folders, artifact directory, and the
 * passthrough rewrite.
 *
 * @param options Entry options (roots, filesystem, pack/variant/memory inputs).
 * @returns The completed run summary including the written artifact path.
 * @throws ManifestError When a selected manifest is missing/malformed or both C#
 *   variants are selected.
 * @throws Error When destination validation fails.
 */
export function pushDownCustomizations(
  options: ClaudePushDownOptions,
): PushDownSummary {
  const {
    repoRoot,
    destinationRoot,
    fs,
    sourceRoot,
    artifactRoot,
    packs,
    csharpVariant,
    memoryMode,
    bundleRoot,
    clock,
  } = options;

  const effectiveSource = sourceRoot ?? repoRoot;
  // Resolve the bundle root that holds manifests and the variant subtree. The
  // repository layout nests the bundle under the source root; an explicit
  // bundleRoot (the bundled template) overrides this.
  const effectiveBundle =
    bundleRoot ?? joinPosix(effectiveSource, BUNDLE_ROOT_RELATIVE_DIR);

  // Resolve the published-path set only when a pack selection is supplied so the
  // no-argument path performs no manifest I/O.
  const publishedPaths = resolvePublishedPaths(
    packs ?? null,
    effectiveBundle,
    fs,
  );

  // Wrap the adapter so enumeration omits excluded paths and honors selections.
  const excludingFs = new ExcludingFileSystem(
    fs,
    repoRoot,
    EXCLUDED_RELATIVE_PATHS,
    {
      sourceRoot: effectiveSource,
      destinationRoot,
      publishedPaths,
      csharpVariant: csharpVariant ?? "modern",
      memoryMode: memoryMode ?? "overwrite",
      variantRoot: effectiveBundle,
    },
  );

  return enginePushDown({
    repoRoot,
    destinationRoot,
    fs: excludingFs,
    ...(sourceRoot === undefined ? {} : { sourceRoot }),
    ...(artifactRoot === undefined ? {} : { artifactRoot }),
    rootFolders: ROOT_FOLDERS,
    artifactDirectory: ARTIFACT_DIRECTORY,
    rewriteReferences: passthroughRewrite,
    ...(clock === undefined ? {} : { clock }),
  });
}
