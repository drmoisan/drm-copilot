/**
 * Promotion-type resolution of the promotion-entry MCP tool for a checkpoint.
 *
 * Purpose:
 *     A bug-type checkpoint (`promotion-type` equal to `"bug"`) creates its
 *     potential entry with the bug variant of the promotion-entry tool. This
 *     module resolves a route's declared MCP tool list against that promotion
 *     type. It mirrors the Python authority in
 *     `scripts/dev_tools/_orchestrator_state_routing.py` and the PowerShell
 *     authority so all three runtimes produce the same verdict.
 *
 * Boundaries:
 *     Pure logic only. No I/O, no clock, no randomness, no module imports.
 */

/** MCP tool that creates a feature-type potential entry. */
export const FEATURE_PROMOTION_ENTRY_TOOL = "new_potential_entry";

/** MCP tool that creates a bug-type potential entry. */
export const BUG_PROMOTION_ENTRY_TOOL = "new_potential_bug_entry";

/** The exact `promotion-type` value that selects the bug entry tool. */
export const BUG_PROMOTION_TYPE = "bug";

/** The checkpoint key that carries the promotion type (hyphenated form only). */
export const PROMOTION_TYPE_KEY = "promotion-type";

/**
 * Resolve the required MCP tool list for a checkpoint's promotion type.
 *
 * Substitution happens only when `state["promotion-type"]` is strictly equal to
 * the string `"bug"` (no trimming, no case folding, no coercion). Every other
 * value, including an absent key, `null`, and non-string values, yields a copy
 * of the input. Each element strictly equal to the feature tool is replaced by
 * the bug tool in place, preserving order and every other element.
 *
 * @param requiredMcpTools - The route's declared `required_mcp_tools` list.
 * @param state - The checkpoint object read for its `promotion-type` key.
 * @returns A new array; neither argument is mutated.
 */
export function resolvePromotionEntryTools(
  requiredMcpTools: string[],
  state: Record<string, unknown>,
): string[] {
  if (state[PROMOTION_TYPE_KEY] !== BUG_PROMOTION_TYPE) {
    return [...requiredMcpTools];
  }
  return requiredMcpTools.map((tool) =>
    tool === FEATURE_PROMOTION_ENTRY_TOOL ? BUG_PROMOTION_ENTRY_TOOL : tool,
  );
}
