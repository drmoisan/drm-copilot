import { describe, expect, it } from "@jest/globals";

import type { FileSystem } from "../../../src/lib/file-system";
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
