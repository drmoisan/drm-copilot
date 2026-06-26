import { describe, expect, it } from "@jest/globals";

import type { FileSystem } from "../../src/lib/file-system";
import {
  ensureSeparatorBlock,
  formatLabelHeading,
  isLabelLine,
  isSeparatorLine,
  LABEL_PREFIXES,
  prefixContentLine,
  processMarkdown,
  readContent,
  SEPARATOR_LINE,
  writeOutput,
} from "../../src/lib/markdown-label-formatter";

/**
 * In-memory FileSystem fake for hermetic I/O tests. Backed by a Map of path to
 * content. The glob method is unused by this suite and returns an empty list.
 */
class InMemoryFileSystem implements FileSystem {
  readonly files = new Map<string, string>();

  glob(): string[] {
    return [];
  }

  isFile(path: string): boolean {
    return this.files.has(path);
  }

  readTextFile(path: string): string {
    const content = this.files.get(path);
    if (content === undefined) {
      throw new Error(`file not found: ${path}`);
    }
    return content;
  }

  writeTextFile(path: string, content: string): void {
    this.files.set(path, content);
  }

  ensureDir(): void {
    // No-op: this in-memory fake does not model directories.
  }
}

describe("markdown-label-formatter constants", () => {
  it("exposes label prefixes and separator token", () => {
    // Arrange / Act / Assert
    expect(LABEL_PREFIXES).toEqual(["User:", "GitHub Copilot:"]);
    expect(SEPARATOR_LINE).toBe("---");
  });
});

describe("processMarkdown", () => {
  it("formats the first label with content", () => {
    // Arrange
    const input = "User: Hello world";
    const expected = ["# User:", "", "", "> Hello world"].join("\n");

    // Act
    const result = processMarkdown(input);

    // Assert
    expect(result).toBe(expected);
  });

  it("inserts a separator before a non-initial label", () => {
    // Arrange
    const input = ["Intro line", "User: Hi there"].join("\n");
    const expected = [
      "> Intro line",
      "",
      "---",
      "",
      "# User:",
      "",
      "",
      "> Hi there",
    ].join("\n");

    // Act
    const result = processMarkdown(input);

    // Assert
    expect(result).toBe(expected);
  });

  it("handles multiple labels and quotes other lines", () => {
    // Arrange
    const input = [
      "User: First message",
      "Second line from user",
      "GitHub Copilot: Reply text",
      "Follow up line",
    ].join("\n");
    const expected = [
      "# User:",
      "",
      "",
      "> First message",
      "> Second line from user",
      "",
      "---",
      "",
      "# GitHub Copilot:",
      "",
      "",
      "> Reply text",
      "> Follow up line",
    ].join("\n");

    // Act
    const result = processMarkdown(input);

    // Assert
    expect(result).toBe(expected);
  });

  it("skips extra spacing when a label has no inline text", () => {
    // Arrange
    const input = ["Intro", "User:", "Next line"].join("\n");
    const expected = ["> Intro", "", "---", "", "# User:", "> Next line"].join(
      "\n",
    );

    // Act
    const result = processMarkdown(input);

    // Assert
    expect(result).toBe(expected);
  });

  it("preserves a trailing newline", () => {
    // Arrange
    const input = "User: Hi\n";
    const expected = ["# User:", "", "", "> Hi", ""].join("\n");

    // Act
    const result = processMarkdown(input);

    // Assert
    expect(result).toBe(expected);
  });

  it("treats a whitespace-only separator line as blank", () => {
    // Arrange
    const input = "User: text\n   \nmore content";

    // Act
    const result = processMarkdown(input);

    // Assert: whitespace-only lines collapse to blank, producing a blank gap.
    expect(result).toContain("\n\n");
  });
});

describe("isLabelLine", () => {
  it("recognizes the User label", () => {
    expect(isLabelLine("User: some text")).toBe(true);
  });

  it("recognizes the GitHub Copilot label", () => {
    expect(isLabelLine("GitHub Copilot: response")).toBe(true);
  });

  it("rejects a non-label line", () => {
    expect(isLabelLine("Just some text")).toBe(false);
  });
});

describe("isSeparatorLine", () => {
  it("treats a blank line as a separator", () => {
    expect(isSeparatorLine("")).toBe(true);
  });

  it("treats the separator token as a separator", () => {
    expect(isSeparatorLine("---")).toBe(true);
  });

  it("rejects a content line", () => {
    expect(isSeparatorLine("Some content")).toBe(false);
  });
});

describe("formatLabelHeading", () => {
  it("formats a label with trailing text", () => {
    // Arrange / Act
    const result = formatLabelHeading("User: hello world");

    // Assert
    expect(result.heading).toBe("# User:");
    expect(result.trailing).toBe("hello world");
  });

  it("formats a label with no trailing text", () => {
    // Arrange / Act
    const result = formatLabelHeading("User:");

    // Assert
    expect(result.heading).toBe("# User:");
    expect(result.trailing).toBe("");
  });
});

describe("prefixContentLine", () => {
  it("quotes a non-empty line", () => {
    expect(prefixContentLine("content text")).toBe("> content text");
  });

  it("emits a bare quote marker for an empty line", () => {
    expect(prefixContentLine("")).toBe(">");
  });
});

describe("ensureSeparatorBlock", () => {
  it("adds a separator block", () => {
    // Arrange
    const lines = ["content"];

    // Act
    ensureSeparatorBlock(lines);

    // Assert
    expect(lines).toEqual(["content", "", "---", ""]);
  });

  it("removes trailing blanks before adding the separator", () => {
    // Arrange
    const lines = ["content", "", ""];

    // Act
    ensureSeparatorBlock(lines);

    // Assert
    expect(lines).toEqual(["content", "", "---", ""]);
  });
});

describe("readContent", () => {
  it("reads from a file path", () => {
    // Arrange
    const fs = new InMemoryFileSystem();
    fs.writeTextFile("input.md", "file content");

    // Act
    const result = readContent(fs, "input.md", () => "stdin content");

    // Assert
    expect(result).toBe("file content");
  });

  it("reads from the stdin callback when path is null", () => {
    // Arrange
    const fs = new InMemoryFileSystem();

    // Act
    const result = readContent(fs, null, () => "stdin content");

    // Assert
    expect(result).toBe("stdin content");
  });
});

describe("writeOutput", () => {
  it("writes to a file path", () => {
    // Arrange
    const fs = new InMemoryFileSystem();

    // Act
    writeOutput(fs, "output content", "out.md", () => {
      throw new Error("stdout should not be called");
    });

    // Assert
    expect(fs.readTextFile("out.md")).toBe("output content");
  });

  it("writes to the stdout callback when path is null", () => {
    // Arrange
    const fs = new InMemoryFileSystem();
    const captured: string[] = [];

    // Act
    writeOutput(fs, "stdout content", null, (s) => captured.push(s));

    // Assert
    expect(captured).toEqual(["stdout content"]);
  });
});
