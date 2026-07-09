import { describe, expect, it, jest } from "@jest/globals";
import { resolveSessionTranscriptPath } from "../../../src/lib/subagent-tree/session-transcript-resolver";
import { InMemoryFileSystem } from "./in-memory-file-system";

/** Absolute workspace root (mirrors a real Windows cwd). */
const WORKSPACE_ROOT = "C:\\Users\\Dan\\repos\\drm-copilot";
/** Fake resolved user-global Claude projects directory. */
const PROJECTS_ROOT = "/claude-root/projects";
/** Encoded directory name for WORKSPACE_ROOT (`:` and separators -> `-`). */
const EXACT_DIR = "C--Users-Dan-repos-drm-copilot";
/** A `-wt-` worktree sibling directory of EXACT_DIR. */
const SIBLING_DIR = "C--Users-Dan-repos-drm-copilot-wt-2026-07-09T09-18";
/** A representative valid (UUIDv4-shaped) session id. */
const VALID_ID = "ef8e8029-7c73-4346-80c7-5b0ad94b33fe";

describe("resolveSessionTranscriptPath — validation", () => {
  const malformedIds: ReadonlyArray<{ label: string; id: string }> = [
    { label: "forward-slash separator", id: "aaaa/bbbb" },
    { label: "backslash separator", id: "aaaa\\bbbb" },
    { label: "dot-dot traversal", id: "..aaaaaa" },
    { label: "empty string", id: "" },
    { label: "over-length (65 chars)", id: "a".repeat(65) },
    { label: "under-length (7 chars)", id: "abc1234" },
    { label: "out-of-charset underscore", id: "abcd_efg1" },
  ];

  it.each(malformedIds)(
    "rejects a malformed session id ($label) naming the rule and never touches the filesystem",
    ({ id }) => {
      // Arrange: spy on the only filesystem methods the resolver could call.
      const fileSystem = new InMemoryFileSystem();
      const listSpy = jest.spyOn(fileSystem, "listDirectory");
      const isFileSpy = jest.spyOn(fileSystem, "isFile");

      // Act + Assert: the call throws before any filesystem access.
      expect(() =>
        resolveSessionTranscriptPath(
          id,
          WORKSPACE_ROOT,
          PROJECTS_ROOT,
          fileSystem,
        ),
      ).toThrow(/must match \^\[0-9A-Za-z-\]\{8,64\}\$/);
      expect(listSpy).not.toHaveBeenCalled();
      expect(isFileSpy).not.toHaveBeenCalled();
    },
  );
});

describe("resolveSessionTranscriptPath — resolution", () => {
  it("resolves the transcript in the exact-match encoded directory", () => {
    // Arrange
    const fileSystem = new InMemoryFileSystem();
    const expected = `${PROJECTS_ROOT}/${EXACT_DIR}/${VALID_ID}.jsonl`;
    fileSystem.addFile(expected, "");

    // Act
    const result = resolveSessionTranscriptPath(
      VALID_ID,
      WORKSPACE_ROOT,
      PROJECTS_ROOT,
      fileSystem,
    );

    // Assert
    expect(result).toBe(expected);
  });

  it("resolves the transcript in a -wt- worktree sibling directory", () => {
    // Arrange: only the sibling holds the transcript.
    const fileSystem = new InMemoryFileSystem();
    const expected = `${PROJECTS_ROOT}/${SIBLING_DIR}/${VALID_ID}.jsonl`;
    fileSystem.addFile(expected, "");

    // Act
    const result = resolveSessionTranscriptPath(
      VALID_ID,
      WORKSPACE_ROOT,
      PROJECTS_ROOT,
      fileSystem,
    );

    // Assert
    expect(result).toBe(expected);
  });

  it("matches encoded directories case-insensitively", () => {
    // Arrange: the on-disk directory uses a lowercase drive-letter segment
    // while the encoded workspace name is upper-case.
    const fileSystem = new InMemoryFileSystem();
    const lowerDir = EXACT_DIR.toLowerCase();
    const expected = `${PROJECTS_ROOT}/${lowerDir}/${VALID_ID}.jsonl`;
    fileSystem.addFile(expected, "");

    // Act
    const result = resolveSessionTranscriptPath(
      VALID_ID,
      WORKSPACE_ROOT,
      PROJECTS_ROOT,
      fileSystem,
    );

    // Assert
    expect(result).toBe(expected);
  });

  it("returns the first matching directory deterministically when several contain the transcript", () => {
    // Arrange: both the exact dir and the sibling contain the id. The exact
    // dir sorts before the sibling (prefix), so it is the deterministic first
    // hit under the sorted directory listing.
    const fileSystem = new InMemoryFileSystem();
    const exactPath = `${PROJECTS_ROOT}/${EXACT_DIR}/${VALID_ID}.jsonl`;
    const siblingPath = `${PROJECTS_ROOT}/${SIBLING_DIR}/${VALID_ID}.jsonl`;
    fileSystem.addFile(exactPath, "");
    fileSystem.addFile(siblingPath, "");

    // Act
    const result = resolveSessionTranscriptPath(
      VALID_ID,
      WORKSPACE_ROOT,
      PROJECTS_ROOT,
      fileSystem,
    );

    // Assert: the first-in-order matching directory wins.
    expect(result).toBe(exactPath);
  });

  it("throws a not-found error naming the searched directories for a valid but unknown id", () => {
    // Arrange: a matching directory exists but does not contain the id.
    const fileSystem = new InMemoryFileSystem();
    fileSystem.addFile(
      `${PROJECTS_ROOT}/${EXACT_DIR}/some-other-session.jsonl`,
      "",
    );

    // Act + Assert
    expect(() =>
      resolveSessionTranscriptPath(
        VALID_ID,
        WORKSPACE_ROOT,
        PROJECTS_ROOT,
        fileSystem,
      ),
    ).toThrow(`${PROJECTS_ROOT}/${EXACT_DIR}`);
  });
});
