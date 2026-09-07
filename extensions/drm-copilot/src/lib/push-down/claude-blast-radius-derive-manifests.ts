/**
 * Manifest vocabulary and project-directory classification for the derivation.
 *
 * Purpose:
 *     Own the manifest names, the two manifest-suffix families, the exclusion
 *     set, and the classification step. `claude-blast-radius-derive-core.ts`
 *     imports this module and re-exports its surface, so existing import paths
 *     keep working. It decides, for one file name, whether it marks a project
 *     directory at all and whether it marks one that becomes a MODULE. The two
 *     questions are distinct because a .NET project file is a structure signal
 *     that is not a module (issue #643): every assembly of a multi-project
 *     solution carries one, so admitting them made a nine-project layout emit
 *     nine modules and put every pair of items in it into contention.
 *
 * Invariants / Constraints:
 *     - `.sln` and `.slnx` join the NON-module family alongside `.csproj`,
 *       `.fsproj`, and `.vbproj`. Ancestor pruning previously removed a nested
 *       solution directory because a module beneath it outranked it; once
 *       project directories stop being modules there is no descendant to prune
 *       against, so a nested solution file would become a module of its own
 *       unless it is classified as non-module here.
 *     - `MANIFEST_SUFFIXES` is the concatenation of the two families, so
 *       `isManifestFileName` keeps its previous behaviour.
 *     - No I/O; every function is pure.
 */

/**
 * One visited destination directory and its shallow file listing. The scanner
 * supplies one per directory it visits, the root having an empty path.
 */
export interface DirectoryObservation {
  /** Destination-relative POSIX path; the root is the empty string. */
  readonly relativePath: string;
  /** Names of the files directly inside the directory, excluding directories. */
  readonly fileNames: ReadonlyArray<string>;
}

/** Exact file names whose presence marks a directory as a project directory. */
export const MANIFEST_FILENAMES: ReadonlySet<string> = new Set([
  "build.gradle",
  "build.gradle.kts",
  "Cargo.toml",
  "go.mod",
  "package.json",
  "pom.xml",
  "pyproject.toml",
  "setup.py",
]);

/**
 * Suffixes whose bearing directory becomes a module. Empty today: every
 * suffix-matched manifest this derivation knows is a .NET project or solution
 * file, and none makes its directory a module. The family is declared rather
 * than omitted so a future module-naming suffix has a home.
 */
export const MODULE_MANIFEST_SUFFIXES: ReadonlyArray<string> = [];

/**
 * Suffixes that mark a project directory WITHOUT making it a module. A
 * directory carrying only one of these is observed structure: it suppresses the
 * top-level-directory fallback but emits no module of its own.
 */
export const NON_MODULE_MANIFEST_SUFFIXES: ReadonlyArray<string> = [
  ".csproj",
  ".fsproj",
  ".vbproj",
  ".sln",
  ".slnx",
];

/** File-name suffixes whose presence marks a directory as a project directory. */
export const MANIFEST_SUFFIXES: ReadonlyArray<string> = [
  ...MODULE_MANIFEST_SUFFIXES,
  ...NON_MODULE_MANIFEST_SUFFIXES,
];

/**
 * Directory names the destination scan never descends into: build output,
 * dependency caches, and location buckets. A location bucket admitted as a
 * module would attach to nearly every work item, so `doc`, `docs`, `test`, and
 * `tests` are pruned here rather than filtered later. Dot-prefixed names are
 * excluded by {@link isExcludedDirectoryName}, not by membership of this set.
 */
export const EXCLUDED_DIR_NAMES: ReadonlySet<string> = new Set([
  "__pycache__",
  "artifacts",
  "bin",
  "build",
  "coverage",
  "dist",
  "doc",
  "docs",
  "node_modules",
  "obj",
  "out",
  "target",
  "test",
  "tests",
  "venv",
]);

/** Result of classifying a destination's directory observations. */
export interface ProjectDirectoryClassification {
  /** Destination-relative paths that become modules, ordinally sorted. */
  readonly modulePaths: ReadonlyArray<string>;
  /**
   * Whether any project directory was observed, module-bearing or not. True
   * suppresses the top-level-directory fallback: a destination that declared
   * its structure with .NET project files has said what it is, so falling back
   * to its top-level directories substitutes a weaker signal.
   */
  readonly structureObserved: boolean;
}

/**
 * Compare two strings ordinally.
 * @param left First string.
 * @param right Second string.
 * @returns Negative, zero, or positive per the comparator contract.
 */
export function compareOrdinal(left: string, right: string): number {
  return left < right ? -1 : left > right ? 1 : 0;
}

/**
 * Report whether a directory name is excluded from the destination scan.
 * @param name A single directory name, not a path.
 * @returns True when the name is a pruned bucket or begins with a dot.
 */
export function isExcludedDirectoryName(name: string): boolean {
  return name.startsWith(".") || EXCLUDED_DIR_NAMES.has(name);
}

/**
 * Report whether a file name marks its directory as a project directory.
 * @param fileName A single file name, not a path.
 * @returns True for an exact manifest name or any manifest suffix.
 */
export function isManifestFileName(fileName: string): boolean {
  if (MANIFEST_FILENAMES.has(fileName)) {
    return true;
  }
  // Suffix matching covers the .NET project and solution families, whose file
  // names vary with the project name and so cannot be listed exactly.
  return MANIFEST_SUFFIXES.some((suffix) => fileName.endsWith(suffix));
}

/**
 * Report whether a file name marks its directory as a MODULE.
 * @param fileName A single file name, not a path.
 * @returns True for an exact manifest name or a module-family suffix.
 */
export function isModuleManifestFileName(fileName: string): boolean {
  if (MANIFEST_FILENAMES.has(fileName)) {
    return true;
  }
  return MODULE_MANIFEST_SUFFIXES.some((suffix) => fileName.endsWith(suffix));
}

/**
 * Report whether a file name is a structure signal that is not a module.
 * @param fileName A single file name, not a path.
 * @returns True for a non-module-family suffix, not an exact manifest name.
 */
export function isNonModuleManifestFileName(fileName: string): boolean {
  return (
    !MANIFEST_FILENAMES.has(fileName) &&
    NON_MODULE_MANIFEST_SUFFIXES.some((suffix) => fileName.endsWith(suffix))
  );
}

/**
 * Select the observations that are project directories (algorithm step 2).
 * @param observations Every visited directory, including the root.
 * @returns The sorted module paths and whether structure was observed.
 */
export function classifyProjectDirectories(
  observations: ReadonlyArray<DirectoryObservation>,
): ProjectDirectoryClassification {
  const modulePaths: string[] = [];
  let structureObserved = false;
  // The root is skipped categorically: a root-level manifest would name the
  // whole destination and yield the universal glob `**`, the defect being fixed.
  for (const observation of observations) {
    if (observation.relativePath === "") {
      continue;
    }
    if (observation.fileNames.some(isModuleManifestFileName)) {
      modulePaths.push(observation.relativePath);
      structureObserved = true;
      continue;
    }
    // A directory carrying only a non-module manifest contributes no path but
    // still records that the destination declared its structure.
    if (observation.fileNames.some(isNonModuleManifestFileName)) {
      structureObserved = true;
    }
  }
  return { modulePaths: modulePaths.sort(compareOrdinal), structureObserved };
}
