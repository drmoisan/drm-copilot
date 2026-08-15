/**
 * Destination-aware routing-merge decorator for the Claude push-down.
 *
 * Purpose:
 *     Special-case the single destination-relative path
 *     `config/orchestration-routing.json` so publishing it into a workspace that
 *     already carries its own routing document adds the source's routes without
 *     discarding the destination's. One further path,
 *     `config/blast-radius.json`, is intercepted by the blast-radius derive
 *     decorator composed alongside this one
 *     (`claude-blast-radius-derive.ts`); every remaining path passes straight
 *     through to the wrapped adapter.
 *
 * Why a decorator rather than engine logic:
 *     The merge is Claude-specific and path-specific. Putting it in the shared
 *     `copilot-customizations-engine` would apply it to the Copilot and Codex
 *     entry points, which publish no `config/` tree and must stay unchanged, and
 *     putting it in `rewriteReferences` would be wrong because that hook sees
 *     only the source text and never the destination's current content.
 *
 * Merge rule (pinned for idempotency):
 *     - Destination file absent: write the source text unchanged.
 *     - Destination present: start from the destination document; preserve
 *       destination key order for keys the destination already has; the source
 *       `parallel` route overwrites or is inserted; source routes the
 *       destination lacks and source top-level non-`routes` blocks the
 *       destination lacks are appended in source order.
 *     - Serialization is 2-space indentation with a trailing newline, so pushing
 *       twice is byte-stable.
 *     - An unparseable destination document fails that one file with an explicit
 *       error and its bytes are never written.
 *
 * Side effects:
 *     Reads the destination file and delegates all I/O to the wrapped adapter.
 */

import { type PushDownFileSystem } from "./filesystem-adapter";

/** JSON value shape the routing document is parsed into. */
type JsonValue =
  null | boolean | number | string | JsonValue[] | { [key: string]: JsonValue };

/** JSON object shape used for the document and its `routes` block. */
type JsonObject = { [key: string]: JsonValue };

/** Top-level key holding the route table. */
const ROUTES_KEY = "routes";

/** Route name whose source definition always wins over the destination's. */
const AUTHORITATIVE_ROUTE = "parallel";

/**
 * Error raised when a destination routing document cannot be parsed.
 *
 * Purpose:
 *     Distinguish an unparseable destination file from any other write failure
 *     so the run summary can name the offending path and the publisher can
 *     leave its bytes untouched.
 */
export class RoutingMergeError extends Error {
  /** Destination path whose current content could not be parsed. */
  public readonly path: string;

  /**
   * @param path Destination path that failed to parse.
   * @param detail Parser detail appended to the message.
   */
  constructor(path: string, detail: string) {
    super(
      `Destination routing document is not valid JSON and was not written: ` +
        `${path} (${detail})`,
    );
    this.name = "RoutingMergeError";
    this.path = path;
  }
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
 * Parse text into a JSON object, or throw a {@link RoutingMergeError}.
 *
 * @param text Raw document text.
 * @param path Path reported in the error message.
 * @returns The parsed object.
 * @throws RoutingMergeError When the text is not parseable or not an object.
 */
function parseRoutingObject(text: string, path: string): JsonObject {
  let parsed: unknown;
  try {
    parsed = JSON.parse(text);
  } catch (error) {
    const detail = error instanceof Error ? error.message : String(error);
    throw new RoutingMergeError(path, detail);
  }
  if (parsed === null || typeof parsed !== "object" || Array.isArray(parsed)) {
    throw new RoutingMergeError(path, "document root is not a JSON object");
  }
  return parsed as JsonObject;
}

/**
 * Return a value as a JSON object when it is one, otherwise null.
 *
 * @param value Candidate value read from a parsed document.
 * @returns The value narrowed to an object, or `null`.
 */
function asObject(value: JsonValue | undefined): JsonObject | null {
  if (value === undefined || value === null || typeof value !== "object") {
    return null;
  }
  return Array.isArray(value) ? null : value;
}

/**
 * Merge the source route table into the destination route table.
 *
 * Destination key order is preserved for routes the destination already
 * defines. The source `parallel` route overwrites the destination's; every
 * other destination route is kept verbatim. Source routes the destination lacks
 * are appended in source order.
 *
 * @param destinationRoutes The destination's `routes` block, or null when absent.
 * @param sourceRoutes The source's `routes` block, or null when absent.
 * @returns The merged route table.
 */
function mergeRoutes(
  destinationRoutes: JsonObject | null,
  sourceRoutes: JsonObject | null,
): JsonObject {
  const merged: JsonObject = {};
  // Walk the destination first so its key order survives the merge; only the
  // authoritative route is replaced in place.
  if (destinationRoutes !== null) {
    for (const [name, definition] of Object.entries(destinationRoutes)) {
      const sourceDefinition = sourceRoutes?.[name];
      merged[name] =
        name === AUTHORITATIVE_ROUTE && sourceDefinition !== undefined
          ? sourceDefinition
          : definition;
    }
  }
  // Append the routes the destination does not define, in source order, so a
  // workspace that predates a route (for example `preparation`) receives it.
  if (sourceRoutes !== null) {
    for (const [name, definition] of Object.entries(sourceRoutes)) {
      if (!(name in merged)) {
        merged[name] = definition;
      }
    }
  }
  return merged;
}

/**
 * Merge a source routing document into a destination routing document.
 *
 * @param destinationText Current destination document text.
 * @param sourceText Source document text being published.
 * @param path Destination path reported in a parse error.
 * @returns The merged document text, 2-space indented with a trailing newline.
 * @throws RoutingMergeError When either document is not a JSON object.
 */
export function mergeRoutingDocuments(
  destinationText: string,
  sourceText: string,
  path: string,
): string {
  const destination = parseRoutingObject(destinationText, path);
  const source = parseRoutingObject(sourceText, path);

  const merged: JsonObject = {};
  // Preserve the destination's top-level key order for every key it already
  // carries, replacing only the route table.
  for (const [key, value] of Object.entries(destination)) {
    merged[key] =
      key === ROUTES_KEY
        ? mergeRoutes(asObject(value), asObject(source[ROUTES_KEY]))
        : value;
  }
  // Append the top-level blocks the destination lacks, in source order. The
  // route table is appended here when the destination had none at all.
  for (const [key, value] of Object.entries(source)) {
    if (key in merged) {
      continue;
    }
    merged[key] =
      key === ROUTES_KEY ? mergeRoutes(null, asObject(value)) : value;
  }

  return `${JSON.stringify(merged, null, 2)}\n`;
}

/**
 * Wrap a {@link PushDownFileSystem} so one path is merged instead of overwritten.
 *
 * Every method other than `writeTextFile` delegates unchanged. `writeTextFile`
 * merges only when the target resolves to the configured destination-relative
 * path and the destination file already exists.
 */
export class RoutingMergeFileSystem implements PushDownFileSystem {
  private readonly inner: PushDownFileSystem;
  private readonly destinationRoot: string;
  private readonly mergeRelativePath: string;

  /**
   * @param inner The wrapped adapter performing real I/O.
   * @param destinationRoot Destination workspace root (POSIX path).
   * @param mergeRelativePath Destination-relative path to merge.
   */
  constructor(
    inner: PushDownFileSystem,
    destinationRoot: string,
    mergeRelativePath: string,
  ) {
    this.inner = inner;
    this.destinationRoot = normalizePosix(destinationRoot);
    this.mergeRelativePath = mergeRelativePath;
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
   * Write a file, merging the one configured routing path when it exists.
   *
   * @param path Absolute destination POSIX path.
   * @param content Source content the engine wants to publish.
   * @throws RoutingMergeError When the destination routing document is not
   *   parseable; the destination bytes are left untouched.
   */
  public writeTextFile(path: string, content: string): void {
    if (!this.isMergeTarget(path)) {
      this.inner.writeTextFile(path, content);
      return;
    }
    // An absent destination file has nothing to preserve, so the source text is
    // written unchanged and the second push then merges against it.
    if (!this.inner.isFile(path)) {
      this.inner.writeTextFile(path, content);
      return;
    }
    const merged = mergeRoutingDocuments(
      this.inner.readTextFile(path),
      content,
      path,
    );
    this.inner.writeTextFile(path, merged);
  }

  /**
   * Return whether a destination path is the configured merge target.
   *
   * @param path Absolute destination POSIX path.
   * @returns True when the path resolves to the merge-target relative path.
   */
  private isMergeTarget(path: string): boolean {
    return (
      relativeToPosix(path, this.destinationRoot) === this.mergeRelativePath
    );
  }
}
