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
  copyFileSync: jest.fn(),
  existsSync: jest.fn(),
  mkdirSync: jest.fn(),
}));

jest.mock("node:child_process", () => ({
  spawn: jest.fn(),
}));

jest.mock("../src/repo-automation-execute-discovery");

import { createRepoAutomationService } from "../src/repo-automation-service";
import type {
  RepoAutomationExecutionResult,
  RepoAutomationService,
} from "../src/repo-automation-service";
import * as discovery from "../src/repo-automation-execute-discovery";

const output = { appendLine: jest.fn<(line: string) => void>() };

function createService(): RepoAutomationService {
  return createRepoAutomationService({
    extensionRoot: "C:/extension",
    output,
  });
}

function markerResult(
  tool: RepoAutomationExecutionResult["tool"],
): RepoAutomationExecutionResult {
  return { tool, workspaceRoot: "C:/workspace", summary: "done" };
}

describe("discovery service-method delegation", () => {
  beforeEach(() => {
    output.appendLine.mockReset();
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it("validateDiscoveryArtifacts delegates to the discovery helper with the injected output", async () => {
    const mock = jest
      .mocked(discovery.runValidateDiscoveryArtifacts)
      .mockResolvedValue(markerResult("validate_discovery_artifacts"));
    const input = {
      workspaceRoot: "C:/workspace",
      invocationId: "id-validate",
      artifactType: "profile",
      artifactPath: "p.yaml",
    };

    const result = await createService().validateDiscoveryArtifacts(input);

    expect(mock).toHaveBeenCalledWith(output, input);
    expect(result.tool).toBe("validate_discovery_artifacts");
  });

  it("runDiscoveryInit delegates to the discovery helper forwarding workspaceRoot and invocationId", async () => {
    const mock = jest
      .mocked(discovery.runDiscoveryInit)
      .mockResolvedValue(markerResult("run_discovery_init"));
    const input = {
      workspaceRoot: "C:/workspace",
      invocationId: "id-init",
      targetDir: "discovery",
    };

    await createService().runDiscoveryInit(input);

    expect(mock).toHaveBeenCalledWith(output, input);
    expect(mock.mock.calls[0]?.[1]).toMatchObject({
      workspaceRoot: "C:/workspace",
      invocationId: "id-init",
    });
  });

  it("runDiscoveryRepoInventory delegates to the discovery helper", async () => {
    const mock = jest
      .mocked(discovery.runDiscoveryRepoInventory)
      .mockResolvedValue(markerResult("run_discovery_repo_inventory"));
    const input = { workspaceRoot: "C:/workspace", invocationId: "id-inv" };

    await createService().runDiscoveryRepoInventory(input);

    expect(mock).toHaveBeenCalledWith(output, input);
  });

  it("runDiscoveryDotnetAnalyzer delegates to the discovery helper", async () => {
    const mock = jest
      .mocked(discovery.runDiscoveryDotnetAnalyzer)
      .mockResolvedValue(markerResult("run_discovery_dotnet_analyzer"));
    const input = { workspaceRoot: "C:/workspace", profilePath: "p.yaml" };

    await createService().runDiscoveryDotnetAnalyzer(input);

    expect(mock).toHaveBeenCalledWith(output, input);
  });

  it("runDiscoveryVstoAnalyzer delegates to the discovery helper", async () => {
    const mock = jest
      .mocked(discovery.runDiscoveryVstoAnalyzer)
      .mockResolvedValue(markerResult("run_discovery_vsto_analyzer"));
    const input = { workspaceRoot: "C:/workspace", outputDir: "out" };

    await createService().runDiscoveryVstoAnalyzer(input);

    expect(mock).toHaveBeenCalledWith(output, input);
  });

  it("runDiscoveryScenarioGeneration delegates to the discovery helper", async () => {
    const mock = jest
      .mocked(discovery.runDiscoveryScenarioGeneration)
      .mockResolvedValue(markerResult("run_discovery_scenario_generation"));
    const input = {
      workspaceRoot: "C:/workspace",
      featureContract: "fc.yaml",
      parityMatrix: "pm.yaml",
      runtimeCharacterization: "rc.yaml",
    };

    await createService().runDiscoveryScenarioGeneration(input);

    expect(mock).toHaveBeenCalledWith(output, input);
  });

  it("runDiscoveryReport delegates to the discovery helper", async () => {
    const mock = jest
      .mocked(discovery.runDiscoveryReport)
      .mockResolvedValue(markerResult("run_discovery_report"));
    const input = {
      workspaceRoot: "C:/workspace",
      invocationId: "id-report",
      reportType: "parity",
      inputPath: "matrix.yaml",
    };

    await createService().runDiscoveryReport(input);

    expect(mock).toHaveBeenCalledWith(output, input);
  });
});
