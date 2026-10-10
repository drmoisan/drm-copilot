// Unit tests for the shared ordinal string comparator (issue #796).
// The first three blocks moved verbatim from test/lib/pr-context/models.test.ts;
// the enumerative domain is extended with unpaired surrogates and the research
// triple, and the issue #796 block covers the corrected total order.
import { describe, expect, it } from "@jest/globals";

import { compareCodePoint } from "../../src/lib/string-ordering";

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
    "\uD800",
    "\uDC00",
    "\uD800\uE000",
    "\u{10000}",
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

  it("matches code-point-sequence order for every well-formed pair in the domain", () => {
    // Arrange: a string is well-formed when every high surrogate is followed
    // by a low surrogate and no low surrogate lacks a preceding high surrogate.
    const isWellFormed = (value: string): boolean => {
      for (let index = 0; index < value.length; index += 1) {
        const unit = value.charCodeAt(index);
        if (unit >= 0xd800 && unit <= 0xdbff) {
          const next =
            index + 1 < value.length ? value.charCodeAt(index + 1) : -1;
          if (next < 0xdc00 || next > 0xdfff) {
            return false;
          }
          index += 1;
        } else if (unit >= 0xdc00 && unit <= 0xdfff) {
          return false;
        }
      }
      return true;
    };
    const toCodePoints = (value: string): number[] =>
      [...value].map((character) => character.codePointAt(0) ?? 0);
    const expectedSign = (left: string, right: string): number => {
      const leftPoints = toCodePoints(left);
      const rightPoints = toCodePoints(right);
      const sharedLength = Math.min(leftPoints.length, rightPoints.length);
      for (let index = 0; index < sharedLength; index += 1) {
        const leftPoint = leftPoints[index] ?? 0;
        const rightPoint = rightPoints[index] ?? 0;
        if (leftPoint !== rightPoint) {
          return leftPoint < rightPoint ? -1 : 1;
        }
      }
      if (leftPoints.length === rightPoints.length) {
        return 0;
      }
      return leftPoints.length < rightPoints.length ? -1 : 1;
    };
    const wellFormed = DOMAIN.filter(isWellFormed);
    const violations: string[] = [];

    // Act: record every ordered pair whose result differs from the
    // lexicographic comparison of the code-point sequences.
    for (const left of wellFormed) {
      for (const right of wellFormed) {
        const actual = compareCodePoint(left, right);
        const expected = expectedSign(left, right);
        if (actual !== expected) {
          violations.push(
            `[${describeCodePoints(left)}] vs [${describeCodePoints(right)}]: actual ${String(actual)}, expected ${String(expected)}`,
          );
        }
      }
    }

    // Assert: an empty list; a failure names each offending pair.
    expect(violations).toEqual([]);
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

describe("compareCodePoint issue #796 unpaired surrogates", () => {
  it("issue #796 orders the research triple without a cycle", () => {
    // Arrange: the research triple (U+10000; U+D800 then U+E000; U+E000).
    const a = "\u{10000}";
    const b = "\uD800\uE000";
    const c = "\uE000";

    // Act
    const ab = compareCodePoint(a, b);
    const bc = compareCodePoint(b, c);
    const ca = compareCodePoint(c, a);

    // Assert: the three results do not form a cycle in either direction.
    const isCycle =
      (ab < 0 && bc < 0 && ca < 0) || (ab > 0 && bc > 0 && ca > 0);
    expect(isCycle).toBe(false);
  });

  it("issue #796 returns 0 only for identical strings, including unpaired surrogates", () => {
    // Arrange
    const values = [
      "\uD800",
      "\uDC00",
      "\uD800\uE000",
      "\uDC00\uD800",
      "\u{10000}",
      "\uE000",
    ];

    // Act / Assert: a zero result occurs exactly for identical strings.
    for (const left of values) {
      for (const right of values) {
        expect(compareCodePoint(left, right) === 0).toBe(left === right);
      }
    }
  });

  it("issue #796 orders a lone high surrogate and a lone low surrogate antisymmetrically", () => {
    // Arrange / Act
    const forward = compareCodePoint("\uD800", "\uDC00");
    const backward = compareCodePoint("\uDC00", "\uD800");

    // Assert
    expect(forward).not.toBe(0);
    expect(forward).toBe(-backward);
  });
});
