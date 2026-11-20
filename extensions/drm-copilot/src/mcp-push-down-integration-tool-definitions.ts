/**
 * MCP tool definitions of the two push-down integration tools (issue #1051,
 * S23, S32, S34, S43).
 *
 * Both tools take only `workspace_root`, reject any other property, and are
 * annotated read-only and closed-world. One shared constant is spread into
 * both definition surfaces, following the docs-tool pattern.
 */

import { type ToolDefinition } from "./mcp-repo-automation-tool-definitions";
import { workspaceRootProperty } from "./mcp-push-down-schema-properties";

/** Names of the push-down integration tools, in registration order. */
export const PUSH_DOWN_INTEGRATION_TOOLS = [
  "detect_push_down_integration",
  "validate_push_down_integration",
] as const;

/** One push-down integration tool name. */
export type PushDownIntegrationToolName =
  (typeof PUSH_DOWN_INTEGRATION_TOOLS)[number];

/** A tool definition whose name is one of the push-down integration tools. */
export interface PushDownIntegrationToolDefinition extends Omit<
  ToolDefinition,
  "name"
> {
  readonly name: PushDownIntegrationToolName;
}

/**
 * Build one read-only definition whose only input is `workspace_root`.
 *
 * @param name Tool name.
 * @param description Tool description.
 * @returns The definition.
 */
function definition(
  name: PushDownIntegrationToolName,
  description: string,
): PushDownIntegrationToolDefinition {
  return {
    name,
    description,
    inputSchema: {
      type: "object",
      properties: { workspace_root: workspaceRootProperty },
      required: ["workspace_root"],
      additionalProperties: false,
    },
    annotations: { readOnlyHint: true, openWorldHint: false },
  };
}

/** The two push-down integration tool definitions. */
export const PUSH_DOWN_INTEGRATION_TOOL_DEFINITIONS: ReadonlyArray<PushDownIntegrationToolDefinition> =
  [
    definition(
      "detect_push_down_integration",
      "Report the harness ecosystems and language packs of a push-down destination, its .github/workflows files with their jobs, the structured integration conflicts (each with an id, kind, path, detail and resolution options), and a summary of .push-down-integration-needed.json. Deterministic and read-only; calls no model.",
    ),
    definition(
      "validate_push_down_integration",
      "Check an integrated push-down destination against rules V1 to V5 (workflow subset read, CI data file, required check, coverage artifact path, manifest hashes) and return a pass or fail verdict, the failures per rule, and the fixed list of what validation does not check. Deterministic and read-only; calls no model.",
    ),
  ];
