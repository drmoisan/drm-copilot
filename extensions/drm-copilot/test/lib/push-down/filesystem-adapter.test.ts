import { afterEach, describe, expect, it, jest } from "@jest/globals";
import * as fs from "node:fs";

import { RealPushDownFileSystem } from "../../../src/lib/push-down/filesystem-adapter";

jest.mock("node:fs", () => ({
  readdirSync: jest.fn(),
  statSync: jest.fn(),
  readFileSync: jest.fn(),
  writeFileSync: jest.fn(),
  mkdirSync: jest.fn(),
}));

const readdirSyncMock = fs.readdirSync as jest.MockedFunction<
  typeof fs.readdirSync
>;
const statSyncMock = fs.statSync as jest.MockedFunction<typeof fs.statSync>;
const readFileSyncMock = fs.readFileSync as jest.MockedFunction<
  typeof fs.readFileSync
>;
const writeFileSyncMock = fs.writeFileSync as jest.MockedFunction<
  typeof fs.writeFileSync
>;
const mkdirSyncMock = fs.mkdirSync as jest.MockedFunction<typeof fs.mkdirSync>;

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
    isFile: () => !isDir,
  } as unknown as fs.Dirent;
}

/**
 * Build a Stats-like stub for statSync mocking.
 *
 * @param kind The filesystem entry kind to report.
 * @returns A Stats-shaped stub.
 */
function stats(kind: "file" | "dir"): fs.Stats {
  return {
    isFile: () => kind === "file",
    isDirectory: () => kind === "dir",
  } as unknown as fs.Stats;
}

describe("RealPushDownFileSystem", () => {
  afterEach(() => {
    jest.resetAllMocks();
  });

  describe("listFiles", () => {
    it("returns an empty list when the root is not a directory", () => {
      // Arrange
      statSyncMock.mockImplementation(() => {
        throw new Error("ENOENT");
      });
      const sut = new RealPushDownFileSystem();

      // Act
      const result = sut.listFiles("/missing/root");

      // Assert
      expect(result).toEqual([]);
      expect(readdirSyncMock).not.toHaveBeenCalled();
    });

    it("returns files beneath the root in sorted POSIX order", () => {
      // Arrange: root is a dir; readdir returns nested entries by directory.
      statSyncMock.mockReturnValue(stats("dir"));
      readdirSyncMock.mockImplementation(((dir: string) => {
        const posix = dir.replace(/\\/g, "/");
        if (posix === "/repo/.github") {
          return [dirent("zeta.md", false), dirent("nested", true)];
        }
        if (posix === "/repo/.github/nested") {
          return [dirent("alpha.md", false)];
        }
        return [];
      }) as unknown as typeof fs.readdirSync);
      const sut = new RealPushDownFileSystem();

      // Act
      const result = sut.listFiles("/repo/.github");

      // Assert: sorted lexicographically; nested path precedes top-level zeta.
      expect(result).toEqual([
        "/repo/.github/nested/alpha.md",
        "/repo/.github/zeta.md",
      ]);
    });

    it("skips a subdirectory that becomes unreadable mid-walk", () => {
      // Arrange
      statSyncMock.mockReturnValue(stats("dir"));
      readdirSyncMock.mockImplementation(((dir: string) => {
        const posix = dir.replace(/\\/g, "/");
        if (posix === "/repo/root") {
          return [dirent("file.md", false), dirent("locked", true)];
        }
        throw new Error("EACCES");
      }) as unknown as typeof fs.readdirSync);
      const sut = new RealPushDownFileSystem();

      // Act
      const result = sut.listFiles("/repo/root");

      // Assert: the unreadable subdirectory yields no files.
      expect(result).toEqual(["/repo/root/file.md"]);
    });
  });

  describe("isDir / isFile", () => {
    it("isDir reflects a directory stat", () => {
      // Arrange
      statSyncMock.mockReturnValue(stats("dir"));
      const sut = new RealPushDownFileSystem();

      // Act / Assert
      expect(sut.isDir("/repo")).toBe(true);
    });

    it("isDir returns false when stat throws", () => {
      // Arrange
      statSyncMock.mockImplementation(() => {
        throw new Error("ENOENT");
      });
      const sut = new RealPushDownFileSystem();

      // Act / Assert
      expect(sut.isDir("/missing")).toBe(false);
    });

    it("isFile reflects a file stat", () => {
      // Arrange
      statSyncMock.mockReturnValue(stats("file"));
      const sut = new RealPushDownFileSystem();

      // Act / Assert
      expect(sut.isFile("/repo/a.md")).toBe(true);
    });

    it("isFile returns false when stat throws", () => {
      // Arrange
      statSyncMock.mockImplementation(() => {
        throw new Error("ENOENT");
      });
      const sut = new RealPushDownFileSystem();

      // Act / Assert
      expect(sut.isFile("/missing")).toBe(false);
    });
  });

  describe("readTextFile", () => {
    it("reads UTF-8 text", () => {
      // Arrange
      readFileSyncMock.mockReturnValue("content" as unknown as Buffer);
      const sut = new RealPushDownFileSystem();

      // Act
      const result = sut.readTextFile("/repo/a.md");

      // Assert
      expect(result).toBe("content");
      expect(readFileSyncMock).toHaveBeenCalledWith("/repo/a.md", "utf8");
    });
  });

  describe("writeTextFile", () => {
    it("creates the parent directory and writes LF-normalized UTF-8 text", () => {
      // Arrange
      const sut = new RealPushDownFileSystem();

      // Act
      sut.writeTextFile("/dest/sub/a.md", "line1\r\nline2\rline3");

      // Assert: parent dir created recursively, then CRLF/CR normalized to LF.
      expect(mkdirSyncMock).toHaveBeenCalledWith(
        expect.stringContaining("sub"),
        { recursive: true },
      );
      expect(writeFileSyncMock).toHaveBeenCalledWith(
        "/dest/sub/a.md",
        "line1\nline2\nline3",
        "utf8",
      );
    });
  });

  describe("ensureDir", () => {
    it("creates the directory recursively", () => {
      // Arrange
      const sut = new RealPushDownFileSystem();

      // Act
      sut.ensureDir("/dest/sub");

      // Assert
      expect(mkdirSyncMock).toHaveBeenCalledWith("/dest/sub", {
        recursive: true,
      });
    });
  });
});
