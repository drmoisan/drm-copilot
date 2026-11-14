/**
 * Tests for the docs input grammar and vocabulary module (issue #1173,
 * remediation cycle 1). Every case is in memory.
 */

import { describe, expect, it } from "@jest/globals";

import * as grammarModule from "../src/mcp-tool-inputs-docs-grammar";
import {
  DocsInputError,
  matchesDocsGrammar,
  type DocsGrammar,
} from "../src/mcp-tool-inputs-docs-grammar";
import * as docsInputs from "../src/mcp-tool-inputs-docs";

const REVISION_40 = "a".repeat(40);
const REVISION_64 = "b".repeat(64);
const ELEMENT = `cli-command-${"c".repeat(64)}`;

/** Every value export moved from mcp-tool-inputs-docs.ts (D-1). */
const MOVED_VALUE_EXPORTS = [
  "DOCS_RELATIVE_PATH_PATTERN",
  "DOCS_IDENTIFIER_PATTERN",
  "DOCS_REVISION_PATTERN",
  "DOCS_ELEMENT_ID_PATTERN",
  "DOCS_TEXT_PATTERN",
  "DOCS_LIMIT_PREFIX",
  "DOCS_LEDGER_OPERATIONS",
  "DOCS_DISPOSITIONS",
  "DOCS_DIMENSIONS",
  "DOCS_DIMENSION_STATES",
  "DOCS_LEDGER_COMMON_FIELDS",
  "DocsInputError",
  "matchesDocsGrammar",
] as const;

describe("matchesDocsGrammar", () => {
  it.each<[DocsGrammar, string]>([
    ["relative-path", "docs/guide.md"],
    ["identifier", "owner.name-1"],
    ["revision", REVISION_40],
    ["revision", REVISION_64],
    ["element-id", ELEMENT],
    ["text", " a "],
    ["page-reference", "docs/guide.md"],
    ["page-reference", "docs/guide.md#usage"],
    ["limit", "diagnostic-missing-page"],
  ])("accepts %s value %j", (grammar, candidate) => {
    // Act
    const accepted = matchesDocsGrammar(grammar, candidate);

    // Assert
    expect(accepted).toBe(true);
  });

  it.each<[DocsGrammar, string]>([
    ["relative-path", "/docs/guide.md"],
    ["relative-path", "docs/../guide.md"],
    ["identifier", "Owner"],
    ["revision", "a".repeat(39)],
    ["element-id", `unknown-kind-${"c".repeat(64)}`],
    ["text", "   "],
    ["page-reference", "../guide.md#usage"],
    ["page-reference", "docs/guide.md#"],
    ["page-reference", "docs/guide.md# "],
    ["limit", "missing-page"],
    ["limit", "diagnostic-Missing"],
  ])("rejects %s value %j", (grammar, candidate) => {
    // Act
    const accepted = matchesDocsGrammar(grammar, candidate);

    // Assert
    expect(accepted).toBe(false);
  });

  it("rejects every value for a grammar name that has no pattern", () => {
    // Arrange
    const unknownGrammar = "unknown" as DocsGrammar;

    // Act
    const accepted = matchesDocsGrammar(unknownGrammar, "anything");

    // Assert
    expect(accepted).toBe(false);
  });
});

describe("DocsInputError", () => {
  it("carries the DOCS_INPUT_INVALID code, its name and the prefixed message", () => {
    // Act
    const error = new DocsInputError("profile must be a string.");

    // Assert
    expect(error).toBeInstanceOf(Error);
    expect(error.code).toBe("DOCS_INPUT_INVALID");
    expect(error.name).toBe("DocsInputError");
    expect(error.message).toBe("DOCS_INPUT_INVALID: profile must be a string.");
  });
});

describe("mcp-tool-inputs-docs re-exports", () => {
  it("re-exports every moved symbol from mcp-tool-inputs-docs.ts as the same binding", () => {
    // Act
    const mismatched = MOVED_VALUE_EXPORTS.filter((name) => {
      const reExported: unknown = docsInputs[name];
      return reExported !== grammarModule[name];
    });

    // Assert
    expect(mismatched).toEqual([]);
    for (const name of MOVED_VALUE_EXPORTS) {
      expect(docsInputs[name]).toBe(grammarModule[name]);
    }
  });
});
