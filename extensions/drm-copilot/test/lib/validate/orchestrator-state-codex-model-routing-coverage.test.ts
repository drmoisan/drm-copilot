import { describe, expect, it } from "@jest/globals";

import {
  resolveCodexDeployment,
  validateCodexModelRoutingReceipts,
} from "../../../src/lib/validate/orchestrator-state-codex-model-routing";

function repeatedModelReceipts(): [
  Record<string, unknown>,
  Record<string, unknown>,
] {
  const first: Record<string, unknown> = {
    ...resolveCodexDeployment("atomic-executor", "C4", "standalone", "C4"),
    phase: "S5_atomic_execution",
  };
  return [first, { ...first, phase: "S6_feature_review" }];
}

describe("Codex model-routing coverage boundaries", () => {
  it("formats an unsupported symbol logical agent deterministically", () => {
    const logicalAgent = Symbol("unsupported") as unknown as string;

    expect(() =>
      resolveCodexDeployment(logicalAgent, "C1", "standalone", "C1"),
    ).toThrow("Unsupported Codex logical agent: Symbol(unsupported).");
  });

  it("requires a parallel context to use its forced persona", () => {
    expect(() =>
      resolveCodexDeployment(
        "atomic-executor",
        "C1",
        "parallel_planning",
        "C1",
      ),
    ).toThrow("requires its forced root persona 'parallel-planner'");
  });

  it("requires a parallel persona to use its matching context", () => {
    expect(() =>
      resolveCodexDeployment("parallel-planner", "C1", "standalone", "C1"),
    ).toThrow("requires 'parallel_planning' context");
  });

  it("accepts repeated exact model inputs across distinct phases", () => {
    expect(validateCodexModelRoutingReceipts(repeatedModelReceipts())).toEqual(
      [],
    );
  });

  it("keeps repeated-input resolved-field diagnostics ordered by index", () => {
    const receipts = repeatedModelReceipts();
    receipts[1]["deployment_agent"] = "wrong-agent";
    receipts[1]["model"] = "wrong-model";

    expect(validateCodexModelRoutingReceipts(receipts)).toEqual([
      "Checkpoint codex_model_routing_receipts[1].deployment_agent must be " +
        "'atomic-executor-c4', found 'wrong-agent'.",
      "Checkpoint codex_model_routing_receipts[1].model must be " +
        "'gpt-5.6-sol', found 'wrong-model'.",
    ]);
  });

  it("does not alias alternating exact normalized model inputs", () => {
    const first = repeatedModelReceipts()[0];
    const second: Record<string, unknown> = {
      ...resolveCodexDeployment("commit-steward", "C4", "standalone", "C4"),
      phase: "S6_commit_steward",
    };

    expect(
      validateCodexModelRoutingReceipts([
        first,
        second,
        { ...first, phase: "S7_feature_review" },
        { ...second, phase: "S8_status_update" },
      ]),
    ).toEqual([]);
  });

  it("does not cache heterogeneous raw inputs that normalize as invalid", () => {
    const first = repeatedModelReceipts()[0];
    first["logical_agent"] = null;
    const second = { ...first, logical_agent: undefined };

    expect(validateCodexModelRoutingReceipts([first, second])).toEqual([
      "Checkpoint codex_model_routing_receipts[0] has invalid routing inputs: " +
        "Unsupported Codex logical agent: 'None'.",
      "Checkpoint codex_model_routing_receipts[1] has invalid routing inputs: " +
        "Unsupported Codex logical agent: 'None'.",
    ]);
  });

  it("rejects a ceiling transition on the initial receipt", () => {
    const receipts = repeatedModelReceipts();
    receipts[0]["ceiling_transition"] = {};

    expect(validateCodexModelRoutingReceipts(receipts)).toEqual([
      "Checkpoint codex_model_routing_receipts[0].ceiling_transition must " +
        "be absent unless the ceiling rises.",
    ]);
  });

  it("rejects a ceiling transition when the repeated ceiling does not rise", () => {
    const receipts = repeatedModelReceipts();
    receipts[1]["ceiling_transition"] = {
      from: "C3",
      to: "C4",
      affected_delegation_ids: ["agent-1"],
    };

    expect(validateCodexModelRoutingReceipts(receipts)).toEqual([
      "Checkpoint codex_model_routing_receipts[1].ceiling_transition must " +
        "be absent unless the ceiling rises.",
    ]);
  });
});
