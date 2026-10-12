import { describe, expect, it } from "@jest/globals";

import { validateEpicOrchestratorStateText } from "../../../src/lib/validate/epic-orchestrator-state-core";

describe("validateEpicOrchestratorStateText duplicate-folder ordering", () => {
  it("889-cp-order: reports duplicate feature folders in code-point order (U+FF5E before U+1F600)", () => {
    // Arrange: each folder appears twice; the supplementary-plane folder is
    // inserted first so default UTF-16 order would report it first.
    const supplementary = "\u{1F600}";
    const highBmp = "～";
    const text = JSON.stringify({
      features: [
        { feature_folder: supplementary },
        { feature_folder: supplementary },
        { feature_folder: highBmp },
        { feature_folder: highBmp },
      ],
    });

    // Act
    const errors = validateEpicOrchestratorStateText(text);

    // Assert: only the duplicate-folder messages, U+FF5E first.
    const duplicateErrors = errors.filter((error) =>
      error.includes("duplicate features[].feature_folder"),
    );
    expect(duplicateErrors).toEqual([
      `Epic checkpoint has duplicate features[].feature_folder: ${highBmp}`,
      `Epic checkpoint has duplicate features[].feature_folder: ${supplementary}`,
    ]);
  });
});
