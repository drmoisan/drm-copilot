import { describe, expect, it } from "@jest/globals";
import {
  canonicalPlanPath,
  createScenario,
} from "./orchestration-handoff-authority-service-test-support";

describe("portable orchestration handoff authority service", () => {
  it("rejects a canonical envelope escape before any file read", () => {
    // Arrange
    const scenario = createScenario({
      handoffEnvelopePath: "../handoff.json",
      blockedRepositoryPaths: ["../handoff.json"],
    });

    // Act
    const result = scenario.resolve("topology");

    // Assert
    expect(result.primaryFailureCode).toBe("HANDOFF_PLAN_PATH_INVALID");
    expect(scenario.readTextFile).not.toHaveBeenCalled();
  });

  it.each(["topology", "provider_routing"] as const)(
    "rejects a canonical plan escape for %s before reading the plan",
    (kind) => {
      // Arrange
      const scenario = createScenario({
        blockedRepositoryPaths: [
          "docs/features/active/portable-handoff-614/plan.md",
        ],
      });

      // Act
      const result = scenario.resolve(kind);

      // Assert
      expect(result.primaryFailureCode).toBe("HANDOFF_PLAN_PATH_INVALID");
      expect(scenario.readTextFile).toHaveBeenCalledTimes(1);
      expect(scenario.readTextFile).not.toHaveBeenCalledWith(canonicalPlanPath);
    },
  );

  it("reports an envelope read failure without attempting a plan read", () => {
    // Arrange
    const scenario = createScenario({ envelopeReadFailure: true });

    // Act
    const result = scenario.resolve("topology");

    // Assert
    expect(result.primaryFailureCode).toBe("HANDOFF_VALIDATOR_UNAVAILABLE");
    expect(scenario.readTextFile).toHaveBeenCalledTimes(1);
  });

  it("reports an envelope hash mismatch before contract parsing", () => {
    // Arrange
    const scenario = createScenario({ expectedEnvelopeSha256: "f".repeat(64) });

    // Act
    const result = scenario.resolve("topology");

    // Assert
    expect(result.primaryFailureCode).toBe("HANDOFF_SOURCE_HASH_MISMATCH");
    expect(scenario.readTextFile).toHaveBeenCalledTimes(1);
  });

  it("reports contract parse failure before plan resolution", () => {
    // Arrange
    const scenario = createScenario({ envelopeText: "{" });

    // Act
    const result = scenario.resolve("topology");

    // Assert
    expect(result.primaryFailureCode).toBe("HANDOFF_UNSUPPORTED_VERSION");
    expect(scenario.readTextFile).toHaveBeenCalledTimes(1);
  });

  it("reports a plan read failure after canonical plan resolution", () => {
    // Arrange
    const scenario = createScenario({ planReadFailure: true });

    // Act
    const result = scenario.resolve("provider_routing");

    // Assert
    expect(result.primaryFailureCode).toBe("HANDOFF_PLAN_PATH_INVALID");
    expect(scenario.readTextFile).toHaveBeenLastCalledWith(canonicalPlanPath);
  });

  it("reports provider mismatch before resolving or reading the plan", () => {
    // Arrange
    const scenario = createScenario({ requestProvider: "claude" });

    // Act
    const result = scenario.resolve("topology");

    // Assert
    expect(result.primaryFailureCode).toBe(
      "HANDOFF_PROVIDER_ROUTING_UNAVAILABLE",
    );
    expect(scenario.readTextFile).toHaveBeenCalledTimes(1);
  });

  it("preserves primary-error ordering for simultaneous validation failures", () => {
    // Arrange
    const scenario = createScenario({
      bindingWorkspaceRoot: "C:/different-workspace",
      requestWorkspaceRoot: "C:/requested-workspace",
      planSha256: "0".repeat(64),
    });

    // Act
    const result = scenario.resolve("topology");

    // Assert
    expect(result.primaryFailureCode).toBe("HANDOFF_WORKSPACE_MISMATCH");
    expect(scenario.readTextFile).toHaveBeenCalledTimes(2);
  });

  it.each([
    [
      "valid-ordinary-claude-to-codex.json",
      "codex_topology_policy",
      "codex_model_policy",
    ],
    [
      "valid-parallel-codex-to-claude.json",
      "claude_native_worktree_policy",
      "model_policy",
    ],
  ] as const)(
    "resolves topology and routing for destination provider in %s",
    (fixtureName, topologyPolicy, routingPolicy) => {
      // Arrange
      const topologyScenario = createScenario({ fixtureName });
      const routingScenario = createScenario({ fixtureName });

      // Act
      const topology = topologyScenario.resolve("topology");
      const routing = routingScenario.resolve("provider_routing");

      // Assert
      expect(topology).toMatchObject({
        status: "validated",
        resolution: { topology_policy: topologyPolicy },
      });
      expect(routing).toMatchObject({
        status: "validated",
        resolution: { routing_policy: routingPolicy },
      });
    },
  );
});
