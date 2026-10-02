import { describe, expect, it } from "@jest/globals";
import * as fs from "node:fs";
import * as path from "node:path";

import {
  resolveIssueAdoption,
  type IssueAdoptionResult,
} from "../../../src/lib/validate/orchestrator-state-issue-adoption";
import { validateRoutingContract } from "../../../src/lib/validate/orchestrator-state-routing";

/**
 * Unit tests for the TypeScript issue-adoption resolver.
 *
 * These tests mirror `tests/scripts/dev_tools/test_orchestrator_state_issue_adoption.py`:
 * positive schema cases (AC-6), every rejection rule with its exact ordered
 * error text (AC-7), the closed waivable set (AC-8), the fail-closed invariant
 * on a fixed deterministic grid (AC-9), presence gating (AC-11), and the
 * case-sensitive tool name. Two further blocks exercise the wiring in
 * `validateRoutingContract` with the real routing matrix read from
 * `config/orchestration-routing.json`. No file is written, and no timer, clock,
 * or random source is used.
 */

const REPO_ROOT = path.resolve(__dirname, "..", "..", "..", "..", "..");
const ROUTING_MATRIX: unknown = JSON.parse(
  fs.readFileSync(
    path.join(REPO_ROOT, "config", "orchestration-routing.json"),
    "utf8",
  ),
);

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
const PREPARATION_TOOLS: readonly string[] = [
  "new_potential_entry",
  "potential_to_issue",
  "new_active_feature_folder",
  "validate_orchestration_artifacts",
];
const REMEDIATION_TOOLS: readonly string[] = [
  "collect_pr_context",
  "validate_orchestration_artifacts",
];
const NON_WAIVABLE_SUCCESSFUL: ReadonlySet<string> = new Set([
  "new_active_feature_folder",
  "collect_pr_context",
  "validate_orchestration_artifacts",
]);
const VALID_RECORD =
  "docs/features/potential/promoted/2026-08-22-promotion-gate-lacks-preexisting-issue-branch.md";

const E1 = "Checkpoint issue_adoption must be an object when present.";
const E2A =
  "Checkpoint issue_adoption.issue_num must be a string of decimal digits without a leading zero.";
const E2B =
  "Checkpoint issue_adoption.issue_num must equal the checkpoint issue-num.";
const E3 =
  "Checkpoint issue_adoption.issue_url must end with /issues/ followed by issue_num.";
const E4 =
  "Checkpoint issue_adoption.origin must be one of transferred, filed_before_orchestration, epic_decomposition.";
const E5 =
  "Checkpoint issue_adoption.verified_via must be one of gh_issue_view, gh_api_get, github_mcp_issue_read.";
const E6 = "Checkpoint issue_adoption.verified_at must be present.";
const E7 = "Checkpoint issue_adoption.evidence must be a non-empty string.";
const E8A =
  "Checkpoint issue_adoption.waived_tools must be a non-empty list of tool names.";
const E8INCLUDE =
  "Checkpoint issue_adoption.waived_tools must include potential_to_issue.";
const LEO = "Checkpoint local_execution_overrides must be empty at completion.";

const e8cannot = (tool: string): string =>
  `Checkpoint issue_adoption.waived_tools names a tool that cannot be waived: ${tool}.`;
const e8notreq = (routeId: string, tool: string): string =>
  `Checkpoint issue_adoption.waived_tools names a tool that is not required by route ${routeId}: ${tool}.`;
const e8receipt = (tool: string): string =>
  `Checkpoint issue_adoption.waived_tools names a tool that has a successful MCP receipt: ${tool}.`;
const e8dup = (tool: string): string =>
  `Checkpoint issue_adoption.waived_tools lists a tool more than once: ${tool}.`;
const e9 = (tool: string): string =>
  `Checkpoint issue_adoption.potential_record must name a markdown file under docs/features/potential/ when waiving ${tool}.`;
const missingReceipt = (tool: string): string =>
  `Checkpoint missing successful MCP receipt: ${tool}.`;

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

/** Return a large-route checkpoint whose receipts lack potential_to_issue. */
function largeCheckpoint(
  extra: Record<string, unknown> = {},
): Record<string, unknown> {
  const agents = [
    "task-researcher",
    "prd-feature",
    "atomic-planner",
    "atomic-executor",
    "feature-review",
    "pr-author",
  ];
  const skills = [
    "orchestrate",
    "feature-promotion-lifecycle",
    "atomic-plan-contract",
    "acceptance-criteria-tracking",
    "pr-context-artifacts",
    "pr-base-branch-merge-base",
  ];
  return {
    route_id: "large",
    "promotion-type": "feature",
    "issue-num": "509",
    required_agents: agents,
    required_skills: skills,
    required_mcp_tools: [...LARGE_TOOLS],
    delegation_receipts: agents.map((agent) => ({ agent_name: agent })),
    skill_receipts: skills.map((skill) => ({
      skill,
      required: true,
      evidence: "e",
    })),
    mcp_call_receipts: LARGE_TOOLS.filter(
      (tool) => tool !== "potential_to_issue",
    ).map((tool) => ({ tool, ok: true, evidence: "e" })),
    local_execution_overrides: [],
    delegation_bypasses: [],
    ...extra,
  };
}

describe("resolveIssueAdoption accepts valid records (AC-6)", () => {
  it("accepts a feature checkpoint waiving potential_to_issue alone", () => {
    const result = resolve(stateWith(adoption()));
    expect(result.errors).toEqual([]);
    expect(waived(result)).toEqual(["potential_to_issue"]);
  });

  it("accepts a feature checkpoint waiving the feature entry tool with a record", () => {
    const record = adoption({
      waived_tools: ["potential_to_issue", "new_potential_entry"],
      potential_record: VALID_RECORD,
    });
    const result = resolve(stateWith(record));
    expect(result.errors).toEqual([]);
    expect(waived(result)).toEqual([
      "new_potential_entry",
      "potential_to_issue",
    ]);
  });

  it("accepts a bug checkpoint waiving the bug entry tool with a record", () => {
    const record = adoption({
      waived_tools: ["potential_to_issue", "new_potential_bug_entry"],
      potential_record: VALID_RECORD,
    });
    const result = resolve(stateWith(record, "bug"), "large", LARGE_BUG_TOOLS);
    expect(result.errors).toEqual([]);
    expect(waived(result)).toEqual([
      "new_potential_bug_entry",
      "potential_to_issue",
    ]);
  });

  it("accepts the same record on the preparation route", () => {
    const result = resolve(
      stateWith(adoption()),
      "preparation",
      PREPARATION_TOOLS,
    );
    expect(result.errors).toEqual([]);
    expect(waived(result)).toEqual(["potential_to_issue"]);
  });

  it.each(["transferred", "filed_before_orchestration", "epic_decomposition"])(
    "accepts the origin value %s",
    (origin) => {
      const result = resolve(stateWith(adoption({ origin })));
      expect(result.errors).toEqual([]);
      expect(waived(result)).toEqual(["potential_to_issue"]);
    },
  );

  it.each(["gh_issue_view", "gh_api_get", "github_mcp_issue_read"])(
    "accepts the verification source %s",
    (verifiedVia) => {
      const result = resolve(
        stateWith(adoption({ verified_via: verifiedVia })),
      );
      expect(result.errors).toEqual([]);
      expect(waived(result)).toEqual(["potential_to_issue"]);
    },
  );
});

describe("resolveIssueAdoption rejects malformed records (AC-7)", () => {
  it.each([
    ["string", "adopted"],
    ["integer", 509],
    ["list", ["potential_to_issue"]],
    ["null", null],
  ])("rejects a non-object value of kind %s", (_label, value) => {
    const result = resolve(stateWith(value));
    expect(result.errors).toEqual([E1]);
    expect(waived(result)).toEqual([]);
  });

  it.each([
    ["an integer issue number", { issue_num: 509 }, [E2A, E3]],
    [
      "a leading-zero issue number",
      {
        issue_num: "0509",
        issue_url: "https://github.com/drmoisan/drm-copilot/issues/0509",
      },
      [E2A, E3],
    ],
    [
      "an issue number unequal to the checkpoint issue-num",
      {
        issue_num: "510",
        issue_url: "https://github.com/drmoisan/drm-copilot/issues/510",
      },
      [E2B],
    ],
    [
      "a mismatched issue URL",
      { issue_url: "https://github.com/drmoisan/drm-copilot/issues/510" },
      [E3],
    ],
    ["an unknown origin", { origin: "imported" }, [E4]],
    ["an unknown verification source", { verified_via: "curl" }, [E5]],
    ["an absent verification time", { verified_at: undefined }, [E6]],
    ["a null verification time", { verified_at: null }, [E6]],
    ["a blank verification time", { verified_at: "   " }, [E6]],
    ["blank evidence", { evidence: "" }, [E7]],
    ["an empty waived list", { waived_tools: [] }, [E8A]],
    ["a string waived list", { waived_tools: "potential_to_issue" }, [E8A]],
    [
      "a waived list with a blank entry",
      { waived_tools: ["potential_to_issue", " "] },
      [E8A],
    ],
    [
      "a waived list with an integer entry",
      { waived_tools: ["potential_to_issue", 7] },
      [E8A],
    ],
    [
      "a waived list without the issue-creation tool",
      { waived_tools: ["new_potential_entry"], potential_record: VALID_RECORD },
      [E8INCLUDE],
    ],
    [
      "an invalid potential record when waiving the entry tool",
      {
        waived_tools: ["potential_to_issue", "new_potential_entry"],
        potential_record: "notes/record.txt",
      },
      [e9("new_potential_entry")],
    ],
  ])("rejects %s", (_label, overrides, expected) => {
    const fields: Record<string, unknown> = overrides;
    const record = adoption(fields);
    // An undefined override stands for an absent member.
    for (const [key, value] of Object.entries(fields)) {
      if (value === undefined) {
        delete record[key];
      }
    }
    const result = resolve(stateWith(record));
    expect(result.errors).toEqual(expected);
    expect(waived(result)).toEqual([]);
  });
});

describe("resolveIssueAdoption enforces the closed waivable set (AC-8)", () => {
  it("rejects waiving the feature-folder tool", () => {
    const record = adoption({
      waived_tools: ["potential_to_issue", "new_active_feature_folder"],
    });
    expect(resolve(stateWith(record)).errors).toEqual([
      e8cannot("new_active_feature_folder"),
    ]);
  });

  it("rejects waiving the artifact-validation tool", () => {
    const record = adoption({
      waived_tools: ["potential_to_issue", "validate_orchestration_artifacts"],
    });
    expect(resolve(stateWith(record)).errors).toEqual([
      e8cannot("validate_orchestration_artifacts"),
    ]);
  });

  it("rejects waiving the feature entry tool on a bug checkpoint", () => {
    const record = adoption({
      waived_tools: ["potential_to_issue", "new_potential_entry"],
      potential_record: VALID_RECORD,
    });
    const result = resolve(stateWith(record, "bug"), "large", LARGE_BUG_TOOLS);
    expect(result.errors).toEqual([e8notreq("large", "new_potential_entry")]);
  });

  it("rejects any waiver on the remediation route", () => {
    const result = resolve(
      stateWith(adoption()),
      "remediation",
      REMEDIATION_TOOLS,
      new Set(REMEDIATION_TOOLS),
    );
    expect(result.errors).toEqual([
      e8notreq("remediation", "potential_to_issue"),
    ]);
  });

  it("rejects waiving a tool that holds a successful receipt", () => {
    const result = resolve(
      stateWith(adoption()),
      "large",
      LARGE_TOOLS,
      new Set(LARGE_TOOLS),
    );
    expect(result.errors).toEqual([e8receipt("potential_to_issue")]);
  });

  it("rejects a tool listed twice", () => {
    const record = adoption({
      waived_tools: ["potential_to_issue", "potential_to_issue"],
    });
    const result = resolve(stateWith(record));
    expect(result.errors).toEqual([e8dup("potential_to_issue")]);
    expect(waived(result)).toEqual([]);
  });
});

describe("resolveIssueAdoption fails closed and is presence gated (AC-9, AC-11)", () => {
  it("empties the waived set whenever any error is reported across a fixed grid", () => {
    // Deterministic enumeration; no random source.
    let combinations = 0;
    let observedValid = 0;
    for (const issueNum of ["509", "0509"]) {
      for (const origin of ["transferred", "imported"]) {
        for (const verifiedVia of ["gh_issue_view", "curl"]) {
          for (const verifiedAt of ["2026-09-29T15:15:00Z", " "]) {
            for (const evidence of ["gh issue view 509", ""]) {
              for (const tools of [
                ["potential_to_issue"],
                ["potential_to_issue", "new_potential_entry"],
                [],
              ]) {
                combinations += 1;
                const result = resolve(
                  stateWith(
                    adoption({
                      issue_num: issueNum,
                      issue_url: `https://github.com/drmoisan/drm-copilot/issues/${issueNum}`,
                      origin,
                      verified_via: verifiedVia,
                      verified_at: verifiedAt,
                      evidence,
                      waived_tools: tools,
                      potential_record: VALID_RECORD,
                    }),
                  ),
                );
                if (result.errors.length > 0) {
                  expect(waived(result)).toEqual([]);
                } else {
                  observedValid += 1;
                  expect(waived(result)).toEqual([...tools].sort());
                }
              }
            }
          }
        }
      }
    }
    expect(combinations).toBe(96);
    expect(observedValid).toBe(2);
  });

  it("yields no errors and no waivers without the adoption key", () => {
    const result = resolve({ "issue-num": "509", "promotion-type": "feature" });
    expect(result.errors).toEqual([]);
    expect(waived(result)).toEqual([]);
  });

  it("rejects the case-variant tool name Potential_To_Issue", () => {
    const result = resolve(
      stateWith(adoption({ waived_tools: ["Potential_To_Issue"] })),
    );
    expect(result.errors).toEqual([e8cannot("Potential_To_Issue"), E8INCLUDE]);
    expect(waived(result)).toEqual([]);
  });
});

describe("validateRoutingContract issue-adoption wiring", () => {
  it("returns no adoption errors and no waivers when issue_adoption is absent", () => {
    const errors = validateRoutingContract(largeCheckpoint(), {
      routingMatrix: ROUTING_MATRIX,
    });
    expect(errors).toEqual([missingReceipt("potential_to_issue")]);
  });

  it("fails closed and places adoption errors after the receipt loop and before local_execution_overrides errors", () => {
    const state = largeCheckpoint({
      issue_adoption: adoption({ origin: "imported" }),
      local_execution_overrides: ["manual-step"],
    });
    const errors = validateRoutingContract(state, {
      routingMatrix: ROUTING_MATRIX,
    });
    expect(errors).toEqual([missingReceipt("potential_to_issue"), E4, LEO]);
  });

  it("waives the receipt requirement for a valid adoption record", () => {
    const state = largeCheckpoint({ issue_adoption: adoption() });
    expect(
      validateRoutingContract(state, { routingMatrix: ROUTING_MATRIX }),
    ).toEqual([]);
  });
});
