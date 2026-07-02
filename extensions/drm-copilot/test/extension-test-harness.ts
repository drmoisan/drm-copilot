import { jest } from "@jest/globals";
import {
  createMockProcess,
  createMockProcessWithStderr,
  getFreshChildProcessMock,
  getFreshFsMock,
  prepareFreshModulesWithPosixPathResolve,
  setExecutablePresenceOnFsMock,
  type ExecutablePresence,
  type MockChildProcess,
  type MockExistsSync,
} from "./runtime-test-helpers";

type CommandHandler = (...args: unknown[]) => Promise<void> | void;

interface MockTerminal {
  readonly show: jest.Mock;
  readonly sendText: jest.Mock;
  readonly dispose: jest.Mock;
}

const commandHandlers = new Map<string, CommandHandler>();
const appendLineMock = jest.fn<(line: string) => void>();
const showInputBoxMock = jest.fn();
const showQuickPickMock = jest.fn();
const showOpenDialogMock = jest.fn();
const showWarningMessageMock = jest.fn();
const showInformationMessageMock = jest.fn();
const showErrorMessageMock = jest.fn();
const openTextDocumentMock = jest.fn();
const showTextDocumentMock = jest.fn();
function buildMockTerminal(): MockTerminal {
  return {
    show: jest.fn(),
    sendText: jest.fn(),
    dispose: jest.fn(),
  };
}

const createTerminalMock = jest.fn((): MockTerminal => buildMockTerminal());
const registerCommandMock = jest.fn(
  (command: string, handler: CommandHandler) => {
    commandHandlers.set(command, handler);
    return { dispose: jest.fn() };
  },
);

let quickPickResultLabel: string | undefined = "origin/main";
let workspaceFoldersState: Array<{ uri: { fsPath: string } }> | undefined = [
  { uri: { fsPath: "C:/workspace" } },
];

const registerMcpServerDefinitionProviderMock = jest.fn(() => ({
  dispose: jest.fn(),
}));

let preClaudeScriptPathConfig: string | undefined = undefined;
let postCodexScriptPathConfig: string | undefined = undefined;
let codexExecutablePathConfig: string | undefined = undefined;

const getConfigurationMock = jest.fn((section?: string) => ({
  get: <T>(key: string): T | undefined => {
    if (
      section === "drmCopilotExtension.newClaudeWorktreeSession" &&
      key === "preClaudeScriptPath"
    ) {
      return preClaudeScriptPathConfig as T | undefined;
    }
    if (
      section === "drmCopilotExtension.newCodexWorktreeSession" &&
      key === "postCodexScriptPath"
    ) {
      return postCodexScriptPathConfig as T | undefined;
    }
    if (
      section === "drmCopilotExtension.newCodexWorktreeSession" &&
      key === "codexExecutablePath"
    ) {
      return codexExecutablePathConfig as T | undefined;
    }
    return undefined;
  },
}));

jest.mock(
  "vscode",
  () => ({
    commands: {
      registerCommand: registerCommandMock,
    },
    window: {
      createOutputChannel: jest.fn(() => ({
        appendLine: appendLineMock,
        dispose: jest.fn(),
      })),
      showTextDocument: showTextDocumentMock,
      showOpenDialog: showOpenDialogMock,
      showInputBox: showInputBoxMock,
      showQuickPick: showQuickPickMock,
      showWarningMessage: showWarningMessageMock,
      showInformationMessage: showInformationMessageMock,
      showErrorMessage: showErrorMessageMock,
      createTerminal: createTerminalMock,
    },
    workspace: {
      get workspaceFolders() {
        return workspaceFoldersState;
      },
      openTextDocument: openTextDocumentMock,
      getConfiguration: getConfigurationMock,
    },
    Uri: {
      joinPath: jest.fn((base: { fsPath: string }, ...segments: string[]) => ({
        fsPath: `${base.fsPath}/${segments.join("/")}`,
      })),
      file: jest.fn((fsPath: string) => ({ fsPath })),
    },
    lm: {
      registerMcpServerDefinitionProvider:
        registerMcpServerDefinitionProviderMock,
    },
    EventEmitter: jest.fn(() => ({
      event: jest.fn(),
      dispose: jest.fn(),
    })),
    McpStdioServerDefinition: jest.fn(),
  }),
  { virtual: true },
);

jest.mock("node:fs", () => ({
  copyFileSync: jest.fn(),
  existsSync: jest.fn(),
  mkdirSync: jest.fn(),
  readFileSync: jest.fn(),
  writeFileSync: jest.fn(),
  // statSync/readdirSync support the in-process push-down filesystem adapter
  // (F3). They default to "not found"/"empty" so suites that do not seed a
  // push-down tree are unaffected.
  statSync: jest.fn(() => {
    throw new Error("ENOENT");
  }),
  readdirSync: jest.fn(() => []),
}));

jest.mock("node:child_process", () => ({
  spawn: jest.fn(),
  spawnSync: jest.fn(),
}));

const fsMock = jest.requireMock("node:fs") as {
  existsSync: MockExistsSync;
  readFileSync: jest.MockedFunction<
    (filePath: string, encoding?: string) => string
  >;
  writeFileSync: jest.MockedFunction<
    (filePath: string, content: string, encoding?: string) => void
  >;
  mkdirSync: jest.MockedFunction<
    (dirPath: string, options?: { recursive?: boolean }) => void
  >;
  statSync: jest.MockedFunction<(filePath: string) => unknown>;
  readdirSync: jest.MockedFunction<(dirPath: string) => unknown[]>;
};

const childProcessMock = jest.requireMock("node:child_process") as {
  spawn: jest.Mock;
  spawnSync: jest.Mock;
};

function getExtensionModule(): typeof import("../src/extension") {
  // eslint-disable-next-line @typescript-eslint/no-require-imports -- the harness must load the mocked extension module graph used by Jest tests
  return require("../src/extension") as typeof import("../src/extension");
}

export function setGitBranchDiscoveryState(input: {
  readonly originHead?: string;
  readonly remoteRefs?: ReadonlyArray<string>;
  readonly localRefs?: ReadonlyArray<string>;
}): void {
  const originHead = input.originHead ?? "origin/main";
  const remoteRefs = input.remoteRefs ?? ["origin/HEAD", "origin/main"];
  const localRefs = input.localRefs ?? ["main"];

  childProcessMock.spawnSync.mockImplementation((...rawArgs: unknown[]) => {
    const args = (rawArgs[1] as ReadonlyArray<string> | undefined) ?? [];
    const joined = args.join(" ");
    if (joined.includes("symbolic-ref") && joined.includes("origin/HEAD")) {
      return {
        status: originHead.length > 0 ? 0 : 1,
        stdout: originHead,
        stderr: originHead.length > 0 ? "" : "origin/HEAD not set",
      };
    }

    if (
      joined.includes("for-each-ref") &&
      joined.includes("refs/remotes/origin")
    ) {
      return {
        status: 0,
        stdout: remoteRefs.join("\n"),
        stderr: "",
      };
    }

    if (joined.includes("for-each-ref") && joined.includes("refs/heads")) {
      return {
        status: 0,
        stdout: localRefs.join("\n"),
        stderr: "",
      };
    }

    return {
      status: 0,
      stdout: "",
      stderr: "",
    };
  });

  showQuickPickMock.mockImplementation(async (...rawArgs: unknown[]) => {
    const items =
      (rawArgs[0] as ReadonlyArray<{ label: string }> | undefined) ?? [];
    if (!quickPickResultLabel) {
      return undefined;
    }

    const matched = items.find((item) => item.label === quickPickResultLabel);
    return matched ?? items[0];
  });
}

export function setExecutablePresence(presence: ExecutablePresence): void {
  setExecutablePresenceOnFsMock(fsMock, presence);
}

let pyprojectFixtureContent: string | undefined = undefined;

/**
 * Configures the fs mock to report a `pyproject.toml` at the workspace root
 * with the supplied content. Pass `undefined` to clear the fixture (the
 * default reset state).
 *
 * The pyproject detection layers on top of the executable-presence mock so
 * tests calling `setExecutablePresence` followed by `setPyprojectFixture`
 * get correct behavior for both runtime probing and pyproject detection.
 *
 * @param content The full text content of the simulated pyproject.toml.
 */
export function setPyprojectFixture(content: string | undefined): void {
  pyprojectFixtureContent = content;

  const previousExistsImpl = fsMock.existsSync.getMockImplementation();
  fsMock.existsSync.mockImplementation((filePath: string): boolean => {
    if (filePath.toLowerCase().endsWith("pyproject.toml")) {
      return pyprojectFixtureContent !== undefined;
    }
    return previousExistsImpl ? previousExistsImpl(filePath) : false;
  });

  fsMock.readFileSync.mockImplementation((filePath: string): string => {
    if (
      filePath.toLowerCase().endsWith("pyproject.toml") &&
      pyprojectFixtureContent !== undefined
    ) {
      return pyprojectFixtureContent;
    }
    throw new Error(`Unexpected fs.readFileSync call: ${filePath}`);
  });
}

export function setFreshExecutablePresence(presence: ExecutablePresence): void {
  setExecutablePresenceOnFsMock(getFreshFsMock(), presence);
}

export function setWorkspaceFolders(
  value: Array<{ uri: { fsPath: string } }> | undefined,
): void {
  workspaceFoldersState = value;
}

/**
 * Controls the value returned by
 * `vscode.workspace.getConfiguration("drmCopilotExtension.newClaudeWorktreeSession").get<string>("preClaudeScriptPath")`.
 * Pass `undefined` to simulate the setting being unset (the default reset
 * state), in which case the handler applies its TypeScript-side default.
 *
 * @param value The configured pre-`claude` script path, or `undefined` to
 *              leave the setting unset.
 */
export function setPreClaudeScriptPathConfig(value: string | undefined): void {
  preClaudeScriptPathConfig = value;
}

/**
 * Controls the value returned by
 * `vscode.workspace.getConfiguration("drmCopilotExtension.newCodexWorktreeSession").get<string>("postCodexScriptPath")`.
 * Pass `undefined` to simulate the setting being unset.
 *
 * @param value The configured post-`codex` script path, or `undefined`.
 */
export function setPostCodexScriptPathConfig(value: string | undefined): void {
  postCodexScriptPathConfig = value;
}

/**
 * Controls the value returned by
 * `vscode.workspace.getConfiguration("drmCopilotExtension.newCodexWorktreeSession").get<string>("codexExecutablePath")`.
 * Pass `undefined` to simulate the setting being unset.
 *
 * @param value The configured `codex` executable path, or `undefined`.
 */
export function setCodexExecutablePathConfig(value: string | undefined): void {
  codexExecutablePathConfig = value;
}

export function resetExtensionHarnessState(): void {
  process.env.PATH = "C:/bin";
  process.env.PATHEXT = ".EXE;.CMD";
  commandHandlers.clear();
  appendLineMock.mockReset();
  registerCommandMock.mockClear();
  registerMcpServerDefinitionProviderMock.mockClear();
  getConfigurationMock.mockClear();
  preClaudeScriptPathConfig = undefined;
  postCodexScriptPathConfig = undefined;
  codexExecutablePathConfig = undefined;
  childProcessMock.spawn.mockReset();
  childProcessMock.spawnSync.mockReset();
  fsMock.readFileSync.mockReset();
  fsMock.writeFileSync.mockReset();
  fsMock.mkdirSync.mockReset();
  fsMock.statSync.mockReset();
  fsMock.statSync.mockImplementation(() => {
    throw new Error("ENOENT");
  });
  fsMock.readdirSync.mockReset();
  fsMock.readdirSync.mockReturnValue([]);
  pyprojectFixtureContent = undefined;
  showInputBoxMock.mockReset();
  showQuickPickMock.mockReset();
  showOpenDialogMock.mockReset();
  showWarningMessageMock.mockReset();
  showInformationMessageMock.mockReset();
  showErrorMessageMock.mockReset();
  openTextDocumentMock.mockReset();
  showTextDocumentMock.mockReset();
  createTerminalMock.mockReset();
  createTerminalMock.mockImplementation((): MockTerminal =>
    buildMockTerminal(),
  );
  openTextDocumentMock.mockImplementation(async (uri: { fsPath: string }) => ({
    uri,
  }));
  showTextDocumentMock.mockResolvedValue(undefined);
  workspaceFoldersState = [{ uri: { fsPath: "C:/workspace" } }];
  quickPickResultLabel = "origin/main";
  setGitBranchDiscoveryState({
    originHead: "origin/main",
    remoteRefs: ["origin/HEAD", "origin/main", "origin/develop"],
    localRefs: ["main"],
  });
}

export function activateAndGetHandler(commandId: string): CommandHandler {
  const extensionModule = getExtensionModule();
  const context = {
    extensionUri: { fsPath: "C:/extension" },
    subscriptions: [] as Array<{ dispose(): void }>,
  };

  extensionModule.activate(context as never);
  const handler = commandHandlers.get(commandId);
  if (!handler) {
    throw new Error(`Missing command handler: ${commandId}`);
  }

  return handler;
}

export async function activateFreshHandlerWithPosixPathResolve(
  commandId: string,
): Promise<CommandHandler> {
  const extensionModule = getExtensionModule();
  const context = {
    extensionUri: { fsPath: "C:/extension" },
    subscriptions: [] as Array<{ dispose(): void }>,
  };
  extensionModule.activate(context as never);
  const handler = commandHandlers.get(commandId);
  if (!handler) {
    throw new Error(`Missing command handler: ${commandId}`);
  }

  return handler;
}

export function detectRuntime(
  runtimeKind: import("../src/command-runtime").RuntimeKind,
): import("../src/command-runtime").RuntimeResolution {
  return getExtensionModule().detectRuntime(runtimeKind);
}

export function resolveCodexExecutable(
  configuredExecutable: string | undefined,
): string {
  return getExtensionModule().resolveCodexExecutable(configuredExecutable);
}

export function deactivate(): void {
  getExtensionModule().deactivate();
}

export {
  appendLineMock,
  childProcessMock,
  commandHandlers,
  createMockProcess,
  createMockProcessWithStderr,
  createTerminalMock,
  fsMock,
  getConfigurationMock,
  getFreshChildProcessMock,
  prepareFreshModulesWithPosixPathResolve,
  registerCommandMock,
  registerMcpServerDefinitionProviderMock,
  resolveCodexExecutable,
  openTextDocumentMock,
  showInputBoxMock,
  showOpenDialogMock,
  showQuickPickMock,
  showWarningMessageMock,
  showInformationMessageMock,
  showErrorMessageMock,
  showTextDocumentMock,
};

export type { CommandHandler, MockChildProcess, MockTerminal };
