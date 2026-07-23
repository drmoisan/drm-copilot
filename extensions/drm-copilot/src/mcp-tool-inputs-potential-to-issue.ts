import {
  normalizeRequiredText,
  normalizeWorkspaceDestinationPath,
  normalizeWorkspaceRoot,
  validatePromotionType,
  validateWorkMode,
} from "./workflow-command-arguments";
import {
  asToolArgumentObject,
  type PotentialToIssueToolInput,
} from "./mcp-tool-inputs";

/**
 * Resolves the `potential_to_issue` MCP tool input, failing closed on an
 * omitted `workspace_root` and resolving a workspace-relative `potential_path`
 * against the resolved workspace root.
 *
 * Extracted from `mcp-tool-inputs.ts` (following the
 * `mcp-tool-inputs-push-down.ts` precedent) so the base module stays within the
 * 500-line production-file limit.
 *
 * @param rawInput The raw MCP tool argument object.
 * @param fallbackWorkspaceRoot Optional explicit workspace-root fallback used by
 *   the VS Code command surface; MCP handlers pass nothing so an omitted
 *   `workspace_root` fails closed.
 * @returns The resolved, validated potential-to-issue tool input.
 * @throws Error when `workspace_root` is omitted with no fallback, or when
 *   required fields are missing or invalid.
 */
export function resolvePotentialToIssueToolInput(
  rawInput: unknown,
  fallbackWorkspaceRoot?: string,
): PotentialToIssueToolInput {
  const args = asToolArgumentObject(rawInput);
  const workspaceRoot = normalizeWorkspaceRoot(
    args["workspace_root"],
    fallbackWorkspaceRoot,
  );
  // Resolve a workspace-relative potential_path against the resolved
  // workspace_root (not the server's process.cwd()) so the tool honors its
  // documented "Absolute or workspace-relative path" contract. An absolute
  // path is preserved unchanged by normalizeWorkspaceDestinationPath.
  const potentialPath = normalizeWorkspaceDestinationPath(
    normalizeRequiredText(args["potential_path"], "potential_path"),
    workspaceRoot,
    "potential_path",
  );
  return {
    workspaceRoot,
    potentialPath,
    promotionType: validatePromotionType(
      normalizeRequiredText(args["promotion_type"], "promotion_type"),
      "promotion_type",
    ),
    workMode: validateWorkMode(
      normalizeRequiredText(args["work_mode"], "work_mode"),
      "work_mode",
    ),
  };
}
