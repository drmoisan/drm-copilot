/**
 * Input resolver of `migrate_development_docs` (issue #1016, spec "Inputs / Outputs").
 *
 * Required: `workspace_root` (non-empty string) and `mode` (`"dry-run"` or
 * `"apply"`). Optional: `rename_decisions_path` and `report_directory`
 * (strings). Any other property is rejected before the service is called.
 */
import type { MigrateDevelopmentDocsInput } from "./lib/development-docs-migration/migrate-development-docs-service-call";
import { asToolArgumentObject } from "./mcp-tool-inputs";
import { normalizeWorkspaceRoot } from "./workflow-command-arguments";

const ALLOWED_KEYS: ReadonlySet<string> = new Set([
  "workspace_root",
  "mode",
  "rename_decisions_path",
  "report_directory",
]);

/**
 * Read an optional string property.
 *
 * @param args Tool arguments.
 * @param key Property name.
 * @returns The value, or undefined when absent.
 * @throws Error When the property is present and not a string.
 */
function optionalString(
  args: Readonly<Record<string, unknown>>,
  key: string,
): string | undefined {
  const value = args[key];
  if (value === undefined) {
    return undefined;
  }
  if (typeof value !== "string") {
    throw new Error(`${key} must be a string.`);
  }
  return value;
}

/**
 * Resolve and check the raw MCP arguments.
 *
 * @param rawInput Raw MCP tool arguments.
 * @returns The resolved input.
 * @throws Error For a missing or blank `workspace_root`, an invalid `mode`, a
 *   non-string optional field, or an unknown property.
 */
export function resolveMigrateDevelopmentDocsToolInput(
  rawInput: unknown,
): MigrateDevelopmentDocsInput {
  const args = asToolArgumentObject(rawInput);
  const extra = Object.keys(args)
    .filter((key) => !ALLOWED_KEYS.has(key))
    .sort();
  if (extra.length > 0) {
    throw new Error(`Unexpected input properties: ${extra.join(", ")}.`);
  }
  const workspaceRoot = normalizeWorkspaceRoot(args["workspace_root"]);
  const mode = args["mode"];
  if (mode !== "dry-run" && mode !== "apply") {
    throw new Error('mode is required and must be "dry-run" or "apply".');
  }
  const renameDecisionsPath = optionalString(args, "rename_decisions_path");
  const reportDirectory = optionalString(args, "report_directory");
  return {
    workspaceRoot,
    mode,
    ...(renameDecisionsPath === undefined ? {} : { renameDecisionsPath }),
    ...(reportDirectory === undefined ? {} : { reportDirectory }),
  };
}
