import { describe, expect, it } from "@jest/globals";

import {
  findUserStoryLink,
  formatList,
  normalizeReference,
  section,
  truncate,
  truncateLines,
} from "../../../src/lib/pr-context/models";

/**
 * Tests for the pure helpers ported from `pr_context/models.py`. Each test
 * targets one behavior and follows Arrange-Act-Assert. The cases exercise the
 * exact boundary and regex semantics the rendered PR-context output depends on.
 */

describe("section", () => {
  it("wraps the title in the banner with surrounding newlines", () => {
    // Arrange / Act
    const result = section("PR Comparison");

    // Assert
    expect(result).toBe("\n===== PR Comparison =====\n");
  });
});

describe("truncate", () => {
  it("returns the text unchanged when length equals the limit", () => {
    // Arrange: a string exactly at the default limit boundary.
    const text = "a".repeat(800);

    // Act
    const result = truncate(text);

    // Assert
    expect(result).toBe(text);
  });

  it("rstrips and appends an ellipsis when over the limit", () => {
    // Arrange: limit-3 prefix ends in spaces so rstrip is observable.
    const text = "ab   " + "c".repeat(100);

    // Act
    const result = truncate(text, 8);

    // Assert: first 5 chars are "ab   ", rstripped to "ab", then "...".
    expect(result).toBe("ab...");
  });

  it("returns the text unchanged when shorter than the limit", () => {
    expect(truncate("short", 800)).toBe("short");
  });
});

describe("truncateLines", () => {
  it("returns the text unchanged when line count is under the limit", () => {
    const text = "l1\nl2\nl3";
    expect(truncateLines(text, 5)).toBe(text);
  });

  it("returns the text unchanged when line count equals the limit", () => {
    const text = "l1\nl2\nl3";
    expect(truncateLines(text, 3)).toBe(text);
  });

  it("truncates and appends the suffix when over the limit", () => {
    // Arrange
    const text = "l1\nl2\nl3\nl4";

    // Act
    const result = truncateLines(text, 2);

    // Assert
    expect(result).toBe("l1\nl2\n\nTRUNCATED: first 2 lines shown");
  });
});

describe("normalizeReference", () => {
  it("strips a leading hash then surrounding whitespace", () => {
    // lstrip("#") only removes a hash that is the very first character; the
    // leading space here is not stripped by lstrip, so only the trailing space
    // is removed by the subsequent strip(), preserving the inner '#'.
    expect(normalizeReference("  #42 ")).toBe("#42");
  });

  it("strips a hash at the start then trims surrounding whitespace", () => {
    expect(normalizeReference("#42 ")).toBe("42");
  });

  it("strips all leading hashes (lstrip semantics)", () => {
    expect(normalizeReference("##7")).toBe("7");
  });

  it("returns a bare number unchanged", () => {
    expect(normalizeReference("99")).toBe("99");
  });
});

describe("findUserStoryLink", () => {
  it("returns null for empty body", () => {
    expect(findUserStoryLink("")).toBeNull();
  });

  it("returns null when no user-story link is present", () => {
    expect(findUserStoryLink("no link here")).toBeNull();
  });

  it("extracts the parenthesized markdown target", () => {
    const body = "See the story [here](docs/features/active/x/user-story.md).";
    expect(findUserStoryLink(body)).toBe(
      "docs/features/active/x/user-story.md",
    );
  });

  it("falls back to a bare token when no parenthesized match exists", () => {
    const body = "Story at docs/x/user-story.md for details";
    expect(findUserStoryLink(body)).toBe("docs/x/user-story.md");
  });

  it("extracts the repo-relative path from a GitHub blob URL", () => {
    const body =
      "(https://github.com/org/repo/blob/main/docs/features/active/x/user-story.md)";
    expect(findUserStoryLink(body)).toBe(
      "docs/features/active/x/user-story.md",
    );
  });

  it("strips a leading slash from a non-URL candidate", () => {
    const body = "(/docs/x/user-story.md)";
    expect(findUserStoryLink(body)).toBe("docs/x/user-story.md");
  });
});

describe("formatList", () => {
  it("returns the empty text when no truthy values remain", () => {
    expect(formatList([], "(none)")).toBe("(none)");
  });

  it("filters out falsy values before rendering", () => {
    expect(formatList(["a", "", "b"], "(none)")).toBe("- a\n- b");
  });

  it("returns the empty text when every value is falsy", () => {
    expect(formatList(["", ""], "(empty)")).toBe("(empty)");
  });
});
