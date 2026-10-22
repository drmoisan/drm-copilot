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
import type { MockChildProcess } from "./runtime-test-helpers";
import { buildServiceResult } from "./discovery-test-helpers";

const WORKSPACE_ROOT = "C:/workspace";
const GATEWAY_ARGV_PREFIX = ["-I", "-m", "drm_copilot_discovery.gateway"];

/** The most recent spawned child, so its stdin request can be inspected. */
let spawnedProcesses: MockChildProcess[] = [];

function spawnCall(callIndex = 0): [string, string[], { cwd: string }] {
  const call = childProcessMock.spawn.mock.calls[callIndex] as
    [string, string[], { cwd: string }] | undefined;
  if (call === undefined) {
    throw new Error("spawn was not invoked");
  }
  return call;
}

function spawnArgs(callIndex = 0): string[] {
  return spawnCall(callIndex)[1];
}

function stdinRequest(callIndex = 0): Record<string, unknown> {
  const child = spawnedProcesses[callIndex];
  if (child === undefined || child.stdin.written.length !== 1) {
    throw new Error("exactly one request document was expected on stdin");
  }
  return JSON.parse(child.stdin.written[0] ?? "") as Record<string, unknown>;
}

function expectGatewayInvocation(): void {
  const [, args, options] = spawnCall();
  expect(args.slice(0, 3)).toEqual(GATEWAY_ARGV_PREFIX);
  expect(args).toEqual([
    ...GATEWAY_ARGV_PREFIX,
    "--workspace-root",
    WORKSPACE_ROOT,
    "--principal",
    "local-user",
  ]);
  expect(args).not.toContain("-c");
  expect(options.cwd).toBe(WORKSPACE_ROOT);
}

describe("discovery VS Code commands", () => {
  beforeEach(() => {
    resetExtensionHarnessState();
    spawnedProcesses = [];
    // Resolve a PATH python and make every spawned gateway return one valid
    // success result document on stdout.
    setExecutablePresence({ python: true, py: false });
    childProcessMock.spawn.mockImplementation((): MockChildProcess => {
      const child = createMockProcess(0, JSON.stringify(buildServiceResult()));
      spawnedProcesses.push(child);
      return child;
    });
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

  it("validateDiscoveryArtifacts direct invocation sends the per-kind request to the gateway", async () => {
    const handler = activateAndGetHandler(
      "drmCopilotExtension.validateDiscoveryArtifacts",
    );
    await handler({ artifact_type: "profile", artifact_path: "p.yaml" });

    expectGatewayInvocation();
    expect(stdinRequest()).toMatchObject({
      $schema: "urn:drm-copilot:discovery:2.0.0:service-request",
      operation: "validate-profile",
      mode: "structural",
      inputs: { input_path: "p.yaml" },
    });
    expect(appendLineMock).toHaveBeenCalled();
    expect(showQuickPickMock).not.toHaveBeenCalled();
  });

  it("validateDiscoveryArtifacts interactive invocation prompts then validates the whole workspace", async () => {
    showQuickPickMock.mockResolvedValueOnce("all");
    showInputBoxMock.mockResolvedValueOnce(".");

    const handler = activateAndGetHandler(
      "drmCopilotExtension.validateDiscoveryArtifacts",
    );
    await handler();

    expectGatewayInvocation();
    expect(stdinRequest()).toMatchObject({
      operation: "validate-all",
      mode: "structural",
      inputs: {},
    });
  });

  it("runDiscoveryInit rejects the retired target_dir contract without spawning", async () => {
    const handler = activateAndGetHandler(
      "drmCopilotExtension.runDiscoveryInit",
    );

    await expect(handler({ target_dir: "discovery" })).rejects.toThrow(
      "does not accept targetDir",
    );
    expect(childProcessMock.spawn).not.toHaveBeenCalled();
  });

  it("runDiscoveryInit interactive invocation prompts for the target directory and rejects it", async () => {
    showInputBoxMock.mockResolvedValueOnce("discovery");

    const handler = activateAndGetHandler(
      "drmCopilotExtension.runDiscoveryInit",
    );

    await expect(handler()).rejects.toThrow("does not accept targetDir");
    expect(childProcessMock.spawn).not.toHaveBeenCalled();
  });

  it("runDiscoveryRepoInventory direct invocation sends the inventory request with the profile", async () => {
    const handler = activateAndGetHandler(
      "drmCopilotExtension.runDiscoveryRepoInventory",
    );
    await handler({ profile_path: "profile.yaml" });

    expectGatewayInvocation();
    expect(stdinRequest()).toMatchObject({
      operation: "inventory",
      profile_path: "profile.yaml",
      write: false,
      dry_run: false,
      inputs: {},
    });
    expect(spawnArgs()).not.toContain("--json");
  });

  it("runDiscoveryRepoInventory interactive invocation runs without prompts", async () => {
    const handler = activateAndGetHandler(
      "drmCopilotExtension.runDiscoveryRepoInventory",
    );
    await handler();

    expectGatewayInvocation();
    expect(stdinRequest()).toMatchObject({ operation: "inventory" });
    expect(showInputBoxMock).not.toHaveBeenCalled();
  });

  it("runDiscoveryDotnetAnalyzer direct and interactive invocations select the dotnet analyzer", async () => {
    const handler = activateAndGetHandler(
      "drmCopilotExtension.runDiscoveryDotnetAnalyzer",
    );
    await handler({});
    await handler();

    expectGatewayInvocation();
    expect(stdinRequest(0)).toMatchObject({
      operation: "inventory",
      inputs: { analyzer_ids: ["dotnet"] },
    });
    expect(stdinRequest(1)).toMatchObject({
      inputs: { analyzer_ids: ["dotnet"] },
    });
  });

  it("runDiscoveryVstoAnalyzer rejects the retired output_dir input and otherwise selects office-vsto", async () => {
    const handler = activateAndGetHandler(
      "drmCopilotExtension.runDiscoveryVstoAnalyzer",
    );

    await expect(handler({ output_dir: "out" })).rejects.toThrow(
      "does not accept outputDir",
    );
    expect(childProcessMock.spawn).not.toHaveBeenCalled();

    await handler();
    expectGatewayInvocation();
    expect(stdinRequest()).toMatchObject({
      inputs: { analyzer_ids: ["office-vsto"] },
    });
  });

  it("runDiscoveryScenarioGeneration rejects the retired three-input contract", async () => {
    const handler = activateAndGetHandler(
      "drmCopilotExtension.runDiscoveryScenarioGeneration",
    );

    await expect(
      handler({
        feature_contract: "fc.yaml",
        parity_matrix: "pm.yaml",
        runtime_characterization: "rc.yaml",
      }),
    ).rejects.toThrow("does not accept featureContract");
    expect(childProcessMock.spawn).not.toHaveBeenCalled();
  });

  it("runDiscoveryScenarioGeneration interactive invocation still prompts for the three inputs and rejects them", async () => {
    showInputBoxMock
      .mockResolvedValueOnce("fc.yaml")
      .mockResolvedValueOnce("pm.yaml")
      .mockResolvedValueOnce("rc.yaml");

    const handler = activateAndGetHandler(
      "drmCopilotExtension.runDiscoveryScenarioGeneration",
    );

    await expect(handler()).rejects.toThrow("does not accept featureContract");
    expect(showInputBoxMock).toHaveBeenCalledTimes(3);
    expect(childProcessMock.spawn).not.toHaveBeenCalled();
  });

  it("runDiscoveryReport rejects the retired input_path contract", async () => {
    const handler = activateAndGetHandler(
      "drmCopilotExtension.runDiscoveryReport",
    );

    await expect(
      handler({ report_type: "parity", input_path: "matrix.yaml" }),
    ).rejects.toThrow("does not accept inputPath");
    expect(childProcessMock.spawn).not.toHaveBeenCalled();
  });

  it("runDiscoveryReport interactive completion invocation prompts for both inputs and rejects them", async () => {
    showQuickPickMock.mockResolvedValueOnce("completion");
    showInputBoxMock
      .mockResolvedValueOnce("cov.json")
      .mockResolvedValueOnce("par.yaml");

    const handler = activateAndGetHandler(
      "drmCopilotExtension.runDiscoveryReport",
    );

    await expect(handler()).rejects.toThrow(
      "does not accept coverageInput, parityInput",
    );
    expect(childProcessMock.spawn).not.toHaveBeenCalled();
  });

  it("surfaces a malformed gateway result as a blocking transport error", async () => {
    childProcessMock.spawn.mockImplementation((): MockChildProcess => {
      const child = createMockProcess(0, "ok: wrote discovery/x.json");
      spawnedProcesses.push(child);
      return child;
    });
    const handler = activateAndGetHandler(
      "drmCopilotExtension.runDiscoveryRepoInventory",
    );

    await expect(handler({})).rejects.toThrow("DISCOVERY_RESULT_MALFORMED");
  });

  it.each([
    ["validateDiscoveryArtifacts", "quick pick", [undefined], []],
    ["validateDiscoveryArtifacts", "artifact path", ["profile"], [undefined]],
    ["runDiscoveryInit", "target directory", [], [undefined]],
    ["runDiscoveryScenarioGeneration", "feature contract", [], [undefined]],
    [
      "runDiscoveryScenarioGeneration",
      "parity matrix",
      [],
      ["fc.yaml", undefined],
    ],
    [
      "runDiscoveryScenarioGeneration",
      "runtime characterization",
      [],
      ["fc.yaml", "pm.yaml", undefined],
    ],
    ["runDiscoveryReport", "report type", [undefined], []],
    ["runDiscoveryReport", "coverage input", ["completion"], [undefined]],
    [
      "runDiscoveryReport",
      "parity input",
      ["completion"],
      ["cov.json", undefined],
    ],
    ["runDiscoveryReport", "report input", ["parity"], [undefined]],
  ] as const)(
    "%s interactive invocation cancelled at the %s prompt neither spawns nor rejects",
    async (command, _prompt, quickPicks, inputs) => {
      for (const pick of quickPicks) {
        showQuickPickMock.mockResolvedValueOnce(pick);
      }
      for (const value of inputs) {
        showInputBoxMock.mockResolvedValueOnce(value);
      }
      const handler = activateAndGetHandler(`drmCopilotExtension.${command}`);

      await expect(handler()).resolves.toBeUndefined();

      expect(childProcessMock.spawn).not.toHaveBeenCalled();
    },
  );
});
