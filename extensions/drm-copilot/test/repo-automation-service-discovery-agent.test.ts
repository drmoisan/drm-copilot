/**
 * Prove the service-level prepare and finalize flows run through the injected
 * authority provider and the fixed runtime.
 *
 * Prepare pins the pre-invocation baseline and the runtime identity through a
 * recorded root `prepare-agent` request before persisting protected bindings;
 * finalize runs `finalize-agent` for the invocation and mints the receipt.
 * Host options are forwarded verbatim.
 */

import { describe, expect, it, jest } from "@jest/globals";

jest.mock("vscode", () => ({}), { virtual: true });

import { invocationDirectory } from "../src/discovery-authority-paths";
import { BASELINE_RESULT_FILE } from "../src/discovery-invocation";
import {
  ACTIVATION as FINAL_ACTIVATION,
  result as finalizeResult,
  scenario,
  WS,
} from "./discovery-finalization-test-support";
import {
  baselineResult,
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
  const expectedOutputs = [
    {
      artifact_kind: "inventory-snapshot",
      id: "output-one",
      path: "out/inventory.json",
      format: "json",
      expected_sha256: null,
    },
  ];
  const request = {
    workspaceRoot: WS_ROOT,
    skillId: "inventory-legacy-system",
    selectedIds: ["legacy-crm"],
    paths: ["src/Orders"],
    expectedOutputs,
    executionContext: "standalone",
    complexity: "C2",
  };

  it("pins the baseline through prepare-agent, persists protected bindings and returns the deployment", async () => {
    const io = seeded();
    const baseline = baselineResult();
    const launcher = new FakeLauncher(successOutcome(baseline));
    const result = await service(launcher, provider(io)).prepareDiscoveryAgent(
      request,
    );
    // Exactly one runtime call, the root prepare-agent request; doctor is not called.
    expect(launcher.captures).toHaveLength(1);
    expect(launcher.request()).toMatchObject({
      operation: "prepare-agent",
      mode: "structural",
      workspace_root: WS_ROOT,
      invocation_ref: null,
      authorization_ref: null,
      inputs: {
        skill_id: "inventory-legacy-system",
        selected_ids: ["legacy-crm"],
        paths: ["src/Orders"],
        expected_outputs: expectedOutputs,
        execution_context: "standalone",
        complexity: "C2",
      },
    });
    expect(launcher.single().args).toEqual(
      expect.arrayContaining(["--principal", "local-user"]),
    );
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
      `${directory}/${BASELINE_RESULT_FILE}`,
    ]);
    expect(io.files.has(`${directory}/invocation.json`)).toBe(true);
    expect(io.files.get(`${directory}/${BASELINE_RESULT_FILE}`)).toBe(
      `${JSON.stringify(baseline, null, 2)}\n`,
    );
    expect(result.summary).toContain("legacy-parity-analyst");
  });

  it.each([
    [
      "a blocking prepare-agent result",
      baselineResult({
        ok: false,
        exit_code: 1,
        findings: [
          {
            code: "PREPARE_OUTPUT_DIGEST",
            severity: "error",
            artifact_path: "out/inventory.json",
            pointer: "/inputs/expected_outputs",
            related_ids: [],
            related_paths: [],
            message:
              "The expected output digest differs from the captured bytes.",
            next_action: "Correct the expected output row and prepare again.",
          },
        ],
      }),
      "DISCOVERY_PREPARE_BASELINE_FAILED",
    ],
    [
      "a refused prepare-agent result",
      baselineResult({ ok: false, exit_code: 3, runtime: null }),
      "DISCOVERY_PREPARE_BASELINE_FAILED",
    ],
    [
      "a result of another operation",
      buildServiceResult({ operation: "doctor", runtime: RUNTIME }),
      "DISCOVERY_PREPARE_BASELINE_FAILED",
    ],
  ])("refuses %s before touching the store", async (_label, outcome, code) => {
    const io = seeded();
    const before = io.writtenPaths().length;
    const launcher = new FakeLauncher(successOutcome(outcome));
    await expect(
      service(launcher, provider(io)).prepareDiscoveryAgent(request),
    ).rejects.toThrow(code);
    expect(io.writtenPaths()).toHaveLength(before);
  });

  it("names the blocking finding codes in the baseline refusal", async () => {
    const io = seeded();
    const launcher = new FakeLauncher(
      successOutcome(
        baselineResult({
          ok: false,
          exit_code: 1,
          findings: [
            {
              code: "PREPARE_OUTPUT_LOCATION",
              severity: "error",
              artifact_path: "out/inventory.json",
              pointer: "/inputs/expected_outputs",
              related_ids: [],
              related_paths: [],
              message: "The expected output is not writable for its kind.",
              next_action: "Correct the expected output row and prepare again.",
            },
          ],
        }),
      ),
    );
    await expect(
      service(launcher, provider(io)).prepareDiscoveryAgent(request),
    ).rejects.toThrow("PREPARE_OUTPUT_LOCATION");
  });

  it("refuses an unsupported capability through the protected store", async () => {
    const io = seeded(capability({ status: "unsupported" }));
    const launcher = new FakeLauncher(successOutcome(baselineResult()));
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
    // Finalize runs under the host principal with the trusted identity set,
    // never as local-user (P12-T3 transport).
    expect(launcher.single().args.slice(-10)).toEqual([
      "--principal",
      "host",
      "--author-id",
      "agent-alpha",
      "--session-id",
      "session-alpha",
      "--host-name",
      "codex",
      "--agent-role",
      scene.role,
    ]);
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

  it("correlates a gated finalize by its consumed authorization when no request_id is supplied", async () => {
    // The native hook and the MCP gate refuse caller identity fields such as
    // request_id, so the agent's finalize arrives with the forwarded grant only.
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
      authorizationRef: "authz-alpha-0000000000000001",
    });
    expect(launcher.request()).toMatchObject({
      authorization_ref: "authz-alpha-0000000000000001",
    });
    const receipt = JSON.parse(scene.io.files.get(result.artifacts![0]!)!) as {
      identity: { request_id: string };
    };
    expect(receipt.identity.request_id).toBe("authz-alpha-0000000000000001");
    expect(result.receipt?.validation_result).toBe("pass");
  });

  it("refuses a finalize that carries neither a request_id nor a consumed authorization", async () => {
    const scene = scenario();
    const launcher = new FakeLauncher(successOutcome(finalizeResult(scene)));
    await expect(
      service(
        launcher,
        provider(scene.io, {
          agent: { agentId: "agent-alpha", role: scene.role },
          reader: scene.reader,
          activation: () => FINAL_ACTIVATION,
        }),
      ).finalizeDiscoveryAgent({
        workspaceRoot: WS.workspace_root,
        invocationRef: scene.invocationId,
      }),
    ).rejects.toThrow("FINALIZATION_REQUEST_INVALID");
    expect(launcher.captures).toHaveLength(0);
  });
});

describe("agent operations with explicit host options", () => {
  it("forwards the interpreter, invocation id, profile and ceiling to the prepare flow", async () => {
    const io = seeded();
    const launcher = new FakeLauncher(successOutcome(baselineResult()));
    const result = await service(launcher, provider(io)).prepareDiscoveryAgent({
      workspaceRoot: WS_ROOT,
      invocationId: "prepare-custom",
      interpreter: "C:/custom/python.exe",
      profilePath: "docs/migration/discovery/domain-profile.yaml",
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
    // The ceiling steers TypeScript routing only; the Python request matrix does not admit it.
    const sent = launcher.request();
    expect(sent).toMatchObject({
      operation: "prepare-agent",
      profile_path: "docs/migration/discovery/domain-profile.yaml",
    });
    expect(
      Object.keys(sent["inputs"] as Record<string, unknown>).sort(),
    ).toEqual([
      "complexity",
      "execution_context",
      "expected_outputs",
      "paths",
      "selected_ids",
      "skill_id",
    ]);
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
    expect(launcher.single().args).toEqual(
      expect.arrayContaining([
        "--principal",
        "host",
        "--agent-role",
        scene.role,
      ]),
    );
    expect(result.receipt?.planning_authorized).toBe(true);
    expect(output.appendLine).toHaveBeenCalledWith(
      expect.stringContaining("[finalize-custom]"),
    );
  });
});
