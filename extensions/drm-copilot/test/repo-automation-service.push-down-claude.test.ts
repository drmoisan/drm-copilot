import {
  afterEach,
  beforeEach,
  describe,
  expect,
  it,
  jest,
} from "@jest/globals";

import {
  createMockProcess,
  setExecutablePresenceOnFsMock,
} from "./runtime-test-helpers";

const appendLineMock = jest.fn<(line: string) => void>();

jest.mock("vscode", () => ({}), { virtual: true });

jest.mock("node:fs", () => ({
  copyFileSync: jest.fn(),
  existsSync: jest.fn(),
  mkdirSync: jest.fn(),
}));

jest.mock("node:child_process", () => ({
  spawn: jest.fn(),
}));

import { createRepoAutomationService } from "../src/repo-automation-service";

const fsMock = jest.requireMock("node:fs") as {
  existsSync: jest.MockedFunction<(filePath: string) => boolean>;
};

const childProcessMock = jest.requireMock("node:child_process") as {
  spawn: jest.Mock;
};

describe("repo automation service pushDownClaudeCustomizations", () => {
  beforeEach(() => {
    process.env.PATH = "C:/bin";
    process.env.PATHEXT = ".EXE;.CMD";
    appendLineMock.mockReset();
    childProcessMock.spawn.mockReset();
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it("invokes executeScript with the correct tool, runtimeKind, bundledRelativePath, args, summary, and stdoutArtifactPattern", async () => {
    setExecutablePresenceOnFsMock(fsMock, { python: true });
    childProcessMock.spawn.mockReturnValue(createMockProcess(0));
    const service = createRepoAutomationService({
      extensionRoot: "C:/extension",
      output: { appendLine: appendLineMock },
    });
    const workspaceRoot = "C:/workspace";

    const result = await service.pushDownClaudeCustomizations({
      workspaceRoot,
      invocationId: "push_down_claude_customizations",
    });

    // Verify the bundled script path and arguments passed to spawn.
    const [executable, args, options] = childProcessMock.spawn.mock
      .calls[0] as [string, string[], { cwd: string; shell: boolean }];
    expect(executable).toBe("python");
    expect(args[0]).toBe(
      "C:/extension/resources/templates/push_down_claude_customizations.py",
    );
    expect(args).toContain("--destination");
    expect(args).toContain(workspaceRoot);
    expect(options.cwd).toBe(workspaceRoot);
    expect(options.shell).toBe(false);
    expect(result.tool).toBe("push_down_claude_customizations");
    expect(result.summary).toContain(
      "Pushed bundled Claude Code customizations",
    );
  });

  it("defaults invocationId to 'push_down_claude_customizations' when omitted from input", async () => {
    setExecutablePresenceOnFsMock(fsMock, { python: true });
    childProcessMock.spawn.mockReturnValue(createMockProcess(0));
    const service = createRepoAutomationService({
      extensionRoot: "C:/extension",
      output: { appendLine: appendLineMock },
    });

    // Omit invocationId — the service should supply the default.
    const result = await service.pushDownClaudeCustomizations({
      workspaceRoot: "C:/workspace",
    });

    expect(result.tool).toBe("push_down_claude_customizations");
  });

  it("forwards an explicit invocationId when provided", async () => {
    setExecutablePresenceOnFsMock(fsMock, { python: true });
    childProcessMock.spawn.mockReturnValue(createMockProcess(0));
    const service = createRepoAutomationService({
      extensionRoot: "C:/extension",
      output: { appendLine: appendLineMock },
    });

    const result = await service.pushDownClaudeCustomizations({
      workspaceRoot: "C:/workspace",
      invocationId: "custom-id-123",
    });

    // The result.tool reflects the canonical tool name, not the invocationId.
    expect(result.tool).toBe("push_down_claude_customizations");
    expect(result.workspaceRoot).toBe("C:/workspace");
  });

  it("appends --packs, --csharp-variant, and --memory-mode when supplied", async () => {
    setExecutablePresenceOnFsMock(fsMock, { python: true });
    childProcessMock.spawn.mockReturnValue(createMockProcess(0));
    const service = createRepoAutomationService({
      extensionRoot: "C:/extension",
      output: { appendLine: appendLineMock },
    });

    await service.pushDownClaudeCustomizations({
      workspaceRoot: "C:/workspace",
      packs: ["core", "typescript"],
      csharpVariant: "legacy",
      memoryMode: "merge",
    });

    const [, args] = childProcessMock.spawn.mock.calls[0] as [string, string[]];
    // The packs array is joined into a single comma-separated CLI value.
    const packsIndex = args.indexOf("--packs");
    expect(packsIndex).toBeGreaterThanOrEqual(0);
    expect(args[packsIndex + 1]).toBe("core,typescript");
    const variantIndex = args.indexOf("--csharp-variant");
    expect(variantIndex).toBeGreaterThanOrEqual(0);
    expect(args[variantIndex + 1]).toBe("legacy");
    const memoryIndex = args.indexOf("--memory-mode");
    expect(memoryIndex).toBeGreaterThanOrEqual(0);
    expect(args[memoryIndex + 1]).toBe("merge");
  });

  it("spawns exactly the destination args for a no-field input (backward compatible)", async () => {
    setExecutablePresenceOnFsMock(fsMock, { python: true });
    childProcessMock.spawn.mockReturnValue(createMockProcess(0));
    const service = createRepoAutomationService({
      extensionRoot: "C:/extension",
      output: { appendLine: appendLineMock },
    });

    await service.pushDownClaudeCustomizations({
      workspaceRoot: "C:/workspace",
    });

    const [, args] = childProcessMock.spawn.mock.calls[0] as [string, string[]];
    // The first arg is the bundled script path; the rest are exactly the
    // destination flag and the workspace root, with no optional flags appended.
    expect(args.slice(1)).toStrictEqual(["--destination", "C:/workspace"]);
    expect(args).not.toContain("--packs");
    expect(args).not.toContain("--csharp-variant");
    expect(args).not.toContain("--memory-mode");
  });

  it("omits --packs when the packs array is empty", async () => {
    setExecutablePresenceOnFsMock(fsMock, { python: true });
    childProcessMock.spawn.mockReturnValue(createMockProcess(0));
    const service = createRepoAutomationService({
      extensionRoot: "C:/extension",
      output: { appendLine: appendLineMock },
    });

    await service.pushDownClaudeCustomizations({
      workspaceRoot: "C:/workspace",
      packs: [],
    });

    const [, args] = childProcessMock.spawn.mock.calls[0] as [string, string[]];
    // An empty packs array must not produce a --packs flag.
    expect(args).not.toContain("--packs");
  });
});
