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
  seedFile,
  seedTemplateTree,
  setPythonPresence,
} from "./new-active-feature-folder-fs-harness";

/**
 * In-process behavioral cases for the `newActiveFeatureFolder` command (F8),
 * extracted from `extension.new-active-feature-folder.test.ts` so neither file
 * exceeds the 500-line limit. These cases replace the former Python-runtime and
 * non-zero-exit assertions: the missing-python case is inverted to assert
 * success without Python, and the exit-code case is replaced by an in-process
 * workflow failure that surfaces the preserved error message.
 */

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

describe("drm-copilot newActiveFeatureFolder in-process behavior", () => {
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

  it("succeeds without any python runtime present", async () => {
    // Arrange: python is absent on PATH; the in-process path must not need it.
    seedTemplateTree(tree, "feature");
    setPythonPresence(fsMock, false);
    showQuickPickMock
      .mockResolvedValueOnce("feature")
      .mockResolvedValueOnce("full");
    showInputBoxMock
      .mockResolvedValueOnce("blank-pr-context")
      .mockResolvedValueOnce("");

    const handler = activateAndGetHandler(
      "drmCopilotExtension.newActiveFeatureFolder",
    );

    // Act / Assert: completes without a python-runtime error.
    await expect(handler()).resolves.toBeUndefined();
    expect(pythonScriptSpawned(childProcessMock)).toBe(false);
    expect(
      tree.files.has(
        "C:/workspace/docs/features/active/blank-pr-context/spec.md",
      ),
    ).toBe(true);
  });

  it("forwards templateRoot to the bundled feature-templates (no python spawn)", async () => {
    // Arrange: the template tree exists ONLY under the bundled feature-templates
    // root. A successful creation proves the service forwarded `this.templateRoot`
    // (the --template-root parity) to the in-process workflow.
    seedTemplateTree(tree, "feature");
    showQuickPickMock
      .mockResolvedValueOnce("feature")
      .mockResolvedValueOnce("minor-audit");
    showInputBoxMock
      .mockResolvedValueOnce("test-feature")
      .mockResolvedValueOnce("");

    const handler = activateAndGetHandler(
      "drmCopilotExtension.newActiveFeatureFolder",
    );
    await handler();

    // Assert: minor-audit issue.md was created under the active folder and no
    // Python script was spawned.
    expect(pythonScriptSpawned(childProcessMock)).toBe(false);
    expect(
      tree.files.has("C:/workspace/docs/features/active/test-feature/issue.md"),
    ).toBe(true);
  });

  it("surfaces an in-process workflow failure (target exists without force)", async () => {
    // Arrange: the target folder already exists, so createActiveFolder throws
    // the preserved failure message instead of a python exit code.
    seedTemplateTree(tree, "feature");
    seedFile(
      tree,
      "C:/workspace/docs/features/active/blank-pr-context/existing.md",
      "x",
    );
    showQuickPickMock
      .mockResolvedValueOnce("feature")
      .mockResolvedValueOnce("full");
    showInputBoxMock
      .mockResolvedValueOnce("blank-pr-context")
      .mockResolvedValueOnce("");

    const handler = activateAndGetHandler(
      "drmCopilotExtension.newActiveFeatureFolder",
    );

    await expect(handler()).rejects.toThrow(/Target exists:/);
    expect(pythonScriptSpawned(childProcessMock)).toBe(false);
  });
});
