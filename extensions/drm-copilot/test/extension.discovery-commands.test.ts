/**
 * Workspace-level discovery commands: validate, initialize, inventory, reports,
 * doctor, configure, transfer and migrate.
 *
 * Each command runs through the real extension activation with the gateway
 * process mocked, so the assertions read the v2 request the shared service
 * wrote to the gateway stdin. Direct arguments bypass every prompt, interactive
 * invocations prompt only for the operation's required inputs, cancellation
 * stops without spawning, and no terminal is created on any path.
 */

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
  createTerminalMock,
  resetExtensionHarnessState,
  setExecutablePresence,
  showInputBoxMock,
  showQuickPickMock,
} from "./extension-test-harness";
import type { MockChildProcess } from "./runtime-test-helpers";
import { buildServiceResult } from "./discovery-test-helpers";

const WORKSPACE_ROOT = "C:/workspace";
const GATEWAY_ARGV_PREFIX = ["-I", "-m", "drm_copilot_discovery.gateway"];
const COMMANDS = [
  "validateDiscoveryArtifacts",
  "runDiscoveryInit",
  "runDiscoveryRepoInventory",
  "runDiscoveryDotnetAnalyzer",
  "runDiscoveryVstoAnalyzer",
  "runDiscoveryScenarioGeneration",
  "runDiscoveryReport",
  "runDiscoveryDoctor",
  "configureDiscoveryWorkspace",
  "transferDiscoverySnapshot",
  "migrateDiscoveryArtifacts",
  "createDiscoveryArtifact",
  "linkDiscoveryEvidence",
] as const;

let spawnedProcesses: MockChildProcess[] = [];

function spawnCall(callIndex = 0): [string, string[], { cwd: string }] {
  const call = childProcessMock.spawn.mock.calls[callIndex] as
    [string, string[], { cwd: string }] | undefined;
  if (call === undefined) {
    throw new Error("spawn was not invoked");
  }
  return call;
}

function stdinRequest(callIndex = 0): Record<string, unknown> {
  const child = spawnedProcesses[callIndex];
  if (child === undefined || child.stdin.written.length !== 1) {
    throw new Error("exactly one request document was expected on stdin");
  }
  return JSON.parse(child.stdin.written[0] ?? "") as Record<string, unknown>;
}

function expectGatewayInvocation(workspaceRoot = WORKSPACE_ROOT): void {
  const [, args, options] = spawnCall();
  expect(args).toEqual([
    ...GATEWAY_ARGV_PREFIX,
    "--workspace-root",
    workspaceRoot,
    "--principal",
    "local-user",
  ]);
  expect(args).not.toContain("-c");
  expect(options.cwd).toBe(workspaceRoot);
  expect(createTerminalMock).not.toHaveBeenCalled();
}

function handlerFor(command: (typeof COMMANDS)[number]) {
  return activateAndGetHandler(`drmCopilotExtension.${command}`);
}

describe("discovery VS Code commands", () => {
  beforeEach(() => {
    resetExtensionHarnessState();
    spawnedProcesses = [];
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

  it("registers the seven existing command ids and the six new ones", () => {
    for (const command of COMMANDS) {
      expect(handlerFor(command)).toBeDefined();
    }
    expect(COMMANDS).toHaveLength(13);
  });

  it("validateDiscoveryArtifacts direct invocation sends the per-kind request", async () => {
    await handlerFor("validateDiscoveryArtifacts")({
      artifact_type: "profile",
      artifact_path: "p.yaml",
    });
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

  it("validateDiscoveryArtifacts direct invocation honours a custom workspace, profile and mode", async () => {
    await handlerFor("validateDiscoveryArtifacts")({
      workspace_root: "D:/other",
      profile_path: "docs/custom.yaml",
      artifact_type: "all",
      artifact_path: ".",
      mode: "discovery-complete",
      dry_run: true,
    });
    expectGatewayInvocation("D:/other");
    expect(stdinRequest()).toMatchObject({
      operation: "validate-all",
      mode: "discovery-complete",
      dry_run: true,
      workspace_root: "D:/other",
      profile_path: "docs/custom.yaml",
    });
  });

  it("validateDiscoveryArtifacts interactive invocation prompts then validates the whole workspace", async () => {
    showQuickPickMock.mockResolvedValueOnce("all");
    showInputBoxMock.mockResolvedValueOnce(".");
    await handlerFor("validateDiscoveryArtifacts")();
    expectGatewayInvocation();
    expect(stdinRequest()).toMatchObject({
      operation: "validate-all",
      mode: "structural",
      inputs: {},
    });
  });

  it("runDiscoveryInit direct invocation sends the explicit system identity", async () => {
    await handlerFor("runDiscoveryInit")({
      system_id: "crm",
      system_name: "Legacy CRM",
      system_role: "legacy-source",
      repository_id: "legacy-crm",
      production_roots: ["src"],
      dry_run: true,
    });
    expectGatewayInvocation();
    expect(stdinRequest()).toMatchObject({
      operation: "init",
      dry_run: true,
      inputs: {
        system_id: "crm",
        system_name: "Legacy CRM",
        system_role: "legacy-source",
        repository_id: "legacy-crm",
        production_roots: ["src"],
      },
    });
  });

  it("runDiscoveryInit interactive invocation prompts only for the system identity", async () => {
    showInputBoxMock
      .mockResolvedValueOnce("crm")
      .mockResolvedValueOnce("Legacy CRM")
      .mockResolvedValueOnce("legacy-crm");
    showQuickPickMock.mockResolvedValueOnce("combined");
    await handlerFor("runDiscoveryInit")();
    expect(showInputBoxMock).toHaveBeenCalledTimes(3);
    expect(showQuickPickMock).toHaveBeenCalledTimes(1);
    expect(stdinRequest()).toMatchObject({
      operation: "init",
      inputs: {
        system_id: "crm",
        system_name: "Legacy CRM",
        system_role: "combined",
        repository_id: "legacy-crm",
      },
    });
  });

  it("runDiscoveryInit rejects the retired target_dir contract without spawning", async () => {
    await expect(
      handlerFor("runDiscoveryInit")({ target_dir: "discovery" }),
    ).rejects.toThrow("does not accept targetDir");
    expect(childProcessMock.spawn).not.toHaveBeenCalled();
  });

  it("runDiscoveryRepoInventory direct invocation sends the inventory request with the profile", async () => {
    await handlerFor("runDiscoveryRepoInventory")({
      profile_path: "profile.yaml",
      analyzer_ids: ["repository"],
      write: true,
    });
    expectGatewayInvocation();
    expect(stdinRequest()).toMatchObject({
      operation: "inventory",
      profile_path: "profile.yaml",
      write: true,
      dry_run: false,
      inputs: { analyzer_ids: ["repository"] },
    });
  });

  it("runDiscoveryRepoInventory interactive invocation runs without prompts", async () => {
    await handlerFor("runDiscoveryRepoInventory")();
    expectGatewayInvocation();
    expect(stdinRequest()).toMatchObject({
      operation: "inventory",
      inputs: {},
    });
    expect(showInputBoxMock).not.toHaveBeenCalled();
    expect(showQuickPickMock).not.toHaveBeenCalled();
  });

  it("runDiscoveryDotnetAnalyzer and runDiscoveryVstoAnalyzer select their fixed analyzers", async () => {
    await handlerFor("runDiscoveryDotnetAnalyzer")({});
    await handlerFor("runDiscoveryVstoAnalyzer")();
    expect(stdinRequest(0)).toMatchObject({
      operation: "inventory",
      inputs: { analyzer_ids: ["dotnet"] },
    });
    expect(stdinRequest(1)).toMatchObject({
      inputs: { analyzer_ids: ["office-vsto"] },
    });
  });

  it("runDiscoveryVstoAnalyzer rejects the retired output_dir input without spawning", async () => {
    await expect(
      handlerFor("runDiscoveryVstoAnalyzer")({ output_dir: "out" }),
    ).rejects.toThrow("does not accept outputDir");
    expect(childProcessMock.spawn).not.toHaveBeenCalled();
  });

  it("runDiscoveryReport direct invocation sends the whole-workspace mode and format", async () => {
    await handlerFor("runDiscoveryReport")({
      report_type: "completion",
      mode: "parity-complete",
      format: "both",
      write: true,
    });
    expectGatewayInvocation();
    expect(stdinRequest()).toMatchObject({
      operation: "completion-report",
      mode: "parity-complete",
      format: "both",
      write: true,
    });
  });

  it("runDiscoveryReport interactive invocation prompts only for the report type", async () => {
    showQuickPickMock.mockResolvedValueOnce("coverage");
    await handlerFor("runDiscoveryReport")();
    expect(showInputBoxMock).not.toHaveBeenCalled();
    expect(stdinRequest()).toMatchObject({
      operation: "coverage-report",
      mode: "structural",
      format: "json",
    });
  });

  it("runDiscoveryReport rejects the retired input_path contract without spawning", async () => {
    await expect(
      handlerFor("runDiscoveryReport")({
        report_type: "parity",
        input_path: "m.yaml",
      }),
    ).rejects.toThrow("does not accept inputPath");
    expect(childProcessMock.spawn).not.toHaveBeenCalled();
  });

  it("runDiscoveryDoctor runs the diagnostic without prompts on both paths", async () => {
    await handlerFor("runDiscoveryDoctor")({});
    await handlerFor("runDiscoveryDoctor")();
    expectGatewayInvocation();
    expect(stdinRequest(0)).toMatchObject({
      operation: "doctor",
      mode: "structural",
    });
    expect(stdinRequest(1)).toMatchObject({ operation: "doctor" });
    expect(showInputBoxMock).not.toHaveBeenCalled();
  });

  it("configureDiscoveryWorkspace direct activation and interactive deactivation", async () => {
    await handlerFor("configureDiscoveryWorkspace")({
      configuration_action: "activate",
      input_path: "docs/profile.yaml",
      dry_run: true,
    });
    expect(stdinRequest(0)).toMatchObject({
      operation: "configure",
      dry_run: true,
      inputs: {
        configuration_action: "activate",
        input_path: "docs/profile.yaml",
      },
    });

    showQuickPickMock.mockResolvedValueOnce("deactivate");
    await handlerFor("configureDiscoveryWorkspace")();
    expect(showInputBoxMock).not.toHaveBeenCalled();
    expect(stdinRequest(1)).toMatchObject({
      operation: "configure",
      inputs: { configuration_action: "deactivate" },
    });

    showQuickPickMock.mockResolvedValueOnce("activate");
    showInputBoxMock.mockResolvedValueOnce("docs/other.yaml");
    await handlerFor("configureDiscoveryWorkspace")();
    expect(stdinRequest(2)).toMatchObject({
      inputs: {
        configuration_action: "activate",
        input_path: "docs/other.yaml",
      },
    });
  });

  it("transferDiscoverySnapshot exports a prompted identity list and imports a direct manifest", async () => {
    showQuickPickMock.mockResolvedValueOnce("export");
    showInputBoxMock.mockResolvedValueOnce("orders.export, billing.invoice");
    await handlerFor("transferDiscoverySnapshot")();
    expect(stdinRequest(0)).toMatchObject({
      operation: "snapshot-export",
      inputs: { selected_ids: ["orders.export", "billing.invoice"] },
    });

    await handlerFor("transferDiscoverySnapshot")({
      direction: "import",
      manifest_path: "snapshots/manifest.json",
      write: true,
    });
    expect(stdinRequest(1)).toMatchObject({
      operation: "snapshot-import",
      write: true,
      inputs: { manifest_path: "snapshots/manifest.json" },
    });

    showQuickPickMock.mockResolvedValueOnce("import");
    showInputBoxMock.mockResolvedValueOnce("snapshots/other.json");
    await handlerFor("transferDiscoverySnapshot")();
    expect(stdinRequest(2)).toMatchObject({
      inputs: { manifest_path: "snapshots/other.json" },
    });
  });

  it("migrateDiscoveryArtifacts direct and interactive invocations send the v1-to-v2 request", async () => {
    await handlerFor("migrateDiscoveryArtifacts")({
      destination: "docs/migration/discovery",
      system_id: "crm",
      system_name: "Legacy CRM",
      system_role: "legacy-source",
      repository_id: "legacy-crm",
      paths: ["legacy/a.yaml"],
      dry_run: true,
    });
    expect(stdinRequest(0)).toMatchObject({
      operation: "migrate",
      dry_run: true,
      inputs: {
        from_version: 1,
        to_version: 2,
        destination: "docs/migration/discovery",
        paths: ["legacy/a.yaml"],
        system_role: "legacy-source",
      },
    });

    showInputBoxMock
      .mockResolvedValueOnce("docs/v2")
      .mockResolvedValueOnce("crm")
      .mockResolvedValueOnce("Legacy CRM")
      .mockResolvedValueOnce("legacy-crm")
      .mockResolvedValueOnce("legacy/profile.yaml");
    showQuickPickMock.mockResolvedValueOnce("combined");
    await handlerFor("migrateDiscoveryArtifacts")();
    expect(stdinRequest(1)).toMatchObject({
      operation: "migrate",
      inputs: {
        destination: "docs/v2",
        system_id: "crm",
        system_role: "combined",
        input_path: "legacy/profile.yaml",
      },
    });
  });

  it("surfaces a malformed gateway result as a blocking transport error", async () => {
    childProcessMock.spawn.mockImplementation((): MockChildProcess => {
      const child = createMockProcess(0, "ok: wrote discovery/x.json");
      spawnedProcesses.push(child);
      return child;
    });
    await expect(handlerFor("runDiscoveryRepoInventory")({})).rejects.toThrow(
      "DISCOVERY_RESULT_MALFORMED",
    );
  });

  it.each([
    ["validateDiscoveryArtifacts", "quick pick", [undefined], []],
    ["validateDiscoveryArtifacts", "artifact path", ["profile"], [undefined]],
    ["runDiscoveryInit", "system id", [], [undefined]],
    ["runDiscoveryInit", "system name", [], ["crm", undefined]],
    ["runDiscoveryInit", "system role", [undefined], ["crm", "Legacy CRM"]],
    [
      "runDiscoveryInit",
      "repository id",
      ["combined"],
      ["crm", "Legacy CRM", undefined],
    ],
    ["runDiscoveryReport", "report type", [undefined], []],
    ["configureDiscoveryWorkspace", "action", [undefined], []],
    ["configureDiscoveryWorkspace", "profile path", ["activate"], [undefined]],
    ["transferDiscoverySnapshot", "direction", [undefined], []],
    ["transferDiscoverySnapshot", "identities", ["export"], [" , "]],
    ["transferDiscoverySnapshot", "manifest", ["import"], [undefined]],
    ["migrateDiscoveryArtifacts", "destination", [], [undefined]],
    [
      "migrateDiscoveryArtifacts",
      "system role",
      [undefined],
      ["docs/v2", "crm", "n"],
    ],
    [
      "migrateDiscoveryArtifacts",
      "source file",
      ["combined"],
      ["docs/v2", "crm", "n", "r", undefined],
    ],
  ] as const)(
    "%s interactive invocation cancelled at the %s prompt neither spawns nor rejects",
    async (command, _prompt, quickPicks, inputs) => {
      for (const pick of quickPicks) {
        showQuickPickMock.mockResolvedValueOnce(pick);
      }
      for (const value of inputs) {
        showInputBoxMock.mockResolvedValueOnce(value);
      }
      await expect(handlerFor(command)()).resolves.toBeUndefined();
      expect(childProcessMock.spawn).not.toHaveBeenCalled();
      expect(createTerminalMock).not.toHaveBeenCalled();
    },
  );
});
