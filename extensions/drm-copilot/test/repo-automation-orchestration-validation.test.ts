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

describe("repo automation orchestration validation", () => {
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

  it("validateOrchestrationArtifacts spawns the bundled validator with correct args", async () => {
    setExecutablePresence({ python: true });
    childProcessMock.spawn.mockReturnValue(createMockProcess(0));
    const service = createRepoAutomationService({
      extensionRoot: "C:/extension",
      output: { appendLine: appendLineMock },
    });

    const result = await service.validateOrchestrationArtifacts({
      workspaceRoot: "C:/workspace",
      invocationId: "validate_orchestration_artifacts",
      artifactType: "plan",
      artifactPath: "docs/plan.md",
      requireComplete: false,
    });

    const [executable, args] = childProcessMock.spawn.mock.calls[0] as [
      string,
      string[],
    ];
    expect(executable).toBe("python");
    expect(args[0]).toBe(
      "C:/extension/resources/templates/validate_orchestration_artifacts.py",
    );
    expect(args).toContain("plan");
    expect(args).toContain("docs/plan.md");
    expect(args).not.toContain("--require-complete");
    expect(result.tool).toBe("validate_orchestration_artifacts");
  });

  it("validateOrchestrationArtifacts passes --require-complete when requested", async () => {
    setExecutablePresence({ python: true });
    childProcessMock.spawn.mockReturnValue(createMockProcess(0));
    const service = createRepoAutomationService({
      extensionRoot: "C:/extension",
      output: { appendLine: appendLineMock },
    });

    await service.validateOrchestrationArtifacts({
      workspaceRoot: "C:/workspace",
      invocationId: "validate_orchestration_artifacts",
      artifactType: "policy-audit",
      artifactPath: "docs/policy-audit.md",
      requireComplete: true,
    });

    const [, args] = childProcessMock.spawn.mock.calls[0] as [string, string[]];
    expect(args).toContain("--require-complete");
    expect(args).toContain("policy-audit");
    expect(args).toContain("docs/policy-audit.md");
  });
});
