import {
  BUG_PROMOTION_ENTRY_TOOL,
  BUG_PROMOTION_TYPE,
  FEATURE_PROMOTION_ENTRY_TOOL,
  PROMOTION_TYPE_KEY,
  resolvePromotionEntryTools,
} from "../../../src/lib/validate/orchestrator-state-promotion-tools";

const SMALL_ROUTE_TOOLS: string[] = [
  "new_potential_entry",
  "potential_to_issue",
  "new_active_feature_folder",
  "collect_pr_context",
  "validate_orchestration_artifacts",
];

const SMALL_ROUTE_BUG_TOOLS: string[] = [
  "new_potential_bug_entry",
  "potential_to_issue",
  "new_active_feature_folder",
  "collect_pr_context",
  "validate_orchestration_artifacts",
];

function bugState(): Record<string, unknown> {
  return { [PROMOTION_TYPE_KEY]: BUG_PROMOTION_TYPE };
}

describe("constants", () => {
  it("exports the documented literal values", () => {
    expect(FEATURE_PROMOTION_ENTRY_TOOL).toBe("new_potential_entry");
    expect(BUG_PROMOTION_ENTRY_TOOL).toBe("new_potential_bug_entry");
    expect(BUG_PROMOTION_TYPE).toBe("bug");
    expect(PROMOTION_TYPE_KEY).toBe("promotion-type");
  });
});

describe("resolvePromotionEntryTools bug substitution", () => {
  it("substitutes the feature tool with the bug tool for a bug checkpoint", () => {
    const resolved = resolvePromotionEntryTools(["new_potential_entry"], bugState());

    expect(resolved).toEqual(["new_potential_bug_entry"]);
  });

  it("preserves order and every other tool of the real small-route list", () => {
    const resolved = resolvePromotionEntryTools(SMALL_ROUTE_TOOLS, bugState());

    expect(resolved).toEqual(SMALL_ROUTE_BUG_TOOLS);
  });

  it("substitutes every occurrence when the feature tool appears twice", () => {
    const resolved = resolvePromotionEntryTools(
      ["new_potential_entry", "x", "new_potential_entry"],
      bugState(),
    );

    expect(resolved).toEqual([
      "new_potential_bug_entry",
      "x",
      "new_potential_bug_entry",
    ]);
  });

  it("leaves a list without the feature tool unchanged under bug", () => {
    const input = ["collect_pr_context", "validate_orchestration_artifacts"];

    expect(resolvePromotionEntryTools(input, bugState())).toEqual(input);
  });

  it("keeps an empty list empty", () => {
    expect(resolvePromotionEntryTools([], bugState())).toEqual([]);
  });

  it("does not substitute a differently cased tool name", () => {
    const resolved = resolvePromotionEntryTools(
      ["New_Potential_Entry"],
      bugState(),
    );

    expect(resolved).toEqual(["New_Potential_Entry"]);
  });
});

describe("resolvePromotionEntryTools non-substituting values", () => {
  const stringCases: Array<[string, string]> = [
    ["feature", "feature"],
    ["capitalized Bug", "Bug"],
    ["upper-case BUG", "BUG"],
    ["leading space", " bug"],
    ["trailing space", "bug "],
    ["empty string", ""],
  ];

  it.each(stringCases)("returns an equal list for %s", (_label, value) => {
    const resolved = resolvePromotionEntryTools(SMALL_ROUTE_TOOLS, {
      [PROMOTION_TYPE_KEY]: value,
    });

    expect(resolved).toEqual(SMALL_ROUTE_TOOLS);
  });

  const nonStringCases: Array<[string, unknown]> = [
    ["null", null],
    ["boolean true", true],
    ["number 1", 1],
    ["array containing bug", ["bug"]],
    ["empty object", {}],
  ];

  it.each(nonStringCases)("returns an equal list for %s", (_label, value) => {
    const resolved = resolvePromotionEntryTools(SMALL_ROUTE_TOOLS, {
      [PROMOTION_TYPE_KEY]: value,
    });

    expect(resolved).toEqual(SMALL_ROUTE_TOOLS);
  });

  it("returns an equal list when the promotion-type key is absent", () => {
    expect(resolvePromotionEntryTools(SMALL_ROUTE_TOOLS, {})).toEqual(
      SMALL_ROUTE_TOOLS,
    );
  });

  it("ignores the underscore key promotion_type", () => {
    const resolved = resolvePromotionEntryTools(SMALL_ROUTE_TOOLS, {
      promotion_type: "bug",
    });

    expect(resolved).toEqual(SMALL_ROUTE_TOOLS);
  });
});

describe("resolvePromotionEntryTools immutability", () => {
  it("returns a different array reference than the input", () => {
    const resolved = resolvePromotionEntryTools(SMALL_ROUTE_TOOLS, {});

    expect(resolved).not.toBe(SMALL_ROUTE_TOOLS);
  });

  it("does not mutate a frozen input list or the state", () => {
    const input = Object.freeze([...SMALL_ROUTE_TOOLS]) as string[];
    const state = Object.freeze(bugState());

    const resolved = resolvePromotionEntryTools(input, state);

    expect(resolved).toEqual(SMALL_ROUTE_BUG_TOOLS);
    expect(input).toEqual(SMALL_ROUTE_TOOLS);
    expect(state).toEqual({ "promotion-type": "bug" });
  });
});

describe("resolvePromotionEntryTools fixed-grid invariants", () => {
  const promotionTypeGrid: unknown[] = [
    "bug",
    "feature",
    "Bug",
    " bug",
    "",
    null,
    true,
    1,
    ["bug"],
    {},
    undefined,
  ];
  const toolListGrid: string[][] = [
    [],
    ["new_potential_entry"],
    ["a", "new_potential_entry", "b"],
    ["new_potential_entry", "new_potential_entry"],
    ["new_potential_bug_entry"],
    SMALL_ROUTE_TOOLS,
  ];

  it("holds length, substitution, identity, and idempotence for every grid pair", () => {
    for (const promotionType of promotionTypeGrid) {
      for (const tools of toolListGrid) {
        const state = { [PROMOTION_TYPE_KEY]: promotionType };
        const resolved = resolvePromotionEntryTools(tools, state);

        expect(resolved).toHaveLength(tools.length);
        if (promotionType === "bug") {
          expect(resolved).not.toContain(FEATURE_PROMOTION_ENTRY_TOOL);
        } else {
          expect(resolved).toEqual(tools);
        }
        expect(resolvePromotionEntryTools(resolved, state)).toEqual(resolved);
      }
    }
  });
});
