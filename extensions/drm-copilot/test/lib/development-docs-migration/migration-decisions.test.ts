import { describe, expect, it } from "@jest/globals";

import {
  buildDecisionSkeleton,
  computeSourceDigest,
  CONSUMED_CHOICES,
  parseMigrationDecisions,
  RECORD_ONLY_KEYS,
  validateMigrationDecisions,
  type MigrationDecisions,
} from "../../../src/lib/development-docs-migration/migration-decisions";

const F1 = "docs/features/active/2026-10-30-foo-1016";
const F5 = "docs/features/archive/epic-planner-receipt-checks-key-gate-543";

/** Build a complete, valid decision-file object. */
function validFile(): Record<string, unknown> {
  const globals: Record<string, unknown> = {
    discovery_templates_target: ".dev/discovery/templates",
    in_tree_rewrite_scope: "links-only",
    commit_split: "single",
  };
  for (const key of RECORD_ONLY_KEYS) {
    globals[key] = `answer for ${key}`;
  }
  return {
    version: 1,
    dry_run_report: "dev-docs-migration-dry-run.2026-11-20T07-00.json",
    source_digest: "abc",
    global_decisions: globals,
    rewrite_exclusions: ["**/evidence/**"],
    decisions: [
      {
        source: F5,
        action: "rename",
        target: "0543-epic-planner-receipt-checks-key-gate-b",
      },
      { source: F1, action: "keep" },
    ],
  };
}

function withGlobal(key: string, value: unknown): string {
  const file = validFile();
  const globals = file["global_decisions"] as Record<string, unknown>;
  if (value === undefined) {
    delete globals[key];
  } else {
    globals[key] = value;
  }
  return JSON.stringify(file);
}

function parse(file: Record<string, unknown>): MigrationDecisions {
  return parseMigrationDecisions(JSON.stringify(file));
}

describe("parseMigrationDecisions", () => {
  it("parses a valid decision file", () => {
    // Act
    const decisions = parse(validFile());

    // Assert
    expect(decisions).toMatchObject({
      version: 1,
      sourceDigest: "abc",
      dryRunReport: "dev-docs-migration-dry-run.2026-11-20T07-00.json",
      discoveryTemplatesTarget: ".dev/discovery/templates",
      inTreeRewriteScope: "links-only",
      commitSplit: "single",
      rewriteExclusions: ["**/evidence/**"],
    });
    expect(decisions.decisions).toHaveLength(2);
    expect(Object.keys(decisions.recordOnly)).toHaveLength(9);
  });

  it("rejects a version other than 1", () => {
    expect(() => parse({ ...validFile(), version: 2 })).toThrow(
      "version must be 1",
    );
  });

  it("rejects invalid JSON, a non-object, a missing digest and a non-object global_decisions", () => {
    expect(() => parseMigrationDecisions("{")).toThrow("not valid JSON");
    expect(() => parseMigrationDecisions("[]")).toThrow(
      "must be a JSON object",
    );
    expect(() => parse({ ...validFile(), source_digest: 5 })).toThrow(
      "source_digest must be a string",
    );
    expect(() => parse({ ...validFile(), global_decisions: [] })).toThrow(
      "global_decisions must be an object",
    );
    expect(() => parse({ ...validFile(), dry_run_report: 3 })).toThrow(
      "dry_run_report must be a string",
    );
  });

  describe.each(RECORD_ONLY_KEYS.map((key) => [key]))(
    "record-only key %s",
    (key) => {
      it.each([
        ["null", null],
        ["missing", undefined],
        ["a non-string", 7],
      ])("is rejected when %s", (_label, value) => {
        expect(() => parseMigrationDecisions(withGlobal(key, value))).toThrow(
          `global_decisions.${key} must be a present string`,
        );
      });
    },
  );

  describe.each(CONSUMED_CHOICES.map((key) => [key]))(
    "consumed choice %s",
    (key) => {
      it.each([
        ["null", null],
        ["missing", undefined],
      ])("is accepted when %s", (_label, value) => {
        const decisions = parseMigrationDecisions(withGlobal(key, value));
        expect(decisions).toBeDefined();
      });

      it("is rejected when a non-string", () => {
        expect(() => parseMigrationDecisions(withGlobal(key, 4))).toThrow(
          `global_decisions.${key} must be a string or null`,
        );
      });
    },
  );

  it.each(["in_tree_rewrite_scope", "commit_split"])(
    "rejects %s outside the spec's value set",
    (key) => {
      expect(() =>
        parseMigrationDecisions(withGlobal(key, "everything")),
      ).toThrow(`global_decisions.${key} must be one of`);
    },
  );

  it("limits decisions[].action to rename and keep and requires a rename target", () => {
    expect(() =>
      parse({ ...validFile(), decisions: [{ source: F1, action: "delete" }] }),
    ).toThrow("decisions[0].action must be rename or keep");
    expect(() =>
      parse({ ...validFile(), decisions: [{ source: F1, action: "rename" }] }),
    ).toThrow("decisions[0].target must be a string for a rename");
    expect(() =>
      parse({ ...validFile(), decisions: [{ action: "keep" }] }),
    ).toThrow("decisions[0].source must be a string");
    expect(() => parse({ ...validFile(), decisions: {} })).toThrow(
      "decisions must be an array",
    );
  });

  it("rejects non-string rewrite exclusions and defaults absent lists to empty", () => {
    expect(() => parse({ ...validFile(), rewrite_exclusions: [1] })).toThrow(
      "rewrite_exclusions must be an array of strings",
    );
    const file = validFile();
    delete file["rewrite_exclusions"];
    delete file["decisions"];
    delete file["dry_run_report"];
    const decisions = parse(file);
    expect(decisions.rewriteExclusions).toEqual([]);
    expect(decisions.decisions).toEqual([]);
    expect(decisions.dryRunReport).toBeNull();
  });
});

describe("computeSourceDigest", () => {
  it("is stable under input order and changed by one added path", () => {
    // Act
    const first = computeSourceDigest([F1, F5]);
    const reordered = computeSourceDigest([F5, F1]);
    const added = computeSourceDigest([F1, F5, "docs/features/completed/x-1"]);

    // Assert
    expect(first).toMatch(/^[0-9a-f]{64}$/);
    expect(reordered).toBe(first);
    expect(added).not.toBe(first);
  });
});

describe("validateMigrationDecisions", () => {
  const decisions = parse({ ...validFile(), source_digest: "d1" });
  const context = {
    reportedFolders: [F1, F5],
    heldSources: [F5],
    sourceDigest: "d1",
    requiredChoices: [...CONSUMED_CHOICES],
  };

  it("returns no refusal for matching decisions", () => {
    expect(validateMigrationDecisions(decisions, context)).toEqual([]);
  });

  it("refuses on a source_digest mismatch", () => {
    expect(
      validateMigrationDecisions(decisions, {
        ...context,
        sourceDigest: "d2",
      })[0],
    ).toContain("source_digest mismatch");
  });

  it("refuses a decision naming an unreported source", () => {
    expect(
      validateMigrationDecisions(decisions, {
        ...context,
        reportedFolders: [F5],
      }),
    ).toEqual([`decision names a source that is not a reported folder: ${F1}`]);
  });

  it("refuses a rename target that is not issue-first", () => {
    const bad = parse({
      ...validFile(),
      source_digest: "d1",
      decisions: [{ source: F5, action: "rename", target: "2026-01-01-x-543" }],
    });
    expect(validateMigrationDecisions(bad, context)).toEqual([
      "rename target is not issue-first: 2026-01-01-x-543",
    ]);
  });

  it("refuses a held source with no decision entry", () => {
    const none = parse({ ...validFile(), source_digest: "d1", decisions: [] });
    expect(validateMigrationDecisions(none, context)).toEqual([
      `held item has no decision entry: ${F5}`,
    ]);
  });

  it("refuses an unset required choice and accepts it when not required", () => {
    const unset = parseMigrationDecisions(
      JSON.stringify({
        ...JSON.parse(withGlobal("commit_split", null)),
        source_digest: "d1",
      }),
    );
    expect(validateMigrationDecisions(unset, context)).toEqual([
      "required global choice is unset: commit_split",
    ]);
    expect(
      validateMigrationDecisions(unset, {
        ...context,
        requiredChoices: ["in_tree_rewrite_scope"],
      }),
    ).toEqual([]);
  });

  it("accepts a reported mechanical rename with no decision entry", () => {
    const only = parse({
      ...validFile(),
      source_digest: "d1",
      decisions: [{ source: F5, action: "keep" }],
    });
    expect(validateMigrationDecisions(only, context)).toEqual([]);
  });
});

describe("buildDecisionSkeleton", () => {
  it("lists every held item and every consumed and record-only key with null", () => {
    // Act
    const skeleton = buildDecisionSkeleton({
      dryRunReport: "r.json",
      sourceDigest: "d",
      heldSources: [F5],
    });

    // Assert
    const globals = skeleton["global_decisions"] as Record<string, unknown>;
    expect(Object.keys(globals).sort()).toEqual(
      [...CONSUMED_CHOICES, ...RECORD_ONLY_KEYS].sort(),
    );
    expect(Object.values(globals).every((value) => value === null)).toBe(true);
    expect(skeleton["decisions"]).toEqual([
      { source: F5, action: null, target: null },
    ]);
    expect(skeleton["source_digest"]).toBe("d");
    expect(skeleton["version"]).toBe(1);
  });
});
