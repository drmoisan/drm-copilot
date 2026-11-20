/**
 * In-memory fakes for the development-docs migration suites (issue #1016).
 *
 * None of these fakes touches the disk, starts a process or reads `process.cwd()`.
 */
import type {
  CommandResult,
  CommandRunOptions,
  CommandRunner,
} from "../../../src/lib/subprocess-runner";
import { compileGlob, type FileSystem } from "../../../src/lib/file-system";
import type { MigrationGit } from "../../../src/lib/development-docs-migration/migration-git";

/** One recorded runner call. */
export interface RecordedCall {
  readonly args: ReadonlyArray<string>;
  readonly options: CommandRunOptions | undefined;
}

/** Fake command runner: records argv and options and returns a scripted result. */
export class FakeCommandRunner implements CommandRunner {
  readonly calls: RecordedCall[] = [];

  constructor(
    private readonly respond: (
      args: ReadonlyArray<string>,
    ) => CommandResult = () => ({ stdout: "", stderr: "", code: 0 }),
  ) {}

  run(args: readonly string[], options?: CommandRunOptions): CommandResult {
    this.calls.push({ args: [...args], options });
    return this.respond(args);
  }
}

/** Shared ordered event log so suites can assert call order across fakes. */
export type EventLog = string[];

/** In-memory {@link FileSystem} keyed by forward-slash path. */
export class InMemoryFileSystem implements FileSystem {
  readonly files = new Map<string, string>();
  readonly directories = new Set<string>();
  readonly writes: string[] = [];

  constructor(
    initial: Readonly<Record<string, string>> = {},
    readonly events: EventLog = [],
  ) {
    for (const [path, content] of Object.entries(initial)) {
      this.files.set(path, content);
    }
  }

  glob(root: string, pattern: string): string[] {
    const matcher = compileGlob(pattern);
    const prefix = root === "" ? "" : `${root.replace(/\/+$/, "")}/`;
    return [...this.files.keys()]
      .filter((path) => path.startsWith(prefix))
      .filter((path) => matcher.test(path.slice(prefix.length)));
  }

  isFile(path: string): boolean {
    return this.files.has(path);
  }

  exists(path: string): boolean {
    return this.isFile(path) || this.isDirectory(path);
  }

  isDirectory(path: string): boolean {
    const prefix = `${path.replace(/\/+$/, "")}/`;
    return (
      this.directories.has(path) ||
      [...this.files.keys()].some((file) => file.startsWith(prefix))
    );
  }

  listDirectory(path: string): string[] {
    const prefix = `${path.replace(/\/+$/, "")}/`;
    const names = new Set<string>();
    for (const file of this.files.keys()) {
      if (file.startsWith(prefix)) {
        names.add(file.slice(prefix.length).split("/")[0] ?? "");
      }
    }
    return [...names].sort();
  }

  readTextFile(path: string): string {
    const content = this.files.get(path);
    if (content === undefined) {
      throw new Error(`ENOENT: ${path}`);
    }
    return content;
  }

  writeTextFile(path: string, content: string): void {
    this.files.set(path, content);
    this.writes.push(path);
    this.events.push(`write:${path}`);
  }

  ensureDir(path: string): void {
    this.directories.add(path);
    this.events.push(`ensureDir:${path}`);
  }
}

/** Options of {@link FakeMigrationGit}. */
export interface FakeMigrationGitOptions {
  readonly root?: string;
  readonly untracked?: ReadonlyArray<string>;
  readonly dirty?: boolean;
  readonly insideWorkTree?: boolean;
}

/**
 * Fake git over an {@link InMemoryFileSystem}: every file of the file system is
 * tracked, and `move` renames the moved paths in the file system.
 */
export class FakeMigrationGit implements MigrationGit {
  readonly moves: Array<{ from: string; to: string }> = [];
  private readonly root: string;

  constructor(
    private readonly fileSystem: InMemoryFileSystem,
    private readonly options: FakeMigrationGitOptions = {},
  ) {
    this.root = options.root ?? "repo";
  }

  private relative(): string[] {
    const prefix = `${this.root}/`;
    return [...this.fileSystem.files.keys()]
      .filter((path) => path.startsWith(prefix))
      .map((path) => path.slice(prefix.length))
      .sort();
  }

  listTrackedFiles(pathspecs: ReadonlyArray<string>): ReadonlyArray<string> {
    return filterBySpecs(this.relative(), pathspecs);
  }

  listUntrackedFiles(pathspecs: ReadonlyArray<string>): ReadonlyArray<string> {
    return filterBySpecs([...(this.options.untracked ?? [])], pathspecs);
  }

  hasUncommittedTrackedChanges(): boolean {
    return this.options.dirty ?? false;
  }

  isInsideWorkTree(): boolean {
    return this.options.insideWorkTree ?? true;
  }

  move(from: string, to: string): void {
    const sources = this.relative().filter(
      (path) => path === from || path.startsWith(`${from}/`),
    );
    if (sources.length === 0) {
      throw new Error(`fatal: bad source, source=${from}`);
    }
    for (const path of sources) {
      const content = this.fileSystem.files.get(`${this.root}/${path}`) ?? "";
      this.fileSystem.files.delete(`${this.root}/${path}`);
      this.fileSystem.files.set(
        `${this.root}/${to}${path.slice(from.length)}`,
        content,
      );
    }
    this.moves.push({ from, to });
    this.fileSystem.events.push(`move:${from}->${to}`);
  }
}

/**
 * Filter paths by git-style pathspecs (a directory or file prefix).
 *
 * @param paths Repository-relative paths.
 * @param pathspecs Pathspecs; an empty list matches everything.
 * @returns The matching paths.
 */
function filterBySpecs(
  paths: ReadonlyArray<string>,
  pathspecs: ReadonlyArray<string>,
): string[] {
  if (pathspecs.length === 0) {
    return [...paths];
  }
  return paths.filter((path) =>
    pathspecs.some((spec) => {
      const clean = spec.replace(/\/+$/, "");
      return path === clean || path.startsWith(`${clean}/`);
    }),
  );
}
