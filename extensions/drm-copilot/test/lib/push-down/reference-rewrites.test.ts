import { describe, expect, it } from "@jest/globals";

import {
  buildRewriteCatalog,
  normalizeReferenceForLookup,
  rewriteTextReferences,
  splitTrailingPunctuation,
} from "../../../src/lib/push-down/reference-rewrites";

describe("buildRewriteCatalog", () => {
  it("contains all seven catalog entries keyed by normalized reference", () => {
    // Arrange / Act
    const catalog = buildRewriteCatalog();

    // Assert
    expect([...catalog.keys()].sort()).toEqual(
      [
        "scripts.dev_tools.pr_context.collector",
        "scripts.dev_tools.new_active_feature_folder",
        "scripts.dev_tools.potential_to_issue",
        "scripts/dev_tools/new_potential_bug_entry.py",
        "scripts/dev_tools/new-potential-entry.ps1",
        "scripts.dev_tools.push_down_copilot_customizations",
        "scripts/dev_tools/sync-agents-from-instructions.ps1",
      ].sort(),
    );
  });
});

describe("normalizeReferenceForLookup", () => {
  it("strips the poetry run python -m prefix", () => {
    // Arrange / Act / Assert
    expect(
      normalizeReferenceForLookup(
        "poetry run python -m scripts.dev_tools.potential_to_issue",
      ),
    ).toBe("scripts.dev_tools.potential_to_issue");
  });

  it("strips a ${workspaceFolder} forward-slash prefix and normalizes dev-tools", () => {
    // Arrange / Act / Assert
    expect(
      normalizeReferenceForLookup(
        "${workspaceFolder}/scripts/dev-tools/new-potential-entry.ps1",
      ),
    ).toBe("scripts/dev_tools/new-potential-entry.ps1");
  });

  it("strips a ${workspaceFolder} backslash prefix and normalizes separators", () => {
    // Arrange / Act / Assert
    expect(
      normalizeReferenceForLookup(
        "${workspaceFolder}\\scripts\\dev_tools\\new_potential_bug_entry.py",
      ),
    ).toBe("scripts/dev_tools/new_potential_bug_entry.py");
  });
});

describe("splitTrailingPunctuation", () => {
  it("peels trailing sentence punctuation while preserving the core", () => {
    // Arrange / Act
    const [core, suffix] = splitTrailingPunctuation(
      "scripts.dev_tools.potential_to_issue).",
    );

    // Assert
    expect(core).toBe("scripts.dev_tools.potential_to_issue");
    expect(suffix).toBe(").");
  });

  it("returns the reference unchanged when there is no trailing punctuation", () => {
    // Arrange / Act
    const [core, suffix] = splitTrailingPunctuation("scripts.dev_tools.foo");

    // Assert
    expect(core).toBe("scripts.dev_tools.foo");
    expect(suffix).toBe("");
  });
});

describe("rewriteTextReferences", () => {
  it("rewrites the pr_context collector reference to the live command", () => {
    // Arrange
    const text =
      "Run poetry run python -m scripts.dev_tools.pr_context.collector before review.";

    // Act
    const [rewritten, rewrittenCount, placeholderCount, unmatched] =
      rewriteTextReferences(text);

    // Assert
    expect(rewrittenCount).toBe(1);
    expect(placeholderCount).toBe(0);
    expect(unmatched).toEqual([]);
    expect(rewritten).toContain(
      "VS Code command: `drm-copilot: Collect PR Context`",
    );
    expect(rewritten).toContain(
      "command ID: `drmCopilotExtension.collectPrContext`",
    );
    expect(rewritten).not.toContain("scripts.dev_tools.pr_context.collector");
  });

  it("rewrites the new_active_feature_folder reference", () => {
    // Arrange
    const text =
      "Use poetry run python -m scripts.dev_tools.new_active_feature_folder now.";

    // Act
    const [rewritten, rewrittenCount] = rewriteTextReferences(text);

    // Assert
    expect(rewrittenCount).toBe(1);
    expect(rewritten).toContain(
      "command ID: `drmCopilotExtension.newActiveFeatureFolder`",
    );
  });

  it("rewrites the potential_to_issue reference", () => {
    // Arrange
    const text = "See scripts.dev_tools.potential_to_issue here.";

    // Act
    const [rewritten, rewrittenCount] = rewriteTextReferences(text);

    // Assert
    expect(rewrittenCount).toBe(1);
    expect(rewritten).toContain(
      "command ID: `drmCopilotExtension.potentialToIssue`",
    );
  });

  it("normalizes both ${workspaceFolder} dev-tools slash variants", () => {
    // Arrange
    const text =
      "Run ${workspaceFolder}/scripts/dev_tools/new_potential_bug_entry.py and " +
      "${workspaceFolder}/scripts/dev-tools/new-potential-entry.ps1.";

    // Act
    const [rewritten, rewrittenCount, placeholderCount] =
      rewriteTextReferences(text);

    // Assert
    expect(rewrittenCount).toBe(2);
    expect(placeholderCount).toBe(0);
    expect(rewritten).toContain(
      "command ID: `drmCopilotExtension.newPotentialBugEntry`",
    );
    expect(rewritten).toContain(
      "command ID: `drmCopilotExtension.newPotentialEntry`",
    );
    expect(rewritten).not.toContain(
      "scripts/dev_tools/new_potential_bug_entry.py",
    );
    expect(rewritten).not.toContain(
      "scripts/dev-tools/new-potential-entry.ps1",
    );
  });

  it("rewrites the push_down_copilot_customizations reference", () => {
    // Arrange
    const text =
      "Run poetry run python -m scripts.dev_tools.push_down_copilot_customizations to push.";

    // Act
    const [rewritten, rewrittenCount] = rewriteTextReferences(text);

    // Assert
    expect(rewrittenCount).toBeGreaterThanOrEqual(1);
    expect(rewritten).toContain(
      "command ID: `drmCopilotExtension.pushDownCopilotCustomizations`",
    );
  });

  it("rewrites the sync-agents-from-instructions reference", () => {
    // Arrange
    const text =
      "Run ${workspaceFolder}/scripts/dev-tools/sync-agents-from-instructions.ps1 to regenerate.";

    // Act
    const [rewritten, rewrittenCount] = rewriteTextReferences(text);

    // Assert
    expect(rewrittenCount).toBe(1);
    expect(rewritten).toContain(
      "command ID: `drmCopilotExtension.syncAgentsFromInstructions`",
    );
    expect(rewritten).not.toContain("sync-agents-from-instructions.ps1");
  });

  it("preserves trailing punctuation around a rewritten reference", () => {
    // Arrange
    const text = "See scripts.dev_tools.potential_to_issue.";

    // Act
    const [rewritten] = rewriteTextReferences(text);

    // Assert: the trailing period is preserved immediately after the rendered
    // command reference, and the reference text itself is gone.
    expect(rewritten).toContain(
      "command ID: `drmCopilotExtension.potentialToIssue`).",
    );
    expect(rewritten).not.toContain("scripts.dev_tools.potential_to_issue");
  });

  it("reports unmatched references without rewriting them, in first-seen order", () => {
    // Arrange
    const text =
      "Run scripts.dev_tools.unknown_b then scripts.dev_tools.unknown_a then scripts.dev_tools.unknown_b again.";

    // Act
    const [rewritten, rewrittenCount, placeholderCount, unmatched] =
      rewriteTextReferences(text);

    // Assert: unchanged text, zero counts, deterministic first-seen order, dedup.
    expect(rewritten).toBe(text);
    expect(rewrittenCount).toBe(0);
    expect(placeholderCount).toBe(0);
    expect(unmatched).toEqual([
      "scripts.dev_tools.unknown_b",
      "scripts.dev_tools.unknown_a",
    ]);
  });

  it("leaves text with no script references unchanged", () => {
    // Arrange
    const text = "This prose mentions no scripts at all.";

    // Act
    const [rewritten, rewrittenCount, placeholderCount, unmatched] =
      rewriteTextReferences(text);

    // Assert
    expect(rewritten).toBe(text);
    expect(rewrittenCount).toBe(0);
    expect(placeholderCount).toBe(0);
    expect(unmatched).toEqual([]);
  });
});
