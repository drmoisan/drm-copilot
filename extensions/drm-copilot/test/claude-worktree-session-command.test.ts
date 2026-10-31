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
  createTerminalMock,
  resetExtensionHarnessState,
  setExecutablePresence,
  setPreClaudeScriptPathConfig,
  showInputBoxMock,
} from "./extension-test-harness";

/** Terminal options captured from the single createTerminal call. */
interface CapturedTerminalOptions {
  readonly name: string;
  readonly cwd: string;
  readonly shellPath: string;
  readonly shellArgs: ReadonlyArray<string>;
  readonly hideFromUser?: boolean;
}

/** Shape of the mock terminal returned by the harness createTerminal mock. */
interface CapturedTerminal {
  readonly show: jest.Mock;
  readonly sendText: jest.Mock;
}

/**
 * Reads the options passed to the first createTerminal call.
 *
 * @returns The captured terminal options.
 */
function capturedTerminalOptions(): CapturedTerminalOptions {
  const [options] = createTerminalMock.mock.calls[0] as [
    CapturedTerminalOptions,
  ];
  return options;
}

/**
 * Reads the mock terminal returned by the first createTerminal call.
 *
 * @returns The captured mock terminal.
 */
function capturedTerminal(): CapturedTerminal {
  return createTerminalMock.mock.results[0]?.value as CapturedTerminal;
}

describe("newClaudeWorktreeSession", () => {
  beforeEach(() => {
    resetExtensionHarnessState();
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it("newClaudeWorktreeSession creates one hidden terminal and never calls sendText", async () => {
    // Arrange
    setExecutablePresence({ pwsh: true, powershell: false });
    setPreClaudeScriptPathConfig("");
    showInputBoxMock.mockResolvedValueOnce("Refactor the auth module.");
    const handler = activateAndGetHandler(
      "drmCopilotExtension.newClaudeWorktreeSession",
    );

    // Act
    await handler();

    // Assert
    expect(createTerminalMock).toHaveBeenCalledTimes(1);
    const options = capturedTerminalOptions();
    expect(options.hideFromUser).toBe(true);
    expect(options.shellArgs).toHaveLength(4);
    expect(options.shellArgs.slice(0, 3)).toEqual([
      "-NoLogo",
      "-NoExit",
      "-EncodedCommand",
    ]);
    const terminal = capturedTerminal();
    expect(terminal.show).toHaveBeenCalledTimes(1);
    expect(terminal.sendText).not.toHaveBeenCalled();
  });
});
