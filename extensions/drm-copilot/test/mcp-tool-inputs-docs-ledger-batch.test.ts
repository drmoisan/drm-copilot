/**
 * Tests for the update_docs_ledger operations batch validation and
 * serialization (issue #1173 B2.5). Every input is an in-memory value; no
 * process is launched and no file is read or written.
 */

import { describe, expect, it } from "@jest/globals";

import {
  DOCS_LEDGER_BATCH_ITEM_FIELDS,
  serializeDocsLedgerOperations,
  validateDocsLedgerOperations,
} from "../src/mcp-tool-inputs-docs-ledger-batch";
import { DocsInputError } from "../src/mcp-tool-inputs-docs";

const ELEMENT = `cli-command-${"a".repeat(64)}`;

describe("validateDocsLedgerOperations", () => {
  it("accepts items carrying every item field and returns them in input order", () => {
    // Arrange
    const operations = [
      {
        operation: "set-dimension",
        element: ELEMENT,
        pages: ["docs/a.md"],
        dimension: "accurate",
        state: "pass",
        claim: "The page states the flag.",
        rationale: "r",
      },
      {
        operation: "set-disposition",
        limit: "diagnostic-x",
        disposition: "deferred",
        owner: "docs-team",
        target: "Next release",
      },
      { operation: "remove-entry", element: ELEMENT },
    ];

    // Act
    const result = validateDocsLedgerOperations(operations);

    // Assert
    expect(result).toEqual(operations);
    expect([...DOCS_LEDGER_BATCH_ITEM_FIELDS].sort()).toEqual(
      [
        "claim",
        "dimension",
        "disposition",
        "element",
        "limit",
        "operation",
        "owner",
        "pages",
        "rationale",
        "state",
        "target",
      ].sort(),
    );
  });

  it.each([
    ["a value that is not an array", { operation: "pin" }, "must be an array"],
    ["an empty array", [], "at least one"],
    ["an item that is not an object", [7], "operations[0] must be an object"],
    ["an array item", [[]], "operations[0] must be an object"],
    ["a null item", [null], "operations[0] must be an object"],
    [
      "an unknown key",
      [{ operation: "remove-entry", element: ELEMENT, actor_id: "x" }],
      "does not accept actor_id",
    ],
    ["a missing operation", [{ element: ELEMENT }], "operation must be one of"],
    [
      "a sync-refs item",
      [{ operation: "sync-refs" }],
      "sync-refs is not a batch item",
    ],
    [
      "an unknown operation",
      [{ operation: "explode" }],
      "operation must be one of",
    ],
    [
      "an invalid element id",
      [{ operation: "remove-entry", element: "cli-command-x" }],
      "element-id grammar",
    ],
    [
      "an invalid limit",
      [{ operation: "remove-entry", limit: "x" }],
      "limit grammar",
    ],
    [
      "an invalid owner",
      [{ operation: "set-disposition", element: ELEMENT, owner: "Docs Team" }],
      "identifier grammar",
    ],
    [
      "a blank rationale",
      [{ operation: "set-disposition", element: ELEMENT, rationale: " " }],
      "text grammar",
    ],
    [
      "a non-string text field",
      [{ operation: "set-disposition", element: ELEMENT, target: 5 }],
      "target must be a string",
    ],
    [
      "an unknown disposition",
      [{ operation: "set-disposition", element: ELEMENT, disposition: "x" }],
      "disposition must be one of",
    ],
    [
      "an unknown dimension",
      [{ operation: "set-dimension", element: ELEMENT, dimension: "x" }],
      "dimension must be one of",
    ],
    [
      "an unknown state",
      [{ operation: "set-dimension", element: ELEMENT, state: "x" }],
      "state must be one of",
    ],
    [
      "pages that are not an array",
      [{ operation: "pin", element: ELEMENT, pages: "docs/a.md" }],
      "pages must be an array",
    ],
    [
      "a page that is not a page reference",
      [{ operation: "pin", element: ELEMENT, pages: ["/abs.md"] }],
      "page-reference grammar",
    ],
    [
      "a repeated page",
      [
        {
          operation: "set-disposition",
          element: ELEMENT,
          pages: ["docs/a.md", "docs/a.md"],
        },
      ],
      "must not repeat",
    ],
  ])("rejects %s", (_case, value, fragment) => {
    // Act
    const act = (): unknown => validateDocsLedgerOperations(value);

    // Assert
    expect(act).toThrow(DocsInputError);
    expect(act).toThrow(fragment);
  });

  it("names the index of the failing item", () => {
    // Act
    const act = (): unknown =>
      validateDocsLedgerOperations([
        { operation: "remove-entry", element: ELEMENT },
        { operation: "pin", element: ELEMENT, pages: ["docs/a.md"], x: 1 },
      ]);

    // Assert
    expect(act).toThrow("operations[1] does not accept x");
  });
});

describe("serializeDocsLedgerOperations", () => {
  it("serializes the items as the operations document", () => {
    // Arrange
    const items = [{ operation: "remove-entry", element: ELEMENT }];

    // Act
    const text = serializeDocsLedgerOperations(items);

    // Assert
    expect(JSON.parse(text)).toEqual({ operations: items });
  });
});
