import { type FileSystem } from "../../../src/lib/file-system";

/**
 * Tree-backed in-memory `FileSystem` for pr-context tests.
 *
 * Purpose:
 *     Provide a hermetic filesystem fake that supports the directory-aware
 *     predicates the pr-context port relies on (`exists`, `isDirectory`,
 *     `listDirectory`, `glob`) plus text read/write. Directories are tracked
 *     explicitly; adding a file implicitly registers its ancestor directories so
 *     `isDirectory`/`listDirectory` behave like a real tree.
 *
 * Path convention:
 *     Forward-slash POSIX paths, matching the production modules.
 */
export class TreeFileSystem implements FileSystem {
  readonly files = new Map<string, string>();
  readonly dirs = new Set<string>();
  readonly ensuredDirs: string[] = [];

  /** Register a directory (and its ancestors). */
  addDir(path: string): void {
    this.registerAncestors(path);
    this.dirs.add(stripTrailingSlash(path));
  }

  /** Register a file (and its ancestor directories) with content. */
  addFile(path: string, content: string): void {
    const normalized = stripTrailingSlash(path);
    this.registerAncestors(normalized);
    this.files.set(normalized, content);
  }

  glob(root: string, pattern: string): string[] {
    const matcher = compileGlob(pattern);
    const prefix = `${stripTrailingSlash(root)}/`;
    const matches: string[] = [];
    // Test each seeded file path, relative to root, against the pattern.
    for (const path of this.files.keys()) {
      if (path.startsWith(prefix)) {
        const relative = path.slice(prefix.length);
        if (matcher.test(relative)) {
          matches.push(path);
        }
      }
    }
    return matches;
  }

  isFile(path: string): boolean {
    return this.files.has(stripTrailingSlash(path));
  }

  exists(path: string): boolean {
    const normalized = stripTrailingSlash(path);
    return this.files.has(normalized) || this.dirs.has(normalized);
  }

  isDirectory(path: string): boolean {
    return this.dirs.has(stripTrailingSlash(path));
  }

  listDirectory(path: string): string[] {
    const prefix = `${stripTrailingSlash(path)}/`;
    const children = new Set<string>();
    // Collect immediate child names from both files and directories.
    for (const entry of [...this.files.keys(), ...this.dirs]) {
      if (entry.startsWith(prefix)) {
        const rest = entry.slice(prefix.length);
        const firstSegment = rest.split("/")[0];
        if (firstSegment) {
          children.add(firstSegment);
        }
      }
    }
    return [...children].sort((left, right) =>
      left < right ? -1 : left > right ? 1 : 0,
    );
  }

  readTextFile(path: string): string {
    const content = this.files.get(stripTrailingSlash(path));
    if (content === undefined) {
      throw new Error(`ENOENT: ${path}`);
    }
    return content;
  }

  writeTextFile(path: string, content: string): void {
    this.addFile(path, content);
  }

  ensureDir(path: string): void {
    this.ensuredDirs.push(path);
    this.addDir(path);
  }

  /** Register every ancestor directory of a path. */
  private registerAncestors(path: string): void {
    const segments = stripTrailingSlash(path).split("/");
    // Recreate each ancestor directory so tree predicates stay consistent.
    for (let index = 1; index < segments.length; index += 1) {
      const ancestor = segments.slice(0, index).join("/");
      if (ancestor) {
        this.dirs.add(ancestor);
      }
    }
  }
}

/** Strip a single trailing slash for normalized path comparison. */
function stripTrailingSlash(value: string): string {
  return value.replace(/\/+$/u, "");
}

/**
 * Compile a glob with `**` and `*` support into an anchored RegExp matching a
 * relative POSIX path.
 */
function compileGlob(pattern: string): RegExp {
  let regex = "";
  let index = 0;
  while (index < pattern.length) {
    const char = pattern[index]!;
    if (char === "*" && pattern[index + 1] === "*") {
      if (pattern[index + 2] === "/") {
        regex += "(?:.*/)?";
        index += 3;
      } else {
        regex += ".*";
        index += 2;
      }
      continue;
    }
    if (char === "*") {
      regex += "[^/]*";
      index += 1;
      continue;
    }
    regex += char.replace(/[.+?^${}()|[\]\\]/g, "\\$&");
    index += 1;
  }
  return new RegExp(`^${regex}$`);
}
