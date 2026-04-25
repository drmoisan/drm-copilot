import {
  afterEach,
  beforeEach,
  describe,
  expect,
  it,
  jest,
} from "@jest/globals";

import {
  activateAndGetHandler,
  appendLineMock,
  resetExtensionHarnessState,
  showQuickPickMock,
} from "./extension-test-harness";

describe("drm-copilot listMcpTools command", () => {
  beforeEach(() => {
    resetExtensionHarnessState();
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it("shows the MCP tool list in a Quick Pick and logs it to the output channel", async () => {
    const handler = activateAndGetHandler("drmCopilotExtension.listMcpTools");

    await handler();

    expect(showQuickPickMock).toHaveBeenCalledWith(
      expect.arrayContaining([
        expect.objectContaining({
          label: "collect_commit_context",
        }),
        expect.objectContaining({
          label: "collect_pr_context",
          detail: "Required inputs: base",
        }),
        expect.objectContaining({
          label: "run_poshqc_suite",
        }),
        expect.objectContaining({
          label: "validate_orchestration_artifacts",
          detail: "Required inputs: artifact_type, artifact_path",
        }),
      ]),
      expect.objectContaining({
        title: "drm-copilot: List MCP Tools",
        placeHolder: "Available tools on the drmCopilotExtension MCP server.",
      }),
    );

    const logs = appendLineMock.mock.calls.map(([line]) => String(line));
    expect(logs).toContain(
      "[drmCopilotExtension.listMcpTools] available MCP tools:",
    );
    expect(
      logs.some(
        (line) => line.includes("collect_pr_context") && line.includes("base"),
      ),
    ).toBe(true);
  });
});
