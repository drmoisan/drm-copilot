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
  childProcessMock,
  createMockProcess,
  resetExtensionHarnessState,
  setExecutablePresence,
} from "./extension-test-harness";

describe("drm-copilot pushDownClaudeCustomizations command", () => {
  beforeEach(() => {
    resetExtensionHarnessState();
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it("registers the command 'drmCopilotExtension.pushDownClaudeCustomizations' when activate() runs", () => {
    // activateAndGetHandler throws if the command is not registered.
    activateAndGetHandler("drmCopilotExtension.pushDownClaudeCustomizations");
  });

  it("invokes service.pushDownClaudeCustomizations with workspaceRoot and the canonical invocationId", async () => {
    setExecutablePresence({ python: true });
    childProcessMock.spawn.mockReturnValue(createMockProcess(0));

    const handler = activateAndGetHandler(
      "drmCopilotExtension.pushDownClaudeCustomizations",
    );
    await handler();

    const [executable, args, options] = childProcessMock.spawn.mock
      .calls[0] as [string, string[], { cwd: string }];
    expect(executable).toBe("python");
    expect(args).toContain("--destination");
    expect(args).toContain("C:/workspace");
    // Verify the bundled script is the Claude customizations one.
    expect(
      args.some((a) => a.includes("push_down_claude_customizations")),
    ).toBe(true);
    expect(options.cwd).toBe("C:/workspace");
  });
});
