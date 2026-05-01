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

describe("repo automation service runCodexNativeConverter", () => {
  beforeEach(() => {
    process.env.PATH = "C:/bin";
    process.env.PATHEXT = ".EXE;.CMD";
    appendLineMock.mockReset();
    childProcessMock.spawn.mockReset();
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it("builds bundled codex-native-converter argv and summary", async () => {
    setExecutablePresenceOnFsMock(fsMock, { python: true });
    childProcessMock.spawn.mockReturnValue(createMockProcess(0));

    const service = createRepoAutomationService({
      extensionRoot: "C:/extension",
      output: { appendLine: appendLineMock },
    });

    const result = await service.runCodexNativeConverter({
      workspaceRoot: "C:/workspace",
      invocationId: "run_codex_native_converter",
      mode: "apply",
      sourceEcosystem: "github-copilot",
      sourceRoot: "C:/workspace/source",
      selectedPaths: [
        "C:/workspace/source/.github",
        "C:/workspace/source/AGENTS.md",
      ],
      destinationRoot: "C:/workspace/destination",
      artifactRoot: "C:/workspace/artifacts/codex-native-converter",
      enableRepoPrompts: true,
    });

    const [executable, args, options] = childProcessMock.spawn.mock
      .calls[0] as [string, string[], { cwd: string; shell: boolean }];
    expect(executable).toBe("python");
    expect(args[0]).toBe(
      "C:/extension/resources/templates/codex_native_converter.py",
    );
    expect(args.slice(1)).toEqual([
      "apply",
      "--source-root",
      "C:/workspace/source",
      "--source-ecosystem",
      "github-copilot",
      "--destination-root",
      "C:/workspace/destination",
      "--artifact-root",
      "C:/workspace/artifacts/codex-native-converter",
      "--enable-repo-prompts",
      "--selected-path",
      "C:/workspace/source/.github",
      "--selected-path",
      "C:/workspace/source/AGENTS.md",
    ]);
    expect(options).toEqual({
      cwd: "C:/workspace",
      shell: false,
      stdio: ["ignore", "pipe", "pipe"],
    });
    expect(result.summary).toContain(
      "Ran bundled codex-native-converter in apply mode",
    );
  });

  it("returns the artifact path parsed from codex-native-converter stdout", async () => {
    setExecutablePresenceOnFsMock(fsMock, { python: true });
    childProcessMock.spawn.mockReturnValue(
      createMockProcess(
        0,
        "Artifact root: C:/workspace/artifacts/codex-native-converter\nValidation outcome: pass\n",
      ),
    );

    const service = createRepoAutomationService({
      extensionRoot: "C:/extension",
      output: { appendLine: appendLineMock },
    });

    const result = await service.runCodexNativeConverter({
      workspaceRoot: "C:/workspace",
      mode: "review",
      sourceEcosystem: "claude",
      sourceRoot: "C:/workspace/source",
    });

    expect(result.artifacts).toEqual([
      "C:/workspace/artifacts/codex-native-converter",
    ]);
  });
});
