import { type PushDownFileSystem } from "../../../src/lib/push-down/filesystem-adapter";

/**
 * Normalize a path to forward-slash separators with no trailing slash.
 *
 * @param value Path that may use OS-specific separators.
 * @returns Forward-slash POSIX path without a trailing separator (except root).
 */
function normalize(value: string): string {
  const posix = value.replace(/\\/g, "/");
  if (posix.length > 1 && posix.endsWith("/")) {
    return posix.replace(/\/+$/, "");
  }
  return posix;
}

/**
 * In-memory {@link PushDownFileSystem} fake for hermetic push-down tests.
 *
 * Purpose:
 *     Mirror the Python `RecordingFileSystem` test double: an in-memory text
 *     store keyed by POSIX path, a deterministic sorted `listFiles`, and tracked
 *     directories. It records writes and ensured directories so tests can assert
 *     the publisher's filesystem interactions without touching real disk.
 *
 * Responsibilities:
 *     - `listFiles`: return, in sorted order, every stored file whose path is
 *       beneath the requested root.
 *     - `isDir`: true for any directory seeded/ensured or implied by a stored
 *       file's ancestry.
 *     - `isFile`: true only for an exact stored file path.
 *     - `readTextFile` / `writeTextFile`: in-memory UTF-8 text (LF-normalized
 *       writes to match the real adapter).
 *     - `ensureDir`: record the directory as existing.
 *
 * Invariants / Constraints:
 *     All keys are normalized to forward-slash POSIX form. A write implies the
 *     parent directory chain exists (matching the real adapter's mkdir).
 *
 * Side effects:
 *     None beyond mutating its own in-memory maps.
 */
export class InMemoryPushDownFileSystem implements PushDownFileSystem {
  /** Stored file contents keyed by normalized POSIX path. */
  private readonly files = new Map<string, string>();
  /** Directories that exist (seeded, ensured, or implied by file ancestry). */
  private readonly directories = new Set<string>();
  /** Recorded write calls in invocation order, for assertions. */
  readonly writtenPaths: string[] = [];
  /** Recorded ensureDir calls in invocation order, for assertions. */
  readonly ensuredDirs: string[] = [];

  /**
   * Seed a file and its ancestor directories.
   *
   * @param path File path (any separator style).
   * @param content UTF-8 file content.
   */
  seedFile(path: string, content: string): void {
    const normalized = normalize(path);
    this.files.set(normalized, content);
    this.recordAncestors(normalized);
  }

  /**
   * Seed a directory as existing without any file content.
   *
   * @param path Directory path (any separator style).
   */
  seedDir(path: string): void {
    const normalized = normalize(path);
    this.directories.add(normalized);
    this.recordAncestors(normalized);
  }

  /**
   * Record every ancestor directory of a normalized path as existing.
   *
   * @param normalizedPath A normalized POSIX path whose parents to record.
   */
  private recordAncestors(normalizedPath: string): void {
    const segments = normalizedPath.split("/");
    // Walk from the second segment upward, registering each parent prefix as a
    // directory so isDir reflects implied ancestry the same way real disk does.
    for (let index = 1; index < segments.length; index += 1) {
      const prefix = segments.slice(0, index).join("/");
      if (prefix !== "") {
        this.directories.add(prefix);
      }
    }
  }

  listFiles(root: string): string[] {
    const normalizedRoot = normalize(root);
    if (!this.isDir(normalizedRoot)) {
      return [];
    }
    const prefix = `${normalizedRoot}/`;
    // Collect every stored file that lives beneath the requested root.
    const matches: string[] = [];
    for (const key of this.files.keys()) {
      if (key === normalizedRoot || key.startsWith(prefix)) {
        matches.push(key);
      }
    }
    return matches.sort((left, right) =>
      left < right ? -1 : left > right ? 1 : 0,
    );
  }

  isDir(path: string): boolean {
    return this.directories.has(normalize(path));
  }

  isFile(path: string): boolean {
    return this.files.has(normalize(path));
  }

  readTextFile(path: string): string {
    const normalized = normalize(path);
    const content = this.files.get(normalized);
    if (content === undefined) {
      throw new Error(`InMemoryPushDownFileSystem: missing file ${normalized}`);
    }
    return content;
  }

  writeTextFile(path: string, content: string): void {
    const normalized = normalize(path);
    // Normalize line endings to match the real adapter's LF-normalized write.
    const lfNormalized = content.replace(/\r\n/g, "\n").replace(/\r/g, "\n");
    this.files.set(normalized, lfNormalized);
    this.recordAncestors(normalized);
    this.writtenPaths.push(normalized);
  }

  ensureDir(path: string): void {
    const normalized = normalize(path);
    this.directories.add(normalized);
    this.recordAncestors(normalized);
    this.ensuredDirs.push(normalized);
  }
}

/**
 * Build an {@link InMemoryPushDownFileSystem} pre-seeded with files.
 *
 * @param seedFiles Map of POSIX path to UTF-8 content to seed.
 * @param seedDirs Optional directory paths to seed as existing.
 * @returns A seeded in-memory push-down filesystem fake.
 */
export function buildInMemoryFileSystem(
  seedFiles: Readonly<Record<string, string>> = {},
  seedDirs: ReadonlyArray<string> = [],
): InMemoryPushDownFileSystem {
  const fs = new InMemoryPushDownFileSystem();
  // Seed directories first so an explicitly empty destination directory exists.
  for (const dir of seedDirs) {
    fs.seedDir(dir);
  }
  for (const [path, content] of Object.entries(seedFiles)) {
    fs.seedFile(path, content);
  }
  return fs;
}

/**
 * Create a fixed-instant clock for deterministic `startedAt`/`finishedAt`.
 *
 * @param isoInstant ISO-8601 instant the clock always returns.
 * @returns A zero-argument function returning the same `Date` each call.
 */
export function fixedClock(isoInstant: string): () => Date {
  const instant = new Date(isoInstant);
  return () => instant;
}
