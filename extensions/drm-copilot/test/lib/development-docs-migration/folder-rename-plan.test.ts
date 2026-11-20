import { describe, expect, it } from "@jest/globals";

import {
  planFolderRenames,
  splitFolderPath,
} from "../../../src/lib/development-docs-migration/folder-rename-plan";

const A = "docs/features/active";
const C = "docs/features/completed";
const R = "docs/features/archive";

describe("planFolderRenames", () => {
  it("renames a date-first folder with an issue number mechanically (rules 1-2, F-1)", () => {
    // Act
    const plan = planFolderRenames([`${A}/2026-10-30-foo-bar-1016`]);

    // Assert
    expect(plan.renames).toEqual([
      {
        source: `${A}/2026-10-30-foo-bar-1016`,
        area: "active",
        from: "2026-10-30-foo-bar-1016",
        to: "1016-foo-bar",
      },
    ]);
    expect(plan.held).toEqual([]);
    expect(plan.kept).toEqual([]);
  });

  it.each([`${A}/1016-foo-bar`, `${C}/0042-foo-bar`])(
    "leaves an issue-first folder %s in no list (rule 3, F-3, F-4)",
    (folder) => {
      // Act
      const plan = planFolderRenames([folder]);

      // Assert
      expect(plan).toEqual({ renames: [], held: [], kept: [] });
    },
  );

  it("holds an other-format folder with an issue number as non-matching (rule 4, F-5)", () => {
    // Act
    const plan = planFolderRenames([`${R}/subagentstop-envelope-core-897`]);

    // Assert
    expect(plan.held).toEqual([
      {
        source: `${R}/subagentstop-envelope-core-897`,
        reason: "non-matching",
        candidate: "0897-subagentstop-envelope-core",
      },
    ]);
    expect(plan.renames).toEqual([]);
  });

  it("keeps folders with no recoverable issue number, only in kept (rule 5, F-2, F-6)", () => {
    // Act
    const plan = planFolderRenames([
      `${A}/2026-10-30-foo-bar`,
      `${C}/notes-feature`,
    ]);

    // Assert
    expect(plan.kept).toEqual([
      { source: `${A}/2026-10-30-foo-bar`, format: "date-first" },
      { source: `${C}/notes-feature`, format: "other" },
    ]);
    expect(plan.renames).toEqual([]);
    expect(plan.held).toEqual([]);
  });

  it("holds every folder of an issue number with more than one folder (rule 6)", () => {
    // Act
    const plan = planFolderRenames([
      `${A}/2026-01-01-alpha-543`,
      `${R}/epic-planner-receipt-checks-key-gate-543`,
      `${C}/2026-02-02-other-544`,
    ]);

    // Assert
    expect(plan.held.map((item) => [item.source, item.reason])).toEqual([
      [`${A}/2026-01-01-alpha-543`, "multi-folder-issue"],
      [`${R}/epic-planner-receipt-checks-key-gate-543`, "multi-folder-issue"],
    ]);
    expect(plan.renames.map((rename) => rename.to)).toEqual(["0544-other"]);
  });

  it.each([
    ["2026-01-01-foo-0", "positive integer"],
    ["2026-01-01-foo-12345", "at most 9999"],
    ["2026-01-01-Bad_Name-12", "feature name is invalid"],
    ["2026-01-01-04-05-x-12", "feature name is invalid"],
  ])(
    "reports formatter error for %s and holds it without throwing (rule 7)",
    (name, detail) => {
      // Act
      const plan = planFolderRenames([`${A}/${name}`]);

      // Assert
      expect(plan.held).toHaveLength(1);
      expect(plan.held[0]).toMatchObject({
        source: `${A}/${name}`,
        reason: "formatter-error",
        candidate: null,
      });
      expect(plan.held[0]?.detail).toContain(detail);
    },
  );

  it("holds a candidate that collides case-insensitively with an existing name in another area (rule 8)", () => {
    // Act
    const plan = planFolderRenames([
      `${A}/2026-03-03-feature-12`,
      `${R}/0012-Feature`,
    ]);

    // Assert
    expect(plan.held).toEqual([
      {
        source: `${A}/2026-03-03-feature-12`,
        reason: "collision",
        candidate: "0012-feature",
      },
    ]);
    expect(plan.renames).toEqual([]);
  });

  it("ignores an embedded earlier number and uses the trailing issue", () => {
    // Act
    const plan = planFolderRenames([
      `${C}/2026-10-03-issue-823-tier-rule-adoption-follow-ups-824`,
    ]);

    // Assert
    expect(plan.renames[0]?.to).toBe(
      "0824-issue-823-tier-rule-adoption-follow-ups",
    );
  });

  it("never renames nested folders, because only top-level folders are inputs", () => {
    // Act
    const plan = planFolderRenames([`${A}/2026-10-30-foo-bar-1016`]);

    // Assert: the rename covers the top-level name only; v1/ and audit-*/ move with it.
    expect(plan.renames[0]?.source.split("/")).toHaveLength(4);
    expect(splitFolderPath(`${A}/2026-10-30-foo-bar-1016`)).toEqual({
      area: "active",
      name: "2026-10-30-foo-bar-1016",
    });
  });

  it("returns empty lists for no input", () => {
    expect(planFolderRenames([])).toEqual({ renames: [], held: [], kept: [] });
    expect(splitFolderPath("")).toEqual({ area: "", name: "" });
  });
});
