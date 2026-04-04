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
const showQuickPickMock = jest.fn();
const showInputBoxMock = jest.fn();
let workspaceFoldersState: Array<{ uri: { fsPath: string } }> | undefined = [
  { uri: { fsPath: "C:/workspace" } },
];
let quickPickResultLabel: string | undefined = "origin/main";

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
      showInputBox: showInputBoxMock,
      showQuickPick: showQuickPickMock,
    },
    workspace: {
      get workspaceFolders() {
        return workspaceFoldersState;
      },
    },
    Uri: {
      joinPath: (base: { fsPath: string }, ...segments: string[]) => ({
        fsPath: `${base.fsPath}/${segments.join("/")}`,
      }),
    },
    lm: {
      registerMcpServerDefinitionProvider: jest.fn(() => ({
        dispose: jest.fn(),
      })),
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
  existsSync: jest.fn(
    (filePath: string) =>
      filePath.toLowerCase().includes("python") ||
      filePath.toLowerCase().includes("pwsh"),
  ),
}));

jest.mock("node:child_process", () => ({
  spawn: jest.fn(),
  spawnSync: jest.fn(),
}));

import { activate } from "../src/extension";

const childProcessMock = jest.requireMock("node:child_process") as {
  spawn: jest.Mock;
  spawnSync: jest.Mock;
};

function setGitBranchDiscoveryState(input: {
  readonly originHead?: string;
  readonly remoteRefs?: ReadonlyArray<string>;
  readonly localRefs?: ReadonlyArray<string>;
}): void {
  const originHead = input.originHead ?? "origin/main";
  const remoteRefs = input.remoteRefs ?? ["origin/HEAD", "origin/main"];
  const localRefs = input.localRefs ?? ["main"];

  childProcessMock.spawnSync.mockImplementation(
    (_executable: string, args: ReadonlyArray<string>) => {
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
    },
  );

  showQuickPickMock.mockImplementation(
    async (items: ReadonlyArray<{ label: string }>) => {
      if (!quickPickResultLabel) {
        return undefined;
      }

      return (
        items.find((item) => item.label === quickPickResultLabel) ?? items[0]
      );
    },
  );
}

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

function isPlaceholderOnlyArtifact(text: string, heading: string): boolean {
  const meaningfulLines = text
    .split(/\r?\n/)
    .map((line) => line.trim())
    .filter((line) => line.length > 0);
  if (meaningfulLines.length === 0) {
    return true;
  }

  return meaningfulLines.every(
    (line) => line === heading || line.startsWith("Base ref"),
  );
}

describe("drm-copilot integration behavior", () => {
  beforeEach(() => {
    handlers.clear();
    generatedArtifacts.clear();
    workspaceFoldersState = [{ uri: { fsPath: "C:/workspace" } }];
    quickPickResultLabel = "origin/main";
    showInputBoxMock.mockReset();
    childProcessMock.spawn.mockReset();
    childProcessMock.spawnSync.mockReset();
    showQuickPickMock.mockReset();
    setGitBranchDiscoveryState({
      originHead: "origin/main",
      remoteRefs: ["origin/HEAD", "origin/main", "origin/develop"],
      localRefs: ["main"],
    });
    childProcessMock.spawn.mockImplementation(() => mockProcessSuccess());

    const context = {
      extensionUri: { fsPath: "C:/extension" },
      subscriptions: [] as Array<{ dispose(): void }>,
    };
    activate(context as never);
  });

  it("helloPython produces artifacts/hello_python.txt using bundled script execution", async () => {
    await handlerFor("drmCopilotExtension.helloPython")();

    const [executable, args, options] = childProcessMock.spawn.mock
      .calls[0] as [string, string[], { cwd: string }];
    expect(executable).toBe("python");
    expect(args[0]).toBe("C:/extension/resources/templates/hello_python.py");
    expect(options.cwd).toBe("C:/workspace");
  });

  it("helloPowerShell produces artifacts/hello_pwsh.txt using bundled script execution", async () => {
    await handlerFor("drmCopilotExtension.helloPowerShell")();

    const [executable, args, options] = childProcessMock.spawn.mock
      .calls[0] as [string, string[], { cwd: string }];
    expect(executable).toBe("pwsh");
    expect(args[args.length - 1]).toBe(
      "C:/extension/resources/templates/hello_pwsh.ps1",
    );
    expect(options.cwd).toBe("C:/workspace");
  });

  it("execution enforces no copy of hello_python.py or hello_pwsh.ps1 into workspace root", async () => {
    await handlerFor("drmCopilotExtension.helloPython")();
    await handlerFor("drmCopilotExtension.helloPowerShell")();

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
    await handlerFor("drmCopilotExtension.collectCommitContext")();

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

    await handlerFor("drmCopilotExtension.collectCommitContext")();

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

    await handlerFor("drmCopilotExtension.collectCommitContext")();

    const artifactPath = "C:/workspace/artifacts/commit_context.txt";
    const artifactText = generatedArtifacts.get(artifactPath) ?? "";
    expect(artifactText).toContain("===== Staged files (name-status) =====");
    expect(artifactText).toContain("(no staged changes)");
  });

  it("collectPrContext executes bundled wrapper script in destination workspace", async () => {
    await handlerFor("drmCopilotExtension.collectPrContext")();

    const [, args, options] = childProcessMock.spawn.mock.calls[0] as [
      string,
      string[],
      { cwd: string },
    ];
    expect(args[0]).toBe(
      "C:/extension/resources/templates/collect_pr_context.py",
    );
    expect(args).toContain("--base");
    expect(args).toContain("--repo-root");
    expect(args).toContain("C:/workspace");
    expect(options.cwd).toBe("C:/workspace");
  });

  it("collectPrContext handles workspace paths with spaces or unicode", async () => {
    workspaceFoldersState = [
      {
        uri: {
          fsPath: "C:/workspace/Repo Δ with spaces",
        },
      },
    ];

    await handlerFor("drmCopilotExtension.collectPrContext")();

    const [, args, options] = childProcessMock.spawn.mock.calls[0] as [
      string,
      string[],
      { cwd: string },
    ];
    expect(options.cwd).toBe("C:/workspace/Repo Δ with spaces");
    const repoRootIndex = args.indexOf("--repo-root");
    expect(repoRootIndex).toBeGreaterThan(-1);
    expect(args[repoRootIndex + 1]).toBe("C:/workspace/Repo Δ with spaces");
    expect(args).toContain("--out");
    expect(args).toContain("artifacts/pr_context.summary.txt");
    expect(args).toContain("--appendix-out");
    expect(args).toContain("artifacts/pr_context.appendix.txt");
  });

  it("collectPrContext writes summary and appendix artifacts", async () => {
    childProcessMock.spawn.mockImplementation(
      (_executable: string, args: string[], options: { cwd: string }) => {
        const summaryIndex = args.indexOf("--out");
        const appendixIndex = args.indexOf("--appendix-out");
        const summaryRelativePath =
          summaryIndex >= 0
            ? (args[summaryIndex + 1] ?? "artifacts/pr_context.summary.txt")
            : "artifacts/pr_context.summary.txt";
        const appendixRelativePath =
          appendixIndex >= 0
            ? (args[appendixIndex + 1] ?? "artifacts/pr_context.appendix.txt")
            : "artifacts/pr_context.appendix.txt";

        generatedArtifacts.set(
          `${options.cwd}/${summaryRelativePath}`,
          [
            "===== PR Intent =====",
            "Primary outcome:",
            "User/dev impact:",
            "",
            "===== Base/Head =====",
            "Base ref (requested): origin/main",
            "",
            "===== Changed files (name-status) =====",
            "M\textensions/drm-copilot/resources/templates/collect_pr_context.py",
            "",
          ].join("\n"),
        );
        generatedArtifacts.set(
          `${options.cwd}/${appendixRelativePath}`,
          [
            "===== Comparison metadata =====",
            "Base ref: origin/main",
            "",
            "===== Numstat =====",
            "12\t3\textensions/drm-copilot/resources/templates/collect_pr_context.py",
            "",
          ].join("\n"),
        );

        return mockProcessSuccess();
      },
    );

    await handlerFor("drmCopilotExtension.collectPrContext")();

    expect(
      generatedArtifacts.has("C:/workspace/artifacts/pr_context.summary.txt"),
    ).toBe(true);
    expect(
      generatedArtifacts.has("C:/workspace/artifacts/pr_context.appendix.txt"),
    ).toBe(true);

    const summaryText =
      generatedArtifacts.get("C:/workspace/artifacts/pr_context.summary.txt") ??
      "";
    const appendixText =
      generatedArtifacts.get(
        "C:/workspace/artifacts/pr_context.appendix.txt",
      ) ?? "";
    expect(summaryText).toContain("===== PR Intent =====");
    expect(summaryText).toContain("===== Base/Head =====");
    expect(summaryText).toContain("===== Changed files (name-status) =====");
    expect(appendixText).toContain("===== Comparison metadata =====");
    expect(appendixText).toContain("===== Numstat =====");
    expect(
      isPlaceholderOnlyArtifact(summaryText, "===== PR Intent ====="),
    ).toBe(false);
    expect(
      isPlaceholderOnlyArtifact(
        appendixText,
        "===== Comparison metadata =====",
      ),
    ).toBe(false);
  });

  it("pushDownCopilotCustomizations executes bundled wrapper script in workspace", async () => {
    await handlerFor("drmCopilotExtension.pushDownCopilotCustomizations")();

    const [executable, args, options] = childProcessMock.spawn.mock
      .calls[0] as [string, string[], { cwd: string }];
    expect(executable).toBe("python");
    expect(
      normalizePath(args[0]).endsWith(
        "resources/templates/push_down_copilot_customizations.py",
      ),
    ).toBe(true);
    expect(options.cwd).toBe("C:/workspace");
  });

  it("pushDownCopilotCustomizations passes workspace root as --destination", async () => {
    await handlerFor("drmCopilotExtension.pushDownCopilotCustomizations")();

    const [, args] = childProcessMock.spawn.mock.calls[0] as [string, string[]];
    const destinationIndex = args.indexOf("--destination");
    expect(destinationIndex).toBeGreaterThan(-1);
    expect(args[destinationIndex + 1]).toBe("C:/workspace");
  });

  it("syncAgentsFromInstructions runs the bundled PowerShell template against the active workspace root", async () => {
    await handlerFor("drmCopilotExtension.syncAgentsFromInstructions")();

    const [executable, args, options] = childProcessMock.spawn.mock
      .calls[0] as [string, string[], { cwd: string }];
    const repoRootIndex = args.indexOf("-RepoRoot");
    const fileIndex = args.indexOf("-File");

    expect(executable).toBe("pwsh");
    expect(fileIndex).toBeGreaterThan(-1);
    expect(args[fileIndex + 1]).toBe(
      "C:/extension/resources/templates/sync-agents-from-instructions.ps1",
    );
    expect(repoRootIndex).toBeGreaterThan(-1);
    expect(args[repoRootIndex + 1]).toBe("C:/workspace");
    expect(options.cwd).toBe("C:/workspace");
  });

  it("newPotentialEntry succeeds in a workspace without docs/features/templates using bundled templates", async () => {
    const templateLessWorkspacePath = "C:/workspace/template-less";
    workspaceFoldersState = [
      {
        uri: {
          fsPath: templateLessWorkspacePath,
        },
      },
    ];
    showInputBoxMock.mockResolvedValue("template-less-entry");

    await handlerFor("drmCopilotExtension.newPotentialEntry")();

    const [executable, args, options] = childProcessMock.spawn.mock
      .calls[0] as [string, string[], { cwd: string }];
    const templateRootIndex = args.indexOf("-TemplateRoot");
    const scriptPath = args[args.indexOf("-File") + 1] ?? "";

    expect(executable).toBe("pwsh");
    expect(templateRootIndex).toBeGreaterThan(-1);
    expect(args[templateRootIndex + 1]).toBe(
      "C:/extension/resources/feature-templates",
    );
    expect(
      normalizePath(scriptPath).endsWith(
        "resources/templates/new-potential-entry.ps1",
      ),
    ).toBe(true);
    expect(options.cwd).toBe(templateLessWorkspacePath);
    expect(
      args.some((arg) =>
        normalizePath(arg).includes("/docs/features/templates/"),
      ),
    ).toBe(false);
  });
});
