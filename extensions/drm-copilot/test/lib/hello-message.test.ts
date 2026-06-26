import { describe, expect, it } from "@jest/globals";

import { type FileSystem } from "../../src/lib/file-system";
import { writeHelloMessage } from "../../src/lib/hello-message";

/**
 * In-memory {@link FileSystem} fake recording `ensureDir` calls and the content
 * written via `writeTextFile`. The read/discovery methods are unused by
 * {@link writeHelloMessage} and throw to surface any unexpected dependency.
 */
class InMemoryFileSystem implements FileSystem {
  readonly written = new Map<string, string>();
  readonly ensuredDirs: string[] = [];

  glob(): string[] {
    throw new Error("not used");
  }

  isFile(): boolean {
    throw new Error("not used");
  }

  exists(): boolean {
    throw new Error("not used");
  }

  isDirectory(): boolean {
    throw new Error("not used");
  }

  listDirectory(): string[] {
    throw new Error("not used");
  }

  readTextFile(): string {
    throw new Error("not used");
  }

  writeTextFile(path: string, content: string): void {
    this.written.set(path, content);
  }

  ensureDir(path: string): void {
    this.ensuredDirs.push(path);
  }
}

describe("writeHelloMessage", () => {
  const workspaceRoot = "/workspace";
  const expectedPath = "/workspace/artifacts/hello_python.txt";

  it("ensures the artifacts parent directory is created", () => {
    // Arrange
    const fs = new InMemoryFileSystem();

    // Act
    writeHelloMessage({ fileSystem: fs, workspaceRoot });

    // Assert
    expect(fs.ensuredDirs).toContain("/workspace/artifacts");
  });

  it("writes the exact hello_python.txt content to the resolved path", () => {
    // Arrange
    const fs = new InMemoryFileSystem();

    // Act
    writeHelloMessage({ fileSystem: fs, workspaceRoot });

    // Assert: byte-identical to the former Python output, including trailing
    // newline.
    expect(fs.written.get(expectedPath)).toBe("hello_python:ok\n");
  });

  it("returns the structured result with tool, summary, and artifacts", () => {
    // Arrange
    const fs = new InMemoryFileSystem();

    // Act
    const result = writeHelloMessage({ fileSystem: fs, workspaceRoot });

    // Assert
    expect(result.tool).toBe("hello_python");
    expect(result.workspaceRoot).toBe(workspaceRoot);
    expect(result.summary).toBe("Wrote artifacts/hello_python.txt.");
    expect(result.artifacts).toEqual(["artifacts/hello_python.txt"]);
  });

  it("normalizes the written path to POSIX separators on Windows-style roots", () => {
    // Arrange: a backslash-separated workspace root must yield a POSIX path.
    const fs = new InMemoryFileSystem();

    // Act
    writeHelloMessage({ fileSystem: fs, workspaceRoot: "C:\\repo" });

    // Assert
    expect(fs.written.has("C:/repo/artifacts/hello_python.txt")).toBe(true);
    expect(fs.ensuredDirs).toContain("C:/repo/artifacts");
  });

  it("emits the summary through the optional log sink", () => {
    // Arrange
    const fs = new InMemoryFileSystem();
    const logged: string[] = [];

    // Act
    const result = writeHelloMessage({
      fileSystem: fs,
      workspaceRoot,
      log: (message) => logged.push(message),
    });

    // Assert
    expect(logged).toEqual([result.summary]);
  });
});
