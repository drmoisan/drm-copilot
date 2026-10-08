"""Promotion-entry MCP tool resolution for orchestrator checkpoints.

Purpose:
    Hold the feature-type and bug-type promotion-entry tool constants and the
    helper that resolves a route's required promotion-entry tool from the
    checkpoint's ``promotion-type``. This module mirrors the TypeScript module
    ``extensions/drm-copilot/src/lib/validate/orchestrator-state-promotion-tools.ts``.

Usage:
    Import the names listed in ``__all__`` from this module. The
    routing-contract module re-exports every one of them, so existing callers
    continue to resolve them from their original import location unchanged.

Invariants / Constraints:
    - Only a ``promotion-type`` of exactly ``"bug"`` swaps the promotion-entry
      tool; every other value leaves the route list unchanged.
    - This module imports nothing from ``scripts.dev_tools``.

Side Effects:
    None.
"""

from __future__ import annotations

from typing import Any

# Declare the module's intended exported surface. Listing the private helper
# here marks it as a deliberate re-export consumed by the routing-contract
# module, so static analysis does not flag it as unused locally or as
# private-usage when imported across the module boundary.
__all__ = [
    "FEATURE_PROMOTION_ENTRY_TOOL",
    "BUG_PROMOTION_ENTRY_TOOL",
    "_resolve_promotion_entry_tools",
]

# The routing matrix records the feature-type promotion-entry MCP tool in every
# route's `required_mcp_tools`. A bug-type promotion genuinely exercises the
# bug-type tool instead, so the validator resolves the promotion-entry tool from
# the checkpoint's `promotion-type` rather than treating the matrix value as
# literal for every promotion type.
FEATURE_PROMOTION_ENTRY_TOOL = "new_potential_entry"
BUG_PROMOTION_ENTRY_TOOL = "new_potential_bug_entry"


def _resolve_promotion_entry_tools(
    required_mcp_tools: list[str], state: dict[str, Any]
) -> list[str]:
    """Resolve the promotion-entry MCP tool to the checkpoint's promotion type.

    Purpose:
        The routing matrix records the feature-type promotion-entry tool
        (`new_potential_entry`) in every route's `required_mcp_tools`. A bug-type
        promotion genuinely exercises `new_potential_bug_entry` instead, so a
        bug-type checkpoint can never truthfully record a `new_potential_entry`
        receipt. This helper substitutes the bug-type promotion-entry tool for
        the feature-type one when, and only when, the checkpoint's hyphenated
        `promotion-type` key is exactly `"bug"`, leaving every other required
        tool untouched and preserving matrix order.

    Args:
        required_mcp_tools (list[str]): The route's declared `required_mcp_tools`
            list from the routing matrix, in matrix order.
        state (dict[str, Any]): Parsed checkpoint state. The promotion type is
            read from the hyphenated `promotion-type` key.

    Returns:
        list[str]: A new list in the same order as `required_mcp_tools`. When the
        checkpoint's `promotion-type` is exactly `"bug"`, each occurrence of
        `new_potential_entry` is replaced by `new_potential_bug_entry`. For a
        `feature` promotion type, an absent key, a non-string value, or any other
        value, the list is returned unchanged so feature and legacy checkpoints
        validate exactly as before.

    Raises:
        None.

    Side Effects:
        None.
    """

    promotion_type = state.get("promotion-type")
    # Only an explicit bug-type promotion swaps the promotion-entry tool.
    # Feature, absent, and any non-"bug" value keep the matrix list unchanged so
    # feature-type and legacy/absent checkpoints validate byte-identically to
    # the prior behavior.
    if promotion_type != "bug":
        return list(required_mcp_tools)

    # Substitute the bug-type promotion-entry tool for the feature-type one while
    # preserving matrix order and every other required tool exactly.
    return [
        BUG_PROMOTION_ENTRY_TOOL if tool == FEATURE_PROMOTION_ENTRY_TOOL else tool
        for tool in required_mcp_tools
    ]
