import {
  afterEach,
  beforeEach,
  describe,
  expect,
  it,
  jest,
} from "@jest/globals";

type CommandHandler = () => Promise<void> | void;

const commandHandlers = new Map<string, CommandHandler>();
const registerCommandMock = jest.fn(
  (command: string, handler: CommandHandler) => {
    commandHandlers.set(command, handler);
    return { dispose: jest.fn() };
  },
);

jest.mock(
  "vscode",
  () => ({
    commands: {
      registerCommand: registerCommandMock,
    },
    window: {
      createOutputChannel: jest.fn(() => ({
        appendLine: jest.fn(),
        dispose: jest.fn(),
      })),
      showQuickPick: jest.fn(),
    },
    workspace: {
      get workspaceFolders() {
        return [{ uri: { fsPath: "C:/workspace" } }];
      },
    },
    Uri: {
      joinPath: jest.fn((base: { fsPath: string }, relative: string) => ({
        fsPath: `${base.fsPath}/${relative}`,
      })),
    },
  }),
  { virtual: true },
);

jest.mock("node:fs", () => ({
  existsSync: jest.fn(() => true),
}));

jest.mock("node:child_process", () => ({
  spawn: jest.fn(),
  spawnSync: jest.fn(),
}));

import { activate } from "../src/extension";

function activateExtension(): void {
  const context = {
    extensionUri: { fsPath: "C:/extension" },
    subscriptions: [] as Array<{ dispose(): void }>,
  };

  activate(context as never);
}

describe("drm-copilot placeholder command registration", () => {
  beforeEach(() => {
    commandHandlers.clear();
    registerCommandMock.mockClear();
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it("registers push-down placeholder commands", () => {
    activateExtension();

    expect(
      commandHandlers.has(
        "scaffoldExtension.newActiveFeatureFolderPlaceholder",
      ),
    ).toBe(true);
    expect(
      commandHandlers.has("scaffoldExtension.potentialToIssuePlaceholder"),
    ).toBe(true);
    expect(
      commandHandlers.has(
        "scaffoldExtension.newPotentialBugEntryPyPlaceholder",
      ),
    ).toBe(true);
    expect(
      commandHandlers.has("scaffoldExtension.newPotentialEntryPsPlaceholder"),
    ).toBe(true);
  });

  it("placeholder command throws deterministic not implemented error", async () => {
    activateExtension();

    const handler = commandHandlers.get(
      "scaffoldExtension.newActiveFeatureFolderPlaceholder",
    );

    if (!handler) {
      throw new Error(
        "Missing handler scaffoldExtension.newActiveFeatureFolderPlaceholder",
      );
    }

    await expect(handler()).rejects.toThrow(
      "Not implemented: scaffoldExtension.newActiveFeatureFolderPlaceholder is a placeholder for scripts.dev_tools.new_active_feature_folder.",
    );
  });
});
