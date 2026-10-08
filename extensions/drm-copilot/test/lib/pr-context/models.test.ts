import { describe, expect, it } from "@jest/globals";

import {
  compareCodePoint,
  escapeRegExp,
  findUserStoryLink,
  formatList,
  normalizeReference,
  section,
  sortedSet,
  splitLines,
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

describe("compareCodePoint", () => {
  it("returns 0 for identical strings", () => {
    expect(compareCodePoint("abc", "abc")).toBe(0);
  });

  it("returns -1 when left sorts before right", () => {
    expect(compareCodePoint("a", "b")).toBe(-1);
  });

  it("returns 1 when left sorts after right", () => {
    expect(compareCodePoint("b", "a")).toBe(1);
  });

  it("treats the empty string as less than a non-empty string", () => {
    expect(compareCodePoint("", "a")).toBe(-1);
  });

  it("is case-sensitive, sorting uppercase before lowercase", () => {
    expect(compareCodePoint("A", "a")).toBe(-1);
  });

  it("orders a prefix before its longer extension", () => {
    expect(compareCodePoint("a", "ab")).toBe(-1);
  });
});

describe("compareCodePoint - enumerative properties over a fixed domain", () => {
  const DOMAIN = [
    "",
    "a",
    "A",
    "aa",
    "ab",
    "b",
    "ba",
    "é",
    "😀",
    "\uE000",
    "\uFFFF",
  ];

  /**
   * Describe a string as its U+XXXX code-point sequence so a violation entry
   * names the offending value unambiguously, including non-printing characters.
   */
  const describeCodePoints = (value: string): string => {
    if (value === "") {
      return "(empty)";
    }
    return [...value]
      .map(
        (character) =>
          "U+" +
          (character.codePointAt(0) ?? 0)
            .toString(16)
            .toUpperCase()
            .padStart(4, "0"),
      )
      .join(" ");
  };

  it("is reflexive for every value in the domain", () => {
    for (const value of DOMAIN) {
      expect(compareCodePoint(value, value)).toBe(0);
    }
  });

  it("is antisymmetric for every ordered pair in the domain", () => {
    // Arrange
    const violations: string[] = [];

    // Act: record every pair whose forward and backward results disagree.
    for (const left of DOMAIN) {
      for (const right of DOMAIN) {
        const forward = compareCodePoint(left, right);
        const backward = compareCodePoint(right, left);
        if (forward !== -backward) {
          violations.push(
            `[${describeCodePoints(left)}] vs [${describeCodePoints(right)}]: forward ${String(forward)}, backward ${String(backward)}`,
          );
        }
      }
    }

    // Assert: an empty list; a failure names each offending pair.
    expect(violations).toEqual([]);
  });

  it("is transitive for every ordered triple in the domain", () => {
    // Arrange
    const violations: string[] = [];

    // Act: record every triple where a <= b and b <= c but a > c.
    for (const a of DOMAIN) {
      for (const b of DOMAIN) {
        for (const c of DOMAIN) {
          if (
            compareCodePoint(a, b) <= 0 &&
            compareCodePoint(b, c) <= 0 &&
            compareCodePoint(a, c) > 0
          ) {
            violations.push(
              `[${describeCodePoints(a)}] <= [${describeCodePoints(b)}] <= [${describeCodePoints(c)}] but a > c`,
            );
          }
        }
      }
    }

    // Assert: an empty list; a failure names each offending triple.
    expect(violations).toEqual([]);
  });

  it("returns only -1, 0, or 1 for every ordered pair in the domain", () => {
    for (const left of DOMAIN) {
      for (const right of DOMAIN) {
        expect([-1, 0, 1]).toContain(compareCodePoint(left, right));
      }
    }
  });
});

describe("compareCodePoint issue #740 code-point order", () => {
  it("D1 orders U+FFFF before U+1F600 in both argument orders", () => {
    // Arrange / Act
    const forward = compareCodePoint("\uFFFF", "\u{1F600}");
    const backward = compareCodePoint("\u{1F600}", "\uFFFF");

    // Assert
    expect(forward).toBe(-1);
    expect(backward).toBe(1);
  });

  it("D2 orders U+E000 before U+10000", () => {
    // Arrange / Act
    const result = compareCodePoint("\uE000", "\u{10000}");

    // Assert
    expect(result).toBe(-1);
  });

  it("D3 orders U+FF5E before U+1F600", () => {
    // Arrange / Act
    const result = compareCodePoint("\uFF5E", "\u{1F600}");

    // Assert
    expect(result).toBe(-1);
  });

  it("D4 orders a shared-prefix U+FFFD before a shared-prefix U+1F600", () => {
    // Arrange / Act
    const result = compareCodePoint("a\uFFFD", "a\u{1F600}");

    // Assert
    expect(result).toBe(-1);
  });

  it("S1 sorts a mixed BMP and non-BMP array into a literal code-point order", () => {
    // Arrange
    const sample = [
      "b",
      "\u{1F600}",
      "a",
      "\uFFFF",
      "\u00E9",
      "",
      "A",
      "ab",
      "\uE000",
    ];

    // Act
    const sorted = [...sample].sort(compareCodePoint);

    // Assert: the expected order is a literal, not derived from `<` or `>`.
    expect(sorted).toEqual([
      "",
      "A",
      "a",
      "ab",
      "b",
      "\u00E9",
      "\uE000",
      "\uFFFF",
      "\u{1F600}",
    ]);
  });

  it("A1 orders U+00E9 before U+1F600", () => {
    // Arrange / Act
    const result = compareCodePoint("\u00E9", "\u{1F600}");

    // Assert
    expect(result).toBe(-1);
  });

  it("A2 orders U+1F600 before U+1F601 (trail-surrogate difference)", () => {
    // Arrange / Act
    const result = compareCodePoint("\u{1F600}", "\u{1F601}");

    // Assert
    expect(result).toBe(-1);
  });

  it("A3 orders U+1F600 before U+20000 (lead-surrogate difference)", () => {
    // Arrange / Act
    const result = compareCodePoint("\u{1F600}", "\u{20000}");

    // Assert
    expect(result).toBe(-1);
  });

  it("A4 orders a before a U+1F600 extension (prefix)", () => {
    // Arrange / Act
    const result = compareCodePoint("a", "a\u{1F600}");

    // Assert
    expect(result).toBe(-1);
  });
});

describe("sortedSet", () => {
  it("removes duplicates and sorts by code point", () => {
    // Arrange / Act
    const result = sortedSet(["b", "a", "b", "A"]);

    // Assert
    expect(result).toEqual(["A", "a", "b"]);
  });

  it("orders U+FFFF before U+1F600", () => {
    // Arrange / Act
    const result = sortedSet(["\u{1F600}", "\uFFFF"]);

    // Assert
    expect(result).toEqual(["\uFFFF", "\u{1F600}"]);
  });

  it("accepts a Set and a generator", () => {
    // Arrange
    const fromSet = new Set(["b", "a"]);
    function* generateValues(): Generator<string> {
      yield "b";
      yield "a";
      yield "b";
    }

    // Act
    const setResult = sortedSet(fromSet);
    const generatorResult = sortedSet(generateValues());

    // Assert
    expect(setResult).toEqual(["a", "b"]);
    expect(generatorResult).toEqual(["a", "b"]);
  });

  it("does not mutate the input array", () => {
    // Arrange
    const values = ["b", "a", "b"];

    // Act
    sortedSet(values);

    // Assert
    expect(values).toEqual(["b", "a", "b"]);
  });

  it("returns an empty array for empty input", () => {
    // Arrange / Act
    const result = sortedSet([]);

    // Assert
    expect(result).toEqual([]);
  });
});

describe("escapeRegExp", () => {
  it("escapes every regex metacharacter so the pattern matches the literal text", () => {
    // Arrange
    const text = ".*+?^${}()|[]\\";

    // Act
    const pattern = new RegExp("^" + escapeRegExp(text) + "$", "u");

    // Assert
    expect(pattern.test(text)).toBe(true);
  });

  it("leaves a hyphen unescaped", () => {
    // Arrange / Act
    const result = escapeRegExp("a-b");

    // Assert
    expect(result).toBe("a-b");
  });

  it("returns plain text unchanged", () => {
    // Arrange / Act
    const result = escapeRegExp("abc");

    // Assert
    expect(result).toBe("abc");
  });
});

describe("splitLines", () => {
  it("returns an empty array for the empty string", () => {
    expect(splitLines("")).toEqual([]);
  });

  it("splits on CRLF", () => {
    expect(splitLines("a\r\nb")).toEqual(["a", "b"]);
  });

  it("splits on a lone CR", () => {
    expect(splitLines("a\rb")).toEqual(["a", "b"]);
  });

  it("drops a single trailing terminator", () => {
    expect(splitLines("a\n")).toEqual(["a"]);
  });

  it("keeps an interior empty line before a trailing terminator", () => {
    expect(splitLines("a\n\n")).toEqual(["a", ""]);
  });

  it("returns one empty line for a lone newline", () => {
    expect(splitLines("\n")).toEqual([""]);
  });

  it("does not split on U+2028", () => {
    expect(splitLines("a\u2028b")).toEqual(["a\u2028b"]);
  });
});
