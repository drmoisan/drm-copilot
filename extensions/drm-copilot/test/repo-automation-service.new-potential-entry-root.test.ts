/**
 * Unit tests for the development-docs root argument of
 * `RepoAutomationService.newPotentialEntry` (issue #1035, D-P4).
 *
 * The service resolves the root through its injected `fileSystem` and appends
 * `-DevelopmentDocsRoot <root>` only when the resolved root differs from the
 * default, so the default argv stays byte-identical. Hermetic: `node:fs` and
 * `node:child_process` are mocked and the file system is an in-memory map.
 */
import {
  afterEach,
  beforeEach,
  describe,
  expect,
  it,
  jest,
} from "@jest/globals";

import {
  createMockProcess,
  setExecutablePresenceOnFsMock,
} from "./runtime-test-helpers";
import { type FileSystem } from "../src/lib/file-system";

jest.mock("vscode", () => ({}), { virtual: true });

jest.mock("node:fs", () => ({
  copyFileSync: jest.fn(),
  existsSync: jest.fn(),
  mkdirSync: jest.fn(),
}));

jest.mock("node:child_process", () => ({
  spawn: jest.fn(),
}));

import { createRepoAutomationService } from "../src/repo-automation-service";

const fsMock = jest.requireMock("node:fs") as {
  existsSync: jest.MockedFunction<(filePath: string) => boolean>;
};

const childProcessMock = jest.requireMock("node:child_process") as {
  spawn: jest.Mock;
};

/**
 * Map-backed {@link FileSystem} fake; a directory exists when a seeded file
 * lies beneath it.
 */
class MapFileSystem implements FileSystem {
  readonly files = new Map<string, string>();

  glob(): string[] {
    return [];
  }

  isFile(path: string): boolean {
    return this.files.has(path);
  }

  exists(path: string): boolean {
    return this.files.has(path) || this.isDirectory(path);
  }

  isDirectory(path: string): boolean {
    return [...this.files.keys()].some((file) => file.startsWith(`${path}/`));
  }

  listDirectory(): string[] {
    return [];
  }

  readTextFile(path: string): string {
    const content = this.files.get(path);
    if (content === undefined) {
      throw new Error(`File not found: ${path}`);
    }
    return content;
  }

  writeTextFile(path: string, content: string): void {
    this.files.set(path, content);
  }

  ensureDir(): void {
    // No directory bookkeeping is needed by these cases.
  }
}

/**
 * Run `newPotentialEntry` and return the spawned argv.
 *
 * @param fileSystem Injected file system.
 * @returns The argv passed to the spawned `pwsh`.
 */
async function spawnedArgs(fileSystem: FileSystem): Promise<string[]> {
  const service = createRepoAutomationService({
    extensionRoot: "C:/extension",
    output: { appendLine: jest.fn() },
    fileSystem,
  });
  await service.newPotentialEntry({
    workspaceRoot: "C:/workspace",
    invocationId: "new_potential_entry",
    shortName: "mcp-entry",
  });
  const [, args] = childProcessMock.spawn.mock.calls[0] as [string, string[]];
  return args;
}

describe("RepoAutomationService.newPotentialEntry development-docs root", () => {
  beforeEach(() => {
    process.env["PATH"] = "C:/bin";
    process.env["PATHEXT"] = ".EXE;.CMD";
    childProcessMock.spawn.mockReset();
    setExecutablePresenceOnFsMock(fsMock, { pwsh: true });
    childProcessMock.spawn.mockReturnValue(createMockProcess(0));
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it("passes -DevelopmentDocsRoot .dev when .dev is configured and present", async () => {
    // Arrange
    const fileSystem = new MapFileSystem();
    fileSystem.files.set(
      "C:/workspace/config/orchestration-routing.json",
      '{"development_docs_root": ".dev"}',
    );
    fileSystem.files.set("C:/workspace/.dev/README.md", "x");

    // Act
    const args = await spawnedArgs(fileSystem);

    // Assert
    expect(args.slice(-2)).toEqual(["-DevelopmentDocsRoot", ".dev"]);
  });

  it("does not pass -DevelopmentDocsRoot under the default root", async () => {
    // Arrange: no routing file resolves the default root (R-1).
    const fileSystem = new MapFileSystem();

    // Act
    const args = await spawnedArgs(fileSystem);

    // Assert
    expect(args).not.toContain("-DevelopmentDocsRoot");
    expect(args.slice(-4)).toEqual([
      "-ShortName",
      "mcp-entry",
      "-TemplateRoot",
      "C:/extension/resources/feature-templates",
    ]);
  });

  it("does not pass -DevelopmentDocsRoot when .dev is configured but absent", async () => {
    // Arrange: R-7 falls back to an existing docs/features.
    const fileSystem = new MapFileSystem();
    fileSystem.files.set(
      "C:/workspace/config/orchestration-routing.json",
      '{"development_docs_root": ".dev"}',
    );
    fileSystem.files.set("C:/workspace/docs/features/README.md", "x");

    // Act
    const args = await spawnedArgs(fileSystem);

    // Assert
    expect(args).not.toContain("-DevelopmentDocsRoot");
  });
});
