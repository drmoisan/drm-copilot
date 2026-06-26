/**
 * Shared in-memory `node:fs` harness helpers for the extension-level
 * new-active-feature-folder tests.
 *
 * The `jest.mock("node:fs", ...)` declaration must live in each test module
 * (so the mocked `node:fs` is loaded before `../src/extension`), but the pure
 * wiring helpers that operate on the resulting mock are shared here to avoid
 * duplicating ~150 lines across the two extension test files.
 */

/** Shape of the `node:fs` mock used by the in-process port. */
export interface NafFsMock {
  existsSync: jest.MockedFunction<(filePath: string) => boolean>;
  readFileSync: jest.MockedFunction<(filePath: string) => string>;
  writeFileSync: jest.MockedFunction<
    (filePath: string, content: string) => void
  >;
  mkdirSync: jest.MockedFunction<(dirPath: string) => void>;
  copyFileSync: jest.MockedFunction<(src: string, dest: string) => void>;
  renameSync: jest.MockedFunction<(src: string, dest: string) => void>;
  unlinkSync: jest.MockedFunction<(filePath: string) => void>;
  statSync: jest.MockedFunction<(filePath: string) => { isFile(): boolean }>;
  readdirSync: jest.MockedFunction<
    (
      dirPath: string,
    ) => Array<{ name: string; isFile(): boolean; isDirectory(): boolean }>
  >;
}

/** Mutable in-memory tree backing the harness. */
export interface MemTree {
  readonly files: Map<string, string>;
  readonly dirs: Set<string>;
}

/** Create a fresh, empty in-memory tree. */
export function createMemTree(): MemTree {
  return { files: new Map<string, string>(), dirs: new Set<string>() };
}

/**
 * Normalize a path to forward slashes.
 *
 * @param value Path that may use backslashes.
 * @returns The forward-slash form.
 */
export function toPosix(value: string): string {
  return value.replace(/\\/g, "/");
}

/**
 * Seed a file into the in-memory tree.
 *
 * @param tree The in-memory tree.
 * @param path File path.
 * @param content File content.
 */
export function seedFile(tree: MemTree, path: string, content: string): void {
  tree.files.set(toPosix(path), content);
}

/**
 * Seed the bundled feature-template tree for the given type.
 *
 * @param tree The in-memory tree.
 * @param featureType Template type directory.
 */
export function seedTemplateTree(tree: MemTree, featureType: string): void {
  const dir = `C:/extension/resources/feature-templates/${featureType}`;
  seedFile(tree, `${dir}/user-story.md`, "# <feature-name>\n");
  seedFile(tree, `${dir}/spec.md`, "# <feature-name>\n");
  seedFile(
    tree,
    `${dir}/plan.yyyy-MM-ddTHH-mm.md`,
    "# <feature-name>\n- Last Updated: <yyyy-MM-ddTHH-mm>\n",
  );
}

/**
 * Wire the `node:fs` mock to the in-memory tree so the in-process port runs
 * hermetically.
 *
 * @param fsMock The harness `node:fs` mock.
 * @param tree The in-memory tree the mock reads/writes.
 */
export function installInProcessFs(fsMock: NafFsMock, tree: MemTree): void {
  fsMock.existsSync.mockImplementation((filePath: string): boolean => {
    const p = toPosix(filePath);
    if (tree.files.has(p) || tree.dirs.has(p)) {
      return true;
    }
    // A directory is "present" when any seeded file lives under it.
    for (const file of tree.files.keys()) {
      if (file.startsWith(`${p}/`)) {
        return true;
      }
    }
    return false;
  });
  fsMock.readFileSync.mockImplementation((filePath: string): string => {
    const content = tree.files.get(toPosix(filePath));
    if (content === undefined) {
      throw new Error(`ENOENT: ${filePath}`);
    }
    return content;
  });
  fsMock.writeFileSync.mockImplementation(
    (filePath: string, content: string) => {
      tree.files.set(toPosix(filePath), String(content));
    },
  );
  fsMock.mkdirSync.mockImplementation((dirPath: string) => {
    tree.dirs.add(toPosix(dirPath));
  });
  fsMock.copyFileSync.mockImplementation((src: string, dest: string) => {
    tree.files.set(toPosix(dest), tree.files.get(toPosix(src)) ?? "");
  });
  fsMock.renameSync.mockImplementation((src: string, dest: string) => {
    tree.files.set(toPosix(dest), tree.files.get(toPosix(src)) ?? "");
    tree.files.delete(toPosix(src));
  });
  fsMock.unlinkSync.mockImplementation((filePath: string) => {
    tree.files.delete(toPosix(filePath));
  });
  fsMock.statSync.mockImplementation((filePath: string) => ({
    isFile: () => tree.files.has(toPosix(filePath)),
  }));
  fsMock.readdirSync.mockImplementation((dirPath: string) => {
    const prefix = `${toPosix(dirPath)}/`;
    const seen = new Set<string>();
    const entries: Array<{
      name: string;
      isFile(): boolean;
      isDirectory(): boolean;
    }> = [];
    // Emit each immediate child of `dirPath`: files directly under it, and the
    // first segment of any deeper path as a directory entry.
    for (const file of tree.files.keys()) {
      if (!file.startsWith(prefix)) {
        continue;
      }
      const relative = file.slice(prefix.length);
      const slash = relative.indexOf("/");
      if (slash === -1) {
        entries.push({
          name: relative,
          isFile: () => true,
          isDirectory: () => false,
        });
      } else {
        const dirName = relative.slice(0, slash);
        if (!seen.has(dirName)) {
          seen.add(dirName);
          entries.push({
            name: dirName,
            isFile: () => false,
            isDirectory: () => true,
          });
        }
      }
    }
    return entries;
  });
}

/**
 * Set whether a `python` executable appears present on PATH, layering over the
 * existing in-process fs existsSync implementation.
 *
 * @param fsMock The harness `node:fs` mock.
 * @param presence Whether python is present.
 */
export function setPythonPresence(fsMock: NafFsMock, presence: boolean): void {
  const previous = fsMock.existsSync.getMockImplementation();
  fsMock.existsSync.mockImplementation((filePath: string): boolean => {
    if (filePath.toLowerCase().includes("python")) {
      return presence;
    }
    return previous ? previous(filePath) : false;
  });
}

/**
 * Whether any `spawn` call targeted the bundled `.py` script.
 *
 * @param childProcessMock The harness `node:child_process` mock.
 * @returns True when a `new_active_feature_folder.py` spawn occurred.
 */
export function pythonScriptSpawned(childProcessMock: {
  spawn: jest.Mock;
}): boolean {
  return childProcessMock.spawn.mock.calls.some((call: unknown[]) =>
    ((call[1] as string[] | undefined) ?? []).some((arg) =>
      arg.endsWith("new_active_feature_folder.py"),
    ),
  );
}
