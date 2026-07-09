import { describe, expect, it } from "@jest/globals";
import {
  buildRootSessionPickEntries,
  formatLastActivityTimestamp,
  MAX_PATH_LABEL_LENGTH,
  truncateLeftAnchored,
} from "../../../src/lib/subagent-tree/quick-pick-labels";

describe("truncateLeftAnchored", () => {
  it("returns the value unchanged when shorter than the maximum", () => {
    // Arrange
    const value = "short/path";
    // Act
    const result = truncateLeftAnchored(value, 60);
    // Assert
    expect(result).toBe("short/path");
  });

  it("returns the value unchanged when exactly the maximum length", () => {
    // Arrange
    const value = "abcde";
    // Act
    const result = truncateLeftAnchored(value, 5);
    // Assert
    expect(result).toBe("abcde");
    expect(result).toHaveLength(5);
  });

  it("left-truncates with an ellipsis when longer than the maximum, preserving the tail", () => {
    // Arrange: a 16-character value truncated to 10.
    const value = "0123456789abcdef";
    const maxLength = 10;
    // Act
    const result = truncateLeftAnchored(value, maxLength);
    // Assert: total length equals maxLength; ellipsis-prefixed; tail chars
    // equal the real value tail.
    expect(result).toHaveLength(maxLength);
    expect(result.startsWith("…")).toBe(true);
    expect(result).toBe("…789abcdef");
    expect(result.slice(1)).toBe(value.slice(value.length - (maxLength - 1)));
    expect(value.endsWith(result.slice(1))).toBe(true);
  });

  it("degenerates to a single ellipsis glyph for a maxLength of 1", () => {
    // Act
    const result = truncateLeftAnchored("abc", 1);
    // Assert
    expect(result).toBe("…");
  });

  it("degenerates to a single ellipsis glyph for a maxLength of 0", () => {
    // Act
    const result = truncateLeftAnchored("abc", 0);
    // Assert
    expect(result).toBe("…");
  });

  it("returns an empty string unchanged", () => {
    // Act
    const result = truncateLeftAnchored("", 10);
    // Assert
    expect(result).toBe("");
  });

  it("exposes the module label-length constant", () => {
    // Assert: guards the documented default used by host wiring.
    expect(MAX_PATH_LABEL_LENGTH).toBe(60);
  });
});

describe("formatLastActivityTimestamp", () => {
  it("renders a known epoch as an exact yyyy-MM-dd HH:mm UTC string", () => {
    // Arrange: 2021-01-01 12:00:00 UTC.
    const epochMs = 1609502400000;
    // Act
    const result = formatLastActivityTimestamp(epochMs);
    // Assert
    expect(result).toBe("2021-01-01 12:00");
  });

  it("renders undefined as the literal 'unknown'", () => {
    // Act
    const result = formatLastActivityTimestamp(undefined);
    // Assert
    expect(result).toBe("unknown");
  });

  it("renders the epoch 0 boundary as 1970-01-01 00:00", () => {
    // Act
    const result = formatLastActivityTimestamp(0);
    // Assert
    expect(result).toBe("1970-01-01 00:00");
  });
});

describe("buildRootSessionPickEntries", () => {
  it("orders entries most-recent-first", () => {
    // Arrange
    const candidates = [
      { path: "/a.jsonl", lastActivityMs: 1000 },
      { path: "/b.jsonl", lastActivityMs: 3000 },
      { path: "/c.jsonl", lastActivityMs: 2000 },
    ];
    // Act
    const entries = buildRootSessionPickEntries(candidates, 60);
    // Assert
    expect(entries.map((entry) => entry.path)).toEqual([
      "/b.jsonl",
      "/c.jsonl",
      "/a.jsonl",
    ]);
  });

  it("sorts candidates with an undefined mtime last", () => {
    // Arrange
    const candidates = [
      { path: "/unreadable.jsonl", lastActivityMs: undefined },
      { path: "/readable.jsonl", lastActivityMs: 5000 },
    ];
    // Act
    const entries = buildRootSessionPickEntries(candidates, 60);
    // Assert
    expect(entries.map((entry) => entry.path)).toEqual([
      "/readable.jsonl",
      "/unreadable.jsonl",
    ]);
    expect(entries[1]?.label.startsWith("unknown")).toBe(true);
  });

  it("breaks equal-timestamp ties by path ascending", () => {
    // Arrange: identical timestamps, so the path is the deterministic tiebreak.
    const candidates = [
      { path: "/zzz.jsonl", lastActivityMs: 1000 },
      { path: "/aaa.jsonl", lastActivityMs: 1000 },
      { path: "/mmm.jsonl", lastActivityMs: 1000 },
    ];
    // Act
    const entries = buildRootSessionPickEntries(candidates, 60);
    // Assert
    expect(entries.map((entry) => entry.path)).toEqual([
      "/aaa.jsonl",
      "/mmm.jsonl",
      "/zzz.jsonl",
    ]);
  });

  it("breaks ties between two unreadable-mtime candidates by path ascending", () => {
    // Arrange: both undefined so they tie and fall back to path ordering.
    const candidates = [
      { path: "/y.jsonl", lastActivityMs: undefined },
      { path: "/x.jsonl", lastActivityMs: undefined },
    ];
    // Act
    const entries = buildRootSessionPickEntries(candidates, 60);
    // Assert
    expect(entries.map((entry) => entry.path)).toEqual([
      "/x.jsonl",
      "/y.jsonl",
    ]);
  });

  it("composes the label with the timestamp first, then the truncated tail", () => {
    // Arrange: a path longer than the small maxPathLength so it is truncated.
    const longPath = "/claude-root/projects/encoded-dir/session-abcdef.jsonl";
    const candidates = [{ path: longPath, lastActivityMs: 1609502400000 }];
    // Act
    const [entry] = buildRootSessionPickEntries(candidates, 20);
    // Assert: label = "<timestamp>  <truncated>"; two-space separator.
    expect(entry?.label).toBe(
      `2021-01-01 12:00  ${truncateLeftAnchored(longPath, 20)}`,
    );
  });

  it("sets detail equal to the full absolute path even when the label is truncated", () => {
    // Arrange
    const longPath = "/claude-root/projects/encoded-dir/session-abcdef.jsonl";
    const candidates = [{ path: longPath, lastActivityMs: 1000 }];
    // Act
    const [entry] = buildRootSessionPickEntries(candidates, 20);
    // Assert
    expect(entry?.detail).toBe(longPath);
    expect(entry?.path).toBe(longPath);
  });

  it("returns an empty array for an empty candidate list", () => {
    // Act
    const entries = buildRootSessionPickEntries([], 60);
    // Assert
    expect(entries).toEqual([]);
  });

  it("does not mutate the input candidate array", () => {
    // Arrange
    const candidates = [
      { path: "/a.jsonl", lastActivityMs: 1000 },
      { path: "/b.jsonl", lastActivityMs: 3000 },
    ];
    const originalOrder = candidates.map((candidate) => candidate.path);
    // Act
    buildRootSessionPickEntries(candidates, 60);
    // Assert
    expect(candidates.map((candidate) => candidate.path)).toEqual(
      originalOrder,
    );
  });
});
