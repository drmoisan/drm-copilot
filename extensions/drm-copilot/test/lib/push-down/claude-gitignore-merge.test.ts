import { describe, expect, it } from "@jest/globals";

import {
  CLAUDE_GITIGNORE_BEGIN_SENTINEL,
  CLAUDE_GITIGNORE_END_SENTINEL,
  CLAUDE_MANAGED_IGNORE_ENTRIES,
  mergeClaudeGitignore,
} from "../../../src/lib/push-down/claude-gitignore-merge";

/**
 * Unit tests for the pure destination-`.gitignore` merge introduced by issue
 * #596. The function under test performs no I/O, so these tests exercise it
 * directly and touch no filesystem.
 */
describe("mergeClaudeGitignore", () => {
  /** Counts non-overlapping occurrences of a literal within a text. */
  function countOccurrences(text: string, literal: string): number {
    return text.split(literal).length - 1;
  }

  it("appends a managed block to an absent input", () => {
    // Arrange
    const absentDestination = "";

    // Act
    const merged = mergeClaudeGitignore(absentDestination);

    // Assert
    expect(merged).toBe(
      [
        CLAUDE_GITIGNORE_BEGIN_SENTINEL,
        ...CLAUDE_MANAGED_IGNORE_ENTRIES,
        CLAUDE_GITIGNORE_END_SENTINEL,
        "",
      ].join("\n"),
    );
  });

  it("appends a managed block to input without one", () => {
    // Arrange
    const current = "node_modules/\ndist/\n";

    // Act
    const merged = mergeClaudeGitignore(current);

    // Assert
    expect(merged.startsWith("node_modules/\ndist/\n")).toBe(true);
    expect(countOccurrences(merged, CLAUDE_GITIGNORE_BEGIN_SENTINEL)).toBe(1);
    expect(countOccurrences(merged, CLAUDE_GITIGNORE_END_SENTINEL)).toBe(1);
    for (const entry of CLAUDE_MANAGED_IGNORE_ENTRIES) {
      expect(merged).toContain(entry);
    }
  });

  it("returns identical text for input that already carries an up-to-date block", () => {
    // Arrange
    const upToDate = mergeClaudeGitignore("node_modules/\n");

    // Act
    const merged = mergeClaudeGitignore(upToDate);

    // Assert
    expect(merged).toBe(upToDate);
  });

  it("replaces a stale managed block in place", () => {
    // Arrange
    const stale = [
      "node_modules/",
      "",
      CLAUDE_GITIGNORE_BEGIN_SENTINEL,
      ".claude/state/",
      CLAUDE_GITIGNORE_END_SENTINEL,
      "",
      "coverage/",
      "",
    ].join("\n");

    // Act
    const merged = mergeClaudeGitignore(stale);

    // Assert
    expect(merged).toBe(
      [
        "node_modules/",
        "",
        CLAUDE_GITIGNORE_BEGIN_SENTINEL,
        ...CLAUDE_MANAGED_IGNORE_ENTRIES,
        CLAUDE_GITIGNORE_END_SENTINEL,
        "",
        "coverage/",
        "",
      ].join("\n"),
    );
  });

  it("emits one managed block when a managed entry already appears outside it", () => {
    // Arrange
    const withUnmanagedDuplicate = [
      ".claude/state/",
      "node_modules/",
      "",
      CLAUDE_GITIGNORE_BEGIN_SENTINEL,
      CLAUDE_GITIGNORE_END_SENTINEL,
      "",
    ].join("\n");

    // Act
    const merged = mergeClaudeGitignore(withUnmanagedDuplicate);

    // Assert
    expect(countOccurrences(merged, CLAUDE_GITIGNORE_BEGIN_SENTINEL)).toBe(1);
    expect(merged.startsWith(".claude/state/\nnode_modules/\n")).toBe(true);
    for (const entry of CLAUDE_MANAGED_IGNORE_ENTRIES) {
      expect(merged).toContain(entry);
    }
    expect(countOccurrences(merged, ".claude/state/")).toBe(2);
  });

  it("appends a managed block to input with no trailing newline", () => {
    // Arrange
    const noTrailingNewline = "node_modules/";

    // Act
    const merged = mergeClaudeGitignore(noTrailingNewline);

    // Assert
    expect(merged.startsWith("node_modules/\n")).toBe(true);
    expect(merged.endsWith(`${CLAUDE_GITIGNORE_END_SENTINEL}\n`)).toBe(true);
    expect(countOccurrences(merged, CLAUDE_GITIGNORE_BEGIN_SENTINEL)).toBe(1);
  });

  it("normalizes CRLF input to LF in the merged text", () => {
    // Arrange
    const crlfInput = "node_modules/\r\ndist/\r\n";

    // Act
    const merged = mergeClaudeGitignore(crlfInput);

    // Assert
    expect(merged).not.toContain("\r");
    expect(merged.startsWith("node_modules/\ndist/\n")).toBe(true);
    expect(mergeClaudeGitignore(merged)).toBe(merged);
  });

  it("preserves content following an opening sentinel that has no closing sentinel", () => {
    // Arrange
    const unterminated = [
      "a/",
      CLAUDE_GITIGNORE_BEGIN_SENTINEL,
      ".old/",
      "b/",
      "c/",
      "",
    ].join("\n");

    // Act
    const merged = mergeClaudeGitignore(unterminated);

    // Assert
    expect(merged).toBe(
      [
        "a/",
        CLAUDE_GITIGNORE_BEGIN_SENTINEL,
        ...CLAUDE_MANAGED_IGNORE_ENTRIES,
        CLAUDE_GITIGNORE_END_SENTINEL,
        ".old/",
        "b/",
        "c/",
        "",
      ].join("\n"),
    );
    expect(countOccurrences(merged, CLAUDE_GITIGNORE_BEGIN_SENTINEL)).toBe(1);
    expect(countOccurrences(merged, CLAUDE_GITIGNORE_END_SENTINEL)).toBe(1);
    expect(mergeClaudeGitignore(merged)).toBe(merged);
  });
});
