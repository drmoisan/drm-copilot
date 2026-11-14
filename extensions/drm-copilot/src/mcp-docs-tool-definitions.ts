/**
 * MCP tool definitions for the six docs tools (issue #1036).
 *
 * The input schema of each tool is derived from its declarative input table in
 * `mcp-tool-inputs-docs.ts`, so the advertised fields, enums and required list
 * cannot drift from the resolver. One shared constant is spread into both
 * definition surfaces.
 */

import { type ToolDefinition } from "./mcp-repo-automation-tool-definitions";
import { workspaceRootProperty } from "./mcp-push-down-schema-properties";
import {
  DOCS_TOOL_INPUT_TABLES,
  type DocsInputRow,
  type DocsToolName,
} from "./mcp-tool-inputs-docs";

/** A tool definition whose name is one of the docs tools. */
export interface DocsToolDefinition extends Omit<ToolDefinition, "name"> {
  readonly name: DocsToolName;
}

/** The only docs tool that can change ledger, matrix or pin artifacts. */
export const DOCS_MUTATING_TOOLS = ["update_docs_ledger"] as const;

const FIELD_DESCRIPTIONS: Readonly<Record<string, string>> = {
  profile:
    "Workspace-relative docs profile path; PowerShell resolves its default when omitted.",
  paths: "Workspace-relative page paths to check; all pages when omitted.",
  analyzers:
    "Analyzer identifiers to run; all configured analyzers when omitted.",
  revision: "Full 40- or 64-character lowercase hexadecimal revision.",
  operation:
    "Ledger operation; exactly one of operation and operations is given.",
  operations:
    "Batch of ledger operations (issue #1173), each an object with the operation fields of this tool; sync-refs is not a batch item. Sent to update-ledger -Operations - on standard input and applied all-or-nothing: one load, one rule comparison, one write.",
  element: "Element id (<kind>-<sha256>).",
  limit:
    "Diagnostic identifier with the diagnostic- prefix; the alternative to element for set-disposition and remove-entry.",
  disposition: "Ledger disposition.",
  pages:
    "Page references (<relative path> or <relative path>#<anchor>); no repeated entry.",
  rationale: "Rationale text; must not begin with '-'.",
  owner: "Owner identifier.",
  target: "Target text; must not begin with '-'.",
  dimension: "Parity dimension.",
  state: "Parity state.",
  claim: "Evidence claim text; must not begin with '-'.",
  actor_kind: "Kind of actor recorded on the change.",
  actor_id: "Actor identifier recorded on the change.",
  write: "Commit the ledger change; the default false is a dry run.",
  snapshot: "Workspace-relative inventory snapshot path.",
  output_directory: "Workspace-relative output directory for the dry run.",
  path_prefixes:
    "Workspace-relative path prefixes (issue #1173); only snapshot elements whose path starts with one of them are generated. All elements when omitted.",
  mode: "Validation mode.",
};

function fieldSchema(row: DocsInputRow): object {
  const description = FIELD_DESCRIPTIONS[row.field] ?? row.field;
  switch (row.spec.type) {
    case "string":
      return { type: "string", minLength: 1, description };
    case "enum":
      return { type: "string", enum: [...row.spec.values], description };
    case "boolean":
      return { type: "boolean", default: false, description };
    case "string-array":
      return {
        type: "array",
        items: { type: "string", minLength: 1 },
        ...(row.spec.unique ? { uniqueItems: true } : {}),
        description,
      };
    case "object-array":
      return {
        type: "array",
        items: { type: "object" },
        minItems: 1,
        description,
      };
  }
}

function definition(
  name: DocsToolName,
  description: string,
  readOnly: boolean,
): DocsToolDefinition {
  const rows: ReadonlyArray<DocsInputRow> = DOCS_TOOL_INPUT_TABLES[name].rows;
  const properties: Record<string, object> = {
    workspace_root: workspaceRootProperty,
  };
  for (const row of rows) {
    properties[row.field] = fieldSchema(row);
  }
  return {
    name,
    description,
    inputSchema: {
      type: "object",
      properties,
      required: [
        "workspace_root",
        ...rows.filter((row) => row.required).map((row) => row.field),
      ],
      additionalProperties: false,
    },
    annotations: readOnly
      ? { readOnlyHint: true, openWorldHint: false }
      : { readOnlyHint: false, destructiveHint: true, openWorldHint: false },
  };
}

/** The six docs tool definitions, in union order. */
export const DOCS_TOOL_DEFINITIONS: ReadonlyArray<DocsToolDefinition> = [
  definition(
    "run_docs_check",
    "Check documentation pages through the workspace's Invoke-DocsCommand.ps1 -Command check -Json and return the envelope with exit code and findings. Requires pwsh 7.4 and the pushed-down .claude/lib/docs.",
    true,
  ),
  definition(
    "run_docs_inventory",
    "Build the surface inventory through Invoke-DocsCommand.ps1 -Command inventory -Json and return the snapshot in the envelope result without writing it.",
    true,
  ),
  definition(
    "run_docs_coverage",
    "Report documentation coverage through Invoke-DocsCommand.ps1 -Command coverage -Json.",
    true,
  ),
  definition(
    "update_docs_ledger",
    "Change the docs coverage ledger, parity matrix or evidence pins through Invoke-DocsCommand.ps1 -Command update-ledger -Json. A dry run unless write is true; the only mutating docs tool.",
    false,
  ),
  definition(
    "generate_docs_reference",
    "Plan generated reference pages through Invoke-DocsCommand.ps1 -Command generate-reference -Json as a dry run; never writes pages.",
    true,
  ),
  definition(
    "validate_docs_artifacts",
    "Validate docs artifacts through Invoke-DocsCommand.ps1 -Command validate -Json for one mode and revision; never persists a receipt.",
    true,
  ),
];
