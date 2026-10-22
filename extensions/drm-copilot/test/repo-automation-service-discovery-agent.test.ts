/**
 * Prove the service-level prepare and finalize flows run through the injected
 * authority provider and the fixed runtime.
 *
 * Prepare pins the runtime identity through a recorded `doctor` request before
 * persisting protected bindings; finalize runs `finalize-agent` for the
 * invocation and mints the receipt. Host options are forwarded verbatim.
 */

import { describe, expect, it, jest } from "@jest/globals";

jest.mock("vscode", () => ({}), { virtual: true });

import { invocationDirectory } from "../src/discovery-authority-paths";
import {
  ACTIVATION as FINAL_ACTIVATION,
  result as finalizeResult,
  scenario,
  WS,
} from "./discovery-finalization-test-support";
import {
  capability,
  LOCATION,
  RUNTIME,
  seeded,
} from "./discovery-invocation-test-support";
import {
  buildServiceResult,
  FakeLauncher,
  successOutcome,
} from "./discovery-test-helpers";
import {
  output,
  provider,
  service,
  WS_ROOT,
} from "./repo-automation-service-discovery-test-support";

describe("prepareDiscoveryAgent", () => {
  const request = {
    workspaceRoot: WS_ROOT,
    skillId: "inventory-legacy-system",
    selectedIds: ["legacy-crm"],
    paths: ["src/Orders"],
    expectedOutputs: [
      {
        artifact_kind: "inventory-snapshot",
        id: "output-one",
        path: "out/inventory.json",
        format: "json",
        expected_sha256: null,
      },
    ],
    executionContext: "standalone",
    complexity: "C2",
  };

  it("pins the runtime through doctor, persists protected bindings and returns the deployment", async () => {
    const io = seeded();
    const launcher = new FakeLauncher(
      successOutcome(
        buildServiceResult({ operation: "doctor", runtime: RUNTIME }),
      ),
    );
    const result = await service(launcher, provider(io)).prepareDiscoveryAgent(
      request,
    );
    expect(launcher.request()).toMatchObject({
      operation: "doctor",
      workspace_root: WS_ROOT,
    });
    expect(result.tool).toBe("prepare_discovery_agent");
    expect(result.invocation).toMatchObject({
      invocation_id: "invocation-0123456789abcdef0001",
      role: "legacy-parity-analyst",
      skill_id: "inventory-legacy-system",
      deployment: {
        agent_name: "legacy-parity-analyst-c2",
        model: "gpt-6.1-sol",
        reasoning_effort: "medium",
        complexity: "C2",
      },
      mirror_path:
        "artifacts/discovery/invocations/invocation-0123456789abcdef0001.json",
    });
    const directory = invocationDirectory(
      LOCATION,
      "session-alpha",
      "invocation-0123456789abcdef0001",
    );
    expect(result.artifacts).toEqual([
      `${directory}/invocation.json`,
      `${directory}/topology-receipt.json`,
      `${directory}/model-receipt.json`,
      `${directory}/required-outputs.json`,
    ]);
    expect(io.files.has(`${directory}/invocation.json`)).toBe(true);
    expect(result.summary).toContain("legacy-parity-analyst");
  });

  it.each([
    [
      "an unhealthy doctor result",
      buildServiceResult({
        operation: "doctor",
        ok: false,
        exit_code: 1,
        runtime: RUNTIME,
      }),
    ],
    [
      "a doctor result without runtime identity",
      buildServiceResult({ operation: "doctor", runtime: null }),
    ],
  ])("refuses %s before touching the store", async (_label, doctor) => {
    const io = seeded();
    const before = io.writtenPaths().length;
    const launcher = new FakeLauncher(successOutcome(doctor));
    await expect(
      service(launcher, provider(io)).prepareDiscoveryAgent(request),
    ).rejects.toThrow("DISCOVERY_RUNTIME_IDENTITY_UNAVAILABLE");
    expect(io.writtenPaths()).toHaveLength(before);
  });

  it("refuses an unsupported capability through the protected store", async () => {
    const io = seeded(capability({ status: "unsupported" }));
    const launcher = new FakeLauncher(
      successOutcome(
        buildServiceResult({ operation: "doctor", runtime: RUNTIME }),
      ),
    );
    await expect(
      service(launcher, provider(io)).prepareDiscoveryAgent(request),
    ).rejects.toThrow("required discovery controls");
  });
});

describe("finalizeDiscoveryAgent", () => {
  it("runs finalize-agent for the invocation and mints the receipt", async () => {
    const scene = scenario();
    const launcher = new FakeLauncher(successOutcome(finalizeResult(scene)));
    const authority = provider(scene.io, {
      agent: { agentId: "agent-alpha", role: scene.role },
      reader: scene.reader,
      activation: () => FINAL_ACTIVATION,
    });
    const result = await service(launcher, authority).finalizeDiscoveryAgent({
      workspaceRoot: WS.workspace_root,
      invocationRef: scene.invocationId,
      requestId: "request-finalize",
    });
    expect(launcher.request()).toMatchObject({
      operation: "finalize-agent",
      mode: "agent-output",
      invocation_ref: scene.invocationId,
      workspace_root: WS.workspace_root,
    });
    expect(result.tool).toBe("finalize_discovery_agent");
    expect(result.receipt).toMatchObject({
      validation_result: "pass",
      output_valid: true,
      planning_authorized: true,
    });
    expect(result.receipt?.receipt_ref).toMatch(/^receipt-[0-9a-f]{64}$/u);
    expect(result.artifacts?.[0]).toContain("/receipts/");
    expect(result.discovery).toEqual(finalizeResult(scene));
  });

  it("refuses to finalize without a trusted agent identity", async () => {
    const scene = scenario();
    const launcher = new FakeLauncher(successOutcome(finalizeResult(scene)));
    await expect(
      service(
        launcher,
        provider(scene.io, {
          reader: scene.reader,
          activation: () => FINAL_ACTIVATION,
        }),
      ).finalizeDiscoveryAgent({
        workspaceRoot: WS.workspace_root,
        invocationRef: scene.invocationId,
        requestId: "request-finalize",
      }),
    ).rejects.toThrow("FINALIZATION_IDENTITY_UNAVAILABLE");
    expect(launcher.captures).toHaveLength(0);
  });
});

describe("agent operations with explicit host options", () => {
  it("forwards the interpreter, invocation id and ceiling to the prepare flow", async () => {
    const io = seeded();
    const launcher = new FakeLauncher(
      successOutcome(
        buildServiceResult({ operation: "doctor", runtime: RUNTIME }),
      ),
    );
    const result = await service(launcher, provider(io)).prepareDiscoveryAgent({
      workspaceRoot: WS_ROOT,
      invocationId: "prepare-custom",
      interpreter: "C:/custom/python.exe",
      skillId: "review-discovery-coverage",
      selectedIds: [],
      paths: [],
      expectedOutputs: [
        {
          artifact_kind: "coverage-report",
          id: "report-one",
          path: "out/coverage.json",
          format: "json",
          expected_sha256: null,
        },
      ],
      executionContext: "epic_execution_child",
      complexity: "C3",
      orchestrationComplexityCeiling: "C4",
    });
    expect(launcher.single().executable).toBe("C:/custom/python.exe");
    expect(result.invocation?.deployment).toMatchObject({
      agent_name: "migration-coverage-reviewer-c3-elevated",
      model: "gpt-6-astra",
      execution_context: "epic_execution_child",
    });
    expect(output.appendLine).toHaveBeenCalledWith(
      expect.stringContaining("[prepare-custom]"),
    );
  });

  it("forwards the interpreter, invocation id and profile to the finalize flow", async () => {
    const scene = scenario();
    const launcher = new FakeLauncher(successOutcome(finalizeResult(scene)));
    const authority = provider(scene.io, {
      agent: { agentId: "agent-alpha", role: scene.role },
      reader: scene.reader,
      activation: () => FINAL_ACTIVATION,
    });
    const result = await service(launcher, authority).finalizeDiscoveryAgent({
      workspaceRoot: WS.workspace_root,
      invocationId: "finalize-custom",
      interpreter: "C:/custom/python.exe",
      profilePath: WS.profile_path,
      invocationRef: scene.invocationId,
      requestId: "request-finalize",
    });
    expect(launcher.single().executable).toBe("C:/custom/python.exe");
    expect(launcher.request()).toMatchObject({ profile_path: WS.profile_path });
    expect(result.receipt?.planning_authorized).toBe(true);
    expect(output.appendLine).toHaveBeenCalledWith(
      expect.stringContaining("[finalize-custom]"),
    );
  });
});
