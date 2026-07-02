import { type PushDownFileSystem } from "./filesystem-adapter";

export const CORE_PACK_NAME = "core";
export const SUPPORTED_PACK_NAMES: ReadonlySet<string> = new Set([
  "core",
  "python",
  "powershell",
  "typescript",
  "csharp-modern",
  "csharp-legacy",
]);
export const CSHARP_CANONICAL_PATHS: ReadonlyArray<string> = [
  ".agents/skills/csharp/SKILL.md",
  ".agents/skills/csharp-qa-gate/SKILL.md",
  ".agents/skills/invoke-csharp-engineer/SKILL.md",
  ".codex/agents/csharp-typed-engineer.toml",
];
export const CSHARP_PACK_NAMES: ReadonlySet<string> = new Set([
  "csharp-modern",
  "csharp-legacy",
]);
export const AGENTS_LEGACY_VARIANT_SOURCE_PREFIX =
  ".agents-variants/csharp-legacy";
export const CODEX_LEGACY_VARIANT_SOURCE_PREFIX =
  ".codex-variants/csharp-legacy";

export type CSharpVariant = "modern" | "legacy";
export type MemoryMode = "overwrite" | "merge" | "skip";

export class ManifestError extends Error {
  constructor(message: string) {
    super(message);
    this.name = "ManifestError";
  }
}

export interface PackManifest {
  readonly name: string;
  readonly label: string;
  readonly paths: ReadonlyArray<string>;
  readonly sourcePrefix: string | null;
}

function joinPosix(dir: string, name: string): string {
  const normalizedDir = dir.replace(/\\/g, "/").replace(/\/+$/, "");
  return normalizedDir === "" ? name : `${normalizedDir}/${name}`;
}

export function loadPackManifests(
  manifestDir: string,
  selectedPackNames: ReadonlySet<string>,
  fs: PushDownFileSystem,
): Map<string, PackManifest> {
  const unknown = [...selectedPackNames].filter(
    (name) => !SUPPORTED_PACK_NAMES.has(name),
  );
  if (unknown.length > 0) {
    throw new ManifestError(`Unknown Codex pack name(s): ${unknown.sort()}`);
  }
  const namesToLoad = new Set<string>(selectedPackNames);
  namesToLoad.add(CORE_PACK_NAME);
  const manifests = new Map<string, PackManifest>();
  for (const name of [...namesToLoad].sort()) {
    const manifestPath = joinPosix(manifestDir, `${name}.json`);
    if (!fs.isFile(manifestPath)) {
      throw new ManifestError(
        `Codex pack manifest is missing for pack '${name}': ${manifestPath}`,
      );
    }
    manifests.set(
      name,
      parseManifest(name, manifestPath, fs.readTextFile(manifestPath)),
    );
  }
  return manifests;
}

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
      `Codex pack manifest is not valid JSON for pack '${name}': ${manifestPath}`,
    );
  }
  if (loaded === null || typeof loaded !== "object" || Array.isArray(loaded)) {
    throw new ManifestError(
      `Codex pack manifest must be a JSON object for pack '${name}': ${manifestPath}`,
    );
  }
  const parsed = loaded as Record<string, unknown>;
  const manifestName = parsed["name"];
  const manifestLabel = parsed["label"] ?? manifestName;
  const manifestPaths = parsed["paths"];
  const sourcePrefix = parsed["source_prefix"];
  if (typeof manifestName !== "string" || manifestName === "") {
    throw new ManifestError(
      `Codex pack manifest 'name' must be a non-empty string: ${manifestPath}`,
    );
  }
  if (typeof manifestLabel !== "string" || manifestLabel === "") {
    throw new ManifestError(
      `Codex pack manifest 'label' must be a non-empty string: ${manifestPath}`,
    );
  }
  if (!Array.isArray(manifestPaths) || manifestPaths.length === 0) {
    throw new ManifestError(
      `Codex pack manifest 'paths' must be a non-empty list of strings: ${manifestPath}`,
    );
  }
  const paths: string[] = [];
  for (const entry of manifestPaths) {
    if (typeof entry !== "string" || entry === "") {
      throw new ManifestError(
        `Codex pack manifest 'paths' must be a non-empty list of strings: ${manifestPath}`,
      );
    }
    paths.push(entry);
  }
  if (
    sourcePrefix !== undefined &&
    sourcePrefix !== null &&
    typeof sourcePrefix !== "string"
  ) {
    throw new ManifestError(
      `Codex pack manifest 'source_prefix' must be a string when present: ${manifestPath}`,
    );
  }
  return {
    name: manifestName,
    label: manifestLabel,
    paths,
    sourcePrefix:
      sourcePrefix === undefined || sourcePrefix === null ? null : sourcePrefix,
  };
}

export function computePublishedPaths(
  selectedPackNames: ReadonlySet<string> | null,
  manifests: Map<string, PackManifest>,
): ReadonlySet<string> | null {
  if (selectedPackNames === null || selectedPackNames.size === 0) {
    return null;
  }
  const effectiveNames = new Set<string>(selectedPackNames);
  effectiveNames.add(CORE_PACK_NAME);
  const published = new Set<string>();
  for (const name of effectiveNames) {
    const manifest = manifests.get(name);
    if (manifest === undefined) {
      throw new ManifestError(
        `No loaded Codex manifest for selected pack '${name}'.`,
      );
    }
    for (const path of manifest.paths) {
      published.add(path);
    }
  }
  return published;
}

export function resolveVariantSourcePath(
  destinationRelativePath: string,
  csharpVariant: CSharpVariant,
): string {
  if (
    csharpVariant === "legacy" &&
    CSHARP_CANONICAL_PATHS.includes(destinationRelativePath)
  ) {
    if (destinationRelativePath.startsWith(".agents/")) {
      return `${AGENTS_LEGACY_VARIANT_SOURCE_PREFIX}/${destinationRelativePath.slice(".agents/".length)}`;
    }
    if (destinationRelativePath.startsWith(".codex/")) {
      return `${CODEX_LEGACY_VARIANT_SOURCE_PREFIX}/${destinationRelativePath.slice(".codex/".length)}`;
    }
  }
  return destinationRelativePath;
}

export function assertSingleCsharpToolchain(
  publishedPaths: ReadonlySet<string>,
  selectedPackNames: ReadonlySet<string>,
): void {
  const selectedCsharp = [...selectedPackNames]
    .filter((name) => CSHARP_PACK_NAMES.has(name))
    .sort();
  if (selectedCsharp.length > 1) {
    throw new ManifestError(
      "C# mutual exclusion violated: both modern and legacy Codex C# packs were " +
        `selected (${selectedCsharp.join(", ")}); select exactly one C# variant.`,
    );
  }
  void publishedPaths;
}
