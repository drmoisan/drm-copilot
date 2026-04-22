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
  copyFileSync: jest.MockedFunction<
    (source: string, destination: string) => void
  >;
  existsSync: jest.MockedFunction<(filePath: string) => boolean>;
  mkdirSync: jest.MockedFunction<
    (filePath: string, options?: { recursive?: boolean }) => void
  >;
};

const childProcessMock = jest.requireMock("node:child_process") as {
  spawn: jest.Mock;
};

function setExecutablePresence(presence: {
  readonly python?: boolean;
  readonly py?: boolean;
  readonly pwsh?: boolean;
  readonly powershell?: boolean;
}): void {
  setExecutablePresenceOnFsMock(fsMock, presence);
}

describe("repo automation hard-lock prompt resolution", () => {
  beforeEach(() => {
    process.env.PATH = "C:/bin";
    process.env.PATHEXT = ".EXE;.CMD";
    appendLineMock.mockReset();
    childProcessMock.spawn.mockReset();
    fsMock.copyFileSync.mockReset();
    fsMock.mkdirSync.mockReset();
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it("resolveExecuteHardLockPrompt without output or quiet produces only --target and --workspace args and no artifacts", async () => {
    setExecutablePresence({ python: true });
    childProcessMock.spawn.mockReturnValue(createMockProcess(0));
    const service = createRepoAutomationService({
      extensionRoot: "C:/extension",
      output: { appendLine: appendLineMock },
    });

    const result = await service.resolveExecuteHardLockPrompt({
      workspaceRoot: "C:/workspace",
      invocationId: "resolve_execute_hard_lock_prompt",
      target: "C:/workspace/docs/features/active/feature-123/plan.md",
    });

    const [executable, args] = childProcessMock.spawn.mock.calls[0] as [
      string,
      string[],
    ];
    expect(executable).toBe("python");
    expect(args[0]).toBe(
      "C:/extension/resources/templates/resolve_hard_lock_prompt.py",
    );
    expect(args).toEqual([
      "C:/extension/resources/templates/resolve_hard_lock_prompt.py",
      "--target",
      "C:/workspace/docs/features/active/feature-123/plan.md",
      "--workspace",
      "C:/workspace",
    ]);
    expect(args).not.toContain("--output");
    expect(args).not.toContain("--quiet");
    expect(result.artifacts).toBeUndefined();
  });

  it("resolveExecuteHardLockPrompt with output appends --output and returns the absolute artifact path", async () => {
    setExecutablePresence({ python: true });
    childProcessMock.spawn.mockReturnValue(createMockProcess(0));
    const service = createRepoAutomationService({
      extensionRoot: "C:/extension",
      output: { appendLine: appendLineMock },
    });

    const result = await service.resolveExecuteHardLockPrompt({
      workspaceRoot: "C:/workspace",
      invocationId: "resolve_execute_hard_lock_prompt",
      target: "C:/workspace/docs/features/active/feature-123/plan.md",
      output: "artifacts/hard_lock_prompt.txt",
    });

    const [, args] = childProcessMock.spawn.mock.calls[0] as [string, string[]];
    expect(args).toEqual(
      expect.arrayContaining([
        "--target",
        "C:/workspace/docs/features/active/feature-123/plan.md",
        "--workspace",
        "C:/workspace",
        "--output",
        "artifacts/hard_lock_prompt.txt",
      ]),
    );
    expect(args).not.toContain("--quiet");
    expect(result.artifacts).toEqual([
      "C:/workspace/artifacts/hard_lock_prompt.txt",
    ]);
  });

  it("resolveExecuteHardLockPrompt with output and quiet appends both flags and returns the artifact path", async () => {
    setExecutablePresence({ python: true });
    childProcessMock.spawn.mockReturnValue(createMockProcess(0));
    const service = createRepoAutomationService({
      extensionRoot: "C:/extension",
      output: { appendLine: appendLineMock },
    });

    const result = await service.resolveExecuteHardLockPrompt({
      workspaceRoot: "C:/workspace",
      invocationId: "resolve_execute_hard_lock_prompt",
      target: "C:/workspace/docs/features/active/feature-123/plan.md",
      output: "artifacts/hard_lock_prompt.txt",
      quiet: true,
    });

    const [, args] = childProcessMock.spawn.mock.calls[0] as [string, string[]];
    expect(args).toEqual(
      expect.arrayContaining([
        "--target",
        "C:/workspace/docs/features/active/feature-123/plan.md",
        "--workspace",
        "C:/workspace",
        "--output",
        "artifacts/hard_lock_prompt.txt",
        "--quiet",
      ]),
    );
    expect(result.artifacts).toEqual([
      "C:/workspace/artifacts/hard_lock_prompt.txt",
    ]);
  });

  it("resolveExecuteHardLockPrompt with an absolute output path uses it directly in artifacts", async () => {
    setExecutablePresence({ python: true });
    childProcessMock.spawn.mockReturnValue(createMockProcess(0));
    const service = createRepoAutomationService({
      extensionRoot: "C:/extension",
      output: { appendLine: appendLineMock },
    });

    const result = await service.resolveExecuteHardLockPrompt({
      workspaceRoot: "C:/workspace",
      invocationId: "resolve_execute_hard_lock_prompt",
      target: "C:/workspace/docs/features/active/feature-123/plan.md",
      output: "C:/absolute/hard_lock_prompt.txt",
      quiet: true,
    });

    const [, args] = childProcessMock.spawn.mock.calls[0] as [string, string[]];
    expect(args).toEqual(
      expect.arrayContaining([
        "--output",
        "C:/absolute/hard_lock_prompt.txt",
        "--quiet",
      ]),
    );
    expect(result.artifacts).toEqual(["C:/absolute/hard_lock_prompt.txt"]);
  });

  it("resolveExecuteHardLockPrompt rejects quiet without output at the TS layer", async () => {
    setExecutablePresence({ python: true });
    const service = createRepoAutomationService({
      extensionRoot: "C:/extension",
      output: { appendLine: appendLineMock },
    });

    await expect(
      service.resolveExecuteHardLockPrompt({
        workspaceRoot: "C:/workspace",
        invocationId: "resolve_execute_hard_lock_prompt",
        target: "C:/workspace/docs/features/active/feature-123/plan.md",
        quiet: true,
      }),
    ).rejects.toThrow(
      "resolve_execute_hard_lock_prompt: 'quiet' requires 'output' to be set.",
    );

    expect(childProcessMock.spawn).not.toHaveBeenCalled();
  });
});
