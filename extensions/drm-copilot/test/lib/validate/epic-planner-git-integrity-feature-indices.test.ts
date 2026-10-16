import { describe, expect, it } from "@jest/globals";

import type { ParsedEpicKickoff } from "../../../src/lib/validate/epic-kickoff-artifact";
import {
  type ReadinessGitRepository,
  validatePlanningGitIntegrity,
} from "../../../src/lib/validate/epic-planner-git-integrity";

const BRANCH = "epic/sample-epic-integration";
const COMMIT = "1".repeat(40);
const HASH = "a".repeat(40);
const PLAN_101 = "docs/features/active/feature-101/plan.md";
const PLAN_102 = "docs/features/active/feature-102/plan.md";
const INDEX_ZERO_COMMIT_ERROR =
  "Epic planner checkpoint features[0].planning_commit must be hexadecimal.";
const INDEX_ONE_COMMIT_ERROR =
  "Epic planner checkpoint features[1].planning_commit must be hexadecimal.";
const INDEX_TWO_COMMIT_ERROR =
  "Epic planner checkpoint features[2].planning_commit must be hexadecimal.";

/** Git fake under which every plan is committed and unchanged. */
const git: ReadinessGitRepository = {
  refExists: (ref) => ref === BRANCH,
  commitExists: (commit) => commit === COMMIT,
  isAncestor: (commit, ref) => commit === COMMIT && ref === BRANCH,
  lastCommit: () => COMMIT,
  committedBlobHash: (ref) => (ref === COMMIT ? HASH : undefined),
  worktreeBlobHash: () => HASH,
};

const parsed: ParsedEpicKickoff = {
  slug: "sample-epic",
  invocationSlug: "sample-epic",
  manifestPath: "docs/features/epics/sample-epic/epic.md",
  integrationBranch: BRANCH,
  features: [],
  planHashes: {},
};

/** Validate Git integrity for the given checkpoint features and plans. */
function errorsFor(features: unknown, plans: readonly string[]): string[] {
  return validatePlanningGitIntegrity(
    { integration_branch: BRANCH, features },
    parsed,
    plans,
    git,
  );
}

const emptyCases: ReadonlyArray<{
  readonly label: string;
  readonly features: unknown;
}> = [
  { label: "empty", features: [] },
  { label: "non-list", features: "not-a-list" },
];

describe("validatePlanningGitIntegrity original feature index", () => {
  it("uses the original feature index after a non-object entry", () => {
    const features = [
      "not-a-feature",
      { plan_path: PLAN_101 },
      { plan_path: PLAN_102, planning_commit: "bad" },
    ];

    const errors = errorsFor(features, [PLAN_101, PLAN_102]);

    expect(errors).toEqual([INDEX_TWO_COMMIT_ERROR]);
  });

  it("uses the original feature index after a plan-less entry", () => {
    const features = [
      { plan_path: 7 },
      { plan_path: PLAN_101, planning_commit: "bad" },
    ];

    const errors = errorsFor(features, [PLAN_101]);

    expect(errors).toEqual([INDEX_ONE_COMMIT_ERROR]);
  });

  it("keeps the feature index unchanged without skipped entries", () => {
    const features = [
      { plan_path: PLAN_101 },
      { plan_path: PLAN_102, planning_commit: "bad" },
    ];

    const errors = errorsFor(features, [PLAN_101, PLAN_102]);

    expect(errors).toEqual([INDEX_ONE_COMMIT_ERROR]);
  });

  it("keeps the positional pairing when no entry carries the plan", () => {
    const features = [{ planning_commit: "bad" }];

    const errors = errorsFor(features, [PLAN_101]);

    expect(errors).toEqual([INDEX_ZERO_COMMIT_ERROR]);
  });

  it("matches a dot-prefixed plan_path to its normalized plan", () => {
    const features = [
      "not-a-feature",
      { plan_path: PLAN_101 },
      { plan_path: `./${PLAN_102}`, planning_commit: "bad" },
    ];

    const errors = errorsFor(features, [PLAN_101, PLAN_102]);

    expect(errors).toEqual([INDEX_TWO_COMMIT_ERROR]);
  });

  it.each(emptyCases)(
    "reports no feature error for a $label features value",
    ({ features }) => {
      expect(errorsFor(features, [PLAN_101])).toEqual([]);
    },
  );
});
