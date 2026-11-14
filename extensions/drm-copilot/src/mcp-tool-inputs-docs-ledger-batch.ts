/**
 * Validation and serialization of the `operations` field of
 * `update_docs_ledger` (issue #1173 B2.5).
 *
 * Each item uses the `update_docs_ledger` field names. The resolver in
 * `mcp-tool-inputs-docs.ts` serializes the validated items as
 * `{ "operations": [...] }`, emits `-Operations -` and passes the text as
 * standard input, so the document never travels on the command line. The
 * per-operation field rules stay with `Test-DocsUpdateLedgerArgument`, which
 * the CLI applies to every item.
 */

import {
  DOCS_DIMENSION_STATES,
  DOCS_LEDGER_COMMON_FIELDS,
  DOCS_DIMENSIONS,
  DOCS_DISPOSITIONS,
  DOCS_LEDGER_OPERATIONS,
  DocsInputError,
  matchesDocsGrammar,
  type DocsGrammar,
} from "./mcp-tool-inputs-docs";

/** Fields one operations item may carry. */
export const DOCS_LEDGER_BATCH_ITEM_FIELDS = [
  "operation",
  "element",
  "limit",
  "disposition",
  "pages",
  "rationale",
  "owner",
  "target",
  "dimension",
  "state",
  "claim",
] as const;

/** One validated operations item. */
export type DocsLedgerBatchItem = Readonly<Record<string, unknown>>;

const STRING_FIELDS: Readonly<Record<string, DocsGrammar>> = {
  element: "element-id",
  limit: "limit",
  rationale: "text",
  owner: "identifier",
  target: "text",
  claim: "text",
};

function enumValues(field: string): ReadonlyArray<string> | undefined {
  switch (field) {
    case "disposition":
      return DOCS_DISPOSITIONS;
    case "dimension":
      return DOCS_DIMENSIONS;
    case "state":
      return DOCS_DIMENSION_STATES;
    default:
      return undefined;
  }
}

function checkGrammar(
  label: string,
  grammar: DocsGrammar,
  value: unknown,
): void {
  if (typeof value !== "string") {
    throw new DocsInputError(`${label} must be a string.`);
  }
  if (!matchesDocsGrammar(grammar, value)) {
    throw new DocsInputError(
      `${label} value ${JSON.stringify(value)} does not match the ${grammar} grammar.`,
    );
  }
}

function checkPages(label: string, value: unknown): void {
  if (!Array.isArray(value)) {
    throw new DocsInputError(`${label} must be an array of strings.`);
  }
  const items: unknown[] = value;
  items.forEach((item) => {
    checkGrammar(label, "page-reference", item);
  });
  if (new Set(items).size !== items.length) {
    throw new DocsInputError(`${label} must not repeat an entry.`);
  }
}

function checkItem(index: number, item: unknown): DocsLedgerBatchItem {
  const prefix = `operations[${String(index)}]`;
  if (typeof item !== "object" || item === null || Array.isArray(item)) {
    throw new DocsInputError(`${prefix} must be an object.`);
  }
  const record = item as DocsLedgerBatchItem;
  const allowed = new Set<string>(DOCS_LEDGER_BATCH_ITEM_FIELDS);
  for (const key of Object.keys(record)) {
    if (!allowed.has(key)) {
      throw new DocsInputError(`${prefix} does not accept ${key}.`);
    }
  }
  const operation = record["operation"];
  if (operation === "sync-refs") {
    throw new DocsInputError(
      `${prefix}: sync-refs is not a batch item; call it as its own operation.`,
    );
  }
  const operations: ReadonlyArray<unknown> = DOCS_LEDGER_OPERATIONS;
  if (typeof operation !== "string" || !operations.includes(operation)) {
    throw new DocsInputError(
      `${prefix}.operation must be one of ${DOCS_LEDGER_OPERATIONS.filter((name) => name !== "sync-refs").join(", ")}.`,
    );
  }
  for (const [field, value] of Object.entries(record)) {
    const label = `${prefix}.${field}`;
    const grammar = STRING_FIELDS[field];
    const values = enumValues(field);
    if (field === "pages") {
      checkPages(label, value);
    } else if (grammar !== undefined) {
      checkGrammar(label, grammar, value);
    } else if (
      values !== undefined &&
      (typeof value !== "string" || !values.includes(value))
    ) {
      throw new DocsInputError(`${label} must be one of ${values.join(", ")}.`);
    }
  }
  return record;
}

/**
 * Validates the `operations` field of `update_docs_ledger`.
 *
 * @param raw The field value.
 * @returns The items in input order.
 * @throws DocsInputError when the value is not a non-empty array of objects,
 *   an item carries an unknown key, its operation is `sync-refs` or not a
 *   ledger operation, or a field fails its grammar.
 */
export function validateDocsLedgerOperations(
  raw: unknown,
): ReadonlyArray<DocsLedgerBatchItem> {
  if (!Array.isArray(raw)) {
    throw new DocsInputError("operations must be an array of objects.");
  }
  const items: unknown[] = raw;
  if (items.length === 0) {
    throw new DocsInputError("operations must hold at least one item.");
  }
  return items.map((item, index) => checkItem(index, item));
}

/**
 * Serializes validated items as the operations document.
 *
 * @param items The validated items.
 * @returns The JSON text `{ "operations": [...] }`.
 */
export function serializeDocsLedgerOperations(
  items: ReadonlyArray<DocsLedgerBatchItem>,
): string {
  return JSON.stringify({ operations: items });
}

/**
 * Applies the update_docs_ledger rule that exactly one of operation and
 * operations is given, and returns the operations document for a batch.
 *
 * @param input The raw MCP arguments.
 * @param checkOperation The single-operation field check of the resolver.
 * @returns The serialized operations document, or undefined for a single
 *   operation.
 * @throws DocsInputError when both or neither field is given, a per-operation
 *   field is given beside operations, or an item is invalid.
 */
export function checkDocsLedgerInput(
  input: Readonly<Record<string, unknown>>,
  checkOperation: (input: Readonly<Record<string, unknown>>) => void,
): string | undefined {
  if (
    (input["operation"] === undefined) ===
    (input["operations"] === undefined)
  ) {
    throw new DocsInputError(
      "update_docs_ledger requires exactly one of operation and operations.",
    );
  }
  if (input["operations"] === undefined) {
    checkOperation(input);
    return undefined;
  }
  const allowed = new Set<string>([...DOCS_LEDGER_COMMON_FIELDS, "operations"]);
  for (const [field, value] of Object.entries(input)) {
    const present =
      value !== undefined && !(Array.isArray(value) && value.length === 0);
    if (present && !allowed.has(field)) {
      throw new DocsInputError(`operations does not accept ${field}.`);
    }
  }
  return serializeDocsLedgerOperations(
    validateDocsLedgerOperations(input["operations"]),
  );
}
