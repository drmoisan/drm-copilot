import { describe, expect, it, jest } from "@jest/globals";

import { collectCommitContext } from "../../src/lib/collect-commit-context";
import {
  buildOptions,
  createRunner,
  defaultRoute,
  InMemoryFileSystem,
} from "./collect-commit-context.test-helpers";

describe("collectCommitContext output", () => {
  it("writes the output file at the configured path", () => {
    // Arrange
    const { runner } = createRunner(defaultRoute);
    const fs = new InMemoryFileSystem();

    // Act
    collectCommitContext(buildOptions(runner, fs));

    // Assert
    expect(fs.written.has("/workspace/artifacts/commit_context.txt")).toBe(
      true,
    );
  });

  it("ensures the parent directory of the output path is created", () => {
    // Arrange
    const { runner } = createRunner(defaultRoute);
    const fs = new InMemoryFileSystem();

    // Act
    collectCommitContext(buildOptions(runner, fs));

    // Assert: ensureDir is invoked with the dirname of the output path.
    expect(fs.ensuredDirs).toContain("/workspace/artifacts");
  });

  it("contains all thirteen expected section headers", () => {
    // Arrange: route per the Python `test_output_contains_expected_sections`.
    const { runner } = createRunner((args) => {
      if (args.includes("remote")) {
        return { stdout: "origin\thttps://github.com/user/repo.git (fetch)" };
      }
      if (args.includes("rev-parse") && args.includes("HEAD")) {
        return { stdout: "main" };
      }
      if (args.includes("rev-parse") && args.includes("@{u}")) {
        return { stdout: "origin/main" };
      }
      if (args.includes("status")) {
        return { stdout: "## main...origin/main" };
      }
      if (
        args.includes("diff") &&
        args.includes("--cached") &&
        args.includes("--name-status")
      ) {
        return { stdout: "M\tfile.py" };
      }
      if (args.includes("diff") && args.includes("--cached")) {
        return { stdout: "diff --git a/file.py b/file.py" };
      }
      if (args.includes("diff") && args.includes("--name-status")) {
        return { stdout: "" };
      }
      if (
        args.includes("diff") &&
        args.includes("HEAD") &&
        args.includes("--stat")
      ) {
        return { stdout: "1 file changed" };
      }
      if (
        args.includes("diff") &&
        args.includes("HEAD") &&
        args.includes("--name-only")
      ) {
        return { stdout: "file.py" };
      }
      if (args.includes("ls-files")) {
        return { stdout: "" };
      }
      if (args.includes("log")) {
        return {
          stdout:
            "abc123\nAuthor <author@example.com>\nMon Dec 18 2023\n" +
            "Committer <committer@example.com>\nMon Dec 18 2023\n" +
            "feat: add feature\n\ndetailed body",
        };
      }
      return { stdout: "" };
    });
    const fs = new InMemoryFileSystem();

    // Act
    collectCommitContext(buildOptions(runner, fs));

    // Assert
    const body =
      fs.written.get("/workspace/artifacts/commit_context.txt") ?? "";
    const expectedHeaders = [
      "===== Repository remotes =====",
      "===== Current branch =====",
      "===== Upstream =====",
      "===== Status (short) =====",
      "===== Staged files (name-status) =====",
      "===== Staged diff =====",
      "===== Unstaged files (name-status) =====",
      "===== Unstaged diff =====",
      "===== Untracked files =====",
      "===== Diff stat (staged + unstaged) =====",
      "===== Changed Python files =====",
      "===== Last commit (header only) =====",
      "===== Change intent (edit below) =====",
    ];
    for (const header of expectedHeaders) {
      expect(body).toContain(header);
    }
  });

  it("renders (no upstream) when there is no upstream", () => {
    // Arrange
    const { runner } = createRunner((args) => {
      if (args.includes("@{u}")) {
        return { stdout: "" };
      }
      return { stdout: "mock" };
    });
    const fs = new InMemoryFileSystem();

    // Act
    collectCommitContext(buildOptions(runner, fs));

    // Assert
    const body =
      fs.written.get("/workspace/artifacts/commit_context.txt") ?? "";
    expect(body).toContain("(no upstream)");
  });

  it("renders (no staged changes) when staged diffs are empty", () => {
    // Arrange
    const { runner } = createRunner((args) => {
      if (args.includes("diff") && args.includes("--cached")) {
        return { stdout: "" };
      }
      return { stdout: "mock" };
    });
    const fs = new InMemoryFileSystem();

    // Act
    collectCommitContext(buildOptions(runner, fs));

    // Assert
    const body =
      fs.written.get("/workspace/artifacts/commit_context.txt") ?? "";
    expect(body).toContain("(no staged changes)");
  });

  it("renders (no unstaged changes) when unstaged diffs are empty", () => {
    // Arrange: mirror the Python no-unstaged routing.
    const { runner } = createRunner((args) => {
      if (
        args.includes("diff") &&
        !args.includes("--cached") &&
        args.includes("--name-status")
      ) {
        return { stdout: "" };
      }
      if (
        args.includes("diff") &&
        !args.includes("--cached") &&
        !args.includes("HEAD")
      ) {
        return { stdout: "" };
      }
      return { stdout: "mock" };
    });
    const fs = new InMemoryFileSystem();

    // Act
    collectCommitContext(buildOptions(runner, fs));

    // Assert
    const body =
      fs.written.get("/workspace/artifacts/commit_context.txt") ?? "";
    expect(body).toContain("(no unstaged changes)");
  });

  it("renders (no untracked files) when ls-files is empty", () => {
    // Arrange
    const { runner } = createRunner((args) => {
      if (args.includes("ls-files")) {
        return { stdout: "" };
      }
      return { stdout: "mock" };
    });
    const fs = new InMemoryFileSystem();

    // Act
    collectCommitContext(buildOptions(runner, fs));

    // Assert
    const body =
      fs.written.get("/workspace/artifacts/commit_context.txt") ?? "";
    expect(body).toContain("(no untracked files)");
  });

  it("renders (no changes) when the diff stat is empty", () => {
    // Arrange
    const { runner } = createRunner((args) => {
      if (
        args.includes("diff") &&
        args.includes("HEAD") &&
        args.includes("--stat")
      ) {
        return { stdout: "" };
      }
      return { stdout: "mock" };
    });
    const fs = new InMemoryFileSystem();

    // Act
    collectCommitContext(buildOptions(runner, fs));

    // Assert
    const body =
      fs.written.get("/workspace/artifacts/commit_context.txt") ?? "";
    expect(body).toContain("(no changes)");
  });

  it("filters changed files to keep only .py entries", () => {
    // Arrange
    const { runner } = createRunner((args) => {
      if (
        args.includes("diff") &&
        args.includes("HEAD") &&
        args.includes("--name-only")
      ) {
        return { stdout: "file1.py\nfile2.txt\nfile3.py\nREADME.md" };
      }
      return { stdout: "mock" };
    });
    const fs = new InMemoryFileSystem();

    // Act
    collectCommitContext(buildOptions(runner, fs));

    // Assert
    const body =
      fs.written.get("/workspace/artifacts/commit_context.txt") ?? "";
    expect(body).toContain("file1.py");
    expect(body).toContain("file3.py");
    expect(body).not.toContain("file2.txt");
    expect(body).not.toContain("README.md");
  });

  it("renders (no Python files changed) when no .py files changed", () => {
    // Arrange
    const { runner } = createRunner((args) => {
      if (
        args.includes("diff") &&
        args.includes("HEAD") &&
        args.includes("--name-only")
      ) {
        return { stdout: "file.txt\nREADME.md" };
      }
      return { stdout: "mock" };
    });
    const fs = new InMemoryFileSystem();

    // Act
    collectCommitContext(buildOptions(runner, fs));

    // Assert
    const body =
      fs.written.get("/workspace/artifacts/commit_context.txt") ?? "";
    expect(body).toContain("(no Python files changed)");
  });

  it("renders (no previous commits) when the log is empty", () => {
    // Arrange
    const { runner } = createRunner((args) => {
      if (args.includes("log")) {
        return { stdout: "" };
      }
      return { stdout: "mock" };
    });
    const fs = new InMemoryFileSystem();

    // Act
    collectCommitContext(buildOptions(runner, fs));

    // Assert
    const body =
      fs.written.get("/workspace/artifacts/commit_context.txt") ?? "";
    expect(body).toContain("(no previous commits)");
  });

  it("formats the last commit with all header fields and indented body lines", () => {
    // Arrange: mirror the Python `test_formats_last_commit_correctly` fixture.
    const { runner } = createRunner((args) => {
      if (args.includes("log")) {
        return {
          stdout:
            "abc123def456\n" +
            "John Doe <john@example.com>\n" +
            "Mon Dec 18 10:30:00 2023 -0500\n" +
            "Jane Committer <jane@example.com>\n" +
            "Mon Dec 18 10:35:00 2023 -0500\n" +
            "feat: add new feature\n" +
            "\n" +
            "This is a detailed description\n" +
            "spanning multiple lines",
        };
      }
      return { stdout: "mock" };
    });
    const fs = new InMemoryFileSystem();

    // Act
    collectCommitContext(buildOptions(runner, fs));

    // Assert
    const body =
      fs.written.get("/workspace/artifacts/commit_context.txt") ?? "";
    expect(body).toContain("commit abc123def456");
    expect(body).toContain("Author:     John Doe <john@example.com>");
    expect(body).toContain("AuthorDate: Mon Dec 18 10:30:00 2023 -0500");
    expect(body).toContain("Commit:     Jane Committer <jane@example.com>");
    expect(body).toContain("CommitDate: Mon Dec 18 10:35:00 2023 -0500");
    expect(body).toContain("    feat: add new feature");
    expect(body).toContain("    This is a detailed description");
    expect(body).toContain("    spanning multiple lines");
  });

  it("emits the written-path message through the log callback", () => {
    // Arrange
    const { runner } = createRunner(defaultRoute);
    const fs = new InMemoryFileSystem();
    const log = jest.fn<(message: string) => void>();

    // Act
    collectCommitContext(buildOptions(runner, fs, { log }));

    // Assert
    expect(log).toHaveBeenCalledWith(
      "Commit context written to: /workspace/artifacts/commit_context.txt",
    );
  });
});
