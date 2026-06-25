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
  showQuickPickMock,
} from "./extension-test-harness";

interface PackQuickPickItem {
  readonly label: string;
  readonly pack: string;
  readonly picked: boolean;
}

/**
 * Configure the shared showQuickPick mock to answer the push-down command's
 * three prompts in order: the multi-select pack QuickPick, the optional C#
 * variant prompt, and the memory-mode prompt. Passing `undefined` for any step
 * simulates cancellation at that step. The C# variant answer is consumed only
 * when the selected packs include C#.
 */
function queuePushDownPrompts(input: {
  readonly packs: ReadonlyArray<string> | undefined;
  readonly csharpVariant?: string | undefined;
  readonly memoryMode?: string | undefined;
}): void {
  const responses: unknown[] = [];
  // Multi-select returns an array of picked items; undefined is cancellation.
  if (input.packs === undefined) {
    responses.push(undefined);
  } else {
    responses.push(
      input.packs.map(
        (pack): PackQuickPickItem => ({ label: pack, pack, picked: true }),
      ),
    );
    // The C# variant prompt only fires when C# was selected.
    if (input.packs.includes("csharp")) {
      responses.push(input.csharpVariant);
    }
    responses.push(input.memoryMode);
  }

  let callIndex = 0;
  showQuickPickMock.mockImplementation(async () => {
    const response = responses[callIndex];
    callIndex += 1;
    return response;
  });
}

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

  it("maps pack, C# variant, and memory selections to the spawned CLI args", async () => {
    setExecutablePresence({ python: true });
    childProcessMock.spawn.mockReturnValue(createMockProcess(0));
    queuePushDownPrompts({
      packs: ["typescript", "csharp"],
      csharpVariant: "legacy",
      memoryMode: "merge",
    });

    const handler = activateAndGetHandler(
      "drmCopilotExtension.pushDownClaudeCustomizations",
    );
    await handler();

    const [executable, args, options] = childProcessMock.spawn.mock
      .calls[0] as [string, string[], { cwd: string }];
    expect(executable).toBe("python");
    expect(args).toContain("--destination");
    expect(args).toContain("C:/workspace");
    // The selected packs are joined into a single comma-separated value.
    const packsIndex = args.indexOf("--packs");
    expect(packsIndex).toBeGreaterThanOrEqual(0);
    expect(args[packsIndex + 1]).toBe("typescript,csharp");
    const variantIndex = args.indexOf("--csharp-variant");
    expect(variantIndex).toBeGreaterThanOrEqual(0);
    expect(args[variantIndex + 1]).toBe("legacy");
    const memoryIndex = args.indexOf("--memory-mode");
    expect(memoryIndex).toBeGreaterThanOrEqual(0);
    expect(args[memoryIndex + 1]).toBe("merge");
    expect(
      args.some((a) => a.includes("push_down_claude_customizations")),
    ).toBe(true);
    expect(options.cwd).toBe("C:/workspace");
  });

  it("skips the C# variant prompt when C# is not selected", async () => {
    setExecutablePresence({ python: true });
    childProcessMock.spawn.mockReturnValue(createMockProcess(0));
    queuePushDownPrompts({
      packs: ["python", "typescript"],
      memoryMode: "overwrite",
    });

    const handler = activateAndGetHandler(
      "drmCopilotExtension.pushDownClaudeCustomizations",
    );
    await handler();

    const [, args] = childProcessMock.spawn.mock.calls[0] as [string, string[]];
    // No C# variant flag is added when C# was not among the selected packs.
    expect(args).not.toContain("--csharp-variant");
    const packsIndex = args.indexOf("--packs");
    expect(args[packsIndex + 1]).toBe("python,typescript");
    expect(args).toContain("--memory-mode");
    // Only two QuickPick prompts are shown (packs, memory) without the variant.
    expect(showQuickPickMock.mock.calls).toHaveLength(2);
  });

  it("aborts without invoking the service when the pack selection is cancelled", async () => {
    setExecutablePresence({ python: true });
    childProcessMock.spawn.mockReturnValue(createMockProcess(0));
    queuePushDownPrompts({ packs: undefined });

    const handler = activateAndGetHandler(
      "drmCopilotExtension.pushDownClaudeCustomizations",
    );
    await handler();

    expect(childProcessMock.spawn).not.toHaveBeenCalled();
  });

  it("aborts without invoking the service when the C# variant prompt is cancelled", async () => {
    setExecutablePresence({ python: true });
    childProcessMock.spawn.mockReturnValue(createMockProcess(0));
    queuePushDownPrompts({
      packs: ["csharp"],
      csharpVariant: undefined,
      memoryMode: "overwrite",
    });

    const handler = activateAndGetHandler(
      "drmCopilotExtension.pushDownClaudeCustomizations",
    );
    await handler();

    expect(childProcessMock.spawn).not.toHaveBeenCalled();
  });

  it("aborts without invoking the service when the memory-mode prompt is cancelled", async () => {
    setExecutablePresence({ python: true });
    childProcessMock.spawn.mockReturnValue(createMockProcess(0));
    queuePushDownPrompts({
      packs: ["python"],
      memoryMode: undefined,
    });

    const handler = activateAndGetHandler(
      "drmCopilotExtension.pushDownClaudeCustomizations",
    );
    await handler();

    expect(childProcessMock.spawn).not.toHaveBeenCalled();
  });
});
