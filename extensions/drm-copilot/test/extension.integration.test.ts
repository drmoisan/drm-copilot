import { EventEmitter } from "node:events";
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
      filePath.toLowerCase().includes("pwsh") ||
      filePath.replace(/\\/g, "/").endsWith("/.git"),
  ),
  statSync: jest.fn(() => {
    throw new Error("ENOENT");
  }),
  readdirSync: jest.fn(() => []),
  readFileSync: jest.fn(() => {
    throw new Error("ENOENT");
  }),
  writeFileSync: jest.fn((filePath: string, content: string) => {
    inProcessWrites.set(filePath.replace(/\\/g, "/"), content);
  }),
  mkdirSync: jest.fn(),
}));

jest.mock("node:child_process", () => ({
  spawn: jest.fn(),
  spawnSync: jest.fn(),
}));

import { activate } from "../src/extension";

/** Files written through the mocked node:fs by an in-process collector run. */
const inProcessWrites = new Map<string, string>();

const fsMock = jest.requireMock("node:fs") as {
  existsSync: jest.MockedFunction<(filePath: string) => boolean>;
  statSync: jest.Mock;
  readdirSync: jest.Mock;
  readFileSync: jest.Mock;
  writeFileSync: jest.Mock;
  mkdirSync: jest.Mock;
};

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

function setExecutablePresence(presence: {
  readonly python?: boolean;
  readonly py?: boolean;
  readonly pwsh?: boolean;
}): void {
  fsMock.existsSync.mockImplementation((filePath: string) => {
    const lowerPath = filePath.toLowerCase();
    if (lowerPath.includes("python")) {
      return presence.python ?? false;
    }

    if (lowerPath.includes(`${"\\"}py.`) || lowerPath.endsWith("/py")) {
      return presence.py ?? false;
    }

    if (lowerPath.includes("pwsh")) {
      return presence.pwsh ?? false;
    }

    return false;
  });
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
    setExecutablePresence({ python: true, py: false, pwsh: true });
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

  // NOTE: The three `collectCommitContext` integration cases previously here
  // (bundled-resource Python spawn, staged-sections fixture, no-staged marker)
  // moved to `extension.collect-commit-context.integration.test.ts` when F4
  // ported the command to the in-process TS path. The original file already
  // exceeded the 500-line limit, so the reworked cases were extracted rather
  // than grown in place.

  it("collectPrContext runs the in-process collector without spawning Python", async () => {
    inProcessWrites.clear();

    await handlerFor("drmCopilotExtension.collectPrContext")();

    // The in-process port (F9) never spawns a Python process.
    expect(childProcessMock.spawn).not.toHaveBeenCalled();
    // Both artifacts are written through node:fs against the workspace root.
    expect(inProcessWrites.has("artifacts/pr_context.summary.txt")).toBe(true);
    expect(inProcessWrites.has("artifacts/pr_context.appendix.txt")).toBe(true);
  });

  it("collectPrContext handles workspace paths with spaces or unicode", async () => {
    inProcessWrites.clear();
    workspaceFoldersState = [
      {
        uri: {
          fsPath: "C:/workspace/Repo Δ with spaces",
        },
      },
    ];

    await handlerFor("drmCopilotExtension.collectPrContext")();

    expect(childProcessMock.spawn).not.toHaveBeenCalled();
    // The collector writes both artifacts (relative paths) without failing on
    // the unicode/space workspace path.
    expect(inProcessWrites.has("artifacts/pr_context.summary.txt")).toBe(true);
    expect(inProcessWrites.has("artifacts/pr_context.appendix.txt")).toBe(true);
  });

  it("collectPrContext writes summary and appendix artifacts in-process", async () => {
    inProcessWrites.clear();

    await handlerFor("drmCopilotExtension.collectPrContext")();

    expect(childProcessMock.spawn).not.toHaveBeenCalled();
    const summaryText =
      inProcessWrites.get("artifacts/pr_context.summary.txt") ?? "";
    const appendixText =
      inProcessWrites.get("artifacts/pr_context.appendix.txt") ?? "";
    // The summary carries the canonical PR-intent and base/head sections.
    expect(summaryText).toContain("===== PR Intent =====");
    expect(summaryText).toContain("===== Base/Head =====");
    // The appendix begins with the generated-timestamp section.
    expect(appendixText).toContain("===== Context generated =====");
  });

  // NOTE: The push-down copilot and codex/agents integration cases previously
  // here asserted a bundled-Python spawn (executable === "python", bundled
  // `resources/templates/push_down_*.py` path, py -3 fallback). F3 ported these
  // two commands to the in-process TS path, so they no longer spawn Python. The
  // in-process delegation and the preserved `tool`/`summary`/`artifacts`
  // contract are covered by the service-call unit suite
  // (`test/lib/push-down/push-down-service-call.test.ts`), mirroring the F4
  // `collectCommitContext` precedent that removed its Python-spawn integration
  // cases. The `potentialToIssue` command was likewise ported to the in-process
  // TS path (F7); its in-process behavior is covered by the
  // `test/lib/potential-to-issue/**` and `extension.potential-to-issue.test.ts`
  // suites. Unrelated spawn-based cases (PowerShell commands and the still-Python
  // `collect_pr_context` command) are unchanged below.

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

  it("linkParentChild runs the bundled PowerShell template against the active workspace root", async () => {
    showInputBoxMock.mockResolvedValueOnce("12").mockResolvedValueOnce("34");

    await handlerFor("drmCopilotExtension.linkParentChild")();

    const [executable, args, options] = childProcessMock.spawn.mock
      .calls[0] as [string, string[], { cwd: string }];
    const childIndex = args.indexOf("-ChildIssueNumber");
    const parentIndex = args.indexOf("-ParentIssueNumber");
    const fileIndex = args.indexOf("-File");

    expect(executable).toBe("pwsh");
    expect(fileIndex).toBeGreaterThan(-1);
    expect(args[fileIndex + 1]).toBe(
      "C:/extension/resources/templates/link-parent-child.ps1",
    );
    expect(childIndex).toBeGreaterThan(-1);
    expect(args[childIndex + 1]).toBe("12");
    expect(parentIndex).toBeGreaterThan(-1);
    expect(args[parentIndex + 1]).toBe("34");
    expect(options.cwd).toBe("C:/workspace");
    expect(
      args.some((arg) =>
        normalizePath(arg).includes("/scripts/dev-tools/link-parent-child.ps1"),
      ),
    ).toBe(false);
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
