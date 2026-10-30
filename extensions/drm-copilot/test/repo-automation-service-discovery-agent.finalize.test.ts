/**
 * Prove the service-level finalize flow runs under the identity of the
 * one-use authorization the gate consumed for the invocation and mints the
 * receipt; without a consumed record the call is refused, never run as
 * local-user. Host options are forwarded verbatim.
 */

import { describe, expect, it, jest } from "@jest/globals";

jest.mock("vscode", () => ({}), { virtual: true });

import type { RepoAutomationService } from "../src/repo-automation-service";
import {
  ACTIVATION as FINAL_ACTIVATION,
  result as finalizeResult,
  scenario,
  type Scenario,
  WS,
} from "./discovery-finalization-test-support";
import {
  AUTHORIZATION_REF,
  issueAuthorization,
  startInvocation,
} from "./discovery-grant-test-support";
import { FakeLauncher, successOutcome } from "./discovery-test-helpers";
import {
  output,
  provider,
  service,
} from "./repo-automation-service-discovery-test-support";

const FINALIZE_RAW = (invocationRef: string) => ({
  workspace_root: WS.workspace_root,
  invocation_ref: invocationRef,
});

/**
 * Start the scenario's invocation, issue the finalize authorization and consume
 * it through the service, as the MCP gate does before the handler runs.
 */
function consumedFinalize(
  scene: Scenario,
  launcher: FakeLauncher,
): { subject: RepoAutomationService; authorizationRef: string } {
  startInvocation(scene.io, scene.invocationId);
  issueAuthorization(scene.io, {
    invocationId: scene.invocationId,
    tool: "finalize_discovery_agent",
    operation: "finalize-agent",
    inputs: FINALIZE_RAW(scene.invocationId),
    role: scene.role,
    workspace: WS,
  });
  const subject = service(
    launcher,
    provider(scene.io, {
      reader: scene.reader,
      activation: () => FINAL_ACTIVATION,
    }),
  );
  const authorizationRef = subject.consumeDiscoveryToolAuthorization!({
    workspaceRoot: WS.workspace_root,
    tool: "finalize_discovery_agent",
    operation: "finalize-agent",
    inputs: FINALIZE_RAW(scene.invocationId),
    invocationRef: scene.invocationId,
  });
  return { subject, authorizationRef };
}

describe("finalizeDiscoveryAgent", () => {
  it("runs finalize-agent under the consumed authorization's identity and mints the receipt", async () => {
    const scene = scenario();
    const launcher = new FakeLauncher(successOutcome(finalizeResult(scene)));
    const { subject, authorizationRef } = consumedFinalize(scene, launcher);
    const result = await subject.finalizeDiscoveryAgent({
      workspaceRoot: WS.workspace_root,
      invocationRef: scene.invocationId,
      requestId: "request-finalize",
      authorizationRef,
    });
    expect(launcher.request()).toMatchObject({
      operation: "finalize-agent",
      mode: "agent-output",
      invocation_ref: scene.invocationId,
      authorization_ref: AUTHORIZATION_REF,
      workspace_root: WS.workspace_root,
    });
    // Finalize runs under the host principal with the consumed record's identity,
    // never as local-user (P12-T3 transport, P15-T14 identity source).
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

  it("refuses to finalize without a consumed authorization", async () => {
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
    const { subject, authorizationRef } = consumedFinalize(scene, launcher);
    const result = await subject.finalizeDiscoveryAgent({
      workspaceRoot: WS.workspace_root,
      invocationRef: scene.invocationId,
      authorizationRef,
    });
    expect(launcher.request()).toMatchObject({
      authorization_ref: authorizationRef,
    });
    const receipt = JSON.parse(scene.io.files.get(result.artifacts![0]!)!) as {
      identity: { request_id: string; agent_id: string };
    };
    expect(receipt.identity.request_id).toBe(authorizationRef);
    expect(receipt.identity.agent_id).toBe("agent-alpha");
    expect(result.receipt?.validation_result).toBe("pass");
  });

  it("refuses a consumed authorization that binds another invocation and a reference consumed once already", async () => {
    const scene = scenario();
    const launcher = new FakeLauncher(successOutcome(finalizeResult(scene)));
    const { subject, authorizationRef } = consumedFinalize(scene, launcher);
    await expect(
      subject.finalizeDiscoveryAgent({
        workspaceRoot: WS.workspace_root,
        invocationRef: "invocation-other-000000001",
        authorizationRef,
      }),
    ).rejects.toThrow("FINALIZATION_IDENTITY_UNAVAILABLE");
    // The consumed record was handed out once; a second finalize with the same
    // reference has no record behind it.
    await expect(
      subject.finalizeDiscoveryAgent({
        workspaceRoot: WS.workspace_root,
        invocationRef: scene.invocationId,
        authorizationRef,
      }),
    ).rejects.toThrow("FINALIZATION_IDENTITY_UNAVAILABLE");
    expect(launcher.captures).toHaveLength(0);
  });
});

describe("finalize with explicit host options", () => {
  it("forwards the interpreter, invocation id and profile to the finalize flow", async () => {
    const scene = scenario();
    const launcher = new FakeLauncher(successOutcome(finalizeResult(scene)));
    const { subject, authorizationRef } = consumedFinalize(scene, launcher);
    const result = await subject.finalizeDiscoveryAgent({
      workspaceRoot: WS.workspace_root,
      invocationId: "finalize-custom",
      interpreter: "C:/custom/python.exe",
      profilePath: WS.profile_path,
      invocationRef: scene.invocationId,
      requestId: "request-finalize",
      authorizationRef,
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
