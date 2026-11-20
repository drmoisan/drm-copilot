/**
 * Input resolver of the two push-down integration tools (issue #1051, S42).
 *
 * The only accepted property is `workspace_root`, a non-empty string; a
 * missing, non-string or empty value and any extra property are rejected
 * before the service is called.
 */

import { asToolArgumentObject } from "./mcp-tool-inputs";
import { normalizeWorkspaceRoot } from "./workflow-command-arguments";

/** Resolved input of a push-down integration tool. */
export interface PushDownIntegrationToolInput {
  readonly workspaceRoot: string;
}

/**
 * Resolve and check the raw MCP arguments.
 *
 * @param rawInput Raw MCP tool arguments.
 * @returns The resolved input.
 * @throws Error When the arguments are not an object, carry a property other
 *   than `workspace_root`, or `workspace_root` is missing, not a string, or
 *   empty.
 */
export function resolvePushDownIntegrationToolInput(
  rawInput: unknown,
): PushDownIntegrationToolInput {
  const args = asToolArgumentObject(rawInput);
  const extra = Object.keys(args)
    .filter((key) => key !== "workspace_root")
    .sort();
  if (extra.length > 0) {
    throw new Error(`Unexpected input properties: ${extra.join(", ")}.`);
  }
  return { workspaceRoot: normalizeWorkspaceRoot(args["workspace_root"]) };
}
