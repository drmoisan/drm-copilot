/**
 * Value grammars and ledger vocabulary of the docs MCP tool inputs (issue
 * #1036; split out by issue #1173).
 *
 * This is the lower-level grammar and vocabulary module shared by the docs
 * input resolver (`mcp-tool-inputs-docs.ts`) and the ledger batch module
 * (`mcp-tool-inputs-docs-ledger-batch.ts`). It imports neither, so the two
 * modules depend on it without forming an import cycle. The patterns mirror
 * `schemas/docs/v1/common.schema.json` exactly.
 */

/**
 * Path-segment character class of the docs-common `relative-path` pattern. The
 * line and paragraph separator escapes are assembled from a backslash and the
 * hexadecimal digits so the source holds the escape text, not the characters.
 */
const LINE_SEPARATOR_ESCAPES = ["2028", "2029"]
  .map((digits) => `${String.fromCharCode(92)}u${digits}`)
  .join("");
const PATH_SEGMENT_CLASS = String.raw`[^/\\:\x00-\x1f${LINE_SEPARATOR_ESCAPES}*?<>|]`;
/** Docs-common `relative-path` pattern (exact committed string). */
export const DOCS_RELATIVE_PATH_PATTERN = String.raw`^(?!/)(?!.*(?:^|/)\.{1,2}(?:/|$))${PATH_SEGMENT_CLASS}+(?:/${PATH_SEGMENT_CLASS}+)*$(?![\s\S])`;
/** Docs-common `identifier` pattern (exact committed string). */
export const DOCS_IDENTIFIER_PATTERN = String.raw`^[a-z][a-z0-9]*(?:[._-][a-z0-9]+)*$(?![\s\S])`;
/** Docs-common `revision` pattern (exact committed string). */
export const DOCS_REVISION_PATTERN = String.raw`^(?:[0-9a-f]{40}|[0-9a-f]{64})$(?![\s\S])`;
/** Docs-common `element-id` pattern (exact committed string). */
export const DOCS_ELEMENT_ID_PATTERN = String.raw`^(?:cli-command|cli-option|http-route|config-key|public-symbol|architecture-component)-[0-9a-f]{64}$`;
/** Docs-common `text` pattern (exact committed string). */
export const DOCS_TEXT_PATTERN = String.raw`\S`;
/** Prefix of the diagnostic identifier accepted by `update-ledger -Limit`. */
export const DOCS_LIMIT_PREFIX = "diagnostic-";

export const DOCS_LEDGER_OPERATIONS = [
  "set-disposition",
  "remove-entry",
  "pin",
  "unpin",
  "set-dimension",
  "sync-refs",
  "bind-page-refs",
] as const;
export const DOCS_DISPOSITIONS = [
  "documented",
  "excluded",
  "deferred",
] as const;
export const DOCS_DIMENSIONS = [
  "exists",
  "accurate",
  "example_present",
  "owner_assigned",
  "diataxis_mode",
] as const;
export const DOCS_DIMENSION_STATES = [
  "pass",
  "fail",
  "not-assessed",
  "not-applicable",
] as const;

/** Value grammars a string field can carry. */
export type DocsGrammar =
  | "relative-path"
  | "identifier"
  | "revision"
  | "element-id"
  | "page-reference"
  | "text"
  | "limit";

/** Fields every `update_docs_ledger` operation accepts. */
export const DOCS_LEDGER_COMMON_FIELDS = [
  "workspace_root",
  "profile",
  "operation",
  "actor_kind",
  "actor_id",
  "write",
] as const;

/** Rejection of a docs tool input before any process starts. */
export class DocsInputError extends Error {
  readonly code = "DOCS_INPUT_INVALID";

  constructor(message: string) {
    super(`DOCS_INPUT_INVALID: ${message}`);
    this.name = "DocsInputError";
  }
}

const GRAMMAR_PATTERNS: Readonly<Record<string, RegExp>> = {
  "relative-path": new RegExp(DOCS_RELATIVE_PATH_PATTERN),
  identifier: new RegExp(DOCS_IDENTIFIER_PATTERN),
  revision: new RegExp(DOCS_REVISION_PATTERN),
  "element-id": new RegExp(DOCS_ELEMENT_ID_PATTERN),
  text: new RegExp(DOCS_TEXT_PATTERN),
};

function splitPageReference(reference: string): {
  readonly path: string;
  readonly anchor: string | undefined;
} {
  const separator = reference.indexOf("#");
  return separator < 0
    ? { path: reference, anchor: undefined }
    : {
        path: reference.slice(0, separator),
        anchor: reference.slice(separator + 1),
      };
}

/**
 * Tests a value against a docs grammar.
 *
 * @param grammar The grammar name.
 * @param candidate The string value.
 * @returns True when the value satisfies the grammar.
 */
export function matchesDocsGrammar(
  grammar: DocsGrammar,
  candidate: string,
): boolean {
  const test = (name: string, text: string): boolean =>
    GRAMMAR_PATTERNS[name]?.test(text) ?? false;
  if (grammar === "page-reference") {
    const { path, anchor } = splitPageReference(candidate);
    return (
      test("relative-path", path) &&
      (anchor === undefined || test("text", anchor))
    );
  }
  if (grammar === "limit") {
    return (
      test("identifier", candidate) && candidate.startsWith(DOCS_LIMIT_PREFIX)
    );
  }
  return test(grammar, candidate);
}
