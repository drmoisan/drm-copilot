# promotion-receipt-destination-unverified (Issue #623)

- Date captured: 2026-09-29
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/promotion-receipt-destination-unverified-623/ (Issue #623)

> Scope note: GitHub issue #623 originally bundled three independent MCP-server tooling defects. The 2026-09-29 consolidation comment on #623 is authoritative for scope: this folder tracks only item 2. Item 1 (zero PoshQC coverage) moved to #527 and item 3 (bug-route tool-name mismatch) moved to #405. Neither is in scope here.

- Issue: #623
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/623
- Last Updated: 2026-09-29
- Work Mode: full-bug

## Summary

The bundled promotion-to-issue MCP tool returns a success receipt naming a `destination_path` under `docs/features/potential/promoted/`, but in at least one observed instance no file existed at that path afterwards. The source potential entry is removed from `docs/features/potential/` regardless, so the potential document is lost while the receipt asserts it was relocated.

Per the consolidation comment, `extensions/drm-copilot/src/lib/potential-to-issue/promotion.ts:437-442` and `promotion-filesystem.ts:89` perform the rename with no existence check afterwards.

## Environment

- OS/version: Windows 11 (consumer TaskMaster repository)
- Command/flags used: promotion-to-issue MCP tool (`mcp__drm-copilot__potential_to_issue`)
- Originally reported as TaskMaster issue #554 (2026-09-02)

## Steps to Reproduce

1. Create a potential entry under `docs/features/potential/`.
2. Promote it through the promotion-to-issue MCP tool.
3. Observe the receipt `destination_path` under `docs/features/potential/promoted/` and check whether a file exists at that path.

## Expected Behavior

After the rename, the tool verifies that the destination file exists. If it does not, the tool fails loudly with a specific error instead of returning a success receipt.

## Actual Behavior

The tool returns a success receipt whose `destination_path` does not exist on disk in at least one observed instance. The failure was intermittent: other invocations in the same session wrote the promoted record correctly.

## Suggested Direction

Verify that the destination exists after the rename and fail loudly otherwise. Also determine whether the Python promotion path has the same gap; include it only if research confirms the same defect.

## Acceptance Criteria

Acceptance criteria for this full-bug item are authored in `spec.md`.
