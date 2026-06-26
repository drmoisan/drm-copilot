import * as fs from "node:fs";
import * as nodePath from "node:path";

/**
 * Filesystem contract required by the push-down customization publisher.
 *
 * Purpose:
 *     Port the Python `PushDownFileSystem` Protocol
 *     (`push_down_copilot_customizations_filesystem.py`). It provides the small,
 *     typed seam the publisher engine uses so the core logic stays deterministic
 *     in tests while the production CLI works against the real disk.
 *
 * Responsibilities:
 *     - `listFiles`: enumerate every file beneath a root in sorted order so
 *       summary artifacts and tests remain deterministic.
 *     - `isDir` / `isFile`: reflect current filesystem state for destination
 *       validation and created-vs-overwritten classification.
 *     - `readTextFile` / `writeTextFile`: UTF-8 text I/O (writes LF-normalized).
 *     - `ensureDir`: idempotent directory creation.
 *
 * Path convention:
 *     All path arguments and returned paths are forward-slash POSIX strings.
 *     This differs from the F1 `FileSystem` interface and is intentional: it
 *     mirrors the Python `PushDownFileSystem` protocol shape one-to-one.
 *
 * Side effects:
 *     Concrete implementations may touch the real filesystem.
 */
export interface PushDownFileSystem {
  /**
   * Return all files beneath `root` as sorted forward-slash POSIX paths.
   *
   * @param root Root directory to enumerate (POSIX path).
   * @returns Sorted file paths beneath `root`; empty when `root` is not a
   *   directory.
   */
  listFiles(root: string): string[];

  /** Return true when `path` exists and is a directory. */
  isDir(path: string): boolean;

  /** Return true when `path` exists and is a regular file. */
  isFile(path: string): boolean;

  /** Read the file at `path` as UTF-8 text. */
  readTextFile(path: string): string;

  /** Write `content` to `path` as UTF-8 text (LF-normalized). */
  writeTextFile(path: string, content: string): void;

  /** Ensure the directory at `path` exists, creating parents as needed. */
  ensureDir(path: string): void;
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
 * Production {@link PushDownFileSystem} backed by `node:fs`.
 *
 * Purpose:
 *     Provide the real-disk behavior for source enumeration, destination writes,
 *     and summary-artifact emission. Mirrors the Python
 *     `RealPushDownFileSystem`: recursive sorted enumeration, UTF-8 reads, and
 *     LF-normalized writes (Python `newline="\n"`).
 *
 * Invariants / Constraints:
 *     The scoped customization trees contain repository text content, so this
 *     adapter reads and writes UTF-8 text.
 *
 * Side effects:
 *     Reads from and writes to the real filesystem.
 */
export class RealPushDownFileSystem implements PushDownFileSystem {
  /**
   * Return all files beneath a root path in sorted order.
   *
   * Mirrors Python `RealPushDownFileSystem.list_files`: returns an empty list
   * when the root is not a directory, otherwise recursively collects every file
   * and sorts the result so summary artifacts remain deterministic.
   *
   * @param root Root directory to enumerate (POSIX path).
   * @returns Sorted forward-slash POSIX file paths beneath `root`.
   */
  listFiles(root: string): string[] {
    const normalizedRoot = toPosixPath(root);
    if (!this.isDir(normalizedRoot)) {
      return [];
    }

    const files: string[] = [];
    // Walk the tree recursively so every nested file is collected; sorting is
    // applied once at the end to keep enumeration order stable for artifacts.
    const walk = (currentDir: string): void => {
      let entries: fs.Dirent[];
      try {
        entries = fs.readdirSync(currentDir, { withFileTypes: true });
      } catch {
        // A directory that becomes unreadable mid-walk contributes no files.
        return;
      }
      // Inspect each entry: record files and descend into subdirectories.
      for (const entry of entries) {
        const childPosix = joinPosix(currentDir, entry.name);
        if (entry.isDirectory()) {
          walk(childPosix);
        } else if (entry.isFile()) {
          files.push(childPosix);
        }
      }
    };

    walk(normalizedRoot);
    // Sort lexicographically to match Python's `sorted(files)` on POSIX paths.
    return files.sort((left, right) =>
      left < right ? -1 : left > right ? 1 : 0,
    );
  }

  /**
   * @param path Path to inspect.
   * @returns True when `path` exists and is a directory.
   */
  isDir(path: string): boolean {
    try {
      return fs.statSync(path).isDirectory();
    } catch {
      return false;
    }
  }

  /**
   * @param path Path to inspect.
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
   * @param path File to read.
   * @returns The file content decoded as UTF-8.
   */
  readTextFile(path: string): string {
    return fs.readFileSync(path, "utf8");
  }

  /**
   * Write UTF-8 text to a file path, creating parent directories first.
   *
   * Mirrors Python `RealPushDownFileSystem.write_text`, which creates the parent
   * directory and writes with `newline="\n"`. Content is LF-normalized so the
   * write is byte-stable regardless of the host line-ending convention.
   *
   * @param path Destination file path.
   * @param content UTF-8 text to write.
   */
  writeTextFile(path: string, content: string): void {
    const parent = nodePath.dirname(path);
    fs.mkdirSync(parent, { recursive: true });
    // Normalize CRLF/CR to LF so writes match Python's newline="\n" behavior.
    const lfNormalized = content.replace(/\r\n/g, "\n").replace(/\r/g, "\n");
    fs.writeFileSync(path, lfNormalized, "utf8");
  }

  /**
   * Ensure a directory exists, creating any missing parents.
   *
   * @param path Directory path to create.
   */
  ensureDir(path: string): void {
    fs.mkdirSync(path, { recursive: true });
  }
}
