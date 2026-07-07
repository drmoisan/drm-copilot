import { describe, expect, it } from "@jest/globals";
import {
  encodeWorkspacePath,
  matchEncodedDirectories,
} from "../../../src/lib/subagent-tree/workspace-encoding";

describe("encodeWorkspacePath", () => {
  it("replaces backslashes, forward slashes, and colons with hyphens", () => {
    // Arrange
    const workspacePath = "C:\\Users\\DanMoisan\\repos\\drm-copilot";

    // Act
    const encoded = encodeWorkspacePath(workspacePath);

    // Assert
    expect(encoded).toBe("C--Users-DanMoisan-repos-drm-copilot");
  });

  it("encodes a forward-slash workspace path identically to a backslash one", () => {
    // Arrange
    const backslashPath = "C:\\Users\\DanMoisan\\repos\\drm-copilot";
    const forwardSlashPath = "C:/Users/DanMoisan/repos/drm-copilot";

    // Act
    const encodedBackslash = encodeWorkspacePath(backslashPath);
    const encodedForwardSlash = encodeWorkspacePath(forwardSlashPath);

    // Assert
    expect(encodedForwardSlash).toBe(encodedBackslash);
  });
});

describe("matchEncodedDirectories", () => {
  it("matches an on-disk directory whose drive-letter segment uses a lowercase letter against an uppercase-encoded workspace name", () => {
    // Arrange: on-disk directory uses a lowercase drive-letter segment
    // (`c--...`), while the workspace path (and its encoded form) uses an
    // uppercase drive letter (`C:\...` -> `C--...`).
    const encodedWorkspaceName = encodeWorkspacePath(
      "C:\\Users\\DanMoisan\\repos\\drm-copilot",
    );
    const directoryNames = [
      "c--users-danmoisan-repos-drm-copilot",
      "C--Users-DanMoisan-repos-some-other-repo",
    ];

    // Act
    const matches = matchEncodedDirectories(
      directoryNames,
      encodedWorkspaceName,
    );

    // Assert: only the lowercase-drive-letter directory matches.
    expect(matches).toEqual(["c--users-danmoisan-repos-drm-copilot"]);
  });

  it("includes a per-worktree sibling folder among the matched candidate directories", () => {
    // Arrange
    const encodedWorkspaceName = encodeWorkspacePath(
      "C:\\Users\\DanMoisan\\repos\\drm-copilot",
    );
    const directoryNames = [
      "C--Users-DanMoisan-repos-drm-copilot",
      "C--Users-DanMoisan-repos-drm-copilot-wt-2026-06-13-11-51",
      "C--Users-DanMoisan-repos-drm-copilot-unrelated-suffix",
      "C--Users-DanMoisan-repos-some-other-repo",
    ];

    // Act
    const matches = matchEncodedDirectories(
      directoryNames,
      encodedWorkspaceName,
    );

    // Assert: the base directory and the `-wt-` sibling both match; a
    // directory that merely shares a prefix without the `-wt-` separator
    // does not.
    expect(matches).toEqual([
      "C--Users-DanMoisan-repos-drm-copilot",
      "C--Users-DanMoisan-repos-drm-copilot-wt-2026-06-13-11-51",
    ]);
  });

  it("includes a nested worktree-of-a-worktree sibling folder", () => {
    // Arrange: confirms the `-wt-<suffix>` segment may itself be appended
    // onto an already `-wt-`-suffixed base, per the confirmed encoding rule.
    const encodedWorkspaceName = encodeWorkspacePath(
      "C:\\Users\\DanMoisan\\repos\\drm-copilot-wt-2026-07-03-16-18",
    );
    const directoryNames = [
      "C--Users-DanMoisan-repos-drm-copilot-wt-2026-07-03-16-18",
      "C--Users-DanMoisan-repos-drm-copilot-wt-2026-07-03-16-18-wt-2026-07-03-22-30",
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
      "C:\\Users\\DanMoisan\\repos\\drm-copilot",
    );
    const directoryNames = ["C--Users-DanMoisan-repos-some-other-repo"];

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
    // C:/Users/DanMoisan/repos/drm-copilot-wt/2026-07-07T12-00; encoding the
    // `/` between `drm-copilot-wt` and the timestamp to `-` yields the same
    // `-wt-` infix the flat scheme produced, so the prefix match still resolves
    // it with no logic change.
    const encodedWorkspaceName = encodeWorkspacePath(
      "C:\\Users\\DanMoisan\\repos\\drm-copilot",
    );
    const directoryNames = [
      "C--Users-DanMoisan-repos-drm-copilot",
      "C--Users-DanMoisan-repos-drm-copilot-wt-2026-07-07T12-00",
    ];

    // Act
    const matches = matchEncodedDirectories(
      directoryNames,
      encodedWorkspaceName,
    );

    // Assert
    expect(matches).toEqual([
      "C--Users-DanMoisan-repos-drm-copilot",
      "C--Users-DanMoisan-repos-drm-copilot-wt-2026-07-07T12-00",
    ]);
  });

  it("matches a new-scheme worktree-of-a-worktree encoded name", () => {
    // Arrange: the workspace root is itself a nested-scheme leaf; a worktree of
    // that worktree appends another `-wt/<timestamp>` segment, which encodes to
    // a further `-wt-<timestamp>` suffix on the already `-wt-`-suffixed base.
    const encodedWorkspaceName = encodeWorkspacePath(
      "C:/Users/DanMoisan/repos/drm-copilot-wt/2026-07-07T12-00",
    );
    const directoryNames = [
      "C--Users-DanMoisan-repos-drm-copilot-wt-2026-07-07T12-00",
      "C--Users-DanMoisan-repos-drm-copilot-wt-2026-07-07T12-00-wt-2026-07-07T18-00",
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
      "C:/Users/DanMoisan/repos/drm-copilot-wt/2026-07-07T12-00",
    );
    const directoryNames = [
      "C--Users-DanMoisan-repos-drm-copilot-wt-2026-07-07T12-00",
      "C--Users-DanMoisan-repos-some-other-repo",
    ];

    // Act
    const matches = matchEncodedDirectories(
      directoryNames,
      encodedWorkspaceName,
    );

    // Assert
    expect(matches).toEqual([
      "C--Users-DanMoisan-repos-drm-copilot-wt-2026-07-07T12-00",
    ]);
  });
});
