import { describe, expect, it } from "@jest/globals";

import { validateArtifact } from "../../../src/lib/validate/orchestration-artifacts";

/**
 * Dispatch tests for the two parallel-orchestration artifact types.
 *
 * These live in their own file because the pre-existing
 * `orchestration-artifacts.test.ts` is already at the 500-line policy cap. The
 * assertions mirror the epic dispatch cases: each type must reach its Phase 4
 * core, each gate flag must be threaded through, and the unsupported-type
 * fallback must stay unchanged.
 */

const ORCHESTRATOR_COMPLETION_ERROR =
  "Parallel checkpoint completion validation failed: open mode requires a mutations[] entry with op 'close'.";

const ORCHESTRATOR_ITEM_COMPLETION_ERROR =
  "Parallel checkpoint items[0] completion validation failed: merge_status is not merged or worktree_removed; found: None.";

const PLANNER_READY_SENTINEL_ERROR =
  "Parallel planner checkpoint next_step must be 'PARALLEL_EXECUTION_READY'; found: None.";

describe("validateArtifact parallel dispatch", () => {
  it("routes parallel-orchestrator-state to the parallel orchestrator validator", () => {
    // Arrange / Act
    const errors = validateArtifact({
      artifactType: "parallel-orchestrator-state",
      text: "[]",
    });

    // Assert
    expect(errors).toEqual(["Parallel checkpoint root must be a JSON object."]);
  });

  it("routes parallel-planner-state to the parallel planner validator", () => {
    // Arrange / Act
    const errors = validateArtifact({
      artifactType: "parallel-planner-state",
      text: "[]",
    });

    // Assert
    expect(errors).toEqual([
      "Parallel planner checkpoint root must be a JSON object.",
    ]);
  });

  it("threads requireComplete into parallel-orchestrator-state", () => {
    // Arrange
    const text = JSON.stringify({
      mode: "open",
      items: [{ issue_num: 1, feature_folder: "f", state: "in_progress" }],
    });

    // Act
    const errors = validateArtifact({
      artifactType: "parallel-orchestrator-state",
      text,
      requireComplete: true,
    });

    // Assert
    expect(errors).toContain(ORCHESTRATOR_ITEM_COMPLETION_ERROR);
    expect(errors).toContain(ORCHESTRATOR_COMPLETION_ERROR);
  });

  it("leaves the completion gate off for parallel-orchestrator-state by default", () => {
    // Arrange
    const text = JSON.stringify({
      mode: "open",
      items: [{ issue_num: 1, feature_folder: "f", state: "in_progress" }],
    });

    // Act
    const errors = validateArtifact({
      artifactType: "parallel-orchestrator-state",
      text,
    });

    // Assert
    expect(errors).not.toContain(ORCHESTRATOR_ITEM_COMPLETION_ERROR);
    expect(errors).not.toContain(ORCHESTRATOR_COMPLETION_ERROR);
  });

  it("threads requireReadyForExecution into parallel-planner-state", () => {
    // Arrange / Act
    const errors = validateArtifact({
      artifactType: "parallel-planner-state",
      text: "{}",
      requireReadyForExecution: true,
    });

    // Assert
    expect(errors).toContain(PLANNER_READY_SENTINEL_ERROR);
  });

  it("leaves the readiness gate off for parallel-planner-state by default", () => {
    // Arrange / Act
    const errors = validateArtifact({
      artifactType: "parallel-planner-state",
      text: "{}",
    });

    // Assert
    expect(errors).not.toContain(PLANNER_READY_SENTINEL_ERROR);
  });

  it("ignores the readiness flag on the parallel orchestrator route", () => {
    // Arrange / Act
    const errors = validateArtifact({
      artifactType: "parallel-orchestrator-state",
      text: JSON.stringify({ mode: "open" }),
      requireReadyForExecution: true,
    });

    // Assert
    expect(errors).not.toContain(ORCHESTRATOR_COMPLETION_ERROR);
    expect(errors).not.toContain(PLANNER_READY_SENTINEL_ERROR);
  });

  it("ignores the completion flag on the parallel planner route", () => {
    // Arrange / Act
    const errors = validateArtifact({
      artifactType: "parallel-planner-state",
      text: "{}",
      requireComplete: true,
    });

    // Assert
    expect(errors).not.toContain(PLANNER_READY_SENTINEL_ERROR);
  });

  // This case previously asserted that `parallel-kickoff` fell through to the
  // unsupported-artifact-type branch. That expectation became false by design:
  // `docs/features/epics/parallel-orchestration/epic.md`, section "Planner
  // Adjudication: the kickoff-contract boundary (F3 / F4)", assigns the
  // kickoff-contract module and the `parallel-kickoff` artifact type to the
  // parallel-planner-surface feature, and this repository's
  // `.claude/rules/parallel-orchestration.md`, section "F3 Scope Boundary —
  // kickoff contract deferred to F4", records the same boundary.
  it("routes the parallel kickoff type to the kickoff validator", () => {
    // Arrange / Act
    const errors = validateArtifact({
      artifactType: "parallel-kickoff",
      text: "",
    });

    // Assert
    expect(errors).toEqual(["Parallel kickoff is empty."]);
  });

  it("keeps the unsupported-artifact-type fallback unchanged", () => {
    // Arrange / Act
    const errors = validateArtifact({
      artifactType: "parallel-status-doc",
      text: "",
    });

    // Assert
    expect(errors).toEqual(["Unsupported artifact type: parallel-status-doc"]);
  });
});
