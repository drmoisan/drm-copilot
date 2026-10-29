import { afterEach, describe, expect, it, jest } from "@jest/globals";

import { isFeatureFolderPath } from "../../../src/lib/validate/orchestrator-state-feature-folder-record";
import {
  resolveIssueAdoption,
  type IssueAdoptionResult,
} from "../../../src/lib/validate/orchestrator-state-issue-adoption";

/**
 * Unit tests for the issue-adoption `feature_folder_record` (issue #992).
 *
 * These tests mirror
 * `tests/scripts/dev_tools/test_orchestrator_state_issue_adoption_feature_folder.py`
 * through `resolveIssueAdoption`: rule 10 (an object record is required when
 * `new_active_feature_folder` is waived) and rules 11a to 11e (path pattern,
 * equality with the checkpoint `feature-folder`, the closed `verified_via`
 * set, presence-only `verified_at`, and non-blank `evidence`). No file is read
 * or written, and no timer, clock, or random source is used.
 */

const FEATURE_FOLDER = "docs/features/active/2026-09-29-sample-feature-509";
const FOLDER_TOOL = "new_active_feature_folder";
const LARGE_TOOLS: readonly string[] = [
  "new_potential_entry",
  "potential_to_issue",
  FOLDER_TOOL,
  "collect_pr_context",
  "validate_orchestration_artifacts",
];
const SUCCESSFUL_WITHOUT_FOLDER: ReadonlySet<string> = new Set([
  "collect_pr_context",
  "validate_orchestration_artifacts",
]);

const E10 =
  "Checkpoint issue_adoption.feature_folder_record must be an object when waiving new_active_feature_folder.";
const E11A =
  "Checkpoint issue_adoption.feature_folder_record.path must be a folder path under docs/features/active/ without dot segments or a trailing slash.";
const E11B =
  "Checkpoint issue_adoption.feature_folder_record.path must equal the checkpoint feature-folder.";
const E11C =
  "Checkpoint issue_adoption.feature_folder_record.verified_via must be one of git_cat_file_head, git_ls_tree_head.";
const E11D =
  "Checkpoint issue_adoption.feature_folder_record.verified_at must be present.";
const E11E =
  "Checkpoint issue_adoption.feature_folder_record.evidence must be a non-empty string.";

/** Return a valid feature_folder_record with overrides. */
function folderRecord(
  overrides: Record<string, unknown> = {},
): Record<string, unknown> {
  return {
    path: FEATURE_FOLDER,
    verified_via: "git_cat_file_head",
    verified_at: "2026-09-29T15:20:00Z",
    evidence: `git cat-file -t HEAD:${FEATURE_FOLDER} printed tree`,
    ...overrides,
  };
}

/** Return the base adoption record for issue 509 with overrides. */
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

/** Return an adoption that waives the folder tool with the given record. */
function folderAdoption(
  record: unknown = folderRecord(),
): Record<string, unknown> {
  return adoption({
    waived_tools: ["potential_to_issue", FOLDER_TOOL],
    feature_folder_record: record,
  });
}

/** Return a minimal checkpoint carrying the adoption and a feature-folder. */
function folderState(
  value: unknown,
  folder: unknown = FEATURE_FOLDER,
  includeFolder = true,
): Record<string, unknown> {
  const state: Record<string, unknown> = {
    "issue-num": "509",
    "promotion-type": "feature",
    issue_adoption: value,
  };
  if (includeFolder) {
    state["feature-folder"] = folder;
  }
  return state;
}

/** Run the resolver on the large route with no folder-tool receipt. */
function resolve(state: Record<string, unknown>): IssueAdoptionResult {
  return resolveIssueAdoption(state, {
    routeId: "large",
    requiredMcpTools: LARGE_TOOLS,
    successfulTools: SUCCESSFUL_WITHOUT_FOLDER,
  });
}

afterEach(() => {
  jest.resetAllMocks();
});

describe("feature_folder_record rule 10", () => {
  it("waives the folder tool with a valid record", () => {
    const result = resolve(folderState(folderAdoption()));
    expect(result.errors).toEqual([]);
    expect(result.waivedTools.has(FOLDER_TOOL)).toBe(true);
  });

  it("reports rule 10 when the record key is absent", () => {
    const value = adoption({
      waived_tools: ["potential_to_issue", FOLDER_TOOL],
    });
    const result = resolve(folderState(value));
    expect(result.errors).toEqual([E10]);
    expect(result.waivedTools.size).toBe(0);
  });

  it.each([
    ["null", null],
    ["string", FEATURE_FOLDER],
    ["list", ["path"]],
    ["number", 7],
  ])("reports rule 10 for a %s record", (_label, record) => {
    expect(resolve(folderState(folderAdoption(record))).errors).toEqual([E10]);
  });

  it("is silent when the tool is not waived and no record exists", () => {
    expect(resolve(folderState(adoption())).errors).toEqual([]);
  });
});

describe("feature_folder_record rule 11a", () => {
  it.each([
    ["outside-prefix", "docs/features/completed/2026-09-29-sample-feature-509"],
    ["dot-segment", "docs/features/active/./2026-09-29-sample-feature-509"],
    [
      "dot-dot-segment",
      "docs/features/active/../active/2026-09-29-sample-feature-509",
    ],
    ["empty-segment", "docs/features/active//2026-09-29-sample-feature-509"],
    ["trailing-slash", "docs/features/active/2026-09-29-sample-feature-509/"],
    ["backslash", "docs\\features\\active\\2026-09-29-sample-feature-509"],
    ["drive-letter", "C:/docs/features/active/2026-09-29-sample-feature-509"],
    ["leading-hyphen", "docs/features/active/-2026-09-29-sample-feature-509"],
    ["glob-character", "docs/features/active/2026-09-*"],
    ["prefix-only", "docs/features/active/"],
    [
      "trailing-newline",
      "docs/features/active/2026-09-29-sample-feature-509\n",
    ],
    ["empty", ""],
  ])("rejects a malformed path (%s)", (_label, badPath) => {
    const state = folderState(
      folderAdoption(folderRecord({ path: badPath })),
      badPath,
    );
    expect(resolve(state).errors).toEqual([E11A]);
    expect(isFeatureFolderPath(badPath)).toBe(false);
  });

  it("rejects a non-string path", () => {
    const state = folderState(folderAdoption(folderRecord({ path: 509 })));
    expect(resolve(state).errors).toEqual([E11A]);
  });

  it("accepts a valid nested path", () => {
    const nested = "docs/features/active/epic-2026/child_1.v2";
    const state = folderState(
      folderAdoption(folderRecord({ path: nested })),
      nested,
    );
    expect(resolve(state).errors).toEqual([]);
    expect(isFeatureFolderPath(nested)).toBe(true);
  });
});

describe("feature_folder_record rule 11b", () => {
  it.each([
    ["different", "docs/features/active/2026-09-29-other-feature-510", true],
    ["case-variant", FEATURE_FOLDER.toUpperCase(), true],
    ["number", 992, true],
    ["null", null, true],
    ["absent", FEATURE_FOLDER, false],
  ])(
    "requires equality with feature-folder (%s)",
    (_label, folder, include) => {
      const state = folderState(folderAdoption(), folder, include);
      expect(resolve(state).errors).toEqual([E11B]);
    },
  );
});

describe("feature_folder_record rules 11c to 11e", () => {
  it.each(["git_ls_tree_head", "git_cat_file_head"])(
    "accepts verified_via %s",
    (value) => {
      const record = folderRecord({ verified_via: value });
      expect(resolve(folderState(folderAdoption(record))).errors).toEqual([]);
    },
  );

  it.each([["git_status"], ["GIT_CAT_FILE_HEAD"], [null], [1]])(
    "rejects verified_via %p",
    (value) => {
      const record = folderRecord({ verified_via: value });
      expect(resolve(folderState(folderAdoption(record))).errors).toEqual([
        E11C,
      ]);
    },
  );

  it.each([[null], [""], ["   "]])("rejects verified_at %p", (value) => {
    const record = folderRecord({ verified_at: value });
    expect(resolve(folderState(folderAdoption(record))).errors).toEqual([E11D]);
  });

  it("rejects an absent verified_at", () => {
    const record = {
      path: FEATURE_FOLDER,
      verified_via: "git_cat_file_head",
      evidence: "git cat-file printed tree",
    };
    expect(resolve(folderState(folderAdoption(record))).errors).toEqual([E11D]);
  });

  it("treats verified_at as presence-only", () => {
    const record = folderRecord({ verified_at: 0 });
    expect(resolve(folderState(folderAdoption(record))).errors).toEqual([]);
  });

  it.each([[""], ["  "], [null], [3]])("rejects evidence %p", (value) => {
    const record = folderRecord({ evidence: value });
    expect(resolve(folderState(folderAdoption(record))).errors).toEqual([E11E]);
  });

  it("accepts non-blank evidence", () => {
    const record = folderRecord({
      evidence: "git ls-tree HEAD printed the folder",
    });
    expect(resolve(folderState(folderAdoption(record))).errors).toEqual([]);
  });

  it("accumulates record errors in rule order", () => {
    const record = {
      path: "docs/x",
      verified_via: "x",
      verified_at: " ",
      evidence: "",
    };
    expect(resolve(folderState(folderAdoption(record))).errors).toEqual([
      E11A,
      E11C,
      E11D,
      E11E,
    ]);
  });

  it("validates a record when the tool is not waived", () => {
    const value = adoption({
      feature_folder_record: folderRecord({ evidence: "" }),
    });
    const result = resolve(folderState(value));
    expect(result.errors).toEqual([E11E]);
    expect(result.waivedTools.size).toBe(0);
  });

  it("does not run record rules when waived_tools is malformed", () => {
    const value = adoption({
      waived_tools: "potential_to_issue",
      feature_folder_record: folderRecord({ evidence: "" }),
    });
    const errors = resolve(folderState(value)).errors;
    expect(errors).not.toContain(E11E);
    expect(errors).not.toContain(E10);
  });
});
