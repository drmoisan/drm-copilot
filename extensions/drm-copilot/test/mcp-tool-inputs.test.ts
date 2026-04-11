import { describe, expect, it } from "@jest/globals";

import {
  resolveCollectCommitContextToolInput,
  resolveCollectPrContextToolInput,
  resolveNewActiveFeatureFolderToolInput,
  resolveNewPotentialBugEntryToolInput,
  resolveNewPotentialEntryToolInput,
  resolvePotentialToIssueToolInput,
  resolvePushDownCodexAndAgentsCustomizationsToolInput,
  resolvePushDownCopilotCustomizationsToolInput,
  resolveResolveExecuteHardLockPromptToolInput,
  resolveRunPoshQCSuiteToolInput,
  resolveValidateOrchestrationArtifactsToolInput,
} from "../src/mcp-tool-inputs";

function createRunPoshQCSuiteArgs(
  overrides: Readonly<Record<string, unknown>> = {},
): Readonly<Record<string, unknown>> {
  return {
    workspace_root: "C:/workspace",
    scan_folders: ["src", "tests/powershell"],
    ...overrides,
  };
}

function createValidateArtifactsArgs(
  overrides: Readonly<Record<string, unknown>> = {},
): Readonly<Record<string, unknown>> {
  return {
    workspace_root: "C:/workspace",
    artifact_type: "plan",
    artifact_path: "docs/plan.md",
    require_complete: true,
    ...overrides,
  };
}

describe("resolveRunPoshQCSuiteToolInput", () => {
  it("returns workspaceRoot and scanFolders for a valid string array", () => {
    expect(resolveRunPoshQCSuiteToolInput(createRunPoshQCSuiteArgs())).toEqual({
      workspaceRoot: "C:/workspace",
      scanFolders: ["src", "tests/powershell"],
    });
  });

  it("falls back to the provided workspace root when workspace_root is omitted", () => {
    expect(
      resolveRunPoshQCSuiteToolInput(
        createRunPoshQCSuiteArgs({ workspace_root: undefined }),
        "D:/fallback-workspace",
      ),
    ).toEqual({
      workspaceRoot: "D:/fallback-workspace",
      scanFolders: ["src", "tests/powershell"],
    });
  });

  it("rejects non-array scan_folders", () => {
    expect(() =>
      resolveRunPoshQCSuiteToolInput(
        createRunPoshQCSuiteArgs({ scan_folders: "src" }),
      ),
    ).toThrow("Field 'scan_folders' must be an array when provided.");
  });

  it("rejects non-string scan_folders elements", () => {
    expect(() =>
      resolveRunPoshQCSuiteToolInput(
        createRunPoshQCSuiteArgs({ scan_folders: ["src", 7] }),
      ),
    ).toThrow("Field 'scan_folders[1]' must be a string.");
  });
});

describe("resolveValidateOrchestrationArtifactsToolInput", () => {
  it("returns artifactType, artifactPath, and requireComplete true for a valid plan payload", () => {
    expect(
      resolveValidateOrchestrationArtifactsToolInput(
        createValidateArtifactsArgs(),
      ),
    ).toEqual({
      workspaceRoot: "C:/workspace",
      artifactType: "plan",
      artifactPath: "docs/plan.md",
      requireComplete: true,
    });
  });

  it("rejects a missing artifact_path", () => {
    expect(() =>
      resolveValidateOrchestrationArtifactsToolInput(
        createValidateArtifactsArgs({ artifact_path: undefined }),
      ),
    ).toThrow("Field 'artifact_path' must be a string.");
  });

  it("rejects a non-string artifact_path", () => {
    expect(() =>
      resolveValidateOrchestrationArtifactsToolInput(
        createValidateArtifactsArgs({ artifact_path: 42 }),
      ),
    ).toThrow("Field 'artifact_path' must be a string.");
  });

  it("rejects an invalid artifact_type enum", () => {
    expect(() =>
      resolveValidateOrchestrationArtifactsToolInput(
        createValidateArtifactsArgs({ artifact_type: "invalid-type" }),
      ),
    ).toThrow("Field 'artifact_type' must be one of:");
  });

  it("omits requireComplete when the field is not true", () => {
    const result = resolveValidateOrchestrationArtifactsToolInput(
      createValidateArtifactsArgs({ require_complete: undefined }),
    );
    expect(result).toEqual({
      workspaceRoot: "C:/workspace",
      artifactType: "plan",
      artifactPath: "docs/plan.md",
    });
    expect("requireComplete" in result).toBe(false);
  });

  it("accepts each valid artifact_type value", () => {
    for (const validType of [
      "plan",
      "policy-audit",
      "code-review",
      "feature-audit",
      "orchestrator-state",
    ]) {
      const result = resolveValidateOrchestrationArtifactsToolInput(
        createValidateArtifactsArgs({ artifact_type: validType }),
      );
      expect(result.artifactType).toBe(validType);
    }
  });
});

describe("asToolArgumentObject via resolvers", () => {
  it("treats undefined rawInput as empty arguments", () => {
    const result = resolveCollectCommitContextToolInput(
      undefined,
      "C:/fallback",
    );
    expect(result.workspaceRoot).toBe("C:/fallback");
  });

  it("rejects non-object rawInput", () => {
    expect(() => resolveCollectCommitContextToolInput("not-an-object")).toThrow(
      "Tool arguments must be an object.",
    );
  });

  it("rejects null rawInput", () => {
    expect(() => resolveCollectCommitContextToolInput(null)).toThrow(
      "Tool arguments must be an object.",
    );
  });

  it("rejects array rawInput", () => {
    expect(() => resolveCollectCommitContextToolInput([])).toThrow(
      "Tool arguments must be an object.",
    );
  });
});

describe("resolveCollectCommitContextToolInput", () => {
  it("returns workspaceRoot from explicit workspace_root", () => {
    expect(
      resolveCollectCommitContextToolInput({ workspace_root: "C:/ws" }),
    ).toEqual({ workspaceRoot: "C:/ws" });
  });

  it("uses fallback when workspace_root is missing", () => {
    expect(resolveCollectCommitContextToolInput({}, "C:/fb")).toEqual({
      workspaceRoot: "C:/fb",
    });
  });
});

describe("resolveCollectPrContextToolInput", () => {
  it("returns workspaceRoot and base for valid input", () => {
    expect(
      resolveCollectPrContextToolInput({
        workspace_root: "C:/ws",
        base: "main",
      }),
    ).toEqual({ workspaceRoot: "C:/ws", base: "main" });
  });

  it("rejects missing base field", () => {
    expect(() =>
      resolveCollectPrContextToolInput({ workspace_root: "C:/ws" }),
    ).toThrow("Field 'base' must be a string.");
  });
});

describe("resolvePushDownCopilotCustomizationsToolInput", () => {
  it("returns workspaceRoot from explicit value", () => {
    expect(
      resolvePushDownCopilotCustomizationsToolInput({
        workspace_root: "C:/ws",
      }),
    ).toEqual({ workspaceRoot: "C:/ws" });
  });
});

describe("resolvePushDownCodexAndAgentsCustomizationsToolInput", () => {
  it("returns workspaceRoot from explicit value", () => {
    expect(
      resolvePushDownCodexAndAgentsCustomizationsToolInput({
        workspace_root: "C:/ws",
      }),
    ).toEqual({ workspaceRoot: "C:/ws" });
  });
});

describe("resolveNewPotentialBugEntryToolInput", () => {
  it("returns workspaceRoot and shortName for valid input", () => {
    expect(
      resolveNewPotentialBugEntryToolInput({
        workspace_root: "C:/ws",
        short_name: "fix-crash",
      }),
    ).toEqual({ workspaceRoot: "C:/ws", shortName: "fix-crash" });
  });

  it("rejects missing short_name", () => {
    expect(() =>
      resolveNewPotentialBugEntryToolInput({ workspace_root: "C:/ws" }),
    ).toThrow("Field 'short_name' must be a string.");
  });
});

describe("resolveNewPotentialEntryToolInput", () => {
  it("returns workspaceRoot and shortName for valid input", () => {
    expect(
      resolveNewPotentialEntryToolInput({
        workspace_root: "C:/ws",
        short_name: "new-feature",
      }),
    ).toEqual({ workspaceRoot: "C:/ws", shortName: "new-feature" });
  });
});

describe("resolvePotentialToIssueToolInput", () => {
  it("returns all fields for valid input", () => {
    expect(
      resolvePotentialToIssueToolInput({
        workspace_root: "C:/ws",
        potential_path: "docs/potential/entry.md",
        promotion_type: "feature",
        work_mode: "full-feature",
      }),
    ).toEqual({
      workspaceRoot: "C:/ws",
      potentialPath: "docs/potential/entry.md",
      promotionType: "feature",
      workMode: "full-feature",
    });
  });

  it("rejects missing promotion_type", () => {
    expect(() =>
      resolvePotentialToIssueToolInput({
        workspace_root: "C:/ws",
        potential_path: "docs/entry.md",
        work_mode: "full-feature",
      }),
    ).toThrow("Field 'promotion_type' must be a string.");
  });
});

describe("resolveNewActiveFeatureFolderToolInput", () => {
  it("returns all fields including issueNumber when provided", () => {
    expect(
      resolveNewActiveFeatureFolderToolInput({
        workspace_root: "C:/ws",
        feature_name: "add-widget",
        type: "feature",
        work_mode: "full-feature",
        issue_number: "42",
      }),
    ).toEqual({
      workspaceRoot: "C:/ws",
      featureName: "add-widget",
      type: "feature",
      workMode: "full-feature",
      issueNumber: "42",
    });
  });

  it("omits issueNumber when not provided", () => {
    const result = resolveNewActiveFeatureFolderToolInput({
      workspace_root: "C:/ws",
      feature_name: "add-widget",
      type: "feature",
      work_mode: "full-feature",
    });
    expect(result.workspaceRoot).toBe("C:/ws");
    expect("issueNumber" in result).toBe(false);
  });
});

describe("resolveResolveExecuteHardLockPromptToolInput", () => {
  it("returns workspaceRoot and target for valid input", () => {
    expect(
      resolveResolveExecuteHardLockPromptToolInput({
        workspace_root: "C:/ws",
        target: "docs/plan.md",
      }),
    ).toEqual({ workspaceRoot: "C:/ws", target: "docs/plan.md" });
  });

  it("rejects missing target", () => {
    expect(() =>
      resolveResolveExecuteHardLockPromptToolInput({
        workspace_root: "C:/ws",
      }),
    ).toThrow("Field 'target' must be a string.");
  });
});
