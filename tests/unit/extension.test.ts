import { describe, expect, jest, test, beforeEach } from "@jest/globals";
import type * as vscode from "vscode";

// Mock VS Code API
const mockRegisterCommand = jest.fn();
const mockRegisterTaskProvider = jest.fn();
const mockShowInformationMessage = jest.fn();

jest.mock(
  "vscode",
  () => ({
    commands: {
      registerCommand: mockRegisterCommand,
    },
    tasks: {
      registerTaskProvider: mockRegisterTaskProvider,
    },
    window: {
      showInformationMessage: mockShowInformationMessage,
    },
  }),
  { virtual: true },
);

// Import after mocking
import { activate, deactivate } from "../../src/extension";
import { TASK_COMMAND_MAP } from "../../src/task-command-map";

describe("Extension activation", () => {
  let mockContext: vscode.ExtensionContext;

  beforeEach(() => {
    // Clear all mocks before each test
    jest.clearAllMocks();

    // Create a minimal mock context
    mockContext = {
      subscriptions: [],
      extensionPath: "/test/path",
      extensionUri: { fsPath: "/test/path" } as vscode.Uri,
      asAbsolutePath: jest.fn(
        (relativePath: string) => `/test/path/${relativePath}`,
      ),
    } as unknown as vscode.ExtensionContext;

    // Mock registerCommand to return a disposable
    mockRegisterCommand.mockReturnValue({
      dispose: jest.fn(),
    });

    // Mock registerTaskProvider to return a disposable
    mockRegisterTaskProvider.mockReturnValue({
      dispose: jest.fn(),
    });
  });

  test("activates and registers the task provider", () => {
    activate(mockContext);

    expect(mockRegisterTaskProvider).toHaveBeenCalledWith(
      "drm-copilot",
      expect.any(Object),
    );
  });

  test("registers the applyCustomizations command", () => {
    activate(mockContext);

    const commandCalls = mockRegisterCommand.mock.calls;
    const applyCustomizationsCall = commandCalls.find(
      (call) => call[0] === "drm-copilot.applyCustomizations",
    );

    expect(applyCustomizationsCall).toBeDefined();
  });

  test("registers all utility commands from TASK_COMMAND_MAP", () => {
    activate(mockContext);

    // Should register applyCustomizations + all commands from TASK_COMMAND_MAP
    const expectedCommandCount = Object.keys(TASK_COMMAND_MAP).length + 1;
    expect(mockRegisterCommand).toHaveBeenCalledTimes(expectedCommandCount);

    // Verify each command from TASK_COMMAND_MAP is registered
    for (const commandId of Object.keys(TASK_COMMAND_MAP)) {
      const commandCall = mockRegisterCommand.mock.calls.find(
        (call) => call[0] === commandId,
      );
      expect(commandCall).toBeDefined();
    }
  });

  test("registers key drm-copilot commands", () => {
    activate(mockContext);

    const expectedCommands = [
      "drm-copilot.loadOpenAIKey",
      "drm-copilot.qcBlackFormat",
      "drm-copilot.qcRuffLint",
      "drm-copilot.qcPyrightTypeCheck",
      "drm-copilot.poshQCFormat",
      "drm-copilot.devPromotePotentialToIssue",
      "drm-copilot.tsPrettierFormat",
      "drm-copilot.tsEslintLint",
    ];

    const registeredCommands = mockRegisterCommand.mock.calls.map(
      (call) => call[0],
    );

    for (const commandId of expectedCommands) {
      expect(registeredCommands).toContain(commandId);
    }
  });

  test("adds disposables to context subscriptions", () => {
    activate(mockContext);

    // Should have registered: task provider + applyCustomizations + all TASK_COMMAND_MAP commands
    const expectedSubscriptions = Object.keys(TASK_COMMAND_MAP).length + 2;
    expect(mockContext.subscriptions).toHaveLength(expectedSubscriptions);
  });

  test("shows activation message", () => {
    activate(mockContext);

    expect(mockShowInformationMessage).toHaveBeenCalledWith(
      expect.stringContaining("DRM Copilot:"),
    );
    expect(mockShowInformationMessage).toHaveBeenCalledWith(
      expect.stringContaining("commands registered"),
    );
  });

  test("deactivate function exists and is callable", () => {
    expect(() => deactivate()).not.toThrow();
  });
});
