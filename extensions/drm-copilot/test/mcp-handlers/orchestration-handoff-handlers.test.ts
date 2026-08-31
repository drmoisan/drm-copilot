import { describe, expect, it, jest } from "@jest/globals";

import { handlePortableHandoffTool } from "../../src/mcp-handlers/orchestration-handoff-handlers";
import {
  createMockService,
  createPreparedTransitionCase,
} from "../mcp-server-test-service";

function withOverride(key: string, value: unknown): Record<string, unknown> {
  return { ...createPreparedTransitionCase().arguments, [key]: value };
}

describe("portable orchestration handoff MCP handlers", () => {
  it.each([undefined, null, []])(
    "rejects non-object input %#",
    async (input) => {
      await expect(
        handlePortableHandoffTool(
          "transition_prepared_orchestration",
          input,
          createMockService(),
        ),
      ).rejects.toThrow("Portable handoff input must be an object.");
    },
  );

  it.each([
    ["workspace_root", 1, "workspace_root must be a non-empty string."],
    ["workspace_root", " ", "workspace_root must be a non-empty string."],
    ["workspace_root", "workspace", "workspace_root must be an absolute path."],
    [
      "destination_provider",
      "other",
      "destination_provider must be 'claude' or 'codex'.",
    ],
    [
      "handoff_envelope_path",
      "artifacts\\handoff.json",
      "handoff_envelope_path must be repository-relative POSIX syntax.",
    ],
    [
      "handoff_envelope_path",
      "/artifacts/handoff.json",
      "handoff_envelope_path must be repository-relative POSIX syntax.",
    ],
    [
      "handoff_envelope_path",
      "artifacts//handoff.json",
      "handoff_envelope_path must be repository-relative POSIX syntax.",
    ],
    [
      "handoff_envelope_path",
      "artifacts/./handoff.json",
      "handoff_envelope_path must be repository-relative POSIX syntax.",
    ],
    [
      "handoff_envelope_path",
      "artifacts/../handoff.json",
      "handoff_envelope_path must be repository-relative POSIX syntax.",
    ],
    [
      "expected_handoff_envelope_sha256",
      "invalid",
      "expected_handoff_envelope_sha256 must be a lowercase SHA-256 digest.",
    ],
    [
      "source_checkpoint_path",
      "artifacts\\source.json",
      "source_checkpoint_path must be repository-relative POSIX syntax.",
    ],
    [
      "expected_source_checkpoint_sha256",
      "INVALID",
      "expected_source_checkpoint_sha256 must be a lowercase SHA-256 digest.",
    ],
    ["mode", "apply", "mode must be 'dry_run' or 'materialize'."],
  ])("rejects invalid %s input %#", async (key, value, message) => {
    await expect(
      handlePortableHandoffTool(
        "transition_prepared_orchestration",
        withOverride(key, value),
        createMockService(),
      ),
    ).rejects.toThrow(message);
  });

  it("returns deterministic unavailable results for optional service seams", async () => {
    // Arrange
    const fixture = createPreparedTransitionCase();
    const service = createMockService();
    delete service.transitionPreparedOrchestration;

    // Act
    const topology = await handlePortableHandoffTool(
      "resolve_orchestration_topology",
      fixture.arguments,
      service,
    );
    const routing = await handlePortableHandoffTool(
      "resolve_provider_routing",
      { ...fixture.arguments, destination_provider: "claude" },
      service,
    );
    const transition = await handlePortableHandoffTool(
      "transition_prepared_orchestration",
      fixture.arguments,
      service,
    );

    // Assert
    expect(topology).toMatchObject({
      status: "blocked",
      primary_failure_code: "HANDOFF_TOPOLOGY_RESOLVER_UNAVAILABLE",
    });
    expect(routing).toMatchObject({
      status: "blocked",
      primary_failure_code: "HANDOFF_PROVIDER_ROUTING_UNAVAILABLE",
    });
    expect(transition).toMatchObject({
      status: "blocked",
      source_checkpoint_sha256:
        fixture.arguments.expected_source_checkpoint_sha256,
      primary_failure_code: "HANDOFF_VALIDATOR_UNAVAILABLE",
    });
  });

  it("dispatches available topology and routing service methods", async () => {
    // Arrange
    const fixture = createPreparedTransitionCase();
    const resolution = {
      status: "validated",
      handoffId: "handoff-614",
      handoffEnvelopeSha256: fixture.arguments.expected_handoff_envelope_sha256,
      primaryFailureCode: null,
      affectedPaths: [],
      unsupportedCapabilities: [],
      resolution: { provider: "codex" },
    } as const;
    const service = Object.assign(createMockService(), {
      resolveOrchestrationTopology: jest.fn(async () => resolution),
      resolveProviderRouting: jest.fn(async () => resolution),
    });

    // Act
    const topology = await handlePortableHandoffTool(
      "resolve_orchestration_topology",
      fixture.arguments,
      service,
    );
    const routing = await handlePortableHandoffTool(
      "resolve_provider_routing",
      fixture.arguments,
      service,
    );

    // Assert
    expect(topology).toMatchObject({ status: "validated" });
    expect(routing).toMatchObject({ status: "validated" });
    expect(service.resolveOrchestrationTopology).toHaveBeenCalledTimes(1);
    expect(service.resolveProviderRouting).toHaveBeenCalledTimes(1);
  });
});
