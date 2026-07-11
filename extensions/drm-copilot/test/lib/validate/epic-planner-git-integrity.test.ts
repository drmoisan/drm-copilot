import { describe, expect, it } from "@jest/globals";

import type { ParsedEpicKickoff } from "../../../src/lib/validate/epic-kickoff-artifact";
import {
  type ReadinessGitRepository,
  validateCommittedFile,
  validatePlanningGitIntegrity,
} from "../../../src/lib/validate/epic-planner-git-integrity";

const BRANCH = "epic/sample-epic-integration";
const COMMIT = "1".repeat(40);
const FINAL_COMMIT = "2".repeat(40);
const HASH = "a".repeat(40);
const OTHER_HASH = "b".repeat(40);
const PLAN = "docs/features/active/feature-101/plan.md";

class GitStub implements ReadinessGitRepository {
  public ref = true;
  public readonly commits = new Set([COMMIT, FINAL_COMMIT]);
  public readonly ancestors = new Set([
    `${COMMIT}:${BRANCH}`,
    `${FINAL_COMMIT}:${BRANCH}`,
  ]);
  public last: string | undefined = COMMIT;
  public readonly committed = new Map([
    [`${COMMIT}:${PLAN}`, HASH],
    [`${FINAL_COMMIT}:${PLAN}`, HASH],
    [`${BRANCH}:file.md`, HASH],
  ]);
  public readonly worktree = new Map([
    [PLAN, HASH],
    ["file.md", HASH],
  ]);

  public refExists(): boolean {
    return this.ref;
  }

  public commitExists(commit: string): boolean {
    return this.commits.has(commit);
  }

  public isAncestor(commit: string, ref: string): boolean {
    return this.ancestors.has(`${commit}:${ref}`);
  }

  public lastCommit(): string | undefined {
    return this.last;
  }

  public committedBlobHash(ref: string, path: string): string | undefined {
    return this.committed.get(`${ref}:${path}`);
  }

  public worktreeBlobHash(path: string): string | undefined {
    return this.worktree.get(path);
  }
}

function parsed(overrides: Partial<ParsedEpicKickoff> = {}): ParsedEpicKickoff {
  return {
    slug: "sample-epic",
    invocationSlug: "sample-epic",
    manifestPath: "docs/features/epics/sample-epic/epic.md",
    integrationBranch: BRANCH,
    features: [],
    planHashes: {},
    ...overrides,
  };
}

function state(overrides: Readonly<Record<string, unknown>> = {}) {
  return {
    integration_branch: BRANCH,
    features: [{}],
    ...overrides,
  };
}

describe("validateCommittedFile", () => {
  it("reports missing, unhashable, and drifting files", () => {
    const git = new GitStub();

    expect(
      validateCommittedFile(git, BRANCH, "missing.md", "file")[0],
    ).toContain("requires file committed");
    git.committed.set(`${BRANCH}:missing-worktree.md`, HASH);
    expect(
      validateCommittedFile(git, BRANCH, "missing-worktree.md", "file")[0],
    ).toContain("could not hash worktree");
    git.committed.set(`${BRANCH}:drift.md`, HASH);
    git.worktree.set("drift.md", OTHER_HASH);
    expect(validateCommittedFile(git, BRANCH, "drift.md", "file")[0]).toContain(
      "worktree drift",
    );
    expect(validateCommittedFile(git, BRANCH, "file.md", "file")).toEqual([]);
  });
});

describe("validatePlanningGitIntegrity", () => {
  it("rejects a missing integration branch and missing derived commit", () => {
    const git = new GitStub();
    git.ref = false;
    expect(
      validatePlanningGitIntegrity(state(), parsed(), [PLAN], git)[0],
    ).toContain("branch does not exist");
    git.ref = true;
    git.last = undefined;
    expect(
      validatePlanningGitIntegrity(state(), parsed(), [PLAN], git)[0],
    ).toContain("could not derive");
  });

  it("validates optional integrity object, commit, and hash declarations", () => {
    const git = new GitStub();
    const invalid = validatePlanningGitIntegrity(
      state({
        integrity: "invalid",
        planning_commit: "not-a-commit",
        plan_hashes: "invalid",
      }),
      parsed({ planningCommit: FINAL_COMMIT }),
      [PLAN],
      git,
    );
    expect(invalid.join("\n")).toContain("integrity must be an object");
    expect(invalid.join("\n")).toContain("planning_commit values");
    expect(invalid.join("\n")).toContain("plan_hashes must be an object");
    expect(
      validatePlanningGitIntegrity(
        state({ planning_commit: COMMIT }),
        parsed({ planningCommit: FINAL_COMMIT }),
        [PLAN],
        git,
      ).join("\n"),
    ).toContain("must match");

    const hashes = validatePlanningGitIntegrity(
      state({
        integrity: {
          planning_commit: FINAL_COMMIT,
          plan_hashes: { [PLAN]: OTHER_HASH, "unknown.md": HASH, bad: 1 },
        },
      }),
      parsed({ planHashes: { [PLAN]: HASH } }),
      [PLAN],
      git,
    );
    expect(hashes.join("\n")).toContain("declarations disagree");
    expect(hashes.join("\n")).toContain("entries must map paths");
    expect(hashes.join("\n")).toContain("does not match committed bytes");
    expect(hashes.join("\n")).toContain("unknown planner path");
  });

  it("checks supplied commit existence and ancestry", () => {
    const git = new GitStub();
    git.commits.delete(FINAL_COMMIT);
    expect(
      validatePlanningGitIntegrity(
        state({ planning_commit: FINAL_COMMIT }),
        parsed(),
        [PLAN],
        git,
      ).join("\n"),
    ).toContain("planning commit does not exist");

    git.commits.add(FINAL_COMMIT);
    git.ancestors.delete(`${FINAL_COMMIT}:${BRANCH}`);
    expect(
      validatePlanningGitIntegrity(
        state({ planning_commit: FINAL_COMMIT }),
        parsed(),
        [PLAN],
        git,
      ).join("\n"),
    ).toContain("not an ancestor");
  });

  it("checks feature commit fields, plan blobs, and worktree hashes", () => {
    const git = new GitStub();
    let errors = validatePlanningGitIntegrity(
      state({ features: [{ planning_commit: "bad", plan_hash: "bad" }] }),
      parsed(),
      [PLAN],
      git,
    );
    expect(errors.join("\n")).toContain("must be hexadecimal");
    expect(errors.join("\n")).toContain("plan hash");

    git.worktree.delete(PLAN);
    errors = validatePlanningGitIntegrity(state(), parsed(), [PLAN], git);
    expect(errors.join("\n")).toContain("could not hash worktree atomic plan");

    git.worktree.set(PLAN, HASH);
    git.committed.delete(`${FINAL_COMMIT}:${PLAN}`);
    errors = validatePlanningGitIntegrity(
      state({ features: [{ planning_commit: FINAL_COMMIT }] }),
      parsed(),
      [PLAN],
      git,
    );
    expect(errors.join("\n")).toContain("does not contain");
  });

  it("rejects a derived commit outside the integration branch", () => {
    const git = new GitStub();
    git.ancestors.delete(`${COMMIT}:${BRANCH}`);

    expect(
      validatePlanningGitIntegrity(state(), parsed(), [PLAN], git)[0],
    ).toContain("is not on");
  });
});
