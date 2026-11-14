/**
 * Declarative input tables and resolvers for the six docs MCP tools (issue #1036).
 *
 * Each tool has one table that maps an input field to its PowerShell option of
 * `.claude/lib/docs/Invoke-DocsCommand.ps1` (kind `value`, `multi` or `switch`)
 * and to a grammar mirrored from `schemas/docs/v1/common.schema.json`. The
 * resolver rejects invalid input before any filesystem or process call and
 * emits the options in table order. PowerShell remains authoritative: anything
 * accepted here and rejected there returns exit 2 with `DOCS_CLI_ARGUMENTS`.
 */

import { DocsHostError } from "./docs-command-envelope";
import {
  DOCS_DIMENSION_STATES,
  DOCS_DIMENSIONS,
  DOCS_DISPOSITIONS,
  DOCS_LEDGER_COMMON_FIELDS,
  DOCS_LEDGER_OPERATIONS,
  DocsInputError,
  matchesDocsGrammar,
  type DocsGrammar,
} from "./mcp-tool-inputs-docs-grammar";
import { checkDocsLedgerInput } from "./mcp-tool-inputs-docs-ledger-batch";

export {
  DOCS_DIMENSION_STATES,
  DOCS_DIMENSIONS,
  DOCS_DISPOSITIONS,
  DOCS_ELEMENT_ID_PATTERN,
  DOCS_IDENTIFIER_PATTERN,
  DOCS_LEDGER_COMMON_FIELDS,
  DOCS_LEDGER_OPERATIONS,
  DOCS_LIMIT_PREFIX,
  DOCS_RELATIVE_PATH_PATTERN,
  DOCS_REVISION_PATTERN,
  DOCS_TEXT_PATTERN,
  DocsInputError,
  matchesDocsGrammar,
} from "./mcp-tool-inputs-docs-grammar";
export type { DocsGrammar } from "./mcp-tool-inputs-docs-grammar";

export const DOCS_ACTOR_KINDS = ["human", "agent", "tool"] as const;
export const DOCS_VALIDATE_MODES = [
  "profile",
  "ledger",
  "matrix",
  "docs-complete",
] as const;

/** Declared type of one input field. */
export type DocsFieldSpec =
  | { readonly type: "string"; readonly grammar: DocsGrammar }
  | { readonly type: "enum"; readonly values: ReadonlyArray<string> }
  | {
      readonly type: "string-array";
      readonly grammar: DocsGrammar;
      readonly unique: boolean;
    }
  | { readonly type: "boolean" }
  | { readonly type: "object-array" };

/** One row of a declarative input table. */
export interface DocsInputRow {
  readonly field: string;
  readonly option: string;
  readonly kind: "value" | "multi" | "switch";
  readonly spec: DocsFieldSpec;
  readonly required: boolean;
}

/** The declarative table of one tool. */
export interface DocsToolInputTable {
  readonly subcommand: string;
  readonly rows: ReadonlyArray<DocsInputRow>;
}

/** Builds one row; the option kind follows from the field type. */
function row(
  field: string,
  option: string,
  spec: DocsFieldSpec,
  required = false,
): DocsInputRow {
  const kind =
    spec.type === "string-array"
      ? "multi"
      : spec.type === "boolean"
        ? "switch"
        : "value";
  return { field, option, kind, spec, required };
}

const PATH: DocsFieldSpec = { type: "string", grammar: "relative-path" };
const IDENTIFIER: DocsFieldSpec = { type: "string", grammar: "identifier" };
const REVISION: DocsFieldSpec = { type: "string", grammar: "revision" };
const TEXT: DocsFieldSpec = { type: "string", grammar: "text" };
const oneOf = (values: ReadonlyArray<string>): DocsFieldSpec => ({
  type: "enum",
  values,
});
const listOf = (grammar: DocsGrammar, unique = false): DocsFieldSpec => ({
  type: "string-array",
  grammar,
  unique,
});
const PROFILE_ROW = row("profile", "Profile", PATH);

/**
 * One declarative input table per docs tool, in union order. Rows are listed
 * in the option order of the committed dispatch table of
 * `Invoke-DocsCommand.ps1`, which is also the emission order.
 */
export const DOCS_TOOL_INPUT_TABLES = {
  run_docs_check: {
    subcommand: "check",
    rows: [PROFILE_ROW, row("paths", "Path", listOf("relative-path"))],
  },
  run_docs_inventory: {
    subcommand: "inventory",
    rows: [
      PROFILE_ROW,
      row("analyzers", "Analyzer", listOf("identifier")),
      row("revision", "Revision", REVISION),
    ],
  },
  run_docs_coverage: { subcommand: "coverage", rows: [PROFILE_ROW] },
  update_docs_ledger: {
    subcommand: "update-ledger",
    rows: [
      PROFILE_ROW,
      row("operation", "Operation", oneOf(DOCS_LEDGER_OPERATIONS)),
      row("operations", "Operations", { type: "object-array" }),
      row("element", "Element", { type: "string", grammar: "element-id" }),
      row("limit", "Limit", { type: "string", grammar: "limit" }),
      row("disposition", "Disposition", oneOf(DOCS_DISPOSITIONS)),
      row("pages", "Page", listOf("page-reference", true)),
      row("rationale", "Rationale", TEXT),
      row("owner", "Owner", IDENTIFIER),
      row("target", "Target", TEXT),
      row("dimension", "Dimension", oneOf(DOCS_DIMENSIONS)),
      row("state", "State", oneOf(DOCS_DIMENSION_STATES)),
      row("claim", "Claim", TEXT),
      row("actor_kind", "ActorKind", oneOf(DOCS_ACTOR_KINDS), true),
      row("actor_id", "ActorId", IDENTIFIER, true),
      row("write", "Write", { type: "boolean" }),
    ],
  },
  generate_docs_reference: {
    subcommand: "generate-reference",
    rows: [
      PROFILE_ROW,
      row("snapshot", "Snapshot", PATH),
      row("output_directory", "OutputDirectory", PATH),
      row("path_prefixes", "PathPrefix", listOf("relative-path")),
    ],
  },
  validate_docs_artifacts: {
    subcommand: "validate",
    rows: [
      PROFILE_ROW,
      row("mode", "Mode", oneOf(DOCS_VALIDATE_MODES), true),
      row("revision", "Revision", REVISION, true),
    ],
  },
} as const satisfies Readonly<Record<string, DocsToolInputTable>>;

/** The six docs tool names. */
export type DocsToolName = keyof typeof DOCS_TOOL_INPUT_TABLES;

/** Target rule of one `update-ledger` operation. */
export type DocsLedgerTarget = "either" | "element" | "none";

/** Per-operation field rule of `update_docs_ledger` (1023 `update-ledger` contract). */
export interface DocsLedgerOperationRule {
  readonly required: ReadonlyArray<string>;
  readonly optional: ReadonlyArray<string>;
  readonly target: DocsLedgerTarget;
  readonly onePage: boolean;
}

function rule(
  target: DocsLedgerTarget,
  onePage: boolean,
  required: ReadonlyArray<string>,
  optional: ReadonlyArray<string> = [],
): DocsLedgerOperationRule {
  return { required, optional, target, onePage };
}

/** Per-operation table; `element` xor `limit` for target `either` (D-1). */
export const DOCS_LEDGER_OPERATION_RULES: Readonly<
  Record<(typeof DOCS_LEDGER_OPERATIONS)[number], DocsLedgerOperationRule>
> = {
  "set-disposition": rule(
    "either",
    false,
    ["disposition"],
    ["pages", "rationale", "owner", "target"],
  ),
  "remove-entry": rule("either", false, []),
  pin: rule("element", true, ["pages"], ["claim"]),
  unpin: rule("element", true, ["pages"]),
  "set-dimension": rule(
    "element",
    true,
    ["pages", "dimension", "state"],
    ["rationale"],
  ),
  "sync-refs": rule("none", false, []),
  "bind-page-refs": rule("none", false, []),
};

/** A validated docs tool call. */
export interface ResolvedDocsToolInput {
  readonly workspaceRoot: string;
  readonly subcommand: string;
  /** Option tokens in declarative-table order, ready to follow `-Json`. */
  readonly options: ReadonlyArray<string>;
  /** Standard input: the operations document of an update_docs_ledger batch. */
  readonly stdin?: string;
}

type InputRecord = Readonly<Record<string, unknown>>;

function checkString(
  field: string,
  grammar: DocsGrammar,
  item: unknown,
): string {
  if (typeof item !== "string") {
    throw new DocsInputError(`${field} must be a string.`);
  }
  if (item.length === 0) {
    throw new DocsInputError(`${field} must not be empty.`);
  }
  if (item.startsWith("-")) {
    throw new DocsInputError(`${field} must not begin with '-'.`);
  }
  if (!matchesDocsGrammar(grammar, item)) {
    throw new DocsInputError(
      `${field} value ${JSON.stringify(item)} does not match the ${grammar} grammar.`,
    );
  }
  return item;
}

function emitRow(row: DocsInputRow, raw: unknown): ReadonlyArray<string> {
  const spec = row.spec;
  const name = `-${row.option}`;
  switch (spec.type) {
    case "boolean":
      if (typeof raw !== "boolean") {
        throw new DocsInputError(`${row.field} must be a boolean.`);
      }
      return raw ? [name] : [];
    case "enum":
      if (typeof raw !== "string" || !spec.values.includes(raw)) {
        throw new DocsInputError(
          `${row.field} must be one of ${spec.values.join(", ")}.`,
        );
      }
      return [name, raw];
    case "object-array":
      return [name, "-"];
    case "string":
      return [name, checkString(row.field, spec.grammar, raw)];
    case "string-array": {
      if (!Array.isArray(raw)) {
        throw new DocsInputError(`${row.field} must be an array of strings.`);
      }
      const items = raw.map((item: unknown) =>
        checkString(row.field, spec.grammar, item),
      );
      if (spec.unique && new Set(items).size !== items.length) {
        throw new DocsInputError(`${row.field} must not repeat an entry.`);
      }
      return items.flatMap((item) => [name, item]);
    }
  }
}

function isPresent(input: InputRecord, field: string): boolean {
  const raw = input[field];
  return raw !== undefined && !(Array.isArray(raw) && raw.length === 0);
}

function isLedgerOperation(
  candidate: unknown,
): candidate is (typeof DOCS_LEDGER_OPERATIONS)[number] {
  return DOCS_LEDGER_OPERATIONS.some((operation) => operation === candidate);
}

function checkLedgerOperation(input: InputRecord): void {
  const operation = input["operation"];
  if (!isLedgerOperation(operation)) {
    return;
  }
  const rule = DOCS_LEDGER_OPERATION_RULES[operation];
  const permitted = new Set<string>([
    ...DOCS_LEDGER_COMMON_FIELDS,
    ...rule.required,
    ...rule.optional,
    ...(rule.target === "either" ? ["element", "limit"] : []),
    ...(rule.target === "element" ? ["element"] : []),
  ]);
  for (const field of Object.keys(input)) {
    if (isPresent(input, field) && !permitted.has(field)) {
      throw new DocsInputError(
        `operation ${operation} does not accept ${field}.`,
      );
    }
  }
  for (const field of rule.required) {
    if (!isPresent(input, field)) {
      throw new DocsInputError(`operation ${operation} requires ${field}.`);
    }
  }
  const hasElement = isPresent(input, "element");
  const hasLimit = isPresent(input, "limit");
  if (rule.target === "either" && hasElement === hasLimit) {
    throw new DocsInputError(
      `operation ${operation} requires exactly one of element and limit.`,
    );
  }
  if (rule.target === "element" && !hasElement) {
    throw new DocsInputError(`operation ${operation} requires element.`);
  }
  if (rule.onePage) {
    const pages = input["pages"];
    if (
      !Array.isArray(pages) ||
      pages.length !== 1 ||
      typeof pages[0] !== "string" ||
      pages[0].includes("#")
    ) {
      throw new DocsInputError(
        `operation ${operation} requires exactly one page without an anchor.`,
      );
    }
  }
}

function readWorkspaceRoot(input: InputRecord): string {
  const raw = input["workspace_root"];
  if (typeof raw !== "string" || raw.trim().length === 0) {
    throw new DocsHostError(
      "DOCS_WORKSPACE_ROOT_INVALID",
      "workspace_root is required and must be a non-empty absolute path string.",
    );
  }
  return raw.trim();
}

/**
 * Validates one docs tool input and maps it to its subcommand and options.
 *
 * @param toolName The docs tool.
 * @param rawInput The raw MCP arguments.
 * @returns The workspace root, the subcommand and the ordered option tokens.
 * @throws DocsInputError for an invalid input; DocsHostError with
 *   `DOCS_WORKSPACE_ROOT_INVALID` for a missing or non-string workspace root.
 */
export function resolveDocsToolInput(
  toolName: DocsToolName,
  rawInput: unknown,
): ResolvedDocsToolInput {
  if (
    typeof rawInput !== "object" ||
    rawInput === null ||
    Array.isArray(rawInput)
  ) {
    throw new DocsInputError(`${toolName} input must be an object.`);
  }
  const input = rawInput as InputRecord;
  const workspaceRoot = readWorkspaceRoot(input);
  const table: DocsToolInputTable = DOCS_TOOL_INPUT_TABLES[toolName];
  const known = new Set<string>([
    "workspace_root",
    ...table.rows.map((row) => row.field),
  ]);
  for (const key of Object.keys(input)) {
    if (!known.has(key)) {
      throw new DocsInputError(`${toolName} does not accept ${key}.`);
    }
  }
  const options: string[] = [];
  for (const row of table.rows) {
    const raw = input[row.field];
    if (raw === undefined) {
      if (row.required) {
        throw new DocsInputError(`${toolName} requires ${row.field}.`);
      }
      continue;
    }
    options.push(...emitRow(row, raw));
  }
  const stdin =
    toolName === "update_docs_ledger"
      ? checkDocsLedgerInput(input, checkLedgerOperation)
      : undefined;
  return {
    workspaceRoot,
    subcommand: table.subcommand,
    options,
    ...(stdin === undefined ? {} : { stdin }),
  };
}
