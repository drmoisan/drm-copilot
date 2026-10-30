/**
 * Prove the MCP authorization gate: a controlled call carrying `invocation_ref`
 * consumes exactly one native tool authorization and carries its reference into
 * the handler input, a controlled call without it consumes exactly one root
 * grant and carries that reference, neither path reaches the handler without a
 * record, and the controlled operation set equals the pinned fixture.
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
import {
  createMockService,
  MOCK_ROOT_GRANT_REF,
  type MockService,
} from "./mcp-server-test-service";

const WS = "C:/workspace";
const INVOCATION_REF = "invocation-0123456789abcdef0001";
const AUTHORIZATION_REF = "authz-alpha-0000000000000001";
const ROOT_READ_INPUT = {
  workspace_root: WS,
  read_operation: "list",
  paths: ["src"],
};
const READ_INPUT = { ...ROOT_READ_INPUT, invocation_ref: INVOCATION_REF };

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

function refusing(
  code: "AUTHORIZATION_CONSUMED" | "DISCOVERY_HOST_BINDING_REQUIRED",
) {
  return () => {
    throw new DiscoveryAuthorizationError(code, `${code} raised by the seam`);
  };
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
    expect(CONTROLLED_TOOLS).toHaveLength(12);
    expect(CONTROLLED_TOOLS.every((tool) => isControlledTool(tool))).toBe(true);
    expect(isControlledTool("discovery_capability_sentinel")).toBe(true);
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
    ["discovery_capability_sentinel", {}, "sentinel"],
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

describe("admitControlledToolCall for a specialist call (invocation_ref present)", () => {
  it("consumes the grant bound to the invocation and forwards its reference", () => {
    const service = createMockService();
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
    expect(service.consumeDiscoveryRootGrant).not.toHaveBeenCalled();
  });

  it("digests the raw input as received, including fields the resolver drops", () => {
    const service = createMockService();
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

  it("refuses an empty invocation_ref before any consumption", () => {
    const service = createMockService();

    expect(
      codeOf(() =>
        admitControlledToolCall(
          "read_discovery_source",
          { ...ROOT_READ_INPUT, invocation_ref: "" },
          service,
        ),
      ),
    ).toBe("AUTHORIZATION_REQUEST_INVALID");
    expect(service.consumeDiscoveryToolAuthorization).not.toHaveBeenCalled();
    expect(service.consumeDiscoveryRootGrant).not.toHaveBeenCalled();
  });

  it("fails closed when the service has no authorization seam", () => {
    const service = createMockService() as RepoAutomationService & {
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
    const service = createMockService();
    service.consumeDiscoveryToolAuthorization!.mockImplementation(
      refusing("AUTHORIZATION_CONSUMED"),
    );

    expect(
      codeOf(() =>
        admitControlledToolCall("read_discovery_source", READ_INPUT, service),
      ),
    ).toBe("AUTHORIZATION_CONSUMED");
  });
});

describe("admitControlledToolCall for a root call (invocation_ref absent)", () => {
  it("consumes the root grant for the tool, operation and digest and forwards its reference", () => {
    const service = createMockService();

    const admitted = admitControlledToolCall(
      "read_discovery_source",
      ROOT_READ_INPUT,
      service,
    );

    expect(admitted).toEqual({
      ...ROOT_READ_INPUT,
      root_grant_ref: MOCK_ROOT_GRANT_REF,
    });
    expect(service.consumeDiscoveryRootGrant).toHaveBeenCalledWith({
      workspaceRoot: WS,
      tool: "read_discovery_source",
      operation: "read-source",
      inputs: ROOT_READ_INPUT,
    });
    expect(service.consumeDiscoveryToolAuthorization).not.toHaveBeenCalled();
  });

  it("refuses when no root grant was issued and never falls back to an unverified root", () => {
    const service = createMockService();
    service.consumeDiscoveryRootGrant!.mockImplementation(
      refusing("DISCOVERY_HOST_BINDING_REQUIRED"),
    );

    expect(
      codeOf(() =>
        admitControlledToolCall(
          "read_discovery_source",
          ROOT_READ_INPUT,
          service,
        ),
      ),
    ).toBe("DISCOVERY_HOST_BINDING_REQUIRED");
  });

  it("fails closed when the service has no root grant seam", () => {
    const service = createMockService() as RepoAutomationService & {
      consumeDiscoveryRootGrant?: unknown;
    };
    delete service.consumeDiscoveryRootGrant;

    expect(
      codeOf(() =>
        admitControlledToolCall(
          "read_discovery_source",
          ROOT_READ_INPUT,
          service,
        ),
      ),
    ).toBe("DISCOVERY_HOST_BINDING_REQUIRED");
  });
});

describe("admitControlledToolCall refusals before any consumption", () => {
  it.each([
    ["a non-object input", "text", "AUTHORIZATION_REQUEST_INVALID"],
    [
      "a caller-supplied authorization_ref",
      { ...READ_INPUT, authorization_ref: AUTHORIZATION_REF },
      "AUTHORIZATION_REQUEST_INVALID",
    ],
    [
      "a caller-supplied root_grant_ref",
      { ...ROOT_READ_INPUT, root_grant_ref: MOCK_ROOT_GRANT_REF },
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
  ])("refuses %s", (_label, rawInput, code) => {
    const service = createMockService();

    expect(
      codeOf(() =>
        admitControlledToolCall("read_discovery_source", rawInput, service),
      ),
    ).toBe(code);
    expect(service.consumeDiscoveryToolAuthorization).not.toHaveBeenCalled();
    expect(service.consumeDiscoveryRootGrant).not.toHaveBeenCalled();
  });

  it("refuses an underivable operation", () => {
    const service = createMockService();

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
    expect(service.consumeDiscoveryRootGrant).not.toHaveBeenCalled();
  });
});

describe("controlled tool dispatch through the gate", () => {
  function readService(): MockService {
    const service = createMockService();
    service.readDiscoverySource.mockResolvedValue({
      tool: "read_discovery_source",
      workspaceRoot: WS,
      summary: "read",
    });
    return service;
  }

  it("forwards the consumed authorization reference into the resolved service input", async () => {
    const service = readService();
    service.consumeDiscoveryToolAuthorization!.mockReturnValue(
      AUTHORIZATION_REF,
    );

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
    const service = createMockService();
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

  it("refuses the second specialist call with the same input as consumed and never reaches the service", async () => {
    const service = readService();
    service
      .consumeDiscoveryToolAuthorization!.mockReturnValueOnce(AUTHORIZATION_REF)
      .mockImplementationOnce(refusing("AUTHORIZATION_CONSUMED"));

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

  it("admits a root call through its root grant and runs it without an authorization reference", async () => {
    const service = readService();

    const result = await dispatchRepoAutomationTool(
      "read_discovery_source",
      ROOT_READ_INPUT,
      service,
    );

    expect(result.ok).toBe(true);
    expect(service.consumeDiscoveryRootGrant).toHaveBeenCalledWith(
      expect.objectContaining({
        tool: "read_discovery_source",
        operation: "read-source",
      }),
    );
    expect(service.consumeDiscoveryToolAuthorization).not.toHaveBeenCalled();
    expect(service.readDiscoverySource).toHaveBeenCalledWith(
      expect.not.objectContaining({ authorizationRef: expect.anything() }),
    );
  });

  it("refuses a root call without a live root grant before any runtime launch", async () => {
    const service = readService();
    service.consumeDiscoveryRootGrant!.mockImplementation(
      refusing("DISCOVERY_HOST_BINDING_REQUIRED"),
    );

    const result = await dispatchRepoAutomationTool(
      "read_discovery_source",
      ROOT_READ_INPUT,
      service,
    );

    expect(result.ok).toBe(false);
    expect(result.summary).toContain("DISCOVERY_HOST_BINDING_REQUIRED");
    expect(service.readDiscoverySource).not.toHaveBeenCalled();
  });
});
