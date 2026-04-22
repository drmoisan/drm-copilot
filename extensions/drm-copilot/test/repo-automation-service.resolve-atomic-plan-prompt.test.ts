import { beforeEach, describe, expect, it, jest } from "@jest/globals";

import {
  createMockProcess,
  createMockProcessWithStderr,
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

describe("repo automation service resolveAtomicPlanPrompt", () => {
  beforeEach(() => {
    process.env.PATH = "C:/bin";
    process.env.PATHEXT = ".EXE;.CMD";
    appendLineMock.mockReset();
    childProcessMock.spawn.mockReset();
  });

  it("uses the bundled wrapper with target and workspace arguments", async () => {
    setExecutablePresenceOnFsMock(fsMock, { python: true });
    childProcessMock.spawn.mockReturnValue(createMockProcess(0));
    const service = createRepoAutomationService({
      extensionRoot: "C:/extension",
      output: { appendLine: appendLineMock },
    });

    const result = await service.resolveAtomicPlanPrompt({
      workspaceRoot: "C:/workspace",
      invocationId: "resolve_atomic_plan_prompt",
      target:
        "C:/workspace/docs/features/active/feature-152/plan.2026-04-17T19-54.md",
    });

    const [executable, args, options] = childProcessMock.spawn.mock
      .calls[0] as [string, string[], { cwd: string; shell: boolean }];
    expect(executable).toBe("python");
    expect(args).toEqual([
      "C:/extension/resources/templates/resolve_atomic_plan_prompt.py",
      "--target",
      "C:/workspace/docs/features/active/feature-152/plan.2026-04-17T19-54.md",
      "--workspace",
      "C:/workspace",
    ]);
    expect(options.cwd).toBe("C:/workspace");
    expect(options.shell).toBe(false);
    expect(result.tool).toBe("resolve_atomic_plan_prompt");
    expect(result.summary).toContain(
      "C:/workspace/docs/features/active/feature-152/plan.2026-04-17T19-54.md",
    );
  });

  it("preserves bundled-wrapper stderr when execution fails", async () => {
    setExecutablePresenceOnFsMock(fsMock, { python: true });
    childProcessMock.spawn.mockReturnValue(
      createMockProcessWithStderr(
        2,
        "resolve_atomic_plan_prompt.py: error: unrecognized arguments: --workspace C:/workspace",
      ),
    );
    const service = createRepoAutomationService({
      extensionRoot: "C:/extension",
      output: { appendLine: appendLineMock },
    });

    await expect(
      service.resolveAtomicPlanPrompt({
        workspaceRoot: "C:/workspace",
        invocationId: "resolve_atomic_plan_prompt",
        target:
          "C:/workspace/docs/features/active/feature-152/plan.2026-04-17T19-54.md",
      }),
    ).rejects.toThrow("Command exited with code 2");
    expect(
      appendLineMock.mock.calls.some(([line]) =>
        line.includes("unrecognized arguments: --workspace C:/workspace"),
      ),
    ).toBe(true);
  });
});
