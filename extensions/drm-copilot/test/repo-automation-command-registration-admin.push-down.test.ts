import { afterEach, describe, expect, it, jest } from "@jest/globals";

/**
 * Tests for the push-down command additions of issue #1029: the Copilot pack
 * QuickPick and the push-down conflict notification on all three commands.
 *
 * The VS Code host is mocked; each command handler is captured at registration
 * time and invoked directly.
 */

const showQuickPickMock =
  jest.fn<(items: unknown, options?: unknown) => Promise<unknown>>();
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

const CONFLICT_LINE =
  "push-down conflict: conflict AGENTS.md (layer shared, pack core): edited locally";
const EXCLUSION_CONFLICT_LINE =
  "push-down exclusion conflict: destination file present, not overwritten: a.md (entry a.md, line 1)";

/**
 * Register the admin commands with a fake service and return one handler.
 *
 * @param commandId Command to capture.
 * @param service Fake service methods.
 * @returns The captured handler.
 */
function handlerFor(
  commandId: string,
  service: Record<string, unknown>,
): () => Promise<unknown> {
  let captured: (() => Promise<unknown>) | undefined;
  registerCommandMock.mockImplementation((...args: unknown[]) => {
    if (args[0] === commandId) {
      captured = args[1] as () => Promise<unknown>;
    }
    return { dispose: jest.fn() };
  });
  registerRepoAutomationAdminCommands({
    context: {} as unknown,
    output: { appendLine: jest.fn() },
    service,
  } as unknown as RepoAutomationCommandRegistrationOptions);
  if (captured === undefined) {
    throw new Error(`Handler for ${commandId} was not registered.`);
  }
  return captured;
}

/** A resolved service result carrying the given warnings. */
function resultWith(warnings?: string[]) {
  return Promise.resolve({
    tool: "push_down_copilot_customizations",
    workspaceRoot: "/fake/workspace",
    summary: "s",
    artifacts: [],
    ...(warnings === undefined ? {} : { warnings }),
  });
}

describe("push-down command additions (issue #1029)", () => {
  afterEach(() => {
    jest.resetAllMocks();
  });

  it("forwards the Copilot pack selection", async () => {
    const pushDown =
      jest.fn<(input: unknown) => ReturnType<typeof resultWith>>();
    pushDown.mockImplementation(() => resultWith());
    const handler = handlerFor(
      "drmCopilotExtension.pushDownCopilotCustomizations",
      { pushDownCopilotCustomizations: pushDown },
    );
    showQuickPickMock.mockResolvedValueOnce([
      { label: "Python", pack: "python", picked: true },
      { label: "C#", pack: "csharp", picked: true },
    ]);

    await handler();

    expect(pushDown).toHaveBeenCalledWith({
      workspaceRoot: "/fake/workspace",
      invocationId: "drmCopilotExtension.pushDownCopilotCustomizations",
      packs: ["python", "csharp"],
    });
    const [items] = showQuickPickMock.mock.calls[0] as [
      Array<{ pack: string; picked: boolean }>,
    ];
    expect(items.every((item) => item.picked)).toBe(true);
    expect(showWarningMessageMock).not.toHaveBeenCalled();
  });

  it("does not call the service when the Copilot pack selection is cancelled", async () => {
    const pushDown =
      jest.fn<(input: unknown) => ReturnType<typeof resultWith>>();
    pushDown.mockImplementation(() => resultWith());
    const handler = handlerFor(
      "drmCopilotExtension.pushDownCopilotCustomizations",
      { pushDownCopilotCustomizations: pushDown },
    );
    showQuickPickMock.mockResolvedValueOnce(undefined);

    await handler();

    expect(pushDown).not.toHaveBeenCalled();
  });

  it("shows the push-down conflict warning for the Copilot command", async () => {
    const handler = handlerFor(
      "drmCopilotExtension.pushDownCopilotCustomizations",
      {
        pushDownCopilotCustomizations: () =>
          resultWith([CONFLICT_LINE, CONFLICT_LINE]),
      },
    );
    showQuickPickMock.mockResolvedValueOnce([]);

    await handler();

    expect(showWarningMessageMock).toHaveBeenCalledWith(
      "Push-down conflicts: 2. See the drm-copilot output channel for the affected paths.",
    );
  });

  it("shows the push-down conflict warning for the Codex command", async () => {
    const handler = handlerFor(
      "drmCopilotExtension.pushDownCodexAndAgentsCustomizations",
      {
        pushDownCodexAndAgentsCustomizations: () => resultWith([CONFLICT_LINE]),
      },
    );
    showQuickPickMock.mockResolvedValueOnce([
      { label: "Python", pack: "python", picked: true },
    ]);

    await handler();

    expect(showWarningMessageMock).toHaveBeenCalledTimes(1);
    expect(showWarningMessageMock).toHaveBeenCalledWith(
      "Push-down conflicts: 1. See the drm-copilot output channel for the affected paths.",
    );
  });

  it("shows the push-down conflict warning for the Claude command beside the exclusion warning", async () => {
    const handler = handlerFor(
      "drmCopilotExtension.pushDownClaudeCustomizations",
      {
        pushDownClaudeCustomizations: () =>
          resultWith([EXCLUSION_CONFLICT_LINE, CONFLICT_LINE]),
      },
    );
    showQuickPickMock
      .mockResolvedValueOnce([
        { label: "Python", pack: "python", picked: true },
      ])
      .mockResolvedValueOnce("overwrite");

    await handler();

    expect(
      showWarningMessageMock.mock.calls.map(([message]) => message),
    ).toEqual([
      "Push-down exclusion conflicts: 1. See the drm-copilot output channel for the affected paths.",
      "Push-down conflicts: 1. See the drm-copilot output channel for the affected paths.",
    ]);
  });
});
