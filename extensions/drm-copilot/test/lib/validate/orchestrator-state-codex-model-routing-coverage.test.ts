import { describe, expect, it } from "@jest/globals";

import { resolveCodexDeployment } from "../../../src/lib/validate/orchestrator-state-codex-model-routing";

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
});
