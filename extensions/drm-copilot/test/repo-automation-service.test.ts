import { EventEmitter } from "node:events";
import {
  afterEach,
  beforeEach,
  describe,
  expect,
  it,
  jest,
} from "@jest/globals";

type MockChildProcess = EventEmitter & {
  stdout: EventEmitter;
  stderr: EventEmitter;
};

const appendLineMock = jest.fn<(line: string) => void>();

jest.mock("vscode", () => ({}), { virtual: true });

jest.mock("node:fs", () => ({
  existsSync: jest.fn(),
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

function createMockProcess(
  exitCode: number,
  stdoutText: string = "",
): MockChildProcess {
  const processMock = new EventEmitter() as MockChildProcess;
  processMock.stdout = new EventEmitter();
  processMock.stderr = new EventEmitter();
  process.nextTick(() => {
    if (stdoutText.length > 0) {
      processMock.stdout.emit("data", Buffer.from(stdoutText, "utf-8"));
    }

    processMock.emit("close", exitCode);
  });
  return processMock;
}

function setExecutablePresence(presence: {
  readonly python?: boolean;
  readonly pwsh?: boolean;
  readonly powershell?: boolean;
}): void {
  fsMock.existsSync.mockImplementation((filePath: string) => {
    const lowerPath = filePath.toLowerCase();
    if (lowerPath.includes("python")) {
      return presence.python ?? false;
    }

    if (lowerPath.includes("pwsh")) {
      return presence.pwsh ?? false;
    }

    if (lowerPath.includes("powershell")) {
      return presence.powershell ?? false;
    }

    return false;
  });
}

describe("repo automation service", () => {
  beforeEach(() => {
    process.env.PATH = "C:/bin";
    process.env.PATHEXT = ".EXE;.CMD";
    appendLineMock.mockReset();
    childProcessMock.spawn.mockReset();
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it("collectPrContext uses bundled extension resources for non-interactive execution", async () => {
    setExecutablePresence({ python: true });
    childProcessMock.spawn.mockReturnValue(createMockProcess(0));
    const service = createRepoAutomationService({
      extensionRoot: "C:/extension",
      output: { appendLine: appendLineMock },
    });

    const result = await service.collectPrContext({
      workspaceRoot: "C:/workspace",
      invocationId: "collect_pr_context",
      base: "origin/main",
    });

    const [executable, args, options] = childProcessMock.spawn.mock
      .calls[0] as [string, string[], { cwd: string; shell: boolean }];
    expect(executable).toBe("python");
    expect(args[0]).toBe(
      "C:/extension/resources/templates/collect_pr_context.py",
    );
    expect(args).toEqual(
      expect.arrayContaining([
        "--base",
        "origin/main",
        "--repo-root",
        "C:/workspace",
        "--out",
        "artifacts/pr_context.summary.txt",
        "--appendix-out",
        "artifacts/pr_context.appendix.txt",
      ]),
    );
    expect(options.cwd).toBe("C:/workspace");
    expect(options.shell).toBe(false);
    expect(result.artifacts).toEqual([
      "C:/workspace/artifacts/pr_context.summary.txt",
      "C:/workspace/artifacts/pr_context.appendix.txt",
    ]);
  });

  it("newPotentialEntry keeps subprocess execution argv-based with shell disabled", async () => {
    setExecutablePresence({ pwsh: true });
    childProcessMock.spawn.mockReturnValue(createMockProcess(0));
    const service = createRepoAutomationService({
      extensionRoot: "C:/extension",
      output: { appendLine: appendLineMock },
    });

    await service.newPotentialEntry({
      workspaceRoot: "C:/workspace",
      invocationId: "new_potential_entry",
      shortName: "mcp-entry",
    });

    const [executable, args, options] = childProcessMock.spawn.mock
      .calls[0] as [string, string[], { cwd: string; shell: boolean }];
    expect(executable).toBe("pwsh");
    expect(args).toEqual([
      "-NoLogo",
      "-NoProfile",
      "-ExecutionPolicy",
      "Bypass",
      "-File",
      "C:/extension/resources/templates/new-potential-entry.ps1",
      "-ShortName",
      "mcp-entry",
      "-TemplateRoot",
      "C:/extension/resources/feature-templates",
    ]);
    expect(options.cwd).toBe("C:/workspace");
    expect(options.shell).toBe(false);
  });
});
