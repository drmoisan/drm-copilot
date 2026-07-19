import {
  afterEach,
  beforeEach,
  describe,
  expect,
  it,
  jest,
} from "@jest/globals";

import {
  activateAndGetHandler,
  appendLineMock,
  childProcessMock,
  createMockProcess,
  resetExtensionHarnessState,
  setExecutablePresence,
  showInputBoxMock,
  showQuickPickMock,
} from "./extension-test-harness";

const WORKSPACE_ROOT = "C:/workspace";

function entryCode(module: string, functionName: string): string {
  return `import sys; from ${module} import ${functionName}; sys.exit(${functionName}())`;
}

function spawnArgs(callIndex = 0): string[] {
  const call = childProcessMock.spawn.mock.calls[callIndex] as
    [string, string[], { cwd: string }] | undefined;
  if (call === undefined) {
    throw new Error("spawn was not invoked");
  }
  return call[1];
}

function spawnCwd(callIndex = 0): string {
  const call = childProcessMock.spawn.mock.calls[callIndex] as [
    string,
    string[],
    { cwd: string },
  ];
  return call[2].cwd;
}

describe("discovery VS Code commands", () => {
  beforeEach(() => {
    resetExtensionHarnessState();
    // Resolve a PATH python and make every spawned discovery CLI succeed.
    setExecutablePresence({ python: true, py: false });
    childProcessMock.spawn.mockReturnValue(createMockProcess(0));
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it("registers all seven discovery commands", () => {
    for (const commandId of [
      "drmCopilotExtension.validateDiscoveryArtifacts",
      "drmCopilotExtension.runDiscoveryInit",
      "drmCopilotExtension.runDiscoveryRepoInventory",
      "drmCopilotExtension.runDiscoveryDotnetAnalyzer",
      "drmCopilotExtension.runDiscoveryVstoAnalyzer",
      "drmCopilotExtension.runDiscoveryScenarioGeneration",
      "drmCopilotExtension.runDiscoveryReport",
    ]) {
      expect(activateAndGetHandler(commandId)).toBeDefined();
    }
  });

  it("validateDiscoveryArtifacts direct invocation spawns the per-kind entry", async () => {
    const handler = activateAndGetHandler(
      "drmCopilotExtension.validateDiscoveryArtifacts",
    );
    await handler({ artifact_type: "profile", artifact_path: "p.yaml" });

    const args = spawnArgs();
    expect(args).toContain(
      entryCode(
        "scripts.dev_tools.validate_discovery_artifacts",
        "main_profile",
      ),
    );
    expect(args).toContain("p.yaml");
    expect(spawnCwd()).toBe(WORKSPACE_ROOT);
    expect(appendLineMock).toHaveBeenCalled();
    expect(showQuickPickMock).not.toHaveBeenCalled();
  });

  it("validateDiscoveryArtifacts interactive invocation prompts then spawns", async () => {
    showQuickPickMock.mockResolvedValueOnce("all");
    showInputBoxMock.mockResolvedValueOnce("discovery/");

    const handler = activateAndGetHandler(
      "drmCopilotExtension.validateDiscoveryArtifacts",
    );
    await handler();

    const args = spawnArgs();
    expect(args).toContain(
      entryCode("scripts.dev_tools.validate_discovery_artifacts", "main"),
    );
    expect(args).toContain("discovery/");
  });

  it("runDiscoveryInit direct invocation spawns init_cli:main with target_dir", async () => {
    const handler = activateAndGetHandler(
      "drmCopilotExtension.runDiscoveryInit",
    );
    await handler({ target_dir: "discovery" });

    const args = spawnArgs();
    expect(args).toContain(
      entryCode("scripts.dev_tools.discovery.init_cli", "main"),
    );
    expect(args).toContain("discovery");
  });

  it("runDiscoveryInit interactive invocation prompts for the target directory", async () => {
    showInputBoxMock.mockResolvedValueOnce("discovery");

    const handler = activateAndGetHandler(
      "drmCopilotExtension.runDiscoveryInit",
    );
    await handler();

    expect(spawnArgs()).toContain(
      entryCode("scripts.dev_tools.discovery.init_cli", "main"),
    );
  });

  it("runDiscoveryRepoInventory direct invocation spawns analyzer.cli:main with --json", async () => {
    const handler = activateAndGetHandler(
      "drmCopilotExtension.runDiscoveryRepoInventory",
    );
    await handler({ profile_path: "profile.yaml" });

    const args = spawnArgs();
    expect(args).toContain(
      entryCode("scripts.dev_tools.discovery.analyzer.cli", "main"),
    );
    expect(args).toContain("profile.yaml");
    expect(args).toContain("--json");
  });

  it("runDiscoveryRepoInventory interactive invocation runs without prompts", async () => {
    const handler = activateAndGetHandler(
      "drmCopilotExtension.runDiscoveryRepoInventory",
    );
    await handler();

    expect(spawnArgs()).toContain(
      entryCode("scripts.dev_tools.discovery.analyzer.cli", "main"),
    );
    expect(showInputBoxMock).not.toHaveBeenCalled();
  });

  it("runDiscoveryDotnetAnalyzer direct invocation spawns stack_cli:main_dotnet", async () => {
    const handler = activateAndGetHandler(
      "drmCopilotExtension.runDiscoveryDotnetAnalyzer",
    );
    await handler({});

    expect(spawnArgs()).toContain(
      entryCode(
        "scripts.dev_tools.discovery.analyzer.stack_cli",
        "main_dotnet",
      ),
    );
  });

  it("runDiscoveryDotnetAnalyzer interactive invocation spawns stack_cli:main_dotnet", async () => {
    const handler = activateAndGetHandler(
      "drmCopilotExtension.runDiscoveryDotnetAnalyzer",
    );
    await handler();

    expect(spawnArgs()).toContain(
      entryCode(
        "scripts.dev_tools.discovery.analyzer.stack_cli",
        "main_dotnet",
      ),
    );
  });

  it("runDiscoveryVstoAnalyzer direct invocation spawns stack_cli:main_vsto", async () => {
    const handler = activateAndGetHandler(
      "drmCopilotExtension.runDiscoveryVstoAnalyzer",
    );
    await handler({ output_dir: "out" });

    const args = spawnArgs();
    expect(args).toContain(
      entryCode("scripts.dev_tools.discovery.analyzer.stack_cli", "main_vsto"),
    );
    expect(args).toContain("--output-dir");
    expect(args).toContain("out");
  });

  it("runDiscoveryVstoAnalyzer interactive invocation spawns stack_cli:main_vsto", async () => {
    const handler = activateAndGetHandler(
      "drmCopilotExtension.runDiscoveryVstoAnalyzer",
    );
    await handler();

    expect(spawnArgs()).toContain(
      entryCode("scripts.dev_tools.discovery.analyzer.stack_cli", "main_vsto"),
    );
  });

  it("runDiscoveryScenarioGeneration direct invocation spawns the generator with three inputs", async () => {
    const handler = activateAndGetHandler(
      "drmCopilotExtension.runDiscoveryScenarioGeneration",
    );
    await handler({
      feature_contract: "fc.yaml",
      parity_matrix: "pm.yaml",
      runtime_characterization: "rc.yaml",
    });

    const args = spawnArgs();
    expect(args).toContain(
      entryCode("scripts.dev_tools.generate_acceptance_scenarios", "main"),
    );
    expect(args).toContain("--feature-contract");
    expect(args).toContain("fc.yaml");
    expect(args).toContain("--parity-matrix");
    expect(args).toContain("--runtime-characterization");
  });

  it("runDiscoveryScenarioGeneration interactive invocation prompts for the three inputs", async () => {
    showInputBoxMock
      .mockResolvedValueOnce("fc.yaml")
      .mockResolvedValueOnce("pm.yaml")
      .mockResolvedValueOnce("rc.yaml");

    const handler = activateAndGetHandler(
      "drmCopilotExtension.runDiscoveryScenarioGeneration",
    );
    await handler();

    const args = spawnArgs();
    expect(args).toContain("fc.yaml");
    expect(args).toContain("pm.yaml");
    expect(args).toContain("rc.yaml");
  });

  it("runDiscoveryReport direct invocation spawns parity_report:main with --input", async () => {
    const handler = activateAndGetHandler(
      "drmCopilotExtension.runDiscoveryReport",
    );
    await handler({ report_type: "parity", input_path: "matrix.yaml" });

    const args = spawnArgs();
    expect(args).toContain(
      entryCode("scripts.dev_tools.discovery.parity_report", "main"),
    );
    expect(args).toContain("--input");
    expect(args).toContain("matrix.yaml");
  });

  it("runDiscoveryReport interactive completion invocation prompts for both inputs", async () => {
    showQuickPickMock.mockResolvedValueOnce("completion");
    showInputBoxMock
      .mockResolvedValueOnce("cov.json")
      .mockResolvedValueOnce("par.yaml");

    const handler = activateAndGetHandler(
      "drmCopilotExtension.runDiscoveryReport",
    );
    await handler();

    const args = spawnArgs();
    expect(args).toContain(
      entryCode("scripts.dev_tools.discovery.completion_report", "main"),
    );
    expect(args).toContain("--coverage-input");
    expect(args).toContain("cov.json");
    expect(args).toContain("--parity-input");
    expect(args).toContain("par.yaml");
  });
});
