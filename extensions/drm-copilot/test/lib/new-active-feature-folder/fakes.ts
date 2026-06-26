/**
 * Shared hermetic test doubles for the new-active-feature-folder cluster tests.
 *
 * Provides a `Map`-backed {@link FolderFileSystem} fake (tracks files, created
 * directories, and moves) and a recording {@link CommandRunner} fake. No real
 * filesystem, subprocess, PATH, or environment access.
 */

import {
  type CommandResult,
  type CommandRunner,
  type CommandRunOptions,
} from "../../../src/lib/subprocess-runner";
import { type FolderFileSystem } from "../../../src/lib/new-active-feature-folder/models";

/**
 * In-memory {@link FolderFileSystem} for hermetic tests.
 *
 * Tracks file contents in a map keyed by forward-slash path; records created
 * directories and move operations. `move` of an absent source throws, and
 * `readText` of an absent path throws, matching the real adapter contract.
 */
export class FakeFolderFileSystem implements FolderFileSystem {
  /** File contents keyed by forward-slash path. */
  readonly files = new Map<string, string>();
  /** Directories created via {@link ensureDir}. */
  readonly createdDirs: string[] = [];
  /** Recorded move operations as `[src, dest]` pairs. */
  readonly moves: Array<[string, string]> = [];

  /**
   * Seed a file into the in-memory tree.
   *
   * @param path Forward-slash file path.
   * @param content File content.
   */
  seed(path: string, content: string): void {
    this.files.set(path, content);
  }

  /**
   * @param path Path to test.
   * @returns True when a file or a created directory matches `path`.
   */
  exists(path: string): boolean {
    if (this.files.has(path)) {
      return true;
    }
    // A path is also "present" when it is a created directory or a prefix of a
    // seeded file path (an implicit ancestor directory).
    if (this.createdDirs.includes(path)) {
      return true;
    }
    for (const filePath of this.files.keys()) {
      if (filePath.startsWith(`${path}/`)) {
        return true;
      }
    }
    return false;
  }

  /**
   * @param path Directory to record as created.
   */
  ensureDir(path: string): void {
    if (!this.createdDirs.includes(path)) {
      this.createdDirs.push(path);
    }
  }

  /**
   * @param src Source file path.
   * @param dest Destination file path.
   */
  copyFile(src: string, dest: string): void {
    const content = this.files.get(src) ?? "";
    this.files.set(dest, content);
  }

  /**
   * @param src Source directory root.
   * @param dest Destination directory root.
   */
  copyTree(src: string, dest: string): void {
    // Copy every seeded file under `src` to the matching path under `dest`.
    for (const [filePath, content] of this.files) {
      if (filePath.startsWith(`${src}/`)) {
        const relative = filePath.slice(src.length + 1);
        this.files.set(`${dest}/${relative}`, content);
      }
    }
  }

  /**
   * @param path Directory to list.
   * @returns Forward-slash file paths directly under `path`.
   */
  listFiles(path: string): string[] {
    const result: string[] = [];
    // Return only the files whose parent directory is exactly `path`.
    for (const filePath of this.files.keys()) {
      if (filePath.startsWith(`${path}/`)) {
        const relative = filePath.slice(path.length + 1);
        if (!relative.includes("/")) {
          result.push(filePath);
        }
      }
    }
    return result;
  }

  /**
   * @param path File to read.
   * @returns The file content.
   * @throws Error When the path is absent.
   */
  readText(path: string): string {
    const content = this.files.get(path);
    if (content === undefined) {
      throw new Error(`FakeFolderFileSystem: missing file ${path}`);
    }
    return content;
  }

  /**
   * @param path File to write.
   * @param content Text content.
   */
  writeText(path: string, content: string): void {
    this.files.set(path, content);
  }

  /**
   * @param src Source path.
   * @param dest Destination path.
   * @throws Error When the source is absent.
   */
  move(src: string, dest: string): void {
    const content = this.files.get(src);
    if (content === undefined) {
      throw new Error(`FakeFolderFileSystem: cannot move missing ${src}`);
    }
    this.files.delete(src);
    this.files.set(dest, content);
    this.moves.push([src, dest]);
  }
}

/**
 * Recording {@link CommandRunner} fake.
 *
 * Returns a queued result per invocation and records each argument vector. Does
 * not spawn any process.
 */
export class FakeCommandRunner implements CommandRunner {
  /** Recorded argument vectors, one per `run` call. */
  readonly calls: Array<readonly string[]> = [];
  private readonly results: CommandResult[];

  /**
   * @param results Queued results returned in order (last result repeats).
   */
  constructor(results: CommandResult[] = []) {
    this.results = results;
  }

  /**
   * @param args Argument vector.
   * @param _options Ignored run options.
   * @returns The next queued result, or a zero-exit empty result.
   */
  run(args: readonly string[], _options?: CommandRunOptions): CommandResult {
    void _options;
    this.calls.push(args);
    const next = this.results.shift() ?? this.results[this.results.length - 1];
    return next ?? { stdout: "", stderr: "", code: 0 };
  }
}
