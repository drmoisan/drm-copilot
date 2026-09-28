import { describe, expect, it } from "@jest/globals";

import {
  ModelUnavailableError,
  resolveCodexDeployment,
} from "../../../src/lib/validate/orchestrator-state-codex-model-routing";

describe("resolveCodexDeployment", () => {
  it.each([
    ["C1", "atomic-executor-c1", "gpt-5.6-luna", "low"],
    ["C2", "atomic-executor-c2", "gpt-5.6-terra", "medium"],
    ["C3", "atomic-executor-c3", "gpt-5.6-terra", "high"],
    ["C4", "atomic-executor-c4", "gpt-5.6-sol", "max"],
  ])(
    "routes standalone %s work to its exact base profile",
    (band, expectedAgent, expectedModel, expectedReasoning) => {
      // Arrange / Act
      const receipt = resolveCodexDeployment(
        "atomic-executor",
        band,
        "standalone",
        band,
      );

      // Assert
      expect(receipt.deployment_agent).toBe(expectedAgent);
      expect(receipt.model).toBe(expectedModel);
      expect(receipt.model_reasoning_effort).toBe(expectedReasoning);
      expect(receipt.c3_overlay_applied).toBe(false);
      expect(receipt.c3_overlay_reason).toBeNull();
    },
  );

  it.each(["epic_preparation_child", "epic_execution_child"])(
    "elevates C3 work in %s context",
    (context) => {
      // Arrange / Act
      const receipt = resolveCodexDeployment(
        "orchestrator",
        "C3",
        context,
        "C3",
      );

      // Assert
      expect(receipt.deployment_agent).toBe("orchestrator-c3-elevated");
      expect(receipt.model).toBe("gpt-5.6-sol");
      expect(receipt.model_reasoning_effort).toBe("high");
      expect(receipt.c3_overlay_applied).toBe(true);
      expect(receipt.c3_overlay_reason).toBe("epic_context");
    },
  );

  it("elevates standalone C3 work when the orchestration ceiling is C4", () => {
    // Arrange / Act
    const receipt = resolveCodexDeployment(
      "task-researcher",
      "C3",
      "standalone",
      "C4",
    );

    // Assert
    expect(receipt.deployment_agent).toBe("task-researcher-c3-elevated");
    expect(receipt.c3_overlay_reason).toBe("c4_orchestration_ceiling");
  });

  it("records both C3 elevation triggers when epic context has a C4 ceiling", () => {
    // Arrange / Act
    const receipt = resolveCodexDeployment(
      "prd-feature",
      "C3",
      "epic_execution_child",
      "C4",
    );

    // Assert
    expect(receipt.c3_overlay_reason).toBe("epic_context_and_c4_ceiling");
  });

  it.each(["epic-planner", "epic-orchestrator"])(
    "forces %s to Sol with ultra reasoning",
    (persona) => {
      // Arrange / Act
      const receipt = resolveCodexDeployment(persona, "C1", "standalone", "C1");

      // Assert
      expect(receipt.deployment_agent).toBe(persona);
      expect(receipt.model).toBe("gpt-5.6-sol");
      expect(receipt.model_reasoning_effort).toBe("ultra");
      expect(receipt.c3_overlay_applied).toBe(false);
    },
  );

  it("does not elevate non-C3 epic-child work", () => {
    // Arrange / Act
    const receipt = resolveCodexDeployment(
      "atomic-planner",
      "C2",
      "epic_preparation_child",
      "C4",
    );

    // Assert
    expect(receipt.deployment_agent).toBe("atomic-planner-c2");
    expect(receipt.model).toBe("gpt-5.6-terra");
    expect(receipt.model_reasoning_effort).toBe("medium");
    expect(receipt.c3_overlay_applied).toBe(false);
  });

  it("maps the route feature-review name to the Codex reviewer family", () => {
    // Arrange / Act
    const receipt = resolveCodexDeployment(
      "feature-review",
      "C2",
      "standalone",
      "C2",
    );

    // Assert
    expect(receipt.logical_agent).toBe("feature-review");
    expect(receipt.deployment_agent).toBe("feature-reviewer-c2");
  });

  it("routes standalone C3 commit-steward work to its Terra high profile", () => {
    // Arrange / Act
    const receipt = resolveCodexDeployment(
      "commit-steward",
      "C3",
      "standalone",
      "C3",
    );

    // Assert
    expect(receipt.deployment_agent).toBe("commit-steward-c3");
    expect(receipt.model).toBe("gpt-5.6-terra");
    expect(receipt.model_reasoning_effort).toBe("high");
  });

  it.each([
    ["unknown", "C1", "standalone", "C1", "Unsupported Codex logical agent"],
    ["orchestrator", "C5", "standalone", "C4", "complexity_band"],
    ["orchestrator", "C1", "other", "C1", "execution_context"],
    [
      "orchestrator",
      "C4",
      "standalone",
      "C3",
      "orchestration_complexity_ceiling",
    ],
  ])(
    "rejects invalid routing inputs for %s/%s/%s/%s",
    (agent, band, context, ceiling, message) => {
      // Arrange / Act / Assert
      expect(() =>
        resolveCodexDeployment(agent, band, context, ceiling),
      ).toThrow(message);
    },
  );

  it("fails explicitly when the exact routed model is unavailable", () => {
    // Arrange / Act / Assert
    expect(() =>
      resolveCodexDeployment(
        "atomic-executor",
        "C4",
        "standalone",
        "C4",
        new Set(["gpt-5.6-terra", "gpt-5.6-luna"]),
      ),
    ).toThrow(ModelUnavailableError);
    expect(() =>
      resolveCodexDeployment(
        "atomic-executor",
        "C4",
        "standalone",
        "C4",
        new Set(["gpt-5.6-terra", "gpt-5.6-luna"]),
      ),
    ).toThrow("model_unavailable");
  });

  it("accepts the exact routed model when available", () => {
    // Arrange / Act
    const receipt = resolveCodexDeployment(
      "atomic-executor",
      "C4",
      "standalone",
      "C4",
      new Set(["gpt-5.6-sol"]),
    );

    // Assert
    expect(receipt.model).toBe("gpt-5.6-sol");
  });
});
