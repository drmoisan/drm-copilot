import { describe, expect, it } from "@jest/globals";

import {
  computeSourceDigest,
  parseMigrationDecisions,
  RECORD_ONLY_KEYS,
  type MigrationDecisions,
} from "../../../src/lib/development-docs-migration/migration-decisions";
import {
  buildMigrationPlan,
  type MigrationPlanInputs,
} from "../../../src/lib/development-docs-migration/migration-plan";

const FOO = "docs/features/active/2026-10-30-foo-1016";
const BAR = "docs/features/completed/2026-01-01-bar-12";
const HELD = "docs/features/archive/subagentstop-envelope-core-897";
const KEPT = "docs/features/archive/notes-feature";

/** Base fixture repository: path to text. */
function baseFiles(): Record<string, string> {
  return {
    [`${FOO}/spec.md`]: `[a](../../../../.github/instructions/a.md)\nsee ${BAR}/plan.md\n`,
    [`${FOO}/v1/plan.md`]: "v1",
    [`${FOO}/audit-1/review.md`]: "audit",
    [`${BAR}/plan.md`]: "plain",
    [`${HELD}/a.md`]: "held",
    [`${KEPT}/a.md`]: "kept",
    "docs/features/templates/feature/spec.md": "template",
    "docs/features/research/q.md": "q",
    "docs/research/r.md": "r",
    "docs/features/backlog.md": "backlog",
    "README.md": `[s](${FOO}/spec.md#scope) and docs/features/backlog.md`,
    ".github/instructions/a.md": "policy",
  };
}

function inputs(
  files: Record<string, string>,
  overrides: Partial<MigrationPlanInputs> = {},
): MigrationPlanInputs {
  return {
    mode: "dry-run",
    insideWorkTree: true,
    hasUncommittedTrackedChanges: false,
    trackedFiles: Object.keys(files),
    untrackedFiles: [],
    readText: (path) => files[path],
    decisions: null,
    defaultDiscoveryTarget: ".dev/discovery/templates",
    ...overrides,
  };
}

/** Build parsed decisions for a fixture, with the fixture's own digest. */
function decisionsFor(
  files: Record<string, string>,
  overrides: Record<string, unknown> = {},
  globals: Record<string, unknown> = {},
): MigrationDecisions {
  const folders = buildMigrationPlan(inputs(files)).plan.candidateFolders;
  const global: Record<string, unknown> = {
    discovery_templates_target: ".dev/discovery/templates",
    in_tree_rewrite_scope: "references-and-links",
    commit_split: "single",
    ...globals,
  };
  for (const key of RECORD_ONLY_KEYS) {
    global[key] = "recorded";
  }
  return parseMigrationDecisions(
    JSON.stringify({
      version: 1,
      source_digest: computeSourceDigest(folders),
      global_decisions: global,
      decisions: [{ source: HELD, action: "keep" }],
      ...overrides,
    }),
  );
}

function apply(
  files: Record<string, string>,
  decisions: MigrationDecisions | null,
  extra: Partial<MigrationPlanInputs> = {},
) {
  return buildMigrationPlan(
    inputs(files, { mode: "apply", decisions, ...extra }),
  );
}

describe("buildMigrationPlan refusal rules", () => {
  it("refuses outside a git work tree in both modes", () => {
    for (const mode of ["dry-run", "apply"] as const) {
      const result = buildMigrationPlan(
        inputs(baseFiles(), { mode, insideWorkTree: false }),
      );
      expect(result.refusals).toContain(
        "workspace_root is not inside a git work tree",
      );
    }
  });

  it("refuses uncommitted tracked changes in apply mode only", () => {
    const files = baseFiles();
    expect(
      apply(files, decisionsFor(files), { hasUncommittedTrackedChanges: true })
        .refusals,
    ).toEqual(["tracked files have uncommitted changes"]);
    expect(
      buildMigrationPlan(inputs(files, { hasUncommittedTrackedChanges: true }))
        .refusals,
    ).toEqual([]);
  });

  it("refuses a non-empty move target and plans the merge entry by entry", () => {
    // Arrange: .dev/active already holds the folder the move would create.
    const files = {
      ...baseFiles(),
      ".dev/active/2026-10-30-foo-1016/x.md": "x",
    };

    // Act
    const result = apply(files, decisionsFor(files));

    // Assert
    expect(result.refusals).toContain(
      "move target exists and is non-empty: .dev/active/2026-10-30-foo-1016",
    );
    expect(result.plan.conflicts).toHaveLength(1);
  });

  it("refuses a move target that collides case-insensitively with an existing path", () => {
    const files = { ...baseFiles(), ".DEV/active/x.md": "x" };
    const result = apply(files, decisionsFor(files));
    expect(
      result.refusals.some((reason) =>
        reason.includes("collides case-insensitively with .DEV"),
      ),
    ).toBe(true);
  });

  it("refuses a digest mismatch", () => {
    const files = baseFiles();
    const result = apply(
      files,
      decisionsFor(files, { source_digest: "stale" }),
    );
    expect(
      result.refusals.some((reason) =>
        reason.startsWith("source_digest mismatch"),
      ),
    ).toBe(true);
  });

  it("refuses a missing decision file when held items or open choices exist, and not otherwise", () => {
    // Held items present.
    expect(apply(baseFiles(), null).refusals[0]).toContain(
      "a decision file is required: 1 held items",
    );
    // Only an open choice: docs/discovery holds a file and there are no held items.
    const choiceOnly = { "docs/discovery/templates/v2/a.json": "{}" };
    expect(apply(choiceOnly, null).refusals).toEqual([
      "a decision file is required: 0 held items, open choices: discovery_templates_target",
    ]);
    // Nothing held and nothing open.
    expect(apply({ "src/x.ts": "x" }, null).refusals).toEqual([]);
  });

  it("names no open choice when only held items require the decision file", () => {
    // Arrange: one held folder, no reference to rewrite and no discovery file.
    const files = { [`${HELD}/a.md`]: "held" };

    // Act
    const { refusals } = apply(files, null);

    // Assert
    expect(refusals).toEqual([
      "a decision file is required: 1 held items, open choices: none",
    ]);
  });

  it("refuses an unmapped entry under docs/features in apply mode and only reports it in dry run", () => {
    const files = { ...baseFiles(), "docs/features/unknown-area/x.md": "x" };
    expect(apply(files, decisionsFor(files)).refusals).toEqual([
      "unmapped entry under docs/features/: docs/features/unknown-area",
    ]);
    const dry = buildMigrationPlan(inputs(files));
    expect(dry.refusals).toEqual([]);
    expect(dry.plan.unmapped).toEqual(["docs/features/unknown-area"]);
  });
});

describe("buildMigrationPlan behavior", () => {
  it("retains production documentation without refusal, move or rewrite (A1)", () => {
    // Arrange
    const files = {
      ...baseFiles(),
      "docs/README.md": "production",
      "docs/documentation-estate/docs-profile.json": "{}",
      "docs/guide.md": "see docs/features/active/x",
    };

    // Act
    const result = apply(files, decisionsFor(files));

    // Assert
    expect(result.refusals).toEqual([]);
    expect(result.plan.retained).toEqual([
      "docs/README.md",
      "docs/documentation-estate/docs-profile.json",
      "docs/guide.md",
    ]);
    expect(
      result.plan.moves.some((move) => move.from.startsWith("docs/guide")),
    ).toBe(false);
    expect(
      result.plan.rewrites.some((rewrite) => rewrite.path.startsWith("docs/")),
    ).toBe(false);
    expect(result.plan.readmeExisting).toBe(true);
    expect(result.plan.createReadme).toBe(false);
  });

  it("plans one move per mapped directory, one rename per folder and an entry merge for research", () => {
    // Act
    const { plan } = apply(baseFiles(), decisionsFor(baseFiles()));

    // Assert
    const expectedMoves = [
      { from: "docs/features/templates", to: ".dev/templates" },
      { from: "docs/features/completed", to: ".dev/completed" },
      { from: "docs/features/research", to: ".dev/research" },
      { from: "docs/features/backlog.md", to: ".dev/backlog.md" },
      { from: "docs/features/archive", to: ".dev/archive" },
      { from: "docs/features/active", to: ".dev/active" },
      { from: "docs/research/r.md", to: ".dev/research/r.md" },
    ];
    expect(plan.moves).toHaveLength(expectedMoves.length);
    expect(plan.moves).toEqual(expect.arrayContaining(expectedMoves));
    // docs/features/research moves whole first; docs/research then merges entry by entry.
    const whole = plan.moves.findIndex(
      (move) => move.from === "docs/features/research",
    );
    const entry = plan.moves.findIndex(
      (move) => move.from === "docs/research/r.md",
    );
    expect(whole).toBeLessThan(entry);
    expect(plan.renames).toEqual([
      { from: ".dev/active/2026-10-30-foo-1016", to: ".dev/active/1016-foo" },
      {
        from: ".dev/completed/2026-01-01-bar-12",
        to: ".dev/completed/0012-bar",
      },
    ]);
    expect(plan.createReadme).toBe(true);
  });

  it("applies default exclusions and decision-file rewrite_exclusions globs (A3)", () => {
    // Arrange
    const files = {
      ...baseFiles(),
      "tests/fixtures/a.json": "docs/features/active/x",
      "tests/fixtures/blast_radius/historical-runs/r.md":
        "docs/features/active/x",
      "x/dev-docs-migration-dry-run.2026-11-20T07-00.md":
        "docs/features/active/x",
      [`${FOO}/evidence/other/e.md`]: "docs/features/active/x",
      "docs/engineering/process-reductions/0001.md": "docs/features/active/x",
    };

    // Act
    const dry = buildMigrationPlan(inputs(files)).plan;
    const decided = apply(
      files,
      decisionsFor(files, {
        rewrite_exclusions: [
          "**/evidence/**",
          "docs/engineering/process-reductions/**",
        ],
      }),
    ).plan;

    // Assert
    expect(dry.excluded).toEqual([
      "tests/fixtures/a.json",
      "tests/fixtures/blast_radius/historical-runs/r.md",
      "x/dev-docs-migration-dry-run.2026-11-20T07-00.md",
    ]);
    expect(decided.excluded).toEqual([
      "docs/engineering/process-reductions/0001.md",
      `${FOO}/evidence/other/e.md`,
      "x/dev-docs-migration-dry-run.2026-11-20T07-00.md",
    ]);
    expect(decided.outsideRewrites.map((item) => item.path)).toContain(
      "tests/fixtures/a.json",
    );
  });

  it.each([
    [
      "references-and-links",
      "[a](../../../.github/instructions/a.md)\nsee .dev/completed/0012-bar/plan.md\n",
    ],
    [
      "links-only",
      `[a](../../../.github/instructions/a.md)\nsee ${BAR}/plan.md\n`,
    ],
    ["none", undefined],
  ])("applies the in-tree rewrite scope %s", (scope, expected) => {
    // Act
    const { plan } = apply(
      baseFiles(),
      decisionsFor(baseFiles(), {}, { in_tree_rewrite_scope: scope }),
    );

    // Assert
    const rewrite = plan.rewrites.find(
      (item) => item.path === ".dev/active/1016-foo/spec.md",
    );
    expect(rewrite?.text).toBe(expected);
    expect(plan.inTreeRewriteScope).toBe(scope);
  });

  it("skips and reports NUL-bearing, U+FFFD-bearing and unreadable files", () => {
    const files = {
      "docs/features/epics/a.md": "a\0b",
      "docs/features/epics/b.md": "�",
    };
    const result = buildMigrationPlan(
      inputs(files, {
        trackedFiles: [...Object.keys(files), "docs/features/epics/c.md"],
      }),
    );
    expect(result.plan.skipped).toEqual([
      "docs/features/epics/a.md",
      "docs/features/epics/b.md",
      "docs/features/epics/c.md",
    ]);
  });

  it("lists untracked files without refusing", () => {
    const files = baseFiles();
    const result = apply(files, decisionsFor(files), {
      untrackedFiles: [`${FOO}/scratch.log`],
    });
    expect(result.refusals).toEqual([]);
    expect(result.plan.untracked).toEqual([`${FOO}/scratch.log`]);
  });

  it("reports the dry-run defaults: OQ-1 target and alternative, OQ-2 and OQ-12 alternatives", () => {
    // Arrange
    const files = {
      ...baseFiles(),
      "docs/discovery/templates/v2/a.json": "{}",
    };

    // Act
    const { plan, refusals } = buildMigrationPlan(inputs(files));

    // Assert
    expect(refusals).toEqual([]);
    expect(plan.discoveryTarget).toBe(".dev/discovery/templates");
    expect(plan.moves).toContainEqual({
      from: "docs/discovery/templates",
      to: ".dev/discovery/templates",
    });
    expect(plan.discoveryAlternative).toEqual({
      target: ".dev/templates",
      moves: [{ from: "docs/discovery/templates/v2", to: ".dev/templates/v2" }],
    });
    expect(plan.inTreeReferencesAndLinks.map((item) => item.path)).toEqual([
      `${FOO}/spec.md`,
    ]);
    expect(plan.inTreeLinksOnly.map((item) => item.path)).toEqual([
      `${FOO}/spec.md`,
    ]);
    expect(plan.openChoices).toEqual([
      "discovery_templates_target",
      "in_tree_rewrite_scope",
      "commit_split",
    ]);
    expect(plan.rewrites).toEqual([]);
    expect(plan.commitSplit).toBeNull();
  });

  it("derives the counts from the supplied tracked-file list", () => {
    const { plan } = buildMigrationPlan(inputs(baseFiles()));
    expect(plan.candidateFolders).toEqual([FOO, HELD, KEPT, BAR].sort());
    expect(plan.sourceDigest).toBe(computeSourceDigest(plan.candidateFolders));
    expect(plan.outsideRewrites).toEqual([
      { path: "README.md", references: 1, links: 1 },
    ]);
  });

  it("classifies a record at a mapped target as in-tree on a post-move dry run", () => {
    // Arrange: the tree is already moved; one record keeps an old prefix.
    const moved = ".dev/completed/0012-bar/plan.md";
    const files = {
      [moved]: "see docs/features/active/x/plan.md\n",
      "README.md": "plain",
    };

    // Act
    const dry = buildMigrationPlan(inputs(files)).plan;
    const applied = apply(
      files,
      decisionsFor(
        files,
        { decisions: [] },
        { in_tree_rewrite_scope: "links-only" },
      ),
    ).plan;

    // Assert
    expect(dry.inTreeReferencesAndLinks.map((item) => item.path)).toEqual([
      moved,
    ]);
    expect(dry.outsideRewrites.map((item) => item.path)).not.toContain(moved);
    expect(applied.rewrites.map((item) => item.path)).not.toContain(moved);
  });
});

describe("buildMigrationPlan decisions", () => {
  it("uses a decision-file discovery_templates_target as the destination of docs/discovery", () => {
    const files = {
      ...baseFiles(),
      "docs/discovery/templates/v2/a.json": "{}",
    };
    const { plan } = apply(
      files,
      decisionsFor(files, {}, { discovery_templates_target: ".dev/templates" }),
    );
    expect(plan.discoveryTarget).toBe(".dev/templates");
    expect(plan.moves).toContainEqual({
      from: "docs/discovery/templates/v2",
      to: ".dev/templates/v2",
    });
  });

  it("requires OQ-1 only when docs/discovery holds a tracked file", () => {
    const withDiscovery = {
      ...baseFiles(),
      "docs/discovery/templates/v2/a.json": "{}",
    };
    const refused = apply(
      withDiscovery,
      decisionsFor(withDiscovery, {}, { discovery_templates_target: null }),
    );
    expect(refused.refusals).toEqual([
      "required global choice is unset: discovery_templates_target",
    ]);
    const allowed = apply(
      baseFiles(),
      decisionsFor(baseFiles(), {}, { discovery_templates_target: null }),
    );
    expect(allowed.refusals).toEqual([]);
  });

  it("requires OQ-2 only when a moved file contains a rewrite candidate", () => {
    const refused = apply(
      baseFiles(),
      decisionsFor(baseFiles(), {}, { in_tree_rewrite_scope: null }),
    );
    expect(refused.refusals).toEqual([
      "required global choice is unset: in_tree_rewrite_scope",
    ]);
    const quiet = { ...baseFiles(), [`${FOO}/spec.md`]: "no references" };
    expect(
      apply(quiet, decisionsFor(quiet, {}, { in_tree_rewrite_scope: null }))
        .refusals,
    ).toEqual([]);
  });

  it("requires OQ-12 only when the plan holds both moves and rewrites", () => {
    const refused = apply(
      baseFiles(),
      decisionsFor(baseFiles(), {}, { commit_split: null }),
    );
    expect(refused.refusals).toEqual([
      "required global choice is unset: commit_split",
    ]);
    const movesOnly = { [`${BAR}/plan.md`]: "plain" };
    expect(
      apply(
        movesOnly,
        decisionsFor(movesOnly, { decisions: [] }, { commit_split: null }),
      ).refusals,
    ).toEqual([]);
  });

  it("applies rename and keep decisions to held and mechanical folders", () => {
    // Arrange
    const decisions = decisionsFor(baseFiles(), {
      decisions: [
        {
          source: HELD,
          action: "rename",
          target: "0897-subagentstop-envelope-core",
        },
        { source: BAR, action: "keep" },
      ],
    });

    // Act
    const { plan, refusals } = apply(baseFiles(), decisions);

    // Assert
    expect(refusals).toEqual([]);
    expect(plan.renames).toEqual([
      { from: ".dev/active/2026-10-30-foo-1016", to: ".dev/active/1016-foo" },
      {
        from: ".dev/archive/subagentstop-envelope-core-897",
        to: ".dev/archive/0897-subagentstop-envelope-core",
      },
    ]);
  });

  it("refuses a decided rename target that collides with an existing name", () => {
    const decisions = decisionsFor(baseFiles(), {
      decisions: [{ source: HELD, action: "rename", target: "0012-bar" }],
    });
    expect(apply(baseFiles(), decisions).refusals).toEqual([
      `rename target collides case-insensitively: 0012-bar (from ${BAR})`,
    ]);
  });

  it("flags a mapping-record candidate only when old and new prefixes both appear", () => {
    const files = {
      ...baseFiles(),
      "notes/map.md": "docs/features/active/ became .dev/active/",
      "notes/old.md": "docs/features/active/ only",
    };
    expect(
      buildMigrationPlan(inputs(files)).plan.mappingRecordCandidates,
    ).toEqual(["notes/map.md"]);
  });

  it("carries kept folders into the plan without refusing them", () => {
    const { plan, refusals } = apply(baseFiles(), decisionsFor(baseFiles()));
    expect(plan.kept).toEqual([{ source: KEPT, format: "other" }]);
    expect(refusals).toEqual([]);
  });
});
