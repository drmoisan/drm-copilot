/**
 * Tests for the `update_docs_ledger` per-operation table (issue #1036, D-1).
 * Split from `mcp-tool-inputs-docs.test.ts` to keep each file below 500
 * logical lines (D-4). Every case is in memory.
 */

import { describe, expect, it } from "@jest/globals";

import {
  DOCS_LEDGER_OPERATION_RULES,
  DocsInputError,
  resolveDocsToolInput,
} from "../src/mcp-tool-inputs-docs";

const ROOT = "/virtual/workspace";
const ELEMENT = `config-key-${"c".repeat(64)}`;
const ACTOR = { actor_kind: "human", actor_id: "maintainer" } as const;

/** A minimal valid input per operation. */
const MINIMAL: Readonly<Record<string, Record<string, unknown>>> = {
  "set-disposition": { element: ELEMENT, disposition: "documented" },
  "remove-entry": { element: ELEMENT },
  pin: { element: ELEMENT, pages: ["docs/a.md"] },
  unpin: { element: ELEMENT, pages: ["docs/a.md"] },
  "set-dimension": {
    element: ELEMENT,
    pages: ["docs/a.md"],
    dimension: "accurate",
    state: "pass",
  },
  "sync-refs": {},
};

/** A valid value for every per-operation field. */
const FIELD_VALUES: Readonly<Record<string, unknown>> = {
  element: ELEMENT,
  limit: "diagnostic-python-cli-1",
  disposition: "deferred",
  pages: ["docs/a.md"],
  rationale: "Reason.",
  owner: "docs-team",
  target: "Next release",
  dimension: "exists",
  state: "fail",
  claim: "The option is documented.",
};

function ledger(operation: string, fields: Record<string, unknown>) {
  return resolveDocsToolInput("update_docs_ledger", {
    workspace_root: ROOT,
    operation,
    ...ACTOR,
    ...fields,
  });
}

function rejects(operation: string, fields: Record<string, unknown>): boolean {
  try {
    ledger(operation, fields);
  } catch (error) {
    return error instanceof DocsInputError;
  }
  return false;
}

describe("update_docs_ledger per-operation table", () => {
  it("rejects each operation missing a required field", () => {
    for (const [operation, rule] of Object.entries(
      DOCS_LEDGER_OPERATION_RULES,
    )) {
      // Arrange
      const minimal = MINIMAL[operation] ?? {};

      // Act and Assert: the minimal input is accepted.
      expect(ledger(operation, minimal).subcommand).toBe("update-ledger");
      for (const field of rule.required) {
        const withoutField = { ...minimal };
        delete withoutField[field];
        expect({
          operation,
          field,
          rejected: rejects(operation, withoutField),
        }).toEqual({
          operation,
          field,
          rejected: true,
        });
      }
      if (rule.target === "element") {
        const withoutElement = { ...minimal };
        delete withoutElement["element"];
        expect(rejects(operation, withoutElement)).toBe(true);
      }
    }
    // An empty pages array counts as absent.
    expect(rejects("pin", { element: ELEMENT, pages: [] })).toBe(true);
    for (const field of ["actor_kind", "actor_id"]) {
      expect(() =>
        resolveDocsToolInput("update_docs_ledger", {
          workspace_root: ROOT,
          operation: "sync-refs",
          ...ACTOR,
          [field]: undefined,
        }),
      ).toThrow(DocsInputError);
    }
  });

  it("rejects each field an operation does not permit", () => {
    for (const [operation, rule] of Object.entries(
      DOCS_LEDGER_OPERATION_RULES,
    )) {
      // Arrange
      const permitted = new Set<string>([
        ...rule.required,
        ...rule.optional,
        ...(rule.target === "none" ? [] : ["element"]),
        ...(rule.target === "either" ? ["limit"] : []),
      ]);
      const minimal = MINIMAL[operation] ?? {};

      for (const [field, value] of Object.entries(FIELD_VALUES)) {
        if (permitted.has(field)) {
          continue;
        }
        // Act and Assert
        expect({
          operation,
          field,
          rejected: rejects(operation, { ...minimal, [field]: value }),
        }).toEqual({
          operation,
          field,
          rejected: true,
        });
      }
    }
  });

  it("requires exactly one of element and limit for set-disposition and remove-entry", () => {
    for (const operation of ["set-disposition", "remove-entry"]) {
      // Arrange
      const minimal = MINIMAL[operation] ?? {};
      const withoutElement = { ...minimal };
      delete withoutElement["element"];
      const limitOnly = { ...withoutElement, limit: "diagnostic-python-cli-1" };

      // Act and Assert
      expect(ledger(operation, limitOnly).options).toContain("-Limit");
      expect(rejects(operation, withoutElement)).toBe(true);
      expect(
        rejects(operation, { ...minimal, limit: "diagnostic-python-cli-1" }),
      ).toBe(true);
      expect(
        rejects(operation, { ...withoutElement, limit: "python-cli-1" }),
      ).toBe(true);
    }
  });

  it("requires a single page without anchor for pin, unpin and set-dimension", () => {
    for (const operation of ["pin", "unpin", "set-dimension"]) {
      // Arrange
      const minimal = MINIMAL[operation] ?? {};

      // Act and Assert
      expect(ledger(operation, minimal).options).toContain("docs/a.md");
      expect(
        rejects(operation, { ...minimal, pages: ["docs/a.md#usage"] }),
      ).toBe(true);
      expect(
        rejects(operation, { ...minimal, pages: ["docs/a.md", "docs/b.md"] }),
      ).toBe(true);
    }
    // set-disposition accepts several pages with anchors.
    expect(
      ledger("set-disposition", {
        ...MINIMAL["set-disposition"],
        pages: ["docs/a.md#one", "docs/b.md"],
      }).options,
    ).toEqual(expect.arrayContaining(["docs/a.md#one", "docs/b.md"]));
  });

  it("does not reject a missing companion value that the ledger reports as a finding", () => {
    // Act
    const excluded = ledger("set-disposition", {
      element: ELEMENT,
      disposition: "excluded",
    });
    const limitDocumented = ledger("set-disposition", {
      limit: "diagnostic-python-cli-1",
      disposition: "documented",
    });

    // Assert: PowerShell, not TypeScript, reports these.
    expect(excluded.options).not.toContain("-Rationale");
    expect(excluded.options).toEqual(
      expect.arrayContaining(["-Disposition", "excluded"]),
    );
    expect(limitDocumented.options).toEqual(
      expect.arrayContaining(["-Limit", "-Disposition"]),
    );
  });
});
