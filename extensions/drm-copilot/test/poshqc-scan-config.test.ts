import type { FileSystem } from "../src/lib/file-system";
import {
  SCAN_CONFIG_RELATIVE_PATH,
  canonicalizeFolders,
  readPoshQcScanFolders,
  resolveScanConfigPath,
  writePoshQcScanFolders,
} from "../src/poshqc-scan-config";

/**
 * In-memory FileSystem fake supporting the read/write/ensureDir surface the
 * scan-config module uses. Unused capabilities throw so accidental reliance is
 * caught. No temporary files or disk I/O are involved.
 */
class InMemoryFileSystem implements FileSystem {
  readonly files: Map<string, string>;
  readonly ensuredDirectories: string[] = [];

  constructor(files: Record<string, string> = {}) {
    this.files = new Map(Object.entries(files));
  }

  glob(): string[] {
    return [];
  }

  isFile(path: string): boolean {
    return this.files.has(path);
  }

  exists(path: string): boolean {
    return this.files.has(path);
  }

  isDirectory(): boolean {
    return false;
  }

  listDirectory(): string[] {
    return [];
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
  }

  ensureDir(path: string): void {
    this.ensuredDirectories.push(path);
  }
}

const WORKSPACE_ROOT = "C:/workspace";
const CONFIG_PATH = `${WORKSPACE_ROOT}/${SCAN_CONFIG_RELATIVE_PATH}`;

describe("poshqc-scan-config readPoshQcScanFolders", () => {
  it("returns an empty array when the configuration file is absent", () => {
    // Arrange
    const fileSystem = new InMemoryFileSystem();

    // Act
    const result = readPoshQcScanFolders(fileSystem, WORKSPACE_ROOT);

    // Assert
    expect(result).toEqual([]);
  });

  it("returns an empty array when test.scanFolders is absent", () => {
    // Arrange
    const fileSystem = new InMemoryFileSystem({
      [CONFIG_PATH]: JSON.stringify({ version: 1, test: {} }),
    });

    // Act / Assert
    expect(readPoshQcScanFolders(fileSystem, WORKSPACE_ROOT)).toEqual([]);
  });

  it("returns an empty array when test.scanFolders is an empty list", () => {
    // Arrange
    const fileSystem = new InMemoryFileSystem({
      [CONFIG_PATH]: JSON.stringify({ version: 1, test: { scanFolders: [] } }),
    });

    // Act / Assert
    expect(readPoshQcScanFolders(fileSystem, WORKSPACE_ROOT)).toEqual([]);
  });

  it("throws an error naming the file for malformed JSON", () => {
    // Arrange
    const fileSystem = new InMemoryFileSystem({
      [CONFIG_PATH]: "{ not-valid-json",
    });

    // Act / Assert
    expect(() => readPoshQcScanFolders(fileSystem, WORKSPACE_ROOT)).toThrow(
      SCAN_CONFIG_RELATIVE_PATH,
    );
  });

  it("throws an error naming the file when version is not 1", () => {
    // Arrange
    const fileSystem = new InMemoryFileSystem({
      [CONFIG_PATH]: JSON.stringify({
        version: 2,
        test: { scanFolders: ["scripts"] },
      }),
    });

    // Act / Assert
    expect(() => readPoshQcScanFolders(fileSystem, WORKSPACE_ROOT)).toThrow(
      /config\/poshqc-scan\.json.*version/,
    );
  });

  it("throws an error naming the file for a blank entry", () => {
    // Arrange
    const fileSystem = new InMemoryFileSystem({
      [CONFIG_PATH]: JSON.stringify({
        version: 1,
        test: { scanFolders: ["scripts", "   "] },
      }),
    });

    // Act / Assert
    expect(() => readPoshQcScanFolders(fileSystem, WORKSPACE_ROOT)).toThrow(
      /config\/poshqc-scan\.json.*blank/,
    );
  });

  it("throws an error naming the file for an absolute-path entry", () => {
    // Arrange
    const fileSystem = new InMemoryFileSystem({
      [CONFIG_PATH]: JSON.stringify({
        version: 1,
        test: { scanFolders: ["C:/absolute/path"] },
      }),
    });

    // Act / Assert
    expect(() => readPoshQcScanFolders(fileSystem, WORKSPACE_ROOT)).toThrow(
      /config\/poshqc-scan\.json.*absolute/,
    );
  });

  it("throws an error naming the file for an entry with a parent traversal segment", () => {
    // Arrange
    const fileSystem = new InMemoryFileSystem({
      [CONFIG_PATH]: JSON.stringify({
        version: 1,
        test: { scanFolders: ["../outside"] },
      }),
    });

    // Act / Assert
    expect(() => readPoshQcScanFolders(fileSystem, WORKSPACE_ROOT)).toThrow(
      /config\/poshqc-scan\.json.*'\.\.'/,
    );
  });

  it("returns canonical folders (deduplicated and sorted) for a valid file", () => {
    // Arrange: intentionally unsorted, with a duplicate and mixed separators.
    const fileSystem = new InMemoryFileSystem({
      [CONFIG_PATH]: JSON.stringify({
        version: 1,
        test: { scanFolders: ["tests\\scripts", "scripts", "scripts"] },
      }),
    });

    // Act
    const result = readPoshQcScanFolders(fileSystem, WORKSPACE_ROOT);

    // Assert
    expect(result).toEqual(["scripts", "tests/scripts"]);
  });
});

describe("poshqc-scan-config writePoshQcScanFolders", () => {
  it("writes canonical content: forward slashes, deduplicated, sorted", () => {
    // Arrange
    const fileSystem = new InMemoryFileSystem();

    // Act: supply backslash separators, a duplicate, and unsorted order.
    writePoshQcScanFolders(fileSystem, WORKSPACE_ROOT, [
      "tests\\scripts",
      "scripts",
      "scripts",
    ]);

    // Assert: the parsed document is canonical.
    const written = fileSystem.files.get(CONFIG_PATH);
    expect(written).toBeDefined();
    expect(JSON.parse(written as string)).toEqual({
      version: 1,
      test: { scanFolders: ["scripts", "tests/scripts"] },
    });
    // A trailing newline keeps the file POSIX-clean.
    expect((written as string).endsWith("\n")).toBe(true);
    // The parent directory was ensured before writing.
    expect(fileSystem.ensuredDirectories).toContain(`${WORKSPACE_ROOT}/config`);
  });

  it("produces a byte-stable read-after-write round-trip", () => {
    // Arrange
    const fileSystem = new InMemoryFileSystem();

    // Act: write once, read the folders back, then write those folders again.
    writePoshQcScanFolders(fileSystem, WORKSPACE_ROOT, [
      "tests/scripts",
      "scripts",
    ]);
    const firstContent = fileSystem.files.get(CONFIG_PATH) as string;
    const readBack = readPoshQcScanFolders(fileSystem, WORKSPACE_ROOT);
    writePoshQcScanFolders(fileSystem, WORKSPACE_ROOT, readBack);
    const secondContent = fileSystem.files.get(CONFIG_PATH) as string;

    // Assert: the folders survive the round-trip and the bytes are identical.
    expect(readBack).toEqual(["scripts", "tests/scripts"]);
    expect(secondContent).toBe(firstContent);
  });
});

describe("poshqc-scan-config helpers", () => {
  it("resolves the configuration path under the workspace root", () => {
    expect(resolveScanConfigPath("C:/workspace")).toBe(CONFIG_PATH);
  });

  it("canonicalizes folders independently of file I/O", () => {
    expect(canonicalizeFolders(["./b", "a\\c", "a\\c", "b/"])).toEqual([
      "a/c",
      "b",
    ]);
  });
});
