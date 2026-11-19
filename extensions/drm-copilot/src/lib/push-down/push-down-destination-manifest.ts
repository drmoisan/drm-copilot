/**
 * Destination manifest of the unified push-down pipeline (issue #1029).
 *
 * Purpose:
 *     Read, validate, hash, and render `.push-down-manifest.json`, the single
 *     destination-root file that records, per pushed-down file, the layer, the
 *     owning pack, and the SHA-256 of the LF-normalized text last written or
 *     adopted. The pipeline compares destination files against these hashes so
 *     a destination's own edits are never overwritten.
 *
 * Invariants / Constraints:
 *     - The rendered text is sorted-key JSON, two-space indented, with a
 *       trailing LF, no byte-order mark, and only the schema fields.
 *     - Paths are destination-relative POSIX paths: no leading `/`, no drive
 *       letter, no UNC prefix, no backslash, and no `..` segment.
 *     - No timestamp and no absolute path is ever rendered.
 *
 * Side effects:
 *     {@link readDestinationManifest} reads through the injected adapter; every
 *     other function is pure.
 */

import { createHash } from "node:crypto";

import { compareCodePoint } from "../string-ordering";
import { type PushDownFileSystem } from "./filesystem-adapter";
import { stringifySorted } from "./copilot-customizations-engine";

/** Destination-root file name of the manifest. */
export const DESTINATION_MANIFEST_RELATIVE_PATH = ".push-down-manifest.json";

/** Schema version written by this release. */
export const DESTINATION_MANIFEST_SCHEMA_VERSION = "1.0.0";

/** The only `schema_version` major version this reader accepts. */
const SUPPORTED_SCHEMA_MAJOR = 1;

/** Ecosystem names that may key a `selection` entry. */
export const MANIFEST_ECOSYSTEM_NAMES: ReadonlyArray<string> = [
  "claude",
  "codex",
  "copilot",
];

/** Layer names that may appear in a `files.<path>.layer` value. */
export const MANIFEST_LAYER_NAMES: ReadonlyArray<string> = [
  "shared",
  "claude",
  "codex",
  "copilot",
];

/** The pack every selection always includes. */
export const MANIFEST_CORE_PACK = "core";

/** Recorded selection of one pushed-down ecosystem. */
export interface DestinationManifestSelection {
  /** Sorted pack names, always including `core`. */
  readonly packs: ReadonlyArray<string>;
  /** C# variant, where the ecosystem has one. */
  readonly csharpVariant?: string;
  /** Agent-memory mode, where the ecosystem has one. */
  readonly memoryMode?: string;
}

/** One managed destination file. */
export interface DestinationManifestFileEntry {
  /** `shared`, `claude`, `codex`, or `copilot`. */
  readonly layer: string;
  /** Owning pack name (`core` for unscoped publishes). */
  readonly pack: string;
  /** Lowercase hex SHA-256 of the LF-normalized text. */
  readonly sha256: string;
}

/** Parsed `.push-down-manifest.json` document. */
export interface DestinationManifest {
  readonly schemaVersion: string;
  readonly payloadVersion: string;
  /** Selection keyed by ecosystem name. */
  readonly selection: Readonly<Record<string, DestinationManifestSelection>>;
  /** Entries keyed by destination-relative POSIX path. */
  readonly files: Readonly<Record<string, DestinationManifestFileEntry>>;
}

/** Raised when the destination manifest cannot be trusted. */
export class DestinationManifestError extends Error {
  /** The manifest field at fault (`(document)` for whole-file conditions). */
  readonly field: string;

  /**
   * @param field Manifest field at fault.
   * @param reason Human-readable reason.
   */
  constructor(field: string, reason: string) {
    super(
      `Invalid push-down destination manifest ${DESTINATION_MANIFEST_RELATIVE_PATH} field '${field}': ${reason}`,
    );
    this.name = "DestinationManifestError";
    this.field = field;
  }
}

/**
 * Normalize CRLF and lone CR line endings to LF.
 *
 * @param text Text in any line-ending style.
 * @returns The LF-normalized text.
 */
export function normalizeLineEndings(text: string): string {
  return text.replace(/\r\n/g, "\n").replace(/\r/g, "\n");
}

/**
 * Hash text as the manifest records it.
 *
 * @param text File text in any line-ending style.
 * @returns Lowercase hex SHA-256 of the UTF-8 bytes of the LF-normalized text.
 */
export function hashPayloadText(text: string): string {
  return createHash("sha256")
    .update(normalizeLineEndings(text), "utf8")
    .digest("hex");
}

/**
 * Describe why a path is not a destination-relative POSIX path.
 *
 * @param path Candidate path.
 * @returns The reason the path is rejected, or `undefined` when it is valid.
 */
export function describeInvalidRelativePath(path: string): string | undefined {
  if (path === "") {
    return "path is empty";
  }
  if (path.includes("\\")) {
    return `path contains a backslash: ${path}`;
  }
  if (path.startsWith("/")) {
    return `path is absolute: ${path}`;
  }
  if (/^[A-Za-z]:/.test(path)) {
    return `path has a drive letter: ${path}`;
  }
  if (path.split("/").includes("..")) {
    return `path has a '..' segment: ${path}`;
  }
  return undefined;
}

/**
 * Narrow a value to a plain JSON object.
 *
 * @param value Candidate value.
 * @returns True when the value is a non-null, non-array object.
 */
function isPlainObject(value: unknown): value is Record<string, unknown> {
  return value !== null && typeof value === "object" && !Array.isArray(value);
}

/**
 * Validate the `schema_version` field.
 *
 * @param value Raw field value.
 * @returns The validated version string.
 * @throws DestinationManifestError When the value is not a supported semver.
 */
function parseSchemaVersion(value: unknown): string {
  if (typeof value !== "string") {
    throw new DestinationManifestError(
      "schema_version",
      "missing or not a string",
    );
  }
  const match = /^(\d+)\.(\d+)\.(\d+)$/.exec(value);
  if (match === null) {
    throw new DestinationManifestError(
      "schema_version",
      `not a semantic version: ${value}`,
    );
  }
  if (Number(match[1]) !== SUPPORTED_SCHEMA_MAJOR) {
    throw new DestinationManifestError(
      "schema_version",
      `unknown major version: ${value}`,
    );
  }
  return value;
}

/**
 * Validate one `selection` value.
 *
 * @param ecosystem Selection key.
 * @param value Raw selection value.
 * @returns The validated selection.
 * @throws DestinationManifestError When the value is malformed.
 */
function parseSelectionEntry(
  ecosystem: string,
  value: unknown,
): DestinationManifestSelection {
  const field = `selection.${ecosystem}`;
  if (!isPlainObject(value)) {
    throw new DestinationManifestError(field, "not an object");
  }
  const packs = value["packs"];
  if (
    !Array.isArray(packs) ||
    !packs.every((pack): pack is string => typeof pack === "string")
  ) {
    throw new DestinationManifestError(
      `${field}.packs`,
      "missing or not a list of strings",
    );
  }
  const sorted = [...packs].sort(compareCodePoint);
  if (sorted.some((pack, index) => pack !== packs[index])) {
    throw new DestinationManifestError(
      `${field}.packs`,
      "packs are not sorted",
    );
  }
  if (!packs.includes(MANIFEST_CORE_PACK)) {
    throw new DestinationManifestError(`${field}.packs`, "packs omit core");
  }
  const csharpVariant = value["csharp_variant"];
  const memoryMode = value["memory_mode"];
  if (csharpVariant !== undefined && typeof csharpVariant !== "string") {
    throw new DestinationManifestError(
      `${field}.csharp_variant`,
      "not a string",
    );
  }
  if (memoryMode !== undefined && typeof memoryMode !== "string") {
    throw new DestinationManifestError(`${field}.memory_mode`, "not a string");
  }
  return {
    packs,
    ...(csharpVariant === undefined ? {} : { csharpVariant }),
    ...(memoryMode === undefined ? {} : { memoryMode }),
  };
}

/**
 * Validate the `selection` field.
 *
 * @param value Raw field value.
 * @returns The validated selection map.
 * @throws DestinationManifestError When a key or value is malformed.
 */
function parseSelection(
  value: unknown,
): Record<string, DestinationManifestSelection> {
  if (!isPlainObject(value)) {
    throw new DestinationManifestError("selection", "missing or not an object");
  }
  const selection: Record<string, DestinationManifestSelection> = {};
  for (const [ecosystem, entry] of Object.entries(value)) {
    if (!MANIFEST_ECOSYSTEM_NAMES.includes(ecosystem)) {
      throw new DestinationManifestError(
        "selection",
        `key is not an ecosystem name: ${ecosystem}`,
      );
    }
    selection[ecosystem] = parseSelectionEntry(ecosystem, entry);
  }
  return selection;
}

/**
 * Validate one `files` entry.
 *
 * @param path Entry key.
 * @param value Raw entry value.
 * @returns The validated entry.
 * @throws DestinationManifestError When the entry is malformed.
 */
function parseFileEntry(
  path: string,
  value: unknown,
): DestinationManifestFileEntry {
  const field = `files.${path}`;
  if (!isPlainObject(value)) {
    throw new DestinationManifestError(field, "not an object");
  }
  const { layer, pack, sha256 } = value;
  if (typeof layer !== "string" || !MANIFEST_LAYER_NAMES.includes(layer)) {
    throw new DestinationManifestError(`${field}.layer`, "unknown layer");
  }
  if (typeof pack !== "string" || pack === "") {
    throw new DestinationManifestError(
      `${field}.pack`,
      "missing or not a non-empty string",
    );
  }
  if (typeof sha256 !== "string" || !/^[0-9a-f]{64}$/.test(sha256)) {
    throw new DestinationManifestError(
      `${field}.sha256`,
      "not a lowercase 64-character hex digest",
    );
  }
  return { layer, pack, sha256 };
}

/**
 * Validate the `files` field.
 *
 * @param value Raw field value.
 * @returns The validated entry map.
 * @throws DestinationManifestError When a path or entry is malformed.
 */
function parseFiles(
  value: unknown,
): Record<string, DestinationManifestFileEntry> {
  if (!isPlainObject(value)) {
    throw new DestinationManifestError("files", "missing or not an object");
  }
  const files: Record<string, DestinationManifestFileEntry> = {};
  for (const [path, entry] of Object.entries(value)) {
    const invalid = describeInvalidRelativePath(path);
    if (invalid !== undefined) {
      throw new DestinationManifestError("files", invalid);
    }
    files[path] = parseFileEntry(path, entry);
  }
  return files;
}

/**
 * Parse and validate manifest text.
 *
 * @param text Raw manifest text.
 * @returns The validated manifest.
 * @throws DestinationManifestError When the text is invalid JSON, has an
 *   unsupported `schema_version`, or misses or malforms a required field.
 */
export function parseDestinationManifest(text: string): DestinationManifest {
  let loaded: unknown;
  try {
    loaded = JSON.parse(text);
  } catch {
    throw new DestinationManifestError("(document)", "not valid JSON");
  }
  if (!isPlainObject(loaded)) {
    throw new DestinationManifestError("(document)", "not a JSON object");
  }
  const schemaVersion = parseSchemaVersion(loaded["schema_version"]);
  const payloadVersion = loaded["payload_version"];
  if (typeof payloadVersion !== "string" || payloadVersion === "") {
    throw new DestinationManifestError(
      "payload_version",
      "missing or not a non-empty string",
    );
  }
  return {
    schemaVersion,
    payloadVersion,
    selection: parseSelection(loaded["selection"]),
    files: parseFiles(loaded["files"]),
  };
}

/**
 * Read the destination manifest, or return `undefined` when it is absent.
 *
 * @param fs Adapter used to probe and read the manifest.
 * @param destinationRoot Destination workspace root (POSIX path).
 * @returns The validated manifest, or `undefined` when no file exists.
 * @throws DestinationManifestError When a directory sits at the manifest path
 *   or the file is invalid.
 */
export function readDestinationManifest(
  fs: PushDownFileSystem,
  destinationRoot: string,
): DestinationManifest | undefined {
  const root = destinationRoot.replace(/\\/g, "/").replace(/\/+$/, "");
  const path = `${root}/${DESTINATION_MANIFEST_RELATIVE_PATH}`;
  if (!fs.isFile(path)) {
    if (fs.isDir(path)) {
      throw new DestinationManifestError(
        "(document)",
        "path is not a regular file",
      );
    }
    return undefined;
  }
  return parseDestinationManifest(fs.readTextFile(path));
}

/**
 * Render a manifest as its committed text.
 *
 * @param manifest Manifest to render.
 * @returns Sorted-key, two-space JSON with a trailing LF and only the schema
 *   fields.
 */
export function renderDestinationManifest(
  manifest: DestinationManifest,
): string {
  const selection: Record<string, Record<string, unknown>> = {};
  for (const [ecosystem, entry] of Object.entries(manifest.selection)) {
    selection[ecosystem] = {
      packs: [...entry.packs],
      ...(entry.csharpVariant === undefined
        ? {}
        : { csharp_variant: entry.csharpVariant }),
      ...(entry.memoryMode === undefined
        ? {}
        : { memory_mode: entry.memoryMode }),
    };
  }
  const files: Record<string, Record<string, string>> = {};
  for (const [path, entry] of Object.entries(manifest.files)) {
    files[path] = {
      layer: entry.layer,
      pack: entry.pack,
      sha256: entry.sha256,
    };
  }
  const document = {
    schema_version: manifest.schemaVersion,
    payload_version: manifest.payloadVersion,
    selection,
    files,
  };
  return `${stringifySorted(document, 2)}\n`;
}
