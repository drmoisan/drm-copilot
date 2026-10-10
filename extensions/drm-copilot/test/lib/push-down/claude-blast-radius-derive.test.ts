// Coverage tests for `src/lib/push-down/claude-blast-radius-derive.ts`, added
// under the coordinator standing decision of 2026-10-09 for #796 (every changed
// line must be covered). `node:fs` is mocked, so no file or directory is
// created or read.
import { afterEach, describe, expect, it, jest } from "@jest/globals";
import * as fs from "node:fs";

import { realDirectoryLister } from "../../../src/lib/push-down/claude-blast-radius-derive";

jest.mock("node:fs", () => ({
  ...jest.requireActual<typeof import("node:fs")>("node:fs"),
  readdirSync: jest.fn(),
}));

const readdirSyncMock = fs.readdirSync as jest.MockedFunction<
  typeof fs.readdirSync
>;

/**
 * Build a minimal Dirent-like entry for mocking readdirSync results.
 *
 * @param name Entry name.
 * @param isDir Whether the entry is a directory.
 * @returns A Dirent-shaped stub.
 */
function dirent(name: string, isDir: boolean): fs.Dirent {
  return {
    name,
    isDirectory: () => isDir,
  } as unknown as fs.Dirent;
}

afterEach(() => {
  jest.resetAllMocks();
});

describe("coverage: claude-blast-radius-derive.ts", () => {
  it("returns directory entries sorted by name with their directory flags", () => {
    // Arrange: entries arrive out of order.
    readdirSyncMock.mockReturnValue([
      dirent("zeta", false),
      dirent("alpha", true),
      dirent("mid", false),
    ] as unknown as ReturnType<typeof fs.readdirSync>);

    // Act
    const entries = realDirectoryLister("/dest");

    // Assert
    expect(entries).toEqual([
      { name: "alpha", isDir: true },
      { name: "mid", isDir: false },
      { name: "zeta", isDir: false },
    ]);
    expect(readdirSyncMock).toHaveBeenCalledWith("/dest", {
      withFileTypes: true,
    });
  });

  it("returns an empty array when the directory cannot be read", () => {
    // Arrange
    readdirSyncMock.mockImplementation(() => {
      throw new Error("EACCES");
    });

    // Act
    const entries = realDirectoryLister("/unreadable");

    // Assert
    expect(entries).toEqual([]);
  });
});
