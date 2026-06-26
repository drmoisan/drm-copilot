import {
  afterEach,
  beforeEach,
  describe,
  expect,
  it,
  jest,
} from "@jest/globals";

import {
  createMemTree,
  installInProcessFs,
  type NafFsMock,
  pythonScriptSpawned,
  seedTemplateTree,
} from "./new-active-feature-folder-fs-harness";

type CommandHandler = (...args: unknown[]) => Promise<void> | void;

const commandHandlers = new Map<string, CommandHandler>();
const showInputBoxMock = jest.fn<() => Promise<string | undefined>>();
const showQuickPickMock = jest.fn<() => Promise<string | undefined>>();
const appendLineMock = jest.fn<(line: string) => void>();
const registerCommandMock = jest.fn(
  (command: string, handler: CommandHandler) => {
    commandHandlers.set(command, handler);
    return { dispose: jest.fn() };
  },
);

let workspaceFoldersState: Array<{ uri: { fsPath: string } }> | undefined = [
  { uri: { fsPath: "C:/workspace" } },
];

jest.mock(
  "vscode",
  () => ({
    commands: { registerCommand: registerCommandMock },
    window: {
      createOutputChannel: jest.fn(() => ({
        appendLine: appendLineMock,
        dispose: jest.fn(),
      })),
      showInputBox: showInputBoxMock,
      showQuickPick: showQuickPickMock,
    },
    workspace: {
      get workspaceFolders() {
        return workspaceFoldersState;
      },
    },
    Uri: {
      joinPath: jest.fn((base: { fsPath: string }, ...segments: string[]) => ({
        fsPath: `${base.fsPath}/${segments.join("/")}`,
      })),
    },
    lm: {
      registerMcpServerDefinitionProvider: jest.fn(() => ({
        dispose: jest.fn(),
      })),
    },
    EventEmitter: jest.fn(() => ({ event: jest.fn(), dispose: jest.fn() })),
    McpStdioServerDefinition: jest.fn(),
  }),
  { virtual: true },
);

jest.mock("node:fs", () => ({
  existsSync: jest.fn(),
  readFileSync: jest.fn(),
  writeFileSync: jest.fn(),
  mkdirSync: jest.fn(),
  copyFileSync: jest.fn(),
  renameSync: jest.fn(),
  unlinkSync: jest.fn(),
  statSync: jest.fn(),
  readdirSync: jest.fn(),
}));

jest.mock("node:child_process", () => ({
  spawn: jest.fn(),
  spawnSync: jest.fn(),
}));

import { activate } from "../src/extension";

const fsMock = jest.requireMock("node:fs") as NafFsMock;
const childProcessMock = jest.requireMock("node:child_process") as {
  spawn: jest.Mock;
  spawnSync: jest.Mock;
};

const tree = createMemTree();

function activateAndGetHandler(commandId: string): CommandHandler {
  const context = {
    extensionUri: { fsPath: "C:/extension" },
    subscriptions: [] as Array<{ dispose(): void }>,
  };

  activate(context as never);
  const handler = commandHandlers.get(commandId);
  if (!handler) {
    throw new Error(`Missing command handler: ${commandId}`);
  }

  return handler;
}

describe("drm-copilot newActiveFeatureFolder command", () => {
  beforeEach(() => {
    process.env.PATH = "C:/bin";
    process.env.PATHEXT = ".EXE;.CMD";
    commandHandlers.clear();
    appendLineMock.mockReset();
    registerCommandMock.mockClear();
    childProcessMock.spawn.mockReset();
    childProcessMock.spawnSync.mockReset();
    for (const mock of Object.values(fsMock)) {
      mock.mockReset();
    }
    showInputBoxMock.mockReset();
    showQuickPickMock.mockReset();
    tree.files.clear();
    tree.dirs.clear();
    workspaceFoldersState = [{ uri: { fsPath: "C:/workspace" } }];
    installInProcessFs(fsMock, tree);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it("registers newActiveFeatureFolder", () => {
    activateAndGetHandler("drmCopilotExtension.newActiveFeatureFolder");

    expect(
      commandHandlers.has("drmCopilotExtension.newActiveFeatureFolder"),
    ).toBe(true);
  });

  it("runs in-process and omits --issue-number when blank (no python spawn)", async () => {
    // Arrange: prompt flow resolves a feature/full creation with no issue.
    seedTemplateTree(tree, "feature");
    showQuickPickMock
      .mockResolvedValueOnce("feature")
      .mockResolvedValueOnce("full");
    showInputBoxMock
      .mockResolvedValueOnce("blank-pr-context")
      .mockResolvedValueOnce("");

    const handler = activateAndGetHandler(
      "drmCopilotExtension.newActiveFeatureFolder",
    );
    await handler();

    // Assert: no Python script spawned; the in-process workflow created the folder.
    expect(pythonScriptSpawned(childProcessMock)).toBe(false);
    expect(
      tree.files.has(
        "C:/workspace/docs/features/active/blank-pr-context/spec.md",
      ),
    ).toBe(true);
  });

  it("direct invocation forwards the issue number without prompts", async () => {
    // Arrange
    seedTemplateTree(tree, "feature");

    const handler = activateAndGetHandler(
      "drmCopilotExtension.newActiveFeatureFolder",
    );
    await handler([
      "--feature-name",
      "blank-pr-context",
      "--type",
      "feature",
      "--issue-number",
      "104",
      "--work-mode",
      "full-feature",
    ]);

    // Assert: UI skipped, no python spawn, issue number flows into the slug.
    expect(showQuickPickMock).not.toHaveBeenCalled();
    expect(showInputBoxMock).not.toHaveBeenCalled();
    expect(pythonScriptSpawned(childProcessMock)).toBe(false);
    expect(
      tree.files.has(
        "C:/workspace/docs/features/active/blank-pr-context-104/spec.md",
      ),
    ).toBe(true);
  });

  it("direct invocation omits the issue number without prompts", async () => {
    // Arrange
    seedTemplateTree(tree, "feature");

    const handler = activateAndGetHandler(
      "drmCopilotExtension.newActiveFeatureFolder",
    );
    await handler([
      "--feature-name",
      "blank-pr-context",
      "--type",
      "feature",
      "--work-mode",
      "minor-audit",
    ]);

    // Assert: minor-audit writes issue.md with no issue-number suffix.
    expect(showQuickPickMock).not.toHaveBeenCalled();
    expect(showInputBoxMock).not.toHaveBeenCalled();
    expect(pythonScriptSpawned(childProcessMock)).toBe(false);
    expect(
      tree.files.has(
        "C:/workspace/docs/features/active/blank-pr-context/issue.md",
      ),
    ).toBe(true);
  });

  it("direct mode rejects a non-digit issue number without running the workflow", async () => {
    const handler = activateAndGetHandler(
      "drmCopilotExtension.newActiveFeatureFolder",
    );

    await expect(
      handler([
        "--feature-name",
        "blank-pr-context",
        "--type",
        "feature",
        "--issue-number",
        "issue-104",
        "--work-mode",
        "full-feature",
      ]),
    ).rejects.toThrow(/issue number/i);
    expect(showQuickPickMock).not.toHaveBeenCalled();
    expect(showInputBoxMock).not.toHaveBeenCalled();
    expect(childProcessMock.spawn).not.toHaveBeenCalled();
    expect(tree.files.size).toBe(0);
  });

  it("direct mode rejects an invalid type without running the workflow", async () => {
    const handler = activateAndGetHandler(
      "drmCopilotExtension.newActiveFeatureFolder",
    );

    await expect(
      handler([
        "--feature-name",
        "blank-pr-context",
        "--type",
        "maintenance",
        "--work-mode",
        "full-feature",
      ]),
    ).rejects.toThrow(/type/i);
    expect(showQuickPickMock).not.toHaveBeenCalled();
    expect(showInputBoxMock).not.toHaveBeenCalled();
    expect(childProcessMock.spawn).not.toHaveBeenCalled();
    expect(tree.files.size).toBe(0);
  });

  it("returns early when the type quick pick is cancelled", async () => {
    showQuickPickMock.mockResolvedValueOnce(undefined);

    const handler = activateAndGetHandler(
      "drmCopilotExtension.newActiveFeatureFolder",
    );
    await handler();

    expect(childProcessMock.spawn).not.toHaveBeenCalled();
    expect(tree.files.size).toBe(0);
  });

  it("returns early when the feature-name input is cancelled", async () => {
    showQuickPickMock.mockResolvedValueOnce("feature");
    showInputBoxMock.mockResolvedValueOnce(undefined);

    const handler = activateAndGetHandler(
      "drmCopilotExtension.newActiveFeatureFolder",
    );
    await handler();

    expect(childProcessMock.spawn).not.toHaveBeenCalled();
    expect(tree.files.size).toBe(0);
  });

  it("returns early when the issue-number input is cancelled", async () => {
    showQuickPickMock.mockResolvedValueOnce("feature");
    showInputBoxMock
      .mockResolvedValueOnce("blank-pr-context")
      .mockResolvedValueOnce(undefined);

    const handler = activateAndGetHandler(
      "drmCopilotExtension.newActiveFeatureFolder",
    );
    await handler();

    expect(childProcessMock.spawn).not.toHaveBeenCalled();
    expect(tree.files.size).toBe(0);
  });

  it("returns early when the work-mode quick pick is cancelled", async () => {
    showQuickPickMock
      .mockResolvedValueOnce("feature")
      .mockResolvedValueOnce(undefined);
    showInputBoxMock
      .mockResolvedValueOnce("blank-pr-context")
      .mockResolvedValueOnce("");

    const handler = activateAndGetHandler(
      "drmCopilotExtension.newActiveFeatureFolder",
    );
    await handler();

    expect(childProcessMock.spawn).not.toHaveBeenCalled();
    expect(tree.files.size).toBe(0);
  });
});
