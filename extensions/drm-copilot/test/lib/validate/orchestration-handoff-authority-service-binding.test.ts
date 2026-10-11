import { describe, expect, it } from "@jest/globals";

import type { CheckoutObservation } from "../../../src/lib/validate/orchestration-handoff-checkout-context";
import {
  createScenario,
  type EnvelopeFixture,
} from "./orchestration-handoff-authority-service-test-support";

type MutationTarget = "binding" | "identity" | "plan";

/** Overwrite exactly one envelope field so each case isolates one binding. */
function mutate(
  section: MutationTarget,
  key: string,
  value: string | number,
): (fixture: EnvelopeFixture) => void {
  return (fixture) => {
    (fixture[section] as Record<string, unknown>)[key] = value;
  };
}

function observedCheckout(
  overrides: Partial<Omit<CheckoutObservation, "status">> = {},
): CheckoutObservation {
  return {
    status: "observed",
    repositoryId: "github.com/drmoisan/drm-copilot",
    workspaceRoot: "C:/Users/operator/drm-copilot",
    branch: "feature/portable-handoff-614",
    headSha: "0".repeat(40),
    ...overrides,
  };
}

describe("independent binding authority over a mutated envelope", () => {
  it.each([
    ["binding", "repository_id", "gh/x", "HANDOFF_REPOSITORY_MISMATCH"],
    ["binding", "workspace_root", "C:/attacker", "HANDOFF_WORKSPACE_MISMATCH"],
    ["binding", "branch", "feature/other", "HANDOFF_BRANCH_LINEAGE_MISMATCH"],
    ["identity", "issue_number", 999, "HANDOFF_ISSUE_FEATURE_MISMATCH"],
    ["identity", "feature_folder", "docs/x", "HANDOFF_ISSUE_FEATURE_MISMATCH"],
    ["identity", "work_mode", "full-bug", "HANDOFF_ISSUE_FEATURE_MISMATCH"],
    ["plan", "path", "docs/x/plan.md", "HANDOFF_PLAN_PATH_INVALID"],
    ["plan", "sha256", "9".repeat(64), "HANDOFF_PLAN_HASH_MISMATCH"],
  ] as const)(
    "blocks a self-consistent envelope whose %s.%s contradicts the independent context",
    (section, key, value, expectedCode) => {
      // Arrange
      const scenario = createScenario({
        mutateEnvelope: mutate(section, key, value),
      });

      // Act
      const result = scenario.resolve("topology");

      // Assert
      expect(result.status).toBe("blocked");
      expect(result.primaryFailureCode).toBe(expectedCode);
    },
  );

  it.each([
    ["repository", { repositoryId: "gh/x" }, "HANDOFF_REPOSITORY_MISMATCH"],
    ["workspace", { workspaceRoot: "C:/other" }, "HANDOFF_WORKSPACE_MISMATCH"],
    ["branch", { branch: "other" }, "HANDOFF_BRANCH_LINEAGE_MISMATCH"],
  ] as const)(
    "blocks when the observed checkout %s contradicts the independent context",
    (_field, override, expectedCode) => {
      // Arrange
      const scenario = createScenario({
        observation: observedCheckout(override),
      });

      // Act
      const result = scenario.resolve("topology");

      // Assert
      expect(result.status).toBe("blocked");
      expect(result.primaryFailureCode).toBe(expectedCode);
    },
  );

  it("blocks an equal_or_descendant relationship the boundary reports as unrelated", () => {
    // Arrange
    const scenario = createScenario({ headRelationshipSatisfied: false });

    // Act
    const result = scenario.resolve("topology");

    // Assert
    expect(result.primaryFailureCode).toBe("HANDOFF_BRANCH_LINEAGE_MISMATCH");
  });

  it("blocks an equal relationship whose observed HEAD differs from the expected source HEAD", () => {
    // Arrange
    const observedHeadSha = "d".repeat(40);
    const scenario = createScenario({
      headRelationshipSatisfied: false,
      mutateEnvelope: mutate("binding", "allowed_head_relationship", "equal"),
      observation: observedCheckout({ headSha: observedHeadSha }),
    });

    // Act
    const result = scenario.resolve("topology");

    // Assert
    expect(result.primaryFailureCode).toBe("HANDOFF_BRANCH_LINEAGE_MISMATCH");
    expect(scenario.isHeadRelationshipSatisfied).toHaveBeenCalledWith(
      expect.objectContaining({ observedHeadSha }),
    );
  });

  it("delegates relationship validity to the boundary using only independent values", () => {
    // Arrange
    const scenario = createScenario({
      mutateEnvelope: mutate("binding", "allowed_head_relationship", "equal"),
    });

    // Act
    scenario.resolve("topology");

    // Assert
    expect(scenario.isHeadRelationshipSatisfied).toHaveBeenCalledWith({
      workspaceRoot: scenario.request.expectedWorkspaceRoot,
      expectedSourceHeadSha: scenario.request.expectedSourceHeadSha,
      observedHeadSha: scenario.request.expectedSourceHeadSha,
      allowedHeadRelationship: scenario.request.allowedHeadRelationship,
    });
  });

  it("fails closed when the checkout observation is unavailable", () => {
    // Arrange
    const scenario = createScenario({
      observation: { status: "unavailable", reason: "git is unavailable" },
    });

    // Act
    const result = scenario.resolve("topology");

    // Assert
    expect(result.status).toBe("blocked");
    expect(result.primaryFailureCode).toBe("HANDOFF_VALIDATOR_UNAVAILABLE");
  });

  it("selects registry-order precedence when several bindings are invalid at once", () => {
    // Arrange
    const scenario = createScenario({
      mutateEnvelope: (fixture) => {
        mutate("binding", "repository_id", "github.com/x/y")(fixture);
        mutate("binding", "workspace_root", "C:/attacker")(fixture);
        mutate("identity", "issue_number", 999)(fixture);
        mutate("plan", "sha256", "9".repeat(64))(fixture);
      },
    });

    // Act
    const result = scenario.resolve("topology");

    // Assert
    expect(result.primaryFailureCode).toBe("HANDOFF_REPOSITORY_MISMATCH");
  });

  it("performs no filesystem write and no Git mutation while validating", () => {
    // Arrange
    const scenario = createScenario({
      mutateEnvelope: mutate("binding", "branch", "feature/other"),
    });

    // Act
    scenario.resolve("provider_routing");

    // Assert
    expect(scenario.fileSystem.writeTextFile).not.toHaveBeenCalled();
    expect(scenario.fileSystem.ensureDir).not.toHaveBeenCalled();
    expect(scenario.observe).toHaveBeenCalledWith(
      scenario.request.expectedWorkspaceRoot,
    );
  });
});
