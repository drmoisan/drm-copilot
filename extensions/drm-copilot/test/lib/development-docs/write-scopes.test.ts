/**
 * Unit tests for the write-scope literal contract (issue #1035, spec
 * "Write-scope literal contract (D-16)"). Every row of the Phase 1 rule
 * table, both example outputs of the spec, and the error branches are
 * asserted with in-memory values only.
 */
import { KNOWN_DEVELOPMENT_DOCS_ROOTS } from "../../../src/lib/development-docs/root";
import {
  REQUIRED_ARTIFACT_RULES,
  SETTINGS_ALLOW_RULES,
  WRITE_SCOPE_RULES,
  WriteScopeArea,
  WriteScopeRule,
  expandRequiredArtifactPattern,
  expandWriteScopeLiterals,
  writeScopeAreaGlob,
} from "../../../src/lib/development-docs/write-scopes";

/** Expand every agent rule of one agent into one flat literal list. */
function literalsOf(agent: string): string[] {
  return WRITE_SCOPE_RULES.filter((rule) => rule.agent === agent).flatMap(
    (rule) => expandWriteScopeLiterals(rule, KNOWN_DEVELOPMENT_DOCS_ROOTS),
  );
}

describe("WRITE_SCOPE_RULES rule table", () => {
  it.each([
    [
      "atomic-planner",
      ["Edit(docs/**)", "Edit(.dev/**)", "Write(docs/**)", "Write(.dev/**)"],
    ],
    [
      "task-researcher",
      [
        "Write(/docs/features/**/research/**)",
        "Write(/.dev/**/research/**)",
        "Write(/docs/research/**)",
        "Write(/.dev/research/**)",
      ],
    ],
    [
      "prd-feature",
      ["Write(/docs/features/active/**)", "Write(/.dev/active/**)"],
    ],
    [
      "feature-review",
      ["Write(/docs/features/active/**)", "Write(/.dev/active/**)"],
    ],
    ["status-updater", ["Write(/docs/features/**)", "Write(/.dev/**)"]],
    ["epic-review", ["Write(/docs/features/**)", "Write(/.dev/**)"]],
    [
      "epic-planner",
      [
        "Write(docs/features/epics/**)",
        "Write(.dev/epics/**)",
        "Edit(docs/features/epics/**)",
        "Edit(.dev/epics/**)",
        "Write(docs/features/potential/**)",
        "Write(.dev/potential/**)",
      ],
    ],
    [
      "epic-orchestrator",
      [
        "Write(docs/features/epics/**)",
        "Write(.dev/epics/**)",
        "Edit(docs/features/epics/**)",
        "Edit(.dev/epics/**)",
      ],
    ],
    [
      "parallel-orchestrator",
      [
        "Write(docs/features/parallel/**)",
        "Write(.dev/parallel/**)",
        "Edit(docs/features/parallel/**)",
        "Edit(.dev/parallel/**)",
      ],
    ],
    [
      "parallel-planner",
      [
        "Write(docs/features/parallel/**)",
        "Write(.dev/parallel/**)",
        "Edit(docs/features/parallel/**)",
        "Edit(.dev/parallel/**)",
      ],
    ],
  ])("expands the %s row into its required literals", (agent, expected) => {
    expect(literalsOf(agent)).toEqual(expected);
  });

  it("holds exactly the ten agents of the rule table", () => {
    const agents = [...new Set(WRITE_SCOPE_RULES.map((rule) => rule.agent))];
    expect(agents).toEqual([
      "atomic-planner",
      "task-researcher",
      "prd-feature",
      "feature-review",
      "status-updater",
      "epic-review",
      "epic-planner",
      "epic-orchestrator",
      "parallel-orchestrator",
      "parallel-planner",
    ]);
  });

  it("expands the spec example for prd-feature", () => {
    const rule: WriteScopeRule = {
      agent: "prd-feature",
      tool: "Write",
      area: "active",
      leadingSlash: true,
    };
    expect(
      expandWriteScopeLiterals(rule, KNOWN_DEVELOPMENT_DOCS_ROOTS),
    ).toEqual(["Write(/docs/features/active/**)", "Write(/.dev/active/**)"]);
  });

  it("expands one literal per root in root order", () => {
    const rule: WriteScopeRule = {
      agent: "x",
      tool: "Edit",
      area: "root",
      leadingSlash: false,
    };
    expect(expandWriteScopeLiterals(rule, [".dev"])).toEqual(["Edit(.dev/**)"]);
    expect(expandWriteScopeLiterals(rule, [])).toEqual([]);
  });
});

describe("SETTINGS_ALLOW_RULES", () => {
  it("expands the settings row without a leading slash", () => {
    expect(
      SETTINGS_ALLOW_RULES.flatMap((rule) =>
        expandWriteScopeLiterals(rule, KNOWN_DEVELOPMENT_DOCS_ROOTS),
      ),
    ).toEqual(["Edit(docs/**)", "Edit(.dev/**)"]);
  });
});

describe("REQUIRED_ARTIFACT_RULES", () => {
  it("expands the prd-feature spec-path pattern of the spec", () => {
    const rule = REQUIRED_ARTIFACT_RULES.find(
      (entry) => entry.agent === "prd-feature",
    );
    expect(rule?.token).toBe("spec-path");
    expect(
      rule && expandRequiredArtifactPattern(rule, KNOWN_DEVELOPMENT_DOCS_ROOTS),
    ).toBe("^(?:docs/features|\\.dev)/active/.+/spec\\.md$");
  });

  it("expands the epic-review epic-audit-path pattern of the spec", () => {
    const rule = REQUIRED_ARTIFACT_RULES.find(
      (entry) => entry.agent === "epic-review",
    );
    expect(rule?.token).toBe("epic-audit-path");
    expect(
      rule && expandRequiredArtifactPattern(rule, KNOWN_DEVELOPMENT_DOCS_ROOTS),
    ).toBe(
      "^(?:docs/features|\\.dev)/epics/.+/epic-audit\\.\\d{4}-\\d{2}-\\d{2}T\\d{2}-\\d{2}\\.md$",
    );
  });

  it("accepts sample paths under both roots and rejects other trees", () => {
    const rule = REQUIRED_ARTIFACT_RULES.find(
      (entry) => entry.token === "spec-path",
    );
    if (rule === undefined) {
      throw new Error("the spec-path rule is missing");
    }
    const pattern = new RegExp(
      expandRequiredArtifactPattern(rule, KNOWN_DEVELOPMENT_DOCS_ROOTS),
    );
    expect(pattern.test("docs/features/active/x/spec.md")).toBe(true);
    expect(pattern.test(".dev/active/x/spec.md")).toBe(true);
    expect(pattern.test("xdev/active/x/spec.md")).toBe(false);
    expect(pattern.test("docs/research/x/spec.md")).toBe(false);
  });

  it("builds a root-area pattern with no area segment", () => {
    expect(
      expandRequiredArtifactPattern(
        { agent: "x", token: "t", area: "root", suffixPattern: "a\\.md$" },
        [".dev"],
      ),
    ).toBe("^(?:\\.dev)/a\\.md$");
  });

  it.each(["feature-research", "one-off-research", "docs-broad"] as const)(
    "rejects the %s area, which is not directly below a root",
    (area) => {
      expect(() =>
        expandRequiredArtifactPattern(
          { agent: "x", token: "t", area, suffixPattern: "a$" },
          KNOWN_DEVELOPMENT_DOCS_ROOTS,
        ),
      ).toThrow("Required-artifact rules support root-child areas only");
    },
  );
});

describe("writeScopeAreaGlob", () => {
  it.each([
    ["root", "docs/features/**", ".dev/**"],
    ["active", "docs/features/active/**", ".dev/active/**"],
    ["potential", "docs/features/potential/**", ".dev/potential/**"],
    ["epics", "docs/features/epics/**", ".dev/epics/**"],
    ["parallel", "docs/features/parallel/**", ".dev/parallel/**"],
    ["feature-research", "docs/features/**/research/**", ".dev/**/research/**"],
    ["one-off-research", "docs/research/**", ".dev/research/**"],
    ["docs-broad", "docs/**", ".dev/**"],
  ] as const)(
    "maps the %s area to its glob under both roots",
    (area, docsFeatures, dev) => {
      expect(writeScopeAreaGlob(area, "docs/features")).toBe(docsFeatures);
      expect(writeScopeAreaGlob(area, ".dev")).toBe(dev);
    },
  );

  it("throws for an unknown area", () => {
    expect(() =>
      writeScopeAreaGlob("unknown" as WriteScopeArea, ".dev"),
    ).toThrow("Unknown write-scope area: unknown");
  });
});
