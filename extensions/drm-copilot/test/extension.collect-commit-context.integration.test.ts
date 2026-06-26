import { beforeEach, describe, expect, it, jest } from "@jest/globals";

type CommandHandler = () => Promise<void> | void;

const handlers = new Map<string, CommandHandler>();
const writtenFiles = new Map<string, string>();
const ensuredDirs: string[] = [];

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
      showInputBox: jest.fn(),
      showQuickPick: jest.fn(),
    },
    workspace: {
      get workspaceFolders() {
        return [{ uri: { fsPath: "C:/workspace" } }];
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

// Mock node:fs so the in-process port's RealFileSystem writes and directory
// creation are observable without touching the real filesystem. existsSync
// reports python/pwsh present so unrelated runtime probes during activation
// resolve successfully.
jest.mock("node:fs", () => ({
  existsSync: jest.fn(
    (filePath: string) =>
      String(filePath).toLowerCase().includes("python") ||
      String(filePath).toLowerCase().includes("pwsh"),
  ),
  writeFileSync: jest.fn((filePath: string, content: string) => {
    writtenFiles.set(String(filePath).replace(/\\/g, "/"), String(content));
  }),
  mkdirSync: jest.fn((dirPath: string) => {
    ensuredDirs.push(String(dirPath).replace(/\\/g, "/"));
  }),
}));

// Mock node:child_process so the in-process SubprocessRunner's spawnSync calls
// return per-git-args output. The legacy Python `spawn` path is also mocked so
// the test can assert it is NOT invoked for this command.
jest.mock("node:child_process", () => ({
  spawn: jest.fn(),
  spawnSync: jest.fn(),
}));

import { activate } from "../src/extension";

const childProcessMock = jest.requireMock("node:child_process") as {
  spawn: jest.Mock;
  spawnSync: jest.Mock;
};

/**
 * Configure spawnSync to return git output keyed by the joined argument list,
 * producing non-empty content for every section so all headers render. Staged
 * diffs return empty to exercise the `(no staged changes)` marker.
 */
function setGitOutput(): void {
  childProcessMock.spawnSync.mockImplementation(
    (_executable: string, args: ReadonlyArray<string>) => {
      const joined = args.join(" ");
      const toBuffer = (text: string): { status: number; stdout: Buffer } => ({
        status: 0,
        stdout: Buffer.from(text, "utf8"),
      });

      if (joined.includes("remote")) {
        return toBuffer("origin\thttps://example.com/repo.git (fetch)");
      }
      if (joined.includes("rev-parse") && joined.includes("HEAD")) {
        return toBuffer("main");
      }
      if (joined.includes("@{u}")) {
        return toBuffer("origin/main");
      }
      if (joined.includes("status")) {
        return toBuffer("## main...origin/main");
      }
      // Staged name-status and staged diff return empty to mark no staged
      // changes, mirroring the historical no-staged integration case.
      if (joined.includes("--cached")) {
        return toBuffer("");
      }
      if (joined.includes("diff") && joined.includes("--name-status")) {
        return toBuffer("M\tsrc/app.ts");
      }
      if (
        joined.includes("diff") &&
        joined.includes("HEAD") &&
        joined.includes("--stat")
      ) {
        return toBuffer("1 file changed");
      }
      if (
        joined.includes("diff") &&
        joined.includes("HEAD") &&
        joined.includes("--name-only")
      ) {
        return toBuffer("module.py");
      }
      if (joined.includes("ls-files")) {
        return toBuffer("untracked.txt");
      }
      if (joined.includes("diff")) {
        return toBuffer("diff --git a/src/app.ts b/src/app.ts");
      }
      if (joined.includes("log")) {
        return toBuffer(
          "abc123\nAuthor <a@example.com>\nMon Dec 18 2023\n" +
            "Committer <c@example.com>\nMon Dec 18 2023\n" +
            "feat: change\n\nbody",
        );
      }
      return toBuffer("");
    },
  );
}

function handlerFor(commandId: string): CommandHandler {
  const handler = handlers.get(commandId);
  if (!handler) {
    throw new Error(`Missing handler ${commandId}`);
  }
  return handler;
}

describe("collectCommitContext in-process integration behavior", () => {
  beforeEach(() => {
    handlers.clear();
    writtenFiles.clear();
    ensuredDirs.length = 0;
    childProcessMock.spawn.mockReset();
    childProcessMock.spawnSync.mockReset();
    setGitOutput();

    const context = {
      extensionUri: { fsPath: "C:/extension" },
      subscriptions: [] as Array<{ dispose(): void }>,
    };
    activate(context as never);
  });

  it("does not spawn the bundled Python script for collect_commit_context", async () => {
    // Act
    await handlerFor("drmCopilotExtension.collectCommitContext")();

    // Assert: the in-process path uses spawnSync, never the legacy `spawn` with
    // a `.py` script path.
    const spawnedPyScripts = childProcessMock.spawn.mock.calls.filter(
      (call: unknown[]) => {
        const args = call[1] as string[] | undefined;
        return (args ?? []).some((arg) =>
          arg.endsWith("/resources/templates/collect_commit_context.py"),
        );
      },
    );
    expect(spawnedPyScripts).toHaveLength(0);
    expect(childProcessMock.spawnSync).toHaveBeenCalled();
  });

  it("writes an artifact containing all required sections for staged changes", async () => {
    // Act
    await handlerFor("drmCopilotExtension.collectCommitContext")();

    // Assert: the artifact is written to the workspace artifacts path.
    const artifactPath = "C:/workspace/artifacts/commit_context.txt";
    const artifactText = writtenFiles.get(artifactPath);
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

    // Each required header must appear exactly once in the written artifact.
    for (const header of requiredHeaders) {
      const count = (artifactText?.split(header).length ?? 0) - 1;
      expect(count).toBe(1);
    }

    // The parent directory of the artifact is created before the write.
    expect(ensuredDirs).toContain("C:/workspace/artifacts");
  });

  it("marks no staged changes when staged diffs are empty", async () => {
    // Act
    await handlerFor("drmCopilotExtension.collectCommitContext")();

    // Assert
    const artifactText =
      writtenFiles.get("C:/workspace/artifacts/commit_context.txt") ?? "";
    expect(artifactText).toContain("===== Staged files (name-status) =====");
    expect(artifactText).toContain("(no staged changes)");
  });
});
