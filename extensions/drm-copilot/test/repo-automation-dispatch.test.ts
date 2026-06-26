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
  getFreshChildProcessMock,
  getFreshFsMock,
  prepareFreshModulesWithPosixPathResolve,
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

function setFreshExecutablePresence(presence: {
  readonly python?: boolean;
  readonly py?: boolean;
  readonly pwsh?: boolean;
  readonly powershell?: boolean;
}): void {
  setExecutablePresenceOnFsMock(getFreshFsMock(), presence);
}

function createFreshRepoAutomationService(): typeof import("../src/repo-automation-service") {
  return jest.requireActual<typeof import("../src/repo-automation-service")>(
    "../src/repo-automation-service",
  );
}

function setExecutablePresence(presence: {
  readonly python?: boolean;
  readonly py?: boolean;
  readonly pwsh?: boolean;
  readonly powershell?: boolean;
}): void {
  setExecutablePresenceOnFsMock(fsMock, presence);
}

describe("repo automation dispatch", () => {
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

  it("collectPrContext runs in-process using the injected runner and filesystem", async () => {
    // Inject hermetic fakes so the in-process TS port (F9) runs without a Python
    // spawn; record the git cwd and the written artifact paths.
    const gitCwds: Array<string | undefined> = [];
    const writes = new Map<string, string>();
    const ensured: string[] = [];
    const service = createRepoAutomationService({
      extensionRoot: "C:/extension",
      output: { appendLine: appendLineMock },
      fileSystem: {
        glob: () => [],
        isFile: (p: string) => writes.has(p.replace(/\\/g, "/")),
        exists: (p: string) => p.replace(/\\/g, "/").endsWith("/.git"),
        isDirectory: () => false,
        listDirectory: () => [],
        readTextFile: () => "",
        writeTextFile: (p: string, c: string) =>
          void writes.set(p.replace(/\\/g, "/"), c),
        ensureDir: (d: string) => void ensured.push(d.replace(/\\/g, "/")),
      },
      runner: {
        run: (args: readonly string[], options?: { cwd?: string }) => {
          gitCwds.push(options?.cwd);
          // gh is unavailable in this hermetic test (auth fails); git resolves.
          if (args[0] === "gh" || String(args[0]).endsWith("gh")) {
            return { stdout: "", stderr: "offline", code: 1 };
          }
          return { stdout: "", stderr: "", code: 0 };
        },
      },
    });

    const result = await service.collectPrContext({
      workspaceRoot: "C:/workspace",
      invocationId: "collect_pr_context",
      base: "origin/main",
    });

    // Assert in-process behavior and the preserved service return contract.
    const summary = "C:/workspace/artifacts/pr_context.summary.txt";
    const appendix = "C:/workspace/artifacts/pr_context.appendix.txt";
    expect(childProcessMock.spawn).not.toHaveBeenCalled();
    expect(gitCwds.length).toBeGreaterThan(0);
    expect(writes.has("artifacts/pr_context.summary.txt")).toBe(true);
    expect(writes.has("artifacts/pr_context.appendix.txt")).toBe(true);
    expect(result.tool).toBe("collect_pr_context");
    expect(result.summary).toBe(
      "Collected PR context against base 'origin/main'.",
    );
    expect(result.artifacts).toEqual([summary, appendix]);
  });

  it("collectCommitContext runs in-process using the injected runner and filesystem", async () => {
    // Inject hermetic fakes so the in-process TS port runs without a Python
    // spawn; record the git cwd and the written artifact path.
    const gitCwds: Array<string | undefined> = [];
    const writes = new Map<string, string>();
    const ensured: string[] = [];
    const service = createRepoAutomationService({
      extensionRoot: "C:/extension",
      output: { appendLine: appendLineMock },
      fileSystem: {
        glob: () => [],
        isFile: () => false,
        readTextFile: () => "",
        writeTextFile: (p: string, c: string) =>
          void writes.set(p.replace(/\\/g, "/"), c),
        ensureDir: (d: string) => void ensured.push(d.replace(/\\/g, "/")),
      },
      runner: {
        run: (_args: readonly string[], options?: { cwd?: string }) => {
          gitCwds.push(options?.cwd);
          return { stdout: "value", stderr: "", code: 0 };
        },
      },
    });

    const result = await service.collectCommitContext({
      workspaceRoot: "C:/workspace",
      invocationId: "collect_commit_context",
    });

    // Assert in-process behavior and preserved service return contract.
    const artifact = "C:/workspace/artifacts/commit_context.txt";
    expect(gitCwds.length).toBeGreaterThan(0);
    expect(gitCwds.every((c) => c === "C:/workspace")).toBe(true);
    expect(writes.has(artifact)).toBe(true);
    expect(ensured).toContain("C:/workspace/artifacts");
    expect(childProcessMock.spawn).not.toHaveBeenCalled();
    expect(result.artifacts).toEqual([artifact]);
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

  it("newPotentialEntry preserves C:/extension on POSIX hosts", async () => {
    prepareFreshModulesWithPosixPathResolve();
    setFreshExecutablePresence({ pwsh: true });
    const freshChildProcessMock = getFreshChildProcessMock();
    freshChildProcessMock.spawn.mockReturnValue(createMockProcess(0));
    const freshModule = createFreshRepoAutomationService();
    const service = freshModule.createRepoAutomationService({
      extensionRoot: "C:/extension",
      output: { appendLine: appendLineMock },
    });

    try {
      await service.newPotentialEntry({
        workspaceRoot: "C:/workspace",
        invocationId: "new_potential_entry",
        shortName: "mcp-entry",
      });

      const [, args] = freshChildProcessMock.spawn.mock.calls[0] as [
        string,
        string[],
      ];
      expect(args[5].startsWith("C:/extension/resources/templates/")).toBe(
        true,
      );
    } finally {
      jest.dontMock("node:path");
      jest.resetModules();
    }
  });

  it("runPoshQCSuite uses the bundled extension wrapper and forwards selected scan folders", async () => {
    setExecutablePresence({ pwsh: true });
    childProcessMock.spawn.mockReturnValue(createMockProcess(0));
    const service = createRepoAutomationService({
      extensionRoot: "C:/extension",
      output: { appendLine: appendLineMock },
    });

    const result = await service.runPoshQCSuite({
      workspaceRoot: "C:/workspace",
      invocationId: "run_poshqc_suite",
      scanFolders: ["C:/workspace/src", "C:/workspace/tests/powershell"],
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
      "C:/extension/resources/templates/run-poshqc-suite.ps1",
      "-WorkspaceRoot",
      "C:/workspace",
      "-ScanFolders",
      "C:/workspace/src",
      "-ScanFolders",
      "C:/workspace/tests/powershell",
    ]);
    expect(options.cwd).toBe("C:/workspace");
    expect(options.shell).toBe(false);
    expect(result.summary).toContain("selected scan folder(s)");
  });

  it("runPoshQCFormat marshals multi-folder scan roots through one ScanFoldersJson argument", async () => {
    setExecutablePresence({ pwsh: true });
    childProcessMock.spawn.mockReturnValue(createMockProcess(0));
    const service = createRepoAutomationService({
      extensionRoot: "C:/extension",
      output: { appendLine: appendLineMock },
    });

    const result = await service.runPoshQCFormat({
      workspaceRoot: "C:/workspace",
      invocationId: "run_poshqc_format",
      scanFolders: [
        "C:/workspace/src",
        "C:/workspace/tests/powershell",
        "C:/workspace/tests/claude-runtime",
      ],
    });

    const [, args] = childProcessMock.spawn.mock.calls[0] as [string, string[]];
    expect(args).toEqual([
      "-NoLogo",
      "-NoProfile",
      "-ExecutionPolicy",
      "Bypass",
      "-File",
      "C:/extension/resources/templates/run-poshqc-format.ps1",
      "-WorkspaceRoot",
      "C:/workspace",
      "-ScanFoldersJson",
      JSON.stringify([
        "C:/workspace/src",
        "C:/workspace/tests/powershell",
        "C:/workspace/tests/claude-runtime",
      ]),
    ]);
    expect(result.summary).toContain("format");
  });

  it("runPoshQCAnalyze marshals multi-folder scan roots through one ScanFoldersJson argument", async () => {
    setExecutablePresence({ pwsh: true });
    childProcessMock.spawn.mockReturnValue(createMockProcess(0));
    const service = createRepoAutomationService({
      extensionRoot: "C:/extension",
      output: { appendLine: appendLineMock },
    });

    const result = await service.runPoshQCAnalyze({
      workspaceRoot: "C:/workspace",
      invocationId: "run_poshqc_analyze",
      scanFolders: [
        "C:/workspace/src",
        "C:/workspace/tests/powershell",
        "C:/workspace/tests/claude-runtime",
      ],
    });

    const [, args] = childProcessMock.spawn.mock.calls[0] as [string, string[]];
    expect(args).toEqual([
      "-NoLogo",
      "-NoProfile",
      "-ExecutionPolicy",
      "Bypass",
      "-File",
      "C:/extension/resources/templates/run-poshqc-analyze.ps1",
      "-WorkspaceRoot",
      "C:/workspace",
      "-ScanFoldersJson",
      JSON.stringify([
        "C:/workspace/src",
        "C:/workspace/tests/powershell",
        "C:/workspace/tests/claude-runtime",
      ]),
    ]);
    expect(result.summary).toContain("analyze");
  });

  it("runPoshQCTest marshals multi-folder scan roots through one ScanFoldersJson argument", async () => {
    setExecutablePresence({ pwsh: true });
    childProcessMock.spawn.mockReturnValue(createMockProcess(0));
    const service = createRepoAutomationService({
      extensionRoot: "C:/extension",
      output: { appendLine: appendLineMock },
    });

    const result = await service.runPoshQCTest({
      workspaceRoot: "C:/workspace",
      invocationId: "run_poshqc_test",
      scanFolders: [
        "C:/workspace/tests/claude-runtime",
        "C:/workspace/tests/claude-hooks",
      ],
    });

    const [, args] = childProcessMock.spawn.mock.calls[0] as [string, string[]];
    expect(args).toEqual([
      "-NoLogo",
      "-NoProfile",
      "-ExecutionPolicy",
      "Bypass",
      "-File",
      "C:/extension/resources/templates/run-poshqc-test.ps1",
      "-WorkspaceRoot",
      "C:/workspace",
      "-ScanFoldersJson",
      JSON.stringify([
        "C:/workspace/tests/claude-runtime",
        "C:/workspace/tests/claude-hooks",
      ]),
    ]);
    expect(result.summary).toContain("test");
  });

  it("runPoshQCAnalyzeAutofix uses the dedicated autofix wrapper", async () => {
    setExecutablePresence({ pwsh: true });
    childProcessMock.spawn.mockReturnValue(createMockProcess(0));
    const service = createRepoAutomationService({
      extensionRoot: "C:/extension",
      output: { appendLine: appendLineMock },
    });

    const result = await service.runPoshQCAnalyzeAutofix({
      workspaceRoot: "C:/workspace",
      invocationId: "run_poshqc_analyze_autofix",
      scanFolders: ["C:/workspace/src"],
    });

    const [, args] = childProcessMock.spawn.mock.calls[0] as [string, string[]];
    expect(args).toContain(
      "C:/extension/resources/templates/run-poshqc-analyze-autofix.ps1",
    );
    expect(args).not.toContain(
      "C:/extension/resources/templates/run-poshqc-suite.ps1",
    );
    expect(result.summary).toContain("autofix");
  });

  it("resolvePolicyAuditTemplateAsset returns the bundled source path without spawning a subprocess", async () => {
    setExecutablePresence({
      python: false,
      py: false,
      pwsh: false,
      powershell: false,
    });
    fsMock.existsSync.mockImplementation((filePath: string) => {
      const normalizedPath = filePath.replace(/\\/g, "/");
      return normalizedPath.endsWith(
        "/resources/templates/policy_audit/AGENTS.md",
      );
    });
    const service = createRepoAutomationService({
      extensionRoot: "C:/extension",
      output: { appendLine: appendLineMock },
    });

    const result = await service.resolvePolicyAuditTemplateAsset({
      workspaceRoot: "C:/workspace",
      invocationId: "resolve_policy_audit_template_asset",
      asset: "agents",
    });

    expect(childProcessMock.spawn).not.toHaveBeenCalled();
    expect(result).toMatchObject({
      tool: "resolve_policy_audit_template_asset",
      workspaceRoot: "C:/workspace",
      assetId: "policy_audit.agents",
      bundledSourcePath:
        "C:/extension/resources/templates/policy_audit/AGENTS.md",
      artifacts: ["C:/extension/resources/templates/policy_audit/AGENTS.md"],
    });
    expect(result.destinationPath).toBeUndefined();
  });

  it("resolvePolicyAuditTemplateAsset copies the bundled asset to a requested target path", async () => {
    fsMock.existsSync.mockImplementation((filePath: string) => {
      const normalizedPath = filePath.replace(/\\/g, "/");
      return normalizedPath.endsWith(
        "/resources/templates/policy_audit/feature-audit.yyyy-MM-ddTHH-mm.md",
      );
    });
    const service = createRepoAutomationService({
      extensionRoot: "C:/extension",
      output: { appendLine: appendLineMock },
    });

    const result = await service.resolvePolicyAuditTemplateAsset({
      workspaceRoot: "C:/workspace",
      invocationId: "resolve_policy_audit_template_asset",
      asset: "feature-audit-template",
      targetPath: "C:/workspace/docs/feature-audit.md",
    });

    expect(fsMock.mkdirSync).toHaveBeenCalledWith("C:/workspace/docs", {
      recursive: true,
    });
    expect(fsMock.copyFileSync).toHaveBeenCalledWith(
      "C:/extension/resources/templates/policy_audit/feature-audit.yyyy-MM-ddTHH-mm.md",
      "C:/workspace/docs/feature-audit.md",
    );
    expect(result).toMatchObject({
      assetId: "policy_audit.feature_audit_template",
      bundledSourcePath:
        "C:/extension/resources/templates/policy_audit/feature-audit.yyyy-MM-ddTHH-mm.md",
      destinationPath: "C:/workspace/docs/feature-audit.md",
      artifacts: [
        "C:/extension/resources/templates/policy_audit/feature-audit.yyyy-MM-ddTHH-mm.md",
        "C:/workspace/docs/feature-audit.md",
      ],
    });
  });
});
