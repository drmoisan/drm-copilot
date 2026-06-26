import { describe, expect, it } from "@jest/globals";

import {
  promotePotential,
  PromotionError,
} from "../../../src/lib/potential-to-issue/promotion";
import {
  buildFeatureContent,
  FakeGhClient,
  FakePotentialFileSystem,
  type RecordedGhCall,
  WORKSPACE,
} from "./promotion-test-support";

/**
 * Core promotion-workflow scenarios ported from `test_potential_to_issue.py`:
 * input validation, the feature success path, the failure path, bug routing,
 * minor-audit routing, and work-mode normalization. Missing-label recovery and
 * smart-punctuation scenarios live in `promotion.missing-label.test.ts`. The
 * shared fakes keep every case hermetic (no real gh/git/filesystem/temp files).
 */
describe("promotePotential — input validation", () => {
  it("throws a PromotionError for an invalid promotion type", () => {
    const fs = new FakePotentialFileSystem();
    fs.files.set("/workspace/tmp/file.md", "# Title");
    expect(() =>
      promotePotential({
        potentialPath: "/workspace/tmp/file.md",
        promotionType: "invalid",
        fs,
        gh: new FakeGhClient({ output: [], exitCode: 0 }),
        workspace: WORKSPACE,
      }),
    ).toThrow(new PromotionError("Invalid promotion type: invalid"));
  });

  it("throws a PromotionError for an invalid work mode", () => {
    const fs = new FakePotentialFileSystem();
    fs.files.set("/workspace/tmp/file.md", "# Title");
    expect(() =>
      promotePotential({
        potentialPath: "/workspace/tmp/file.md",
        promotionType: "feature",
        workMode: "bogus",
        fs,
        gh: new FakeGhClient({ output: [], exitCode: 0 }),
        workspace: WORKSPACE,
      }),
    ).toThrow(new PromotionError("Invalid work mode: bogus"));
  });

  it("throws the auth error when gh is not authenticated", () => {
    const fs = new FakePotentialFileSystem();
    const potential = "/workspace/docs/features/potential/test.md";
    fs.files.set(potential, "# Test\n## Problem / Why\nwhy");
    const gh = new FakeGhClient(
      { output: ["should not be called"], exitCode: 1 },
      null,
      { output: [], exitCode: 0 },
      false,
    );

    expect(() =>
      promotePotential({
        potentialPath: potential,
        fs,
        gh,
        workspace: WORKSPACE,
      }),
    ).toThrow(
      new PromotionError(
        "GitHub CLI is not authenticated. Run 'gh auth login' first.",
      ),
    );
    expect(gh.calls).toHaveLength(0);
  });

  it("throws not-found using the original path argument", () => {
    const fs = new FakePotentialFileSystem();
    expect(() =>
      promotePotential({
        potentialPath: "/missing.md",
        fs,
        gh: new FakeGhClient({ output: [], exitCode: 0 }),
        workspace: WORKSPACE,
      }),
    ).toThrow(new PromotionError("Potential file not found: /missing.md"));
  });

  it("throws empty using the resolved path", () => {
    const fs = new FakePotentialFileSystem();
    const potential = "/workspace/docs/features/potential/empty.md";
    fs.files.set(potential, "   \n  ");
    expect(() =>
      promotePotential({
        potentialPath: potential,
        fs,
        gh: new FakeGhClient({ output: [], exitCode: 0 }),
        workspace: WORKSPACE,
      }),
    ).toThrow(new PromotionError(`Potential file is empty: ${potential}`));
  });
});

describe("promotePotential — feature promotion success", () => {
  it("creates the issue, updates metadata, and moves the file", () => {
    // Arrange
    const fs = new FakePotentialFileSystem();
    const potential = "/workspace/docs/features/potential/sample.md";
    fs.files.set(
      potential,
      [
        "# Feature Title",
        "## Problem / Why",
        "why",
        "## Proposed Behavior",
        "behave",
        "## Acceptance Criteria (early draft)",
        "criteria",
        "## Constraints & Risks",
        "risk",
        "## Test Conditions to Consider",
        "tests",
      ].join("\n"),
    );
    const gh = new FakeGhClient(
      { output: ["Created: https://example.com/issues/123"], exitCode: 0 },
      {
        output: [
          '{"number":123,"title":"t","url":"https://example.com/issues/123","author":{"login":"me"},"updatedAt":"2024-01-02T00:00:00Z"}',
        ],
        exitCode: 0,
      },
    );
    const messages: string[] = [];

    // Act
    const outcome = promotePotential({
      potentialPath: potential,
      promotionType: "feature",
      fs,
      gh,
      workspace: WORKSPACE,
      emit: (m) => messages.push(m),
    });

    // Assert
    expect(outcome.exitCode).toBe(0);
    const expectedDest =
      "/workspace/docs/features/potential/promoted/sample.md";
    expect(outcome.destination).toBe(expectedDest);
    expect(gh.calls).toHaveLength(2);
    expect(fs.moves).toContainEqual([potential, expectedDest]);

    const promoted = fs.files.get(expectedDest) ?? "";
    const lines = promoted.split("\n");
    expect(lines[0]).toBe("# Feature Title (Issue #123)");
    expect(lines).toContain("- Issue: #123");
    expect(lines).toContain("- Issue URL: https://example.com/issues/123");
    expect(lines).toContain("- Last Updated: 2024-01-02");
    expect(lines).toContain(
      "- Status: Promoted -> docs/features/active/Feature_Title/ (Issue #123)",
    );
    expect(messages.some((m) => m.startsWith("Moved potential file"))).toBe(
      true,
    );
  });
});

describe("promotePotential — failure path", () => {
  it("returns the create exit code and does not move on a non-zero, non-label failure", () => {
    // Arrange
    const fs = new FakePotentialFileSystem();
    const potential = "/workspace/docs/features/potential/sample.md";
    const original = "# Feature Title\n## Problem / Why\nwhy";
    fs.files.set(potential, original);
    const gh = new FakeGhClient({ output: ["line1", "line2"], exitCode: 1 });
    const messages: string[] = [];

    // Act
    const outcome = promotePotential({
      potentialPath: potential,
      promotionType: "feature",
      fs,
      gh,
      workspace: WORKSPACE,
      emit: (m) => messages.push(m),
    });

    // Assert
    expect(outcome.exitCode).toBe(1);
    expect(outcome.destination).toBeUndefined();
    expect(fs.moves).toEqual([]);
    expect(fs.files.get(potential)).toBe(original);
    const [verb, args] = gh.calls[0] as RecordedGhCall;
    expect(verb).toBe("create");
    expect(args[0]).toBe("Feature: Feature Title");
    expect(args[2]).toBe("feature");
    const body = args[1] ?? "";
    expect(body).toContain("## Problem / Why\nwhy");
    expect(body).toContain(
      "## Proposed Behavior\n(not provided in potential file)",
    );
    expect(messages).toContain("line1");
    expect(messages).toContain("line2");
  });

  it("emits a synthetic line when create output is empty", () => {
    const fs = new FakePotentialFileSystem();
    const potential = "/workspace/docs/features/potential/sample.md";
    fs.files.set(potential, "# Title\n## Problem / Why\nwhy");
    const gh = new FakeGhClient({ output: [], exitCode: 5 });
    const messages: string[] = [];

    const outcome = promotePotential({
      potentialPath: potential,
      fs,
      gh,
      workspace: WORKSPACE,
      emit: (m) => messages.push(m),
    });

    expect(outcome.exitCode).toBe(5);
    expect(messages).toContain("gh CLI exited with code 5");
  });
});

describe("promotePotential — bug promotion", () => {
  it("routes through the bug-section body", () => {
    // Arrange
    const fs = new FakePotentialFileSystem();
    const potential = "/workspace/docs/features/potential/sample-bug.md";
    fs.files.set(
      potential,
      [
        "# Sample Bug (Potential Bug)",
        "## Summary",
        "summary details",
        "## Environment",
        "- OS: Linux",
        "## Steps to Reproduce",
        "1. step one",
        "## Expected Behavior",
        "expected results",
        "## Actual Behavior",
        "actual results",
        "## Impact / Severity",
        "medium",
        "## Logs / Screenshots",
        "screenshot attached",
      ].join("\n"),
    );
    const gh = new FakeGhClient(
      { output: ["Created: https://example.com/issues/200"], exitCode: 0 },
      {
        output: ['{"number":200,"updatedAt":"2024-02-01T00:00:00Z"}'],
        exitCode: 0,
      },
    );

    // Act
    const outcome = promotePotential({
      potentialPath: potential,
      promotionType: "bug",
      fs,
      gh,
      workspace: WORKSPACE,
    });

    // Assert
    expect(outcome.exitCode).toBe(0);
    const [verb, args] = gh.calls[0] as RecordedGhCall;
    expect(verb).toBe("create");
    expect(args[0]).toBe("Bug: Sample Bug");
    expect(args[2]).toBe("bug");
    const body = args[1] ?? "";
    expect(body).toContain("## Summary\nsummary details");
    expect(body).toContain("## Logs / Screenshots\nscreenshot attached");
    expect(body).toContain(
      "## Source\nFrom: docs/features/potential/sample-bug.md",
    );
  });

  it("fills missing bug sections with placeholders", () => {
    const fs = new FakePotentialFileSystem();
    const potential = "/workspace/docs/features/potential/placeholder-bug.md";
    fs.files.set(
      potential,
      ["# Placeholder Bug", "## Summary", "only summary"].join("\n"),
    );
    const gh = new FakeGhClient({
      output: ["Created: https://example.com/issues/300"],
      exitCode: 0,
    });

    promotePotential({
      potentialPath: potential,
      promotionType: "bug",
      fs,
      gh,
      workspace: WORKSPACE,
    });

    const body = (gh.calls[0] as RecordedGhCall)[1][1] ?? "";
    expect(body).toContain("## Summary\nonly summary");
    expect(body).toContain("## Environment\n(not provided in potential file)");
  });
});

describe("promotePotential — minor-audit routing", () => {
  it("routes through the minor-audit body with the default Evidence Checklist", () => {
    // Arrange: no Evidence Checklist section, so the default is applied.
    const fs = new FakePotentialFileSystem();
    const potential = "/workspace/docs/features/potential/minor.md";
    fs.files.set(potential, buildFeatureContent("Minor Audit Feature"));
    const gh = new FakeGhClient(
      { output: ["Created: https://example.com/issues/55"], exitCode: 0 },
      { output: [], exitCode: 0 },
    );
    const messages: string[] = [];

    // Act
    const outcome = promotePotential({
      potentialPath: potential,
      promotionType: "feature",
      fs,
      gh,
      workspace: WORKSPACE,
      workMode: "minor-audit",
      emit: (m) => messages.push(m),
    });

    // Assert
    expect(outcome.exitCode).toBe(0);
    const body = (gh.calls[0] as RecordedGhCall)[1][1] ?? "";
    expect(body).toContain("## Implementation Intent");
    expect(body).toContain("## Verification Steps");
    expect(body).toContain(
      "## Evidence Checklist\n- [ ] Baseline\n- [ ] End-state\n- [ ] Targeted verification",
    );
    expect(messages).toContain("Selected mode: minor-audit");
    expect(messages.some((m) => m.startsWith("Fallback reason:"))).toBe(false);
  });

  it("persists the minor-audit work-mode marker above the first section", () => {
    const fs = new FakePotentialFileSystem();
    const potential = "/workspace/docs/features/potential/minor-marker.md";
    fs.files.set(
      potential,
      [
        "# Minor Marker Feature",
        "- File: scripts/dev_tools/potential_to_issue.py",
        "- Risk: low",
        "## Problem / Why",
        "problem",
        "## Proposed Behavior",
        "behavior",
      ].join("\n"),
    );
    const gh = new FakeGhClient(
      { output: ["Created: https://example.com/issues/56"], exitCode: 0 },
      { output: [], exitCode: 0 },
    );

    const outcome = promotePotential({
      potentialPath: potential,
      promotionType: "feature",
      fs,
      gh,
      workspace: WORKSPACE,
      workMode: "minor-audit",
    });

    expect(outcome.exitCode).toBe(0);
    const body = (gh.calls[0] as RecordedGhCall)[1][1] ?? "";
    const lines = body.split("\n");
    const firstSection = lines.indexOf("## Problem / Why");
    expect(firstSection).toBeGreaterThan(0);
    expect(lines[firstSection - 1]).toBe("- Work Mode: minor-audit");
  });
});

describe("promotePotential — work-mode normalization", () => {
  it("normalizes the legacy full alias to full-feature for feature work", () => {
    const fs = new FakePotentialFileSystem();
    const potential = "/workspace/docs/features/potential/full-mode.md";
    fs.files.set(potential, buildFeatureContent("Full Mode"));
    const gh = new FakeGhClient(
      { output: ["Created: https://example.com/issues/99"], exitCode: 0 },
      { output: [], exitCode: 0 },
    );

    promotePotential({
      potentialPath: potential,
      promotionType: "feature",
      fs,
      gh,
      workspace: WORKSPACE,
      workMode: "full",
    });

    const body = (gh.calls[0] as RecordedGhCall)[1][1] ?? "";
    expect(body).toContain("- Work Mode: full-feature");
    expect(body).toContain("## Proposed Behavior");
    expect(body).not.toContain("## Implementation Intent");
  });

  it("re-wraps an incompatible work-mode/type combination as a PromotionError", () => {
    // Arrange: full-feature with a bug promotion is rejected by normalize.
    const fs = new FakePotentialFileSystem();
    const potential = "/workspace/docs/features/potential/bad-combo.md";
    fs.files.set(potential, buildFeatureContent("Bad Combo"));
    const gh = new FakeGhClient({ output: [], exitCode: 0 });

    // Act / Assert: the ValueError is re-wrapped with the same message.
    expect(() =>
      promotePotential({
        potentialPath: potential,
        promotionType: "bug",
        fs,
        gh,
        workspace: WORKSPACE,
        workMode: "full-feature",
      }),
    ).toThrow(new PromotionError("full-feature may not be used with bug work"));
  });
});
