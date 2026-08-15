/**
 * Destination-aware blast-radius derivation decorator for the Claude push-down.
 *
 * Purpose:
 *     Special-case the single destination-relative path
 *     `config/blast-radius.json` so publishing it into an unrelated workspace
 *     writes a module map derived from that workspace's own layout rather than
 *     the bundled map, which describes drm-copilot's layout and names none of
 *     the destination's modules. Every other path passes straight through to the
 *     wrapped adapter.
 *
 * Why a decorator rather than engine logic:
 *     The substitution is Claude-specific and path-specific, exactly like the
 *     routing merge it is modeled on ({@link RoutingMergeFileSystem} in
 *     `claude-routing-merge.ts`). Putting it in the shared
 *     `copilot-customizations-engine` would apply it to the Copilot and Codex
 *     entry points, which publish no `config/` tree, and putting it in
 *     `rewriteReferences` would be wrong because that hook sees only source text
 *     and never the destination's layout.
 *
 * Responsibilities:
 *     Own algorithm step 1 only: collect a deterministic observation list by a
 *     depth-limited breadth-first scan of the destination root. Steps 2 through
 *     8 belong to the pure core `claude-blast-radius-derive-core.ts`, which this
 *     module calls and never duplicates.
 *
 * Tolerance rule (pinned):
 *     A `listEntries` failure at any level, including on the destination root
 *     itself, contributes no entries and does not fail the derivation. This
 *     mirrors `RealPushDownFileSystem.listFiles` (`filesystem-adapter.ts`) and
 *     is required rather than merely convenient: existing push-down tests
 *     publish to in-memory destinations such as `/dest` that the real-filesystem
 *     default lister cannot see, so a root-level `readdirSync` failure must
 *     degrade to zero observations, which the core's no-signal floor then
 *     handles.
 *
 * Side effects:
 *     Reads destination directory listings and delegates all writes to the
 *     wrapped adapter.
 */

import * as fs from "node:fs";

import { type PushDownFileSystem } from "./filesystem-adapter";
import {
  BLAST_RADIUS_RELATIVE_PATH,
  deriveDestinationModuleMap,
  type DirectoryObservation,
  isExcludedDirectoryName,
  SCAN_DEPTH_LIMIT,
} from "./claude-blast-radius-derive-core";

export {
  BLAST_RADIUS_RELATIVE_PATH,
  BlastRadiusDeriveError,
  BlastRadiusGuardError,
} from "./claude-blast-radius-derive-core";

/** One entry of a shallow directory listing. */
export interface DirectoryEntry {
  /** Entry name, not a path. */
  readonly name: string;

  /** True when the entry is a directory. */
  readonly isDir: boolean;
}

/**
 * Shallow directory lister seam.
 *
 * The seam exists so tests can describe an in-memory destination layout without
 * touching the real filesystem. Implementations return the entries directly
 * inside `root`; a root that cannot be listed yields an empty array or throws,
 * and both outcomes are treated identically by the scanner.
 */
export type DirectoryLister = (root: string) => ReadonlyArray<DirectoryEntry>;

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
 * Real-filesystem directory lister used when no seam is injected.
 *
 * @param root Absolute directory to list.
 * @returns Entries directly inside `root`, ordinally sorted by name; an empty
 *   array when the directory cannot be read.
 */
export const realDirectoryLister: DirectoryLister = (root) => {
  let entries: fs.Dirent[];
  try {
    entries = fs.readdirSync(root, { withFileTypes: true });
  } catch {
    // A directory that cannot be read contributes no entries; see the tolerance
    // rule in this module's header comment.
    return [];
  }
  return entries
    .map((entry) => ({ name: entry.name, isDir: entry.isDirectory() }))
    .sort((left, right) =>
      left.name < right.name ? -1 : left.name > right.name ? 1 : 0,
    );
};

/**
 * Call a lister without letting its failure abort the derivation.
 *
 * @param lister The injected or default lister.
 * @param path Absolute directory to list.
 * @returns The entries, or an empty array when the lister threw.
 */
function listTolerantly(
  lister: DirectoryLister,
  path: string,
): ReadonlyArray<DirectoryEntry> {
  try {
    return lister(path);
  } catch {
    // Matches the real lister's own tolerance so an injected seam and the
    // default behave identically on an unreadable directory.
    return [];
  }
}

/**
 * Collect the destination observation list (algorithm step 1).
 *
 * Breadth-first from the destination root to {@link SCAN_DEPTH_LIMIT}, visiting
 * subdirectories in ordinal name order and pruning excluded and dot-prefixed
 * names. Breadth-first order with an ordinally sorted queue makes the resulting
 * list a pure function of the visible layout, which is what makes the derived
 * document byte-stable across pushes.
 *
 * @param destinationRoot Absolute destination workspace root (POSIX path).
 * @param lister Shallow directory lister.
 * @returns One observation per visited directory, the root first.
 */
export function collectDestinationObservations(
  destinationRoot: string,
  lister: DirectoryLister,
): DirectoryObservation[] {
  const root = normalizePosix(destinationRoot);
  const observations: DirectoryObservation[] = [];

  // The queue holds directories still to visit with their depth. Depth 1 is the
  // root, so the bound admits the root plus two nested levels.
  let queue: ReadonlyArray<{ path: string; relativePath: string }> = [
    { path: root, relativePath: "" },
  ];
  for (let depth = 1; depth <= SCAN_DEPTH_LIMIT && queue.length > 0; depth++) {
    const nextQueue: { path: string; relativePath: string }[] = [];
    // Visit every directory at the current depth before descending, recording
    // its shallow file names and enqueuing the subdirectories worth visiting.
    for (const current of queue) {
      const entries = listTolerantly(lister, current.path);
      const fileNames: string[] = [];
      for (const entry of entries) {
        if (!entry.isDir) {
          fileNames.push(entry.name);
          continue;
        }
        if (isExcludedDirectoryName(entry.name)) {
          continue;
        }
        nextQueue.push({
          path: `${current.path}/${entry.name}`,
          relativePath:
            current.relativePath === ""
              ? entry.name
              : `${current.relativePath}/${entry.name}`,
        });
      }
      observations.push({
        relativePath: current.relativePath,
        fileNames,
      });
    }
    queue = nextQueue;
  }

  return observations;
}

/**
 * Wrap a {@link PushDownFileSystem} so one path is derived instead of copied.
 *
 * Every method other than `writeTextFile` delegates unchanged. `writeTextFile`
 * substitutes a derived document only when the target resolves to
 * `config/blast-radius.json` relative to the destination root; the bundled
 * content the engine supplies becomes the derivation's base document rather than
 * the bytes written.
 *
 * The wrapped {@link PushDownFileSystem} contract is not widened: this class
 * implements exactly its six members.
 */
export class BlastRadiusDeriveFileSystem implements PushDownFileSystem {
  private readonly inner: PushDownFileSystem;
  private readonly destinationRoot: string;
  private readonly deriveRelativePath: string;
  private readonly lister: DirectoryLister;

  /**
   * @param inner The wrapped adapter performing real I/O.
   * @param destinationRoot Destination workspace root (POSIX path).
   * @param lister Shallow directory lister; defaults to the real filesystem.
   * @param deriveRelativePath Destination-relative path to derive; defaults to
   *   `config/blast-radius.json`.
   */
  constructor(
    inner: PushDownFileSystem,
    destinationRoot: string,
    lister: DirectoryLister = realDirectoryLister,
    deriveRelativePath: string = BLAST_RADIUS_RELATIVE_PATH,
  ) {
    this.inner = inner;
    this.destinationRoot = normalizePosix(destinationRoot);
    this.lister = lister;
    this.deriveRelativePath = deriveRelativePath;
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
   * Write a file, deriving the one configured blast-radius path.
   *
   * @param path Absolute destination POSIX path.
   * @param content Bundled source content the engine wants to publish, used as
   *   the derivation's base document rather than written verbatim.
   * @throws BlastRadiusDeriveError When the bundled document is not parseable.
   * @throws BlastRadiusGuardError When a forbidden glob would be emitted. Both
   *   errors are raised before the inner write, so the destination bytes are
   *   left untouched.
   */
  public writeTextFile(path: string, content: string): void {
    if (!this.isDeriveTarget(path)) {
      this.inner.writeTextFile(path, content);
      return;
    }
    const observations = collectDestinationObservations(
      this.destinationRoot,
      this.lister,
    );
    const derived = deriveDestinationModuleMap(observations, content);
    this.inner.writeTextFile(path, derived);
  }

  /**
   * Return whether a destination path is the configured derivation target.
   *
   * @param path Absolute destination POSIX path.
   * @returns True when the path resolves to the derive-target relative path.
   */
  private isDeriveTarget(path: string): boolean {
    return (
      relativeToPosix(path, this.destinationRoot) === this.deriveRelativePath
    );
  }
}
