import * as fs from "node:fs";
import * as nodePath from "node:path";

/**
 * Filesystem abstraction enabling hermetic, injectable file I/O.
 *
 * Purpose:
 *     Model the Python `FileSystem` Protocol pattern so consuming modules
 *     (`json-config.ts`, `markdown-label-formatter.ts`) depend on an interface
 *     rather than `node:fs` directly. Tests inject an in-memory fake; production
 *     wiring injects {@link RealFileSystem}.
 *
 * Responsibilities:
 *     - `glob`: enumerate paths under a root matching a glob pattern, mirroring
 *       Python `Path.glob` semantics for the governed/exclude patterns used by
 *       `json-config`.
 *     - `isFile`: predicate for whether a path is a regular file.
 *     - `readTextFile` / `writeTextFile`: UTF-8 text I/O.
 *
 * Path convention:
 *     Paths are returned and accepted using forward-slash separators to keep a
 *     single, OS-neutral matching semantics consistent with Python `Path.glob`
 *     pattern strings.
 */
export interface FileSystem {
  /**
   * Enumerate paths under `root` matching `pattern`.
   *
   * @param root Root directory to search under.
   * @param pattern Glob pattern relative to `root` (e.g. `scripts/**\/*.json`).
   * @returns Matching paths joined to `root`, using forward-slash separators.
   */
  glob(root: string, pattern: string): string[];

  /** Return true when `path` refers to an existing regular file. */
  isFile(path: string): boolean;

  /**
   * Return true when `path` exists (file, directory, or other entry).
   *
   * Mirrors Python `Path.exists()`: any access error (missing path, permission
   * failure) resolves to `false` rather than raising.
   *
   * @param path Path to test.
   */
  exists(path: string): boolean;

  /**
   * Return true when `path` exists and is a directory.
   *
   * Mirrors Python `Path.is_dir()`: a missing path or non-directory entry
   * resolves to `false` rather than raising.
   *
   * @param path Path to test.
   */
  isDirectory(path: string): boolean;

  /**
   * List the immediate child entry names of the directory at `path`.
   *
   * Mirrors Python `Path.iterdir()` (names only), returning the child names
   * sorted lexicographically. When `path` is absent or is not a directory, an
   * empty array is returned rather than raising, matching the tolerant
   * discovery semantics the pr-context port relies on.
   *
   * @param path Directory whose immediate children are listed.
   * @returns Sorted child names, or an empty array when `path` is not a
   *   readable directory.
   */
  listDirectory(path: string): string[];

  /** Read the file at `path` as UTF-8 text. */
  readTextFile(path: string): string;

  /** Write `content` to `path` as UTF-8 text. */
  writeTextFile(path: string, content: string): void;

  /**
   * Ensure that the directory at `path` exists, creating parent directories as
   * needed.
   *
   * Mirrors Python `Path.mkdir(parents=True, exist_ok=True)`: the call is
   * idempotent and does not raise when the directory already exists. Consumers
   * (e.g. the commit-context port) call this before writing an output file so
   * the parent directory is guaranteed to exist.
   *
   * @param path Directory path to create, including any missing ancestors.
   */
  ensureDir(path: string): void;
}

/**
 * Narrow filesystem seam exposing only a file's last-modified time.
 *
 * Purpose:
 *     Supply last-activity timestamps for the subagent-tree quick-pick without
 *     widening {@link FileSystem} (which would force edits to its in-memory
 *     fakes for a single consumer). Tests inject a fake that returns fixed
 *     epochs; production wiring injects {@link RealFileTimes}.
 */
export interface FileTimes {
  /**
   * Return the last-modified time of `path` in milliseconds since the Unix
   * epoch, or `undefined` when the time cannot be read (missing file,
   * permission error, or any stat failure).
   *
   * @param path Path whose modified time is requested.
   */
  getModifiedTimeMs(path: string): number | undefined;
}

/**
 * Normalize a path to forward-slash separators.
 *
 * @param value A path that may contain OS-specific separators.
 * @returns The path with all backslashes converted to forward slashes.
 */
export function toPosixPath(value: string): string {
  return value.replace(/\\/g, "/");
}

/**
 * Join a root and a relative path using forward-slash separators.
 *
 * @param root Base path.
 * @param relative Path relative to the base.
 * @returns The combined POSIX-style path.
 */
function joinPosix(root: string, relative: string): string {
  const normalizedRoot = toPosixPath(root).replace(/\/+$/, "");
  const normalizedRelative = toPosixPath(relative).replace(/^\/+/, "");
  if (normalizedRoot === "") {
    return normalizedRelative;
  }
  if (normalizedRelative === "") {
    return normalizedRoot;
  }
  return `${normalizedRoot}/${normalizedRelative}`;
}

/**
 * Escape regular-expression metacharacters in a literal pattern segment.
 *
 * @param value Literal text that may contain regex metacharacters.
 * @returns The text with metacharacters escaped for safe use in a RegExp.
 */
function escapeRegExp(value: string): string {
  return value.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
}

/**
 * Compile a glob pattern into an anchored RegExp matching a relative path.
 *
 * Supported tokens (sufficient for the governed/exclude patterns and Python
 * `Path.glob` semantics used by `json-config`):
 * - `**` matches any number of path segments (including zero).
 * - `*` matches any run of characters within a single path segment.
 * - `?` matches a single non-separator character.
 * - All other characters match literally.
 *
 * The pattern is matched against a relative POSIX path (no leading slash).
 *
 * @param pattern Glob pattern using forward-slash separators.
 * @returns A RegExp anchored to the full relative path.
 */
function compileGlob(pattern: string): RegExp {
  const normalized = toPosixPath(pattern);
  let regex = "";
  let index = 0;

  // Walk the pattern character by character, translating glob tokens. A
  // single pass keeps `**`, `*`, and `?` handling unambiguous and ordered.
  while (index < normalized.length) {
    const char = normalized[index];

    if (char === "*") {
      const isDoubleStar = normalized[index + 1] === "*";
      if (isDoubleStar) {
        // `**/` (or trailing `**`) spans zero or more full path segments.
        const followedBySlash = normalized[index + 2] === "/";
        if (followedBySlash) {
          regex += "(?:.*/)?";
          index += 3;
        } else {
          regex += ".*";
          index += 2;
        }
        continue;
      }
      // Single `*` matches within one segment (no separators).
      regex += "[^/]*";
      index += 1;
      continue;
    }

    if (char === "?") {
      regex += "[^/]";
      index += 1;
      continue;
    }

    regex += escapeRegExp(char ?? "");
    index += 1;
  }

  return new RegExp(`^${regex}$`);
}

/**
 * Production {@link FileSystem} backed by `node:fs`.
 *
 * Purpose:
 *     Provide real disk I/O and a glob walker whose matching semantics align
 *     with the compiled glob RegExp, so hermetic fakes that reuse the same
 *     pattern semantics validate consumer logic rather than the glob engine.
 *
 * Side effects:
 *     Reads from and writes to the local filesystem.
 */
export class RealFileSystem implements FileSystem {
  /**
   * Enumerate files and directories under `root` matching `pattern`.
   *
   * Walks the directory tree once and tests each discovered relative path
   * against the compiled glob. Both files and directories are returned, so the
   * caller (e.g. `iterGovernedFiles`) can apply its own file/exclude checks.
   *
   * @param root Root directory to search under.
   * @param pattern Glob pattern relative to `root`.
   * @returns Matching absolute-style POSIX paths joined to `root`.
   */
  glob(root: string, pattern: string): string[] {
    const matcher = compileGlob(pattern);
    const matches: string[] = [];
    const normalizedRoot = toPosixPath(root);

    // Recursively descend the tree, recording every relative path that matches.
    const walk = (currentDir: string, relativePrefix: string): void => {
      let entries: fs.Dirent[];
      try {
        entries = fs.readdirSync(currentDir, { withFileTypes: true });
      } catch {
        // A missing or unreadable directory yields no matches rather than
        // raising; this mirrors Path.glob returning nothing for absent roots.
        return;
      }

      // Inspect each entry: test it against the matcher and recurse into dirs.
      for (const entry of entries) {
        const relativePath =
          relativePrefix === ""
            ? entry.name
            : `${relativePrefix}/${entry.name}`;
        if (matcher.test(relativePath)) {
          matches.push(joinPosix(normalizedRoot, relativePath));
        }
        if (entry.isDirectory()) {
          walk(nodePath.join(currentDir, entry.name), relativePath);
        }
      }
    };

    walk(normalizedRoot, "");
    return matches;
  }

  /**
   * @param path Path to test.
   * @returns True when `path` exists and is a regular file.
   */
  isFile(path: string): boolean {
    try {
      return fs.statSync(path).isFile();
    } catch {
      return false;
    }
  }

  /**
   * @param path Path to test.
   * @returns True when `path` exists; false on any access error.
   */
  exists(path: string): boolean {
    return fs.existsSync(path);
  }

  /**
   * @param path Path to test.
   * @returns True when `path` exists and is a directory; false otherwise.
   */
  isDirectory(path: string): boolean {
    try {
      return fs.statSync(path).isDirectory();
    } catch {
      return false;
    }
  }

  /**
   * @param path Directory whose immediate children are listed.
   * @returns Sorted child names; an empty array when `path` is not a readable
   *   directory.
   */
  listDirectory(path: string): string[] {
    try {
      // `readdirSync` raises for a missing path or a non-directory; treat any
      // such failure as "no children" to match Python's tolerant discovery.
      return fs
        .readdirSync(path)
        .sort((left, right) => left.localeCompare(right));
    } catch {
      return [];
    }
  }

  /**
   * @param path File to read.
   * @returns The file content decoded as UTF-8.
   */
  readTextFile(path: string): string {
    return fs.readFileSync(path, "utf8");
  }

  /**
   * @param path File to write.
   * @param content Text content to write as UTF-8.
   */
  writeTextFile(path: string, content: string): void {
    fs.writeFileSync(path, content, "utf8");
  }

  /**
   * Create the directory at `path`, including any missing parents.
   *
   * Uses `fs.mkdirSync(path, { recursive: true })`, which is idempotent and
   * does not raise when the directory already exists, matching Python
   * `Path.mkdir(parents=True, exist_ok=True)`.
   *
   * @param path Directory path to create.
   */
  ensureDir(path: string): void {
    fs.mkdirSync(path, { recursive: true });
  }
}

/**
 * Production {@link FileTimes} backed by `node:fs`.
 *
 * Side effects:
 *     Reads file metadata from the local filesystem.
 */
export class RealFileTimes implements FileTimes {
  /**
   * @param path Path whose modified time is requested.
   * @returns The file's `mtimeMs`, or `undefined` on any stat failure.
   */
  getModifiedTimeMs(path: string): number | undefined {
    try {
      return fs.statSync(path).mtimeMs;
    } catch {
      return undefined;
    }
  }
}
