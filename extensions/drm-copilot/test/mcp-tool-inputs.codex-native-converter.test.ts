import { describe, expect, it } from "@jest/globals";

import { resolveRunCodexNativeConverterToolInput } from "../src/mcp-tool-inputs";

describe("resolveRunCodexNativeConverterToolInput", () => {
  it("normalizes review-mode converter input without requiring destination_root", () => {
    expect(
      resolveRunCodexNativeConverterToolInput({
        workspace_root: "C:/workspace",
        mode: "review",
        source_ecosystem: "github-copilot",
        source_root: "fixtures/source",
        selected_paths: [".github", "D:/exports/AGENTS.md"],
        artifact_root: "artifacts/codex-native-converter",
        enable_repo_prompts: true,
      }),
    ).toEqual({
      workspaceRoot: "C:/workspace",
      mode: "review",
      sourceEcosystem: "github-copilot",
      sourceRoot: "C:/workspace/fixtures/source",
      selectedPaths: ["C:/workspace/.github", "D:/exports/AGENTS.md"],
      artifactRoot: "C:/workspace/artifacts/codex-native-converter",
      enableRepoPrompts: true,
    });
  });

  it("rejects apply-mode converter input when destination_root or source_ecosystem is invalid", () => {
    expect(() =>
      resolveRunCodexNativeConverterToolInput({
        workspace_root: "C:/workspace",
        mode: "apply",
        source_ecosystem: "github-copilot",
        source_root: "fixtures/source",
      }),
    ).toThrow("Field 'destination_root' is required when mode is 'apply'.");

    expect(() =>
      resolveRunCodexNativeConverterToolInput({
        workspace_root: "C:/workspace",
        mode: "apply",
        source_ecosystem: "invalid",
        source_root: "fixtures/source",
        destination_root: "dest",
      }),
    ).toThrow("Field 'source_ecosystem' must be 'github-copilot' or 'claude'.");
  });
});
