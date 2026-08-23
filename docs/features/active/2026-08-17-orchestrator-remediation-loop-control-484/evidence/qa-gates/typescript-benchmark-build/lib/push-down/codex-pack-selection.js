"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.ManifestError = exports.CODEX_LEGACY_VARIANT_SOURCE_PREFIX = exports.AGENTS_LEGACY_VARIANT_SOURCE_PREFIX = exports.CSHARP_PACK_NAMES = exports.CSHARP_CANONICAL_PATHS = exports.MANIFEST_PACK_NAMES = exports.SUPPORTED_PACK_NAMES = exports.PUBLIC_CSHARP_PACK_NAME = exports.CORE_PACK_NAME = void 0;
exports.loadPackManifests = loadPackManifests;
exports.resolveManifestPackNames = resolveManifestPackNames;
exports.computePublishedPaths = computePublishedPaths;
exports.resolveVariantSourcePath = resolveVariantSourcePath;
exports.assertSingleCsharpToolchain = assertSingleCsharpToolchain;
exports.CORE_PACK_NAME = "core";
exports.PUBLIC_CSHARP_PACK_NAME = "csharp";
exports.SUPPORTED_PACK_NAMES = new Set([
    "core",
    "python",
    "powershell",
    "typescript",
    exports.PUBLIC_CSHARP_PACK_NAME,
]);
exports.MANIFEST_PACK_NAMES = new Set([
    "core",
    "python",
    "powershell",
    "typescript",
    "csharp-modern",
    "csharp-legacy",
]);
exports.CSHARP_CANONICAL_PATHS = [
    ".agents/skills/csharp/SKILL.md",
    ".agents/skills/csharp-qa-gate/SKILL.md",
    ".agents/skills/invoke-csharp-engineer/SKILL.md",
    ".codex/agents/csharp-typed-engineer.toml",
];
exports.CSHARP_PACK_NAMES = new Set([
    "csharp-modern",
    "csharp-legacy",
]);
exports.AGENTS_LEGACY_VARIANT_SOURCE_PREFIX = ".agents-variants/csharp-legacy";
exports.CODEX_LEGACY_VARIANT_SOURCE_PREFIX = ".codex-variants/csharp-legacy";
class ManifestError extends Error {
    constructor(message) {
        super(message);
        this.name = "ManifestError";
    }
}
exports.ManifestError = ManifestError;
function joinPosix(dir, name) {
    const normalizedDir = dir.replace(/\\/g, "/").replace(/\/+$/, "");
    return normalizedDir === "" ? name : `${normalizedDir}/${name}`;
}
function loadPackManifests(manifestDir, selectedPackNames, fs) {
    const unknown = [...selectedPackNames].filter((name) => !exports.MANIFEST_PACK_NAMES.has(name));
    if (unknown.length > 0) {
        throw new ManifestError(`Unknown Codex pack name(s): ${unknown.sort()}`);
    }
    const namesToLoad = new Set(selectedPackNames);
    namesToLoad.add(exports.CORE_PACK_NAME);
    const manifests = new Map();
    for (const name of [...namesToLoad].sort()) {
        const manifestPath = joinPosix(manifestDir, `${name}.json`);
        if (!fs.isFile(manifestPath)) {
            throw new ManifestError(`Codex pack manifest is missing for pack '${name}': ${manifestPath}`);
        }
        manifests.set(name, parseManifest(name, manifestPath, fs.readTextFile(manifestPath)));
    }
    return manifests;
}
function resolveManifestPackNames(selectedPackNames, csharpVariant) {
    if (selectedPackNames === null || selectedPackNames.size === 0) {
        return null;
    }
    const variantSpecific = [...selectedPackNames].filter((name) => exports.CSHARP_PACK_NAMES.has(name));
    if (variantSpecific.length > 0) {
        throw new ManifestError("Use public Codex pack 'csharp' with csharpVariant instead of " +
            `variant-specific pack name(s): ${variantSpecific.sort().join(", ")}.`);
    }
    const unknown = [...selectedPackNames].filter((name) => !exports.SUPPORTED_PACK_NAMES.has(name));
    if (unknown.length > 0) {
        throw new ManifestError(`Unknown Codex pack name(s): ${unknown.sort()}`);
    }
    const manifestNames = new Set(selectedPackNames);
    if (manifestNames.has(exports.PUBLIC_CSHARP_PACK_NAME)) {
        manifestNames.delete(exports.PUBLIC_CSHARP_PACK_NAME);
        manifestNames.add(`csharp-${csharpVariant}`);
    }
    return manifestNames;
}
function parseManifest(name, manifestPath, rawText) {
    let loaded;
    try {
        loaded = JSON.parse(rawText);
    }
    catch {
        throw new ManifestError(`Codex pack manifest is not valid JSON for pack '${name}': ${manifestPath}`);
    }
    if (loaded === null || typeof loaded !== "object" || Array.isArray(loaded)) {
        throw new ManifestError(`Codex pack manifest must be a JSON object for pack '${name}': ${manifestPath}`);
    }
    const parsed = loaded;
    const manifestName = parsed["name"];
    const manifestLabel = parsed["label"] ?? manifestName;
    const manifestPaths = parsed["paths"];
    const sourcePrefix = parsed["source_prefix"];
    if (typeof manifestName !== "string" || manifestName === "") {
        throw new ManifestError(`Codex pack manifest 'name' must be a non-empty string: ${manifestPath}`);
    }
    if (typeof manifestLabel !== "string" || manifestLabel === "") {
        throw new ManifestError(`Codex pack manifest 'label' must be a non-empty string: ${manifestPath}`);
    }
    if (!Array.isArray(manifestPaths) || manifestPaths.length === 0) {
        throw new ManifestError(`Codex pack manifest 'paths' must be a non-empty list of strings: ${manifestPath}`);
    }
    const paths = [];
    for (const entry of manifestPaths) {
        if (typeof entry !== "string" || entry === "") {
            throw new ManifestError(`Codex pack manifest 'paths' must be a non-empty list of strings: ${manifestPath}`);
        }
        paths.push(entry);
    }
    if (sourcePrefix !== undefined &&
        sourcePrefix !== null &&
        typeof sourcePrefix !== "string") {
        throw new ManifestError(`Codex pack manifest 'source_prefix' must be a string when present: ${manifestPath}`);
    }
    return {
        name: manifestName,
        label: manifestLabel,
        paths,
        sourcePrefix: sourcePrefix === undefined || sourcePrefix === null ? null : sourcePrefix,
    };
}
function computePublishedPaths(selectedPackNames, manifests) {
    if (selectedPackNames === null || selectedPackNames.size === 0) {
        return null;
    }
    const effectiveNames = new Set(selectedPackNames);
    effectiveNames.add(exports.CORE_PACK_NAME);
    const published = new Set();
    for (const name of effectiveNames) {
        const manifest = manifests.get(name);
        if (manifest === undefined) {
            throw new ManifestError(`No loaded Codex manifest for selected pack '${name}'.`);
        }
        for (const path of manifest.paths) {
            published.add(path);
        }
    }
    return published;
}
function resolveVariantSourcePath(destinationRelativePath, csharpVariant) {
    if (csharpVariant === "legacy" &&
        exports.CSHARP_CANONICAL_PATHS.includes(destinationRelativePath)) {
        if (destinationRelativePath.startsWith(".agents/")) {
            return `${exports.AGENTS_LEGACY_VARIANT_SOURCE_PREFIX}/${destinationRelativePath.slice(".agents/".length)}`;
        }
        if (destinationRelativePath.startsWith(".codex/")) {
            return `${exports.CODEX_LEGACY_VARIANT_SOURCE_PREFIX}/${destinationRelativePath.slice(".codex/".length)}`;
        }
    }
    return destinationRelativePath;
}
function assertSingleCsharpToolchain(publishedPaths, selectedPackNames) {
    const selectedCsharp = [...selectedPackNames]
        .filter((name) => exports.CSHARP_PACK_NAMES.has(name))
        .sort();
    if (selectedCsharp.length > 1) {
        throw new ManifestError("C# mutual exclusion violated: both modern and legacy Codex C# packs were " +
            `selected (${selectedCsharp.join(", ")}); select exactly one C# variant.`);
    }
    void publishedPaths;
}
