import {
  afterEach,
  beforeEach,
  describe,
  expect,
  it,
  jest,
} from "@jest/globals";

jest.mock("vscode", () => ({}), { virtual: true });

jest.mock("node:fs", () => ({
  existsSync: jest.fn(),
}));

jest.mock("node:child_process", () => ({
  spawn: jest.fn(),
}));

import {
  runValidateDiscoveryArtifacts,
  runDiscoveryInit,
  runDiscoveryRepoInventory,
  runDiscoveryDotnetAnalyzer,
  runDiscoveryVstoAnalyzer,
  runDiscoveryScenarioGeneration,
  runDiscoveryReport,
} from "../src/repo-automation-execute-discovery";
import { CommandExecutionError } from "../src/command-runtime";
import {
  createMockProcess,
  createMockProcessWithStderr,
  setExecutablePresenceOnFsMock,
  type MockChildProcess,
  type MockExistsSync,
} from "./runtime-test-helpers";

const fsMock = jest.requireMock("node:fs") as { existsSync: MockExistsSync };
const childProcessMock = jest.requireMock("node:child_process") as {
  spawn: jest.Mock;
};

const WORKSPACE_ROOT = "C:/workspace";
const bufferedOutput = { appendLine: (): void => undefined };

interface SpawnCapture {
  readonly executable: string;
  readonly args: ReadonlyArray<string>;
  readonly cwd: string;
}

/** Configure the spawn mock to emit `stdout` then close with `exitCode`. */
function primeSpawn(
  exitCode: number,
  stdout = "",
): { capture(): SpawnCapture } {
  let captured: SpawnCapture | undefined;
  childProcessMock.spawn.mockImplementation(
    (
      executable: string,
      args: ReadonlyArray<string>,
      options: { cwd: string },
    ): MockChildProcess => {
      captured = { executable, args, cwd: options.cwd };
      return createMockProcess(exitCode, stdout);
    },
  );
  return {
    capture(): SpawnCapture {
      if (captured === undefined) {
        throw new Error("spawn was not invoked");
      }
      return captured;
    },
  };
}

function primeSpawnWithStderr(
  exitCode: number,
  stderr: string,
): { capture(): SpawnCapture } {
  let captured: SpawnCapture | undefined;
  childProcessMock.spawn.mockImplementation(
    (
      executable: string,
      args: ReadonlyArray<string>,
      options: { cwd: string },
    ): MockChildProcess => {
      captured = { executable, args, cwd: options.cwd };
      return createMockProcessWithStderr(exitCode, stderr);
    },
  );
  return {
    capture(): SpawnCapture {
      if (captured === undefined) {
        throw new Error("spawn was not invoked");
      }
      return captured;
    },
  };
}

/** Assert the interpreter `-c` argv shape and return the CLI args tail. */
function expectEntryArgv(
  capture: SpawnCapture,
  module: string,
  functionName: string,
): ReadonlyArray<string> {
  expect(capture.args[0]).toBe("-c");
  expect(capture.args[1]).toBe(
    `import sys; from ${module} import ${functionName}; sys.exit(${functionName}())`,
  );
  expect(capture.cwd).toBe(WORKSPACE_ROOT);
  return capture.args.slice(2);
}

describe("discovery service-call helper", () => {
  beforeEach(() => {
    process.env["PATH"] = "C:/bin";
    process.env["PATHEXT"] = ".EXE;.CMD";
    fsMock.existsSync.mockReset();
    // Resolve a PATH `python`; suppress the workspace `.venv` candidate so the
    // interpreter resolution is deterministic.
    setExecutablePresenceOnFsMock(fsMock, {
      "C:/workspace/.venv/Scripts/python.exe": false,
      "C:/workspace/.venv/bin/python": false,
      py: false,
      python: true,
    });
    childProcessMock.spawn.mockReset();
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it("selects the per-kind validate function and passes exactly one positional path", async () => {
    const spawn = primeSpawn(0);
    await runValidateDiscoveryArtifacts(bufferedOutput, {
      workspaceRoot: WORKSPACE_ROOT,
      artifactType: "profile",
      artifactPath: "discovery/profile.yaml",
    });

    const tail = expectEntryArgv(
      spawn.capture(),
      "scripts.dev_tools.validate_discovery_artifacts",
      "main_profile",
    );
    expect(tail).toEqual(["discovery/profile.yaml"]);
  });

  it("maps the all kind to the module main entry", async () => {
    const spawn = primeSpawn(0);
    await runValidateDiscoveryArtifacts(bufferedOutput, {
      workspaceRoot: WORKSPACE_ROOT,
      artifactType: "all",
      artifactPath: "discovery/",
    });

    const tail = expectEntryArgv(
      spawn.capture(),
      "scripts.dev_tools.validate_discovery_artifacts",
      "main",
    );
    expect(tail).toEqual(["discovery/"]);
  });

  it("maps evidence-reference to main_evidence_reference", async () => {
    const spawn = primeSpawn(0);
    await runValidateDiscoveryArtifacts(bufferedOutput, {
      workspaceRoot: WORKSPACE_ROOT,
      artifactType: "evidence-reference",
      artifactPath: "e.yaml",
    });

    expectEntryArgv(
      spawn.capture(),
      "scripts.dev_tools.validate_discovery_artifacts",
      "main_evidence_reference",
    );
  });

  it("returns no parsed artifacts for the validate path", async () => {
    primeSpawn(0, '{"written_paths": ["ignored.txt"]}');
    const result = await runValidateDiscoveryArtifacts(bufferedOutput, {
      workspaceRoot: WORKSPACE_ROOT,
      artifactType: "profile",
      artifactPath: "p.yaml",
    });

    expect(result.artifacts).toBeUndefined();
    expect(result.tool).toBe("validate_discovery_artifacts");
  });

  it("composes init with required positional target_dir plus optional flags", async () => {
    const spawn = primeSpawn(0);
    await runDiscoveryInit(bufferedOutput, {
      workspaceRoot: WORKSPACE_ROOT,
      targetDir: "discovery",
      templateRoot: "templates/discovery",
      force: true,
    });

    const tail = expectEntryArgv(
      spawn.capture(),
      "scripts.dev_tools.discovery.init_cli",
      "main",
    );
    expect(tail).toEqual([
      "discovery",
      "--template-root",
      "templates/discovery",
      "--force",
    ]);
  });

  it("omits optional init flags when not supplied", async () => {
    const spawn = primeSpawn(0);
    await runDiscoveryInit(bufferedOutput, {
      workspaceRoot: WORKSPACE_ROOT,
      targetDir: "discovery",
    });

    const tail = expectEntryArgv(
      spawn.capture(),
      "scripts.dev_tools.discovery.init_cli",
      "main",
    );
    expect(tail).toEqual(["discovery"]);
  });

  it("runs the repo inventory analyzer with optional profile, output-dir, and always --json", async () => {
    const spawn = primeSpawn(0, '{"written_paths": ["a.json", "b.json"]}');
    const result = await runDiscoveryRepoInventory(bufferedOutput, {
      workspaceRoot: WORKSPACE_ROOT,
      profilePath: "profile.yaml",
      outputDir: "out",
    });

    const tail = expectEntryArgv(
      spawn.capture(),
      "scripts.dev_tools.discovery.analyzer.cli",
      "main",
    );
    expect(tail).toEqual(["profile.yaml", "--output-dir", "out", "--json"]);
    expect(result.artifacts).toEqual(["a.json", "b.json"]);
  });

  it("passes only --json when the analyzer profile and output-dir are omitted", async () => {
    const spawn = primeSpawn(0, "{}");
    const result = await runDiscoveryRepoInventory(bufferedOutput, {
      workspaceRoot: WORKSPACE_ROOT,
    });

    const tail = expectEntryArgv(
      spawn.capture(),
      "scripts.dev_tools.discovery.analyzer.cli",
      "main",
    );
    expect(tail).toEqual(["--json"]);
    expect(result.artifacts).toBeUndefined();
  });

  it("runs the dotnet analyzer via stack_cli:main_dotnet", async () => {
    const spawn = primeSpawn(0, '{"written_paths": ["dotnet.json"]}');
    const result = await runDiscoveryDotnetAnalyzer(bufferedOutput, {
      workspaceRoot: WORKSPACE_ROOT,
    });

    const tail = expectEntryArgv(
      spawn.capture(),
      "scripts.dev_tools.discovery.analyzer.stack_cli",
      "main_dotnet",
    );
    expect(tail).toEqual(["--json"]);
    expect(result.artifacts).toEqual(["dotnet.json"]);
  });

  it("runs the vsto analyzer via stack_cli:main_vsto", async () => {
    const spawn = primeSpawn(0, '{"written_paths": ["vsto.json"]}');
    await runDiscoveryVstoAnalyzer(bufferedOutput, {
      workspaceRoot: WORKSPACE_ROOT,
    });

    expectEntryArgv(
      spawn.capture(),
      "scripts.dev_tools.discovery.analyzer.stack_cli",
      "main_vsto",
    );
  });

  it("composes scenario generation with three required inputs and optional output/check", async () => {
    const spawn = primeSpawn(0, "ok: wrote discovery/scenarios.md");
    const result = await runDiscoveryScenarioGeneration(bufferedOutput, {
      workspaceRoot: WORKSPACE_ROOT,
      featureContract: "fc.yaml",
      parityMatrix: "pm.yaml",
      runtimeCharacterization: "rc.yaml",
      outputPath: "discovery/scenarios.md",
      check: true,
    });

    const tail = expectEntryArgv(
      spawn.capture(),
      "scripts.dev_tools.generate_acceptance_scenarios",
      "main",
    );
    expect(tail).toEqual([
      "--feature-contract",
      "fc.yaml",
      "--parity-matrix",
      "pm.yaml",
      "--runtime-characterization",
      "rc.yaml",
      "--output",
      "discovery/scenarios.md",
      "--check",
    ]);
    expect(result.artifacts).toEqual(["discovery/scenarios.md"]);
  });

  it("omits scenario output/check flags and parses no artifact without --output", async () => {
    const spawn = primeSpawn(0, "");
    const result = await runDiscoveryScenarioGeneration(bufferedOutput, {
      workspaceRoot: WORKSPACE_ROOT,
      featureContract: "fc.yaml",
      parityMatrix: "pm.yaml",
      runtimeCharacterization: "rc.yaml",
    });

    const tail = expectEntryArgv(
      spawn.capture(),
      "scripts.dev_tools.generate_acceptance_scenarios",
      "main",
    );
    expect(tail).toEqual([
      "--feature-contract",
      "fc.yaml",
      "--parity-matrix",
      "pm.yaml",
      "--runtime-characterization",
      "rc.yaml",
    ]);
    expect(result.artifacts).toBeUndefined();
  });

  it("dispatches coverage report to coverage_report:main with --input", async () => {
    const spawn = primeSpawn(0);
    await runDiscoveryReport(bufferedOutput, {
      workspaceRoot: WORKSPACE_ROOT,
      reportType: "coverage",
      inputPath: "ledger.json",
      outputPath: "reports/coverage.md",
    });

    const tail = expectEntryArgv(
      spawn.capture(),
      "scripts.dev_tools.discovery.coverage_report",
      "main",
    );
    expect(tail).toEqual([
      "--input",
      "ledger.json",
      "--output",
      "reports/coverage.md",
    ]);
  });

  it("dispatches parity report to parity_report:main with --input", async () => {
    const spawn = primeSpawn(0);
    await runDiscoveryReport(bufferedOutput, {
      workspaceRoot: WORKSPACE_ROOT,
      reportType: "parity",
      inputPath: "matrix.yaml",
    });

    const tail = expectEntryArgv(
      spawn.capture(),
      "scripts.dev_tools.discovery.parity_report",
      "main",
    );
    expect(tail).toEqual(["--input", "matrix.yaml"]);
  });

  it("dispatches completion report to completion_report:main with the two required inputs", async () => {
    const spawn = primeSpawn(0);
    const result = await runDiscoveryReport(bufferedOutput, {
      workspaceRoot: WORKSPACE_ROOT,
      reportType: "completion",
      coverageInput: "cov.json",
      parityInput: "par.yaml",
      outputPath: "reports/completion.md",
    });

    const tail = expectEntryArgv(
      spawn.capture(),
      "scripts.dev_tools.discovery.completion_report",
      "main",
    );
    expect(tail).toEqual([
      "--coverage-input",
      "cov.json",
      "--parity-input",
      "par.yaml",
      "--output",
      "reports/completion.md",
    ]);
    expect(result.artifacts).toBeUndefined();
  });

  it("propagates a non-zero exit as CommandExecutionError carrying stderr", async () => {
    primeSpawnWithStderr(1, "ModuleNotFoundError: scripts.dev_tools");
    await expect(
      runDiscoveryReport(bufferedOutput, {
        workspaceRoot: WORKSPACE_ROOT,
        reportType: "parity",
        inputPath: "matrix.yaml",
      }),
    ).rejects.toBeInstanceOf(CommandExecutionError);
  });

  it("captures the stderr excerpt on the propagated error", async () => {
    primeSpawnWithStderr(2, "boom-detail");
    await expect(
      runDiscoveryInit(bufferedOutput, {
        workspaceRoot: WORKSPACE_ROOT,
        targetDir: "discovery",
      }),
    ).rejects.toMatchObject({ stderr: expect.stringContaining("boom-detail") });
  });
});
