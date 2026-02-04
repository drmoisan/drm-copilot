import { describe, expect, it, jest } from "@jest/globals";

jest.mock(
  "vscode",
  () => ({
    window: {
      showErrorMessage: jest.fn(),
    },
  }),
  { virtual: true },
);

import { dispatchUtility } from "../../src/utilities/utility-dispatcher.ts";

describe("utility-dispatcher", () => {
  it("returns error when tool preflight fails", async () => {
    // This test expects dispatchUtility to handle missing tools gracefully
    // by showing an error message and returning an error result
    const result = await dispatchUtility("drm-copilot.gitCollectPRContext", {
      workspaceRoot: "/test/workspace",
      extensionRoot: "/test/extension",
      inputValues: { PRBaseBranch: "main" },
    });

    expect(result).toBeDefined();
    expect(result.success).toBe(false);
  });
});
