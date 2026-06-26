/**
 * Port-local filesystem seam for the potential-to-issue promotion workflow.
 *
 * Purpose:
 *     Define exactly the filesystem operations the workflow needs
 *     (`resolvePath`, `exists`, `readText`, `writeLines`, `ensureDir`, `move`)
 *     without widening the shared F1 `FileSystem` interface (which lacks
 *     `exists`/`move`/`writeLines`/`resolvePath`). Extracted from `promotion.ts`
 *     so that module stays within the 500-line limit, and re-exported from it
 *     for a stable public surface.
 *
 * Seam usage:
 *     Tests inject a Map-backed fake; production wiring uses
 *     {@link RealPotentialFileSystem}, backed by `node:fs`/`node:path`/`node:os`.
 */

import * as fs from "node:fs";
import * as nodeOs from "node:os";
import * as nodePath from "node:path";

/**
 * Port-local filesystem seam for the promotion workflow.
 *
 * Mirrors the operations of the bundled Python `FileSystem` protocol that the
 * workflow uses, using path strings rather than a `Path` object.
 */
export interface PotentialFileSystem {
  /** Resolve a path string (production expands `~` and resolves absolute). */
  resolvePath(pathStr: string): string;
  /** Return whether the path exists. */
  exists(path: string): boolean;
  /** Read the file at `path` as UTF-8 text. */
  readText(path: string): string;
  /** Write `lines` joined with `\n` to `path` as UTF-8 text. */
  writeLines(path: string, lines: readonly string[]): void;
  /** Ensure the directory at `path` exists, creating parents as needed. */
  ensureDir(path: string): void;
  /** Move `src` to `dest`, ensuring the destination parent exists. */
  move(src: string, dest: string): void;
}

/**
 * Production {@link PotentialFileSystem} backed by `node:fs`/`node:path`/`node:os`.
 *
 * Side effects:
 *     Reads from and writes to the local filesystem; creates directories and
 *     moves files.
 */
export class RealPotentialFileSystem implements PotentialFileSystem {
  /**
   * Resolve a path string: expand a leading `~` then resolve to an absolute
   * path. Mirrors Python `Path(path_str).expanduser().resolve()`.
   *
   * @param pathStr Raw path string.
   * @returns The resolved absolute path string.
   */
  resolvePath(pathStr: string): string {
    // Expand a leading `~` to the user home directory before resolving.
    const expanded =
      pathStr === "~" || pathStr.startsWith("~/")
        ? nodePath.join(nodeOs.homedir(), pathStr.slice(1))
        : pathStr;
    return nodePath.resolve(expanded);
  }

  /** @returns True when `path` exists. */
  exists(path: string): boolean {
    return fs.existsSync(path);
  }

  /** @returns The UTF-8 file content. */
  readText(path: string): string {
    return fs.readFileSync(path, "utf8");
  }

  /** Write `lines` joined with `\n` as UTF-8 text. */
  writeLines(path: string, lines: readonly string[]): void {
    fs.writeFileSync(path, lines.join("\n"), "utf8");
  }

  /** Create `path` and any missing parents (idempotent). */
  ensureDir(path: string): void {
    fs.mkdirSync(path, { recursive: true });
  }

  /** Move `src` to `dest`, ensuring the destination parent exists first. */
  move(src: string, dest: string): void {
    fs.mkdirSync(nodePath.dirname(dest), { recursive: true });
    fs.renameSync(src, dest);
  }
}
