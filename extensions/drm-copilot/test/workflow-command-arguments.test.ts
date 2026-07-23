import { describe, expect, it } from "@jest/globals";

import {
  normalizeWorkspaceDestinationPath,
  normalizeWorkspaceRoot,
  resolveLinkParentChildInvocation,
  resolvePolicyAuditTemplateAssetInvocation,
  resolveRunPoshQCAnalyzeAutofixInvocation,
  resolveRunPoshQCAnalyzeInvocation,
  resolveRunPoshQCFormatInvocation,
  resolveRunPoshQCSuiteInvocation,
  resolveRunPoshQCTestInvocation,
  validatePolicyAuditTemplateAssetSelector,
} from "../src/workflow-command-arguments";

const commandResolvers = [
  resolveRunPoshQCFormatInvocation,
  resolveRunPoshQCAnalyzeInvocation,
  resolveRunPoshQCTestInvocation,
  resolveRunPoshQCAnalyzeAutofixInvocation,
  resolveRunPoshQCSuiteInvocation,
] as const;

describe("PoshQC workflow command arguments", () => {
  it.each(commandResolvers)(
    "returns interactive mode when no args are supplied",
    (resolver) => {
      expect(resolver([])).toEqual({ mode: "interactive" });
    },
  );

  it.each(commandResolvers)(
    "parses repeated --scan-folder flags",
    (resolver) => {
      expect(
        resolver(["--scan-folder", "src", "--scan-folder", "tests/powershell"]),
      ).toEqual({
        mode: "direct",
        input: {
          scanFolders: ["src", "tests/powershell"],
        },
      });
    },
  );

  it.each(commandResolvers)("rejects unknown flags", (resolver) => {
    expect(() => resolver(["--bogus", "value"])).toThrow(/unknown flag/i);
  });

  it.each(commandResolvers)("rejects missing flag values", (resolver) => {
    expect(() => resolver(["--scan-folder"])).toThrow(/requires a value/i);
  });
});

describe("resolvePolicyAuditTemplateAssetInvocation", () => {
  it("parses -asset without -target", () => {
    expect(
      resolvePolicyAuditTemplateAssetInvocation(["-asset", "template"]),
    ).toEqual({
      mode: "direct",
      input: {
        asset: "template",
      },
    });
  });

  it("returns interactive mode when no args are supplied", () => {
    expect(resolvePolicyAuditTemplateAssetInvocation([])).toEqual({
      mode: "interactive",
    });
  });

  it("parses -asset and optional -target flags", () => {
    expect(
      resolvePolicyAuditTemplateAssetInvocation([
        "-asset",
        "agents",
        "-target",
        "docs/policy-audit/AGENTS.md",
      ]),
    ).toEqual({
      mode: "direct",
      input: {
        asset: "agents",
        targetPath: "docs/policy-audit/AGENTS.md",
      },
    });
  });

  it("rejects unknown flags", () => {
    expect(() =>
      resolvePolicyAuditTemplateAssetInvocation(["-bogus", "value"]),
    ).toThrow(/unknown flag/i);
  });

  it("rejects duplicate flags", () => {
    expect(() =>
      resolvePolicyAuditTemplateAssetInvocation([
        "-asset",
        "template",
        "-asset",
        "agents",
      ]),
    ).toThrow(/duplicate flag/i);
  });

  it("rejects unsupported asset selectors", () => {
    expect(() =>
      resolvePolicyAuditTemplateAssetInvocation(["-asset", "invalid"]),
    ).toThrow(
      "asset must be one of: template, agents, code-review-template, feature-audit-template.",
    );
  });
});

describe("resolveLinkParentChildInvocation", () => {
  it("returns interactive mode when no args are supplied", () => {
    expect(resolveLinkParentChildInvocation([])).toEqual({
      mode: "interactive",
    });
  });

  it("parses direct child and parent issue flags", () => {
    expect(
      resolveLinkParentChildInvocation([
        "-ChildIssueNumber",
        "12",
        "-ParentIssueNumber",
        "34",
      ]),
    ).toEqual({
      mode: "direct",
      input: {
        childIssueNumber: "12",
        parentIssueNumber: "34",
      },
    });
  });

  it("rejects non-digit issue numbers", () => {
    expect(() =>
      resolveLinkParentChildInvocation([
        "-ChildIssueNumber",
        "child-12",
        "-ParentIssueNumber",
        "34",
      ]),
    ).toThrow("-ChildIssueNumber must be digits only.");
  });

  it("rejects missing required flags", () => {
    expect(() =>
      resolveLinkParentChildInvocation(["-ChildIssueNumber", "12"]),
    ).toThrow("Missing required flag '-ParentIssueNumber'.");
  });
});

describe("policy-audit helper validation", () => {
  it.each([
    "template",
    "agents",
    "code-review-template",
    "feature-audit-template",
  ] as const)("accepts the supported selector %s", (asset) => {
    expect(validatePolicyAuditTemplateAssetSelector(asset, "asset")).toBe(
      asset,
    );
  });

  it("normalizes a workspace-relative destination path", () => {
    expect(
      normalizeWorkspaceDestinationPath(
        "docs/policy-audit/AGENTS.md",
        "C:/workspace",
        "target_path",
      ),
    ).toBe("C:/workspace/docs/policy-audit/AGENTS.md");
  });

  it("preserves an absolute destination path", () => {
    expect(
      normalizeWorkspaceDestinationPath(
        "D:/exports/policy-audit.md",
        "C:/workspace",
        "target_path",
      ),
    ).toBe("D:/exports/policy-audit.md");
  });
});

describe("normalizeWorkspaceRoot (AC-4 fail-closed)", () => {
  // Omitted value with no explicit fallback must fail closed rather than
  // silently defaulting to the MCP server's process.cwd().
  it("throws an actionable error when the value is omitted and no fallback is supplied", () => {
    expect(() => normalizeWorkspaceRoot(undefined)).toThrow(
      /workspace_root is required/,
    );
  });

  // The VS Code command surface passes an explicit fallback; that path must be
  // preserved unchanged.
  it("returns the explicit fallback when the value is omitted", () => {
    expect(normalizeWorkspaceRoot(undefined, "C:/workspace")).toBe(
      "C:/workspace",
    );
  });

  it("normalizes a valid string value unchanged", () => {
    expect(normalizeWorkspaceRoot("C:/worktree")).toBe("C:/worktree");
  });

  it("preserves the existing invalid-type error", () => {
    expect(() => normalizeWorkspaceRoot(42)).toThrow();
  });

  it("rejects an empty-string workspace_root", () => {
    expect(() => normalizeWorkspaceRoot("")).toThrow();
  });

  it("rejects a whitespace-only workspace_root", () => {
    expect(() => normalizeWorkspaceRoot("   ")).toThrow();
  });
});
