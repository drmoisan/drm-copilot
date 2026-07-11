import { describe, expect, it } from "@jest/globals";

import { resolveValidateOrchestrationArtifactsToolInput } from "../src/mcp-tool-inputs";

function input(
  overrides: Readonly<Record<string, unknown>> = {},
): Record<string, unknown> {
  return {
    workspace_root: "C:/workspace",
    artifact_type: "epic-planner-state",
    artifact_path: "artifacts/orchestration/epic-planner-state.json",
    ...overrides,
  };
}

describe("epic validation MCP tool input", () => {
  it.each(["epic-orchestrator-state", "epic-planner-state", "epic-kickoff"])(
    "accepts the %s artifact type",
    (artifactType) => {
      expect(
        resolveValidateOrchestrationArtifactsToolInput(
          input({ artifact_type: artifactType }),
        ).artifactType,
      ).toBe(artifactType);
    },
  );

  it("forwards Codex-routing and execution-readiness gates when true", () => {
    expect(
      resolveValidateOrchestrationArtifactsToolInput(
        input({
          require_codex_model_routing: true,
          require_codex_topology: true,
          require_ready_for_execution: true,
        }),
      ),
    ).toEqual({
      workspaceRoot: "C:/workspace",
      artifactType: "epic-planner-state",
      artifactPath: "artifacts/orchestration/epic-planner-state.json",
      requireCodexModelRouting: true,
      requireCodexTopology: true,
      requireReadyForExecution: true,
    });
  });

  it("omits Codex-routing and execution-readiness gates when not true", () => {
    const result = resolveValidateOrchestrationArtifactsToolInput(
      input({
        require_codex_model_routing: false,
        require_codex_topology: false,
        require_ready_for_execution: false,
      }),
    );

    expect("requireCodexModelRouting" in result).toBe(false);
    expect("requireCodexTopology" in result).toBe(false);
    expect("requireReadyForExecution" in result).toBe(false);
  });
});
