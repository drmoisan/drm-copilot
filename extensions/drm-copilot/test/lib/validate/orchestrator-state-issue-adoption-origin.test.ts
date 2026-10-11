import { describe, expect, it } from "@jest/globals";

import {
  resolveIssueAdoption,
  type IssueAdoptionResult,
} from "../../../src/lib/validate/orchestrator-state-issue-adoption";

/**
 * Unit tests for the origin-conditional potential_record requirement (issue #849).
 *
 * These cases mirror the issue #849 group in
 * `tests/scripts/dev_tools/test_orchestrator_state_issue_adoption_waivers.py`:
 * a promotion-entry waiver needs no potential_record when origin is
 * `transferred` or `filed_before_orchestration` and the key is absent, still
 * needs one when origin is `epic_decomposition`, and a present record is always
 * validated. No file is read, and no timer, clock, or random source is used.
 */

const LARGE_TOOLS: readonly string[] = [
  "new_potential_entry",
  "potential_to_issue",
  "new_active_feature_folder",
  "collect_pr_context",
  "validate_orchestration_artifacts",
];
const LARGE_BUG_TOOLS: readonly string[] = [
  "new_potential_bug_entry",
  "potential_to_issue",
  "new_active_feature_folder",
  "collect_pr_context",
  "validate_orchestration_artifacts",
];
const PREPARATION_BUG_TOOLS: readonly string[] = [
  "new_potential_bug_entry",
  "potential_to_issue",
  "new_active_feature_folder",
  "validate_orchestration_artifacts",
];
const NON_WAIVABLE_SUCCESSFUL: ReadonlySet<string> = new Set([
  "new_active_feature_folder",
  "collect_pr_context",
  "validate_orchestration_artifacts",
]);
const PREPARATION_SUCCESSFUL: ReadonlySet<string> = new Set([
  "new_active_feature_folder",
  "validate_orchestration_artifacts",
]);

const E4 =
  "Checkpoint issue_adoption.origin must be one of transferred, filed_before_orchestration, epic_decomposition.";

/** Return the rule-9 invalid-potential-record message for a tool. */
const e9 = (tool: string): string =>
  `Checkpoint issue_adoption.potential_record must name a markdown file under docs/features/potential/ when waiving ${tool}.`;

/** Return the base valid adoption record for issue 509 with overrides. */
function adoption(
  overrides: Record<string, unknown> = {},
): Record<string, unknown> {
  return {
    issue_num: "509",
    issue_url: "https://github.com/drmoisan/drm-copilot/issues/509",
    origin: "transferred",
    verified_via: "gh_issue_view",
    verified_at: "2026-09-29T15:15:00Z",
    evidence:
      "gh issue view 509 --json number,state,url: number 509, state OPEN",
    waived_tools: ["potential_to_issue"],
    ...overrides,
  };
}

/** Return a minimal checkpoint carrying the given adoption value. */
function stateWith(
  value: unknown,
  promotionType = "feature",
): Record<string, unknown> {
  return {
    "issue-num": "509",
    "promotion-type": promotionType,
    issue_adoption: value,
  };
}

/** Run the resolver with the large-route defaults unless overridden. */
function resolve(
  state: Record<string, unknown>,
  routeId = "large",
  requiredMcpTools: readonly string[] = LARGE_TOOLS,
  successfulTools: ReadonlySet<string> = NON_WAIVABLE_SUCCESSFUL,
): IssueAdoptionResult {
  return resolveIssueAdoption(state, {
    routeId,
    requiredMcpTools,
    successfulTools,
  });
}

/** Return the waived set as a sorted array for exact comparison. */
function waived(result: IssueAdoptionResult): string[] {
  return [...result.waivedTools].sort();
}

describe("issue-adoption potential_record requirement by origin (issue #849)", () => {
  it("waives the bug entry tool without a record when origin is filed_before_orchestration", () => {
    // Arrange
    const state = stateWith(
      adoption({
        origin: "filed_before_orchestration",
        waived_tools: ["potential_to_issue", "new_potential_bug_entry"],
      }),
      "bug",
    );

    // Act
    const result = resolve(state, "large", LARGE_BUG_TOOLS);

    // Assert
    expect(result.errors).toEqual([]);
    expect(waived(result)).toEqual([
      "new_potential_bug_entry",
      "potential_to_issue",
    ]);
  });

  it("waives the feature entry tool without a record when origin is transferred", () => {
    // Arrange
    const state = stateWith(
      adoption({
        origin: "transferred",
        waived_tools: ["potential_to_issue", "new_potential_entry"],
      }),
    );

    // Act
    const result = resolve(state);

    // Assert
    expect(result.errors).toEqual([]);
    expect(waived(result)).toEqual([
      "new_potential_entry",
      "potential_to_issue",
    ]);
  });

  it("waives the bug entry tool without a record on the preparation route", () => {
    // Arrange
    const state = stateWith(
      adoption({
        origin: "filed_before_orchestration",
        waived_tools: ["potential_to_issue", "new_potential_bug_entry"],
      }),
      "bug",
    );

    // Act
    const result = resolve(
      state,
      "preparation",
      PREPARATION_BUG_TOOLS,
      PREPARATION_SUCCESSFUL,
    );

    // Assert
    expect(result.errors).toEqual([]);
    expect(waived(result)).toEqual([
      "new_potential_bug_entry",
      "potential_to_issue",
    ]);
  });

  it("still reports rule 9 when origin is epic_decomposition and the record is absent", () => {
    // Arrange
    const state = stateWith(
      adoption({
        origin: "epic_decomposition",
        waived_tools: ["potential_to_issue", "new_potential_entry"],
      }),
    );

    // Act
    const result = resolve(state);

    // Assert
    expect(result.errors).toEqual([e9("new_potential_entry")]);
    expect(waived(result)).toEqual([]);
  });

  it("still reports rule 9 when origin is filed_before_orchestration and the record is null", () => {
    // Arrange
    const state = stateWith(
      adoption({
        origin: "filed_before_orchestration",
        waived_tools: ["potential_to_issue", "new_potential_entry"],
        potential_record: null,
      }),
    );

    // Act
    const result = resolve(state);

    // Assert
    expect(result.errors).toEqual([e9("new_potential_entry")]);
    expect(waived(result)).toEqual([]);
  });

  it("still reports rule 9 when origin is transferred and the record path is invalid", () => {
    // Arrange
    const state = stateWith(
      adoption({
        origin: "transferred",
        waived_tools: ["potential_to_issue", "new_potential_entry"],
        potential_record: "notes/record.txt",
      }),
    );

    // Act
    const result = resolve(state);

    // Assert
    expect(result.errors).toEqual([e9("new_potential_entry")]);
    expect(waived(result)).toEqual([]);
  });

  it("reports the origin error and rule 9 when origin is invalid and the record is absent", () => {
    // Arrange
    const state = stateWith(
      adoption({
        origin: "imported",
        waived_tools: ["potential_to_issue", "new_potential_entry"],
      }),
    );

    // Act
    const result = resolve(state);

    // Assert
    expect(result.errors).toEqual([E4, e9("new_potential_entry")]);
    expect(waived(result)).toEqual([]);
  });
});
