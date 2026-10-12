import { describe, expect, it } from "@jest/globals";

import { validateModelRoutingExistence } from "../../../src/lib/validate/orchestrator-state-model-routing-existence";

describe("validateModelRoutingExistence ordering", () => {
  it("889-cp-order: reports missing receipts in code-point order (U+FF5E before U+1F600)", () => {
    // Arrange: supplementary-plane agent delegated first.
    const supplementary = "\u{1F600}";
    const highBmp = "～";
    const state: Record<string, unknown> = {
      delegation_receipts: [
        { agent_name: supplementary },
        { agent_name: highBmp },
      ],
    };

    // Act
    const errors = validateModelRoutingExistence(state);

    // Assert
    expect(errors).toEqual([
      `Checkpoint model_routing_receipts is missing a receipt for delegated agent: ${highBmp}.`,
      `Checkpoint model_routing_receipts is missing a receipt for delegated agent: ${supplementary}.`,
    ]);
  });
});
