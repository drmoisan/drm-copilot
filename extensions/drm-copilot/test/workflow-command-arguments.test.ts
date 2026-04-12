import { describe, expect, it } from "@jest/globals";

import {
  normalizeWorkspaceDestinationPath,
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
    ).toThrow("asset must be one of: template, agents.");
  });
});

describe("policy-audit helper validation", () => {
  it.each(["template", "agents"] as const)(
    "accepts the supported selector %s",
    (asset) => {
      expect(validatePolicyAuditTemplateAssetSelector(asset, "asset")).toBe(
        asset,
      );
    },
  );

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
