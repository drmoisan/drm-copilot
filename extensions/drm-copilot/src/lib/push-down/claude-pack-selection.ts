/**
 * Pack selection, variant routing, and memory-mode helpers for `.claude`
 * push-down.
 *
 * Purpose:
 *     Port `push_down_claude_pack_selection.py`. Provides the pure logic that
 *     the Claude push-down entry point uses to decide which `.claude`-relative
 *     files to publish, which C# variant source to read for each canonical
 *     destination path, and the C# mutual-exclusion assertion.
 *
 * Responsibilities:
 *     - Load and validate pack-manifest JSON via an injected filesystem adapter.
 *     - Compute the published `.claude`-relative path set (always including
 *       `core`).
 *     - Resolve the source-relative path for a destination path given the C#
 *       variant.
 *     - Assert that a single run selects at most one C# variant.
 *
 * Side effects:
 *     None beyond reads performed through the injected adapter.
 */

import { type PushDownFileSystem } from "./filesystem-adapter";

/** Pack name reserved for the always-included non-language customization set. */
export const CORE_PACK_NAME = "core";

/**
 * The four canonical `.claude`-relative C# destination paths shared by the
 * modern and legacy C# packs.
 */
export const CSHARP_CANONICAL_PATHS: ReadonlyArray<string> = [
  ".claude/rules/csharp.md",
  ".claude/agents/csharp-typed-engineer.md",
  ".claude/skills/csharp-qa-gate/SKILL.md",
  ".claude/skills/invoke-csharp-engineer/SKILL.md",
];

/** Pack names whose paths are the canonical C# toolchain. */
export const CSHARP_PACK_NAMES: ReadonlySet<string> = new Set([
  "csharp-modern",
  "csharp-legacy",
]);

/** Bundle-only source prefix for the legacy C# variant subtree. */
export const LEGACY_VARIANT_SOURCE_PREFIX = ".claude-variants/csharp-legacy";

/** Selected C# toolchain variant. */
export type CSharpVariant = "modern" | "legacy";

/** Agent-memory handling mode. */
export type MemoryMode = "overwrite" | "merge" | "skip";

/**
 * Raised when a pack manifest is missing or structurally invalid.
 *
 * Mirrors the Python `ManifestError` (a `ValueError` subclass). A distinct error
 * class lets callers and tests distinguish manifest problems from unrelated
 * errors.
 */
export class ManifestError extends Error {
  constructor(message: string) {
    super(message);
    this.name = "ManifestError";
  }
}

/** One loaded, validated pack manifest. */
export interface PackManifest {
  /** Stable pack identifier (for example `python`). */
  readonly name: string;
  /** Human-readable label used by the command UI. */
  readonly label: string;
  /** The `.claude`-relative destination paths this pack contributes. */
  readonly paths: ReadonlyArray<string>;
  /** Optional bundle-relative source prefix for variant packs; else null. */
  readonly sourcePrefix: string | null;
}

/**
 * Join a directory and a filename using forward-slash separators.
 *
 * @param dir Directory POSIX path.
 * @param name Filename to append.
 * @returns The combined POSIX path.
 */
function joinPosix(dir: string, name: string): string {
  const normalizedDir = dir.replace(/\\/g, "/").replace(/\/+$/, "");
  return normalizedDir === "" ? name : `${normalizedDir}/${name}`;
}

/**
 * Load and validate the selected pack manifests from the bundle.
 *
 * Reads each selected manifest JSON through the injected adapter, validates its
 * required structure, and returns a map from pack name to its typed manifest.
 * `core` is always loaded. Iteration is sorted so error order is deterministic.
 *
 * @param manifestDir Directory holding `<pack>.json` manifest files.
 * @param selectedPackNames Pack names to load (core is added automatically).
 * @param fs Filesystem adapter for existence checks and text reads.
 * @returns Map of pack name to validated manifest, including `core`.
 * @throws ManifestError When a manifest is missing, invalid JSON, not an object,
 *   or has invalid name/label/paths/source_prefix values.
 */
export function loadPackManifests(
  manifestDir: string,
  selectedPackNames: ReadonlySet<string>,
  fs: PushDownFileSystem,
): Map<string, PackManifest> {
  // Always load core in addition to the explicitly selected packs.
  const namesToLoad = new Set<string>(selectedPackNames);
  namesToLoad.add(CORE_PACK_NAME);

  const manifests = new Map<string, PackManifest>();
  // Load each selected manifest in sorted order so any error order is stable.
  for (const name of [...namesToLoad].sort()) {
    const manifestPath = joinPosix(manifestDir, `${name}.json`);
    if (!fs.isFile(manifestPath)) {
      throw new ManifestError(
        `Pack manifest is missing for pack '${name}': ${manifestPath}`,
      );
    }
    const rawText = fs.readTextFile(manifestPath);
    manifests.set(name, parseManifest(name, manifestPath, rawText));
  }
  return manifests;
}

/**
 * Parse and validate one manifest's JSON text into a {@link PackManifest}.
 *
 * @param name The pack name expected for this manifest (the file stem).
 * @param manifestPath The manifest path, used only for error messages.
 * @param rawText The raw JSON text read from the manifest file.
 * @returns The validated, immutable manifest structure.
 * @throws ManifestError When the text is not valid JSON, not an object, or has
 *   missing/wrongly typed name/label/paths/source_prefix values.
 */
function parseManifest(
  name: string,
  manifestPath: string,
  rawText: string,
): PackManifest {
  let loaded: unknown;
  try {
    loaded = JSON.parse(rawText);
  } catch {
    throw new ManifestError(
      `Pack manifest is not valid JSON for pack '${name}': ${manifestPath}`,
    );
  }

  // A JSON array, string, or number is not an object manifest.
  if (loaded === null || typeof loaded !== "object" || Array.isArray(loaded)) {
    throw new ManifestError(
      `Pack manifest must be a JSON object for pack '${name}': ${manifestPath}`,
    );
  }

  const parsed = loaded as Record<string, unknown>;
  const manifestName = parsed["name"];
  const manifestLabel = parsed["label"];
  const manifestPaths = parsed["paths"];
  const sourcePrefix = parsed["source_prefix"];

  // Validate the required string keys; both must be non-empty.
  if (typeof manifestName !== "string" || manifestName === "") {
    throw new ManifestError(
      `Pack manifest 'name' must be a non-empty string: ${manifestPath}`,
    );
  }
  if (typeof manifestLabel !== "string" || manifestLabel === "") {
    throw new ManifestError(
      `Pack manifest 'label' must be a non-empty string: ${manifestPath}`,
    );
  }

  // Validate the paths array is a list of strings.
  if (!Array.isArray(manifestPaths)) {
    throw new ManifestError(
      `Pack manifest 'paths' must be a list of strings: ${manifestPath}`,
    );
  }
  const typedPaths: string[] = [];
  // Narrow each entry to string so a non-string element is rejected explicitly.
  for (const entry of manifestPaths) {
    if (typeof entry !== "string") {
      throw new ManifestError(
        `Pack manifest 'paths' must be a list of strings: ${manifestPath}`,
      );
    }
    typedPaths.push(entry);
  }

  // source_prefix is optional; when present it must be a string.
  if (
    sourcePrefix !== undefined &&
    sourcePrefix !== null &&
    typeof sourcePrefix !== "string"
  ) {
    throw new ManifestError(
      `Pack manifest 'source_prefix' must be a string when present: ${manifestPath}`,
    );
  }

  return {
    name: manifestName,
    label: manifestLabel,
    paths: typedPaths,
    sourcePrefix:
      sourcePrefix === undefined || sourcePrefix === null ? null : sourcePrefix,
  };
}

/**
 * Compute the `.claude`-relative destination paths to publish.
 *
 * Unions every selected pack's paths plus `core`. Returns `null` when no
 * explicit selection was made (the caller then publishes the full tree).
 *
 * @param selectedPackNames Selected pack names, or null/empty for the default.
 * @param manifests Loaded manifests for at least the selected packs plus core.
 * @returns The union path set, or `null` for the publish-everything default.
 * @throws ManifestError When a selected pack has no loaded manifest.
 */
export function computePublishedPaths(
  selectedPackNames: ReadonlySet<string> | null,
  manifests: Map<string, PackManifest>,
): ReadonlySet<string> | null {
  // An empty or null selection means publish-everything (signalled by null).
  if (selectedPackNames === null || selectedPackNames.size === 0) {
    return null;
  }

  // Always include core so the non-language baseline is published.
  const effectiveNames = new Set<string>(selectedPackNames);
  effectiveNames.add(CORE_PACK_NAME);

  const published = new Set<string>();
  // Union every selected pack's destination paths into the published set.
  for (const name of effectiveNames) {
    const manifest = manifests.get(name);
    if (manifest === undefined) {
      throw new ManifestError(
        `No loaded manifest for selected pack '${name}'.`,
      );
    }
    for (const p of manifest.paths) {
      published.add(p);
    }
  }
  return published;
}

/**
 * Resolve the source-relative path to read for a destination path.
 *
 * For the legacy C# variant and a canonical C# path, the read is routed to the
 * bundle-only `.claude-variants/csharp-legacy/` subtree. Non-C# paths and the
 * modern variant resolve to the destination path unchanged.
 *
 * @param destinationRelativePath A `.claude`-relative destination path.
 * @param csharpVariant `modern` (read from `.claude`) or `legacy`.
 * @returns The source-relative path to read.
 */
export function resolveVariantSourcePath(
  destinationRelativePath: string,
  csharpVariant: CSharpVariant,
): string {
  // Only the four canonical C# destinations are variant-routed under legacy.
  if (
    csharpVariant === "legacy" &&
    CSHARP_CANONICAL_PATHS.includes(destinationRelativePath)
  ) {
    // Replace the leading `.claude/` with the legacy variant prefix.
    const tail = destinationRelativePath.slice(".claude/".length);
    return `${LEGACY_VARIANT_SOURCE_PREFIX}/${tail}`;
  }
  return destinationRelativePath;
}

/**
 * Assert the C# selection yields at most one toolchain at the destination.
 *
 * @param publishedPaths The computed destination paths for the run (unused for
 *   the duplicate check since a set deduplicates; kept for parity with Python).
 * @param selectedPackNames The selected pack names.
 * @throws ManifestError When both `csharp-modern` and `csharp-legacy` are
 *   selected in the same run.
 */
export function assertSingleCsharpToolchain(
  publishedPaths: ReadonlySet<string>,
  selectedPackNames: ReadonlySet<string>,
): void {
  // Selecting both C# packs would route two sources to the same destinations.
  const selectedCsharp = [...selectedPackNames]
    .filter((name) => CSHARP_PACK_NAMES.has(name))
    .sort();
  if (selectedCsharp.length > 1) {
    throw new ManifestError(
      "C# mutual exclusion violated: both modern and legacy C# packs were " +
        `selected ([${selectedCsharp.map((n) => `'${n}'`).join(", ")}]); select exactly one C# variant.`,
    );
  }
  // Reference publishedPaths so the parameter is intentionally part of the API.
  void publishedPaths;
}
