/**
 * Unit tests for `src/lib/new-active-feature-folder/models.ts`.
 *
 * Mirrors `tests/scripts/dev_tools/test_new_active_feature_folder_models_coverage.py`.
 * Uses Jest with injected `node:fs` mocks (no real filesystem) and a fixed
 * instant for the clock seam. AAA structure, one behavior per test.
 */

import { afterEach, describe, expect, it, jest } from "@jest/globals";

jest.mock("node:fs");

import * as nodeFs from "node:fs";

import {
  extractDateFromTimestamp,
  getEstTimestamp,
  NAME_PATTERN,
  RealFolderFileSystem,
  validateFeatureName,
} from "../../../src/lib/new-active-feature-folder/models";

const fsMock = nodeFs as jest.Mocked<typeof nodeFs>;

afterEach(() => {
  jest.resetAllMocks();
});

/**
 * Build a minimal `Dirent`-like object for `readdirSync(..., {withFileTypes})`.
 *
 * @param name Entry base name.
 * @param kind Whether the entry is a file or a directory.
 * @returns A `Dirent`-shaped object usable by the code under test.
 */
function dirent(name: string, kind: "file" | "dir"): nodeFs.Dirent {
  return {
    name,
    isFile: () => kind === "file",
    isDirectory: () => kind === "dir",
  } as unknown as nodeFs.Dirent;
}

describe("RealFolderFileSystem.copyTree", () => {
  it("preserves each source-relative path and copies files only", () => {
    // Arrange: a source tree with one nested dir, one nested file, one top file.
    const fs = new RealFolderFileSystem();
    fsMock.readdirSync.mockImplementation((dir: nodeFs.PathLike) => {
      const dirStr = String(dir).replace(/\\/g, "/");
      if (dirStr === "/workspace/templates") {
        return [
          dirent("nested", "dir"),
          dirent("two.txt", "file"),
        ] as unknown as ReturnType<typeof nodeFs.readdirSync>;
      }
      if (dirStr === "/workspace/templates/nested") {
        return [dirent("one.md", "file")] as unknown as ReturnType<
          typeof nodeFs.readdirSync
        >;
      }
      return [] as unknown as ReturnType<typeof nodeFs.readdirSync>;
    });
    fsMock.mkdirSync.mockReturnValue(undefined);
    fsMock.copyFileSync.mockReturnValue(undefined);

    // Act
    fs.copyTree("/workspace/templates", "/workspace/output");

    // Assert: only files copied, each at its source-relative destination path.
    const copies = fsMock.copyFileSync.mock.calls.map((call) => [
      String(call[0]).replace(/\\/g, "/"),
      String(call[1]).replace(/\\/g, "/"),
    ]);
    expect(copies).toEqual([
      ["/workspace/templates/nested/one.md", "/workspace/output/nested/one.md"],
      ["/workspace/templates/two.txt", "/workspace/output/two.txt"],
    ]);
  });
});

describe("RealFolderFileSystem.listFiles", () => {
  it("returns an empty array for a missing directory", () => {
    // Arrange
    const fs = new RealFolderFileSystem();
    fsMock.existsSync.mockReturnValue(false);

    // Act
    const result = fs.listFiles("/workspace/missing");

    // Assert
    expect(result).toEqual([]);
    expect(fsMock.readdirSync).not.toHaveBeenCalled();
  });

  it("returns only the regular files directly under the directory", () => {
    // Arrange
    const fs = new RealFolderFileSystem();
    fsMock.existsSync.mockReturnValue(true);
    fsMock.readdirSync.mockReturnValue([
      dirent("a.md", "file"),
      dirent("sub", "dir"),
      dirent("b.md", "file"),
    ] as unknown as ReturnType<typeof nodeFs.readdirSync>);

    // Act
    const result = fs.listFiles("/workspace/potential");

    // Assert
    expect(result).toEqual([
      "/workspace/potential/a.md",
      "/workspace/potential/b.md",
    ]);
  });
});

describe("RealFolderFileSystem.move", () => {
  it("ensures the parent, unlinks an existing destination file, then renames", () => {
    // Arrange: destination exists as a file; record the call order.
    const fs = new RealFolderFileSystem();
    const order: string[] = [];
    fsMock.mkdirSync.mockImplementation(() => {
      order.push("mkdir");
      return undefined;
    });
    fsMock.existsSync.mockReturnValue(true);
    fsMock.statSync.mockReturnValue({
      isFile: () => true,
    } as unknown as nodeFs.Stats);
    fsMock.unlinkSync.mockImplementation(() => {
      order.push("unlink");
    });
    fsMock.renameSync.mockImplementation(() => {
      order.push("rename");
    });

    // Act
    fs.move("/workspace/source.md", "/workspace/out/target.md");

    // Assert: mkdir -> unlink -> rename order is preserved.
    expect(order).toEqual(["mkdir", "unlink", "rename"]);
  });

  it("does not unlink when the destination does not exist", () => {
    // Arrange
    const fs = new RealFolderFileSystem();
    fsMock.mkdirSync.mockReturnValue(undefined);
    fsMock.existsSync.mockReturnValue(false);
    fsMock.renameSync.mockReturnValue(undefined);

    // Act
    fs.move("/workspace/source.md", "/workspace/out/target.md");

    // Assert
    expect(fsMock.unlinkSync).not.toHaveBeenCalled();
    expect(fsMock.renameSync).toHaveBeenCalledTimes(1);
  });
});

describe("RealFolderFileSystem.exists / ensureDir", () => {
  it("delegates exists() to fs.existsSync", () => {
    // Arrange
    const fs = new RealFolderFileSystem();
    fsMock.existsSync.mockReturnValue(true);

    // Act
    const result = fs.exists("/workspace/out");

    // Assert
    expect(result).toBe(true);
    expect(fsMock.existsSync).toHaveBeenCalledWith("/workspace/out");
  });

  it("delegates ensureDir() to fs.mkdirSync with recursive option", () => {
    // Arrange
    const fs = new RealFolderFileSystem();
    fsMock.mkdirSync.mockReturnValue(undefined);

    // Act
    fs.ensureDir("/workspace/out");

    // Assert
    expect(fsMock.mkdirSync).toHaveBeenCalledWith("/workspace/out", {
      recursive: true,
    });
  });
});

describe("RealFolderFileSystem.copyFile / text I/O", () => {
  it("copyFile ensures the destination parent then copies the file", () => {
    // Arrange
    const fs = new RealFolderFileSystem();
    fsMock.mkdirSync.mockReturnValue(undefined);
    fsMock.copyFileSync.mockReturnValue(undefined);

    // Act
    fs.copyFile("/workspace/in/template.md", "/workspace/out/copied.md");

    // Assert
    expect(
      String(fsMock.mkdirSync.mock.calls[0]?.[0]).replace(/\\/g, "/"),
    ).toBe("/workspace/out");
    expect(fsMock.copyFileSync).toHaveBeenCalledWith(
      "/workspace/in/template.md",
      "/workspace/out/copied.md",
    );
  });

  it("readText delegates to fs.readFileSync with utf8", () => {
    // Arrange
    const fs = new RealFolderFileSystem();
    fsMock.readFileSync.mockReturnValue("copied-content" as never);

    // Act
    const content = fs.readText("/workspace/out/copied.md");

    // Assert
    expect(content).toBe("copied-content");
    expect(fsMock.readFileSync).toHaveBeenCalledWith(
      "/workspace/out/copied.md",
      "utf8",
    );
  });

  it("writeText ensures the parent then writes utf8 content", () => {
    // Arrange
    const fs = new RealFolderFileSystem();
    fsMock.mkdirSync.mockReturnValue(undefined);
    fsMock.writeFileSync.mockReturnValue(undefined);

    // Act
    fs.writeText("/workspace/out/copied.md", "updated-content");

    // Assert
    expect(
      String(fsMock.mkdirSync.mock.calls[0]?.[0]).replace(/\\/g, "/"),
    ).toBe("/workspace/out");
    expect(fsMock.writeFileSync).toHaveBeenCalledWith(
      "/workspace/out/copied.md",
      "updated-content",
      "utf8",
    );
  });
});

describe("getEstTimestamp", () => {
  it("formats a fixed injected instant as YYYY-MM-DDTHH-mm in America/New_York", () => {
    // Arrange: 2024-02-03T04:05 in America/New_York is 09:05 UTC (EST, UTC-5).
    const instant = new Date("2024-02-03T09:05:00Z");

    // Act
    const result = getEstTimestamp(() => instant);

    // Assert
    expect(result).toBe("2024-02-03T04-05");
  });
});

describe("extractDateFromTimestamp", () => {
  it("returns the prefix before the first T", () => {
    // Arrange / Act
    const result = extractDateFromTimestamp("2026-03-14T15-48");

    // Assert
    expect(result).toBe("2026-03-14");
  });
});

describe("validateFeatureName", () => {
  it("accepts kebab-case and underscore-case names", () => {
    // Arrange / Act / Assert
    expect(() => {
      validateFeatureName("notes-feature");
    }).not.toThrow();
    expect(() => {
      validateFeatureName("notes_feature");
    }).not.toThrow();
  });

  it("throws the byte-identical message for an invalid name", () => {
    // Arrange / Act / Assert
    expect(() => {
      validateFeatureName("Not Valid!");
    }).toThrow(
      "Aborted: 'Not Valid!' is invalid. Use kebab/underscore-case letters/numbers (e.g., notes-feature or notes_feature).",
    );
  });

  it("throws for an empty name", () => {
    // Arrange / Act / Assert
    expect(() => {
      validateFeatureName("");
    }).toThrow(
      "Aborted: '' is invalid. Use kebab/underscore-case letters/numbers (e.g., notes-feature or notes_feature).",
    );
  });

  it("NAME_PATTERN matches a kebab/underscore slug and rejects spaces", () => {
    // Arrange / Act / Assert
    expect(NAME_PATTERN.test("notes-feature_2")).toBe(true);
    expect(NAME_PATTERN.test("Not Valid")).toBe(false);
  });
});
