/**
 * Prove the MCP authorization gate: a discovery role's controlled tool call
 * consumes exactly one native grant and carries its reference into the
 * handler input, a root process bypasses the gate without any store read, and
 * the controlled operation set equals the pinned fixture.
 */

import * as fs from "node:fs";
import * as path from "node:path";

import { afterEach, describe, expect, it, jest } from "@jest/globals";

jest.mock("vscode", () => ({ window: { createTerminal: jest.fn() } }), {
  virtual: true,
});

import {
  CONTROLLED_OPERATIONS,
  CONTROLLED_TOOLS,
  DiscoveryAuthorizationError,
} from "../src/discovery-authorization";
import {
  admitControlledToolCall,
  deriveControlledOperation,
  isControlledTool,
  VALIDATE_ARTIFACT_OPERATIONS,
} from "../src/mcp-discovery-authorization-gate";
import { dispatchRepoAutomationTool } from "../src/mcp-tools";
import type { RepoAutomationService } from "../src/repo-automation-service";
import { FIXTURE_DIRECTORY } from "./discovery-authorization-test-support";
import { createMockService, type MockService } from "./mcp-server-test-service";

const WS = "C:/workspace";
const INVOCATION_REF = "invocation-0123456789abcdef0001";
const AUTHORIZATION_REF = "authz-alpha-0000000000000001";
const READ_INPUT = {
  workspace_root: WS,
  read_operation: "list",
  paths: ["src"],
  invocation_ref: INVOCATION_REF,
};

function roleService(
  role: string | null = "legacy-parity-analyst",
): MockService {
  const service = createMockService();
  (service as { discoveryRole?: () => string | null }).discoveryRole = () =>
    role;
  return service;
}

function codeOf(action: () => unknown): string {
  try {
    action();
  } catch (error) {
    if (error instanceof DiscoveryAuthorizationError) {
      return error.code;
    }
    throw error;
  }
  return "ADMITTED";
}

afterEach(() => {
  jest.clearAllMocks();
});

describe("controlled operation set", () => {
  it("equals the pinned host fixture in both order and membership", () => {
    const fixture = JSON.parse(
      fs.readFileSync(
        path.join(FIXTURE_DIRECTORY, "controlled-operations.json"),
        "utf8",
      ),
    ) as { controlled_operations: string[] };
    expect([...CONTROLLED_OPERATIONS]).toEqual(fixture.controlled_operations);
    expect(CONTROLLED_TOOLS).toHaveLength(11);
    expect(CONTROLLED_TOOLS.every((tool) => isControlledTool(tool))).toBe(true);
    expect(isControlledTool("run_discovery_doctor")).toBe(false);
  });
});

describe("deriveControlledOperation", () => {
  it.each([
    ["read_discovery_source", {}, "read-source"],
    ["run_discovery_repo_inventory", {}, "inventory"],
    ["run_discovery_dotnet_analyzer", {}, "inventory"],
    ["run_discovery_vsto_analyzer", {}, "inventory"],
    ["update_discovery_artifact", {}, "update-artifact"],
    ["link_discovery_evidence", {}, "link-evidence"],
    ["run_discovery_scenario_generation", {}, "generate-acceptance"],
    ["finalize_discovery_agent", {}, "finalize-agent"],
    [
      "create_discovery_artifact",
      { artifact_kind: "feature-contract" },
      "new-contract",
    ],
    [
      "create_discovery_artifact",
      { artifact_kind: "runtime-scenario" },
      "new-scenario",
    ],
    [
      "create_discovery_artifact",
      { artifact_kind: "runtime-characterization-scenario" },
      "new-scenario",
    ],
    ["create_discovery_artifact", { artifact_kind: "scope" }, null],
    ["create_discovery_artifact", {}, null],
    ["run_discovery_report", { report_type: "coverage" }, "coverage-report"],
    ["run_discovery_report", { report_type: "parity" }, "parity-report"],
    [
      "run_discovery_report",
      { report_type: "completion" },
      "completion-report",
    ],
    ["run_discovery_report", { report_type: "summary" }, null],
    ["run_discovery_report", { report_type: 7 }, null],
    ["validate_discovery_artifacts", {}, "validate-all"],
    ["validate_discovery_artifacts", { artifact_type: null }, "validate-all"],
    ["validate_discovery_artifacts", { artifact_type: "unknown" }, null],
    ["validate_discovery_artifacts", { artifact_type: 3 }, null],
    ["run_discovery_doctor", {}, null],
    ["run_shell", {}, null],
  ])("derives %s with %j as %s", (tool, inputs, expected) => {
    expect(deriveControlledOperation(tool, inputs)).toBe(expected);
  });

  it.each(Object.entries(VALIDATE_ARTIFACT_OPERATIONS))(
    "maps artifact_type %s to %s like the native adapter",
    (artifactType, operation) => {
      expect(
        deriveControlledOperation("validate_discovery_artifacts", {
          artifact_type: artifactType,
        }),
      ).toBe(operation);
      expect(CONTROLLED_OPERATIONS).toContain(operation);
    },
  );
});

describe("admitControlledToolCall", () => {
  it("returns the raw input unchanged for a root process without consulting the store", () => {
    const service = createMockService();
    const rawInput = { ...READ_INPUT };

    const admitted = admitControlledToolCall(
      "read_discovery_source",
      rawInput,
      service,
    );

    expect(admitted).toBe(rawInput);
    expect(service.consumeDiscoveryToolAuthorization).not.toHaveBeenCalled();
  });

  it("consumes the bound grant for a role and forwards its reference", () => {
    const service = roleService();
    service.consumeDiscoveryToolAuthorization!.mockReturnValue(
      AUTHORIZATION_REF,
    );

    const admitted = admitControlledToolCall(
      "read_discovery_source",
      READ_INPUT,
      service,
    );

    expect(admitted).toEqual({
      ...READ_INPUT,
      authorization_ref: AUTHORIZATION_REF,
    });
    expect(service.consumeDiscoveryToolAuthorization).toHaveBeenCalledWith({
      workspaceRoot: WS,
      tool: "read_discovery_source",
      operation: "read-source",
      inputs: READ_INPUT,
      invocationRef: INVOCATION_REF,
    });
  });

  it("digests the raw input as received, including fields the resolver drops", () => {
    const service = roleService();
    service.consumeDiscoveryToolAuthorization!.mockReturnValue(
      AUTHORIZATION_REF,
    );
    const raw = {
      workspace_root: WS,
      report_type: "coverage",
      invocation_ref: INVOCATION_REF,
      note: "kept verbatim",
    };

    admitControlledToolCall("run_discovery_report", raw, service);

    expect(service.consumeDiscoveryToolAuthorization).toHaveBeenCalledWith(
      expect.objectContaining({ operation: "coverage-report", inputs: raw }),
    );
  });

  it.each([
    ["a non-object input", "text", "AUTHORIZATION_REQUEST_INVALID"],
    [
      "a caller-supplied authorization_ref",
      { ...READ_INPUT, authorization_ref: AUTHORIZATION_REF },
      "AUTHORIZATION_REQUEST_INVALID",
    ],
    [
      "a missing invocation_ref",
      { workspace_root: WS, read_operation: "list", paths: ["src"] },
      "AUTHORIZATION_REQUEST_INVALID",
    ],
    [
      "a missing workspace_root",
      {
        read_operation: "list",
        paths: ["src"],
        invocation_ref: INVOCATION_REF,
      },
      "AUTHORIZATION_REQUEST_INVALID",
    ],
  ])("refuses %s before any consumption", (_label, rawInput, code) => {
    const service = roleService();

    expect(
      codeOf(() =>
        admitControlledToolCall("read_discovery_source", rawInput, service),
      ),
    ).toBe(code);
    expect(service.consumeDiscoveryToolAuthorization).not.toHaveBeenCalled();
  });

  it("refuses an underivable operation before any consumption", () => {
    const service = roleService();

    expect(
      codeOf(() =>
        admitControlledToolCall(
          "create_discovery_artifact",
          {
            workspace_root: WS,
            artifact_kind: "scope",
            invocation_ref: INVOCATION_REF,
          },
          service,
        ),
      ),
    ).toBe("AUTHORIZATION_OPERATION_UNKNOWN");
    expect(service.consumeDiscoveryToolAuthorization).not.toHaveBeenCalled();
  });

  it("fails closed when the service has no consumption seam", () => {
    const service = roleService() as RepoAutomationService & {
      consumeDiscoveryToolAuthorization?: unknown;
    };
    delete service.consumeDiscoveryToolAuthorization;

    expect(
      codeOf(() =>
        admitControlledToolCall("read_discovery_source", READ_INPUT, service),
      ),
    ).toBe("AUTHORIZATION_MISSING");
  });

  it("propagates the consumer's refusal so a replay is reported as consumed", () => {
    const service = roleService();
    service.consumeDiscoveryToolAuthorization!.mockImplementation(() => {
      throw new DiscoveryAuthorizationError(
        "AUTHORIZATION_CONSUMED",
        "already consumed",
      );
    });

    expect(
      codeOf(() =>
        admitControlledToolCall("read_discovery_source", READ_INPUT, service),
      ),
    ).toBe("AUTHORIZATION_CONSUMED");
  });
});

describe("controlled tool dispatch through the gate", () => {
  it("forwards the consumed reference into the resolved service input", async () => {
    const service = roleService();
    service.consumeDiscoveryToolAuthorization!.mockReturnValue(
      AUTHORIZATION_REF,
    );
    service.readDiscoverySource.mockResolvedValue({
      tool: "read_discovery_source",
      workspaceRoot: WS,
      summary: "read",
    });

    const result = await dispatchRepoAutomationTool(
      "read_discovery_source",
      READ_INPUT,
      service,
    );

    expect(result.ok).toBe(true);
    expect(service.readDiscoverySource).toHaveBeenCalledWith(
      expect.objectContaining({
        invocationRef: INVOCATION_REF,
        authorizationRef: AUTHORIZATION_REF,
        mode: "agent-output",
      }),
    );
  });

  it("forwards the consumed reference to finalize", async () => {
    const service = roleService();
    service.consumeDiscoveryToolAuthorization!.mockReturnValue(
      AUTHORIZATION_REF,
    );
    service.finalizeDiscoveryAgent.mockResolvedValue({
      tool: "finalize_discovery_agent",
      workspaceRoot: WS,
      summary: "finalized",
    });

    await dispatchRepoAutomationTool(
      "finalize_discovery_agent",
      { workspace_root: WS, invocation_ref: INVOCATION_REF, request_id: "r" },
      service,
    );

    expect(service.consumeDiscoveryToolAuthorization).toHaveBeenCalledWith(
      expect.objectContaining({
        tool: "finalize_discovery_agent",
        operation: "finalize-agent",
      }),
    );
    expect(service.finalizeDiscoveryAgent).toHaveBeenCalledWith(
      expect.objectContaining({ authorizationRef: AUTHORIZATION_REF }),
    );
  });

  it("refuses the second call with the same input as consumed and never reaches the service", async () => {
    const service = roleService();
    service
      .consumeDiscoveryToolAuthorization!.mockReturnValueOnce(AUTHORIZATION_REF)
      .mockImplementationOnce(() => {
        throw new DiscoveryAuthorizationError(
          "AUTHORIZATION_CONSUMED",
          "Authorization was already consumed.",
        );
      });
    service.readDiscoverySource.mockResolvedValue({
      tool: "read_discovery_source",
      workspaceRoot: WS,
      summary: "read",
    });

    const first = await dispatchRepoAutomationTool(
      "read_discovery_source",
      READ_INPUT,
      service,
    );
    const second = await dispatchRepoAutomationTool(
      "read_discovery_source",
      READ_INPUT,
      service,
    );

    expect(first.ok).toBe(true);
    expect(second.ok).toBe(false);
    expect(second.summary).toContain("AUTHORIZATION_CONSUMED");
    expect(service.readDiscoverySource).toHaveBeenCalledTimes(1);
  });

  it("lets a root process call controlled tools without any authorization read", async () => {
    const service = createMockService();
    service.readDiscoverySource.mockResolvedValue({
      tool: "read_discovery_source",
      workspaceRoot: WS,
      summary: "read",
    });

    const result = await dispatchRepoAutomationTool(
      "read_discovery_source",
      { workspace_root: WS, read_operation: "list", paths: ["src"] },
      service,
    );

    expect(result.ok).toBe(true);
    expect(service.consumeDiscoveryToolAuthorization).not.toHaveBeenCalled();
    expect(service.readDiscoverySource).toHaveBeenCalledWith(
      expect.not.objectContaining({ authorizationRef: expect.anything() }),
    );
  });
});
