import { describe, expect, it } from "@jest/globals";

import {
  isMissingLabelFailure,
  promotePotential,
} from "../../../src/lib/potential-to-issue/promotion";
import {
  buildFeatureContent,
  FakeGhClient,
  FakePotentialFileSystem,
  type RecordedGhCall,
  WORKSPACE,
} from "./promotion-test-support";

/**
 * Missing-label recovery, smart-punctuation, emitted-line ordering, and
 * `isMissingLabelFailure` scenarios ported from `test_potential_to_issue.py`
 * and `test_potential_to_issue_missing_label_regression.py`. Split from
 * `promotion.test.ts` so both files stay within the 500-line limit. The shared
 * fakes keep every case hermetic (no real gh/git/filesystem/temp files).
 */
describe("promotePotential — missing-label recovery", () => {
  it("recovers from a missing-label create failure and moves the file", () => {
    // Arrange: first create fails with the missing-label message; retry succeeds.
    const fs = new FakePotentialFileSystem();
    const potential =
      "/workspace/docs/features/potential/missing-refactor-label.md";
    fs.files.set(potential, buildFeatureContent("Missing Refactor Label"));
    const gh = new FakeGhClient(
      [
        { output: ["could not add label: 'refactor' not found"], exitCode: 1 },
        { output: ["Created: https://example.com/issues/456"], exitCode: 0 },
      ],
      {
        output: ['{"number":456,"updatedAt":"2024-04-06T00:00:00Z"}'],
        exitCode: 0,
      },
      { output: ["refactor label ensured"], exitCode: 0 },
    );

    // Act
    const outcome = promotePotential({
      potentialPath: potential,
      promotionType: "refactor",
      fs,
      gh,
      workspace: WORKSPACE,
    });

    // Assert: single ensureLabel call, two creates, file moved.
    expect(outcome.exitCode).toBe(0);
    const expectedDest =
      "/workspace/docs/features/potential/promoted/missing-refactor-label.md";
    expect(outcome.destination).toBe(expectedDest);
    expect(gh.ensureLabelCalls).toEqual(["refactor"]);
    const createCalls = gh.calls.filter((c) => c[0] === "create");
    expect(createCalls).toHaveLength(2);
    expect(createCalls.every((c) => c[1][2] === "refactor")).toBe(true);
    expect(fs.moves).toContainEqual([potential, expectedDest]);
  });

  it("does not retry when ensureLabel returns a non-zero exit", () => {
    // Arrange: missing-label failure, but ensureLabel fails, so no retry.
    const fs = new FakePotentialFileSystem();
    const potential = "/workspace/docs/features/potential/no-retry.md";
    fs.files.set(potential, buildFeatureContent("No Retry"));
    const gh = new FakeGhClient(
      [
        { output: ["could not add label: 'feature' not found"], exitCode: 1 },
        { output: ["Created: https://example.com/issues/1"], exitCode: 0 },
      ],
      { output: [], exitCode: 0 },
      { output: ["label create failed"], exitCode: 1 },
    );

    // Act
    const outcome = promotePotential({
      potentialPath: potential,
      promotionType: "feature",
      fs,
      gh,
      workspace: WORKSPACE,
    });

    // Assert: exactly one create call; the failure exit code is returned.
    const createCalls = gh.calls.filter((c) => c[0] === "create");
    expect(createCalls).toHaveLength(1);
    expect(outcome.exitCode).toBe(1);
    expect(fs.moves).toEqual([]);
  });

  it("existing label uses a single create attempt with no ensureLabel", () => {
    const fs = new FakePotentialFileSystem();
    const potential = "/workspace/docs/features/potential/existing.md";
    fs.files.set(potential, buildFeatureContent("Existing Feature Label"));
    const gh = new FakeGhClient(
      { output: ["Created: https://example.com/issues/322"], exitCode: 0 },
      { output: [], exitCode: 0 },
    );

    const outcome = promotePotential({
      potentialPath: potential,
      promotionType: "feature",
      fs,
      gh,
      workspace: WORKSPACE,
    });

    expect(outcome.exitCode).toBe(0);
    const createCalls = gh.calls.filter((c) => c[0] === "create");
    expect(createCalls).toHaveLength(1);
    expect(gh.ensureLabelCalls).toEqual([]);
  });
});

describe("promotePotential — smart punctuation and emitted lines", () => {
  it("normalizes smart punctuation in the title and body", () => {
    // Arrange
    const fs = new FakePotentialFileSystem();
    const potential = "/workspace/docs/features/potential/smart.md";
    fs.files.set(
      potential,
      [
        "# “Curly” Feature (Potential Bug)",
        "## Summary",
        "Title uses “smart” quotes and an en dash – plus nbsp here.",
        "## Environment",
        "- OS: “Windows” ",
        "## Expected Behavior",
        "expected with em dash — and quote “",
        "## Actual Behavior",
        "actual with smart apostrophe ’",
      ].join("\n"),
    );
    const gh = new FakeGhClient(
      { output: ["Created: https://example.com/issues/400"], exitCode: 0 },
      { output: [], exitCode: 0 },
    );

    // Act
    promotePotential({
      potentialPath: potential,
      promotionType: "bug",
      fs,
      gh,
      workspace: WORKSPACE,
    });

    // Assert
    const [, args] = gh.calls[0] as RecordedGhCall;
    const title = args[0] ?? "";
    const body = args[1] ?? "";
    expect(title).toContain("Curly");
    expect(title).not.toContain("“");
    expect(body).not.toContain("“");
    expect(body).not.toContain("–");
    expect(body).not.toContain("—");
  });

  it("emits the expected lines in order on the success path", () => {
    const fs = new FakePotentialFileSystem();
    const potential = "/workspace/docs/features/potential/sample.md";
    fs.files.set(potential, buildFeatureContent("Lines Feature"));
    const gh = new FakeGhClient(
      { output: ["Created: https://example.com/issues/77"], exitCode: 0 },
      { output: [], exitCode: 0 },
    );
    const messages: string[] = [];

    promotePotential({
      potentialPath: potential,
      promotionType: "feature",
      fs,
      gh,
      workspace: WORKSPACE,
      emit: (m) => messages.push(m),
    });

    expect(messages).toContain("Selected mode: full-feature");
    expect(messages).toContain(
      "Creating issue: Feature: Lines Feature (label: feature)",
    );
    expect(
      messages.some((m) =>
        m.startsWith("Updated potential file with issue metadata:"),
      ),
    ).toBe(true);
    expect(
      messages.some((m) =>
        m.startsWith("Moved potential file to promoted folder:"),
      ),
    ).toBe(true);
  });
});

describe("isMissingLabelFailure", () => {
  it("matches case-insensitively for the specific label fragment", () => {
    expect(
      isMissingLabelFailure(
        ["COULD NOT ADD LABEL: 'feature' NOT FOUND"],
        "feature",
      ),
    ).toBe(true);
  });

  it("does not match a different label", () => {
    expect(
      isMissingLabelFailure(
        ["could not add label: 'bug' not found"],
        "feature",
      ),
    ).toBe(false);
  });

  it("does not match unrelated output", () => {
    expect(isMissingLabelFailure(["some other error"], "feature")).toBe(false);
  });
});
