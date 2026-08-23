import { describe, expect, it } from "@jest/globals";

import { resolveValidateOrchestrationArtifactsToolInput } from "../src/mcp-tool-inputs";

function readinessInput(overrides: Record<string, unknown> = {}) {
  return {
    workspace_root: "C:/workspace",
    artifact_type: "orchestrator-state",
    artifact_path: "artifacts/orchestration/orchestrator-state.json",
    ...overrides,
  };
}

describe("validate orchestration readiness input", () => {
  it("selects require_pr_creation_ready without selecting completion", () => {
    const result = resolveValidateOrchestrationArtifactsToolInput(
      readinessInput({ require_pr_creation_ready: true }),
    );

    expect(result.requirePrCreationReady).toBe(true);
    expect("requireComplete" in result).toBe(false);
  });

  it("treats omitted and explicit-false readiness as the same false default", () => {
    const omitted =
      resolveValidateOrchestrationArtifactsToolInput(readinessInput());
    const explicitFalse = resolveValidateOrchestrationArtifactsToolInput(
      readinessInput({ require_pr_creation_ready: false }),
    );

    expect(explicitFalse).toEqual(omitted);
    expect("requirePrCreationReady" in omitted).toBe(false);
  });

  it("preserves independently selected readiness and routing flags", () => {
    const result = resolveValidateOrchestrationArtifactsToolInput(
      readinessInput({
        require_pr_creation_ready: true,
        require_complete: false,
        require_model_routing: true,
        require_codex_model_routing: true,
        require_codex_topology: true,
      }),
    );

    expect(result).toMatchObject({
      requirePrCreationReady: true,
      requireModelRouting: true,
      requireCodexModelRouting: true,
      requireCodexTopology: true,
    });
    expect("requireComplete" in result).toBe(false);
  });

  it("rejects a non-boolean readiness value", () => {
    expect(() =>
      resolveValidateOrchestrationArtifactsToolInput(
        readinessInput({ require_pr_creation_ready: "true" }),
      ),
    ).toThrow(
      "Field 'require_pr_creation_ready' must be a boolean when provided.",
    );
  });

  it("rejects an unknown readiness property", () => {
    expect(() =>
      resolveValidateOrchestrationArtifactsToolInput(
        readinessInput({ requirePrCreationReady: true }),
      ),
    ).toThrow("Field 'requirePrCreationReady' is not supported.");
  });
});
