import { describe, expect, it } from "@jest/globals";

import { resolveMigrateDevelopmentDocsToolInput } from "../src/mcp-tool-inputs-development-docs";

describe("resolveMigrateDevelopmentDocsToolInput", () => {
  it("resolves the required fields and omits absent optional fields", () => {
    expect(
      resolveMigrateDevelopmentDocsToolInput({
        workspace_root: "/work",
        mode: "dry-run",
      }),
    ).toEqual({
      workspaceRoot: "/work",
      mode: "dry-run",
    });
  });

  it("carries each optional field through", () => {
    expect(
      resolveMigrateDevelopmentDocsToolInput({
        workspace_root: "/work",
        mode: "apply",
        rename_decisions_path: "d.json",
        report_directory: "reports",
      }),
    ).toEqual({
      workspaceRoot: "/work",
      mode: "apply",
      renameDecisionsPath: "d.json",
      reportDirectory: "reports",
    });
  });

  it.each([
    ["missing", { mode: "dry-run" }, "workspace_root is required"],
    ["blank", { workspace_root: "   ", mode: "dry-run" }, "workspace_root"],
  ])("rejects a %s workspace_root", (_label, input, message) => {
    expect(() => resolveMigrateDevelopmentDocsToolInput(input)).toThrow(
      message,
    );
  });

  it.each([undefined, "plan", 3])("rejects the invalid mode %p", (mode) => {
    expect(() =>
      resolveMigrateDevelopmentDocsToolInput({ workspace_root: "/work", mode }),
    ).toThrow('mode is required and must be "dry-run" or "apply".');
  });

  it.each(["rename_decisions_path", "report_directory"])(
    "rejects a non-string %s",
    (key) => {
      expect(() =>
        resolveMigrateDevelopmentDocsToolInput({
          workspace_root: "/work",
          mode: "dry-run",
          [key]: 5,
        }),
      ).toThrow(`${key} must be a string.`);
    },
  );

  it("rejects unknown keys and non-object input", () => {
    expect(() =>
      resolveMigrateDevelopmentDocsToolInput({
        workspace_root: "/work",
        mode: "dry-run",
        zeta: 1,
        alpha: 2,
      }),
    ).toThrow("Unexpected input properties: alpha, zeta.");
    expect(() => resolveMigrateDevelopmentDocsToolInput("x")).toThrow(
      "Tool arguments must be an object.",
    );
  });
});
