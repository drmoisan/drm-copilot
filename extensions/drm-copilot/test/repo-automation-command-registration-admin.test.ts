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
const showWarningMessageMock = jest.fn();
const registerCommandMock = jest.fn();

jest.mock(
  "vscode",
  () => ({
    window: {
      showQuickPick: showQuickPickMock,
      showWarningMessage: showWarningMessageMock,
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

describe("registerPushDownCodexAndAgentsCustomizationsCommand selections", () => {
  afterEach(() => {
    jest.resetAllMocks();
  });

  it("prompts for packs and C# variant then forwards the public selection", async () => {
    const captured = captureHandlers();
    const pushDownCodexMock = jest.fn(() => Promise.resolve());
    const options = {
      context: {} as unknown,
      output: { appendLine: jest.fn() },
      service: {
        pushDownCodexAndAgentsCustomizations: pushDownCodexMock,
      },
    } as unknown as RepoAutomationCommandRegistrationOptions;

    registerRepoAutomationAdminCommands(options);
    const handler = findHandler(
      captured,
      "drmCopilotExtension.pushDownCodexAndAgentsCustomizations",
    );
    showQuickPickMock
      .mockResolvedValueOnce([{ label: "C#", pack: "csharp", picked: true }])
      .mockResolvedValueOnce("legacy");

    await handler();

    expect(pushDownCodexMock).toHaveBeenCalledWith({
      workspaceRoot: "/fake/workspace",
      invocationId: "drmCopilotExtension.pushDownCodexAndAgentsCustomizations",
      packs: ["csharp"],
      csharpVariant: "legacy",
      memoryMode: "overwrite",
    });
  });

  it("does not prompt for a C# variant when C# is not selected", async () => {
    const captured = captureHandlers();
    const pushDownCodexMock = jest.fn(() => Promise.resolve());
    const options = {
      context: {} as unknown,
      output: { appendLine: jest.fn() },
      service: {
        pushDownCodexAndAgentsCustomizations: pushDownCodexMock,
      },
    } as unknown as RepoAutomationCommandRegistrationOptions;

    registerRepoAutomationAdminCommands(options);
    const handler = findHandler(
      captured,
      "drmCopilotExtension.pushDownCodexAndAgentsCustomizations",
    );
    showQuickPickMock.mockResolvedValueOnce([
      { label: "TypeScript", pack: "typescript", picked: true },
    ]);

    await handler();

    expect(showQuickPickMock).toHaveBeenCalledTimes(1);
    expect(pushDownCodexMock).toHaveBeenCalledWith({
      workspaceRoot: "/fake/workspace",
      invocationId: "drmCopilotExtension.pushDownCodexAndAgentsCustomizations",
      packs: ["typescript"],
      memoryMode: "overwrite",
    });
  });

  it("cancels before service invocation when a selection returns undefined", async () => {
    const captured = captureHandlers();
    const pushDownCodexMock = jest.fn(() => Promise.resolve());
    const options = {
      context: {} as unknown,
      output: { appendLine: jest.fn() },
      service: {
        pushDownCodexAndAgentsCustomizations: pushDownCodexMock,
      },
    } as unknown as RepoAutomationCommandRegistrationOptions;

    registerRepoAutomationAdminCommands(options);
    const handler = findHandler(
      captured,
      "drmCopilotExtension.pushDownCodexAndAgentsCustomizations",
    );
    showQuickPickMock.mockResolvedValueOnce(undefined);

    await handler();

    expect(pushDownCodexMock).not.toHaveBeenCalled();
  });

  it("cancels before service invocation when the C# variant selection is cancelled", async () => {
    const captured = captureHandlers();
    const pushDownCodexMock = jest.fn(() => Promise.resolve());
    const options = {
      context: {} as unknown,
      output: { appendLine: jest.fn() },
      service: {
        pushDownCodexAndAgentsCustomizations: pushDownCodexMock,
      },
    } as unknown as RepoAutomationCommandRegistrationOptions;

    registerRepoAutomationAdminCommands(options);
    const handler = findHandler(
      captured,
      "drmCopilotExtension.pushDownCodexAndAgentsCustomizations",
    );
    showQuickPickMock
      .mockResolvedValueOnce([{ label: "C#", pack: "csharp", picked: true }])
      .mockResolvedValueOnce(undefined);

    await handler();

    expect(pushDownCodexMock).not.toHaveBeenCalled();
  });
});

describe("registerPushDownClaudeCustomizationsCommand conflict notification", () => {
  afterEach(() => {
    jest.resetAllMocks();
  });

  const CONFLICT_LINE =
    "push-down exclusion conflict: destination file present, not overwritten: .claude/rules/quality-tiers.md (entry .claude/rules/quality-tiers.md, line 1)";
  const SKIPPED_LINE =
    "push-down exclusion: skipped .claude/rules/python.md (entry .claude/rules/python.md, line 2)";
  const UNMATCHED_LINE =
    "push-down exclusion: entry matched no payload path: .claude/agent-memory/** (line 3)";

  /**
   * Run the Claude push-down command with a service resolving `result`.
   *
   * @param result The service result the mock resolves.
   */
  async function runCommand(result: Record<string, unknown>): Promise<void> {
    const captured = captureHandlers();
    const options = {
      context: {} as unknown,
      output: { appendLine: jest.fn() },
      service: {
        pushDownClaudeCustomizations: jest.fn(() => Promise.resolve(result)),
      },
    } as unknown as RepoAutomationCommandRegistrationOptions;
    registerRepoAutomationAdminCommands(options);
    const handler = findHandler(
      captured,
      "drmCopilotExtension.pushDownClaudeCustomizations",
    );
    // Pack multi-select without C# (no variant prompt), then memory mode.
    showQuickPickMock
      .mockResolvedValueOnce([
        { label: "Python", pack: "python", picked: true },
      ])
      .mockResolvedValueOnce("overwrite");
    await handler();
  }

  const BASE_RESULT = {
    tool: "push_down_claude_customizations",
    workspaceRoot: "/fake/workspace",
    summary: "Pushed bundled Claude Code customizations.",
    artifacts: [],
  };

  it("shows one warning notification when the result carries at least one conflict line", async () => {
    // Arrange / Act
    await runCommand({
      ...BASE_RESULT,
      warnings: [CONFLICT_LINE, SKIPPED_LINE],
    });

    // Assert
    expect(showWarningMessageMock).toHaveBeenCalledTimes(1);
    const [message] = showWarningMessageMock.mock.calls[0] as [string];
    expect(message.startsWith("Push-down exclusion conflicts: 1")).toBe(true);
    expect(message).toContain(
      "See the drm-copilot output channel for the affected paths.",
    );
  });

  it("shows no notification when the result carries only skipped and unmatched lines", async () => {
    // Arrange / Act
    await runCommand({
      ...BASE_RESULT,
      warnings: [SKIPPED_LINE, UNMATCHED_LINE],
    });

    // Assert
    expect(showWarningMessageMock).not.toHaveBeenCalled();
  });

  it("shows no notification when the result carries no warnings", async () => {
    // Arrange / Act
    await runCommand(BASE_RESULT);

    // Assert
    expect(showWarningMessageMock).not.toHaveBeenCalled();
  });
});
