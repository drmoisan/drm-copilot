import {
  afterEach,
  beforeEach,
  describe,
  expect,
  it,
  jest,
} from "@jest/globals";

/**
 * Behavioral unit tests for the MCP provider registration module.
 *
 * Purpose:
 *   Verify that `registerMcpProvider` registers a provider with the VS Code
 *   language model API, that the callbacks it installs build server definitions
 *   with the expected arguments, and that it correctly sets the workspace `cwd`.
 */

// ----- VS Code mock ---------------------------------------------------------

/** Tracks the provider object passed to `registerMcpServerDefinitionProvider`. */
type CapturedMcpProvider = {
  onDidChangeMcpServerDefinitions: unknown;
  provideMcpServerDefinitions: () => Promise<Array<MockServerDef>>;
  resolveMcpServerDefinition: (server: unknown) => Promise<unknown>;
};

/** Minimal mock shape for a McpStdioServerDefinition object instance. */
type MockServerDef = {
  cwd?: unknown;
};

let capturedProvider: CapturedMcpProvider | null = null;

const registerMcpServerDefinitionProviderMock = jest.fn(
  (_id: string, provider: CapturedMcpProvider) => {
    capturedProvider = provider;
    return { dispose: jest.fn() };
  },
);

/** Tracks instances created by the `McpStdioServerDefinition` mock constructor. */
const mcpServerDefInstances: MockServerDef[] = [];

const McpStdioServerDefinitionMock = jest.fn().mockImplementation(() => {
  const instance: MockServerDef = {};
  mcpServerDefInstances.push(instance);
  return instance;
});

let workspaceFoldersState: Array<{ uri: { fsPath: string } }> | undefined =
  undefined;

jest.mock(
  "vscode",
  () => ({
    lm: {
      registerMcpServerDefinitionProvider:
        registerMcpServerDefinitionProviderMock,
    },
    EventEmitter: jest.fn(() => ({
      event: jest.fn(),
      dispose: jest.fn(),
    })),
    McpStdioServerDefinition: McpStdioServerDefinitionMock,
    Uri: {
      joinPath: jest.fn((base: { fsPath: string }, ...segments: string[]) => ({
        fsPath: `${base.fsPath}/${segments.join("/")}`,
      })),
    },
    workspace: {
      get workspaceFolders() {
        return workspaceFoldersState;
      },
    },
  }),
  { virtual: true },
);

// ----- helpers --------------------------------------------------------------

import { registerMcpProvider } from "../src/mcp-provider";

/** Build a minimal mimicked ExtensionContext for testing. */
function createMockContext(extensionFsPath = "C:/extension"): {
  subscriptions: Array<{ dispose: () => void }>;
  extensionUri: { fsPath: string };
} {
  return {
    subscriptions: [],
    extensionUri: { fsPath: extensionFsPath },
  };
}

// ----- tests ----------------------------------------------------------------

describe("registerMcpProvider", () => {
  beforeEach(() => {
    capturedProvider = null;
    mcpServerDefInstances.length = 0;
    workspaceFoldersState = undefined;
    jest.clearAllMocks();
    // Re-install the mock implementation after clearAllMocks resets it.
    registerMcpServerDefinitionProviderMock.mockImplementation(
      (_id: string, provider: CapturedMcpProvider) => {
        capturedProvider = provider;
        return { dispose: jest.fn() };
      },
    );
    McpStdioServerDefinitionMock.mockImplementation(() => {
      const instance: MockServerDef = {};
      mcpServerDefInstances.push(instance);
      return instance;
    });
  });

  afterEach(() => {
    workspaceFoldersState = undefined;
  });

  it("registers a provider and returns disposables", () => {
    // Arrange: create a minimal context with an empty subscriptions array.
    const context = createMockContext();

    // Act: register the provider.
    const disposables = registerMcpProvider(
      context as unknown as import("vscode").ExtensionContext,
    );

    // Assert: the return value is an array of disposable objects, and the
    // context subscriptions were updated to include them.
    expect(Array.isArray(disposables)).toBe(true);
    expect(disposables.length).toBeGreaterThan(0);
    disposables.forEach((d) => {
      expect(d).toHaveProperty("dispose");
    });
    expect(context.subscriptions.length).toBe(disposables.length);
  });

  it("constructs McpStdioServerDefinition with expected args", async () => {
    // Arrange: context pointing at a known extension path.
    const context = createMockContext("C:/test-extension");

    registerMcpProvider(
      context as unknown as import("vscode").ExtensionContext,
    );

    // Act: invoke the captured provideMcpServerDefinitions callback.
    expect(capturedProvider).not.toBeNull();
    const results = await capturedProvider!.provideMcpServerDefinitions();

    // Assert: the constructor was called with the expected server name, runtime,
    // and a path that ends with mcp-server.js.
    expect(McpStdioServerDefinitionMock).toHaveBeenCalledTimes(1);
    const [name, runtime, args] = McpStdioServerDefinitionMock.mock
      .calls[0] as [string, string, string[]];
    expect(name).toBe("drmCopilotExtension");
    expect(runtime).toBe("node");
    expect(args[0]).toContain("mcp-server.js");
    // Callback must return the constructed definition.
    expect(results).toHaveLength(1);
  });

  it("assigns cwd when workspace is non-empty", async () => {
    // Arrange: simulate an open workspace folder so the cwd branch executes.
    const workspaceUri = { fsPath: "C:/workspace" };
    workspaceFoldersState = [{ uri: workspaceUri }];

    const context = createMockContext();

    registerMcpProvider(
      context as unknown as import("vscode").ExtensionContext,
    );

    // Act: invoke provideMcpServerDefinitions with the workspace populated.
    expect(capturedProvider).not.toBeNull();
    await capturedProvider!.provideMcpServerDefinitions();

    // Assert: the constructed server definition had cwd assigned to the
    // workspace URI.
    expect(mcpServerDefInstances).toHaveLength(1);
    expect(mcpServerDefInstances[0].cwd).toBe(workspaceUri);
  });

  it("returns the server argument unchanged from resolveMcpServerDefinition", async () => {
    // Arrange: create an arbitrary server object to pass through.
    const mockServer = { id: "test-server", name: "drmCopilotExtension" };
    const context = createMockContext();

    registerMcpProvider(
      context as unknown as import("vscode").ExtensionContext,
    );

    // Act: invoke the resolve callback.
    expect(capturedProvider).not.toBeNull();
    const resolved =
      await capturedProvider!.resolveMcpServerDefinition(mockServer);

    // Assert: identity — the same object is returned without modification.
    expect(resolved).toBe(mockServer);
  });
});
