import { describe, expect, it } from "@jest/globals";

import { resolveValidateOrchestrationArtifactsToolInput } from "../src/mcp-tool-inputs";

/**
 * Input-resolution tests for the two parallel-orchestration artifact types.
 *
 * The MCP surface grows by exactly `parallel-orchestrator-state` and
 * `parallel-planner-state`; these tests pin that membership, the forwarding of
 * the two gate flags those types consume, and the unchanged rejection of an
 * artifact type outside the allow-list.
 */

const PARALLEL_ARTIFACT_TYPES = [
  "parallel-orchestrator-state",
  "parallel-planner-state",
] as const;

function input(
  overrides: Readonly<Record<string, unknown>> = {},
): Record<string, unknown> {
  return {
    workspace_root: "C:/workspace",
    artifact_type: "parallel-orchestrator-state",
    artifact_path: "artifacts/orchestration/parallel-orchestrator-state.json",
    ...overrides,
  };
}

describe("parallel validation MCP tool input", () => {
  it.each(PARALLEL_ARTIFACT_TYPES)(
    "accepts the %s artifact type",
    (artifactType) => {
      // Arrange / Act
      const resolved = resolveValidateOrchestrationArtifactsToolInput(
        input({ artifact_type: artifactType }),
      );

      // Assert
      expect(resolved.artifactType).toBe(artifactType);
    },
  );

  it.each(PARALLEL_ARTIFACT_TYPES)(
    "resolves the workspace root and artifact path for %s",
    (artifactType) => {
      // Arrange / Act
      const resolved = resolveValidateOrchestrationArtifactsToolInput(
        input({
          artifact_type: artifactType,
          artifact_path: "artifacts/orchestration/checkpoint.json",
        }),
      );

      // Assert
      expect(resolved).toEqual({
        workspaceRoot: "C:/workspace",
        artifactType,
        artifactPath: "artifacts/orchestration/checkpoint.json",
      });
    },
  );

  it("forwards the completion gate for parallel-orchestrator-state", () => {
    // Arrange / Act
    const resolved = resolveValidateOrchestrationArtifactsToolInput(
      input({
        artifact_type: "parallel-orchestrator-state",
        require_complete: true,
      }),
    );

    // Assert
    expect(resolved).toEqual({
      workspaceRoot: "C:/workspace",
      artifactType: "parallel-orchestrator-state",
      artifactPath: "artifacts/orchestration/parallel-orchestrator-state.json",
      requireComplete: true,
    });
  });

  it("forwards the readiness gate for parallel-planner-state", () => {
    // Arrange / Act
    const resolved = resolveValidateOrchestrationArtifactsToolInput(
      input({
        artifact_type: "parallel-planner-state",
        artifact_path: "artifacts/orchestration/parallel-planner-state.json",
        require_ready_for_execution: true,
      }),
    );

    // Assert
    expect(resolved).toEqual({
      workspaceRoot: "C:/workspace",
      artifactType: "parallel-planner-state",
      artifactPath: "artifacts/orchestration/parallel-planner-state.json",
      requireReadyForExecution: true,
    });
  });

  it.each(PARALLEL_ARTIFACT_TYPES)(
    "omits both gate flags for %s when they are not true",
    (artifactType) => {
      // Arrange / Act
      const resolved = resolveValidateOrchestrationArtifactsToolInput(
        input({
          artifact_type: artifactType,
          require_complete: false,
          require_ready_for_execution: false,
        }),
      );

      // Assert
      expect("requireComplete" in resolved).toBe(false);
      expect("requireReadyForExecution" in resolved).toBe(false);
    },
  );

  // The probe name below was `parallel-kickoff` until that type was added to
  // the allow-list. The addition is adjudicated in
  // `docs/features/epics/parallel-orchestration/epic.md`, section "Planner
  // Adjudication: the kickoff-contract boundary (F3 / F4)", which assigns the
  // `parallel-kickoff` artifact type to the parallel-planner-surface feature;
  // `parallel-status-doc` is a genuinely unregistered name that still
  // exercises the rejection path.
  it("rejects an artifact type outside the allow-list", () => {
    // Arrange / Act / Assert
    expect(() =>
      resolveValidateOrchestrationArtifactsToolInput(
        input({ artifact_type: "parallel-status-doc" }),
      ),
    ).toThrow(/^Field 'artifact_type' must be one of: /);
  });

  it("accepts the adjudicated parallel kickoff artifact type", () => {
    // Arrange / Act
    const resolved = resolveValidateOrchestrationArtifactsToolInput(
      input({ artifact_type: "parallel-kickoff" }),
    );

    // Assert
    expect(resolved.artifactType).toBe("parallel-kickoff");
  });

  it("names every parallel type in the rejection message", () => {
    // Arrange / Act / Assert
    expect(() =>
      resolveValidateOrchestrationArtifactsToolInput(
        input({ artifact_type: "not-an-artifact" }),
      ),
    ).toThrow(
      "Field 'artifact_type' must be one of: plan, policy-audit, code-review, feature-audit, orchestrator-state, epic-orchestrator-state, epic-planner-state, epic-kickoff, parallel-orchestrator-state, parallel-planner-state, parallel-kickoff. Got 'not-an-artifact'.",
    );
  });
});
