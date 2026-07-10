import { beforeEach, describe, expect, it, jest } from "@jest/globals";
import type { FileSystem } from "../src/lib/file-system";

const mockShowQuickPick = jest.fn();
const mockShowInformationMessage = jest.fn();

jest.mock(
  "vscode",
  () => ({
    window: {
      showQuickPick: mockShowQuickPick,
      showInformationMessage: mockShowInformationMessage,
    },
  }),
  { virtual: true },
);

import { readPoshQcScanFolders } from "../src/poshqc-scan-config";
import {
  POSHQC_TEST_PICKER_TITLE,
  promptForPoshQcScanFolders,
} from "../src/poshqc-folder-picker";

const WORKSPACE_ROOT = "C:/workspace";
const CONFIG_PATH = `${WORKSPACE_ROOT}/config/poshqc-scan.json`;

function normalize(path: string): string {
  return path.replace(/\\/g, "/").replace(/\/+$/, "");
}

/**
 * In-memory tree FileSystem seeded with directory paths and file contents.
 * Supports enumeration (`listDirectory`/`isDirectory`) and config I/O. No temp
 * files or disk access.
 */
class TreeFileSystem implements FileSystem {
  private readonly dirs: Set<string>;
  private readonly files: Map<string, string>;
  writeCount = 0;

  constructor(dirs: readonly string[], files: Record<string, string> = {}) {
    this.dirs = new Set(dirs.map(normalize));
    this.files = new Map(Object.entries(files));
  }

  glob(): string[] {
    return [];
  }

  private childNames(path: string): string[] {
    const prefix = `${normalize(path)}/`;
    const names = new Set<string>();
    // Collect the first path segment of every descendant directory and file.
    for (const entry of [...this.dirs, ...this.files.keys()]) {
      if (entry.startsWith(prefix)) {
        const first = entry.slice(prefix.length).split("/")[0];
        if (first) {
          names.add(first);
        }
      }
    }
    return [...names].sort((left, right) => left.localeCompare(right));
  }

  listDirectory(path: string): string[] {
    return this.childNames(path);
  }

  isDirectory(path: string): boolean {
    return this.dirs.has(normalize(path));
  }

  isFile(path: string): boolean {
    return this.files.has(normalize(path));
  }

  exists(path: string): boolean {
    return this.isDirectory(path) || this.isFile(path);
  }

  readTextFile(path: string): string {
    const content = this.files.get(normalize(path));
    if (content === undefined) {
      throw new Error(`ENOENT: ${path}`);
    }
    return content;
  }

  writeTextFile(path: string, content: string): void {
    this.writeCount += 1;
    this.files.set(normalize(path), content);
  }

  ensureDir(path: string): void {
    this.dirs.add(normalize(path));
  }
}

const WORKSPACE_DIRECTORIES = [
  "C:/workspace/scripts",
  "C:/workspace/scripts/powershell",
  "C:/workspace/scripts/powershell/PoshQC",
  "C:/workspace/tests",
  "C:/workspace/tests/scripts",
  "C:/workspace/node_modules",
  "C:/workspace/node_modules/pkg",
  "C:/workspace/.git",
];

/** Config listing an existing folder plus a folder that no longer exists. */
const SEED_CONFIG = JSON.stringify({
  version: 1,
  test: { scanFolders: ["scripts", "tests/scripts", "tests/powershell"] },
});

function createSeededFileSystem(): TreeFileSystem {
  return new TreeFileSystem(WORKSPACE_DIRECTORIES, {
    [CONFIG_PATH]: SEED_CONFIG,
  });
}

describe("promptForPoshQcScanFolders", () => {
  beforeEach(() => {
    mockShowQuickPick.mockReset();
    mockShowInformationMessage.mockReset();
  });

  it("enumerates workspace folders to depth 2, excluding standard directories", async () => {
    // Arrange
    const fileSystem = createSeededFileSystem();
    mockShowQuickPick.mockResolvedValueOnce(undefined);

    // Act
    await promptForPoshQcScanFolders(fileSystem, WORKSPACE_ROOT);

    // Assert: items are the union of enumerated (depth <= 2, excluded names
    // dropped) and configured folders; the depth-3 folder and excluded
    // directories are absent.
    const [items, options] = mockShowQuickPick.mock.calls[0] as [
      Array<{ label: string }>,
      { canPickMany: boolean; title: string },
    ];
    const labels = items.map((item) => item.label);
    expect(labels).toEqual([
      "scripts",
      "scripts/powershell",
      "tests",
      "tests/powershell",
      "tests/scripts",
    ]);
    expect(labels).not.toContain("scripts/powershell/PoshQC");
    expect(labels).not.toContain("node_modules");
    expect(labels).not.toContain(".git");
    expect(options.canPickMany).toBe(true);
    expect(options.title).toBe(POSHQC_TEST_PICKER_TITLE);
  });

  it("seeds picked=true for configured folders", async () => {
    // Arrange
    const fileSystem = createSeededFileSystem();
    mockShowQuickPick.mockResolvedValueOnce(undefined);

    // Act
    await promptForPoshQcScanFolders(fileSystem, WORKSPACE_ROOT);

    // Assert
    const [items] = mockShowQuickPick.mock.calls[0] as [
      Array<{ label: string; picked?: boolean }>,
    ];
    const byLabel = new Map(items.map((item) => [item.label, item]));
    expect(byLabel.get("scripts")?.picked).toBe(true);
    expect(byLabel.get("tests/scripts")?.picked).toBe(true);
    expect(byLabel.get("tests")?.picked).toBe(false);
    expect(byLabel.get("scripts/powershell")?.picked).toBe(false);
  });

  it("shows a configured-but-missing folder with a warning marker rather than dropping it", async () => {
    // Arrange
    const fileSystem = createSeededFileSystem();
    mockShowQuickPick.mockResolvedValueOnce(undefined);

    // Act
    await promptForPoshQcScanFolders(fileSystem, WORKSPACE_ROOT);

    // Assert: tests/powershell is configured but absent from the tree.
    const [items] = mockShowQuickPick.mock.calls[0] as [
      Array<{ label: string; picked?: boolean; description?: string }>,
    ];
    const missing = items.find((item) => item.label === "tests/powershell");
    expect(missing).toBeDefined();
    expect(missing?.picked).toBe(true);
    expect(missing?.description).toContain("$(warning)");
  });

  it("persists an accepted non-empty selection canonically before returning it", async () => {
    // Arrange: return an unsorted, mixed-separator selection.
    const fileSystem = createSeededFileSystem();
    mockShowQuickPick.mockResolvedValueOnce([
      { label: "tests/scripts", folder: "tests\\scripts" },
      { label: "scripts", folder: "scripts" },
    ]);

    // Act
    const result = await promptForPoshQcScanFolders(fileSystem, WORKSPACE_ROOT);

    // Assert: canonical return, config persisted, and a read-back round-trip.
    expect(result).toEqual(["scripts", "tests/scripts"]);
    expect(fileSystem.writeCount).toBe(1);
    expect(readPoshQcScanFolders(fileSystem, WORKSPACE_ROOT)).toEqual([
      "scripts",
      "tests/scripts",
    ]);
  });

  it("performs no write and no run signal when the picker is cancelled", async () => {
    // Arrange
    const fileSystem = createSeededFileSystem();
    mockShowQuickPick.mockResolvedValueOnce(undefined);

    // Act
    const result = await promptForPoshQcScanFolders(fileSystem, WORKSPACE_ROOT);

    // Assert
    expect(result).toBeUndefined();
    expect(fileSystem.writeCount).toBe(0);
    expect(mockShowInformationMessage).not.toHaveBeenCalled();
  });

  it("shows an information message and performs no write on an empty accepted selection", async () => {
    // Arrange
    const fileSystem = createSeededFileSystem();
    mockShowQuickPick.mockResolvedValueOnce([]);

    // Act
    const result = await promptForPoshQcScanFolders(fileSystem, WORKSPACE_ROOT);

    // Assert
    expect(result).toBeUndefined();
    expect(fileSystem.writeCount).toBe(0);
    expect(mockShowInformationMessage).toHaveBeenCalledTimes(1);
  });
});
