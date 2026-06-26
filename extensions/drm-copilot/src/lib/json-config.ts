import type { FileSystem } from "./file-system";
import { toPosixPath } from "./file-system";

/**
 * Governed JSON config discovery, ported from
 * `scripts/dev_tools/json_config.py`.
 *
 * Note: `.vscode` and `.devcontainer` files are JSONC (JSON with comments) and
 * cannot be formatted by jq. They are excluded from formatting because the
 * governed globs do not include them, not via an explicit exclude entry.
 */

/** Governed JSON config globs (relative to repo root). */
export const GOVERNED_GLOBS = [
  "scripts/**/*.json",
  "docs/**/*.json",
  "examples/**/*.json",
] as const;

/** Globs for large/generated data and artifacts excluded from governance. */
export const EXCLUDE_GLOBS = [
  "data/**",
  "artifacts/**",
  "htmlcov/**",
  "coverage*/**",
  "**/node_modules/**",
  ".venv",
  ".venv/**",
  "**/.venv",
  "**/.venv/**",
] as const;

/**
 * Enumerate the ancestor directories of a POSIX path.
 *
 * Replicates Python `Path.parents`: yields each parent directory from the
 * immediate parent up to (but not including) the path itself. The root-most
 * parent is the first path segment.
 *
 * @param path A POSIX-style path.
 * @returns The ancestor paths, immediate parent first.
 */
function parentPaths(path: string): string[] {
  const segments = path.split("/").filter((segment) => segment !== "");
  const parents: string[] = [];
  // Build each ancestor prefix by dropping trailing segments one at a time.
  for (let count = segments.length - 1; count >= 1; count -= 1) {
    parents.push(segments.slice(0, count).join("/"));
  }
  return parents;
}

/**
 * Yield governed JSON files under the repo root respecting excludes.
 *
 * Port of Python `iter_governed_files`. The algorithm:
 * 1) Resolve include matches from {@link GOVERNED_GLOBS}.
 * 2) Build an exclusion set from {@link EXCLUDE_GLOBS}.
 * 3) Keep an included path only when none of its parents are excluded, the path
 *    itself is not excluded, and the path is a regular file.
 *
 * The exclusion-by-parent check mirrors Python
 * `any(parent in excluded for parent in path.parents)`.
 *
 * @param fs Injected filesystem providing `glob` and `isFile`.
 * @param root Repository root to search under.
 * @returns The governed JSON file paths (POSIX style), in include order.
 */
export function iterGovernedFiles(fs: FileSystem, root: string): string[] {
  const normalizedRoot = toPosixPath(root);

  // Resolve include matches first, preserving glob order across patterns.
  const includes: string[] = [];
  for (const pattern of GOVERNED_GLOBS) {
    includes.push(...fs.glob(normalizedRoot, pattern));
  }

  // Build the exclusion set from every exclude glob match.
  const excluded = new Set<string>();
  for (const pattern of EXCLUDE_GLOBS) {
    for (const match of fs.glob(normalizedRoot, pattern)) {
      excluded.add(match);
    }
  }

  // Filter includes: skip any path whose ancestor is excluded, that is itself
  // excluded, or that is not a regular file (e.g. a directory named *.json).
  const result: string[] = [];
  for (const path of includes) {
    const hasExcludedParent = parentPaths(path).some((parent) =>
      excluded.has(parent),
    );
    if (hasExcludedParent) {
      continue;
    }
    if (excluded.has(path)) {
      continue;
    }
    if (fs.isFile(path)) {
      result.push(path);
    }
  }

  return result;
}
