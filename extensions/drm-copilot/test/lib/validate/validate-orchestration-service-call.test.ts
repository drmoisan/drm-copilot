import { describe, expect, it, jest } from "@jest/globals";

import type { FileSystem } from "../../../src/lib/file-system";
import type { CommandRunner } from "../../../src/lib/subprocess-runner";
import * as orchestrationArtifacts from "../../../src/lib/validate/orchestration-artifacts";
import { validateOrchestrationServiceCall } from "../../../src/lib/validate/validate-orchestration-service-call";

const VALID_PLAN = [
  "# Plan",
  "### Phase 0 — Setup",
  "- [ ] [P0-T1] First task",
].join("\n");

/**
 * In-memory FileSystem fake mapping artifact paths to text. The helper only
 * consumes `readTextFile`, so `glob`/`isFile`/`writeTextFile` default to
 * empty/false/throw. The fake also records the last requested read path so
 * tests can assert path resolution.
 */
class VirtualFileSystem implements FileSystem {
  public lastReadPath: string | undefined;
  private readonly contents: Map<string, string>;

  constructor(files: Record<string, string>) {
    this.contents = new Map(Object.entries(files));
  }

  glob(): string[] {
    return [];
  }

  isFile(path: string): boolean {
    return this.contents.has(path);
  }

  readTextFile(path: string): string {
    this.lastReadPath = path;
    const content = this.contents.get(path);
    if (content === undefined) {
      throw new Error(`ENOENT: ${path}`);
    }
    return content;
  }

  writeTextFile(): void {
    throw new Error("not used");
  }

  ensureDir(): void {
    throw new Error("not used");
  }
}

describe("validateOrchestrationServiceCall", () => {
  it("returns the preserved tool, workspaceRoot, and summary on success", () => {
    // Arrange
    const fileSystem = new VirtualFileSystem({
      "C:/workspace/docs/plan.md": VALID_PLAN,
    });

    // Act
    const result = validateOrchestrationServiceCall({
      fileSystem,
      workspaceRoot: "C:/workspace",
      artifactType: "plan",
      artifactPath: "docs/plan.md",
      requireComplete: false,
    });

    // Assert
    expect(result.tool).toBe("validate_orchestration_artifacts");
    expect(result.workspaceRoot).toBe("C:/workspace");
    expect(result.summary).toBe("Validated plan artifact at 'docs/plan.md'.");
  });

  it("resolves the artifact path by joining workspaceRoot and artifactPath", () => {
    // Arrange
    const fileSystem = new VirtualFileSystem({
      "C:/workspace/docs/plan.md": VALID_PLAN,
    });

    // Act
    validateOrchestrationServiceCall({
      fileSystem,
      workspaceRoot: "C:/workspace",
      artifactType: "plan",
      artifactPath: "docs/plan.md",
    });

    // Assert: the resolved read path is the POSIX-joined full path.
    expect(fileSystem.lastReadPath).toBe("C:/workspace/docs/plan.md");
  });

  it("routes require-complete to the orchestrator-state validator", () => {
    // Arrange: a non-object orchestrator-state document under requireComplete.
    const fileSystem = new VirtualFileSystem({
      "C:/workspace/docs/state.json": "[]",
    });

    // Act / Assert: the orchestrator-state validator reports the root error.
    expect(() =>
      validateOrchestrationServiceCall({
        fileSystem,
        workspaceRoot: "C:/workspace",
        artifactType: "orchestrator-state",
        artifactPath: "docs/state.json",
        requireComplete: true,
      }),
    ).toThrow("Checkpoint root must be a JSON object.");
  });

  it("routes require-ready-for-execution to the epic-planner validator", () => {
    const fileSystem = new VirtualFileSystem({
      "C:/workspace/artifacts/orchestration/epic-planner-state.json": "{}",
    });

    expect(() =>
      validateOrchestrationServiceCall({
        fileSystem,
        workspaceRoot: "C:/workspace",
        artifactType: "epic-planner-state",
        artifactPath: "artifacts/orchestration/epic-planner-state.json",
        requireReadyForExecution: true,
      }),
    ).toThrow(
      "Execution-ready planner checkpoint next_step must be 'EPIC_EXECUTION_READY'.",
    );
  });

  it("passes the file-backed context for parallel planner readiness", () => {
    const statePath =
      "C:/workspace/artifacts/orchestration/parallel-planner-state.json";
    const fileSystem = new VirtualFileSystem({ [statePath]: "{}" });
    const runner: CommandRunner = {
      run: jest.fn(() => ({ stdout: "", stderr: "", code: 0 })),
    };
    const dispatch = jest
      .spyOn(orchestrationArtifacts, "validateArtifactWithWarnings")
      .mockReturnValueOnce({ errors: [], warnings: [] });

    const result = validateOrchestrationServiceCall({
      fileSystem,
      runner,
      workspaceRoot: "C:/workspace",
      artifactType: "parallel-planner-state",
      artifactPath: "artifacts/orchestration/parallel-planner-state.json",
      requireReadyForExecution: true,
    });

    expect(result.summary).toContain("parallel-planner-state");
    expect(dispatch).toHaveBeenCalledWith(
      expect.objectContaining({
        artifactPath: statePath,
        fs: fileSystem,
        root: "C:/workspace",
        runner,
        requireReadyForExecution: true,
      }),
    );
    dispatch.mockRestore();
  });

  it.each([true, false])(
    "passes every validator flag to the validator with the same %s value",
    (value) => {
      const fileSystem = new VirtualFileSystem({
        "C:/workspace/docs/plan.md": VALID_PLAN,
      });
      const dispatch = jest
        .spyOn(orchestrationArtifacts, "validateArtifactWithWarnings")
        .mockReturnValueOnce({ errors: [], warnings: [] });

      validateOrchestrationServiceCall({
        fileSystem,
        workspaceRoot: "C:/workspace",
        artifactType: "plan",
        artifactPath: "docs/plan.md",
        requireComplete: value,
        requirePrCreationReady: value,
        requireModelRouting: value,
        requireCodexModelRouting: value,
        requireCodexTopology: value,
        requireReadyForExecution: value,
      });

      expect(dispatch).toHaveBeenCalledWith({
        artifactType: "plan",
        text: VALID_PLAN,
        requireComplete: value,
        requirePrCreationReady: value,
        requireModelRouting: value,
        requireCodexModelRouting: value,
        requireCodexTopology: value,
        requireReadyForExecution: value,
        artifactPath: "C:/workspace/docs/plan.md",
        fs: fileSystem,
        root: "C:/workspace",
      });
      dispatch.mockRestore();
    },
  );

  it("fails closed when parallel readiness lacks the Git evidence seam", () => {
    const fileSystem = new VirtualFileSystem({
      "C:/workspace/artifacts/orchestration/parallel-planner-state.json": "{}",
    });

    expect(() =>
      validateOrchestrationServiceCall({
        fileSystem,
        workspaceRoot: "C:/workspace",
        artifactType: "parallel-planner-state",
        artifactPath: "artifacts/orchestration/parallel-planner-state.json",
        requireReadyForExecution: true,
      }),
    ).toThrow(
      "Parallel Codex readiness evidence context requires filesystem, workspace root, artifact path, and Git runner.",
    );
  });

  it("routes require-codex-topology to the checkpoint validator", () => {
    const fileSystem = new VirtualFileSystem({
      "C:/workspace/docs/state.json": JSON.stringify({
        delegation_receipts: [{ agent_name: "orchestrator" }],
      }),
    });

    expect(() =>
      validateOrchestrationServiceCall({
        fileSystem,
        workspaceRoot: "C:/workspace",
        artifactType: "orchestrator-state",
        artifactPath: "docs/state.json",
        requireCodexTopology: true,
      }),
    ).toThrow(
      "Checkpoint codex_topology_receipts must be a list when present.",
    );
  });

  it("throws with the aggregated error text when validation errors are present", () => {
    // Arrange: a policy-audit document missing required headings.
    const fileSystem = new VirtualFileSystem({
      "C:/workspace/docs/policy-audit.md": "incomplete document",
    });

    // Act / Assert
    expect(() =>
      validateOrchestrationServiceCall({
        fileSystem,
        workspaceRoot: "C:/workspace",
        artifactType: "policy-audit",
        artifactPath: "docs/policy-audit.md",
      }),
    ).toThrow(
      "Validation failed for policy-audit artifact at 'docs/policy-audit.md':",
    );
  });
});
