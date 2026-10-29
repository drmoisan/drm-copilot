/**
 * Prove the service-level prepare flow runs through the injected authority
 * provider, the root grant of the host gate and the fixed runtime.
 *
 * Prepare consumes the root grant of the call, pins the pre-invocation
 * baseline and the runtime identity through a recorded root `prepare-agent`
 * request before persisting protected bindings. Host options are forwarded
 * verbatim. The finalize flow is proved in
 * `repo-automation-service-discovery-agent.finalize.test.ts`.
 */

import { describe, expect, it, jest } from "@jest/globals";

jest.mock("vscode", () => ({}), { virtual: true });

import { invocationDirectory } from "../src/discovery-authority-paths";
import { BASELINE_RESULT_FILE } from "../src/discovery-invocation";
import { issueRootGrant, rootGrantPath } from "./discovery-grant-test-support";
import {
  baselineResult,
  capability,
  LOCATION,
  RUNTIME,
  seeded,
} from "./discovery-invocation-test-support";
import type { MemoryStoreIO } from "./discovery-store-test-helpers";
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

/** The raw MCP input of the prepare call; the root grant is bound to its digest. */
const PREPARE_RAW = {
  workspace_root: WS_ROOT,
  skill_id: "inventory-legacy-system",
};
/** Seed the root grant the native gate issued for the prepare call. */
function prepareGranted(io: MemoryStoreIO): MemoryStoreIO {
  issueRootGrant(io, {
    tool: "prepare_discovery_agent",
    operation: "prepare-agent",
    inputs: PREPARE_RAW,
  });
  return io;
}

/** Keys added to the store since `before`. */
function added(io: MemoryStoreIO, before: ReadonlySet<string>): string[] {
  return [...io.files.keys()].filter((key) => !before.has(key));
}

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
  const unobserved = {
    workspaceRoot: WS_ROOT,
    skillId: "inventory-legacy-system",
    selectedIds: ["legacy-crm"],
    paths: ["src/Orders"],
    expectedOutputs,
    executionContext: "standalone",
    complexity: "C2",
  };
  const request = { ...unobserved, toolInputs: PREPARE_RAW };

  it("consumes the root grant, pins the baseline through prepare-agent, persists protected bindings and returns the deployment", async () => {
    const io = prepareGranted(seeded());
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
    // The launch context is the consumed grant's host, session and parent.
    const record = JSON.parse(
      io.files.get(`${directory}/invocation.json`)!,
    ) as {
      host: string;
      session_id: string;
      parent_agent_id: string;
    };
    expect(record).toMatchObject({
      host: "codex",
      session_id: "session-alpha",
      parent_agent_id: "root-alpha",
    });
    expect(io.files.has(`${rootGrantPath()}.consumed`)).toBe(true);
    expect(io.files.get(`${directory}/${BASELINE_RESULT_FILE}`)).toBe(
      `${JSON.stringify(baseline, null, 2)}\n`,
    );
    expect(result.summary).toContain("legacy-parity-analyst");
  });

  it.each([
    ["without the raw tool input", unobserved, false],
    ["without a root grant for the call", request, false],
    ["with a root grant for another call", request, true],
  ])(
    "refuses a prepare %s before any runtime launch or protected write",
    async (_label, input, foreignGrant) => {
      const io = seeded();
      if (foreignGrant) {
        issueRootGrant(io, {
          tool: "prepare_discovery_agent",
          operation: "prepare-agent",
          inputs: { ...PREPARE_RAW, skill_id: "extract-feature-contract" },
        });
      }
      const before = new Set(io.files.keys());
      const launcher = new FakeLauncher(successOutcome(baselineResult()));
      await expect(
        service(launcher, provider(io)).prepareDiscoveryAgent(input),
      ).rejects.toThrow("DISCOVERY_HOST_BINDING_REQUIRED");
      expect(launcher.captures).toHaveLength(0);
      expect(added(io, before)).toEqual([]);
    },
  );

  it("refuses a replayed root grant as consumed", async () => {
    const io = prepareGranted(seeded());
    const launcher = new FakeLauncher(successOutcome(baselineResult()));
    const subject = service(launcher, provider(io));
    await subject.prepareDiscoveryAgent(request);
    await expect(subject.prepareDiscoveryAgent(request)).rejects.toThrow(
      "AUTHORIZATION_CONSUMED",
    );
    expect(launcher.captures).toHaveLength(1);
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
  ])(
    "refuses %s before any protected write beyond the consumed grant latch",
    async (_label, outcome, code) => {
      const io = prepareGranted(seeded());
      const before = new Set(io.files.keys());
      const launcher = new FakeLauncher(successOutcome(outcome));
      await expect(
        service(launcher, provider(io)).prepareDiscoveryAgent(request),
      ).rejects.toThrow(code);
      // The one-use grant is spent by the attempt; nothing protected is written.
      expect(added(io, before)).toEqual([`${rootGrantPath()}.consumed`]);
    },
  );

  it("names the blocking finding codes in the baseline refusal", async () => {
    const io = prepareGranted(seeded());
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
    const io = prepareGranted(seeded(capability({ status: "unsupported" })));
    const launcher = new FakeLauncher(successOutcome(baselineResult()));
    await expect(
      service(launcher, provider(io)).prepareDiscoveryAgent(request),
    ).rejects.toThrow("required discovery controls");
  });
});

describe("agent operations with explicit host options", () => {
  it("forwards the interpreter, invocation id, profile and ceiling to the prepare flow", async () => {
    const raw = {
      workspace_root: WS_ROOT,
      skill_id: "review-discovery-coverage",
    };
    const io = seeded();
    issueRootGrant(io, {
      tool: "prepare_discovery_agent",
      operation: "prepare-agent",
      inputs: raw,
    });
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
      toolInputs: raw,
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
});
