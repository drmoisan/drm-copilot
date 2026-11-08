---
name: docs-inventory-surface
description: 'Inventory the documented surface of a repository (commands, options, routes, configuration keys, public symbols) through the docs MCP tools. Use as the first step of docs-architect work.'
---

# Docs Inventory Surface

## When to Use This Skill

[docs-architect](../../../.claude/agents/docs-architect.md) runs this skill to
build the surface inventory and compare it with the persisted snapshot named by
the profile `artifact_paths.inventory_snapshot`.

## Prerequisites

Root steps run the docs helper library at `.claude/lib/docs/` under PowerShell 7.4 or later.

## Steps

1. Call `run_docs_inventory` with `workspace_root`, `profile`, and optionally
   `analyzers` and `revision` (40 or 64 lowercase hexadecimal characters). The tool
   returns the snapshot in its result and never writes it.
2. Compare the returned elements with the persisted snapshot: list added,
   removed and changed element ids.
3. When the snapshot must be persisted, report that the root step below is
   required; the role does not write the snapshot.
   Root step: `pwsh -NoProfile -File .claude/lib/docs/Invoke-DocsCommand.ps1 -Command inventory -Profile docs/documentation-estate/docs-profile.json -Write`

## Result

Report the snapshot path, the element counts by kind and the element ids that
changed.
