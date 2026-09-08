/**
 * Pure derivation core for the destination blast-radius module map.
 *
 * Purpose:
 *     Turn a deterministic, already-collected list of destination directory
 *     observations plus the bundled source document into the serialized
 *     `config/blast-radius.json` a destination workspace should receive. The
 *     bundled map describes drm-copilot's own layout, so publishing it verbatim
 *     gives an unrelated destination a module map that names none of its
 *     modules. Deriving the map from the destination's own layout is what makes
 *     the published document meaningful there.
 *
 * Responsibilities:
 *     Own steps 3 through 8 of the derivation algorithm: prune ancestors, name
 *     and glob the module paths, apply the top-level fallback and the no-signal
 *     floor, assemble and serialize the document, and guard against re-emitting
 *     the location-bucket defect this item fixes. Step 2, classification, and
 *     the manifest vocabulary it reads belong to
 *     `claude-blast-radius-derive-manifests.ts` and are re-exported here.
 *     Collecting the observations (step 1, the destination scan) belongs to
 *     `claude-blast-radius-derive.ts`, which performs the I/O.
 *
 * Invariants / Constraints:
 *     - This module performs no I/O: no `fs`, no `child_process`, no network,
 *       and no clock or randomness access. Every function is pure and mutates no
 *       input.
 *     - Identical observations and identical source text produce a
 *       byte-identical output string.
 *     - The emitted key order is `version`, `shared_surfaces`,
 *       `shared_surface_globs`, `mandate_reads`, `mergeable_paths`, `modules`,
 *       `over_breadth_fraction`, with the two optional keys omitted entirely
 *       when the source document does not declare them.
 *     - An observed .NET manifest suppresses the top-level-directory fallback
 *       (issue #643): a destination that declared its layout with project files
 *       has already stated its structure, so the weaker signal is not used.
 *     - The root directory is categorically excluded from classification. A
 *       root-level manifest would otherwise yield the universal glob `**`, which
 *       is the defect class being fixed.
 *     - The guard is unconditional: no emitted glob may be `**`, `docs/**`, or
 *       `tests/**`, so the derivation can never recreate a location bucket.
 *
 * Side effects:
 *     None.
 */

import {
  classifyProjectDirectories,
  compareOrdinal,
} from "./claude-blast-radius-derive-manifests";
import type { DirectoryObservation } from "./claude-blast-radius-derive-manifests";

export {
  MANIFEST_FILENAMES,
  MANIFEST_SUFFIXES,
  MODULE_MANIFEST_SUFFIXES,
  NON_MODULE_MANIFEST_SUFFIXES,
  EXCLUDED_DIR_NAMES,
  isExcludedDirectoryName,
  isManifestFileName,
  classifyProjectDirectories,
} from "./claude-blast-radius-derive-manifests";
export type {
  DirectoryObservation,
  ProjectDirectoryClassification,
} from "./claude-blast-radius-derive-manifests";

/** JSON value shape the bundled source document is parsed into. */
type JsonValue =
  null | boolean | number | string | JsonValue[] | { [key: string]: JsonValue };

/** JSON object shape used for the parsed source document. */
type JsonObject = { [key: string]: JsonValue };

/** Destination-relative path of the document this core derives. */
export const BLAST_RADIUS_RELATIVE_PATH = "config/blast-radius.json";

/**
 * Maximum scan depth: the destination top level plus two nested levels.
 *
 * The bound exists so the scan never performs an unpruned recursive walk of a
 * destination workspace, which would traverse dependency and history trees.
 */
export const SCAN_DEPTH_LIMIT = 3;

/**
 * Modules the push-down itself creates in the destination.
 *
 * The push-down publishes a `.claude` tree and a `config` tree, but only
 * `config` is a module. A payload module wins on a name collision with a
 * derived module because it describes the payload rather than a guess.
 *
 * @remarks
 * The `.claude` tree is deliberately NOT a module. Every agent in the runtime
 * is instructed to read the policy rules and process skills before doing any
 * work, so a `.claude/**` umbrella matches nearly every radius. A level that
 * always fires carries no contention information and only suppresses
 * concurrency, which is exactly the module-map granularity criterion recorded
 * in `.claude/rules/parallel-orchestration.md`.
 *
 * Removing it never weakens the relation below the path level: two items
 * editing the same hook still contend on `path_overlap`, and two items editing
 * a declared shared surface still contend on `shared_surface_overlap`.
 *
 * `config` is retained because `config/**` in a destination holds only the two
 * published files, so it names a subsystem an item can plausibly not touch.
 * Retaining it also keeps the assembled map non-empty, which gives
 * {@link assertNoForbiddenGlob} a non-vacuous input rather than a guard that
 * passes because it was handed nothing to check.
 */
export const PAYLOAD_MODULES: Readonly<Record<string, ReadonlyArray<string>>> =
  {
    config: ["config/**"],
  };

/** Globs the derivation may never emit, in the order the guard reports them. */
export const FORBIDDEN_GLOBS: ReadonlyArray<string> = [
  "**",
  "docs/**",
  "tests/**",
];

/**
 * Top-level keys carried verbatim from the bundled source document.
 *
 * The assembly literal indexes this array positionally, so a new key is
 * APPENDED rather than inserted: inserting mid-array would shift every existing
 * index. `mandate_reads` (issue #489) and `mergeable_paths` (issue #643) are
 * both optional in the source document, and `JSON.stringify` drops an
 * `undefined`-valued property, so an absent source key emits no property
 * without a conditional spread.
 */
const CARRIED_KEYS = [
  "version",
  "shared_surfaces",
  "shared_surface_globs",
  "over_breadth_fraction",
  "mandate_reads",
  "mergeable_paths",
] as const;

/**
 * Error raised when the bundled source document cannot be parsed.
 *
 * Purpose:
 *     Distinguish an unparseable bundled document from any other failure so the
 *     run summary can name the offending path and the publisher can leave the
 *     destination bytes untouched. Follows the `RoutingMergeError` precedent in
 *     `claude-routing-merge.ts`.
 */
export class BlastRadiusDeriveError extends Error {
  /** Destination-relative path of the document that failed to parse. */
  public readonly path: string;

  /**
   * @param path Path named in the message.
   * @param detail Parser detail appended to the message.
   */
  constructor(path: string, detail: string) {
    super(
      `Bundled blast-radius document is not valid JSON and was not written: ` +
        `${path} (${detail})`,
    );
    this.name = "BlastRadiusDeriveError";
    this.path = path;
  }
}

/**
 * Error raised when the derivation would emit a forbidden glob.
 *
 * Purpose:
 *     Make the in-code assertion that the derivation can never recreate the
 *     universal-glob or location-bucket defect observable and testable. The
 *     guard throws before any output is produced, so no destination write can
 *     follow a trip.
 */
export class BlastRadiusGuardError extends Error {
  /** The forbidden glob that tripped the guard. */
  public readonly glob: string;

  /** Name of the module that would have carried the forbidden glob. */
  public readonly moduleName: string;

  /**
   * @param moduleName Module the forbidden glob was assigned to.
   * @param glob The forbidden glob.
   */
  constructor(moduleName: string, glob: string) {
    super(
      `Derived blast-radius module ${moduleName} would emit the forbidden ` +
        `glob ${glob}; the derivation was aborted before writing.`,
    );
    this.name = "BlastRadiusGuardError";
    this.glob = glob;
    this.moduleName = moduleName;
  }
}

/**
 * Drop every path that is a proper ancestor of another path (step 3).
 *
 * Leaf granularity maximizes concurrency. An umbrella module covering sibling
 * projects would make every sibling contend with every other, which is the same
 * coupling the removed `docs` bucket produced.
 *
 * @param paths Candidate project-directory paths.
 * @returns The subset that has no descendant in the input, order preserved.
 */
function pruneAncestors(paths: ReadonlyArray<string>): string[] {
  // A path is an ancestor of another exactly when that other path starts with
  // it followed by a separator; the separator anchor keeps a sibling whose name
  // merely shares a character prefix from being treated as a descendant.
  return paths.filter(
    (candidate) =>
      !paths.some(
        (other) => other !== candidate && other.startsWith(`${candidate}/`),
      ),
  );
}

/**
 * Select the non-excluded top-level directories (algorithm step 5 fallback).
 *
 * @param observations Every visited directory, including the root.
 * @returns Top-level directory names, ordinally sorted. Excluded names are
 *   absent because the scanner never observes them.
 */
function topLevelDirectories(
  observations: ReadonlyArray<DirectoryObservation>,
): string[] {
  const names: string[] = [];
  // A top-level directory is an observation one segment deep; the root itself
  // has an empty relative path and is skipped.
  for (const observation of observations) {
    const relativePath = observation.relativePath;
    if (relativePath !== "" && !relativePath.includes("/")) {
      names.push(relativePath);
    }
  }
  return names.sort(compareOrdinal);
}

/**
 * Build the module map from derived paths and the payload modules (step 7).
 *
 * @param derivedPaths Destination-relative paths that became modules.
 * @returns The module map, module names ordinally sorted, payload modules
 *   winning on a name collision.
 */
function assembleModules(
  derivedPaths: ReadonlyArray<string>,
): Record<string, string[]> {
  const combined = new Map<string, string[]>();
  // Derived modules are inserted first so a payload module of the same name
  // overwrites them; the payload describes what was actually published, while a
  // derived entry of the same name is an inference about the destination.
  for (const path of derivedPaths) {
    combined.set(path, [`${path}/**`]);
  }
  for (const [name, globs] of Object.entries(PAYLOAD_MODULES)) {
    combined.set(name, [...globs]);
  }

  const modules: Record<string, string[]> = {};
  // Insertion order determines the serialized key order, so the names are
  // sorted before insertion rather than after.
  for (const name of [...combined.keys()].sort(compareOrdinal)) {
    const globs = combined.get(name);
    if (globs !== undefined) {
      modules[name] = globs;
    }
  }
  return modules;
}

/**
 * Reject a module map that carries a forbidden glob (algorithm step 8).
 *
 * @param modules The assembled module map.
 * @throws BlastRadiusGuardError When any glob is `**`, `docs/**`, or `tests/**`.
 */
function assertNoForbiddenGlob(modules: Record<string, string[]>): void {
  // Checking the assembled map rather than each derivation step means the guard
  // covers the payload modules and any future contributor to the map as well.
  for (const [name, globs] of Object.entries(modules)) {
    for (const glob of globs) {
      if (FORBIDDEN_GLOBS.includes(glob)) {
        throw new BlastRadiusGuardError(name, glob);
      }
    }
  }
}

/**
 * Parse the bundled source document into a JSON object.
 *
 * @param text Raw bundled document text.
 * @returns The parsed object.
 * @throws BlastRadiusDeriveError When the text is unparseable or not an object.
 */
function parseSourceDocument(text: string): JsonObject {
  let parsed: unknown;
  try {
    parsed = JSON.parse(text);
  } catch (error) {
    const detail = error instanceof Error ? error.message : String(error);
    throw new BlastRadiusDeriveError(BLAST_RADIUS_RELATIVE_PATH, detail);
  }
  if (parsed === null || typeof parsed !== "object" || Array.isArray(parsed)) {
    throw new BlastRadiusDeriveError(
      BLAST_RADIUS_RELATIVE_PATH,
      "document root is not a JSON object",
    );
  }
  return parsed as JsonObject;
}

/**
 * Derive the destination blast-radius document from a destination scan.
 *
 * Executes algorithm steps 2 through 8: classify project directories, prune
 * ancestors, name and glob them, fall back to the top-level directories when no
 * project directory was found, floor to the payload modules when the fallback is
 * empty too, assemble the document, guard it, and serialize.
 *
 * @param observations Deterministic list of visited destination directories,
 *   including the destination root. Supplying an empty list is valid and yields
 *   the no-signal floor.
 * @param sourceDocumentText Text of the bundled `config/blast-radius.json`.
 * @returns The serialized destination document: 2-space indented with a
 *   trailing newline, keys in the order `version`, `shared_surfaces`,
 *   `shared_surface_globs`, `mandate_reads`, `mergeable_paths`, `modules`,
 *   `over_breadth_fraction`. `mandate_reads` and `mergeable_paths` are each
 *   omitted entirely when the bundled source document does not declare them.
 *   An observed .NET manifest suppresses the top-level-directory fallback, so a
 *   destination whose only structure is .NET project files derives no module
 *   beyond the payload floor.
 * @throws BlastRadiusDeriveError When the bundled document is not parseable.
 * @throws BlastRadiusGuardError When an emitted glob is forbidden. The guard
 *   runs before the return, so a trip produces no output at all.
 */
export function deriveDestinationModuleMap(
  observations: ReadonlyArray<DirectoryObservation>,
  sourceDocumentText: string,
): string {
  const source = parseSourceDocument(sourceDocumentText);

  // Project directories are the primary signal. An observed .NET manifest is a
  // structure signal that yields no module of its own, and it SUPPRESSES the
  // top-level-directory fallback: a destination that declared its layout with
  // project files has already said what it is, so falling back to its top-level
  // directories would substitute a weaker signal for a stronger one (issue
  // #643). When nothing at all was observed the payload modules alone are the
  // computed outcome for a structureless destination.
  const classification = classifyProjectDirectories(observations);
  const modulePaths = pruneAncestors(classification.modulePaths);
  const derivedPaths =
    modulePaths.length > 0
      ? modulePaths
      : classification.structureObserved
        ? []
        : topLevelDirectories(observations);

  const modules = assembleModules(derivedPaths);
  assertNoForbiddenGlob(modules);

  // The literal's property order is the serialized key order, so the fixed
  // emission order is expressed here rather than by a separate sort.
  const document = {
    version: source[CARRIED_KEYS[0]],
    shared_surfaces: source[CARRIED_KEYS[1]],
    shared_surface_globs: source[CARRIED_KEYS[2]],
    mandate_reads: source[CARRIED_KEYS[4]],
    mergeable_paths: source[CARRIED_KEYS[5]],
    modules,
    over_breadth_fraction: source[CARRIED_KEYS[3]],
  };

  return `${JSON.stringify(document, null, 2)}\n`;
}
