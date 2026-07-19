import {
  afterEach,
  beforeEach,
  describe,
  expect,
  it,
  jest,
} from "@jest/globals";

jest.mock("vscode", () => ({ window: { createTerminal: jest.fn() } }), {
  virtual: true,
});

import { dispatchRepoAutomationTool } from "../src/mcp-tools";
import { CommandExecutionError } from "../src/command-runtime";
import type {
  RepoAutomationExecutionResult,
  RepoAutomationService,
} from "../src/repo-automation-service";

function createMockService(): jest.Mocked<RepoAutomationService> {
  return {
    collectCommitContext: jest.fn(),
    collectPrContext: jest.fn(),
    runCodexNativeConverter: jest.fn(),
    pushDownCopilotCustomizations: jest.fn(),
    pushDownCodexAndAgentsCustomizations: jest.fn(),
    pushDownClaudeCustomizations: jest.fn(),
    newPotentialBugEntry: jest.fn(),
    newPotentialEntry: jest.fn(),
    linkParentChild: jest.fn(),
    potentialToIssue: jest.fn(),
    newActiveFeatureFolder: jest.fn(),
    runPoshQCFormat: jest.fn(),
    runPoshQCAnalyze: jest.fn(),
    runPoshQCTest: jest.fn(),
    runPoshQCAnalyzeAutofix: jest.fn(),
    runPoshQCSuite: jest.fn(),
    resolvePolicyAuditTemplateAsset: jest.fn(),
    resolveExecuteHardLockPrompt: jest.fn(),
    resolveAtomicPlanPrompt: jest.fn(),
    validateOrchestrationArtifacts: jest.fn(),
    renderSubagentTree: jest.fn(),
    validateDiscoveryArtifacts: jest.fn(),
    runDiscoveryInit: jest.fn(),
    runDiscoveryRepoInventory: jest.fn(),
    runDiscoveryDotnetAnalyzer: jest.fn(),
    runDiscoveryVstoAnalyzer: jest.fn(),
    runDiscoveryScenarioGeneration: jest.fn(),
    runDiscoveryReport: jest.fn(),
  };
}

const WORKSPACE_ROOT = "C:/workspace";

function successResult(
  tool: RepoAutomationExecutionResult["tool"],
  artifacts?: ReadonlyArray<string>,
): RepoAutomationExecutionResult {
  return {
    tool,
    workspaceRoot: WORKSPACE_ROOT,
    summary: `did ${tool}`,
    ...(artifacts === undefined ? {} : { artifacts }),
  };
}

describe("discovery dispatch success mapping", () => {
  let service: jest.Mocked<RepoAutomationService>;

  beforeEach(() => {
    service = createMockService();
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it("maps validate_discovery_artifacts to the snake_case success result", async () => {
    service.validateDiscoveryArtifacts.mockResolvedValue(
      successResult("validate_discovery_artifacts"),
    );

    const result = await dispatchRepoAutomationTool(
      "validate_discovery_artifacts",
      {
        workspace_root: WORKSPACE_ROOT,
        artifact_type: "profile",
        artifact_path: "p.yaml",
      },
      service,
    );

    expect(service.validateDiscoveryArtifacts).toHaveBeenCalledWith({
      workspaceRoot: WORKSPACE_ROOT,
      artifactType: "profile",
      artifactPath: "p.yaml",
    });
    expect(result).toMatchObject({
      ok: true,
      tool: "validate_discovery_artifacts",
      workspace_root: WORKSPACE_ROOT,
      summary: "did validate_discovery_artifacts",
    });
  });

  it("maps run_discovery_init to the success result", async () => {
    service.runDiscoveryInit.mockResolvedValue(
      successResult("run_discovery_init"),
    );

    const result = await dispatchRepoAutomationTool(
      "run_discovery_init",
      { workspace_root: WORKSPACE_ROOT, target_dir: "discovery" },
      service,
    );

    expect(service.runDiscoveryInit).toHaveBeenCalledWith({
      workspaceRoot: WORKSPACE_ROOT,
      targetDir: "discovery",
    });
    expect(result.ok).toBe(true);
  });

  it("surfaces parsed analyzer artifacts on run_discovery_repo_inventory", async () => {
    service.runDiscoveryRepoInventory.mockResolvedValue(
      successResult("run_discovery_repo_inventory", ["a.json", "b.json"]),
    );

    const result = await dispatchRepoAutomationTool(
      "run_discovery_repo_inventory",
      { workspace_root: WORKSPACE_ROOT },
      service,
    );

    expect(result).toMatchObject({
      ok: true,
      tool: "run_discovery_repo_inventory",
      artifacts: ["a.json", "b.json"],
    });
  });

  it("maps run_discovery_dotnet_analyzer success", async () => {
    service.runDiscoveryDotnetAnalyzer.mockResolvedValue(
      successResult("run_discovery_dotnet_analyzer"),
    );

    const result = await dispatchRepoAutomationTool(
      "run_discovery_dotnet_analyzer",
      { workspace_root: WORKSPACE_ROOT },
      service,
    );

    expect(result.ok).toBe(true);
    expect(result.tool).toBe("run_discovery_dotnet_analyzer");
  });

  it("maps run_discovery_vsto_analyzer success", async () => {
    service.runDiscoveryVstoAnalyzer.mockResolvedValue(
      successResult("run_discovery_vsto_analyzer"),
    );

    const result = await dispatchRepoAutomationTool(
      "run_discovery_vsto_analyzer",
      { workspace_root: WORKSPACE_ROOT },
      service,
    );

    expect(result.ok).toBe(true);
  });

  it("maps run_discovery_scenario_generation success", async () => {
    service.runDiscoveryScenarioGeneration.mockResolvedValue(
      successResult("run_discovery_scenario_generation"),
    );

    const result = await dispatchRepoAutomationTool(
      "run_discovery_scenario_generation",
      {
        workspace_root: WORKSPACE_ROOT,
        feature_contract: "fc",
        parity_matrix: "pm",
        runtime_characterization: "rc",
      },
      service,
    );

    expect(service.runDiscoveryScenarioGeneration).toHaveBeenCalledWith({
      workspaceRoot: WORKSPACE_ROOT,
      featureContract: "fc",
      parityMatrix: "pm",
      runtimeCharacterization: "rc",
    });
    expect(result.ok).toBe(true);
  });

  it("maps run_discovery_report completion with its two inputs", async () => {
    service.runDiscoveryReport.mockResolvedValue(
      successResult("run_discovery_report"),
    );

    const result = await dispatchRepoAutomationTool(
      "run_discovery_report",
      {
        workspace_root: WORKSPACE_ROOT,
        report_type: "completion",
        coverage_input: "cov.json",
        parity_input: "par.yaml",
      },
      service,
    );

    expect(service.runDiscoveryReport).toHaveBeenCalledWith({
      workspaceRoot: WORKSPACE_ROOT,
      reportType: "completion",
      coverageInput: "cov.json",
      parityInput: "par.yaml",
    });
    expect(result.ok).toBe(true);
  });
});

describe("discovery dispatch failure and validation mapping", () => {
  let service: jest.Mocked<RepoAutomationService>;

  beforeEach(() => {
    service = createMockService();
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it("maps a thrown CommandExecutionError to ok:false with a bounded stderr excerpt", async () => {
    const stderr = Array.from({ length: 12 }, (_, i) => `line-${i}`).join("\n");
    service.runDiscoveryReport.mockRejectedValue(
      new CommandExecutionError({
        executable: "python",
        args: ["-c", "..."],
        cwd: WORKSPACE_ROOT,
        exitCode: 1,
        stdout: "",
        stderr,
      }),
    );

    const result = await dispatchRepoAutomationTool(
      "run_discovery_report",
      {
        workspace_root: WORKSPACE_ROOT,
        report_type: "parity",
        input_path: "m",
      },
      service,
    );

    expect(result.ok).toBe(false);
    expect(result.tool).toBe("run_discovery_report");
    expect(result.stderr_excerpt).toBeDefined();
    expect(
      (result.stderr_excerpt ?? "").split("\n").length,
    ).toBeLessThanOrEqual(8);
  });

  it("rejects invalid input via the resolver without calling the service", async () => {
    const result = await dispatchRepoAutomationTool(
      "validate_discovery_artifacts",
      { workspace_root: WORKSPACE_ROOT, artifact_type: "profile" },
      service,
    );

    expect(service.validateDiscoveryArtifacts).not.toHaveBeenCalled();
    expect(result.ok).toBe(false);
    expect(result.summary).toMatch(/artifact_path/);
  });

  it("rejects an out-of-enum report_type before touching the service", async () => {
    const result = await dispatchRepoAutomationTool(
      "run_discovery_report",
      { workspace_root: WORKSPACE_ROOT, report_type: "bogus", input_path: "m" },
      service,
    );

    expect(service.runDiscoveryReport).not.toHaveBeenCalled();
    expect(result.ok).toBe(false);
    expect(result.summary).toMatch(/report type/);
  });
});
