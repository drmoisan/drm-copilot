import { describe, expect, it } from "@jest/globals";

import type { FileSystem } from "../../../src/lib/file-system";
import { buildValidateOrchestrationServiceCallInput } from "../../../src/lib/validate/build-validate-orchestration-service-call-input";

/**
 * Minimal FileSystem stub. The builder only carries the reference through to the
 * returned object and never invokes any method, so every member throws to prove
 * it is untouched.
 */
const fileSystemStub: FileSystem = {
  glob() {
    throw new Error("not used");
  },
  isFile() {
    throw new Error("not used");
  },
  readTextFile() {
    throw new Error("not used");
  },
  writeTextFile() {
    throw new Error("not used");
  },
  ensureDir() {
    throw new Error("not used");
  },
};

describe("buildValidateOrchestrationServiceCallInput", () => {
  it("forwards the required fields and the injected filesystem verbatim", () => {
    // Arrange
    const input = {
      workspaceRoot: "C:/workspace",
      artifactType: "plan",
      artifactPath: "docs/plan.md",
    };

    // Act
    const result = buildValidateOrchestrationServiceCallInput(
      fileSystemStub,
      input,
    );

    // Assert
    expect(result.fileSystem).toBe(fileSystemStub);
    expect(result.workspaceRoot).toBe("C:/workspace");
    expect(result.artifactType).toBe("plan");
    expect(result.artifactPath).toBe("docs/plan.md");
  });

  it("omits both optional keys when requireComplete and requireModelRouting are absent", () => {
    // Arrange: neither optional field supplied.
    const input = {
      workspaceRoot: "C:/workspace",
      artifactType: "plan",
      artifactPath: "docs/plan.md",
    };

    // Act
    const result = buildValidateOrchestrationServiceCallInput(
      fileSystemStub,
      input,
    );

    // Assert: keys are absent, not present-with-undefined.
    expect("requireComplete" in result).toBe(false);
    expect("requireModelRouting" in result).toBe(false);
  });

  it("omits an optional key when its value is explicitly undefined", () => {
    // Arrange: both optional fields explicitly undefined.
    const input = {
      workspaceRoot: "C:/workspace",
      artifactType: "orchestrator-state",
      artifactPath: "docs/state.json",
      requireComplete: undefined,
      requireModelRouting: undefined,
    };

    // Act
    const result = buildValidateOrchestrationServiceCallInput(
      fileSystemStub,
      input,
    );

    // Assert
    expect("requireComplete" in result).toBe(false);
    expect("requireModelRouting" in result).toBe(false);
  });

  it("includes both optional keys when both values are defined", () => {
    // Arrange
    const input = {
      workspaceRoot: "C:/workspace",
      artifactType: "orchestrator-state",
      artifactPath: "docs/state.json",
      requireComplete: true,
      requireModelRouting: false,
    };

    // Act
    const result = buildValidateOrchestrationServiceCallInput(
      fileSystemStub,
      input,
    );

    // Assert
    expect(result.requireComplete).toBe(true);
    expect(result.requireModelRouting).toBe(false);
  });

  it("includes only the defined optional key when the other is absent", () => {
    // Arrange: requireComplete defined, requireModelRouting absent.
    const inputCompleteOnly = {
      workspaceRoot: "C:/workspace",
      artifactType: "orchestrator-state",
      artifactPath: "docs/state.json",
      requireComplete: false,
    };
    // requireModelRouting defined, requireComplete absent.
    const inputRoutingOnly = {
      workspaceRoot: "C:/workspace",
      artifactType: "orchestrator-state",
      artifactPath: "docs/state.json",
      requireModelRouting: true,
    };

    // Act
    const completeOnly = buildValidateOrchestrationServiceCallInput(
      fileSystemStub,
      inputCompleteOnly,
    );
    const routingOnly = buildValidateOrchestrationServiceCallInput(
      fileSystemStub,
      inputRoutingOnly,
    );

    // Assert
    expect(completeOnly.requireComplete).toBe(false);
    expect("requireModelRouting" in completeOnly).toBe(false);
    expect(routingOnly.requireModelRouting).toBe(true);
    expect("requireComplete" in routingOnly).toBe(false);
  });
});
