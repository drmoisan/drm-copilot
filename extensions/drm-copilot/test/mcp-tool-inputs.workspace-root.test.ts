import { describe, expect, it } from "@jest/globals";

import {
  resolveNewPotentialBugEntryToolInput,
  resolvePotentialToIssueToolInput,
} from "../src/mcp-tool-inputs";

/**
 * Defect A resolver-level coverage for the fail-closed workspace_root contract
 * and the workspace-relative potential_path normalization. These scenarios are
 * kept in a dedicated file so the main mcp-tool-inputs suite stays under the
 * 500-line production/test file limit.
 */
describe("resolveNewPotentialBugEntryToolInput — fail-closed workspace_root (AC-4)", () => {
  it("throws an actionable error naming workspace_root when omitted with no fallback", () => {
    // Arrange / Act / Assert: no workspace_root and no explicit fallback arg
    // must fail closed rather than silently resolving to process.cwd().
    expect(() =>
      resolveNewPotentialBugEntryToolInput({ short_name: "fix-crash" }),
    ).toThrow(/workspace_root/);
  });

  it("returns the explicit fallback workspace root when workspace_root is omitted", () => {
    // The VS Code command surface passes an explicit fallback; that path is
    // preserved unchanged.
    expect(
      resolveNewPotentialBugEntryToolInput(
        { short_name: "fix-crash" },
        "D:/fallback-workspace",
      ),
    ).toEqual({
      workspaceRoot: "D:/fallback-workspace",
      shortName: "fix-crash",
    });
  });
});

describe("resolvePotentialToIssueToolInput — workspace-relative potential_path (AC-6)", () => {
  it("resolves a workspace-relative potential_path against workspace_root", () => {
    expect(
      resolvePotentialToIssueToolInput({
        workspace_root: "C:/ws",
        potential_path: "docs/potential/entry.md",
        promotion_type: "feature",
        work_mode: "full-feature",
      }).potentialPath,
    ).toBe("C:/ws/docs/potential/entry.md");
  });

  it("preserves an absolute potential_path unchanged", () => {
    expect(
      resolvePotentialToIssueToolInput({
        workspace_root: "C:/ws",
        potential_path: "D:/exports/entry.md",
        promotion_type: "feature",
        work_mode: "full-feature",
      }).potentialPath,
    ).toBe("D:/exports/entry.md");
  });
});
