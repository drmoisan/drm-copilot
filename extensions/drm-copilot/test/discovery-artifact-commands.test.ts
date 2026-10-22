/**
 * Artifact-level discovery commands: create, link and generate.
 *
 * Each command runs through the real extension activation with the gateway
 * process mocked, so the assertions read the v2 request the shared service
 * wrote to the gateway stdin. Direct arguments bypass every prompt; interactive
 * invocations prompt only for the operation's required inputs and stop on
 * cancellation without spawning.
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
const SHA = "a".repeat(64);
let spawnedProcesses: MockChildProcess[] = [];

function stdinRequest(callIndex = 0): Record<string, unknown> {
  const child = spawnedProcesses[callIndex];
  if (child === undefined || child.stdin.written.length !== 1) {
    throw new Error("exactly one request document was expected on stdin");
  }
  return JSON.parse(child.stdin.written[0] ?? "") as Record<string, unknown>;
}

describe("discovery artifact commands", () => {
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

  it("registers the three artifact commands", () => {
    for (const commandId of [
      "drmCopilotExtension.createDiscoveryArtifact",
      "drmCopilotExtension.linkDiscoveryEvidence",
      "drmCopilotExtension.runDiscoveryScenarioGeneration",
    ]) {
      expect(activateAndGetHandler(commandId)).toBeDefined();
    }
  });

  it("createDiscoveryArtifact direct invocation drafts a feature contract under a grant", async () => {
    const handler = activateAndGetHandler(
      "drmCopilotExtension.createDiscoveryArtifact",
    );
    await handler({
      artifact_kind: "feature-contract",
      feature_id: "orders.export",
      name: "Order export",
      invocation_ref: "invocation-alpha-0000000001",
      write: true,
    });
    expect(stdinRequest()).toMatchObject({
      operation: "new-contract",
      mode: "agent-output",
      write: true,
      invocation_ref: "invocation-alpha-0000000001",
      inputs: { feature_id: "orders.export", name: "Order export" },
    });
    expect(showQuickPickMock).not.toHaveBeenCalled();
    expect(showInputBoxMock).not.toHaveBeenCalled();
  });

  it("createDiscoveryArtifact interactive invocation prompts per draft kind", async () => {
    showQuickPickMock.mockResolvedValueOnce("runtime-scenario");
    showInputBoxMock
      .mockResolvedValueOnce("orders.export.happy")
      .mockResolvedValueOnce("orders.export, billing.invoice");
    const handler = activateAndGetHandler(
      "drmCopilotExtension.createDiscoveryArtifact",
    );
    await handler();
    expect(stdinRequest()).toMatchObject({
      operation: "new-scenario",
      mode: "structural",
      inputs: {
        scenario_id: "orders.export.happy",
        feature_ids: ["orders.export", "billing.invoice"],
      },
    });

    showQuickPickMock.mockResolvedValueOnce("feature-contract");
    showInputBoxMock
      .mockResolvedValueOnce("orders.export")
      .mockResolvedValueOnce("Order export");
    await handler();
    expect(stdinRequest(1)).toMatchObject({
      operation: "new-contract",
      inputs: { feature_id: "orders.export", name: "Order export" },
    });
  });

  it("createDiscoveryArtifact rejects a draft mixing the two kinds without spawning", async () => {
    const handler = activateAndGetHandler(
      "drmCopilotExtension.createDiscoveryArtifact",
    );
    await expect(
      handler({
        artifact_kind: "feature-contract",
        feature_id: "f",
        name: "n",
        scenario_id: "s",
      }),
    ).rejects.toThrow("runtime-scenario");
    expect(childProcessMock.spawn).not.toHaveBeenCalled();
  });

  it("linkDiscoveryEvidence direct and interactive invocations bind the target digest", async () => {
    const handler = activateAndGetHandler(
      "drmCopilotExtension.linkDiscoveryEvidence",
    );
    await handler({
      artifact_kind: "feature-contract",
      artifact_id: "orders.export",
      evidence_path: "evidence/run-1.json",
      expected_sha256: SHA,
      dry_run: true,
    });
    expect(stdinRequest()).toMatchObject({
      operation: "link-evidence",
      dry_run: true,
      inputs: {
        artifact_kind: "feature-contract",
        artifact_id: "orders.export",
        evidence_path: "evidence/run-1.json",
        expected_sha256: SHA,
      },
    });

    showQuickPickMock.mockResolvedValueOnce("parity-matrix");
    showInputBoxMock
      .mockResolvedValueOnce("matrix.one")
      .mockResolvedValueOnce("evidence/run-2.json")
      .mockResolvedValueOnce(SHA);
    await handler();
    expect(stdinRequest(1)).toMatchObject({
      operation: "link-evidence",
      inputs: { artifact_kind: "parity-matrix", artifact_id: "matrix.one" },
    });
  });

  it("runDiscoveryScenarioGeneration direct invocation sends the acceptance kind and filters", async () => {
    const handler = activateAndGetHandler(
      "drmCopilotExtension.runDiscoveryScenarioGeneration",
    );
    await handler({
      acceptance_kind: "target-acceptance",
      feature_ids: ["orders.export"],
      output_format: "gherkin",
      workspace_root: "D:/other",
      profile_path: "docs/custom-profile.yaml",
    });
    const call = childProcessMock.spawn.mock.calls[0] as [
      string,
      string[],
      { cwd: string },
    ];
    expect(call[1]).toContain("D:/other");
    expect(call[2].cwd).toBe("D:/other");
    expect(stdinRequest()).toMatchObject({
      operation: "generate-acceptance",
      workspace_root: "D:/other",
      profile_path: "docs/custom-profile.yaml",
      inputs: {
        acceptance_kind: "target-acceptance",
        feature_ids: ["orders.export"],
        output_format: "gherkin",
      },
    });
  });

  it("runDiscoveryScenarioGeneration interactive invocation prompts only for the acceptance kind", async () => {
    showQuickPickMock.mockResolvedValueOnce("legacy-characterization");
    const handler = activateAndGetHandler(
      "drmCopilotExtension.runDiscoveryScenarioGeneration",
    );
    await handler();
    expect(showInputBoxMock).not.toHaveBeenCalled();
    expect(stdinRequest()).toMatchObject({
      operation: "generate-acceptance",
      workspace_root: WORKSPACE_ROOT,
      inputs: { acceptance_kind: "legacy-characterization" },
    });
  });

  it("runDiscoveryScenarioGeneration rejects the retired three-input contract without spawning", async () => {
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

  it.each([
    ["createDiscoveryArtifact", "draft kind", [undefined], []],
    [
      "createDiscoveryArtifact",
      "feature id",
      ["feature-contract"],
      [undefined],
    ],
    [
      "createDiscoveryArtifact",
      "feature name",
      ["feature-contract"],
      ["f", undefined],
    ],
    [
      "createDiscoveryArtifact",
      "scenario id",
      ["runtime-scenario"],
      [undefined],
    ],
    ["createDiscoveryArtifact", "feature ids", ["runtime-scenario"], ["s", ""]],
    ["linkDiscoveryEvidence", "artifact kind", [undefined], []],
    ["linkDiscoveryEvidence", "artifact id", ["feature-contract"], [undefined]],
    [
      "linkDiscoveryEvidence",
      "evidence path",
      ["feature-contract"],
      ["f", undefined],
    ],
    [
      "linkDiscoveryEvidence",
      "digest",
      ["feature-contract"],
      ["f", "e.json", undefined],
    ],
    ["runDiscoveryScenarioGeneration", "acceptance kind", [undefined], []],
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
