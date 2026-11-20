/**
 * Development-docs root resolver (issue #1035, Phase 1 of #1016).
 *
 * Purpose:
 *     Resolve the configured development-records root from the flat key
 *     `development_docs_root` of `config/orchestration-routing.json`, map
 *     area names onto that root, and expose the known-root prefixes that
 *     matchers accept during the fallback release.
 *
 * Resolution rules (spec "Resolution semantics"):
 *     R-1 file absent or unreadable -> `docs/features`.
 *     R-2 key absent -> `docs/features` (no `.dev` probe).
 *     R-3 malformed JSON -> explicit error.
 *     R-4 value outside the closed set -> explicit error.
 *     R-5 value `docs/features` -> `docs/features`.
 *     R-6 value `.dev`, `.dev` exists -> `.dev`.
 *     R-7 value `.dev`, `.dev` absent, `docs/features` exists -> `docs/features`.
 *     R-8 value `.dev`, neither exists -> `.dev`.
 *
 * Side effects:
 *     None. All I/O goes through the injected structural reader, which the
 *     repository `FileSystem` satisfies. This module imports no `vscode` API.
 */

/** Flat top-level key of `config/orchestration-routing.json`. */
export const DEVELOPMENT_DOCS_ROOT_KEY = "development_docs_root";

/** Repository-relative path of the routing configuration file. */
export const DEVELOPMENT_DOCS_ROUTING_FILE =
  "config/orchestration-routing.json";

/** A member of the closed root set. */
export type DevelopmentDocsRoot = "docs/features" | ".dev";

/** Default root when the file or key is absent. */
export const DEFAULT_DEVELOPMENT_DOCS_ROOT: DevelopmentDocsRoot =
  "docs/features";

/** The closed root set, in order: the default root first. */
export const KNOWN_DEVELOPMENT_DOCS_ROOTS: ReadonlyArray<DevelopmentDocsRoot> =
  ["docs/features", ".dev"];

/** Area names that consumers request instead of concatenating paths. */
export type DevelopmentDocsArea =
  | "active"
  | "completed"
  | "archive"
  | "potential"
  | "potential/promoted"
  | "epics"
  | "parallel"
  | "templates"
  | "backlog"
  | "research"
  | "discovery-templates"
  | "engineering";

/** Every area name of the area map, in table order. */
export const DEVELOPMENT_DOCS_AREAS: ReadonlyArray<DevelopmentDocsArea> = [
  "active",
  "completed",
  "archive",
  "potential",
  "potential/promoted",
  "epics",
  "parallel",
  "templates",
  "backlog",
  "research",
  "discovery-templates",
  "engineering",
];

/**
 * Structural reader the resolver needs (D-P5). `FileSystem` satisfies it.
 */
export interface DevelopmentDocsReader {
  /** True when the path exists. */
  exists(path: string): boolean;
  /** True when the path exists and is a directory. */
  isDirectory(path: string): boolean;
  /** Read UTF-8 text; throws when unreadable. */
  readTextFile(path: string): string;
}

/** Areas whose path is the same directory name under each root. */
const ROOT_CHILD_AREAS: ReadonlySet<string> = new Set([
  "active",
  "completed",
  "archive",
  "potential",
  "potential/promoted",
  "epics",
  "parallel",
  "templates",
]);

/** Areas whose `docs/features` form sits outside `docs/features`. */
const SIBLING_AREA_PATHS: Readonly<
  Record<string, Readonly<Record<DevelopmentDocsRoot, string>>>
> = {
  backlog: {
    "docs/features": "docs/features/backlog.md",
    ".dev": ".dev/backlog.md",
  },
  research: { "docs/features": "docs/research", ".dev": ".dev/research" },
  "discovery-templates": {
    "docs/features": "docs/discovery/templates",
    ".dev": ".dev/discovery/templates",
  },
  engineering: {
    "docs/features": "docs/engineering",
    ".dev": ".dev/engineering",
  },
};

/** Areas whose path names a file rather than a directory. */
const FILE_AREAS: ReadonlySet<string> = new Set(["backlog"]);

/**
 * Join a workspace root and a repository-relative path with `/`.
 *
 * @param workspaceRoot Workspace root, with either separator.
 * @param relative Repository-relative forward-slash path.
 * @returns The joined forward-slash path.
 */
function joinWorkspace(workspaceRoot: string, relative: string): string {
  const base = workspaceRoot.replace(/\\/g, "/").replace(/\/+$/, "");
  return base === "" ? relative : `${base}/${relative}`;
}

/**
 * Describe a configured value for an error message.
 *
 * @param value Any parsed JSON value.
 * @returns A JSON rendering, or `undefined` for an absent value.
 */
function describeValue(value: unknown): string {
  const rendered = JSON.stringify(value);
  return rendered === undefined ? "undefined" : rendered;
}

/**
 * Narrow a value to a member of the closed root set.
 *
 * @param value Candidate value.
 * @returns True when the value is exactly a known root.
 */
export function isKnownDevelopmentDocsRoot(
  value: unknown,
): value is DevelopmentDocsRoot {
  return (
    typeof value === "string" &&
    (KNOWN_DEVELOPMENT_DOCS_ROOTS as ReadonlyArray<string>).includes(value)
  );
}

/**
 * Resolve the development-docs root for a workspace (R-1 to R-8).
 *
 * @param reader Structural reader; the repository `FileSystem` satisfies it.
 * @param workspaceRoot Workspace root that holds `config/orchestration-routing.json`.
 * @returns The resolved root.
 * @throws Error For malformed JSON (R-3) or a value outside the closed set (R-4);
 *     the message names the file, the key and the value.
 */
export function resolveDevelopmentDocsRoot(
  reader: DevelopmentDocsReader,
  workspaceRoot: string,
): DevelopmentDocsRoot {
  const configPath = joinWorkspace(
    workspaceRoot,
    DEVELOPMENT_DOCS_ROUTING_FILE,
  );
  if (!reader.exists(configPath)) {
    return DEFAULT_DEVELOPMENT_DOCS_ROOT;
  }
  let text: string;
  try {
    text = reader.readTextFile(configPath);
  } catch {
    // R-1: an unreadable file resolves the default root.
    return DEFAULT_DEVELOPMENT_DOCS_ROOT;
  }
  let parsed: unknown;
  try {
    parsed = JSON.parse(text) as unknown;
  } catch (error) {
    const detail = error instanceof Error ? error.message : String(error);
    throw new Error(
      `${DEVELOPMENT_DOCS_ROUTING_FILE} is not valid JSON, so ${DEVELOPMENT_DOCS_ROOT_KEY} cannot be read (value: unparseable; ${detail}).`,
      { cause: error },
    );
  }
  if (typeof parsed !== "object" || parsed === null || Array.isArray(parsed)) {
    throw new Error(
      `${DEVELOPMENT_DOCS_ROUTING_FILE} is not a JSON object, so ${DEVELOPMENT_DOCS_ROOT_KEY} cannot be read (value: ${describeValue(parsed)}).`,
    );
  }
  const record = parsed as Record<string, unknown>;
  if (
    !Object.prototype.hasOwnProperty.call(record, DEVELOPMENT_DOCS_ROOT_KEY)
  ) {
    return DEFAULT_DEVELOPMENT_DOCS_ROOT;
  }
  const value = record[DEVELOPMENT_DOCS_ROOT_KEY];
  if (!isKnownDevelopmentDocsRoot(value)) {
    throw new Error(
      `${DEVELOPMENT_DOCS_ROUTING_FILE} ${DEVELOPMENT_DOCS_ROOT_KEY} value ${describeValue(value)} is not one of: ${KNOWN_DEVELOPMENT_DOCS_ROOTS.join(", ")}.`,
    );
  }
  if (value === DEFAULT_DEVELOPMENT_DOCS_ROOT) {
    return value;
  }
  if (reader.isDirectory(joinWorkspace(workspaceRoot, ".dev"))) {
    return ".dev";
  }
  if (
    reader.isDirectory(
      joinWorkspace(workspaceRoot, DEFAULT_DEVELOPMENT_DOCS_ROOT),
    )
  ) {
    return DEFAULT_DEVELOPMENT_DOCS_ROOT;
  }
  return ".dev";
}

/**
 * Map an area name onto a root (spec "Area map").
 *
 * @param root A known root.
 * @param area An area name of the area map.
 * @returns The repository-relative forward-slash path of the area.
 * @throws Error When the area is not in the area map.
 */
export function developmentDocsPath(
  root: DevelopmentDocsRoot,
  area: DevelopmentDocsArea,
): string {
  if (ROOT_CHILD_AREAS.has(area)) {
    return `${root}/${area}`;
  }
  const sibling = Object.prototype.hasOwnProperty.call(SIBLING_AREA_PATHS, area)
    ? SIBLING_AREA_PATHS[area]
    : undefined;
  if (sibling === undefined) {
    throw new Error(`Unknown development docs area: ${String(area)}`);
  }
  return sibling[root];
}

/**
 * Return the prefixes of an area under every known root, in root order.
 * Directory areas end with `/`; the file area `backlog` is the exact path.
 *
 * @param area An area name of the area map.
 * @returns One prefix per known root.
 * @throws Error When the area is not in the area map.
 */
export function knownRootPrefixes(
  area: DevelopmentDocsArea,
): ReadonlyArray<string> {
  const suffix = FILE_AREAS.has(area) ? "" : "/";
  return KNOWN_DEVELOPMENT_DOCS_ROOTS.map(
    (root) => `${developmentDocsPath(root, area)}${suffix}`,
  );
}
