import { afterEach, describe, expect, it, jest } from "@jest/globals";
import * as fs from "node:fs";

import { RealFileSystem } from "../../src/lib/file-system";

jest.mock("node:fs", () => ({
  readdirSync: jest.fn(),
  statSync: jest.fn(),
  readFileSync: jest.fn(),
  writeFileSync: jest.fn(),
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

/**
 * Build a minimal Dirent-like entry for mocking readdirSync results.
 */
function dirent(name: string, isDir: boolean): fs.Dirent {
  return {
    name,
    isDirectory: () => isDir,
    isFile: () => !isDir,
  } as unknown as fs.Dirent;
}

describe("RealFileSystem", () => {
  afterEach(() => {
    jest.resetAllMocks();
  });

  describe("isFile", () => {
    it("returns true for a regular file", () => {
      // Arrange
      statSyncMock.mockReturnValue({
        isFile: () => true,
      } as unknown as fs.Stats);
      const sut = new RealFileSystem();

      // Act / Assert
      expect(sut.isFile("/some/file.json")).toBe(true);
    });

    it("returns false for a directory", () => {
      // Arrange
      statSyncMock.mockReturnValue({
        isFile: () => false,
      } as unknown as fs.Stats);
      const sut = new RealFileSystem();

      // Act / Assert
      expect(sut.isFile("/some/dir")).toBe(false);
    });

    it("returns false when statSync throws (missing path)", () => {
      // Arrange
      statSyncMock.mockImplementation(() => {
        throw new Error("ENOENT");
      });
      const sut = new RealFileSystem();

      // Act / Assert
      expect(sut.isFile("/missing")).toBe(false);
    });
  });

  describe("readTextFile", () => {
    it("returns decoded UTF-8 content", () => {
      // Arrange
      readFileSyncMock.mockReturnValue("file body");
      const sut = new RealFileSystem();

      // Act
      const result = sut.readTextFile("/some/file.txt");

      // Assert
      expect(result).toBe("file body");
      expect(readFileSyncMock).toHaveBeenCalledWith("/some/file.txt", "utf8");
    });
  });

  describe("writeTextFile", () => {
    it("delegates to writeFileSync with utf8 encoding", () => {
      // Arrange
      const sut = new RealFileSystem();

      // Act
      sut.writeTextFile("/out/file.txt", "content");

      // Assert
      expect(writeFileSyncMock).toHaveBeenCalledWith(
        "/out/file.txt",
        "content",
        "utf8",
      );
    });
  });

  describe("glob", () => {
    it("returns matches consistent with governed glob semantics", () => {
      // Arrange: model a tree where readdirSync returns entries per directory.
      readdirSyncMock.mockImplementation((dir: fs.PathLike) => {
        const path = String(dir);
        if (path.endsWith("/repo") || path === "/repo") {
          return [dirent("scripts", true)] as unknown as ReturnType<
            typeof fs.readdirSync
          >;
        }
        if (path.endsWith("scripts")) {
          return [
            dirent("config.json", false),
            dirent("notes.txt", false),
          ] as unknown as ReturnType<typeof fs.readdirSync>;
        }
        return [] as unknown as ReturnType<typeof fs.readdirSync>;
      });
      const sut = new RealFileSystem();

      // Act
      const matches = sut.glob("/repo", "scripts/**/*.json");

      // Assert: only the .json file under scripts matches.
      expect(matches).toContain("/repo/scripts/config.json");
      expect(matches).not.toContain("/repo/scripts/notes.txt");
    });

    it("returns an empty list when the root cannot be read", () => {
      // Arrange
      readdirSyncMock.mockImplementation(() => {
        throw new Error("ENOENT");
      });
      const sut = new RealFileSystem();

      // Act
      const matches = sut.glob("/missing", "scripts/**/*.json");

      // Assert
      expect(matches).toEqual([]);
    });

    it("matches a directory entry against a directory-style exclude glob", () => {
      // Arrange
      readdirSyncMock.mockImplementation((dir: fs.PathLike) => {
        const path = String(dir);
        if (path === "/repo") {
          return [dirent("data", true)] as unknown as ReturnType<
            typeof fs.readdirSync
          >;
        }
        if (path.endsWith("data")) {
          return [dirent("corpus.json", false)] as unknown as ReturnType<
            typeof fs.readdirSync
          >;
        }
        return [] as unknown as ReturnType<typeof fs.readdirSync>;
      });
      const sut = new RealFileSystem();

      // Act
      const matches = sut.glob("/repo", "data/**");

      // Assert: data/** matches the nested file under data.
      expect(matches).toContain("/repo/data/corpus.json");
    });
  });
});
