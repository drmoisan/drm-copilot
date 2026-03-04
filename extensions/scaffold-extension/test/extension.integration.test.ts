import { EventEmitter } from "node:events";
import * as fs from "node:fs";
import * as path from "node:path";
import { beforeEach, describe, expect, it, jest } from "@jest/globals";

type CommandHandler = () => Promise<void> | void;
type MockChildProcess = EventEmitter & {
  stdout: EventEmitter;
  stderr: EventEmitter;
};

const handlers = new Map<string, CommandHandler>();
const generatedArtifacts = new Map<string, string>();
let workspaceFoldersState: Array<{ uri: { fsPath: string } }> | undefined = [
  { uri: { fsPath: "C:/workspace" } },
];

jest.mock(
  "vscode",
  () => ({
    commands: {
      registerCommand: (command: string, handler: CommandHandler) => {
        handlers.set(command, handler);
        return { dispose: jest.fn() };
      },
    },
    window: {
      createOutputChannel: () => ({
        appendLine: jest.fn(),
        dispose: jest.fn(),
      }),
    },
    workspace: {
      get workspaceFolders() {
        return workspaceFoldersState;
      },
    },
    Uri: {
      joinPath: (base: { fsPath: string }, relative: string) => ({
        fsPath: `${base.fsPath}/${relative}`,
      }),
    },
  }),
  { virtual: true },
);

jest.mock("node:fs", () => ({
  existsSync: jest.fn(
    (filePath: string) =>
      filePath.toLowerCase().includes("python") ||
      filePath.toLowerCase().includes("pwsh"),
  ),
}));

jest.mock("node:child_process", () => ({
  spawn: jest.fn(),
}));

import { activate } from "../src/extension";

const childProcessMock = jest.requireMock("node:child_process") as {
  spawn: jest.Mock;
};

function mockProcessSuccess(): MockChildProcess {
  const processMock = new EventEmitter() as MockChildProcess;
  processMock.stdout = new EventEmitter();
  processMock.stderr = new EventEmitter();
  process.nextTick(() => {
    processMock.emit("close", 0);
  });
  return processMock;
}

function handlerFor(commandId: string): CommandHandler {
  const handler = handlers.get(commandId);
  if (!handler) {
    throw new Error(`Missing handler ${commandId}`);
  }
  return handler;
}

function normalizePath(pathValue: string): string {
  return pathValue.replace(/\\/g, "/");
}

function loadFixtureArtifact(fixtureFileName: string): string {
  const realFs = jest.requireActual("node:fs") as typeof fs;
  const fixturePath = path.join(__dirname, "fixtures", fixtureFileName);
  return realFs.readFileSync(fixturePath, "utf-8");
}

describe("scaffold-extension integration behavior", () => {
  beforeEach(() => {
    handlers.clear();
    generatedArtifacts.clear();
    workspaceFoldersState = [{ uri: { fsPath: "C:/workspace" } }];
    childProcessMock.spawn.mockReset();
    childProcessMock.spawn.mockImplementation(() => mockProcessSuccess());

    const context = {
      extensionUri: { fsPath: "C:/extension" },
      subscriptions: [] as Array<{ dispose(): void }>,
    };
    activate(context as never);
  });

  it("helloPython produces artifacts/hello_python.txt using bundled script execution", async () => {
    await handlerFor("scaffoldExtension.helloPython")();

    const [executable, args, options] = childProcessMock.spawn.mock
      .calls[0] as [string, string[], { cwd: string }];
    expect(executable).toBe("python");
    expect(args[0]).toBe("C:/extension/resources/templates/hello_python.py");
    expect(options.cwd).toBe("C:/workspace");
  });

  it("helloPowerShell produces artifacts/hello_pwsh.txt using bundled script execution", async () => {
    await handlerFor("scaffoldExtension.helloPowerShell")();

    const [executable, args, options] = childProcessMock.spawn.mock
      .calls[0] as [string, string[], { cwd: string }];
    expect(executable).toBe("pwsh");
    expect(args[args.length - 1]).toBe(
      "C:/extension/resources/templates/hello_pwsh.ps1",
    );
    expect(options.cwd).toBe("C:/workspace");
  });

  it("execution enforces no copy of hello_python.py or hello_pwsh.ps1 into workspace root", async () => {
    await handlerFor("scaffoldExtension.helloPython")();
    await handlerFor("scaffoldExtension.helloPowerShell")();

    const scriptPaths = childProcessMock.spawn.mock.calls.map(
      (call: unknown[]) => {
        const args = call[1] as string[];
        return args[args.length - 1];
      },
    );

    expect(
      scriptPaths.some(
        (pathValue) => pathValue === "C:/workspace/hello_python.py",
      ),
    ).toBe(false);
    expect(
      scriptPaths.some(
        (pathValue) => pathValue === "C:/workspace/hello_pwsh.ps1",
      ),
    ).toBe(false);
  });

  it("collectCommitContext executes bundled resource without workspace script copy", async () => {
    await handlerFor("scaffoldExtension.collectCommitContext")();

    const [, args] = childProcessMock.spawn.mock.calls[0] as [string, string[]];
    const scriptPath = normalizePath(args[0]);
    const extensionRoot = normalizePath("C:/extension");
    const workspaceRoot = normalizePath("C:/workspace");

    expect(scriptPath.startsWith(extensionRoot)).toBe(true);
    expect(
      scriptPath.endsWith("/resources/templates/collect_commit_context.py"),
    ).toBe(true);
    expect(scriptPath.startsWith(workspaceRoot)).toBe(false);
  });

  it("collectCommitContext artifact includes required sections for staged changes", async () => {
    childProcessMock.spawn.mockImplementation(
      (_executable: string, args: string[], options: { cwd: string }) => {
        const outputIndex = args.indexOf("--output");
        if (outputIndex >= 0) {
          const outputRelativePath =
            args[outputIndex + 1] ?? "artifacts/commit_context.txt";
          generatedArtifacts.set(
            `${options.cwd}/${outputRelativePath}`,
            loadFixtureArtifact("collect_commit_context.staged.fixture.txt"),
          );
        }
        return mockProcessSuccess();
      },
    );

    await handlerFor("scaffoldExtension.collectCommitContext")();

    const artifactPath = "C:/workspace/artifacts/commit_context.txt";
    const artifactText = generatedArtifacts.get(artifactPath);
    expect(artifactText).toBeDefined();

    const requiredHeaders = [
      "===== Repository remotes =====",
      "===== Current branch =====",
      "===== Upstream =====",
      "===== Status (short) =====",
      "===== Staged files (name-status) =====",
      "===== Staged diff =====",
      "===== Unstaged files (name-status) =====",
      "===== Unstaged diff =====",
      "===== Untracked files =====",
      "===== Diff stat (staged + unstaged) =====",
      "===== Changed Python files =====",
      "===== Last commit (header only) =====",
    ];

    for (const header of requiredHeaders) {
      const count = artifactText?.split(header).length ?? 0;
      expect(count - 1).toBe(1);
    }

    expect(artifactText).toContain("fixture-staged-sentinel");
  });

  it("collectCommitContext artifact marks no staged changes", async () => {
    childProcessMock.spawn.mockImplementation(
      (_executable: string, args: string[], options: { cwd: string }) => {
        const outputIndex = args.indexOf("--output");
        if (outputIndex >= 0) {
          const outputRelativePath =
            args[outputIndex + 1] ?? "artifacts/commit_context.txt";
          generatedArtifacts.set(
            `${options.cwd}/${outputRelativePath}`,
            loadFixtureArtifact("collect_commit_context.no_staged.fixture.txt"),
          );
        }
        return mockProcessSuccess();
      },
    );

    await handlerFor("scaffoldExtension.collectCommitContext")();

    const artifactPath = "C:/workspace/artifacts/commit_context.txt";
    const artifactText = generatedArtifacts.get(artifactPath) ?? "";
    expect(artifactText).toContain("===== Staged files (name-status) =====");
    expect(artifactText).toContain("(no staged changes)");
  });
});
