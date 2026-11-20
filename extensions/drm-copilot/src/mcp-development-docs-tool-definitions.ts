/**
 * MCP tool definition of `migrate_development_docs` (issue #1016).
 *
 * One shared constant is spread into both definition surfaces, directly before
 * the docs tools.
 */
import { type ToolDefinition } from "./mcp-repo-automation-tool-definitions";
import { workspaceRootProperty } from "./mcp-push-down-schema-properties";

/** The migration tool definition list. */
export const DEVELOPMENT_DOCS_TOOL_DEFINITIONS: ReadonlyArray<ToolDefinition> =
  [
    {
      name: "migrate_development_docs",
      description:
        "Plan or apply the move of development records from docs/ to .dev/ (issue #1016). The dry run writes nothing outside report_directory; apply mode moves with git mv, renames feature folders, rewrites references and requires a decision file when the dry run reports held items or open global choices.",
      inputSchema: {
        type: "object",
        properties: {
          workspace_root: workspaceRootProperty,
          mode: {
            type: "string",
            enum: ["dry-run", "apply"],
            description: "dry-run reports the plan; apply performs it.",
          },
          rename_decisions_path: {
            type: "string",
            description:
              "Decision file (folder-rename-decisions.<UTC>.json), absolute or relative to workspace_root; required by apply when the dry run reports held items or open global choices.",
          },
          report_directory: {
            type: "string",
            description:
              "Directory, absolute or relative to workspace_root, for the Markdown and JSON reports; when omitted no report file is written.",
          },
        },
        required: ["workspace_root", "mode"],
        additionalProperties: false,
      },
      annotations: { destructiveHint: true, openWorldHint: false },
    },
  ];
