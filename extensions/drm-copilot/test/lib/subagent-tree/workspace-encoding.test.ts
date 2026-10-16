import { describe, expect, it } from "@jest/globals";
import * as path from "node:path";
import {
  encodeWorkspacePath,
  matchEncodedDirectories,
} from "../../../src/lib/subagent-tree/workspace-encoding";

const UPPER_DRIVE = "C";
const PARENT_SEGMENTS = ["Users", "fixtureuser", "repos"];
const REPO = "drm-copilot";
const OTHER_REPO = "some-other-repo";
const BACKSLASH = path.win32.sep;
const SLASH = path.posix.sep;

// Absolute workspace path assembled at runtime from neutral segments.
function workspacePathOf(separator: string, ...segments: string[]): string {
  return `${UPPER_DRIVE}:${separator}${[...PARENT_SEGMENTS, ...segments].join(separator)}`;
}

// Expected encoded directory name, derived without calling the code under test.
function encodedNameOf(...segments: string[]): string {
  return `${UPPER_DRIVE}--${[...PARENT_SEGMENTS, ...segments].join("-")}`;
}

describe("encodeWorkspacePath", () => {
  it("replaces backslashes, forward slashes, and colons with hyphens", () => {
    // Arrange
    const workspacePath = workspacePathOf(BACKSLASH, REPO);

    // Act
    const encoded = encodeWorkspacePath(workspacePath);

    // Assert
    expect(encoded).toBe(encodedNameOf(REPO));
  });

  it("encodes a forward-slash workspace path identically to a backslash one", () => {
    // Arrange
    const backslashPath = workspacePathOf(BACKSLASH, REPO);
    const forwardSlashPath = workspacePathOf(SLASH, REPO);

    // Act
    const encodedBackslash = encodeWorkspacePath(backslashPath);
    const encodedForwardSlash = encodeWorkspacePath(forwardSlashPath);

    // Assert
    expect(encodedForwardSlash).toBe(encodedBackslash);
  });
});

describe("matchEncodedDirectories", () => {
  it("matches an on-disk directory whose drive-letter segment uses a lowercase letter against an uppercase-encoded workspace name", () => {
    // Arrange: on-disk directory uses a lowercase drive-letter segment, while
    // the workspace path (and its encoded form) uses an uppercase drive letter.
    const encodedWorkspaceName = encodeWorkspacePath(
      workspacePathOf(BACKSLASH, REPO),
    );
    const lowercaseDirectory = encodedNameOf(REPO).toLowerCase();
    const directoryNames = [lowercaseDirectory, encodedNameOf(OTHER_REPO)];

    // Act
    const matches = matchEncodedDirectories(
      directoryNames,
      encodedWorkspaceName,
    );

    // Assert: only the lowercase-drive-letter directory matches.
    expect(matches).toEqual([lowercaseDirectory]);
  });

  it("includes a per-worktree sibling folder among the matched candidate directories", () => {
    // Arrange
    const encodedWorkspaceName = encodeWorkspacePath(
      workspacePathOf(BACKSLASH, REPO),
    );
    const baseDirectory = encodedNameOf(REPO);
    const siblingDirectory = encodedNameOf(`${REPO}-wt-2026-06-13-11-51`);
    const directoryNames = [
      baseDirectory,
      siblingDirectory,
      encodedNameOf(`${REPO}-unrelated-suffix`),
      encodedNameOf(OTHER_REPO),
    ];

    // Act
    const matches = matchEncodedDirectories(
      directoryNames,
      encodedWorkspaceName,
    );

    // Assert: the base directory and the `-wt-` sibling both match; a
    // directory that merely shares a prefix without the `-wt-` separator
    // does not.
    expect(matches).toEqual([baseDirectory, siblingDirectory]);
  });

  it("includes a nested worktree-of-a-worktree sibling folder", () => {
    // Arrange: confirms the `-wt-<suffix>` segment may itself be appended
    // onto an already `-wt-`-suffixed base, per the confirmed encoding rule.
    const encodedWorkspaceName = encodeWorkspacePath(
      workspacePathOf(BACKSLASH, `${REPO}-wt-2026-07-03-16-18`),
    );
    const directoryNames = [
      encodedNameOf(`${REPO}-wt-2026-07-03-16-18`),
      encodedNameOf(`${REPO}-wt-2026-07-03-16-18-wt-2026-07-03-22-30`),
    ];

    // Act
    const matches = matchEncodedDirectories(
      directoryNames,
      encodedWorkspaceName,
    );

    // Assert
    expect(matches).toEqual(directoryNames);
  });

  it("returns an empty array when no directory name matches", () => {
    // Arrange
    const encodedWorkspaceName = encodeWorkspacePath(
      workspacePathOf(BACKSLASH, REPO),
    );
    const directoryNames = [encodedNameOf(OTHER_REPO)];

    // Act
    const matches = matchEncodedDirectories(
      directoryNames,
      encodedWorkspaceName,
    );

    // Assert
    expect(matches).toEqual([]);
  });

  it("matches a new-scheme nested worktree sibling encoded name", () => {
    // Arrange: under the nested scheme the on-disk worktree is
    // <workspace parent>/drm-copilot-wt/<timestamp>; encoding the
    // separator between `drm-copilot-wt` and the timestamp to `-` yields the
    // same `-wt-` infix the flat scheme produced, so the prefix match still
    // resolves it with no logic change.
    const encodedWorkspaceName = encodeWorkspacePath(
      workspacePathOf(BACKSLASH, REPO),
    );
    const baseDirectory = encodedNameOf(REPO);
    const nestedDirectory = encodedNameOf(`${REPO}-wt-2026-07-07T12-00`);
    const directoryNames = [baseDirectory, nestedDirectory];

    // Act
    const matches = matchEncodedDirectories(
      directoryNames,
      encodedWorkspaceName,
    );

    // Assert
    expect(matches).toEqual([baseDirectory, nestedDirectory]);
  });

  it("matches a new-scheme worktree-of-a-worktree encoded name", () => {
    // Arrange: the workspace root is itself a nested-scheme leaf; a worktree of
    // that worktree appends another `-wt/<timestamp>` segment, which encodes to
    // a further `-wt-<timestamp>` suffix on the already `-wt-`-suffixed base.
    const encodedWorkspaceName = encodeWorkspacePath(
      workspacePathOf(SLASH, `${REPO}-wt`, "2026-07-07T12-00"),
    );
    const directoryNames = [
      encodedNameOf(`${REPO}-wt-2026-07-07T12-00`),
      encodedNameOf(`${REPO}-wt-2026-07-07T12-00-wt-2026-07-07T18-00`),
    ];

    // Act
    const matches = matchEncodedDirectories(
      directoryNames,
      encodedWorkspaceName,
    );

    // Assert
    expect(matches).toEqual(directoryNames);
  });

  it("matches by exact equality when the workspace root is the nested leaf", () => {
    // Arrange: encoding the nested-leaf workspace root produces a name that is
    // matched by the equality branch (no `-wt-` sibling suffix required).
    const encodedWorkspaceName = encodeWorkspacePath(
      workspacePathOf(SLASH, `${REPO}-wt`, "2026-07-07T12-00"),
    );
    const leafDirectory = encodedNameOf(`${REPO}-wt-2026-07-07T12-00`);
    const directoryNames = [leafDirectory, encodedNameOf(OTHER_REPO)];

    // Act
    const matches = matchEncodedDirectories(
      directoryNames,
      encodedWorkspaceName,
    );

    // Assert
    expect(matches).toEqual([leafDirectory]);
  });
});
