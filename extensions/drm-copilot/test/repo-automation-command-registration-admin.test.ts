import { afterEach, describe, expect, it, jest } from "@jest/globals";

/**
 * Unit test for the output-channel logging seam of the Push Down Claude
 * Customizations command (AC5 of issue #256). When the push-down service throws,
 * the failure must be written to the command output channel before being
 * re-thrown so the modal still surfaces.
 *
 * The VS Code host is mocked; the command handler is captured at registration
 * time and invoked directly.
 */

const showQuickPickMock = jest.fn();
const registerCommandMock = jest.fn();

jest.mock(
  "vscode",
  () => ({
    window: {
      showQuickPick: showQuickPickMock,
    },
    commands: {
      registerCommand: registerCommandMock,
    },
    workspace: {
      workspaceFolders: [{ uri: { fsPath: "/fake/workspace" } }],
    },
  }),
  { virtual: true },
);

import { registerRepoAutomationAdminCommands } from "../src/repo-automation-command-registration-admin";
import type { RepoAutomationCommandRegistrationOptions } from "../src/repo-automation-command-registration-types";

interface CapturedHandler {
  readonly commandId: string;
  readonly handler: (...args: unknown[]) => unknown;
}

function captureHandlers(): CapturedHandler[] {
  const captured: CapturedHandler[] = [];
  registerCommandMock.mockImplementation((...args: unknown[]) => {
    const commandId = args[0] as string;
    const handler = args[1] as (...handlerArgs: unknown[]) => unknown;
    captured.push({ commandId, handler });
    return { dispose: jest.fn() };
  });
  return captured;
}

function findHandler(
  captured: CapturedHandler[],
  commandId: string,
): (...args: unknown[]) => unknown {
  const match = captured.find((entry) => entry.commandId === commandId);
  if (match === undefined) {
    throw new Error(`Handler for ${commandId} was not registered.`);
  }
  return match.handler;
}

describe("registerPushDownClaudeCustomizationsCommand output logging", () => {
  afterEach(() => {
    jest.resetAllMocks();
  });

  it("AC5: writes the service failure to the output channel before re-throwing", async () => {
    // Arrange
    const captured = captureHandlers();
    const appendLineMock = jest.fn();
    const failure = new Error("Pack manifest is missing");
    const pushDownMock = jest.fn(() => Promise.reject(failure));

    const options = {
      context: {} as unknown,
      output: { appendLine: appendLineMock },
      service: { pushDownClaudeCustomizations: pushDownMock },
    } as unknown as RepoAutomationCommandRegistrationOptions;

    registerRepoAutomationAdminCommands(options);
    const handler = findHandler(
      captured,
      "drmCopilotExtension.pushDownClaudeCustomizations",
    );

    // Pack multi-select returns C# selected; then variant; then memory mode.
    showQuickPickMock
      .mockResolvedValueOnce([{ label: "C#", pack: "csharp", picked: true }])
      .mockResolvedValueOnce("modern")
      .mockResolvedValueOnce("overwrite");

    // Act / Assert
    await expect(handler()).rejects.toBe(failure);
    expect(appendLineMock).toHaveBeenCalledWith(
      "[drmCopilotExtension.pushDownClaudeCustomizations] push-down failure: Pack manifest is missing",
    );
  });
});
