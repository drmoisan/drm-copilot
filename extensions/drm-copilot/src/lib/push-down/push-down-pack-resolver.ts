/**
 * Pack resolution for every push-down layer (issue #1029).
 *
 * Purpose:
 *     Resolve, per ecosystem, the published path set, the owning-pack lookup,
 *     and the selection record, reaching the existing Claude and Codex loaders
 *     (whose error messages their tests pin) and using the Claude loader over
 *     the new Copilot manifests. Also loads the shared-layer manifest and
 *     provides the enumeration filter that restricts a layer to a path set.
 *
 * Side effects:
 *     Reads manifests through the injected adapter; the filter delegates I/O.
 */

import { compareCodePoint } from "../string-ordering";
import { type PushDownFileSystem } from "./filesystem-adapter";
import * as claudePacks from "./claude-pack-selection";
import * as codexPacks from "./codex-pack-selection";
import {
  type DestinationManifestSelection,
  MANIFEST_CORE_PACK,
} from "./push-down-destination-manifest";
import { type EcosystemName } from "./push-down-layer";

/** Subdirectory of a bundle that holds pack manifests. */
export const PACK_MANIFEST_DIRECTORY = "pack-manifests";

/** Name and file stem of the shared-layer manifest. */
export const SHARED_MANIFEST_NAME = "shared";

/** Pack names a Copilot selection accepts. */
export const COPILOT_PACK_NAMES: ReadonlyArray<string> = [
  "core",
  "csharp",
  "powershell",
  "python",
  "typescript",
];

/** Pack names recorded for a full-tree publish, per ecosystem (D5). */
const FULL_TREE_PACKS: Readonly<
  Record<EcosystemName, (variant: "modern" | "legacy") => string[]>
> = {
  claude: (variant) => [
    "core",
    `csharp-${variant}`,
    "powershell",
    "python",
    "typescript",
  ],
  codex: () => [...COPILOT_PACK_NAMES],
  copilot: () => [...COPILOT_PACK_NAMES],
};

/**
 * Return the pack list a full-tree publish records for an ecosystem (D5).
 *
 * @param ecosystem Ecosystem name.
 * @param csharpVariant Effective C# variant.
 * @returns The sorted pack names, including `core`.
 */
export function fullTreePacks(
  ecosystem: EcosystemName,
  csharpVariant: "modern" | "legacy",
): string[] {
  return recordedPacks(FULL_TREE_PACKS[ecosystem](csharpVariant));
}

/** One loaded pack manifest (the shape both existing loaders return). */
interface LoadedManifest {
  readonly name: string;
  readonly paths: ReadonlyArray<string>;
}

/** Inputs of {@link resolveLayerPublishedPaths}. */
export interface LayerPackResolutionInput {
  readonly ecosystem: EcosystemName;
  /** Selected packs, or `null` for the full tree. */
  readonly packs: ReadonlyArray<string> | null;
  readonly csharpVariant: "modern" | "legacy";
  /** Memory mode, recorded for Claude and Codex. */
  readonly memoryMode: "overwrite" | "merge" | "skip";
  /** Bundle root holding `pack-manifests/`. */
  readonly bundleRoot: string;
  readonly fs: PushDownFileSystem;
}

/** Result of {@link resolveLayerPublishedPaths}. */
export interface ResolvedLayerPacks {
  /** Published destination-relative paths, or `null` for the full tree. */
  readonly publishedPaths: ReadonlySet<string> | null;
  /** Owning pack of a destination-relative path. */
  readonly ownerPack: (relativePath: string) => string;
  /** Selection the destination manifest records. */
  readonly selection: DestinationManifestSelection;
}

/**
 * Join a directory and a relative path with one forward slash.
 *
 * @param root Base POSIX path.
 * @param relative Relative POSIX path.
 * @returns The joined path.
 */
function joinPosix(root: string, relative: string): string {
  const normalizedRoot = root.replace(/\\/g, "/").replace(/\/+$/, "");
  return normalizedRoot === "" ? relative : `${normalizedRoot}/${relative}`;
}

/**
 * Build the owning-pack lookup of a set of loaded manifests.
 *
 * `core` claims first; other packs claim in code-point order of their names,
 * so a path listed by two packs resolves deterministically.
 *
 * @param manifests Loaded manifests keyed by pack name.
 * @returns Lookup returning the owning pack, or `core` for an unlisted path.
 */
export function buildPackOwnerLookup(
  manifests: ReadonlyMap<string, LoadedManifest>,
): (relativePath: string) => string {
  const owners = new Map<string, string>();
  const names = [...manifests.keys()].sort((left, right) =>
    left === MANIFEST_CORE_PACK
      ? -1
      : right === MANIFEST_CORE_PACK
        ? 1
        : compareCodePoint(left, right),
  );
  for (const name of names) {
    for (const path of manifests.get(name)?.paths ?? []) {
      if (!owners.has(path)) {
        owners.set(path, name);
      }
    }
  }
  return (relativePath) => owners.get(relativePath) ?? MANIFEST_CORE_PACK;
}

/**
 * Sort pack names in code-point order and add `core`.
 *
 * @param packs Pack names.
 * @returns The sorted, de-duplicated names including `core`.
 */
function recordedPacks(packs: ReadonlyArray<string>): string[] {
  return [...new Set([MANIFEST_CORE_PACK, ...packs])].sort(compareCodePoint);
}

/**
 * Load the manifests of one ecosystem through its existing loader.
 *
 * @param input Resolution input with a non-empty pack selection.
 * @param packs Non-empty selected pack names.
 * @returns The loaded manifests keyed by pack name.
 * @throws ManifestError When a manifest is missing or malformed, a pack is
 *   unknown, or both C# variants are selected.
 */
function loadEcosystemManifests(
  input: LayerPackResolutionInput,
  packs: ReadonlySet<string>,
): Map<string, LoadedManifest> {
  const manifestDir = joinPosix(input.bundleRoot, PACK_MANIFEST_DIRECTORY);
  if (input.ecosystem === "codex") {
    // The selection is non-empty here, so the translation never returns null.
    const manifestNames = new Set(
      codexPacks.resolveManifestPackNames(packs, input.csharpVariant),
    );
    const manifests = codexPacks.loadPackManifests(
      manifestDir,
      manifestNames,
      input.fs,
    );
    codexPacks.assertSingleCsharpToolchain(new Set(), manifestNames);
    return manifests;
  }
  if (input.ecosystem === "copilot") {
    const unknown = [...packs]
      .filter((name) => !COPILOT_PACK_NAMES.includes(name))
      .sort(compareCodePoint);
    if (unknown.length > 0) {
      throw new claudePacks.ManifestError(
        `Unknown Copilot pack name(s): ${unknown.join(", ")}`,
      );
    }
  }
  const manifests = claudePacks.loadPackManifests(manifestDir, packs, input.fs);
  claudePacks.assertSingleCsharpToolchain(new Set(), packs);
  return manifests;
}

/**
 * Resolve the published paths, owning packs, and recorded selection of one
 * ecosystem layer.
 *
 * @param input Ecosystem, selection, variant, memory mode, bundle, adapter.
 * @returns The published path set (`null` for the full tree), the owning-pack
 *   lookup, and the selection record.
 * @throws ManifestError When a manifest is missing or malformed, a pack is
 *   unknown, or both C# variants are selected.
 */
export function resolveLayerPublishedPaths(
  input: LayerPackResolutionInput,
): ResolvedLayerPacks {
  const variantFields: Partial<DestinationManifestSelection> =
    input.ecosystem === "copilot"
      ? {}
      : { csharpVariant: input.csharpVariant, memoryMode: input.memoryMode };
  if (input.packs === null || input.packs.length === 0) {
    return {
      publishedPaths: null,
      ownerPack: () => MANIFEST_CORE_PACK,
      selection: {
        packs: fullTreePacks(input.ecosystem, input.csharpVariant),
        ...variantFields,
      },
    };
  }
  const selected = new Set(input.packs);
  const manifests = loadEcosystemManifests(input, selected);
  const published = new Set<string>();
  for (const manifest of manifests.values()) {
    for (const path of manifest.paths) {
      published.add(path);
    }
  }
  return {
    publishedPaths: published,
    ownerPack: buildPackOwnerLookup(manifests),
    selection: { packs: recordedPacks(input.packs), ...variantFields },
  };
}

/**
 * Load the shared-layer path set from `shared.json`.
 *
 * @param manifestDir Directory holding `shared.json`.
 * @param fs Adapter used to read the manifest.
 * @returns The shared destination-relative paths.
 * @throws ManifestError When the manifest is missing or malformed.
 */
export function loadSharedLayerPaths(
  manifestDir: string,
  fs: PushDownFileSystem,
): ReadonlySet<string> {
  const path = joinPosix(manifestDir, `${SHARED_MANIFEST_NAME}.json`);
  if (!fs.isFile(path)) {
    throw new claudePacks.ManifestError(
      `Shared-layer manifest is missing: ${path}`,
    );
  }
  let loaded: unknown;
  try {
    loaded = JSON.parse(fs.readTextFile(path));
  } catch {
    throw new claudePacks.ManifestError(
      `Shared-layer manifest is not valid JSON: ${path}`,
    );
  }
  if (loaded === null || typeof loaded !== "object" || Array.isArray(loaded)) {
    throw new claudePacks.ManifestError(
      `Shared-layer manifest must be a JSON object: ${path}`,
    );
  }
  const record = loaded as Record<string, unknown>;
  const paths = record["paths"];
  if (record["name"] !== SHARED_MANIFEST_NAME) {
    throw new claudePacks.ManifestError(
      `Shared-layer manifest 'name' must be '${SHARED_MANIFEST_NAME}': ${path}`,
    );
  }
  if (
    !Array.isArray(paths) ||
    !paths.every((entry): entry is string => typeof entry === "string")
  ) {
    throw new claudePacks.ManifestError(
      `Shared-layer manifest 'paths' must be a list of strings: ${path}`,
    );
  }
  return new Set(paths);
}

/**
 * Enumeration filter that restricts a layer to a published path set.
 *
 * `listFiles` keeps only paths whose source-relative form is published (all
 * paths when the set is `null`); every other call delegates.
 */
export class PublishedPathFilterFileSystem implements PushDownFileSystem {
  private readonly inner: PushDownFileSystem;
  private readonly sourcePrefix: string;
  private readonly publishedPaths: ReadonlySet<string> | null;

  /**
   * @param inner Adapter to filter.
   * @param sourceRoot Root the published paths are relative to.
   * @param publishedPaths Published paths, or `null` to publish everything.
   */
  constructor(
    inner: PushDownFileSystem,
    sourceRoot: string,
    publishedPaths: ReadonlySet<string> | null,
  ) {
    this.inner = inner;
    this.sourcePrefix = `${sourceRoot.replace(/\\/g, "/").replace(/\/+$/, "")}/`;
    this.publishedPaths = publishedPaths;
  }

  listFiles(root: string): string[] {
    const published = this.publishedPaths;
    const listed = this.inner.listFiles(root);
    if (published === null) {
      return listed;
    }
    return listed.filter(
      (path) =>
        !path.startsWith(this.sourcePrefix) ||
        published.has(path.slice(this.sourcePrefix.length)),
    );
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

  writeTextFile(path: string, content: string): void {
    this.inner.writeTextFile(path, content);
  }

  ensureDir(path: string): void {
    this.inner.ensureDir(path);
  }
}
