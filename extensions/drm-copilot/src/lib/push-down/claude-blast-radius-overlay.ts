/**
 * Destination blast-radius overlay for the Claude push-down (issue #508).
 *
 * Purpose:
 *     Every push regenerates `config/blast-radius.json` from the bundled base
 *     and the destination layout, so an entry hand-added to that file is lost.
 *     A destination records its own entries in the destination-owned overlay
 *     `config/blast-radius.local.json`; {@link composeBlastRadiusOverlay}
 *     composes that overlay onto the regenerated base at push time. The overlay
 *     file itself is only read, never written or published.
 *
 * Composition rules (identical in `push_down_claude_blast_radius_overlay.py`):
 *     - Overlay absent: the base text is returned byte for byte.
 *     - `version` must equal the base `version`; the base value is emitted.
 *     - String-list keys: ordered union, base entries first.
 *     - `modules`: overlay modules are added or replace a same-name module;
 *       names are emitted in ordinal order and the forbidden-glob guard applies.
 *     - Other keys in both: objects merge recursively, lists union, otherwise
 *       the overlay value wins. Overlay-only keys are appended in overlay order.
 *     - Every error is raised before any write.
 */

import { type PushDownFileSystem } from "./filesystem-adapter";
import {
  BLAST_RADIUS_RELATIVE_PATH,
  BlastRadiusGuardError,
  FORBIDDEN_GLOBS,
} from "./claude-blast-radius-derive-core";
import { compareOrdinal } from "./claude-blast-radius-derive-manifests";

/** Destination-relative path of the destination-owned overlay. */
export const BLAST_RADIUS_OVERLAY_RELATIVE_PATH =
  "config/blast-radius.local.json";

/** JSON value shape a blast-radius document is parsed into. */
type JsonValue =
  null | boolean | number | string | JsonValue[] | { [key: string]: JsonValue };

/** JSON object shape used for documents and nested blocks. */
type JsonObject = { [key: string]: JsonValue };

/** Keys whose value is an ordered list of strings composed by union. */
const STRING_LIST_KEYS: ReadonlySet<string> = new Set([
  "shared_surfaces",
  "shared_surface_globs",
  "mandate_reads",
  "mergeable_paths",
  "path_roots",
]);

/** Key holding the module-name to glob-list map. */
const MODULES_KEY = "modules";

/** Key whose overlay value must equal the base value. */
const VERSION_KEY = "version";

/**
 * Error raised when a blast-radius overlay cannot be composed.
 *
 * The message names the offending file and, where one applies, the key. The
 * destination `config/blast-radius.json` is never written when it is raised.
 */
export class BlastRadiusOverlayError extends Error {
  /** Relative path of the document that could not be composed. */
  public readonly path: string;

  /**
   * @param path Relative path of the offending document.
   * @param detail Reason appended to the message.
   */
  constructor(path: string, detail: string) {
    super(
      `Blast-radius overlay ${path} was not applied; ` +
        `${BLAST_RADIUS_RELATIVE_PATH} was not written: ${detail}`,
    );
    this.name = "BlastRadiusOverlayError";
    this.path = path;
  }
}

/**
 * Return whether a parsed value is a plain JSON object.
 *
 * @param value Candidate parsed value.
 * @returns True for a non-null, non-array object.
 */
function isJsonObject(value: unknown): value is JsonObject {
  return value !== null && typeof value === "object" && !Array.isArray(value);
}

/**
 * Return whether a parsed value is a list whose members are all strings.
 *
 * @param value Candidate parsed value.
 * @returns True for an array of strings (including an empty array).
 */
function isStringList(value: unknown): value is string[] {
  return (
    Array.isArray(value) && value.every((item) => typeof item === "string")
  );
}

/**
 * Parse text into a JSON object or throw {@link BlastRadiusOverlayError}.
 *
 * @param text Raw document text.
 * @param path Relative path reported in the error.
 * @returns The parsed object.
 */
function parseObject(text: string, path: string): JsonObject {
  let parsed: unknown;
  try {
    parsed = JSON.parse(text);
  } catch (error) {
    const detail = error instanceof Error ? error.message : String(error);
    throw new BlastRadiusOverlayError(path, `not valid JSON (${detail})`);
  }
  if (!isJsonObject(parsed)) {
    throw new BlastRadiusOverlayError(
      path,
      "document root is not a JSON object",
    );
  }
  return parsed;
}

/**
 * Return the ordered union of a base list and overlay strings.
 *
 * @param base Base entries, kept in base order.
 * @param overlay Overlay entries appended in overlay order when not present.
 * @returns The composed list.
 */
function unionStrings(
  base: ReadonlyArray<JsonValue>,
  overlay: ReadonlyArray<string>,
): JsonValue[] {
  const composed: JsonValue[] = [...base];
  const seen = new Set(base.filter((item) => typeof item === "string"));
  for (const item of overlay) {
    if (!seen.has(item)) {
      seen.add(item);
      composed.push(item);
    }
  }
  return composed;
}

/**
 * Compose one string-list key.
 *
 * @param key Top-level key name, reported in the error.
 * @param base Base value, or undefined when the base lacks the key.
 * @param overlay Overlay value.
 * @param overlayPath Overlay path reported in the error.
 * @returns The composed list.
 */
function composeStringList(
  key: string,
  base: JsonValue | undefined,
  overlay: JsonValue,
  overlayPath: string,
): JsonValue[] {
  if (!isStringList(overlay)) {
    throw new BlastRadiusOverlayError(
      overlayPath,
      `key "${key}" must be a list of strings`,
    );
  }
  return unionStrings(Array.isArray(base) ? base : [], overlay);
}

/**
 * Compose the `modules` map and apply the forbidden-glob guard.
 *
 * @param base Base value, or undefined when the base lacks the key.
 * @param overlay Overlay value.
 * @param overlayPath Overlay path reported in the error.
 * @returns The composed map with module names in ordinal order.
 */
function composeModules(
  base: JsonValue | undefined,
  overlay: JsonValue,
  overlayPath: string,
): JsonObject {
  if (
    !isJsonObject(overlay) ||
    !Object.values(overlay).every((globs) => isStringList(globs))
  ) {
    throw new BlastRadiusOverlayError(
      overlayPath,
      `key "${MODULES_KEY}" must map module names to lists of strings`,
    );
  }
  const merged: JsonObject = { ...(isJsonObject(base) ? base : {}) };
  for (const [name, globs] of Object.entries(overlay)) {
    merged[name] = globs;
  }
  const composed: JsonObject = {};
  for (const name of Object.keys(merged).sort(compareOrdinal)) {
    const globs = merged[name] ?? [];
    composed[name] = globs;
    for (const glob of Array.isArray(globs) ? globs : []) {
      if (typeof glob === "string" && FORBIDDEN_GLOBS.includes(glob)) {
        throw new BlastRadiusGuardError(name, glob);
      }
    }
  }
  return composed;
}

/**
 * Merge an overlay value into a base value for a key present in both.
 *
 * @param base Base value.
 * @param overlay Overlay value.
 * @param dottedKey Dotted key path reported in the error.
 * @param overlayPath Overlay path reported in the error.
 * @returns The merged value.
 */
function mergeValues(
  base: JsonValue,
  overlay: JsonValue,
  dottedKey: string,
  overlayPath: string,
): JsonValue {
  if (isJsonObject(base) && isJsonObject(overlay)) {
    const merged: JsonObject = {};
    for (const [key, value] of Object.entries(base)) {
      const overlayValue = overlay[key];
      merged[key] =
        overlayValue === undefined
          ? value
          : mergeValues(
              value,
              overlayValue,
              `${dottedKey}.${key}`,
              overlayPath,
            );
    }
    for (const [key, value] of Object.entries(overlay)) {
      if (!(key in merged)) {
        merged[key] = value;
      }
    }
    return merged;
  }
  if (Array.isArray(base) && Array.isArray(overlay)) {
    if (!isStringList(overlay)) {
      throw new BlastRadiusOverlayError(
        overlayPath,
        `key "${dottedKey}" must be a list of strings`,
      );
    }
    return unionStrings(base, overlay);
  }
  return overlay;
}

/**
 * Compose one overlay key onto the base document.
 *
 * @param key Top-level key.
 * @param base Base value, or undefined when the base lacks the key.
 * @param overlay Overlay value.
 * @param overlayPath Overlay path reported in the error.
 * @returns The composed value.
 */
function composeKey(
  key: string,
  base: JsonValue | undefined,
  overlay: JsonValue,
  overlayPath: string,
): JsonValue {
  if (STRING_LIST_KEYS.has(key)) {
    return composeStringList(key, base, overlay, overlayPath);
  }
  if (key === MODULES_KEY) {
    return composeModules(base, overlay, overlayPath);
  }
  return base === undefined
    ? overlay
    : mergeValues(base, overlay, key, overlayPath);
}

/**
 * Compose a destination overlay onto a regenerated blast-radius document.
 *
 * @param baseText Regenerated `config/blast-radius.json` text.
 * @param overlayText Overlay text, or null when the destination has none.
 * @param overlayPath Overlay path reported in an error.
 * @returns The base text unchanged when the overlay is absent; otherwise the
 *   composed document, 2-space indented with a trailing newline.
 * @throws BlastRadiusOverlayError When either document is malformed, a key has
 *   the wrong shape, or the overlay `version` differs from the base.
 * @throws BlastRadiusGuardError When a composed module carries a forbidden glob.
 */
export function composeBlastRadiusOverlay(
  baseText: string,
  overlayText: string | null,
  overlayPath: string,
): string {
  if (overlayText === null) {
    return baseText;
  }
  const overlay = parseObject(overlayText, overlayPath);
  const base = parseObject(baseText, BLAST_RADIUS_RELATIVE_PATH);
  if (VERSION_KEY in overlay && overlay[VERSION_KEY] !== base[VERSION_KEY]) {
    throw new BlastRadiusOverlayError(
      overlayPath,
      `key "${VERSION_KEY}" does not match the base version`,
    );
  }
  const composed: JsonObject = {};
  for (const [key, value] of Object.entries(base)) {
    const overlayValue = overlay[key];
    composed[key] =
      key === VERSION_KEY || overlayValue === undefined
        ? value
        : composeKey(key, value, overlayValue, overlayPath);
  }
  for (const [key, value] of Object.entries(overlay)) {
    if (!(key in composed)) {
      composed[key] = composeKey(key, undefined, value, overlayPath);
    }
  }
  return `${JSON.stringify(composed, null, 2)}\n`;
}

/**
 * Normalize a path to forward-slash separators with no trailing slash.
 *
 * @param value Path that may use OS-specific separators.
 * @returns Forward-slash POSIX path without a trailing separator.
 */
function normalizePosix(value: string): string {
  return value.replace(/\\/g, "/").replace(/\/+$/, "");
}

/**
 * Return the POSIX path relative to a root, or null when not under the root.
 *
 * Identical in behavior to the helper in `claude-routing-merge.ts`.
 *
 * @param path Candidate child POSIX path.
 * @param root Candidate parent POSIX path.
 * @returns The relative POSIX path, or `null` when not under the root.
 */
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

/**
 * Wrap a {@link PushDownFileSystem} so the blast-radius write carries the
 * destination overlay.
 *
 * Every method other than `writeTextFile` delegates unchanged. A write to the
 * target path is composed with the destination overlay when the overlay file
 * exists; the overlay path is only read, never written.
 */
export class BlastRadiusOverlayFileSystem implements PushDownFileSystem {
  private readonly inner: PushDownFileSystem;
  private readonly destinationRoot: string;
  private readonly overlayRelativePath: string;
  private readonly targetRelativePath: string;

  /**
   * @param inner The wrapped adapter performing real I/O.
   * @param destinationRoot Destination workspace root (POSIX path).
   * @param overlayRelativePath Destination-relative overlay path.
   * @param targetRelativePath Destination-relative path the overlay composes
   *   onto.
   */
  constructor(
    inner: PushDownFileSystem,
    destinationRoot: string,
    overlayRelativePath: string = BLAST_RADIUS_OVERLAY_RELATIVE_PATH,
    targetRelativePath: string = BLAST_RADIUS_RELATIVE_PATH,
  ) {
    this.inner = inner;
    this.destinationRoot = normalizePosix(destinationRoot);
    this.overlayRelativePath = overlayRelativePath;
    this.targetRelativePath = targetRelativePath;
  }

  /** @inheritdoc */
  public listFiles(root: string): string[] {
    return this.inner.listFiles(root);
  }

  /** @inheritdoc */
  public isDir(path: string): boolean {
    return this.inner.isDir(path);
  }

  /** @inheritdoc */
  public isFile(path: string): boolean {
    return this.inner.isFile(path);
  }

  /** @inheritdoc */
  public readTextFile(path: string): string {
    return this.inner.readTextFile(path);
  }

  /** @inheritdoc */
  public ensureDir(path: string): void {
    this.inner.ensureDir(path);
  }

  /**
   * Write a file, composing the destination overlay onto the target path.
   *
   * @param path Absolute destination POSIX path.
   * @param content Content the layers above want to publish.
   * @throws BlastRadiusOverlayError When the overlay cannot be composed; the
   *   destination target keeps its prior bytes.
   * @throws BlastRadiusGuardError When a composed module carries a forbidden
   *   glob; the destination target keeps its prior bytes.
   */
  public writeTextFile(path: string, content: string): void {
    if (
      relativeToPosix(path, this.destinationRoot) !== this.targetRelativePath
    ) {
      this.inner.writeTextFile(path, content);
      return;
    }
    const overlayPath = `${this.destinationRoot}/${this.overlayRelativePath}`;
    const overlayText = this.inner.isFile(overlayPath)
      ? this.inner.readTextFile(overlayPath)
      : null;
    const composed = composeBlastRadiusOverlay(
      content,
      overlayText,
      this.overlayRelativePath,
    );
    this.inner.writeTextFile(path, composed);
  }
}
