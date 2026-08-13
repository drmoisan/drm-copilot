import { describe, expect, it } from "@jest/globals";

import {
  ESCALATION_PRECEDENCE,
  LANGUAGE_BUDGETS,
  resolveCodexTopology,
} from "../../../src/lib/validate/codex-topology-resolver";

describe("resolveCodexTopology", () => {
  it.each([
    ["python", 3, 3, "python-typed-engineer"],
    ["powershell", 2, 3, "powershell-typed-engineer"],
    ["csharp", 3, 3, "csharp-typed-engineer"],
  ])(
    "routes %s at its direct budget to %s",
    (language, productionFiles, testFiles, expectedAgent) => {
      const receipt = resolveCodexTopology(
        [language],
        productionFiles,
        testFiles,
        "standalone",
      );

      expect(receipt).toMatchObject({
        route: "small",
        topology: "typed_engineer",
        logical_agent: expectedAgent,
        routing_reason: "within_language_budget",
      });
    },
  );

  it.each([
    ["python", 4, 3, "production_budget_exceeded"],
    ["powershell", 3, 3, "production_budget_exceeded"],
    ["csharp", 4, 3, "production_budget_exceeded"],
  ])(
    "escalates over-budget %s scope for %s",
    (language, productionFiles, testFiles, reason) => {
      expect(
        resolveCodexTopology(
          [language],
          productionFiles,
          testFiles,
          "standalone",
        ),
      ).toMatchObject({
        route: "large",
        topology: "orchestrator",
        logical_agent: "orchestrator",
        routing_reason: reason,
      });
    },
  );

  it.each([
    ["python", 3, 12, "python-typed-engineer"],
    ["powershell", 2, 12, "powershell-typed-engineer"],
    ["csharp", 3, 12, "csharp-typed-engineer"],
  ])(
    "keeps %s test batch size independent from topology",
    (language, productionFiles, testFiles, expectedAgent) => {
      expect(
        resolveCodexTopology(
          [language],
          productionFiles,
          testFiles,
          "standalone",
        ),
      ).toMatchObject({
        route: "small",
        logical_agent: expectedAgent,
        test_file_count: testFiles,
      });
    },
  );

  it.each([
    [["python", "csharp"], false, "cross_language"],
    [["python"], true, "cross_cutting"],
    [["rust"], false, "unsupported_language"],
    [[], false, "unsupported_language"],
    [["typescript"], false, "direct_mode_disabled"],
  ])("escalates non-direct scope as %s", (languages, crossCutting, reason) => {
    expect(
      resolveCodexTopology(languages, 1, 1, "standalone", {
        crossCutting,
      }),
    ).toMatchObject({
      topology: "orchestrator",
      logical_agent: "orchestrator",
      routing_reason: reason,
    });
  });

  it.each([
    [0, 0],
    [-1, 1],
    [1, -1],
  ])("fails closed for unusable estimates %i/%i", (production, tests) => {
    expect(
      resolveCodexTopology(["python"], production, tests, "standalone"),
    ).toMatchObject({
      logical_agent: "orchestrator",
      routing_reason: "invalid_estimate",
    });
  });

  it.each(["epic_preparation_child", "epic_execution_child"] as const)(
    "forces %s through an orchestrator",
    (context) => {
      expect(resolveCodexTopology(["python"], 1, 1, context)).toMatchObject({
        route: "large",
        logical_agent: "orchestrator",
        routing_reason: "epic_child_context",
        max_production_files: null,
        max_test_files: null,
      });
    },
  );

  it.each(["epic-planner", "epic-orchestrator"] as const)(
    "forces the %s root persona",
    (persona) => {
      expect(
        resolveCodexTopology([], 0, 0, "standalone", {
          rootPersona: persona,
        }),
      ).toMatchObject({
        route: "epic",
        topology: "epic_persona",
        logical_agent: persona,
        root_persona: persona,
        routing_reason: "forced_root_persona",
      });
    },
  );

  it.each([
    ["parallel_planning", "parallel-planner"],
    ["parallel_execution", "parallel-orchestrator"],
  ] as const)("forces %s to the %s root persona", (context, persona) => {
    expect(
      resolveCodexTopology([], 0, 0, context, {
        rootPersona: persona,
      }),
    ).toMatchObject({
      execution_context: context,
      route: "parallel",
      topology: "parallel_persona",
      logical_agent: persona,
      root_persona: persona,
      routing_reason: "forced_root_persona",
    });
  });

  it.each([
    ["parallel_planning", null],
    ["parallel_planning", "orchestrator"],
    ["parallel_planning", "epic-planner"],
    ["parallel_execution", null],
    ["parallel_execution", "orchestrator"],
    ["parallel_execution", "epic-orchestrator"],
    ["parallel_planning", "parallel-orchestrator"],
    ["parallel_execution", "parallel-planner"],
  ] as const)("rejects %s with root persona %s", (context, persona) => {
    expect(() =>
      resolveCodexTopology([], 0, 0, context, {
        rootPersona: persona,
      }),
    ).toThrow("requires its forced root persona");
  });

  it("normalizes and deduplicates languages", () => {
    expect(
      resolveCodexTopology([" Python ", "PYTHON"], 1, 0, "standalone"),
    ).toMatchObject({
      languages: ["python"],
      logical_agent: "python-typed-engineer",
    });
  });

  it.each([
    ["languages", () => resolveCodexTopology([""], 1, 1, "standalone")],
    ["languages", () => resolveCodexTopology("python", 1, 1, "standalone")],
    [
      "production",
      () => resolveCodexTopology(["python"], true, 1, "standalone"),
    ],
    ["tests", () => resolveCodexTopology(["python"], 1, 1.5, "standalone")],
    [
      "cross-cutting",
      () =>
        resolveCodexTopology(["python"], 1, 1, "standalone", {
          crossCutting: null,
        }),
    ],
    [
      "root",
      () =>
        resolveCodexTopology([], 0, 0, "standalone", {
          rootPersona: "unknown",
        }),
    ],
    ["context", () => resolveCodexTopology(["python"], 1, 1, "unknown")],
  ])("rejects invalid %s input", (_label, invoke) => {
    expect(invoke).toThrow();
  });

  it("keeps a root persona distinct from epic child context", () => {
    expect(() =>
      resolveCodexTopology([], 0, 0, "epic_execution_child", {
        rootPersona: "epic-orchestrator",
      }),
    ).toThrow("A forced root persona requires standalone context.");
  });

  it("reports a null execution context using the canonical representation", () => {
    expect(() => resolveCodexTopology(["python"], 1, 1, null as never)).toThrow(
      "found None.",
    );
  });

  it("requires a parallel root persona to use its matching context", () => {
    expect(() =>
      resolveCodexTopology([], 0, 0, "standalone", {
        rootPersona: "parallel-planner",
      }),
    ).toThrow("requires 'parallel_planning' context");
  });

  it("exports the canonical budget and precedence policy", () => {
    expect(LANGUAGE_BUDGETS["typescript"]).toMatchObject({
      direct_mode_enabled: false,
      max_production_files: 0,
      max_test_files: 0,
    });
    expect(ESCALATION_PRECEDENCE).toEqual([
      "epic_child_context",
      "invalid_estimate",
      "cross_language",
      "unsupported_language",
      "cross_cutting",
      "direct_mode_disabled",
      "production_budget_exceeded",
    ]);
  });
});
